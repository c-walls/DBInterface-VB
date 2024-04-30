DROP TABLE Invoices;
DROP TABLE TaskRequests;
DROP TABLE MaterialAssignments;
DROP TABLE Materials;
DROP TABLE LaborAssignments;
DROP TABLE WorkAssignments;
DROP TABLE TaskOrders;
DROP TABLE WorkOrders;
DROP TABLE Tasks;
DROP TABLE Proposals;
DROP TABLE Customers;
DROP TABLE Employees;
DROP SEQUENCE customer_seq;
DROP SEQUENCE proposal_seq;


CREATE TABLE Employees (
    Emp_ID CHAR(4),
    Emp_Name VARCHAR(30) CONSTRAINT Emp_Name_Required NOT NULL,
    Emp_Role VARCHAR(15) CONSTRAINT Emp_Role_Required NOT NULL,
CONSTRAINT PKEmployee PRIMARY KEY (Emp_ID),
CONSTRAINT ChkRole CHECK (Emp_Role IN ('Project Manager', 'Salesperson', 'Crew Supervisor', 'Worker'))
);


CREATE TABLE Customers (
    Cust_No CHAR(6),
    Cust_BillName VARCHAR(50) CONSTRAINT Cust_BillName_Required NOT NULL,
    Cust_BillAddress VARCHAR(100) CONSTRAINT Cust_BillAddress_Required NOT NULL,
    Cust_Type VARCHAR(20) CONSTRAINT Cust_Type_Required NOT NULL,
    BillCycle_Date INTEGER DEFAULT 1,
CONSTRAINT PKCustomer PRIMARY KEY (Cust_No),
CONSTRAINT ChkCust_Type CHECK (Cust_Type IN ('General Contractor', 'Commercial', 'Government', 'Residential')),
CONSTRAINT ChkBillCycle CHECK (BillCycle_Date BETWEEN 1 AND 30)
);

CREATE SEQUENCE customer_seq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER customer_auto_increment
BEFORE INSERT ON Customers
FOR EACH ROW
BEGIN
    SELECT 'C' || TO_CHAR(customer_seq.NEXTVAL, 'FM00000') INTO :new.Cust_No FROM dual;
END;
/


CREATE TABLE Proposals (
    Proposal_No CHAR(6),
    Cust_No CHAR(6) CONSTRAINT PropCust_Required NOT NULL,
    Location_QTY INTEGER CONSTRAINT Location_Qty_Required NOT NULL,
    Est_Method VARCHAR(15) CONSTRAINT Est_Method_Required NOT NULL,
    Salesperson_ID CHAR(4) CONSTRAINT Salesperson_Required NOT NULL,
    Prop_Date DATE DEFAULT SYSDATE CONSTRAINT Prop_Date_Required NOT NULL,
    Prop_Status VARCHAR(10) DEFAULT 'Pending',
    Decision_Date DATE,
CONSTRAINT PKProposal PRIMARY KEY (Proposal_No),
CONSTRAINT FKProposal_Cust FOREIGN KEY (Cust_No) REFERENCES Customers,
CONSTRAINT FKProposal_Emp FOREIGN KEY (Salesperson_ID) REFERENCES Employees(Emp_ID),
CONSTRAINT PosLocation_Qty CHECK (Location_QTY > 0),
CONSTRAINT ChkEstMethod CHECK (Est_Method IN ('Walk Through', 'Floor Plan')),
CONSTRAINT ChkPropStatus CHECK (Prop_Status IN ('Pending', 'Accepted', 'Denied'))
);

CREATE SEQUENCE proposal_seq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER proposal_auto_increment
BEFORE INSERT ON Proposals 
FOR EACH ROW
BEGIN
    SELECT 'P' || TO_CHAR(proposal_seq.NEXTVAL, 'FM00000') INTO :new.Proposal_No FROM dual;
END;
/


CREATE TABLE Tasks (
    Task_ID CHAR(4),
    Task_Name VARCHAR(50) CONSTRAINT Task_Name_Required NOT NULL,
CONSTRAINT PKTask PRIMARY KEY (Task_ID)
);


CREATE TABLE TaskRequests (
    Task_ID CHAR(4),
    Proposal_No CHAR(6),
    Total_SQFT INTEGER CONSTRAINT Total_SQFT_Required NOT NULL,
    Quoted_SQFTPrice DECIMAL(5,2) CONSTRAINT Quoted_SQFTPrice_Required NOT NULL,
CONSTRAINT PKTaskRequest PRIMARY KEY (Proposal_No, Task_ID),
CONSTRAINT FKTaskRequest_Task FOREIGN KEY (Task_ID) REFERENCES Tasks,
CONSTRAINT FKTaskRequest_Prop FOREIGN KEY (Proposal_No) REFERENCES Proposals,
CONSTRAINT PosTotal_SQFT CHECK (Total_SQFT > 0),
CONSTRAINT PosQuoted_SQFTPrice CHECK (Quoted_SQFTPrice > 0)
);


