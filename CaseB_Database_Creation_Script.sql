DROP TABLE TaskRequests;
DROP TABLE MaterialAssignments;
DROP TABLE Materials;
DROP TABLE LaborAssignments;
DROP TABLE WorkAssignments;
DROP TABLE TaskOrders;
DROP TABLE WorkOrders;
DROP TABLE Invoices;
DROP TABLE Tasks;
DROP TABLE Proposals;
DROP TABLE Customers;
DROP TABLE Employees;
DROP SEQUENCE customer_seq;
DROP SEQUENCE proposal_seq;
DROP SEQUENCE assign_seq;


CREATE TABLE Employees (
    Emp_ID CHAR(4),
    Emp_Name VARCHAR(30) CONSTRAINT Emp_Name_Required NOT NULL,
    Emp_Role VARCHAR(15) CONSTRAINT Emp_Role_Required NOT NULL,
    Pay_Type VARCHAR(9) CONSTRAINT PayType_Required NOT NULL,
CONSTRAINT PKEmployee PRIMARY KEY (Emp_ID),
CONSTRAINT ChkRole CHECK (Emp_Role IN ('Project Manager', 'Salesperson', 'Crew Supervisor', 'Worker')),
CONSTRAINT ChkPay_Type CHECK (Pay_Type IN ('Hourly', 'Per Piece', 'Contract'))
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
    Task_Names VARCHAR(50) CONSTRAINT Task_Names_Required NOT NULL,
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
    Order_No CHAR(9),
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


CREATE TABLE Invoices (
    Invoice_No CHAR(6),
    Proposal_No CHAR(6) CONSTRAINT InvoiceOrder_Required NOT NULL,
    Invoice_Date DATE,
    Invoice_Total DECIMAL(10, 2),
CONSTRAINT PKInvoice PRIMARY KEY (Invoice_No),
CONSTRAINT FKInvoice_Proposal FOREIGN KEY (Proposal_No) REFERENCES Proposals,
CONSTRAINT PosInvoiceTotal CHECK (Invoice_Total > 0)
);


CREATE TABLE TaskOrders (
    Task_ID CHAR(4),
    Order_No CHAR(9),
    Task_SQFT INTEGER CONSTRAINT TaskSQFT_Required NOT NULL,
    Est_Duration INTEGER CONSTRAINT EstDuration_Required NOT NULL,
    Task_Status VARCHAR(10) DEFAULT 'Pending',
    Date_Complete DATE,
    Billed_Amount DECIMAL(8, 2),
    Invoice_No CHAR(6),
CONSTRAINT PKTaskOrders PRIMARY KEY (Task_ID, Order_No),
CONSTRAINT FKTaskOrders_Task FOREIGN KEY (Task_ID) REFERENCES Tasks,
CONSTRAINT FKTaskOrders_Order FOREIGN KEY (Order_No) REFERENCES WorkOrders,
CONSTRAINT FKTaskOrders_Invoice FOREIGN KEY (Invoice_No) REFERENCES Invoices,
CONSTRAINT PosTaskSQFT CHECK (Task_SQFT > 0),
CONSTRAINT PosEstDuration CHECK (Est_Duration > 0),
CONSTRAINT PosBilledAmount CHECK (Billed_Amount > 0),
CONSTRAINT ChkTaskStatus CHECK (Task_Status IN ('Pending', 'In Process', 'Completed'))
);

CREATE OR REPLACE TRIGGER TaskStatus_update
AFTER UPDATE OF Task_Status ON TaskOrders
FOR EACH ROW
DECLARE
    next_invoice_no CHAR(6);
    invoice_exists NUMBER;
    proposal_no CHAR(6);
    customer_bill_date NUMBER;
    invoice_date DATE;
    bill_date DATE;
BEGIN
    IF :NEW.Task_Status = 'Completed' THEN
        SELECT COUNT(*) INTO invoice_exists
        FROM Invoices
        JOIN WorkOrders ON Invoices.Proposal_No = WorkOrders.Proposal_No
        WHERE WorkOrders.Order_No = :NEW.Order_No;

        IF invoice_exists = 0 THEN
            SELECT 'I' || LPAD(TO_NUMBER(SUBSTR(MAX(Invoice_No), 2)) + 1, 5, '0') INTO next_invoice_no
            FROM Invoices;

            SELECT Proposal_No INTO proposal_no
            FROM WorkOrders
            WHERE Order_No = :NEW.Order_No;

            INSERT INTO Invoices (Invoice_No, Proposal_No, Invoice_Date, Invoice_Total)
            VALUES (next_invoice_no, proposal_no, SYSDATE, :NEW.Billed_Amount);

            UPDATE TaskOrders
            SET Invoice_No = next_invoice_no
            WHERE Order_No = :NEW.Order_No
            AND Task_ID = :NEW.Task_ID;
        ELSE
            SELECT MAX(Invoice_Date) INTO invoice_date
            FROM Invoices
            WHERE Proposal_No = proposal_no;

            SELECT BillCycle_Date INTO customer_bill_date
            FROM Customers
            WHERE Cust_No = (SELECT Cust_No FROM WorkOrders WHERE Order_No = :NEW.Order_No);

            bill_date := CASE
                WHEN TO_NUMBER(TO_CHAR(SYSDATE, 'DD')) >= customer_bill_date THEN
                    TRUNC(SYSDATE, 'MM') + customer_bill_date
                ELSE
                    ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1) + customer_bill_date
                END;

            IF invoice_date < bill_date THEN
                SELECT 'I' || LPAD(TO_NUMBER(SUBSTR(MAX(Invoice_No), 2)) + 1, 5, '0') INTO next_invoice_no
                FROM Invoices;

                INSERT INTO Invoices (Invoice_No, Proposal_No, Invoice_Date, Invoice_Total)
                VALUES (next_invoice_no, proposal_no, SYSDATE, :NEW.Billed_Amount);

                UPDATE TaskOrders
                SET Invoice_No = next_invoice_no
                WHERE Order_No = :NEW.Order_No
                AND Task_ID = :NEW.Task_ID;
            ELSE
                UPDATE Invoices
                SET Invoice_Total = Invoice_Total + :NEW.Billed_Amount
                WHERE Proposal_No = proposal_no
                AND Invoice_Date = invoice_date;

                UPDATE TaskOrders
                SET Invoice_No = (SELECT Invoice_No FROM Invoices WHERE Proposal_No = proposal_no AND Invoice_Date = invoice_date)
                WHERE Order_No = :NEW.Order_No
                AND Task_ID = :NEW.Task_ID;
            END IF;
        END IF;
    END IF;
