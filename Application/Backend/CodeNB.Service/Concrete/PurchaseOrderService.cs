using CodeNB.Model;
using CodeNB.Repository;
using CodeNB.Service;
using CodeNB.Types;
using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static EmailServices.EmailService;

namespace CodeNB.Service
{
    public class PurchaseOrderService : IPurchaseOrderService
    {
        private readonly IpurchaseOrderRepo _repo;
        private readonly IDepartmentRepository _departmentRepository;
        private readonly IEmailSender _emailSender;


        public PurchaseOrderService(IpurchaseOrderRepo repo, IDepartmentRepository departmentRepository, IEmailSender emailSender)
        {
            _repo = repo;
            _departmentRepository = departmentRepository;
            _emailSender =emailSender;
           
        }

     
        public async Task<PurchaseOrder> CreatePurchaseOrderAsync(PurchaseOrder purchaseOrder) 
        {
            MergeItems(purchaseOrder);
            if (await ValidateAsync(purchaseOrder))
            {
                return await _repo.CreatePurchaseOrderAsync(purchaseOrder);
               
            }

            return purchaseOrder;
        }

        //public async Task<PurchaseOrder> UpdatePurchaseOrder(PurchaseOrder purchaseOrder)
        //{


        //    try
        //    {


        //        if (await ValidateAsync(purchaseOrder))
        //        {
        //            return await _repo.UpdatePurchaseOrder(purchaseOrder);
        //        }

        //    }
        //    catch (SqlException)
        //    {

        //        purchaseOrder.AddError(new ValidationError(
        //            "The record has been updated since you lasr retrieve it",
        //            ErrorType.Business
        //            ));

        //    }

        //    return purchaseOrder;

        //}


        // for tracking merge items


        public async Task<PurchaseOrder> UpdatePurchaseOrder(PurchaseOrder purchaseOrder, List<int> deletedItemIds)
        {
            try
            {
                
                if (await ValidateAsync(purchaseOrder))
                {
                    return await _repo.UpdatePurchaseOrder(purchaseOrder, deletedItemIds);
                }
            }
            catch (SqlException)
            {
               
                purchaseOrder.AddError(new ValidationError(
                    "The record has been updated since you last retrieved it.",
                    ErrorType.Business
                ));
            }

            return purchaseOrder;
        }

        private async Task<bool> ValidateAsync(PurchaseOrder purchaseOrder)
        
        {
            purchaseOrder.Errors.Clear();
            // Validate Entity
            ValidateModel(purchaseOrder);

            // Business Rule Validation
            ValidateBusinessRules(purchaseOrder);
            return purchaseOrder.Errors.Count == 0;

        }
        private void ValidateBusinessRules(PurchaseOrder purchaseOrder)
        {
            if (purchaseOrder.Items == null || !purchaseOrder.Items.Any())
            {
                purchaseOrder.AddError(new ValidationError("A purchase order must contain at least one item.", ErrorType.Business));
                return;
            }


        }

        private void ValidateModel(PurchaseOrder purchaseOrder)
        {
            
            // Validate Entity
            List<ValidationResult> results = new();
            Validator.TryValidateObject(purchaseOrder, new ValidationContext(purchaseOrder), results, true);

            foreach (ValidationResult e in results)
            {
                purchaseOrder.AddError(new(e.ErrorMessage, ErrorType.Model));
            }

            if (purchaseOrder.Items != null)
            {
                foreach (var item in purchaseOrder.Items)
                {
                    var itemResults = new List<ValidationResult>();
                    Validator.TryValidateObject(item, new ValidationContext(item), itemResults, true);

                    foreach (var error in itemResults)
                    {
                        purchaseOrder.AddError(new ValidationError($"Item: {error.ErrorMessage}", ErrorType.Model));
                    }
                }
            }
        }

        