CREATE TABLE WorkOrders (
    Order_No CHAR(4),
    Proposal_No CHAR(6) CONSTRAINT OrderProp_Required NOT NULL,
    Location_Name VARCHAR(50) CONSTRAINT LocName_Required NOT NULL,
    Location_Address VARCHAR(100) CONSTRAINT LocAddress_Required NOT NULL,
    Generated_Date DATE DEFAULT SYSDATE,
    Required_Date DATE CONSTRAINT ReqDate_Required NOT NULL,
    Order_Notes VARCHAR(255),
    Manager_ID CHAR(4) CONSTRAINT Manager_Required NOT NULL,
CONSTRAINT PKWorkOrders PRIMARY KEY (Order_No),
CONSTRAINT FKWorkOrders_Prop FOREIGN KEY (Proposal_No) REFERENCES Proposals,
CONSTRAINT FKWorkOrders_Manager FOREIGN KEY (Manager_ID) REFERENCES Employees(Emp_ID)
);


CREATE TABLE TaskOrders (
    Task_ID CHAR(4),
    Order_No CHAR(4),
    Task_SQFT INTEGER CONSTRAINT TaskSQFT_Required NOT NULL,
    Est_Duration INTEGER CONSTRAINT EstDuration_Required NOT NULL,
    Task_Status VARCHAR(10) DEFAULT 'Pending',
    Date_Complete DATE,
CONSTRAINT PKTaskOrders PRIMARY KEY (Task_ID, Order_No),
CONSTRAINT FKTaskOrders_Task FOREIGN KEY (Task_ID) REFERENCES Tasks,
CONSTRAINT FKTaskOrders_Order FOREIGN KEY (Order_No) REFERENCES WorkOrders,
CONSTRAINT PosTaskSQFT CHECK (Task_SQFT > 0),
CONSTRAINT PosEstDuration CHECK (Est_Duration > 0),
CONSTRAINT ChkTaskStatus CHECK (Task_Status IN ('Pending', 'In Process', 'Completed'))
);


CREATE TABLE WorkAssignments (
    Assignment_No CHAR(4),
    Order_No CHAR(4) CONSTRAINT AssignOrder_Required NOT NULL,
    Authorizer_ID CHAR(4) CONSTRAINT Authorizer_Required NOT NULL,
    Authorized_Date DATE DEFAULT SYSDATE,
    Start_Date DATE,
    Finish_Date DATE,
    Supervisor_ID CHAR(4) CONSTRAINT Supervisor_Required NOT NULL,
    Vehicle_No INTEGER CONSTRAINT Vehicle_Required NOT NULL,
CONSTRAINT PKWorkAssignments PRIMARY KEY (Assignment_No),
CONSTRAINT FKWorkOrders_Assign FOREIGN KEY (Order_No) REFERENCES WorkOrders,
CONSTRAINT FKWorkAssignments_Authorizer FOREIGN KEY (Authorizer_ID) REFERENCES Employees(Emp_ID),
CONSTRAINT FKWorkAssignments_Supervisor FOREIGN KEY (Supervisor_ID) REFERENCES Employees(Emp_ID),
CONSTRAINT ValidStartDate CHECK (Start_Date >= Authorized_Date),
CONSTRAINT ValidFinishDate CHECK (Finish_Date >= Start_Date),
CONSTRAINT PosVehicle CHECK (Vehicle_No >= 0)
);


CREATE TABLE Invoices (
    Invoice_No CHAR(4),
    Proposal_No CHAR(6) CONSTRAINT InvoiceProp_Required NOT NULL,
    Invoice_Date DATE DEFAULT SYSDATE,
    Invoice_Total DECIMAL(10, 2) CONSTRAINT InvoiceTotal_Required NOT NULL,
CONSTRAINT PKInvoice PRIMARY KEY (Invoice_No),
CONSTRAINT FKInvoice_Prop FOREIGN KEY (Proposal_No) REFERENCES Proposals(Proposal_No),
CONSTRAINT PosInvoiceTotal CHECK (Invoice_Total > 0)
);