END;
/

CREATE TABLE WorkAssignments (
    Assignment_No CHAR(6),
    Order_No CHAR(9) CONSTRAINT AssignOrder_Required NOT NULL,
    Authorizer_ID CHAR(4) CONSTRAINT Authorizer_Required NOT NULL,
    Authorized_Date DATE DEFAULT SYSDATE,
    Start_Date DATE CONSTRAINT StartDate_Required NOT NULL,
    Finish_Date DATE,
    Supervisor_ID CHAR(4) CONSTRAINT Supervisor_Required NOT NULL,
    Vehicle_No INTEGER CONSTRAINT Vehicle_Required NOT NULL,
CONSTRAINT PKWorkAssignments PRIMARY KEY (Assignment_No),
CONSTRAINT FKWorkOrders_Assign FOREIGN KEY (Order_No) REFERENCES WorkOrders,
CONSTRAINT FKWorkAssignments_Authorizer FOREIGN KEY (Authorizer_ID) REFERENCES Employees(Emp_ID),
CONSTRAINT FKWorkAssignments_Supervisor FOREIGN KEY (Supervisor_ID) REFERENCES Employees(Emp_ID),
CONSTRAINT PosVehicle CHECK (Vehicle_No >= 0)
);

CREATE SEQUENCE assign_seq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER assignment_auto_increment
BEFORE INSERT ON WorkAssignments 
FOR EACH ROW
BEGIN
    SELECT 'A' || TO_CHAR(assign_seq.NEXTVAL, 'FM00000') INTO :new.Assignment_No FROM dual;
END;
/


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
    Assignment_No CHAR(6),
    Material_ID CHAR(4),
    Material_Sent INTEGER CONSTRAINT MatSent_Required NOT NULL,
    Material_Used INTEGER,
