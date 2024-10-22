-- Data Validation Procedure
CREATE PROCEDURE ValidateCustomerData
AS
BEGIN
    -- Required fields validation
    INSERT INTO error_log (error_type, error_message, record_id)
    SELECT 
        'Missing Required Field',
        'Missing ' + 
        CASE 
            WHEN Customer_Name IS NULL THEN 'Customer Name'
            WHEN Customer_ID IS NULL THEN 'Customer ID'
            WHEN Open_Date IS NULL THEN 'Open Date'
        END,
        Customer_ID
    FROM staging_customers
    WHERE Customer_Name IS NULL 
       OR Customer_ID IS NULL 
       OR Open_Date IS NULL;

    -- Date validation
    INSERT INTO error_log (error_type, error_message, record_id)
    SELECT 
        'Invalid Date',
        'Invalid date format for ' + 
        CASE 
            WHEN ISDATE(Open_Date) = 0 THEN 'Open Date'
            WHEN ISDATE(Last_Consulted_Date) = 0 THEN 'Last Consulted Date'
            WHEN ISDATE(Date_of_Birth) = 0 THEN 'Date of Birth'
        END,
        Customer_ID
    FROM staging_customers
    WHERE ISDATE(Open_Date) = 0 
       OR (Last_Consulted_Date IS NOT NULL AND ISDATE(Last_Consulted_Date) = 0)
       OR (Date_of_Birth IS NOT NULL AND ISDATE(Date_of_Birth) = 0);
END;

-- Data Distribution Procedure
CREATE PROCEDURE DistributeCustomerData
AS
BEGIN
    -- Distribution to India table
    MERGE INTO Table_India AS target
    USING (
        SELECT *
        FROM staging_customers
        WHERE Country = 'IND'
        AND Customer_ID IN (
            SELECT Customer_ID
            FROM staging_customers
            WHERE Country = 'IND'
            GROUP BY Customer_ID
            HAVING Last_Consulted_Date = MAX(Last_Consulted_Date)
        )
    ) AS source
    ON target.Customer_ID = source.Customer_ID
    WHEN MATCHED AND source.Last_Consulted_Date > target.Last_Consulted_Date THEN
        UPDATE SET
            Customer_Name = source.Customer_Name,
            Open_Date = source.Open_Date,
            Last_Consulted_Date = source.Last_Consulted_Date,
            Vaccination_Type = source.Vaccination_Type,
            Doctor_Consulted = source.Doctor_Consulted,
            State = source.State,
            Post_Code = source.Post_Code,
            Date_of_Birth = source.Date_of_Birth,
            Is_Active = source.Is_Active,
            Age = source.Age,
            Days_Since_Last_Consulted = source.Days_Since_Last_Consulted,
            Needs_Followup = source.Needs_Followup,
            Last_Updated = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT VALUES (
            source.Customer_Name,
            source.Customer_ID,
            source.Open_Date,
            source.Last_Consulted_Date,
            source.Vaccination_Type,
            source.Doctor_Consulted,
            source.State,
            source.Post_Code,
            source.Date_of_Birth,
            source.Is_Active,
            source.Age,
            source.Days_Since_Last_Consulted,
            source.Needs_Followup,
            GETDATE()
        );
END;