CREATE TABLE Materials (
    Material_ID CHAR(4),
    Material_Name VARCHAR(50) CONSTRAINT MaterialName_Required NOT NULL,
    Material_UnitCost DECIMAL(5, 2) CONSTRAINT MaterialUnitCost_Required NOT NULL,
    Inventory_QTY INTEGER CONSTRAINT InventoryQTY_Required NOT NULL,
CONSTRAINT PKMaterials PRIMARY KEY (Material_ID),
CONSTRAINT PosUnitCost CHECK (Material_UnitCost > 0),
CONSTRAINT PosInventory CHECK (Inventory_QTY >= 0)
);


CREATE TABLE MaterialAssignments (
    Task_ID CHAR(4),
    Assignment_No CHAR(4),
    Material_ID CHAR(4),
    Material_Sent INTEGER CONSTRAINT MatSent_Required NOT NULL,
    Material_Used INTEGER CONSTRAINT MatUsed_Required NOT NULL,
CONSTRAINT PKMatAssignments PRIMARY KEY (Task_ID, Assignment_No, Material_ID),
CONSTRAINT FKMatAssignments_Task FOREIGN KEY (Task_ID) REFERENCES Tasks,
CONSTRAINT FKMatAssignments_Assign FOREIGN KEY (Assignment_No) REFERENCES WorkAssignments,
CONSTRAINT FKMatAssignments_Material FOREIGN KEY (Material_ID) REFERENCES Materials,
CONSTRAINT PosMatSentQTY CHECK (Material_Sent > 0),
CONSTRAINT PosMatUsedQTY CHECK (Material_Used >= 0)
);


CREATE TABLE LaborAssignments (
    Assignment_No CHAR(4),
    Task_ID CHAR(4),
    Worker CHAR(4),
    Pay_Rate DECIMAL(7,2) CONSTRAINT PayRate_Required NOT NULL,
    Pay_Type VARCHAR(9) CONSTRAINT PayType_Required NOT NULL,
    Est_Hours INTEGER CONSTRAINT EstHours_Required NOT NULL,
    Used_Hours INTEGER,
CONSTRAINT PKTaskAssignments PRIMARY KEY (Assignment_No, Task_ID, Worker),
CONSTRAINT FKTaskAssignments_Assign FOREIGN KEY (Assignment_No) REFERENCES WorkAssignments,
CONSTRAINT FKTaskAssignments_Task FOREIGN KEY (Task_ID) REFERENCES Tasks,
CONSTRAINT FKTaskAssignments_Worker FOREIGN KEY (Worker) REFERENCES Employees(Emp_ID),
CONSTRAINT PosPay_Rate CHECK (Pay_Rate > 0),
CONSTRAINT PosEst_Hours CHECK (Est_Hours > 0),
CONSTRAINT PosUsed_Hours CHECK (Used_Hours > 0 OR Used_Hours IS NULL),
CONSTRAINT ChkPay_Type CHECK (Pay_Type IN ('Hourly', 'Per Piece', 'Contract'))
);



-- INSERT CUSTOMER DATA --
INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date) 
VALUES ('Acme Construction Inc.', '123 Main St, Anytown, CA 12345', 'General Contractor', 1);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Smith Residential Builders', '456 Oak Rd, Sometown, NY 67890', 'General Contractor', 15);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Oakland Transit Authority', '789 Capitol Ave, Washington, DC 20001', 'Government', 1);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Justin Hershowitz', '321 Elm Ln, Mytown, TX 54321', 'Residential', 5);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Cerberus Industrial Solutions LLC', '159 Tower Blvd, Bigcity, CA 90210', 'Commercial', 13);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Tiffany Chesterton', '789 Maple Ave, Suburbville, IL 60610', 'Residential', 15);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Green Valley Contractors', '456 Pine St, Greenville, OR 97330', 'General Contractor', 1);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Southeastern University', '123 College Rd, Unitown, MA 02155', 'Government', 1);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Rick Anderson', '987 Valley Dr, Hilltown, CO 80501', 'Residential', 3);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Apex Developers LLC', '654 City Center Blvd, Metro, NY 10001', 'General Contractor', 25);


-- INSERT EMPLOYEE DATA --
INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role)
VALUES ('E001', 'Michael Thompson', 'Project Manager');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role)
VALUES ('E002', 'Sarah Davis', 'Project Manager');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role)
VALUES ('E003', 'Robert Welsh', 'Salesperson');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role)
VALUES ('E004', 'Aria Jude', 'Salesperson');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role)
VALUES ('E005', 'Marcus Rodriguez', 'Crew Supervisor');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role)
VALUES ('E006', 'David LeFluer', 'Crew Supervisor');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role)
VALUES ('E007', 'Rob Mbota', 'Worker');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role)
VALUES ('E008', 'William Baker', 'Worker');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role)
VALUES ('E009', 'Amanda Wilson', 'Worker');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role)
VALUES ('E010', 'Omar Davilla', 'Worker');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role)
VALUES ('E011', 'Samuel Lee', 'Worker');


