
DROP TRIGGER apply_payment;
DROP TABLE Payments;
DROP TABLE Billing_Cycle;
DROP TABLE Statements;
DROP TABLE Disbursements;
DROP TABLE Loans;
DROP TABLE Customers;
DROP TABLE Loan_Types;
DROP TABLE Employees;


CREATE TABLE Customers (
    Cust_SSN              CHAR(11),
    Cust_FirstName        VARCHAR(25)    CONSTRAINT Cust_FirstName_Required NOT NULL,
    Cust_LastName         VARCHAR(25)    CONSTRAINT Cust_LastName_Required NOT NULL,
    Cust_Address          VARCHAR(100)   CONSTRAINT Cust_Address_Required NOT NULL,
    Cust_Phone            VARCHAR(12)    CONSTRAINT Cust_PhoneRequired NOT NULL,
    Cust_PrimaryIncome    INTEGER        CONSTRAINT Cust_PrimaryIncome_Required NOT NULL,
    Cust_SecondaryIncome  INTEGER,
    Cust_Update           DATE           DEFAULT SYSDATE CONSTRAINT Cust_Update_Required NOT NULL,
CONSTRAINT PKCust_SSN PRIMARY KEY (Cust_SSN),
CONSTRAINT Unique_Cust_Phone UNIQUE (Cust_Phone),
CONSTRAINT Cust_SSN_Format CHECK (REGEXP_LIKE(Cust_SSN, '^[0-9]{3}-[0-9]{2}-[0-9]{4}$')),
CONSTRAINT Cust_Phone_Format CHECK (REGEXP_LIKE(Cust_Phone, '^[0-9]{3}-[0-9]{3}-[0-9]{4}$')),
CONSTRAINT Positive_PrimaryIncome CHECK (Cust_PrimaryIncome > 0),
CONSTRAINT Positive_SecondaryIncome CHECK (Cust_SecondaryIncome > 0));


CREATE TABLE Loan_Types (
    Loan_Type             CHAR(4),
    Loan_Description      VARCHAR(50)    CONSTRAINT Loan_Description_Required NOT NULL,
    Max_LoanTerm          INTEGER        CONSTRAINT Max_LoanTerm_Required NOT NULL,
    Loan_Restrictions     VARCHAR(255),
CONSTRAINT PKLoan_Type PRIMARY KEY (Loan_Type),
CONSTRAINT Unique_Loan_Description UNIQUE (Loan_Description),
CONSTRAINT Loan_Type_Format CHECK (REGEXP_LIKE(Loan_Type, '^[A-Z]{2}[0-9]{2}$')),
CONSTRAINT Valid_Max_LoanTerm CHECK (Max_LoanTerm > 0 and Max_LoanTerm <= 20));


CREATE TABLE Employees (
    Emp_Number            CHAR(6),
    Emp_FirstName         VARCHAR(25)    CONSTRAINT Emp_FirstName_Required NOT NULL,
    Emp_LastName          VARCHAR(25)    CONSTRAINT Emp_LastName_Required NOT NULL,
    Emp_Role              VARCHAR(25),
CONSTRAINT PKEmployee_Number PRIMARY KEY (Emp_Number),
CONSTRAINT Emp_Number_Format CHECK (REGEXP_LIKE(Emp_Number, '^[0-9]{6}$')),
CONSTRAINT Emp_Role_Allowed CHECK (Emp_Role IN ('Loan Officer', 'Underwriter')));


CREATE TABLE Loans (
    Loan_Number           CHAR(12),
    Application_Date      DATE            DEFAULT SYSDATE CONSTRAINT Application_Date_Required NOT NULL,
    Cust_SSN              CHAR(11)        CONSTRAINT Cust_SSN_Required NOT NULL,
    W2_Rcvd               NUMBER(1)       DEFAULT 0 CONSTRAINT W2_Rcvd_Required NOT NULL,
    TaxReturn_Rcvd        NUMBER(1)       DEFAULT 0 CONSTRAINT TaxReturn_Rcvd_Required NOT NULL,
    CreditReport_Rcvd     NUMBER(1)       DEFAULT 0 CONSTRAINT CreditReport_Rcvd_Required NOT NULL,
    BankInfo_Rcvd         NUMBER(1)       DEFAULT 0 CONSTRAINT BankInfo_Rcvd_Required NOT NULL,
    Application_Status    VARCHAR(15)     DEFAULT 'Pending' CONSTRAINT Application_Status_Required NOT NULL,
    Loan_Amount           DECIMAL(8, 2)   CONSTRAINT Loan_Amount_Required NOT NULL,
    Loan_Type             CHAR(4)         CONSTRAINT Loan_Type_Required NOT NULL,
    Loan_Term             INTEGER         CONSTRAINT Loan_Term_Required NOT NULL,
    Interest_Rate         DECIMAL(4, 2)   CONSTRAINT Interest_Rate_Required NOT NULL,
    Monthly_Payment       DECIMAL(6, 2)   CONSTRAINT Monthly_Payment_Required NOT NULL,
    Loan_Officer          CHAR(6)         CONSTRAINT Loan_Officer_Required NOT NULL,
    Underwriter           CHAR(6),
    Loan_ReviewDate       DATE,
    Risk_Factor           VARCHAR(15),
CONSTRAINT PKLoan_Number PRIMARY KEY (Loan_Number),
CONSTRAINT Format_Loan_Number CHECK (REGEXP_LIKE(Loan_Number, '^[0-9]{4}-[0-9]{4}-[0-9]{2}$')),
CONSTRAINT FKCust_SSN FOREIGN KEY (Cust_SSN) REFERENCES Customers,
CONSTRAINT FKLoan_Type FOREIGN KEY (Loan_Type) REFERENCES Loan_Types,
CONSTRAINT FKLoan_Officer FOREIGN KEY (Loan_Officer) REFERENCES Employees(Emp_Number),
CONSTRAINT FKUnderwriter FOREIGN KEY (Underwriter) REFERENCES Employees(Emp_Number),
CONSTRAINT Boolean_W2_Rcvd CHECK (W2_Rcvd IN (0, 1)),
CONSTRAINT Boolean_TaxReturn_Rcvd CHECK (TaxReturn_Rcvd IN (0, 1)),
CONSTRAINT Boolean_CreditReport_Rcvd CHECK (CreditReport_Rcvd IN (0, 1)),
CONSTRAINT Boolean_BankInfo_Rcvd CHECK (BankInfo_Rcvd IN (0, 1)),
CONSTRAINT Positive_Loan_Amount CHECK (Loan_Amount > 0),
CONSTRAINT Positive_Loan_Term CHECK (Loan_Term > 0),
CONSTRAINT Positive_Interest_Rate CHECK (Interest_Rate > 0),
CONSTRAINT Positive_Monthly_Payment CHECK (Monthly_Payment > 0),
CONSTRAINT Valid_Application_Status CHECK (Application_Status IN ('Approved', 'Pending', 'Denied')),
CONSTRAINT Valid_Risk_Factor CHECK (Risk_Factor IN ('High', 'Moderate', 'Low')));


CREATE TABLE Disbursements (
    Check_Number          INTEGER          GENERATED ALWAYS AS IDENTITY,
    Check_Amount          DECIMAL(8, 2)    CONSTRAINT Check_Amount_Required NOT NULL,
    Loan_Number           CHAR(12)         CONSTRAINT FKLoan_Number_Required NOT NULL,
    Disbursement_Date     DATE             DEFAULT SYSDATE CONSTRAINT Disbursement_Date_Required NOT NULL,
CONSTRAINT PKCheck_Number PRIMARY KEY (Check_Number),
CONSTRAINT FKLoan_Number FOREIGN KEY (Loan_Number) REFERENCES Loans,
CONSTRAINT Positive_Check_Amount CHECK (Check_Amount > 0));


CREATE TABLE Statements (
    Statement_Number      CHAR(15),
    Statement_Amount      DECIMAL(8, 2)     CONSTRAINT Statement_Amount_Required NOT NULL,
    Statement_Date        DATE              DEFAULT SYSDATE CONSTRAINT Statement_Date_Required NOT NULL,
    Due_Date              DATE              DEFAULT SYSDATE + 25 CONSTRAINT Due_Date_Required NOT NULL,
CONSTRAINT PKStatement_Number PRIMARY KEY (Statement_Number),
CONSTRAINT Statement_Number_Format CHECK (REGEXP_LIKE(Statement_Number, '^[0-9]{4}-[0-9]{4}-[A-Z]{3}[0-9]{2}$')),
CONSTRAINT Positive_Statement_Amount CHECK (Statement_Amount > 0));


