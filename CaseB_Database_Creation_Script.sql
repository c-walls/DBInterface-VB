DROP TABLE Invoices;
DROP TABLE TaskAssignments;
DROP TABLE WorkAssignments;
DROP TABLE OrderedTasks;
DROP TABLE Materials;
DROP TABLE WorkOrders;
DROP TABLE ProposedTasks;
DROP TABLE Proposals;
DROP TABLE Employees;
DROP TABLE Customers;


CREATE TABLE Employees (
    Emp_Name VARCHAR(30),
    Emp_Role VARCHAR(15) CONSTRAINT Emp_Role_Required NOT NULL,
    Emp_Rate DECIMAL(6, 2) CONSTRAINT Emp_Rate_Required NOT NULL,
    Emp_RateType VARCHAR(9) CONSTRAINT Emp_RateType_Required NOT NULL,
CONSTRAINT PKEmployee PRIMARY KEY (Emp_Name),
CONSTRAINT ChkRole CHECK (Emp_Role IN ('Project Manager', 'Salesperson', 'Crew Supervisor', 'Worker')),
CONSTRAINT ChkRateType CHECK (Emp_RateType IN ('Hourly', 'Per Piece', 'Commission'))
);


CREATE TABLE Customers (
    Cust_No CHAR(4),
    Cust_BillName VARCHAR(50) CONSTRAINT Cust_BillName_Required NOT NULL,
    Cust_BillAddress VARCHAR(100) CONSTRAINT Cust_BillAddress_Required NOT NULL,
    CustomerType VARCHAR(20) CONSTRAINT CustomerType_Required NOT NULL,
    BillCycle_Date INTEGER DEFAULT 1 CONSTRAINT BillCycle_Required NOT NULL,
CONSTRAINT PKCustomer PRIMARY KEY (Cust_No),
CONSTRAINT ChkCustomerType CHECK (CustomerType IN ('General Contractor', 'Commercial', 'Government', 'Residential')),
CONSTRAINT ChkBillCycle CHECK (BillCycle_Date BETWEEN 1 AND 30)
);


CREATE TABLE Proposals (
    Proposal_No CHAR(4),
    Cust_No CHAR(4) CONSTRAINT Cust_Required NOT NULL,
    Location_QTY INTEGER CONSTRAINT Location_Qty_Required NOT NULL,
    Est_Method VARCHAR(15) CONSTRAINT Est_Method_Required NOT NULL,
    Prop_Amount DECIMAL(8,2) CONSTRAINT Prop_Amount_Required NOT NULL,
    Prop_Date DATE DEFAULT SYSDATE CONSTRAINT Prop_Date_Required NOT NULL,
    Salesperson VARCHAR(30) CONSTRAINT Salesperson_Required NOT NULL,
    Prop_Status VARCHAR(10) DEFAULT 'Pending' CONSTRAINT Prop_Status_Required NOT NULL,
    Decision_Date DATE,
CONSTRAINT PKProposal PRIMARY KEY (Proposal_No),
CONSTRAINT FKProposal_Cust FOREIGN KEY (Cust_No) REFERENCES Customers,
CONSTRAINT FKProposal_Emp FOREIGN KEY (Salesperson) REFERENCES Employees(Emp_Name),
CONSTRAINT PosLocation_Qty CHECK (Location_QTY > 0),
CONSTRAINT PosProp_Amount CHECK (Prop_Amount > 0),
CONSTRAINT ChkEstMethod CHECK (Est_Method IN ('Walk Through', 'Floor Plan')),
CONSTRAINT ChkPropStatus CHECK (Prop_Status IN ('Pending', 'Accepted', 'Denied'))
);


CREATE TABLE ProposedTasks (
    Proposal_No CHAR(4),
    Task VARCHAR(50),
    Est_SQFT INTEGER CONSTRAINT Est_SQFT_Required NOT NULL,
    Est_SQFTPrice DECIMAL(5,2) CONSTRAINT Est_SQFTPrice_Required NOT NULL,
CONSTRAINT PKProposedTasks PRIMARY KEY (Proposal_No, Task),
CONSTRAINT FKProposedTasks_Prop FOREIGN KEY (Proposal_No) REFERENCES Proposals,
CONSTRAINT PosEst_SQFT CHECK (Est_SQFT > 0),
CONSTRAINT PosEst_SQFTPrice CHECK (Est_SQFTPrice > 0)
);


