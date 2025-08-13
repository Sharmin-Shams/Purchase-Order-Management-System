import { NgIf } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import {
  faClipboardList,
  faEnvelope,
  faPen,
  faUsers,
} from '@fortawesome/free-solid-svg-icons';
import { DashboardDto } from '@models/dashboard-dto';
import { DashboardService } from '@services/dashboard.service';
import { ChartData, ChartOptions, ChartType } from 'chart.js';
import { BaseChartDirective } from 'ng2-charts';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-employee-dashboard',
  imports: [BaseChartDirective, FontAwesomeModule, NgIf],
  templateUrl: './employee-dashboard.component.html',
  styleUrl: './employee-dashboard.component.scss',
})
export class EmployeeDashboardComponent implements OnInit {
  employeeDashboard: DashboardDto | null = null;
  employeeChartData: ChartData<'bar'> = { labels: [], datasets: [] };
  error = "";
  faEnvelope = faEnvelope;
  faWrite = faPen;
  empIcon = faUsers;
  poIcon = faClipboardList;
  chartType: ChartType = 'bar';
  chartOptions: ChartOptions = {
    responsive: true,
    plugins: {
      legend: {
        display: true,
      },
      tooltip: {
        enabled: true,
      },
    },
    scales: {
      x: {
        title: {
          display: true,
          text: 'Month',
          font: {
            size: 14,
            weight: 'bold',
          },
        },
      },
      y: {
        beginAtZero: true,
        title: {
          display: true,
          text: 'Monthly Expenses',
          font: {
            size: 14,
            weight: 'bold',
          },
        },
      },
    },
  };

  constructor(
    private dashboardService: DashboardService,
    private toastr: ToastrService
  ) {}

  ngOnInit(): void {
    this.loadEmployeeDashboard();
  }

  loadEmployeeDashboard(): void {
    this.dashboardService.getEmployeeDashboard().subscribe({
      next: (data) => {
        this.employeeDashboard = data;

        this.employeeChartData = {
          labels: data.monthlyExpense.map((e) => e.month),
          datasets: [
            {
              data: data.monthlyExpense.map((e) => e.expenseTotal),
              label: 'Employee Monthly Expenses',
            },
          ],
        };
      },
      error: (err) => {
        console.error('Employee dashboard error', err);
        this.error += 'Failed to load Employee Dashboard. ';
        this.toastr.error('Failed to load Employee Dashboard.');
      },
    });
  }
}
