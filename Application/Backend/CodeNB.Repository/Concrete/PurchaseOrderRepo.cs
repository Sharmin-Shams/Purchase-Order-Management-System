using Azure.Core;
using CodeNB.Model;
using CodeNB.Types;
using DAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Repository
{
    public class PurchaseOrderRepo : IpurchaseOrderRepo
    {
        private readonly IDataAccess _db;
        public PurchaseOrderRepo(IDataAccess db)
        {
            _db = db;
        }

        public async Task<PurchaseOrder> CreatePurchaseOrderAsync(PurchaseOrder purchaseOrder)
        {
            

            List<Parm> parms = new()
            {
              
            new Parm("@PurchaseOrderNumber", SqlDbType.Int, purchaseOrder.PurchaseOrderNumber, 0, ParameterDirection.Output),
            new Parm("@RecordVersion", SqlDbType.Timestamp, purchaseOrder.RecordVersion, 0, ParameterDirection.Output),
            new Parm("@EmployeeID", SqlDbType.Int, purchaseOrder.EmployeeID),
            new Parm("@TaxRate", SqlDbType.Decimal, Constants.DEFAULT_TAX_RATE), // Fixed 15% for now
            new Parm("@PurchaseOrderStatusID", SqlDbType.Int, Constants.PURCHASE_ORDER_STATUSID),
            new Parm("@PurchaseOrderItemStatusID", SqlDbType.Int, Constants.PURCHASE_ORDER_ITEM_STATUSID),
            new Parm("@PurchaseOrderItem", SqlDbType.Structured, CreatePurchaseOrderItemsDT(purchaseOrder.Items))
            };

            if (await _db.ExecuteNonQueryAsync("spCreatePurchaseOrderWithItems", parms) > 0)
            {
                purchaseOrder.PurchaseOrderNumber = (int?)parms.FirstOrDefault(p => p.Name == "@PurchaseOrderNumber")!.Value ?? 0;
                purchaseOrder.RecordVersion = (byte[]?)parms.FirstOrDefault(p => p.Name == "@RecordVersion")!.Value;


            }
            else
            {
                throw new DataException("There was an issue creating the purchase order.");
            }
            return purchaseOrder;

        }



        public async Task<List<DepartmentSearchResultDto>> GetPurchaseOrderByDepartment(int departmentId)
        {
            var parms = new List<Parm>
            {
                new Parm("@DepartmentId", SqlDbType.Int, departmentId)
            };

              DataTable dt = await _db.ExecuteAsync("spSearchPurchaseOrdersByDepartment", parms);

            return [.. dt.AsEnumerable().Select(row => new DepartmentSearchResultDto
            {
            PurchaseOrderNumber = row["PurchaseOrderNumber"].ToString().PadLeft(8,'0'),
            CreationDate = Convert.ToDateTime(row["CreationDate"]),
            SupervisorName = row["SupervisorName"].ToString()!,
            PurchaseOrderStatus = row["PurchaseOrderStatus"].ToString()!
                })];
            }


        public async Task<List<PurchaseOrderSearchResultDto>> SearchEmployeePurchaseOrdersAsync(PurchaseOrderSearchDto criteria)
        {
            // var parms = new List<Parm>
            List<Parm> parms = new()
            {
                new Parm("@EmployeeID", SqlDbType.Int, criteria.EmployeeID),
                new Parm("@StartDate", SqlDbType.Date, criteria.StartDate),
                new Parm("@EndDate", SqlDbType.Date, criteria.EndDate),
                new Parm("@PurchaseOrderNumber", SqlDbType.Int, criteria.PurchaseOrderNumber)
            };

            var dt = await _db.ExecuteAsync("spSearchPurchaseOrdersByEmployee", parms);

            return [.. dt.AsEnumerable().Select(row => new PurchaseOrderSearchResultDto
                {
                    PurchaseOrderNumber = row["PurchaseOrderNumber"].ToString()!,
                    PurchaseOrderCreationDate = Convert.ToDateTime(row["CreationDate"]),
                    PurchaseOrderStatus = row["PurchaseOrderStatus"].ToString()!,
                    Subtotal = Convert.ToDecimal(row["Subtotal"]),
                    TaxTotal = Convert.ToDecimal(row["TaxTotal"]),
                    GrandTotal = Convert.ToDecimal(row["GrandTotal"])
                })];
        }

       

        public async Task<PurchaseOrderDto> GetPurchaseOrderDetails(int poNumber)
        {

            List<Parm> parms = new()
                {
                    new("@PurchaseOrderNumber", SqlDbType.Int, poNumber)
                    //new("@EmployeeID", SqlDbType.Int, employeeId)
                };
                DataTable dt = await _db.ExecuteAsync("spGetPurchaseOrderDetails", parms);
           
                if (dt.Rows.Count == 0)
                    return null;

            return new PurchaseOrderDto
            {
                PurchaseOrderNumber = dt.Rows[0]["PurchaseOrderNumber"].ToString(),
                CreationDate = Convert.ToDateTime(dt.Rows[0]["CreationDate"]),
                EmployeeFullName = dt.Rows[0]["EmployeeFullName"].ToString(),
                DepartmentName = dt.Rows[0]["DepartmentName"] == DBNull.Value ? "N/A" : dt.Rows[0]["DepartmentName"].ToString(),
                SupervisorFullName = dt.Rows[0]["SupervisorFullName"] == DBNull.Value ? "N/A" : dt.Rows[0]["SupervisorFullName"].ToString(),
                PurchaseStatus = dt.Rows[0]["StatusName"].ToString(),
                EmployeeID = Convert.ToInt16(dt.Rows[0]["EmployeeID"]),
                RecordVersion = dt.Rows[0]["RecordVersion"] as byte[],
                Subtotal = Convert.ToDecimal(dt.Rows[0]["PurchaseSubtotal"]),
                TaxTotal= Convert.ToDecimal(dt.Rows[0]["PurchaseTaxTotal"]),
                GrandTotal= Convert.ToDecimal(dt.Rows[0]["PurchaseGrandTotal"]),
                Items = dt.AsEnumerable().Select(row => new PurchaseOrderItemDto
                {
                    ID = Convert.ToInt32(row["ID"]),
                    ItemName = row["ItemName"].ToString()!,
                    ItemDescription = row["ItemDescription"].ToString(),
                    ItemQuantity = Convert.ToInt32(row["ItemQuantity"]),
                    ItemPrice = Convert.ToDecimal(row["ItemPrice"]),
                    ItemJustification = row["ItemJustification"].ToString(),
                    ItemPurchaseLocation = row["ItemPurchaseLocation"].ToString(),
                    ItemStatus = row["ItemStatus"].ToString(),
                    DenialReason= row["DenialReason"].ToString(),
                    ModificationReason= row["ModificationReason"].ToString(),
                    RecordVersion = row["RecordVersion"] as byte[],
                    ItemSubtotal = Convert.ToDecimal(row["ItemSubtotal"]),
                    ItemTaxTotal= Convert.ToDecimal(row["ItemTaxTotal"]),
                    ItemGrandTotal = Convert.ToDecimal(row["ItemGrandTotal"])

                }).ToList()
            };
            
        }




        public async Task<List<POSupervisorSearchResultDTO>> SearchPurchaseOrderBySupervisor(POSupervisorSearchDTO criteria)
        {

            List<Parm> parms = new()
            {
                new Parm("@EmployeeID", SqlDbType.Int, criteria.EmployeeID),
                new Parm("@PONumber", SqlDbType.NVarChar, (object?)criteria.PONumber ?? DBNull.Value),
                new Parm("@StartDate", SqlDbType.Date, (object?)criteria.StartDate ?? DBNull.Value),
                new Parm("@EndDate", SqlDbType.Date, (object?)criteria.EndDate ?? DBNull.Value),
                new Parm("@POStatus", SqlDbType.NVarChar, (object?)criteria.POStatus ?? DBNull.Value),
                new Parm("@EmployeeFullName", SqlDbType.NVarChar, (object?)criteria.EmployeeFullName ?? DBNull.Value)
            };
            DataTable dt = await _db.ExecuteAsync("spSearchPurchaseOrdersBySupervisorByDepartment", parms);

            return dt.AsEnumerable()
        .Select(row => new POSupervisorSearchResultDTO
                    {
                        PONumber = row["PONumber"].ToString().PadLeft(8, '0'),
                        CreationDate = Convert.ToDateTime(row["POCreationDate"]),
                        EmployeeFullName = row["EmployeeFullName"].ToString()!,
                        POStatus = row["PO Status"].ToString()!,
                        SubTotal = Convert.ToDecimal(row["SubTotal"]),
                        TaxTotal = Convert.ToDecimal(row["TaxTotal"]),
                        GrandTotal = Convert.ToDecimal(row["GrandTotal"])
                    })
                    .ToList();

        }


        public async Task<bool> ProcessItemDecision(SupervisorItemDecisionDTO dto)
        {
            
                List<Parm> parms = new()
                        {
                            new Parm("@ItemID", SqlDbType.Int, dto.ItemID),
                            new Parm("@UpdatedItemsStatusID", SqlDbType.Int, dto.UpdatedItemStatusID),
                            new Parm("@DenialReason", SqlDbType.NVarChar, (object?)dto.DenialReason ?? DBNull.Value),

                           
                            new Parm("@IsLastItem", SqlDbType.Bit, DBNull.Value, 0, ParameterDirection.Output)
                        };

                
                await _db.ExecuteNonQueryAsync("spProcessItemDecisionAndCheckLast", parms);

                
                bool isLastItem = Convert.ToBoolean(
                    parms.First(p => p.Name == "@IsLastItem").Value
                );

                return isLastItem;
            

        }

        public async Task ClosePurchaseOrderAsync(int purchaseOrderNumber)
        {
            List<Parm> parms = new()
                {
                    new Parm("@PONumber", SqlDbType.Int, purchaseOrderNumber)
                };

            await _db.ExecuteNonQueryAsync("spClosePurchaseOrder", parms);
        }

        public async Task<string> GetEmployeeEmailForPOAsync(int purchaseOrderNumber)
        {
            List<Parm> parms = new()
                {
                    new Parm("@PONumber", SqlDbType.Int, purchaseOrderNumber)
                };

            object? result = await _db.ExecuteScalarAsync("spGetEmployeeEmailForPO", parms);

            return result?.ToString() ?? throw new InvalidOperationException("Email not found for the given purchase order.");
        }

        //public async Task<PurchaseOrder> UpdatePurchaseOrder(PurchaseOrder purchaseOrder)
        //{
        //    List<Parm> parms = new()
        //    {
        //        new Parm("@PurchaseOrderRecordVersion", SqlDbType.Timestamp, purchaseOrder.RecordVersion ?? new byte[8], 0, ParameterDirection.InputOutput),
        //         new Parm("@PurchaseOrderNumber", SqlDbType.Int,purchaseOrder.PurchaseOrderNumber),
        //         new Parm("@UpdatedItems", SqlDbType.Structured, UpdatePurchaseOrderItemsDT(purchaseOrder.Items))

        //    };


        //    if (await _db.ExecuteNonQueryAsync("spUpdatePurchaseOrderWithItems", parms) > 0)
        //    {

        //        purchaseOrder.RecordVersion = (byte[]?)parms.FirstOrDefault(p => p.Name == "@PurchaseOrderRecordVersion")!.Value;


        //    }
        //    else
        //    {
        //        throw new DataException("There was an issue updating the purchase order.");
        //    }
        //    return purchaseOrder;
        //}



        public async Task<PurchaseOrder> UpdatePurchaseOrder(PurchaseOrder purchaseOrder, List<int> deletedItemIds)
        {
            List<Parm> parms = new()
    {
        new Parm("@PurchaseOrderRecordVersion", SqlDbType.Timestamp, purchaseOrder.RecordVersion ?? new byte[8], 0, ParameterDirection.InputOutput),
        new Parm("@PurchaseOrderNumber", SqlDbType.Int, purchaseOrder.PurchaseOrderNumber),
        new Parm("@UpdatedItems", SqlDbType.Structured, UpdatePurchaseOrderItemsDT(purchaseOrder.Items)),
        new Parm("@DeletedItemIds", SqlDbType.Structured, GetDeletedItemIdsTable(deletedItemIds))
    };

            if (await _db.ExecuteNonQueryAsync("spUpdatePurchaseOrderWithItems", parms) > 0)
            {
                purchaseOrder.RecordVersion = (byte[]?)parms.FirstOrDefault(p => p.Name == "@PurchaseOrderRecordVersion")!.Value;
            }
            else
            {
                throw new DataException("There was an issue updating the purchase order.");
            }

            return purchaseOrder;
        }

        private DataTable GetDeletedItemIdsTable(List<int> deletedItemIds)
        {
            var table = new DataTable();
            table.Columns.Add("ID", typeof(int));

            if (deletedItemIds != null)
            {
                foreach (var id in deletedItemIds)
                {
                    table.Rows.Add(id);
                }
            }

            return table;
        }

        private DataTable UpdatePurchaseOrderItemsDT(List<PurchaseOrderItem> items)
        {
            var dt = new DataTable();
            dt.Columns.Add("ID", typeof(int));
            dt.Columns.Add("PurchaseOrderID", typeof(int));
            dt.Columns.Add("ItemName", typeof(string));
            dt.Columns.Add("ItemDescription", typeof(string));
            dt.Columns.Add("ItemQuantity", typeof(int));
            dt.Columns.Add("ItemPrice", typeof(decimal));
            dt.Columns.Add("ItemJustification", typeof(string));
            dt.Columns.Add("ItemPurchaseLocation", typeof(string));
            dt.Columns.Add("PurchaseOrderItemStatusID", typeof(int));
            dt.Columns.Add("DenialReason",typeof(string));
            dt.Columns.Add("ModificationReason", typeof(string));
            dt.Columns.Add("RecordVersion", typeof(byte[]));


            foreach (PurchaseOrderItem item in items)
            {
                object recordVersion = item.ID == 0
                                        ? DBNull.Value
                                        : (item.RecordVersion != null ? (object)item.RecordVersion : DBNull.Value);

                dt.Rows.Add(
                    item.ID,
                    item.PurchaseOrderID,
                    item.ItemName,
                    item.ItemDescription,
                    item.ItemQuantity,
                    item.ItemPrice,
                    item.ItemJustification,
                    item.ItemPurchaseLocation,
                    item.PurchaseOrderItemStatusID,
                    item.DenialReason ?? (object)DBNull.Value,
                    item.ModificationReason ?? (object)DBNull.Value,
                    recordVersion
                    
                );
            }

            return dt;

        }

        private DataTable CreatePurchaseOrderItemsDT(List<PurchaseOrderItem> items)
        {
            var dt = new DataTable();
            dt.Columns.Add("ID", typeof(int));
            dt.Columns.Add("ItemName", typeof(string));
            dt.Columns.Add("ItemDescription", typeof(string));
            dt.Columns.Add("ItemQuantity", typeof(int));
            dt.Columns.Add("ItemPrice", typeof(decimal));
            dt.Columns.Add("ItemJustification", typeof(string));
            dt.Columns.Add("ItemPurchaseLocation", typeof(string));

            foreach (var item in items)
            {
                dt.Rows.Add(
                    item.ID,
                    item.ItemName,
                    item.ItemDescription,
                    item.ItemQuantity,
                    item.ItemPrice,
                    item.ItemJustification,
                    item.ItemPurchaseLocation
                );
            }

            return dt;
        }



    }


}
