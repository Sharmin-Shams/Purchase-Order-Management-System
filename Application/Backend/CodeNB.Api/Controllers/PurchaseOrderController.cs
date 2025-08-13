using CodeNB.Api.Models;
using CodeNB.Model;
using CodeNB.Model.Dtos;
using CodeNB.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System;
using System.Security.Claims;
using System.Text.RegularExpressions;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace CodeNB.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PurchaseOrderController : ControllerBase
    {
        private readonly IPurchaseOrderService purchaseOrderService;
        private readonly IEmployeeService employeeService;

        public PurchaseOrderController(IPurchaseOrderService purchaseOrderService,IEmployeeService employeeService)
        {
            this.purchaseOrderService = purchaseOrderService;
            this.employeeService = employeeService;
        }
        //// GET: api/<PurchaseOrderController>
        //[HttpGet]
        //public IEnumerable<string> Get()
        //{
        //    return new string[] { "value1", "value2" };
        //}

        //// GET api/<PurchaseOrderController>/5
        //[HttpGet("{id}")]
        //public string Get(int id)
        //{
        //    return "value";
        //}

        // POST api/<PurchaseOrderController>

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [Authorize]
        public async Task<ActionResult<ApiMessageResponse>> Create([FromBody] PurchaseOrder purchaseOrder)
        {
            try
            {
                if (purchaseOrder == null)
                {
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "Invalid request. Purchase order data is required."
                    });
                }

                //// Get employee ID from JWT token

                //  int employeeId = purchaseOrder.EmployeeID;
                var employeeIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (!int.TryParse(employeeIdClaim, out int employeeId))
                {
                    // Handle error if claim is missing or not an integer
                    return Unauthorized(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status401Unauthorized,
                        Message = "Invalid or missing employee ID in token."
                    });
                }
                purchaseOrder.EmployeeID =employeeId;
                var result = await purchaseOrderService.CreatePurchaseOrderAsync(purchaseOrder);

                if (result.Errors != null && result.Errors.Count > 0)
                {
                    return BadRequest(new ApiErrorsResponse<ValidationError>
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Errors = result.Errors
                    });
                }
                return StatusCode(StatusCodes.Status201Created, new
                {
                    Status = StatusCodes.Status201Created,
                    Message = "Purchase order created successfully.",
                    PurchaseOrderNumber = result.PurchaseOrderNumber.ToString("D8") 
                });

               
            }
            catch(Exception)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new ApiMessageResponse
                {
                    Status = StatusCodes.Status500InternalServerError,
                    Message = "Something went wrong while processing your request. Please try again later."
                });
            }
        }

        [HttpGet("search")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [Authorize(Roles = $"{nameof(UserRole.CEO)},{nameof(UserRole.RegularSupervisor)},{nameof(UserRole.HRSupervisor)}")]
        public async Task<ActionResult<List<DepartmentSearchResultDto>>> Search([FromQuery] int? departmentId)
        {

            if (departmentId == null)
            {
                return BadRequest(new ApiMessageResponse
                {
                    Status = StatusCodes.Status400BadRequest,
                    Message = "Invalid request. Department is required."
                });
            }
           

            var results = await purchaseOrderService.GetPurchaseOrderByDepartment(departmentId.Value);
            if (results == null)
            {
                return BadRequest(new ApiMessageResponse
                {
                    Status = StatusCodes.Status400BadRequest,
                    Message = "The selected department does not exist or is not active."
                });
            }

            return Ok(results);
        }

        [HttpGet("search/criteria")]

        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [Authorize]
        public async Task<ActionResult<List<PurchaseOrderSearchResultDto>>> SearchPurchaseOrder([FromQuery] PurchaseOrderSearchDto criteria)
        {
            try
            {

                if (!string.IsNullOrWhiteSpace(criteria.PurchaseOrderNumber))
                {
                  
                    if (!int.TryParse(criteria.PurchaseOrderNumber, out _))
                    {
                        return BadRequest(new ApiMessageResponse
                        {
                            Status = StatusCodes.Status400BadRequest,
                            Message = "Invalid purchase order number format."
                        });
                    }

                   
                }

                //// Get employee ID from JWT token

                int? employeeId = GetAuthenticatedEmployeeId();
                criteria.EmployeeID = employeeId;
                var results = await purchaseOrderService.GetPurchaseOrders(criteria);

                    if (results == null || !results.Any())
                    {
                        return NotFound(new ApiMessageResponse
                        {
                            Status = StatusCodes.Status404NotFound,
                            Message = "No purchase orders found matching the search criteria."
                        });
                    }
                
                return Ok(results);
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new ApiMessageResponse
                {
                    Status = StatusCodes.Status500InternalServerError,
                    Message = "Something went wrong while processing your request. Please try again later."
                });
            }
        }

     

        [HttpGet("{poNumber}/details")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [Authorize]
        public async Task<ActionResult<PurchaseOrderDto>> GetPurchaseOrderDetails(int poNumber)
        {
            try
            {

                int employeeId = GetAuthenticatedEmployeeId()
                                    ?? throw new UnauthorizedAccessException("Employee ID not found in token.");
                var result = await purchaseOrderService.GetPurchaseOrderDetails(poNumber);
               
                if (result == null)
                    return NotFound();

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new
                {
                    Message = "An error occurred while retrieving the purchase order.",
                    Error = ex.Message
                });
            }
        }


        [HttpGet("supervisor")]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
       [Authorize(Roles = $"{nameof(UserRole.HRSupervisor)},{nameof(UserRole.RegularSupervisor)}")]
        public async Task<ActionResult<List<POSupervisorSearchResultDTO>>> SearchPurchaseOrders([FromQuery] POSupervisorSearchDTO criteria)
        {
           

            var employeeIdClaim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (!int.TryParse(employeeIdClaim, out int employeeId))
            {
                throw new UnauthorizedAccessException("Unable to retrieve authenticated employee ID.");
            }
            criteria.EmployeeID = employeeId;
            var results = await purchaseOrderService.SearchPurchaseOrderBySupervisor(criteria);
           
            if (results == null || results.Count == 0)
            {
                // return Ok(new { Message = "No matching purchase orders found." });
                return Ok(results ?? new List<POSupervisorSearchResultDTO>());
            }

            return Ok(results);
        }

        [HttpPost("supervisor/item-decision")]
        [Authorize(Roles = $"{nameof(UserRole.HRSupervisor)},{nameof(UserRole.RegularSupervisor)}")]
        public async Task<ActionResult<bool>> ProcessItemDecision([FromBody] SupervisorItemDecisionDTO dto)
        {
            try
            {
                bool isLastItem = await purchaseOrderService.ProcessItemDecisionAsync(dto);
                return Ok(isLastItem); // frontend uses this to prompt for PO closure if true
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Failed to process item decision.", Error = ex.Message });
            }
        }

        [HttpPost("supervisor/close")]
        // [Authorize(Roles = "RegularSupervisor,HRSupervisor")]
        [Authorize(Roles = $"{nameof(UserRole.HRSupervisor)},{nameof(UserRole.RegularSupervisor)}")]
        public async Task<ActionResult> ClosePurchaseOrder([FromBody] int purchaseOrderNumber)
        {
            try
            {
                await purchaseOrderService.ClosePurchaseOrderAsync(purchaseOrderNumber);
                return Ok(new { Message = "Purchase order closed and employee notified." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Failed to close purchase order.", Error = ex.Message });
            }


            //try
            //{
            //    await purchaseOrderService.ClosePurchaseOrderAsync(purchaseOrderNumber);
            //    return Ok(new { Message = "PO closed and employee notified." });
            //}
           
            //catch
            //{
            //    return StatusCode(500, new { Message = "Unexpected error occurred." });
            //}
        }
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [HttpPut("{id}")]

        public async Task<ActionResult> UpdatePurchaseOrder(int id, [FromBody] PurchaseOrderUpdateRequest request)
        {
            try
            {
                if (request == null || request.PurchaseOrder == null)
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "Invalid request."
                    });

                if (id != request.PurchaseOrder.PurchaseOrderNumber)
                    return BadRequest(new ApiMessageResponse
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Message = "ID mismatch."
                    });

                var updatedPo = await purchaseOrderService.UpdatePurchaseOrder(request.PurchaseOrder, request.deletedItemIds);

                if (updatedPo.Errors.Count > 0)
                {
                    return BadRequest(new ApiErrorsResponse<ValidationError>
                    {
                        Status = StatusCodes.Status400BadRequest,
                        Errors = updatedPo.Errors
                    });
                }

                return Ok(updatedPo);
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new ApiMessageResponse
                {
                    Status = StatusCodes.Status500InternalServerError,
                    Message = "Something went wrong while processing your request."
                });
            }
        }



        //public async Task<ActionResult<PurchaseOrder>> UpdatePurchaseOrder(int id, [FromBody] PurchaseOrder purchaseOrder)
        //{

        //    try
        //    {

        //        if (purchaseOrder == null)
        //            return BadRequest(new ApiMessageResponse
        //            {
        //                Status = StatusCodes.Status400BadRequest,
        //                Message = "Invalid request."
        //            });
        //        if (id != purchaseOrder.PurchaseOrderNumber)
        //            return BadRequest("ID mismatch.");

        //        var updatedPurchaseOrder = await purchaseOrderService.UpdatePurchaseOrder(purchaseOrder);

        //        if (updatedPurchaseOrder.Errors.Count > 0)
        //            // There are arguments that we should return 422 here, however
        //            // 400 is fine
        //            return BadRequest(new ApiErrorsResponse<ValidationError>
        //            {
        //                Status = StatusCodes.Status400BadRequest,
        //                Errors = updatedPurchaseOrder.Errors
        //            });

        //        return Ok(purchaseOrder);
        //    }
        //    catch (Exception)
        //    {

        //        return StatusCode(StatusCodes.Status500InternalServerError, new ApiMessageResponse
        //        {
        //            Status = StatusCodes.Status500InternalServerError,
        //            Message = "Something went wrong while processing your request."
        //        });
        //    }
        //}



        private int? GetAuthenticatedEmployeeId()
        {
            var employeeIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (int.TryParse(employeeIdClaim, out int employeeId))
            {
                return employeeId;
            }

            return null; 
        }
    }
}