CREATE TABLE WorkOrders (
    Order_No CHAR(4),
    Proposal_No CHAR(4),
    Location_Name VARCHAR(50),
    Location_Address VARCHAR(100),
    Generated_Date DATE,
    Required_Date DATE,
    Order_Notes VARCHAR(255),
    Manager VARCHAR(30),
CONSTRAINT PKWorkOrders PRIMARY KEY (Order_No),
CONSTRAINT FKWorkOrders_Prop FOREIGN KEY (Proposal_No) REFERENCES Proposals,
CONSTRAINT FKWorkOrders_Manager FOREIGN KEY (Manager) REFERENCES Employees(Emp_Name)
);


CREATE TABLE OrderedTasks (
    Order_No CHAR(4),
    Task VARCHAR(50),
    Task_SQFT INTEGER,
    Est_Duration INTEGER,
    Task_Status VARCHAR(10),
    Date_Complete DATE,
CONSTRAINT PKOrderedTasks PRIMARY KEY (Order_No, Task),
CONSTRAINT FKOrderedTasks_Order FOREIGN KEY (Order_No) REFERENCES WorkOrders
);


CREATE TABLE WorkAssignments (
    Assignment_No CHAR(4),
    Order_No CHAR(4),
    Authorized_By VARCHAR(30),
    Authorized_Date DATE,
    Start_Date DATE,
    Finish_Date DATE,
    Supervisor VARCHAR(30),
    Vehicle_No INTEGER,
CONSTRAINT PKWorkAssignments PRIMARY KEY (Assignment_No),
CONSTRAINT FKWorkOrders_Assign FOREIGN KEY (Order_No) REFERENCES WorkOrders,
CONSTRAINT FKWorkAssignments_Authorizer FOREIGN KEY (Authorized_By) REFERENCES Employees(Emp_Name),
CONSTRAINT FKWorkAssignments_Supervisor FOREIGN KEY (Supervisor) REFERENCES Employees(Emp_Name)
);


CREATE TABLE Invoices (
    Invoice_No CHAR(4),
    Proposal_No CHAR(4),
    Invoice_Date DATE,
    Invoice_Total DECIMAL(10, 2),
CONSTRAINT PKInvoice PRIMARY KEY (Invoice_No),
CONSTRAINT FKInvoice_Prop FOREIGN KEY (Proposal_No) REFERENCES Proposals(Proposal_No)
);


CREATE TABLE Materials (
    Material_Name VARCHAR(50),
    Material_UnitCost DECIMAL(5, 2),
    Material_UnitSQFT INTEGER,
    Inventory_QTY INTEGER,
CONSTRAINT PKMaterials PRIMARY KEY (Material_Name)
);


CREATE TABLE TaskAssignments (
    Assignment_No CHAR(4),
    Task VARCHAR(50),
    Material_Name VARCHAR(50),
    Send_QTY INTEGER,
    Used_QTY INTEGER,
    Worker VARCHAR(30),
    Est_Hours INTEGER,
    Used_Hours INTEGER,
CONSTRAINT PKTaskAssignments PRIMARY KEY (Assignment_No, Task),
CONSTRAINT FKTaskAssignments_Assign FOREIGN KEY (Assignment_No) REFERENCES WorkAssignments,
CONSTRAINT FKTaskAssignments_Material FOREIGN KEY (Material_Name) REFERENCES Materials,
CONSTRAINT FKTaskAssignments_Worker FOREIGN KEY (Worker) REFERENCES Employees(Emp_Name)
);



-- INSERT CUSTOMER DATA --
INSERT INTO Customers (Cust_No, Cust_BillName, Cust_BillAddress, CustomerType, BillCycle_Date) 
VALUES ('C001', 'Acme Construction Inc.', '123 Main St, Anytown, CA 12345', 'General Contractor', 1);

INSERT INTO Customers (Cust_No, Cust_BillName, Cust_BillAddress, CustomerType, BillCycle_Date)
VALUES ('C002', 'Smith Residential Builders', '456 Oak Rd, Sometown, NY 67890', 'General Contractor', 15);

INSERT INTO Customers (Cust_No, Cust_BillName, Cust_BillAddress, CustomerType, BillCycle_Date)
VALUES ('C003', 'Oakland Transit Authority', '789 Capitol Ave, Washington, DC 20001', 'Government', 1);

INSERT INTO Customers (Cust_No, Cust_BillName, Cust_BillAddress, CustomerType, BillCycle_Date)
VALUES ('C004', 'Justin Hershowitz', '321 Elm Ln, Mytown, TX 54321', 'Residential', 5);