CREATE TABLE Billing_Cycle (
    Loan_Number           CHAR(12),
    Statement_Number      CHAR(15),
    Loan_Balance          DECIMAL(8, 2)     CONSTRAINT Loan_Balance_Required NOT NULL,
    Account_Status        VARCHAR(15)       CONSTRAINT Account_Status_Required NOT NULL,
    Interest_Due          DECIMAL(8, 2)     CONSTRAINT Interest_Due_Required NOT NULL,
    Principal_Due         DECIMAL(8, 2)     CONSTRAINT Principal_Due_Required NOT NULL,
    Payments_Applied      DECIMAL(8, 2)     DEFAULT 0 CONSTRAINT Payments_Applied_Required NOT NULL,
    Last_Payment          DATE,
CONSTRAINT PKBilling_Cycle PRIMARY KEY (Loan_Number, Statement_Number),
CONSTRAINT CPKLoan_Number FOREIGN KEY (Loan_Number) REFERENCES Loans,
CONSTRAINT CPKStatement_Number FOREIGN KEY (Statement_Number) REFERENCES Statements,
CONSTRAINT Positive_Loan_Balance CHECK (Loan_Balance >= 0),
CONSTRAINT Positive_Interest_Due CHECK (Interest_Due >= 0),
CONSTRAINT Positive_Principal_Due CHECK (Principal_Due >= 0),
CONSTRAINT Positive_Payments_Applied CHECK (Payments_Applied >= 0),
CONSTRAINT Valid_Account_Status CHECK (Account_Status IN ('Current', 'Delinquent')));


CREATE TABLE Payments (
    Payment_Number        INTEGER           GENERATED ALWAYS AS IDENTITY,
    Statement_Number      CHAR(15)          CONSTRAINT FKStatement_Number_Required NOT NULL,
    Payment_Amount        DECIMAL(8, 2)     CONSTRAINT Payment_Amount_Required NOT NULL,
    Payment_Date          DATE              CONSTRAINT Payment_Date_Required NOT NULL,
CONSTRAINT PKPayment_Number PRIMARY KEY (Payment_Number),
CONSTRAINT FKStatement_Number FOREIGN KEY (Statement_Number) REFERENCES Statements,
CONSTRAINT Positive_Payment_Amount CHECK (Payment_Amount > 0));

CREATE OR REPLACE TRIGGER apply_payment
AFTER INSERT ON Payments
FOR EACH ROW
DECLARE
    remaining_payment_amount DECIMAL(8, 2);
    remaining_due DECIMAL(8, 2);
BEGIN
    -- Start with the full payment amount
    remaining_payment_amount := :new.Payment_Amount;

    -- Apply the payment to each loan from oldest to most recent
    FOR cycle IN (
        SELECT Interest_Due, Principal_Due, Loan_Number, Payments_Applied
        FROM Billing_Cycle
        WHERE Statement_Number = :new.Statement_Number
        ORDER BY TO_NUMBER(SUBSTR(Loan_Number, -2))
    )
    LOOP
        -- Calculate the remaining due for this loan's billing cycle
            remaining_due := cycle.Interest_Due + cycle.Principal_Due - cycle.Payments_Applied;

            -- Apply payment to the remaining due, up to the remaining payment amount
            IF LEAST(remaining_payment_amount, remaining_due) > 0 THEN
                UPDATE Billing_Cycle
                SET Payments_Applied = Payments_Applied + LEAST(remaining_payment_amount, remaining_due),
                    Last_Payment = :new.Payment_Date
                WHERE Statement_Number = :new.Statement_Number
                AND Loan_Number = cycle.Loan_Number;
            END IF;

            remaining_payment_amount := remaining_payment_amount - LEAST(remaining_payment_amount, remaining_due);

        -- If there's no payment left, exit the loop
        EXIT WHEN remaining_payment_amount <= 0;
    END LOOP;
END;
/



