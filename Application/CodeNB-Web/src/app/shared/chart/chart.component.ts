import { CommonModule } from '@angular/common';
import { Component, Input, OnInit } from '@angular/core';
import { DashboardDto } from '@models/dashboard-dto';
import { DashboardService } from '@services/dashboard.service';
import { ChartData, ChartOptions, ChartType } from 'chart.js';
import { BaseChartDirective } from 'ng2-charts';

@Component({
  selector: 'app-chart',
  imports: [CommonModule, BaseChartDirective],
  templateUrl: './chart.component.html',
  styleUrl: './chart.component.scss',
  standalone: true
})
export class ChartComponent implements OnInit{
  dashboard: DashboardDto | null = null;
    error = '';
    chartLabels: string[] = [];
  
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

    chartData: ChartData<'bar'> = {
      labels: [],
      datasets: [],
    };
  
    constructor(private dashboardService: DashboardService) {}
  
    ngOnInit(): void {
      this.dashboardService.getEmployeeDashboard().subscribe({
        next: (data) => {
          this.dashboard = data;
          this.error = '';
           this.chartLabels = data.monthlyExpense.map((e) => e.month);
  
          this.chartData = {
            labels: data.monthlyExpense.map((e) => e.month),
            datasets: [
              {
                data: data.monthlyExpense.map((e) => e.expenseTotal),
                label: 'Monthly Expenses',
              },
            ],
          };
        },
        error: (err) => {
          if (err.error && err.message) {
            this.error = err.message;
          } else {
            this.error = 'Failed to load the Dashboard.Please try again.';
          }
        },
      });
    }

}