INSERT INTO Customers (Cust_No, Cust_BillName, Cust_BillAddress, CustomerType, BillCycle_Date)
VALUES ('C005', 'Cerberus Industrial Solutions LLC', '159 Tower Blvd, Bigcity, CA 90210', 'Commercial', 13);

INSERT INTO Customers (Cust_No, Cust_BillName, Cust_BillAddress, CustomerType, BillCycle_Date)
VALUES ('C006', 'Tiffany Chesterton', '789 Maple Ave, Suburbville, IL 60610', 'Residential', 15);

INSERT INTO Customers (Cust_No, Cust_BillName, Cust_BillAddress, CustomerType, BillCycle_Date)
VALUES ('C007', 'Green Valley Contractors', '456 Pine St, Greenville, OR 97330', 'General Contractor', 1);

INSERT INTO Customers (Cust_No, Cust_BillName, Cust_BillAddress, CustomerType, BillCycle_Date)
VALUES ('C008', 'Southeastern University', '123 College Rd, Unitown, MA 02155', 'Government', 1);

INSERT INTO Customers (Cust_No, Cust_BillName, Cust_BillAddress, CustomerType, BillCycle_Date)
VALUES ('C009', 'Rick Anderson', '987 Valley Dr, Hilltown, CO 80501', 'Residential', 3);

INSERT INTO Customers (Cust_No, Cust_BillName, Cust_BillAddress, CustomerType, BillCycle_Date)
VALUES ('C010', 'Apex Developers LLC', '654 City Center Blvd, Metro, NY 10001', 'General Contractor', 25);


-- INSERT EMPLOYEE DATA --
INSERT INTO Employees (Emp_Name, Emp_Role, Emp_Rate, Emp_RateType)
VALUES ('Michael Thompson', 'Project Manager', 26.50, 'Hourly');

INSERT INTO Employees (Emp_Name, Emp_Role, Emp_Rate, Emp_RateType)
VALUES ('Sarah Davis', 'Project Manager', 27.00, 'Hourly');

INSERT INTO Employees (Emp_Name, Emp_Role, Emp_Rate, Emp_RateType)
VALUES ('Robert Welsh', 'Salesperson', 22.50, 'Hourly');

INSERT INTO Employees (Emp_Name, Emp_Role, Emp_Rate, Emp_RateType)
VALUES ('Aria Jude', 'Salesperson', 20.00, 'Hourly');

INSERT INTO Employees (Emp_Name, Emp_Role, Emp_Rate, Emp_RateType)
VALUES ('Marcus Rodriguez', 'Crew Supervisor', 27.00, 'Hourly');

INSERT INTO Employees (Emp_Name, Emp_Role, Emp_Rate, Emp_RateType)
VALUES ('David LeFluer', 'Crew Supervisor', 24.50, 'Hourly');

INSERT INTO Employees (Emp_Name, Emp_Role, Emp_Rate, Emp_RateType)
VALUES ('Rob Mbota', 'Worker', 14.00, 'Hourly');

INSERT INTO Employees (Emp_Name, Emp_Role, Emp_Rate, Emp_RateType)
VALUES ('William Baker', 'Worker', 13.50, 'Hourly');

INSERT INTO Employees (Emp_Name, Emp_Role, Emp_Rate, Emp_RateType)
VALUES ('Amanda Wilson', 'Worker', 14.00, 'Hourly');

INSERT INTO Employees (Emp_Name, Emp_Role, Emp_Rate, Emp_RateType)
VALUES ('Omar Davilla', 'Worker', 15.00, 'Hourly');

INSERT INTO Employees (Emp_Name, Emp_Role, Emp_Rate, Emp_RateType)
VALUES ('Samuel Lee', 'Worker', 12.50, 'Hourly');


-- INSERT MATERIAL DATA --
INSERT INTO Materials (Material_Name, Material_UnitCost, Material_UnitSQFT, Inventory_QTY)
VALUES ('Fiberglass Batts', 98.00, 100, 2000);

INSERT INTO Materials (Material_Name, Material_UnitCost, Material_UnitSQFT, Inventory_QTY)
VALUES ('Rockwool Batts', 135.00, 100, 1250);

INSERT INTO Materials (Material_Name, Material_UnitCost, Material_UnitSQFT, Inventory_QTY)
VALUES ('Rigid Foam Boards', 18.25, 32, 1000);