-- INSERT CUSTOMER DATA --
INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('123-45-6780', 'Sophia', 'Thompson', '789 Maple Blvd, Mapleview, CA 92345', '555-123-4560', 55000, 8000, TO_DATE('2023-09-12', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('234-56-7801', 'Liam', 'Johnson', '159 Oak Ln, Oakville, TX 67890', '555-234-5601', 62000, NULL, TO_DATE('2023-11-05', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('345-67-8012', 'Emma', 'Garcia', '753 Pine Ave, Pinewood, NY 09876', '555-345-6702', 48000, NULL, TO_DATE('2023-12-22', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('567-89-0134', 'Ava', 'Rogers', '369 Spruce Rd, Sprucedale, IL 67890', '555-567-8904', 58000, NULL, TO_DATE('2023-08-28', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('678-90-1245', 'Jacob', 'Wilson', '159 Oak Blvd, Oakridge, PA 09875', '555-678-9015', 81000, 18000, TO_DATE('2023-10-17', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('789-01-2356', 'Mia', 'Anderson', '753 Maple St, Maplecrest, CA 54322', '555-789-0126', 66000, NULL, TO_DATE('2023-07-08', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('890-12-3467', 'Michael', 'Thomas', '246 Pine Ln, Pineville, TX 67891', '555-890-1237', 38000, NULL, TO_DATE('2023-09-29', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('901-23-4578', 'Olivia', 'Jackson', '369 Cedar Ave, Cedargrove, NY 09874', '555-901-2348', 52000, NULL, TO_DATE('2023-12-11', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('012-34-5689', 'Noah', 'White', '159 Spruce Blvd, Sprucewood, FL 54323', '555-012-3459', 49000, 11000, TO_DATE('2023-07-31', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('123-45-6781', 'Isabella', 'Harris', '753 Oak Ln, Oakridge, IL 67892', '555-123-4561', 68000, 30000, TO_DATE('2023-10-09', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('234-56-7802', 'Mason', 'Martin', '246 Maple Ave, Maplecrest, PA 09876', '555-234-5602', 47000, NULL, TO_DATE('2023-11-21', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('345-67-8013', 'Harper', 'Thompson', '369 Pine Rd, Pineville, CA 54324', '555-345-6703', 48000, 21000, TO_DATE('2023-08-14', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('456-78-9024', 'Ethan', 'Garcia', '159 Cedar St, Cedarbrook, TX 67893', '555-456-7804', 104000, NULL, TO_DATE('2023-09-06', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('567-89-0135', 'Abigail', 'Martinez', '753 Spruce Ave, Sprucedale, NY 09877', '555-567-8905', 63000, 7000, TO_DATE('2023-12-18', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('678-90-1246', 'Benjamin', 'Robinson', '246 Oak Blvd, Oakridge, FL 54325', '555-678-9016', 56000, NULL, TO_DATE('2023-06-25', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('789-01-2357', 'Avery', 'Clark', '369 Maple Rd, Maplecrest, IL 67893', '555-789-0127', 59000, 9000, TO_DATE('2023-08-05', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('890-12-3468', 'Emily', 'Rodriguez', '159 Pine St, Pineville, PA 09878', '555-890-1238', 74000, NULL, TO_DATE('2023-10-22', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('901-23-4579', 'Daniel', 'Lewis', '753 Cedar Ave, Cedargrove, CA 54326', '555-901-2349', 92000, 19000, TO_DATE('2023-07-16', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('012-34-5690', 'Amelia', 'Lee', '246 Spruce Blvd, Sprucewood, TX 67894', '555-012-3460', 57000, NULL, TO_DATE('2023-09-03', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('123-45-6782', 'James', 'Walker', '369 Oak Ln, Oakridge, NY 09879', '555-123-4562', 83000, 16000, TO_DATE('2023-11-13', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('234-56-7803', 'Evelyn', 'Hall', '159 Maple St, Maplecrest, FL 54327', '555-234-5603', 41000, NULL, TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('345-67-8014', 'Alexander', 'Young', '753 Pine Ave, Pinewood, IL 67895', '555-345-6704', 71000, 13000, TO_DATE('2023-08-18', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('456-56-9023', 'Sophia', 'King', '246 Cedar St, Cedarbrook, PA 09880', '555-456-7805', 38000, NULL, TO_DATE('2023-07-02', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('567-89-0136', 'Elijah', 'Chatum', '369 Cedar Rd, Cedargrove, CA 54327', '555-567-8906', 61000, NULL, TO_DATE('2023-10-30', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('678-90-1247', 'Charlotte', 'Lopez', '159 Pine Ave, Pinewood, TX 67895', '555-678-9017', 73000, 15000, TO_DATE('2023-08-11', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('789-01-2358', 'Logan', 'Zion', '753 Maple Blvd, Mapleview, IL 67893', '555-789-0128', 85000, NULL, TO_DATE('2023-11-24', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('890-12-3469', 'Luna', 'Perez', '246 Oak Ln, Oakridge, PA 09879', '555-890-1239', 79000, NULL, TO_DATE('2023-09-08', 'YYYY-MM-DD'));

INSERT INTO Customers (Cust_SSN, Cust_FirstName, Cust_LastName, Cust_Address, Cust_Phone, Cust_PrimaryIncome, Cust_SecondaryIncome, Cust_Update)
VALUES ('901-23-4580', 'Henry', 'Schreiber', '369 Cedar St, Cedarbrook, FL 54328', '555-901-2350', 60000, NULL, TO_DATE('2023-07-20', 'YYYY-MM-DD'));



-- INSERT LOAN TYPES --
INSERT INTO Loan_Types (Loan_Type, Loan_Description, Max_LoanTerm, Loan_Restrictions)
VALUES ('PL01', 'Personal Loan - Home Improvement', 15, 'Allowed Range of $1,500 - $50,000. Quotes required for amounts over $10,000');

INSERT INTO Loan_Types (Loan_Type, Loan_Description, Max_LoanTerm, Loan_Restrictions)
VALUES ('PL02', 'Personal Loan - Education', 8, 'Allowed Range of $1,000 - $5,000 per semester. Must provide proof of enrollment in college or vocational training program');

INSERT INTO Loan_Types (Loan_Type, Loan_Description, Max_LoanTerm, Loan_Restrictions)
VALUES ('PL03', 'Personal Loan - Miscellaneous', 5, 'Allowed Range of $1,500 - $7,500.');

INSERT INTO Loan_Types (Loan_Type, Loan_Description, Max_LoanTerm, Loan_Restrictions)
VALUES ('PL04', 'Personal Loan - Debt Consolidation', 15, 'Allowed Range of $3,500 - $50,000. Must provide proof of payoff.');

INSERT INTO Loan_Types (Loan_Type, Loan_Description, Max_LoanTerm, Loan_Restrictions)
VALUES ('AL01', 'Auto Loan - New Car', 8, 'Allowed Range of $15,000 - $75,000. Down payment of 10% required.');

INSERT INTO Loan_Types (Loan_Type, Loan_Description, Max_LoanTerm, Loan_Restrictions)
VALUES ('AL02', 'Auto Loan - Used Car', 7, 'Allowed Range of $8,000 - $50,000. Vehicle age must not exceed 8 years');

INSERT INTO Loan_Types (Loan_Type, Loan_Description, Max_LoanTerm, Loan_Restrictions)
VALUES ('AL03', 'Auto Loan - Motorcycle', 5, 'Allowed Range of $2,500 - $25,000. Motorcycle age must not exceed 10 years');

INSERT INTO Loan_Types (Loan_Type, Loan_Description, Max_LoanTerm, Loan_Restrictions)
VALUES ('RE01', 'Recreation Equipment Loan - Boat', 8, 'Allowed Range of $7,500 - $50,000. Down payment of 20% required.');

INSERT INTO Loan_Types (Loan_Type, Loan_Description, Max_LoanTerm, Loan_Restrictions)
VALUES ('RE02', 'Recreation Equipment Loan - RV', 10, 'Allowed Range of $20,000 - $75,000. Down payment of 20% required.');



-- INSERT EMPLOYEE DATA --
INSERT INTO Employees (Emp_Number, Emp_FirstName, Emp_LastName, Emp_Role)
VALUES ('001001', 'Todd', 'Gallagher', 'Loan Officer');

INSERT INTO Employees (Emp_Number, Emp_FirstName, Emp_LastName, Emp_Role)
VALUES ('001002', 'Aurelia', 'Fitzgerald', 'Loan Officer');

INSERT INTO Employees (Emp_Number, Emp_FirstName, Emp_LastName, Emp_Role)
VALUES ('001003', 'Simon', 'Manning', 'Loan Officer');

INSERT INTO Employees (Emp_Number, Emp_FirstName, Emp_LastName, Emp_Role)
VALUES ('001004', 'Carter', 'Drake', 'Loan Officer');

INSERT INTO Employees (Emp_Number, Emp_FirstName, Emp_LastName, Emp_Role)
VALUES ('001005', 'Mark', 'Callahan', 'Underwriter');

INSERT INTO Employees (Emp_Number, Emp_FirstName, Emp_LastName, Emp_Role)
VALUES ('001006', 'Sylvia', 'Hawkins', 'Underwriter');

INSERT INTO Employees (Emp_Number, Emp_FirstName, Emp_LastName, Emp_Role)
VALUES ('001007', 'Kurt', 'Brennan', 'Underwriter');



-- INSERT LOAN DATA --
INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('6781-0001-01', TO_DATE('2023-05-19', 'YYYY-MM-DD'), '123-45-6781', 1, 1, 1, 1, 'Approved', 25000, 'PL01', 15, 5.5, 253.47, '001001', '001006', TO_DATE('2023-05-22', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('0135-0001-01', TO_DATE('2023-05-11', 'YYYY-MM-DD'), '567-89-0135', 1, 1, 1, 1, 'Approved', 25000, 'AL03', 5, 3.5, 489.58, '001003', '001007', TO_DATE('2023-05-14', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('7801-0001-01', TO_DATE('2023-06-05', 'YYYY-MM-DD'), '234-56-7801', 1, 1, 1, 1, 'Approved', 10000, 'AL02', 6, 3.5, 168.05, '001002', '001006', TO_DATE('2023-06-10', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer)
VALUES ('1246-0001-01', TO_DATE('2023-06-25', 'YYYY-MM-DD'), '678-90-1246', 0, 0, 1, 0, 'Denied', 50000, 'AL01', 6, 6.5, 791.67, '001004');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('9023-0001-01', TO_DATE('2023-07-02', 'YYYY-MM-DD'), '456-56-9023', 1, 1, 1, 1, 'Approved', 20000, 'AL01', 6, 4.5, 352.78, '001004', '001005', TO_DATE('2023-07-05', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('2358-0001-01', TO_DATE('2023-07-04', 'YYYY-MM-DD'), '789-01-2358', 1, 1, 1, 1, 'Approved', 10000, 'PL01', 8, 5.5, 150, '001004', '001007', TO_DATE('2023-07-07', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer)
VALUES ('2356-0001-01', TO_DATE('2023-07-08', 'YYYY-MM-DD'), '789-01-2356', 1, 1, 1, 0, 'Denied', 30000, 'RE02', 10, 6.5, 412.50, '001001');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('4579-0001-01', TO_DATE('2023-07-16', 'YYYY-MM-DD'), '901-23-4579', 1, 1, 1, 1, 'Approved', 10000, 'AL03', 5, 3.5, 195.83, '001003', '001007', TO_DATE('2023-07-19', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('5689-0001-01', TO_DATE('2023-07-31', 'YYYY-MM-DD'), '012-34-5689', 1, 1, 1, 1, 'Approved', 5000, 'PL02', 8, 6.5, 79.17, '001004', '001007', TO_DATE('2023-08-03', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('1245-0001-01', TO_DATE('2023-07-31', 'YYYY-MM-DD'), '678-90-1245', 1, 1, 1, 1, 'Approved', 5000, 'PL02', 8, 6.5, 79.17, '001003', '001006', TO_DATE('2023-08-03', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('8014-0001-01', TO_DATE('2023-08-10', 'YYYY-MM-DD'), '345-67-8014', 1, 1, 1, 1, 'Approved', 5000, 'PL02', 8, 6.5, 79.17, '001001', '001007', TO_DATE('2023-08-13', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('1247-0001-01', TO_DATE('2023-08-11', 'YYYY-MM-DD'), '678-90-1247', 1, 1, 1, 1, 'Approved', 10000, 'AL02', 7, 3.5, 148.21, '001004', '001007', TO_DATE('2023-08-14', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('8013-0001-01', TO_DATE('2023-08-14', 'YYYY-MM-DD'), '345-67-8013', 1, 1, 1, 1, 'Approved', 7500, 'PL03', 5, 6.5, 165.63, '001001', '001005', TO_DATE('2023-08-17', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('0134-0001-01', TO_DATE('2023-08-28', 'YYYY-MM-DD'), '567-89-0134', 1, 1, 1, 1, 'Approved', 10000, 'AL03', 5, 3.5, 195.83, '001002', '001007', TO_DATE('2023-08-31', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('9024-0001-01', TO_DATE('2023-09-06', 'YYYY-MM-DD'), '456-78-9024', 1, 1, 1, 1, 'Approved', 30000, 'RE02', 10, 5.5, 387.50, '001002', '001005', TO_DATE('2023-09-09', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('6780-0001-01', TO_DATE('2023-09-12', 'YYYY-MM-DD'), '123-45-6780', 1, 1, 1, 1, 'Approved', 25000, 'AL01', 8, 4.5, 354.17, '001001', '001005', TO_DATE('2023-09-15', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('3467-0001-01', TO_DATE('2023-09-29', 'YYYY-MM-DD'), '890-12-3467', 1, 1, 1, 1, 'Denied', 45000, 'AL01', 5, 5.5, 312.50, '001002', '001005', TO_DATE('2023-10-02', 'YYYY-MM-DD'), 'High');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('3469-0001-01', TO_DATE('2023-10-08', 'YYYY-MM-DD'), '890-12-3469', 1, 1, 1, 1, 'Approved', 2500, 'PL02', 4, 6.5, 65.63, '001001', '001006', TO_DATE('2023-10-11', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('3468-0001-01', TO_DATE('2023-10-22', 'YYYY-MM-DD'), '890-12-3468', 1, 1, 1, 1, 'Approved', 15000, 'PL01', 10, 5.5, 193.75, '001003', '001006', TO_DATE('2023-10-25', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('0136-0001-01', TO_DATE('2023-10-30', 'YYYY-MM-DD'), '567-89-0136', 1, 1, 1, 1, 'Approved', 5000, 'PL02', 8, 6.5, 79.17, '001003', '001006', TO_DATE('2023-11-02', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('6782-0001-01', TO_DATE('2023-11-13', 'YYYY-MM-DD'), '123-45-6782', 1, 1, 1, 1, 'Approved', 10000, 'AL03', 5, 4.5, 204.17, '001001', '001006', TO_DATE('2023-11-16', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('7802-0001-01', TO_DATE('2023-11-21', 'YYYY-MM-DD'), '234-56-7802', 1, 1, 1, 1, 'Approved', 10000, 'AL02', 5, 3.5, 195.83, '001001', '001007', TO_DATE('2023-11-24', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('3467-0001-02', TO_DATE('2023-11-30', 'YYYY-MM-DD'), '890-12-3467', 1, 1, 1, 1, 'Approved', 12000, 'PL04', 10, 6.5, 165.00, '001002', '001005', TO_DATE('2023-12-03', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('2357-0001-01', TO_DATE('2023-12-05', 'YYYY-MM-DD'), '789-01-2357', 1, 1, 1, 1, 'Approved', 28000, 'AL01', 7, 4.5, 438.33, '001004', '001006', TO_DATE('2023-12-08', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('4578-0001-01', TO_DATE('2023-12-11', 'YYYY-MM-DD'), '901-23-4578', 1, 1, 1, 1, 'Denied', 50000, 'AL01', 7, 4.5, 375.00, '001003', '001006', TO_DATE('2023-12-14', 'YYYY-MM-DD'), 'High');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer)
VALUES ('8014-0001-02', TO_DATE('2023-12-18', 'YYYY-MM-DD'), '345-67-8014', 1, 1, 1, 0, 'Denied', 5000, 'PL02', 8, 6.5, 81.25, '001001');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('8012-0001-01', TO_DATE('2023-12-22', 'YYYY-MM-DD'), '345-67-8012', 1, 1, 1, 1, 'Approved', 5000, 'PL03', 5, 7.5, 114.58, '001003', '001006', TO_DATE('2023-12-25', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('2358-0001-02', TO_DATE('2023-12-24', 'YYYY-MM-DD'), '789-01-2358', 1, 1, 1, 1, 'Approved', 10000, 'AL02', 5, 3.5, 195.83, '001002', '001005', TO_DATE('2023-12-27', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('7801-0001-02', TO_DATE('2024-01-05', 'YYYY-MM-DD'), '234-56-7801', 1, 1, 1, 1, 'Approved', 5000, 'PL02', 5, 6.5, 110.42, '001002', '001005', TO_DATE('2024-01-10', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('9023-0001-02', TO_DATE('2024-01-09', 'YYYY-MM-DD'), '456-56-9023', 1, 1, 1, 1, 'Approved', 5000, 'PL04', 10, 6.5, 68.75, '001002', '001005', TO_DATE('2024-01-12', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('5690-0001-01', TO_DATE('2024-01-13', 'YYYY-MM-DD'), '012-34-5690', 1, 1, 1, 1, 'Approved', 10000, 'AL02', 7, 3.5, 148.21, '001004', '001005', TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('7803-0001-01', TO_DATE('2024-01-14', 'YYYY-MM-DD'), '234-56-7803', 1, 1, 1, 1, 'Denied', 25000, 'RE01', 8, 6.5, 333.33, '001002', '001006', TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'High');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('3468-0001-02', TO_DATE('2024-02-03', 'YYYY-MM-DD'), '890-12-3468', 1, 1, 1, 1, 'Approved', 15000, 'RE01', 8, 5.5, 225.00, '001001', '001006', TO_DATE('2024-02-06', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('9024-0001-02', TO_DATE('2024-02-07', 'YYYY-MM-DD'), '456-78-9024', 1, 1, 1, 1, 'Approved', 25000, 'AL01', 8, 4.5, 354.17, '001002', '001005', TO_DATE('2024-02-10', 'YYYY-MM-DD'), 'Low');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('4580-0001-01', TO_DATE('2024-02-10', 'YYYY-MM-DD'), '901-23-4580', 1, 1, 1, 1, 'Approved', 25000, 'PL04', 15, 6.5, 274.31, '001003', '001005', TO_DATE('2024-02-12', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('6782-0001-02', TO_DATE('2024-03-17', 'YYYY-MM-DD'), '123-45-6782', 1, 1, 1, 1, 'Approved', 25000, 'AL02', 5, 4.0, 500.00, '001003', '001007', TO_DATE('2024-03-20', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('5689-0001-02', TO_DATE('2024-03-18', 'YYYY-MM-DD'), '012-34-5689', 1, 1, 1, 1, 'Approved', 25000, 'PL04', 10, 6.5, 343.75, '001004', '001005', TO_DATE('2024-03-21', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter, Loan_ReviewDate, Risk_Factor)
VALUES ('6781-0001-02', TO_DATE('2024-03-18', 'YYYY-MM-DD'), '123-45-6781', 1, 1, 1, 1, 'Approved', 20000, 'RE01', 8, 5.5, 300.00, '001002', '001005', TO_DATE('2024-03-21', 'YYYY-MM-DD'), 'Moderate');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer)
VALUES ('4579-0001-02', TO_DATE('2024-3-18', 'YYYY-MM-DD'), '901-23-4579', 1, 1, 1, 0, 'Pending', 15000, 'AL02', 5, 3.5, 293.75, '001002');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer)
VALUES ('2358-0001-03', TO_DATE('2024-03-20', 'YYYY-MM-DD'), '789-01-2358', 0, 0, 1, 1, 'Pending', 25000, 'RE02', 8, 5.5, 375.00, '001001');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter)
VALUES ('6780-0001-02', TO_DATE('2024-03-20', 'YYYY-MM-DD'), '123-45-6780', 1, 1, 1, 1, 'Pending', 15000, 'PL01', 10, 6.5, 206.25, '001001', '001005');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter)
VALUES ('7802-0001-02', TO_DATE('2024-03-21', 'YYYY-MM-DD'), '234-56-7802', 1, 1, 1, 1, 'Pending', 5000, 'PL04', 5, 6.5, 108.33, '001002', '001006');

INSERT INTO Loans (Loan_Number, Application_Date, Cust_SSN, W2_Rcvd, TaxReturn_Rcvd, CreditReport_Rcvd, BankInfo_Rcvd, Application_Status, Loan_Amount, Loan_Type, Loan_Term, Interest_Rate, Monthly_Payment, Loan_Officer, Underwriter)
VALUES ('3467-0001-03', TO_DATE('2024-03-21', 'YYYY-MM-DD'), '890-12-3467', 1, 1, 1, 1, 'Pending', 5000, 'PL03', 5, 7.0, 112.5, '001002', '001007');



-- INSERT DISBURSEMENT DATA --
INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (25000, '0135-0001-01', TO_DATE('2023-05-19', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (25000, '6781-0001-01', TO_DATE('2023-05-25', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (10000, '7801-0001-01', TO_DATE('2023-06-13', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (20000, '9023-0001-01', TO_DATE('2023-07-09', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (10000, '2358-0001-01', TO_DATE('2023-07-11', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (10000, '4579-0001-01', TO_DATE('2023-07-24', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (5000, '1245-0001-01', TO_DATE('2023-08-07', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (5000, '5689-0001-01', TO_DATE('2023-08-07', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (5000, '8014-0001-01', TO_DATE('2023-08-17', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (10000, '1247-0001-01', TO_DATE('2023-08-19', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (7500, '8013-0001-01', TO_DATE('2023-08-21', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (10000, '0134-0001-01', TO_DATE('2023-09-03', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (30000, '9024-0001-01', TO_DATE('2023-09-13', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (25000, '6780-0001-01', TO_DATE('2023-09-17', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (2500, '3469-0001-01', TO_DATE('2023-10-15', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (15000, '3468-0001-01', TO_DATE('2023-10-29', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (5000, '0136-0001-01', TO_DATE('2023-11-08', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (10000, '6782-0001-01', TO_DATE('2023-11-20', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (10000, '7802-0001-01', TO_DATE('2023-11-27', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (12000, '3467-0001-02', TO_DATE('2023-12-06', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (28000, '2357-0001-01', TO_DATE('2023-12-12', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (5000, '8012-0001-01', TO_DATE('2023-12-28', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (10000, '2358-0001-02', TO_DATE('2023-12-31', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (5000, '7801-0001-02', TO_DATE('2024-01-12', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (5000, '9023-0001-02', TO_DATE('2024-01-16', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (10000, '5690-0001-01', TO_DATE('2024-01-20', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (15000, '3468-0001-02', TO_DATE('2024-02-10', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (25000, '9024-0001-02', TO_DATE('2024-02-13', 'YYYY-MM-DD'));

INSERT INTO Disbursements (Check_Amount, Loan_Number, Disbursement_Date)
VALUES (25000, '4580-0001-01', TO_DATE('2024-02-15', 'YYYY-MM-DD'));



-- INSERT STATEMENT DATA --
INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6781-0001-JUN23', 253.47, TO_DATE('2023-06-01', 'YYYY-MM-DD'), TO_DATE('2023-06-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0135-0001-JUN23', 489.58, TO_DATE('2023-06-01', 'YYYY-MM-DD'), TO_DATE('2023-06-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6781-0001-JUL23', 253.47, TO_DATE('2023-07-01', 'YYYY-MM-DD'), TO_DATE('2023-07-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7801-0001-JUL23', 168.05, TO_DATE('2023-07-01', 'YYYY-MM-DD'), TO_DATE('2023-07-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0135-0001-JUL23', 489.58, TO_DATE('2023-07-01', 'YYYY-MM-DD'), TO_DATE('2023-07-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('4579-0001-AUG23', 195.83, TO_DATE('2023-08-01', 'YYYY-MM-DD'), TO_DATE('2023-08-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0135-0001-AUG23', 489.58, TO_DATE('2023-08-01', 'YYYY-MM-DD'), TO_DATE('2023-08-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6781-0001-AUG23', 253.47, TO_DATE('2023-08-01', 'YYYY-MM-DD'), TO_DATE('2023-08-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7801-0001-AUG23', 168.05, TO_DATE('2023-08-01', 'YYYY-MM-DD'), TO_DATE('2023-08-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9023-0001-AUG23', 352.78, TO_DATE('2023-08-01', 'YYYY-MM-DD'), TO_DATE('2023-08-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('2358-0001-AUG23', 150, TO_DATE('2023-08-01', 'YYYY-MM-DD'), TO_DATE('2023-08-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6781-0001-SEP23', 253.47, TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8014-0001-SEP23', 79.17, TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8013-0001-SEP23', 165.63, TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('4579-0001-SEP23', 195.83, TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0135-0001-SEP23', 489.58, TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('5689-0001-SEP23', 79.17, TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1245-0001-SEP23', 79.17, TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7801-0001-SEP23', 168.05, TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9023-0001-SEP23', 352.78, TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1247-0001-SEP23', 148.21, TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('2358-0001-SEP23', 150, TO_DATE('2023-09-01', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8014-0001-OCT23', 79.17, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('4579-0001-OCT23', 195.83, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0135-0001-OCT23', 489.58, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9024-0001-OCT23', 387.50, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8013-0001-OCT23', 165.63, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6781-0001-OCT23', 253.47, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('5689-0001-OCT23', 79.17, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1245-0001-OCT23', 79.17, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0134-0001-OCT23', 195.83, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7801-0001-OCT23', 168.05, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6780-0001-OCT23', 354.17, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9023-0001-OCT23', 352.78, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1247-0001-OCT23', 148.21, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('2358-0001-OCT23', 150, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3469-0001-NOV23', 65.63, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('2358-0001-NOV23', 150, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1247-0001-NOV23', 148.21, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9023-0001-NOV23', 352.78, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6780-0001-NOV23', 354.17, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7801-0001-NOV23', 168.05, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0134-0001-NOV23', 195.83, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1245-0001-NOV23', 79.17, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('5689-0001-NOV23', 79.17, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6781-0001-NOV23', 253.47, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8013-0001-NOV23', 165.63, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9024-0001-NOV23', 387.50, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0135-0001-NOV23', 489.58, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3468-0001-NOV23', 193.75, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('4579-0001-NOV23', 195.83, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8014-0001-NOV23', 79.17, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3469-0001-DEC23', 65.63, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0136-0001-DEC23', 79.17, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('2358-0001-DEC23', 150, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1247-0001-DEC23', 148.21, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9023-0001-DEC23', 352.78, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6780-0001-DEC23', 354.17, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7801-0001-DEC23', 168.05, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0134-0001-DEC23', 195.83, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1245-0001-DEC23', 79.17, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('5689-0001-DEC23', 79.17, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6781-0001-DEC23', 253.47, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7802-0001-DEC23', 195.83, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8013-0001-DEC23', 165.63, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9024-0001-DEC23', 387.50, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0135-0001-DEC23', 489.58, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3468-0001-DEC23', 193.75, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('4579-0001-DEC23', 195.83, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6782-0001-DEC23', 204.17, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8014-0001-DEC23', 79.17, TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3469-0001-JAN24', 65.63, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('2358-0001-JAN24', 345.83, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1247-0001-JAN24', 148.21, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0136-0001-JAN24', 79.17, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9023-0001-JAN24', 352.78, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6780-0001-JAN24', 354.17, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7801-0001-JAN24', 168.05, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8012-0001-JAN24', 114.58, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0134-0001-JAN24', 195.83, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1245-0001-JAN24', 158.34, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3467-0001-JAN24', 165.00, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('5689-0001-JAN24', 79.17, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6781-0001-JAN24', 253.47, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7802-0001-JAN24', 195.83, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8013-0001-JAN24', 165.63, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9024-0001-JAN24', 387.50, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0135-0001-JAN24', 979.16, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('2357-0001-JAN24', 438.33, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3468-0001-JAN24', 193.75, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('4579-0001-JAN24', 195.83, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6782-0001-JAN24', 204.17, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8014-0001-JAN24', 79.17, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3469-0001-FEB24', 65.63, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('2358-0001-FEB24', 345.83, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1247-0001-FEB24', 148.21, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0136-0001-FEB24', 79.17, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9023-0001-FEB24', 421.53, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6780-0001-FEB24', 354.17, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7801-0002-FEB24', 278.47, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8012-0001-FEB24', 114.58, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0134-0001-FEB24', 195.83, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1245-0001-FEB24', 79.17, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3467-0001-FEB24', 165.00, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('5689-0001-FEB24', 79.17, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6781-0001-FEB24', 253.47, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7802-0001-FEB24', 195.83, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8013-0001-FEB24', 331.26, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9024-0001-FEB24', 387.50, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0135-0001-FEB24', 1468.74, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('2357-0001-FEB24', 438.33, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3468-0001-FEB24', 193.75, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('4579-0001-FEB24', 195.83, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('5690-0001-FEB24', 148.21, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6782-0001-FEB24', 204.17, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8014-0001-FEB24', 79.17, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3467-0001-MAR24', 165.00, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('5689-0001-MAR24', 79.17, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0136-0001-MAR24', 79.17, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7802-0001-MAR24', 195.83, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8013-0001-MAR24', 496.89, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9024-0001-MAR24', 741.67, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0135-0001-MAR24', 1958.32, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('2357-0001-MAR24', 438.33, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3468-0001-MAR24', 418.75, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('4579-0001-MAR24', 195.83, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('5690-0001-MAR24', 148.21, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6782-0001-MAR24', 204.17, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8014-0001-MAR24', 158.34, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('3469-0001-MAR24', 65.63, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('4580-0001-MAR24', 274.31, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('2358-0001-MAR24', 345.83, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('9023-0001-MAR24', 421.53, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1247-0001-MAR24', 148.21, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6780-0001-MAR24', 354.17, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('7801-0002-MAR24', 278.47, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('8012-0001-MAR24', 229.16, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('0134-0001-MAR24', 195.83, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('1245-0001-MAR24', 79.17, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));

INSERT INTO Statements (Statement_Number, Statement_Amount, Statement_Date, Due_Date)
VALUES ('6781-0001-MAR24', 253.47, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-25', 'YYYY-MM-DD'));


-- INSERT BILLING CYCLE DATA --
INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6781-0001-01', '6781-0001-JUN23', 25000, 'Current', 114.58, 138.89);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0135-0001-01', '0135-0001-JUN23', 25000, 'Current', 72.92, 416.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0135-0001-01', '0135-0001-JUL23', 24583.34, 'Current', 72.92, 416.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6781-0001-01', '6781-0001-JUL23', 24861.11, 'Current', 114.58, 138.89);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7801-0001-01', '7801-0001-JUL23', 10000, 'Current', 29.17, 138.88);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7801-0001-01', '7801-0001-AUG23', 9861.12, 'Current', 29.17, 138.88);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6781-0001-01', '6781-0001-AUG23', 24722.22, 'Current', 114.58, 138.89);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0135-0001-01', '0135-0001-AUG23', 24166.68, 'Current', 72.92, 416.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('4579-0001-01', '4579-0001-AUG23', 10000, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9023-0001-01', '9023-0001-AUG23', 20000, 'Current', 75.00, 277.78);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2358-0001-01', '2358-0001-AUG23', 10000, 'Current', 45.83, 104.17);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7801-0001-01', '7801-0001-SEP23', 9722.24, 'Current', 29.17, 138.88);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1245-0001-01', '1245-0001-SEP23', 5000, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('5689-0001-01', '5689-0001-SEP23', 5000, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6781-0001-01', '6781-0001-SEP23', 24583.33, 'Current', 114.58, 138.89);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8013-0001-01', '8013-0001-SEP23', 7500, 'Current', 40.63, 125.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0135-0001-01', '0135-0001-SEP23', 23750.02, 'Current', 72.92, 416.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('4579-0001-01', '4579-0001-SEP23', 9833.34, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8014-0001-01', '8014-0001-SEP23', 5000, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9023-0001-01', '9023-0001-SEP23', 19722.22, 'Current', 75.00, 277.78);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1247-0001-01', '1247-0001-SEP23', 10000, 'Current', 29.17, 119.04);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2358-0001-01', '2358-0001-SEP23', 9895.83, 'Current', 45.83, 104.17);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2358-0001-01', '2358-0001-OCT23', 9791.66, 'Current', 45.83, 104.17);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0135-0001-01', '0135-0001-OCT23', 23333.36, 'Current', 72.92, 416.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('4579-0001-01', '4579-0001-OCT23', 9666.68, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8014-0001-01', '8014-0001-OCT23', 4947.91, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9023-0001-01', '9023-0001-OCT23', 19444.44, 'Current', 75.00, 277.78);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1247-0001-01', '1247-0001-OCT23', 9880.96, 'Current', 29.17, 119.04);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9024-0001-01', '9024-0001-OCT23', 30000, 'Current', 137.50, 250.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8013-0001-01', '8013-0001-OCT23', 7375.00, 'Current', 40.63, 125.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6781-0001-01', '6781-0001-OCT23', 24444.44, 'Current', 114.58, 138.89);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('5689-0001-01', '5689-0001-OCT23', 4947.91, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1245-0001-01', '1245-0001-OCT23', 4947.91, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7801-0001-01', '7801-0001-OCT23', 9583.36, 'Current', 29.17, 138.88);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0134-0001-01', '0134-0001-OCT23', 10000, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6780-0001-01', '6780-0001-OCT23', 25000.00, 'Current', 93.75, 260.42);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3469-0001-01', '3469-0001-NOV23', 2500, 'Current', 13.54, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2358-0001-01', '2358-0001-NOV23', 9687.49, 'Current', 45.83, 104.17);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1247-0001-01', '1247-0001-NOV23', 9761.92, 'Current', 29.17, 119.04);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9023-0001-01', '9023-0001-NOV23', 19166.66, 'Current', 75.00, 277.78);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8014-0001-01', '8014-0001-NOV23', 4895.82, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('4579-0001-01', '4579-0001-NOV23', 9500.02, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3468-0001-01', '3468-0001-NOV23', 15000, 'Current', 68.75, 125.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0135-0001-01', '0135-0001-NOV23', 22916.70, 'Current', 72.92, 416.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9024-0001-01', '9024-0001-NOV23', 29750.00, 'Current', 137.50, 250.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8013-0001-01', '8013-0001-NOV23', 7250.00, 'Current', 40.63, 125.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6781-0001-01', '6781-0001-NOV23', 24305.55, 'Current', 114.58, 138.89);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('5689-0001-01', '5689-0001-NOV23', 4895.82, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1245-0001-01', '1245-0001-NOV23', 4895.82, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0134-0001-01', '0134-0001-NOV23', 9833.34, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7801-0001-01', '7801-0001-NOV23', 9444.48, 'Current', 29.17, 138.88);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6780-0001-01', '6780-0001-NOV23', 24739.58, 'Current', 93.75, 260.42);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3469-0001-01', '3469-0001-DEC23', 2447.91, 'Current', 13.54, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2358-0001-01', '2358-0001-DEC23', 9583.32, 'Current', 45.83, 104.17);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1247-0001-01', '1247-0001-DEC23', 9642.88, 'Current', 29.17, 119.04);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0136-0001-01', '0136-0001-DEC23', 5000, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9023-0001-01', '9023-0001-DEC23', 18888.88, 'Current', 75.00, 277.78);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8014-0001-01', '8014-0001-DEC23', 4843.73, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6782-0001-01', '6782-0001-DEC23', 10000, 'Current', 37.50, 166.67);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('4579-0001-01', '4579-0001-DEC23', 9333.36, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3468-0001-01', '3468-0001-DEC23', 14875.00, 'Current', 68.75, 125.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0135-0001-01', '0135-0001-DEC23', 22500.04, 'Delinquent', 72.92, 416.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9024-0001-01', '9024-0001-DEC23', 29500.00, 'Current', 137.50, 250.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8013-0001-01', '8013-0001-DEC23', 7125.00, 'Current', 40.63, 125.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7802-0001-01', '7802-0001-DEC23', 10000, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6781-0001-01', '6781-0001-DEC23', 24166.66, 'Current', 114.58, 138.89);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('5689-0001-01', '5689-0001-DEC23', 4843.73, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1245-0001-01', '1245-0001-DEC23', 4843.73, 'Delinquent', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0134-0001-01', '0134-0001-DEC23', 9666.68, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7801-0001-01', '7801-0001-DEC23', 9305.60, 'Current', 29.17, 138.88);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6780-0001-01', '6780-0001-DEC23', 24479.16, 'Current', 93.75, 260.42);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3469-0001-01', '3469-0001-JAN24', 2395.82, 'Current', 13.54, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2358-0001-02', '2358-0001-JAN24', 10000, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9024-0001-01', '9024-0001-JAN24', 29250.00, 'Current', 137.50, 250.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2358-0001-01', '2358-0001-JAN24', 9479.15, 'Current', 45.83, 104.17);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1247-0001-01', '1247-0001-JAN24', 9523.84, 'Current', 29.17, 119.04);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0136-0001-01', '0136-0001-JAN24', 4947.91, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9023-0001-01', '9023-0001-JAN24', 18611.10, 'Current', 75.00, 277.78);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8014-0001-01', '8014-0001-JAN24', 4791.64, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6782-0001-01', '6782-0001-JAN24', 9833.33, 'Current', 37.50, 166.67);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('4579-0001-01', '4579-0001-JAN24', 9166.70, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3468-0001-01', '3468-0001-JAN24', 14750.00, 'Current', 68.75, 125.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2357-0001-01', '2357-0001-JAN24', 28000, 'Current', 105.00, 333.33);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0135-0001-01', '0135-0001-JAN24', 22500.04, 'Delinquent', 145.84, 833.32);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8013-0001-01', '8013-0001-JAN24', 7000.00, 'Delinquent', 40.63, 125.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7802-0001-01', '7802-0001-JAN24', 9833.34, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6781-0001-01', '6781-0001-JAN24', 24027.77, 'Current', 114.58, 138.89);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('5689-0001-01', '5689-0001-JAN24', 4791.64, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3467-0001-02', '3467-0001-JAN24', 12000, 'Current', 65.00, 100.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1245-0001-01', '1245-0001-JAN24', 4843.73, 'Current', 54.16, 104.18);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0134-0001-01', '0134-0001-JAN24', 9500.02, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8012-0001-01', '8012-0001-JAN24', 5000, 'Current', 31.25, 83.33);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7801-0001-01', '7801-0001-JAN24', 9166.72, 'Current', 29.17, 138.88);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6780-0001-01', '6780-0001-JAN24', 24218.74, 'Current', 93.75, 260.42);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3469-0001-01', '3469-0001-FEB24', 2343.73, 'Current', 13.54, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2358-0001-02', '2358-0001-FEB24', 9833.34, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2358-0001-01', '2358-0001-FEB24', 9374.98, 'Current', 45.83, 104.17);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1247-0001-01', '1247-0001-FEB24', 9404.80, 'Current', 29.17, 119.04);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0136-0001-01', '0136-0001-FEB24', 4895.82, 'Delinquent', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9023-0001-02', '9023-0001-FEB24', 5000, 'Current', 27.08, 41.67);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9023-0001-01', '9023-0001-FEB24', 18333.32, 'Current', 75.00, 277.78);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8014-0001-01', '8014-0001-FEB24', 4740.55, 'Delinquent', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6782-0001-01', '6782-0001-FEB24', 9666.66, 'Current', 37.50, 166.67);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('5690-0001-01', '5690-0001-FEB24', 10000, 'Current', 29.17, 119.04);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('4579-0001-01', '4579-0001-FEB24', 9000.04, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3468-0001-01', '3468-0001-FEB24', 14625.00, 'Current', 68.75, 125.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2357-0001-01', '2357-0001-FEB24', 27666.67, 'Current', 103.33, 333.33);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0135-0001-01', '0135-0001-FEB24', 22500.04, 'Delinquent', 218.76, 1249.98);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9024-0001-01', '9024-0001-FEB24', 29000.00, 'Current', 137.50, 250.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8013-0001-01', '8013-0001-FEB24', 7000.00, 'Delinquent', 81.26, 250.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7802-0001-01', '7802-0001-FEB24', 9666.68, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6781-0001-01', '6781-0001-FEB24', 23888.88, 'Current', 114.58, 138.89);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('5689-0001-01', '5689-0001-FEB24', 4739.55, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3467-0001-02', '3467-0001-FEB24', 11900, 'Current', 64.17, 100.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1245-0001-01', '1245-0001-FEB24', 4739.55, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0134-0001-01', '0134-0001-FEB24', 9333.36, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8012-0001-01', '8012-0001-FEB24', 4916.66, 'Delinquent', 31.25, 83.33);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7801-0001-02', '7801-0002-FEB24', 5000, 'Current', 27.08, 83.34);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7801-0001-01', '7801-0002-FEB24', 9027.84, 'Current', 29.17, 138.88);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6780-0001-01', '6780-0001-FEB24', 23958.32, 'Current', 93.75, 260.42);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('4580-0001-01', '4580-0001-MAR24', 25000, 'Current', 113.54, 160.77);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3469-0001-01', '3469-0001-MAR24', 2291.64, 'Current', 13.54, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2358-0001-02', '2358-0001-MAR24', 9666.68, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2358-0001-01', '2358-0001-MAR24', 9270.81, 'Current', 45.83, 104.17);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1247-0001-01', '1247-0001-MAR24', 9285.76, 'Current', 29.17, 119.04);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0136-0001-01', '0136-0001-MAR24', 4895.82, 'Delinquent', 54.16, 104.18);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9023-0001-02', '9023-0001-MAR24', 4958.33, 'Current', 27.08, 41.67);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9023-0001-01', '9023-0001-MAR24', 18055.54, 'Current', 75.00, 277.78);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8014-0001-01', '8014-0001-MAR24', 4740.55, 'Delinquent', 54.16, 104.18);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6782-0001-01', '6782-0001-MAR24', 9499.99, 'Current', 37.50, 166.67);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('5690-0001-01', '5690-0001-MAR24', 9880.96, 'Current', 28.77, 119.44);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('4579-0001-01', '4579-0001-MAR24', 8833.38, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3468-0001-02', '3468-0001-MAR24', 15000.00, 'Current', 68.75, 156.25);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3468-0001-01', '3468-0001-MAR24', 14500.00, 'Current', 68.75, 125.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('2357-0001-01', '2357-0001-MAR24', 27333.34, 'Current', 101.67, 333.33);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0135-0001-01', '0135-0001-MAR24', 22500.04, 'Delinquent', 291.68, 1666.64);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9024-0001-02', '9024-0001-MAR24', 25000.00, 'Current', 93.75, 260.42);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('9024-0001-01', '9024-0001-MAR24', 28750.00, 'Current', 131.25, 250.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8013-0001-01', '8013-0001-MAR24', 7000.00, 'Delinquent', 121.89, 375.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7802-0001-01', '7802-0001-MAR24', 9500.02, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6781-0001-01', '6781-0001-MAR24', 23749.99, 'Current', 114.58, 138.89);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('5689-0001-01', '5689-0001-MAR24', 4687.46, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('3467-0001-02', '3467-0001-MAR24', 11800, 'Current', 65.00, 100.00);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('1245-0001-01', '1245-0001-MAR24', 4687.46, 'Current', 27.08, 52.09);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('0134-0001-01', '0134-0001-MAR24', 9166.70, 'Current', 29.17, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('8012-0001-01', '8012-0001-MAR24', 4916.66, 'Delinquent', 62.5, 166.66);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7801-0001-02', '7801-0002-MAR24', 4916.66, 'Current', 26.74, 83.34);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('7801-0001-01', '7801-0002-MAR24', 8888.96, 'Current', 29.17, 138.88);

INSERT INTO Billing_Cycle (Loan_Number, Statement_Number, Loan_Balance, Account_Status, Interest_Due, Principal_Due)
VALUES ('6780-0001-01', '6780-0001-MAR24', 23697.90, 'Current', 93.75, 260.42);


-- INSERT PAYMENT DATE --
INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6781-0001-JUN23', 253.47, TO_DATE('2023-06-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0135-0001-JUN23', 489.58, TO_DATE('2023-06-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7801-0001-JUL23', 168.05, TO_DATE('2023-07-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6781-0001-JUL23', 253.47, TO_DATE('2023-07-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0135-0001-JUL23', 489.58, TO_DATE('2023-07-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7801-0001-AUG23', 168.05, TO_DATE('2023-08-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('4579-0001-AUG23', 195.83, TO_DATE('2023-08-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6781-0001-AUG23', 253.47, TO_DATE('2023-08-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0135-0001-AUG23', 489.58, TO_DATE('2023-08-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9023-0001-AUG23', 352.78, TO_DATE('2023-08-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('2358-0001-AUG23', 150, TO_DATE('2023-08-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7801-0001-SEP23', 168.05, TO_DATE('2023-09-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8013-0001-SEP23', 165.63, TO_DATE('2023-09-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('5689-0001-SEP23', 79.17, TO_DATE('2023-09-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('1245-0001-SEP23', 79.17, TO_DATE('2023-09-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('4579-0001-SEP23', 195.83, TO_DATE('2023-09-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8014-0001-SEP23', 79.17, TO_DATE('2023-09-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6781-0001-SEP23', 253.47, TO_DATE('2023-09-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0135-0001-SEP23', 489.58, TO_DATE('2023-09-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9023-0001-SEP23', 352.78, TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('1247-0001-SEP23', 148.21, TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('2358-0001-SEP23', 150, TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0134-0001-OCT23', 195.83, TO_DATE('2023-10-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7801-0001-OCT23', 168.05, TO_DATE('2023-10-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6780-0001-OCT23', 354.17, TO_DATE('2023-10-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('5689-0001-OCT23', 79.17, TO_DATE('2023-10-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('1245-0001-OCT23', 79.17, TO_DATE('2023-10-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6781-0001-OCT23', 253.47, TO_DATE('2023-10-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8014-0001-OCT23', 79.17, TO_DATE('2023-10-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('4579-0001-OCT23', 195.83, TO_DATE('2023-10-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0135-0001-OCT23', 489.58, TO_DATE('2023-10-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9024-0001-OCT23', 387.50, TO_DATE('2023-10-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8013-0001-OCT23', 165.63, TO_DATE('2023-10-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('1247-0001-OCT23', 148.21, TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9023-0001-OCT23', 352.78, TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('2358-0001-OCT23', 150, TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0134-0001-NOV23', 195.83, TO_DATE('2023-11-13', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7801-0001-NOV23', 168.05, TO_DATE('2023-11-13', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('5689-0001-NOV23', 79.17, TO_DATE('2023-11-13', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('1245-0001-NOV23', 79.17, TO_DATE('2023-11-13', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6780-0001-NOV23', 354.17, TO_DATE('2023-11-13', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6781-0001-NOV23', 253.47, TO_DATE('2023-11-21', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9024-0001-NOV23', 387.50, TO_DATE('2023-11-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8013-0001-NOV23', 165.63, TO_DATE('2023-11-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('4579-0001-NOV23', 195.83, TO_DATE('2023-11-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8014-0001-NOV23', 79.17, TO_DATE('2023-11-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3468-0001-NOV23', 193.75, TO_DATE('2023-11-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0135-0001-NOV23', 489.58, TO_DATE('2023-11-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9023-0001-NOV23', 352.78, TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('2358-0001-NOV23', 150, TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3469-0001-NOV23', 65.63, TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('1247-0001-NOV23', 148.21, TO_DATE('2023-11-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7801-0001-DEC23', 168.05, TO_DATE('2023-12-15', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6780-0001-DEC23', 354.17, TO_DATE('2023-12-15', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0134-0001-DEC23', 195.83, TO_DATE('2023-12-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9024-0001-DEC23', 387.50, TO_DATE('2023-12-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8013-0001-DEC23', 165.63, TO_DATE('2023-12-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7802-0001-DEC23', 195.83, TO_DATE('2023-12-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6781-0001-DEC23', 253.47, TO_DATE('2023-12-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6782-0001-DEC23', 204.17, TO_DATE('2023-12-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('5689-0001-DEC23', 79.17, TO_DATE('2023-12-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('4579-0001-DEC23', 195.83, TO_DATE('2023-12-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0136-0001-DEC23', 79.17, TO_DATE('2023-12-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8014-0001-DEC23', 79.17, TO_DATE('2023-12-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3468-0001-DEC23', 193.75, TO_DATE('2023-12-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9023-0001-DEC23', 352.78, TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3469-0001-DEC23', 65.63, TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('2358-0001-DEC23', 150, TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('1247-0001-DEC23', 148.21, TO_DATE('2023-12-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0134-0001-JAN24', 195.83, TO_DATE('2024-01-13', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8012-0001-JAN24', 114.58, TO_DATE('2024-01-13', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7801-0001-JAN24', 168.05, TO_DATE('2024-01-13', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6780-0001-JAN24', 354.17, TO_DATE('2024-01-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7802-0001-JAN24', 195.83, TO_DATE('2024-01-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('5689-0001-JAN24', 79.17, TO_DATE('2024-01-15', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('1245-0001-JAN24', 158.34, TO_DATE('2024-01-15', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6781-0001-JAN24', 253.47, TO_DATE('2024-01-19', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9024-0001-JAN24', 387.50, TO_DATE('2024-01-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3467-0001-JAN24', 165.00, TO_DATE('2024-01-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0136-0001-JAN24', 79.17, TO_DATE('2024-01-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8014-0001-JAN24', 79.17, TO_DATE('2024-01-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6782-0001-JAN24', 204.17, TO_DATE('2024-01-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('4579-0001-JAN24', 195.83, TO_DATE('2024-01-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3468-0001-JAN24', 193.75, TO_DATE('2024-01-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('2357-0001-JAN24', 438.33, TO_DATE('2024-01-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9023-0001-JAN24', 352.78, TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('2358-0001-JAN24', 345.83, TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3469-0001-JAN24', 65.63, TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('1247-0001-JAN24', 148.21, TO_DATE('2024-01-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7801-0002-FEB24', 278.47, TO_DATE('2024-02-15', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6780-0001-FEB24', 354.17, TO_DATE('2024-02-15', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6781-0001-FEB24', 253.47, TO_DATE('2024-02-15', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('0134-0001-FEB24', 195.83, TO_DATE('2024-02-18', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7802-0001-FEB24', 195.83, TO_DATE('2024-02-18', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3467-0001-FEB24', 165.00, TO_DATE('2024-02-18', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('1245-0001-FEB24', 79.17, TO_DATE('2024-02-18', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('5689-0001-FEB24', 79.17, TO_DATE('2024-02-23', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9024-0001-FEB24', 387.50, TO_DATE('2024-02-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6782-0001-FEB24', 204.17, TO_DATE('2024-02-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('4579-0001-FEB24', 195.83, TO_DATE('2024-02-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('5690-0001-FEB24', 148.21, TO_DATE('2024-02-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3468-0001-FEB24', 193.75, TO_DATE('2024-02-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('2357-0001-FEB24', 438.33, TO_DATE('2024-02-24', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9023-0001-FEB24', 421.53, TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('2358-0001-FEB24', 345.83, TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('1247-0001-FEB24', 148.21, TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3469-0001-FEB24', 65.63, TO_DATE('2024-02-25', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8012-0001-MAR24', 100.00, TO_DATE('2024-03-08', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6782-0001-MAR24', 204.17, TO_DATE('2024-03-10', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6780-0001-MAR24', 354.17, TO_DATE('2024-03-12', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('4579-0001-MAR24', 195.83, TO_DATE('2024-03-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('7802-0001-MAR24', 195.83, TO_DATE('2024-03-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3467-0001-MAR24', 165.00, TO_DATE('2024-03-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('2357-0001-MAR24', 438.33, TO_DATE('2024-03-14', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('2358-0001-MAR24', 345.83, TO_DATE('2024-03-15', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('9023-0001-MAR24', 421.53, TO_DATE('2024-03-15', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('8012-0001-MAR24', 75.00, TO_DATE('2024-03-15', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3469-0001-MAR24', 65.63, TO_DATE('2024-03-17', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('6781-0001-MAR24', 253.47, TO_DATE('2024-03-18', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('5689-0001-MAR24', 79.17, TO_DATE('2024-03-18', 'YYYY-MM-DD'));

INSERT INTO Payments (Statement_Number, Payment_Amount, Payment_Date)
VALUES ('3468-0001-MAR24', 418.75, TO_DATE('2024-03-20', 'YYYY-MM-DD'));