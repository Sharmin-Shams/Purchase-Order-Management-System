import { Component, OnInit } from '@angular/core';
import { DashboardDto } from '@models/dashboard-dto';
import { ChartData, ChartOptions, ChartType } from 'chart.js';
import { DashboardService } from '@services/dashboard.service';
import { BaseChartDirective } from 'ng2-charts';
import { CommonModule } from '@angular/common';
import { ToastrService } from 'ngx-toastr';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { faClipboardList, faEnvelope, faPen, faUsers } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-supervisor-dashboard',
  imports: [BaseChartDirective, CommonModule, FontAwesomeModule],

  templateUrl: './supervisor-dashboard.component.html',
  styleUrl: './supervisor-dashboard.component.scss',
})
export class SupervisorDashboardComponent implements OnInit {
  employeeDashboard: DashboardDto | null = null;
  supervisorDashboard: DashboardDto | null = null;
  error = '';
  faEnvelope = faEnvelope;
  faWrite = faPen;
  empIcon = faUsers;
  poIcon = faClipboardList

  employeeChartData: ChartData<'bar'> = { labels: [], datasets: [] };
  supervisorChartData: ChartData<'bar'> = { labels: [], datasets: [] };

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
    this.loadSupervisorDashboard();
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

  loadSupervisorDashboard(): void {
    this.dashboardService.getSupervisorDashboard().subscribe({
      next: (data) => {
        this.supervisorDashboard = data;

        console.log(data);
        this.supervisorChartData = {
          labels: data.monthlyExpense.map((e) => e.month),
          datasets: [
            {
              data: data.monthlyExpense.map((e) => e.expenseTotal),
              label: 'Supervisor Monthly Expenses',
            },
          ],
        };
      },
      error: (err) => {
        console.error('Supervisor dashboard error', err);
        this.error += 'Failed to load Supervisor Dashboard.';
        this.toastr.error('Failed to load Supervisor Dashboard.');
      },
    });
  }
}