        public async Task MergeItems(PurchaseOrder purchaseOrder)
        {

            await Task.Run(() =>
            {


                if (purchaseOrder.Items == null || purchaseOrder.Items.Count == 0)
                    return;


                var merged = new List<PurchaseOrderItem>();


                foreach (var item in purchaseOrder.Items)
                {
                    var name = item.ItemName?.Trim().ToLower();
                    var desc = item.ItemDescription?.Trim().ToLower();
                    var justification = item.ItemJustification?.ToLower();
                    var location = item.ItemPurchaseLocation?.ToLower();


                    var existing = merged.FirstOrDefault(m =>
                        (m.ItemName?.Trim().ToLower() ?? "") == name &&
                        (m.ItemDescription?.Trim().ToLower() ?? "") == desc &&
                        m.ItemPrice == item.ItemPrice &&
                        (m.ItemJustification?.Trim().ToLower() ?? "") == justification &&
                        (m.ItemPurchaseLocation?.Trim().ToLower() ?? "") == location
                    );

                    if (existing != null)
                    {
                        existing.ItemQuantity += item.ItemQuantity;
                    }
                    else
                    {
                        merged.Add(new PurchaseOrderItem
                        {
                            ItemName = item.ItemName?.Trim() ?? "",
                            ItemDescription = item.ItemDescription?.Trim() ?? "",
                            ItemQuantity = item.ItemQuantity,
                            ItemPrice = item.ItemPrice,
                            ItemJustification = item.ItemJustification?.Trim() ?? "",
                            ItemPurchaseLocation = item.ItemPurchaseLocation?.Trim() ?? "",
                            PurchaseOrderItemStatusID = 1,
                            RecordVersion = item.RecordVersion
                        });
                    }
                }

                purchaseOrder.Items = merged;
            });
        }

        public async Task<List<DepartmentSearchResultDto>> GetPurchaseOrderByDepartment(int departmentId)
        {
            

            var allDepartments = await _departmentRepository.GetAll();


            if (!allDepartments.Any(d => d.Id == departmentId))
                return null;
               

            return await _repo.GetPurchaseOrderByDepartment(departmentId);
        }
        public async Task<List<PurchaseOrderSearchResultDto>> GetPurchaseOrders(PurchaseOrderSearchDto criteria)
        {

            // insert from JWT
          //  int employeeId= 1;
            return await _repo.SearchEmployeePurchaseOrdersAsync(criteria);

        }

        public async Task<PurchaseOrderDto> GetPurchaseOrderDetails(int poNumber)

        {
           
            return await _repo.GetPurchaseOrderDetails(poNumber);

        }

        public async Task<List<POSupervisorSearchResultDTO>> SearchPurchaseOrderBySupervisor(POSupervisorSearchDTO criteria)
        {
            return await _repo.SearchPurchaseOrderBySupervisor(criteria);
        }


        public async Task<bool> ProcessItemDecisionAsync(SupervisorItemDecisionDTO dto)
        {
            
            bool isLastItem = await _repo.ProcessItemDecision(dto);
            return isLastItem;
        }

        public async Task ClosePurchaseOrderAsync(int purchaseOrderNumber)
        {
            await _repo.ClosePurchaseOrderAsync(purchaseOrderNumber);

            string employeeEmail = await _repo.GetEmployeeEmailForPOAsync(purchaseOrderNumber);


            var message = new EmailMessageDto(new string[] { employeeEmail },
                    "Purchase Order Notification", $"All items in your purchase order #{purchaseOrderNumber:D8} have been reviewed and the PO has been closed.");
             _emailSender.SendEmail(message);

            //var emailMessage = new EmailMessageDto
            //{
            //    To = employeeEmail,
            //    Subject = "Your Purchase Order Has Been Reviewed",
            //    Content = $"All items in your purchase order #{purchaseOrderNumber:D8} have been reviewed and the PO has been closed."
            //};

            // _emailService.SendEmail(emailMessage);

        }

    }
}
