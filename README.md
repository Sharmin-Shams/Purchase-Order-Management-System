#  Purchase Order Management System

A full-stack **Purchase Order (PO) Management System** built with **Angular**, **ASP.NET Core**, and **SQL Server**.  
The system supports both **employee** and **supervisor** workflows, including creating, editing, approving/denying, and closing purchase orders.



##  Features

### Employee Features
- Create new purchase orders(PO) with item-level details.
- Search POs by date range and PO number.
- Edit existing POs before supervisor review.
- Mark items as **No Longer Required** (automatically updates quantity, price, and description).
- Real-time totals (subtotal, tax, total) calculated on the frontend.
- Dashboard with:
  - Monthly PO expenses graph.

### Supervisor Features
- Search POs by date range, PO number, employee name, and status.
- Approve or deny items individually with optional modification of quantity, price, or location.
- Require denial reasons for rejected items.
- Optionally close POs when all items are processed.
- Send email notifications to employees when a PO is closed.
- Dashboard with:
  - Pending POs to approve.
  - Monthly PO expenses graph.



##  Tech Stack

**Frontend:** Angular 19, TypeScript, Bootstrap  
**Backend:** ASP.NET Core 8.0 MVC + Web API (C#), ADO.NET  
**Database:** SQL Server  



##  Installation

###  Clone the repository
```sh
git clone https://github.com/Sharmin-Shams/Purchase-Order-Management-System.git
cd Purchase-Order-Management-System
```
###  Setup the Database
Open SQL Server Management Studio (SSMS).

Run the SQL scripts inside the Database folder.

### Run the Backend

Navigate to the backend folder:
```sh
cd Application/Backend
```
Open the project in Visual Studio and run the project.

### Run the Frontend

Navigate to the frontend folder
```sh
cd Application/CodeNB-Web
``` 
Install dependencies:
```sh
npm install @angular/cdk@19.2.16
```
Start the Angular app:
```sh
ng serve
```
Access the app at `http://localhost:4200/`



## Demo Login Credentials:

### Supervisor:
"Username": "00000002",
"Password": "Password123!"
### Employee: 
"Username": "00000008",
"Password": "Password123!"