CONSTRAINT PKMatAssignments PRIMARY KEY (Task_ID, Assignment_No, Material_ID),
CONSTRAINT FKMatAssignments_Task FOREIGN KEY (Task_ID) REFERENCES Tasks,
CONSTRAINT FKMatAssignments_Assign FOREIGN KEY (Assignment_No) REFERENCES WorkAssignments,
CONSTRAINT FKMatAssignments_Material FOREIGN KEY (Material_ID) REFERENCES Materials,
CONSTRAINT PosMatSentQTY CHECK (Material_Sent > 0),
CONSTRAINT PosMatUsedQTY CHECK (Material_Used >= 0)
);


CREATE TABLE LaborAssignments (
    Assignment_No CHAR(6),
    Task_ID CHAR(4),
    Worker CHAR(4),
    Pay_Rate DECIMAL(7,2) CONSTRAINT PayRate_Required NOT NULL,
    Est_Hours INTEGER CONSTRAINT EstHours_Required NOT NULL,
    Used_Hours INTEGER,
CONSTRAINT PKTaskAssignments PRIMARY KEY (Assignment_No, Task_ID, Worker),
CONSTRAINT FKTaskAssignments_Assign FOREIGN KEY (Assignment_No) REFERENCES WorkAssignments,
CONSTRAINT FKTaskAssignments_Task FOREIGN KEY (Task_ID) REFERENCES Tasks,
CONSTRAINT FKTaskAssignments_Worker FOREIGN KEY (Worker) REFERENCES Employees(Emp_ID),
CONSTRAINT PosPay_Rate CHECK (Pay_Rate > 0),
CONSTRAINT PosEst_Hours CHECK (Est_Hours > 0),
CONSTRAINT PosUsed_Hours CHECK (Used_Hours > 0 OR Used_Hours IS NULL)
);



-- INSERT CUSTOMER DATA --
INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date) 
VALUES ('Acme Construction Inc.', '123 Main St, Anytown, CA 12345', 'General Contractor', 1);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Smith Residential Builders', '456 Otter Dr, Sometown, NY 67890', 'General Contractor', 15);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Oakland Transit Authority', '789 Capitol Ave, Washington, DC 20001', 'Government', 1);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('City of Lakeview', '789 Capitol Ave, Springfield, IL 62701', 'Government', 1);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Justin Hershowitz', '321 Elm Ln, Mytown, TX 54321', 'Residential', 5);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Wilson Family Builders', '456 Crestview Dr, Hilltown, CO 80501', 'General Contractor', 3);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Cerberus Industrial Solutions LLC', '159 Tower Blvd, Bigcity, CA 90210', 'Commercial', 13);

INSERT INTO Customers (Cust_BillName, Cust_BillAddress, Cust_Type, BillCycle_Date)
VALUES ('Steel City Industrial', '159 Iron St, Bigcity, CA 90210', 'Commercial', 5);

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
INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role, Pay_Type)
VALUES ('E001', 'Michael Thompson', 'Project Manager', 'Contract');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role, Pay_Type)
VALUES ('E002', 'Sarah Davis', 'Project Manager', 'Contract');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role, Pay_Type)
VALUES ('E003', 'Robert Welsh', 'Salesperson', 'Hourly');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role, Pay_Type)
VALUES ('E004', 'Aria Jude', 'Salesperson', 'Hourly');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role, Pay_Type)
VALUES ('E005', 'Marcus Rodriguez', 'Crew Supervisor', 'Hourly');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role, Pay_Type)
VALUES ('E006', 'David LeFluer', 'Crew Supervisor', 'Hourly');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role, Pay_Type)
VALUES ('E007', 'Rob Mbota', 'Worker', 'Hourly');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role, Pay_Type)
VALUES ('E008', 'William Baker', 'Worker', 'Hourly');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role, Pay_Type)
VALUES ('E009', 'Amanda Wilson', 'Worker', 'Hourly');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role, Pay_Type)
VALUES ('E010', 'Omar Davilla', 'Worker', 'Per Piece');

INSERT INTO Employees (Emp_ID, Emp_Name, Emp_Role, Pay_Type)
VALUES ('E011', 'Samuel Lee', 'Worker', 'Per Piece');


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
INSERT INTO Tasks (Task_ID, Task_Names)
VALUES ('T001', 'Wall Insulation');

INSERT INTO Tasks (Task_ID, Task_Names)
VALUES ('T002', 'Floor Insulation');

INSERT INTO Tasks (Task_ID, Task_Names)
VALUES ('T003', 'Attic Insulation');

INSERT INTO Tasks (Task_ID, Task_Names)
VALUES ('T004', 'Spray Foam Insulation');

