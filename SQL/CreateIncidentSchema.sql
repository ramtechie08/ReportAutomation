-- Create incident table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'incident')
BEGIN
    CREATE TABLE incident (
        incident_id INT PRIMARY KEY IDENTITY(1,1),
        number NVARCHAR(50) NOT NULL UNIQUE,
        short_description NVARCHAR(500),
        assignment_group NVARCHAR(100),
        state NVARCHAR(50),
        close_code NVARCHAR(100),
        closure_template NVARCHAR(100),
        closed_date DATETIME,
        created_date DATETIME DEFAULT GETUTCDATE(),
        updated_date DATETIME DEFAULT GETUTCDATE()
    );
    
    -- Create indexes for performance
    CREATE INDEX idx_created_date ON incident(created_date);
    CREATE INDEX idx_closed_date ON incident(closed_date);
    CREATE INDEX idx_assignment_group ON incident(assignment_group);
    CREATE INDEX idx_state ON incident(state);
    CREATE INDEX idx_close_code ON incident(close_code);
    
    PRINT 'incident table created successfully';
END
ELSE
BEGIN
    PRINT 'incident table already exists';
END;

-- Create incident_monthly_summary table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'incident_monthly_summary')
BEGIN
    CREATE TABLE incident_monthly_summary (
        summary_id INT PRIMARY KEY IDENTITY(1,1),
        year INT NOT NULL,
        month INT NOT NULL,
        assignment_group NVARCHAR(100),
        incident_count INT,
        created_date DATETIME DEFAULT GETUTCDATE(),
        UNIQUE(year, month, assignment_group)
    );
    
    CREATE INDEX idx_year_month ON incident_monthly_summary(year, month);
    
    PRINT 'incident_monthly_summary table created successfully';
END
ELSE
BEGIN
    PRINT 'incident_monthly_summary table already exists';
END;

-- Create non_compliance_log table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'non_compliance_log')
BEGIN
    CREATE TABLE non_compliance_log (
        compliance_id INT PRIMARY KEY IDENTITY(1,1),
        incident_id INT NOT NULL,
        report_date DATE NOT NULL,
        compliance_issue NVARCHAR(255),
        close_code NVARCHAR(100),
        assignment_group NVARCHAR(100),
        created_date DATETIME DEFAULT GETUTCDATE(),
        FOREIGN KEY (incident_id) REFERENCES incident(incident_id)
    );
    
    CREATE INDEX idx_report_date ON non_compliance_log(report_date);
    CREATE INDEX idx_assignment_group_compliance ON non_compliance_log(assignment_group);
    
    PRINT 'non_compliance_log table created successfully';
END
ELSE
BEGIN
    PRINT 'non_compliance_log table already exists';
END;

-- Create repetitive_incidents_log table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'repetitive_incidents_log')
BEGIN
    CREATE TABLE repetitive_incidents_log (
        repetitive_id INT PRIMARY KEY IDENTITY(1,1),
        short_description NVARCHAR(500),
        assignment_group NVARCHAR(100),
        occurrence_count INT,
        first_occurrence DATETIME,
        last_occurrence DATETIME,
        report_month INT,
        report_year INT,
        created_date DATETIME DEFAULT GETUTCDATE()
    );
    
    CREATE INDEX idx_report_month_year ON repetitive_incidents_log(report_year, report_month);
    
    PRINT 'repetitive_incidents_log table created successfully';
END
ELSE
BEGIN
    PRINT 'repetitive_incidents_log table already exists';
END;

-- Create stored procedure for monthly incident count
IF NOT EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetMonthlyIncidentCount')
BEGIN
    EXEC(N'
    CREATE PROCEDURE sp_GetMonthlyIncidentCount
        @year INT,
        @month INT
    AS
    BEGIN
        SELECT 
            assignment_group AS AssignmentGroup,
            COUNT(*) AS IncidentCount,
            DATEFROMPARTS(@year, @month, 1) AS ReportMonth
        FROM incident
        WHERE YEAR(created_date) = @year 
          AND MONTH(created_date) = @month
        GROUP BY assignment_group
        ORDER BY IncidentCount DESC
    END
    ');
    
    PRINT 'sp_GetMonthlyIncidentCount stored procedure created successfully';
END;

-- Create stored procedure for YoY comparison
IF NOT EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetYoYComparison')
BEGIN
    EXEC(N'
    CREATE PROCEDURE sp_GetYoYComparison
        @year INT,
        @month INT
    AS
    BEGIN
        SELECT 
            assignment_group AS AssignmentGroup,
            SUM(CASE WHEN YEAR(created_date) = @year THEN 1 ELSE 0 END) AS CurrentYearCount,
            SUM(CASE WHEN YEAR(created_date) = @year - 1 THEN 1 ELSE 0 END) AS PreviousYearCount,
            @year * 100 + @month AS YearMonth
        FROM incident
        WHERE (YEAR(created_date) = @year OR YEAR(created_date) = @year - 1)
          AND MONTH(created_date) = @month
        GROUP BY assignment_group
    END
    ');
    
    PRINT 'sp_GetYoYComparison stored procedure created successfully';
END;

-- Create stored procedure for repetitive incidents
IF NOT EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetRepetitiveIncidents')
BEGIN
    EXEC(N'
    CREATE PROCEDURE sp_GetRepetitiveIncidents
        @year INT,
        @month INT
    AS
    BEGIN
        SELECT 
            short_description,
            assignment_group,
            COUNT(*) AS OccurrenceCount,
            MIN(created_date) AS FirstOccurrence,
            MAX(created_date) AS LastOccurrence
        FROM incident
        WHERE YEAR(created_date) = @year 
          AND MONTH(created_date) = @month
        GROUP BY short_description, assignment_group
        HAVING COUNT(*) > 1
        ORDER BY OccurrenceCount DESC
    END
    ');
    
    PRINT 'sp_GetRepetitiveIncidents stored procedure created successfully';
END;

-- Create stored procedure for daily non-compliance
IF NOT EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetDailyNonCompliance')
BEGIN
    EXEC(N'
    CREATE PROCEDURE sp_GetDailyNonCompliance
        @reportDate DATE
    AS
    BEGIN
        SELECT 
            incident_id,
            number,
            close_code,
            closure_template,
            closed_date,
            assignment_group
        FROM incident
        WHERE CAST(closed_date AS DATE) = @reportDate
          AND (close_code IS NULL OR close_code = '''')
        ORDER BY closed_date DESC
    END
    ');
    
    PRINT 'sp_GetDailyNonCompliance stored procedure created successfully';
END;

PRINT '
========================================
Database schema setup completed!
========================================
Tables created:
- incident
- incident_monthly_summary
- non_compliance_log
- repetitive_incidents_log

Stored Procedures created:
- sp_GetMonthlyIncidentCount
- sp_GetYoYComparison
- sp_GetRepetitiveIncidents
- sp_GetDailyNonCompliance

Next steps:
1. Update appsettings.json with your database password
2. Seed sample data into incident table
3. Run the application with: dotnet run
4. Access Swagger at: https://localhost:5001/swagger
========================================
';
