-- Staging table for initial data load
CREATE TABLE staging_customers (
    Customer_Name VARCHAR(255) NOT NULL,
    Customer_ID VARCHAR(18) NOT NULL,
    Open_Date DATE NOT NULL,
    Last_Consulted_Date DATE,
    Vaccination_Type CHAR(5),
    Doctor_Consulted VARCHAR(255),
    State CHAR(5),
    Country CHAR(5),
    Post_Code INT,
    Date_of_Birth DATE,
    Is_Active CHAR(1),
    Age INT GENERATED ALWAYS AS (
        FLOOR(DATEDIFF(DAY, Date_of_Birth, GETDATE()) / 365.25)
    ) STORED,
    Days_Since_Last_Consulted INT GENERATED ALWAYS AS (
        DATEDIFF(DAY, Last_Consulted_Date, GETDATE())
    ) STORED,
    Needs_Followup CHAR(1) GENERATED ALWAYS AS (
        CASE WHEN DATEDIFF(DAY, Last_Consulted_Date, GETDATE()) > 30 THEN 'Y' ELSE 'N' END
    ) STORED,
    Created_At DATETIME DEFAULT GETDATE(),
    CONSTRAINT PK_staging_customers PRIMARY KEY (Customer_ID, Last_Consulted_Date)
);

-- Create country-specific table template
CREATE TABLE Table_India (
    Customer_Name VARCHAR(255) NOT NULL,
    Customer_ID VARCHAR(18) NOT NULL,
    Open_Date DATE NOT NULL,
    Last_Consulted_Date DATE,
    Vaccination_Type CHAR(5),
    Doctor_Consulted VARCHAR(255),
    State CHAR(5),
    Post_Code INT,
    Date_of_Birth DATE,
    Is_Active CHAR(1),
    Age INT,
    Days_Since_Last_Consulted INT,
    Needs_Followup CHAR(1),
    Last_Updated DATETIME DEFAULT GETDATE(),
    CONSTRAINT PK_India_customers PRIMARY KEY (Customer_ID)
);

-- Error logging table
CREATE TABLE error_log (
    error_id INT IDENTITY(1,1) PRIMARY KEY,
    error_type VARCHAR(50),
    error_message VARCHAR(500),
    record_id VARCHAR(18),
    created_at DATETIME DEFAULT GETDATE()
);