INSERT INTO Tasks (Task_ID, Task_Names)
VALUES ('T005', 'Ceiling Insulation');

INSERT INTO Tasks (Task_ID, Task_Names)
VALUES ('T006', 'Ceiling Acoustics');

INSERT INTO Tasks (Task_ID, Task_Names)
VALUES ('T007', 'Asbestos Removal');

INSERT INTO Tasks (Task_ID, Task_Names)
VALUES ('T008', 'Air Sealing');


-- INSERT PROPOSAL DATA --
INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status, Decision_Date)
VALUES ('C00001', 2, 'Floor Plan', 'E004', TO_DATE('2024-03-20', 'YYYY-MM-DD'), 'Accepted', TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status, Decision_Date)
VALUES ('C00002', 1, 'Floor Plan', 'E003', TO_DATE('2024-04-08', 'YYYY-MM-DD'), 'Accepted', TO_DATE('2024-04-15', 'YYYY-MM-DD'));

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status, Decision_Date)
VALUES ('C00003', 2, 'Floor Plan', 'E004', TO_DATE('2024-04-10', 'YYYY-MM-DD'), 'Accepted', TO_DATE('2024-04-25', 'YYYY-MM-DD'));

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status, Decision_Date)
VALUES ('C00004', 1, 'Floor Plan', 'E004', TO_DATE('2024-04-11', 'YYYY-MM-DD'), 'Accepted', TO_DATE('2024-04-23', 'YYYY-MM-DD'));

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status, Decision_Date)
VALUES ('C00005', 1, 'Walk Through', 'E003', TO_DATE('2024-04-15', 'YYYY-MM-DD'), 'Denied', TO_DATE('2024-04-20', 'YYYY-MM-DD'));

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status, Decision_Date)
VALUES ('C00006', 2, 'Floor Plan', 'E003', TO_DATE('2024-04-15', 'YYYY-MM-DD'), 'Accepted', TO_DATE('2024-04-30', 'YYYY-MM-DD'));

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status)
VALUES ('C00007', 2, 'Floor Plan', 'E004', TO_DATE('2024-04-19', 'YYYY-MM-DD'), 'Pending');

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status)
VALUES ('C00008', 2, 'Floor Plan', 'E004', TO_DATE('2024-04-20', 'YYYY-MM-DD'), 'Accepted');

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status, Decision_Date)
VALUES ('C00009', 1, 'Walk Through', 'E004', TO_DATE('2024-04-22', 'YYYY-MM-DD'), 'Accepted', TO_DATE('2024-04-30', 'YYYY-MM-DD'));

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status)
VALUES ('C00010', 1, 'Floor Plan', 'E003', TO_DATE('2024-04-23', 'YYYY-MM-DD'), 'Pending');

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status, Decision_Date)
VALUES ('C00011', 2, 'Walk Through', 'E003', TO_DATE('2024-04-26', 'YYYY-MM-DD'), 'Accepted', TO_DATE('2024-05-01', 'YYYY-MM-DD'));

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status)
VALUES ('C00012', 1, 'Floor Plan', 'E004', TO_DATE('2024-05-01', 'YYYY-MM-DD'), 'Pending');

INSERT INTO Proposals (Cust_No, Location_QTY, Est_Method, Salesperson_ID, Prop_Date, Prop_Status, Decision_Date)
VALUES ('C00013', 2, 'Floor Plan', 'E003', TO_DATE('2024-05-01', 'YYYY-MM-DD'), 'Denied', TO_DATE('2024-05-01', 'YYYY-MM-DD'));


-- INSERT TASK REQUESTS DATA --
INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00001', 'T001', 500, 4.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00001', 'T004', 800, 7.00);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00002', 'T001', 2250, 4.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00002', 'T002', 1150, 5.00);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00003', 'T001', 2750, 4.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00003', 'T003', 1250, 5.00);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00004', 'T007', 3800, 6.75);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00005', 'T001', 750, 4.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00005', 'T005', 450, 4.75);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00006', 'T001', 2950, 4.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00006', 'T004', 1600, 7.00);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00007', 'T001', 7500, 4.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00007', 'T002', 2550, 5.00);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00007', 'T003', 2500, 3.75);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00007', 'T004', 1600, 7.00);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00008', 'T001', 3500, 4.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00008', 'T006', 2050, 5.00);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00009', 'T001', 2550, 4.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00009', 'T008', 1100, 7.25);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00010', 'T007', 4200, 6.75);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00011', 'T001', 3750, 4.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00011', 'T003', 2250, 5.00);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00011', 'T004', 1500, 7.00);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00012', 'T001', 950, 4.50);

