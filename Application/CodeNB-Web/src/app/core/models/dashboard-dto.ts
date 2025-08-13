import { MonthlyExpenseDto } from "./monthly-expense-dto";

export class DashboardDto{

    monthlyExpense : MonthlyExpenseDto[];
    pendingPOCount?:number;
    unreadReviewCount?:number;
    pendingsReviewsToCreateCount? :number;
    totalSupervisedEmployees?: number;

}