-- INSERT MATERIAL DATA --
INSERT INTO Materials (Material_ID, Material_Name, Material_UnitCost, Inventory_QTY)
VALUES ('M001', 'Fiberglass Batts', 98.00, 2000);

INSERT INTO Materials (Material_ID, Material_Name, Material_UnitCost, Inventory_QTY)
VALUES ('M002', 'Rockwool Batts', 135.00, 1250);

INSERT INTO Materials (Material_ID, Material_Name, Material_UnitCost, Inventory_QTY)
VALUES ('M003', 'Rigid Foam Boards', 18.25, 1000);

INSERT INTO Materials (Material_ID, Material_Name, Material_UnitCost, Inventory_QTY)
VALUES ('M004', 'Fiberglass Loose Fill', 68.50, 1200);

INSERT INTO Materials (Material_ID, Material_Name, Material_UnitCost, Inventory_QTY)
VALUES ('M005', 'Rockwool Loose Fill', 95.00, 800);

INSERT INTO Materials (Material_ID, Material_Name, Material_UnitCost, Inventory_QTY)
VALUES ('M006', 'Cellulose Loose Fill', 82.75, 1500);

INSERT INTO Materials (Material_ID, Material_Name, Material_UnitCost, Inventory_QTY)
VALUES ('M007', 'Closed-Cell Spray Foam', 355.00, 75);

INSERT INTO Materials (Material_ID, Material_Name, Material_UnitCost, Inventory_QTY)
VALUES ('M008', 'Open-Cell Spray Foam', 315.00, 100);


-- INSERT TASK DATA --
INSERT INTO Tasks (Task_ID, Task_Name)
VALUES ('T001', 'Wall Insulation');

INSERT INTO Tasks (Task_ID, Task_Name)
VALUES ('T002', 'Ceiling Insulation');


-- INSERT PROPOSAL DATA --
INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status)
VALUES ('C00001', 2, 'Floor Plan', 'E004', TO_DATE('2024-04-20', 'YYYY-MM-DD'), 'Pending');

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status, Decision_Date)
VALUES ('C00002', 1, 'Floor Plan', 'E003', TO_DATE('2024-04-18', 'YYYY-MM-DD'), 'Accepted', TO_DATE('2024-04-25', 'YYYY-MM-DD'));

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status, Decision_Date)
VALUES ('C00003', 3, 'Floor Plan', 'E004', TO_DATE('2024-04-10', 'YYYY-MM-DD'), 'Denied', TO_DATE('2024-04-25', 'YYYY-MM-DD'));


-- INSERT PROPOSED TASK DATA --
INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00001', 'T001', 500, 2.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00001', 'T002', 300, 2.00);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00002', 'T001', 250, 2.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00002', 'T002', 150, 2.00);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00003', 'T001', 750, 2.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00003', 'T002', 450, 2.00);

-- INSERT WORK ORDER DATA --
--INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)

-- INSERT TASKORDER DATA --
--INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status, Date_Complete)

-- INSERT WORK ASSIGNMENT DATA --
--INSERT INTO WorkAssignments (Assignment_No, Order_No, Authorizer_ID, Authorized_Date, Start_Date, Finish_Date, Supervisor_ID, Vehicle_No)

-- INSERT MATERIAL ASSIGNMENT DATA --
--INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Send_QTY, Used_QTY)

-- INSERT LABOR ASSIGNMENT DATA --
--INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Pay_Type, Est_Hours, Used_Hours)

-- INSERT INVOICE DATA --
--INSERT INTO Invoices (Invoice_No, Proposal_No, Invoice_Date, Invoice_Total)

SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Employees;
SELECT COUNT(*) FROM Materials;
SELECT COUNT(*) FROM Proposals;
SELECT COUNT(*) FROM Tasks;
SELECT COUNT(*) FROM TaskRequests;
--SELECT COUNT(*) FROM WorkOrders;
--SELECT COUNT(*) FROM TaskOrders;
--SELECT COUNT(*) FROM WorkAssignments;
--SELECT COUNT(*) FROM MaterialAssignments;
--SELECT COUNT(*) FROM LaborAssignments;
--SELECT COUNT(*) FROM Invoices;


COMMIT;