INSERT INTO TaskRequests (Proposal_No, Task_ID, Total_SQFT, Quoted_SQFTPrice)
VALUES ('P00013', 'T001', 1500, 4.50);


-- INSERT INVOICE DATA --
INSERT INTO Invoices (Invoice_No, Proposal_No, Invoice_Date, Invoice_Total)
VALUES ('I00001', 'P00001', TO_DATE('2024-04-08', 'YYYY-MM-DD'), 12500.00);

INSERT INTO Invoices (Invoice_No, Proposal_No, Invoice_Date, Invoice_Total)
VALUES ('I00002', 'P00004', TO_DATE('2024-04-23', 'YYYY-MM-DD'), 25650.00);

INSERT INTO Invoices (Invoice_No, Proposal_No)
VALUES ('I00003', 'P00006');


-- INSERT WORK ORDER DATA --
INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)
VALUES ('W00001-01', 'P00001', 'Acme Construction Office', '123 Main St, Anytown, TX 12345', TO_DATE('2024-04-10', 'YYYY-MM-DD'), '', 'E001');

INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)
VALUES ('W00001-02', 'P00001', 'Acme Construction Warehouse', '123 Main St, Anytown, TX 12345', TO_DATE('2024-04-10', 'YYYY-MM-DD'), '', 'E001');

INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)
VALUES ('W00002-01', 'P00002', 'Centerview Subdivision Lot 2', '456 Oak Rd, Pionville, LA 70890', TO_DATE('2024-04-15', 'YYYY-MM-DD'), '', 'E002');

INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)
VALUES ('W00002-02', 'P00002', 'Centerview Subivision Lot 7', '456 Otter Dr, Pionville, LA 70890', TO_DATE('2024-04-15', 'YYYY-MM-DD'), '', 'E002');

INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)
VALUES ('W00003-01', 'P00003', 'Oakland Transit Authority', '784 Capitol Ave, Oakland, AR 20001', TO_DATE('2024-05-01', 'YYYY-MM-DD'), '', 'E001');

INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)
VALUES ('W00003-02', 'P00003', 'Oakland Transit Annex', '789 Capitol Ave, Oakland, AR 20001', TO_DATE('2024-05-01', 'YYYY-MM-DD'), '', 'E002');

INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)
VALUES ('W00004-01', 'P00004', 'Lakeview City Hall', '104 Main Ave, Lakeview, TX 62701', TO_DATE('2024-04-23', 'YYYY-MM-DD'), '', 'E001');

INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)
VALUES ('W00005-01', 'P00006', 'Chesterton Residence', '789 Maple Ave, Suburbville, LA 70610', TO_DATE('2024-05-04', 'YYYY-MM-DD'), '', 'E002');

INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)
VALUES ('W00005-02', 'P00006', 'Broadmoore Development Lot 12', '1105 Pine St, Newtown, LA 70610', TO_DATE('2024-05-04', 'YYYY-MM-DD'), '', 'E002');

INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)
VALUES ('W00006-01', 'P00008', 'Altitude Products LLC.', '1105 Steward Blvd, Trailhead, TX 20210', TO_DATE('2024-05-10', 'YYYY-MM-DD'), '', 'E002');

INSERT INTO WorkOrders (Order_No, Proposal_No, Location_Name, Location_Address, Required_Date, Order_Notes, Manager_ID)
VALUES ('W00006-02', 'P00008', 'Precision Manufacturing Warehouse #3', '159 Iron St, Tyler, TX 75701', TO_DATE('2024-05-15', 'YYYY-MM-DD'), '', 'E001');