INSERT INTO Materials (Material_Name, Material_UnitCost, Material_UnitSQFT, Inventory_QTY)
VALUES ('Fiberglass Loose Fill', 68.50, 125, 1200);

INSERT INTO Materials (Material_Name, Material_UnitCost, Material_UnitSQFT, Inventory_QTY)
VALUES ('Rockwool Loose Fill', 95.00, 125, 800);

INSERT INTO Materials (Material_Name, Material_UnitCost, Material_UnitSQFT, Inventory_QTY)
VALUES ('Cellulose Loose Fill', 82.75, 150, 1500);

INSERT INTO Materials (Material_Name, Material_UnitCost, Material_UnitSQFT, Inventory_QTY)
VALUES ('Closed-Cell Spray Foam', 355.00, 200, 75);

INSERT INTO Materials (Material_Name, Material_UnitCost, Material_UnitSQFT, Inventory_QTY)
VALUES ('Open-Cell Spray Foam', 315.00, 200, 100);


-- INSERT PROPOSAL DATA --
INSERT INTO Proposals (Proposal_No, Cust_No, Location_QTY, Est_Method, Prop_Amount, Prop_Date, Salesperson, Prop_Status)
VALUES ('P001', 'C001', 2, 'Floor Plan', 15000, TO_DATE('2024-04-20', 'YYYY-MM-DD'), 'Robert Welsh', 'Pending');

INSERT INTO Proposals (Proposal_No, Cust_No, Location_QTY, Est_Method, Prop_Amount, Prop_Date, Salesperson, Prop_Status, Decision_Date)
VALUES ('P002', 'C002', 1, 'Floor Plan', 8500, TO_DATE('2024-04-18', 'YYYY-MM-DD'), 'Aria Jude', 'Accepted', TO_DATE('2024-04-25', 'YYYY-MM-DD'));

INSERT INTO Proposals (Proposal_No, Cust_No, Location_QTY, Est_Method, Prop_Amount, Prop_Date, Salesperson, Prop_Status, Decision_Date)
VALUES ('P003', 'C003', 3, 'Floor Plan', 25000, TO_DATE('2024-04-10', 'YYYY-MM-DD'), 'Aria Jude', 'Denied', TO_DATE('2024-04-25', 'YYYY-MM-DD'));


-- INSERT PROPOSED TASK DATA --
INSERT INTO ProposedTasks (Proposal_No, Task, Est_SQFT, Est_SQFTPrice)
VALUES ('P001', 'Wall Insulation', 500, 2.50);

INSERT INTO ProposedTasks (Proposal_No, Task, Est_SQFT, Est_SQFTPrice)
VALUES ('P001', 'Ceiling Insulation', 300, 2.00);

INSERT INTO ProposedTasks (Proposal_No, Task, Est_SQFT, Est_SQFTPrice)
VALUES ('P002', 'Wall Insulation', 250, 2.50);

INSERT INTO ProposedTasks (Proposal_No, Task, Est_SQFT, Est_SQFTPrice)
VALUES ('P002', 'Ceiling Insulation', 150, 2.00);

INSERT INTO ProposedTasks (Proposal_No, Task, Est_SQFT, Est_SQFTPrice)
VALUES ('P003', 'Wall Insulation', 750, 2.50);

INSERT INTO ProposedTasks (Proposal_No, Task, Est_SQFT, Est_SQFTPrice)
VALUES ('P003', 'Ceiling Insulation', 450, 2.00);

-- INSERT WORK ORDER DATA --
--INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Generated_Date, Required_Date, Order_Notes, Manager)

-- INSERT ORDERED TASK DATA --
--INSERT INTO OrderedTasks (Order_No, Task, Task_SQFT, Est_Duration, Task_Status, Date_Complete)

-- INSERT WORK ASSIGNMENT DATA --
--INSERT INTO WorkAssignments (Assignment_No, Order_No, Authorized_By, Authorized_Date, Start_Date, Finish_Date, Supervisor, Vehicle_No)

-- INSERT TASK ASSIGNMENT DATA --
--INSERT INTO TaskAssignments (Assignment_No, Task, Material_ID, Send_QTY, Used_QTY, Worker, Est_Hours, Used_Hours)

-- INSERT INVOICE DATA --
--INSERT INTO Invoices (Invoice_No, Proposal_No, Invoice_Date, Invoice_Total)

SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Employees;
SELECT COUNT(*) FROM Materials;
SELECT COUNT(*) FROM Proposals;
SELECT COUNT(*) FROM ProposedTasks;

COMMIT;