-- INSERT TASKORDER DATA --
INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status, Date_Complete, Billed_Amount, Invoice_No)
VALUES ('T001', 'W00001-01', 500, 12, 'Completed', TO_DATE('2024-04-05', 'YYYY-MM-DD'), 2850, 'I00001');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status, Date_Complete, Billed_Amount, Invoice_No)
VALUES ('T004', 'W00001-01', 450, 6, 'Completed', TO_DATE('2024-04-05', 'YYYY-MM-DD'), 6500, 'I00001');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status, Date_Complete, Billed_Amount, Invoice_No)
VALUES ('T004', 'W00001-02', 350, 18, 'Completed', TO_DATE('2024-04-08', 'YYYY-MM-DD'), 3150, 'I00001');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status, Date_Complete)
VALUES ('T001', 'W00002-01', 1050, 15, 'Completed', TO_DATE('2024-04-17', 'YYYY-MM-DD'));

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status)
VALUES ('T002', 'W00002-01', 1150, 9, 'In Process');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status)
VALUES ('T001', 'W00002-02', 1200, 24, 'Pending');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status)
VALUES ('T001', 'W00003-01', 2750, 15, 'Pending');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status)
VALUES ('T005', 'W00003-02', 1250, 35, 'Pending');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status, Date_Complete, Billed_Amount, Invoice_No)
VALUES ('T007', 'W00004-01', 3800, 50, 'Completed', TO_DATE('2024-04-22', 'YYYY-MM-DD'), 25650, 'I00002');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status, Date_Complete, Invoice_No)
VALUES ('T001', 'W00005-01', 1500, 50, 'Completed', TO_DATE('2024-04-26', 'YYYY-MM-DD'), 'I00003');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status, Date_Complete, Invoice_No)
VALUES ('T004', 'W00005-01', 1600, 30, 'Completed', TO_DATE('2024-04-29', 'YYYY-MM-DD'), 'I00003');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status, Date_Complete, Invoice_No)
VALUES ('T001', 'W00005-02', 1450, 30, 'Completed', TO_DATE('2024-05-03', 'YYYY-MM-DD'), 'I00003');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status)
VALUES ('T001', 'W00006-01', 3500, 65, 'Pending');

INSERT INTO TaskOrders (Task_ID, Order_No, Task_SQFT, Est_Duration, Task_Status)
VALUES ('T006', 'W00006-02', 2050, 45, 'Pending');


-- INSERT WORK ASSIGNMENT DATA --
INSERT INTO WorkAssignments (Assignment_No, Order_No, Authorizer_ID, Start_Date, Finish_Date, Supervisor_ID, Vehicle_No)
VALUES ('A00001', 'W00001-01', 'E001', TO_DATE('2024-04-04', 'YYYY-MM-DD'), TO_DATE('2024-04-05', 'YYYY-MM-DD'), 'E005', 1);

INSERT INTO WorkAssignments (Assignment_No, Order_No, Authorizer_ID, Start_Date, Finish_Date, Supervisor_ID, Vehicle_No)
VALUES ('A00002', 'W00001-02', 'E001', TO_DATE('2024-04-07', 'YYYY-MM-DD'), TO_DATE('2024-04-08', 'YYYY-MM-DD'), 'E005', 1);

INSERT INTO WorkAssignments (Assignment_No, Order_No, Authorizer_ID, Start_Date, Finish_Date, Supervisor_ID, Vehicle_No)
VALUES ('A00003', 'W00002-01', 'E002', TO_DATE('2024-04-16', 'YYYY-MM-DD'), TO_DATE('2024-04-17', 'YYYY-MM-DD'), 'E006', 2);

INSERT INTO WorkAssignments (Assignment_No, Order_No, Authorizer_ID, Start_Date, Finish_Date, Supervisor_ID, Vehicle_No)
VALUES ('A00004', 'W00004-01', 'E002', TO_DATE('2024-04-16', 'YYYY-MM-DD'), TO_DATE('2024-04-17', 'YYYY-MM-DD'), 'E006', 2);

INSERT INTO WorkAssignments (Assignment_No, Order_No, Authorizer_ID, Start_Date, Finish_Date, Supervisor_ID, Vehicle_No)
VALUES ('A00005', 'W00004-01', 'E002', TO_DATE('2024-04-19', 'YYYY-MM-DD'), TO_DATE('2024-04-20', 'YYYY-MM-DD'), 'E006', 2);

INSERT INTO WorkAssignments (Assignment_No, Order_No, Authorizer_ID, Start_Date, Finish_Date, Supervisor_ID, Vehicle_No)
VALUES ('A00006', 'W00004-01', 'E002', TO_DATE('2024-04-21', 'YYYY-MM-DD'), TO_DATE('2024-04-22', 'YYYY-MM-DD'), 'E006', 2);

INSERT INTO WorkAssignments (Assignment_No, Order_No, Authorizer_ID, Start_Date, Finish_Date, Supervisor_ID, Vehicle_No)
VALUES ('A00007', 'W00005-01', 'E002', TO_DATE('2024-04-25', 'YYYY-MM-DD'), TO_DATE('2024-04-26', 'YYYY-MM-DD'), 'E006', 2);

INSERT INTO WorkAssignments (Assignment_No, Order_No, Authorizer_ID, Start_Date, Finish_Date, Supervisor_ID, Vehicle_No)
VALUES ('A00008', 'W00005-01', 'E002', TO_DATE('2024-04-28', 'YYYY-MM-DD'), TO_DATE('2024-04-29', 'YYYY-MM-DD'), 'E006', 2);

INSERT INTO WorkAssignments (Assignment_No, Order_No, Authorizer_ID, Start_Date, Finish_Date, Supervisor_ID, Vehicle_No)
VALUES ('A00009', 'W00005-02', 'E002', TO_DATE('2024-05-02', 'YYYY-MM-DD'), TO_DATE('2024-05-03', 'YYYY-MM-DD'), 'E006', 2);


-- INSERT MATERIAL ASSIGNMENT DATA --
INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Material_Sent, Material_Used)
VALUES ('T001', 'A00001', 'M001', 7, 6);

INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Material_Sent, Material_Used)
VALUES ('T004', 'A00001', 'M008', 2, 2);

INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Material_Sent, Material_Used)
VALUES ('T004', 'A00002', 'M007', 2, 2);

INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Material_Sent, Material_Used)
VALUES ('T001', 'A00003', 'M001', 15, 13);

INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Material_Sent, Material_Used)
VALUES ('T002', 'A00003', 'M002', 8, 6);

INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Material_Sent, Material_Used)
VALUES ('T007', 'A00004', 'M007', 5, 5);

INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Material_Sent, Material_Used)
VALUES ('T007', 'A00005', 'M007', 5, 5);

INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Material_Sent, Material_Used)
VALUES ('T007', 'A00006', 'M007', 5, 3);

INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Material_Sent, Material_Used)
VALUES ('T001', 'A00007', 'M001', 20, 18);

INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Material_Sent, Material_Used)
VALUES ('T004', 'A00008', 'M007', 5, 4);

INSERT INTO MaterialAssignments (Task_ID, Assignment_No, Material_ID, Material_Sent, Material_Used)
VALUES ('T001', 'A00009', 'M001', 15, 14);


-- INSERT LABOR ASSIGNMENT DATA --
INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00001', 'T001', 'E007', 16.75, 10, 10);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00001', 'T004', 'E008', 20.00, 5, 5);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00002', 'T004', 'E009', 15.00, 5, 5);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00003', 'T001', 'E007', 16.75, 8, 8);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00003', 'T001', 'E010', 18.50, 8, 8);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00003', 'T002', 'E008', 20.00, 8, 7);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00004', 'T007', 'E007', 16.75, 12, 12);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00004', 'T007', 'E010', 18.50, 12, 12);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00005', 'T007', 'E007', 16.75, 12, 12);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00005', 'T007', 'E010', 18.50, 12, 12);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00006', 'T007', 'E007', 16.75, 12, 10);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00006', 'T007', 'E010', 18.50, 12, 10);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00007', 'T001', 'E008', 20.00, 10, 10);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00007', 'T001', 'E009', 15.00, 10, 10);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00008', 'T004', 'E008', 20.00, 10, 10);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00008', 'T004', 'E007', 16.75, 10, 10);

INSERT INTO LaborAssignments (Assignment_No, Task_ID, Worker, Pay_Rate, Est_Hours, Used_Hours)
VALUES ('A00009', 'T001', 'E009', 15.00, 10, 10);





SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Employees;
SELECT COUNT(*) FROM Materials;
SELECT COUNT(*) FROM Proposals;
SELECT COUNT(*) FROM Tasks;
SELECT COUNT(*) FROM TaskRequests;
SELECT COUNT(*) FROM WorkOrders;
SELECT COUNT(*) FROM TaskOrders;
SELECT COUNT(*) FROM WorkAssignments;
SELECT COUNT(*) FROM MaterialAssignments;
SELECT COUNT(*) FROM LaborAssignments;
SELECT COUNT(*) FROM Invoices;


COMMIT;