````markdown name=README.md
# Incident Automation Report Backend

A comprehensive C# backend service for generating incident automation reports with SQL Server database integration to `ustcas74.kcc.com/snowmirror`.

## Features

✅ **Monthly Incident Count by Assignment Group** - Track incident volume by team/department  
✅ **Year-over-Year (YoY) Comparison** - Monitor trends with percentage change analysis  
✅ **Repetitive Incidents Tracking** - Identify recurring issues for root cause analysis  
✅ **Daily Non-Compliance Checks** - Validate close_code and closure_template compliance  
✅ **Comprehensive Monthly Reports** - All-in-one aggregated reporting  

## Prerequisites

- .NET 5.0 SDK or higher
- SQL Server (connected to `ustcas74.kcc.com`)
- Database: `snowmirror`
- NuGet Packages (auto-restored)

## Installation

### 1. Clone Repository
```bash
git clone https://github.com/ramtechie08/ReportAutomation.git
cd ReportAutomation
```

### 2. Configure Database Connection
Update `appsettings.json` with your SQL Server credentials:

```json
"ConnectionStrings": {
  "SnowmirrorDB": "Server=ustcas74.kcc.com;Database=snowmirror;User Id=sa;Password=YOUR_PASSWORD;Connection Timeout=30;Encrypt=true;TrustServerCertificate=true;"
}
```

### 3. Create Database Schema
Execute the SQL script to create tables and stored procedures:

```bash
# Using SQL Server Management Studio or sqlcmd
sqlcmd -S ustcas74.kcc.com -d snowmirror -i SQL/CreateIncidentSchema.sql
```

### 4. Build & Run
```bash
dotnet restore
dotnet build
dotnet run
```

The application starts at `https://localhost:5001`

## API Endpoints

### 1. Monthly Incident Count by Assignment Group

```
GET /api/report/monthly-incidents/{year}/{month}
```

**Example:**
```
GET /api/report/monthly-incidents/2026/05
```

**Response:**
```json
{
  "success": true,
  "message": "Monthly incident count retrieved successfully",
  "data": [
    {
      "assignmentGroup": "IT Operations",
      "incidentCount": 145,
      "reportMonth": "2026-05-01T00:00:00Z"
    },
    {
      "assignmentGroup": "Network Support",
      "incidentCount": 98,
      "reportMonth": "2026-05-01T00:00:00Z"
    }
  ],
  "timestamp": "2026-05-15T10:30:00Z"
}
```

### 2. Year-over-Year (YoY) Comparison

```
GET /api/report/yoy-comparison/{year}/{month}
```

**Example:**
```
GET /api/report/yoy-comparison/2026/05
```

**Response:**
```json
{
  "success": true,
  "message": "Year-over-year comparison retrieved successfully",
  "data": [
    {
      "assignmentGroup": "IT Operations",
      "currentYearCount": 145,
      "previousYearCount": 120,
      "percentageChange": 20.83,
      "yearMonth": 202605
    }
  ],
  "timestamp": "2026-05-15T10:30:00Z"
}
```

### 3. Repetitive Incidents

```
GET /api/report/repetitive-incidents/{year}/{month}
```

**Example:**
```
GET /api/report/repetitive-incidents/2026/05
```

**Response:**
```json
{
  "success": true,
  "message": "Repetitive incidents retrieved successfully",
  "data": [
    {
      "incidentShortDescription": "Network connectivity issue",
      "assignmentGroup": "Network Support",
      "occurrenceCount": 12,
      "firstOccurrence": "2026-05-01T09:15:00Z",
      "lastOccurrence": "2026-05-15T14:30:00Z",
      "impactPercentage": 8.5
    }
  ],
  "timestamp": "2026-05-15T10:30:00Z"
}
```

### 4. Daily Non-Compliance Report

```
GET /api/report/non-compliance/{reportDate}
```

**Example:**
```
GET /api/report/non-compliance/2026-05-15
```

**Response:**
```json
{
  "success": true,
  "message": "Daily non-compliance report retrieved successfully",
  "data": [
    {
      "incidentId": 1001,
      "number": "INC0001234",
      "closeCode": "RESOLVED",
      "closureTemplate": "standard_resolution",
      "isCompliant": true,
      "complianceIssue": "None",
      "closedDate": "2026-05-15T10:00:00Z",
      "assignmentGroup": "IT Operations"
    },
    {
      "incidentId": 1002,
      "number": "INC0001235",
      "closeCode": null,
      "closureTemplate": "standard_resolution",
      "isCompliant": false,
      "complianceIssue": "Missing close_code",
      "closedDate": "2026-05-15T11:30:00Z",
      "assignmentGroup": "Network Support"
    }
  ],
  "timestamp": "2026-05-15T10:30:00Z"
}
```

### 5. Daily Non-Compliance Summary

```
GET /api/report/daily-non-compliance-summary/{reportDate}
```

**Example:**
```
GET /api/report/daily-non-compliance-summary/2026-05-15
```

**Response:**
```json
{
  "success": true,
  "message": "Non-compliance summary retrieved successfully",
  "data": [
    {
      "assignmentGroup": "IT Operations",
      "nonCompliantByCloseCode": {
        "null": 5,
        "UNRESOLVED": 2
      },
      "totalNonCompliant": 7,
      "totalClosed": 145,
      "complianceRate": 95.17,
      "reportDate": "2026-05-15"
    }
  ],
  "timestamp": "2026-05-15T10:30:00Z"
}
```

### 6. Comprehensive Monthly Report

```
GET /api/report/monthly-report/{year}/{month}
```

**Example:**
```
GET /api/report/monthly-report/2026/05
```

**Response:**
```json
{
  "success": true,
  "message": "Comprehensive monthly report retrieved successfully",
  "data": {
    "year": 2026,
    "month": 5,
    "monthlyCounts": [...],
    "yoYComparison": [...],
    "repetitiveIncidents": [...],
    "nonComplianceSummaries": [...],
    "generatedAt": "2026-05-15T10:30:00Z"
  },
  "timestamp": "2026-05-15T10:30:00Z"
}
```

### 7. Health Check

```
GET /api/report/health
```

**Response:**
```json
{
  "success": true,
  "message": "Service is healthy",
  "data": "OK",
  "timestamp": "2026-05-15T10:30:00Z"
}
```

## Database Schema

### Tables

#### `incident`
Main incident table with all incident details:
- `incident_id` - Primary key
- `number` - Incident ticket number
- `short_description` - Brief description
- `assignment_group` - Assigned group/team
- `state` - Current state (Open, Closed, etc.)
- `close_code` - Closure code (RESOLVED, CLOSED, etc.)
- `closure_template` - Template used for closure
- `closed_date` - Closure date/time
- And additional tracking fields

**Indexes:**
- `idx_created_date`
- `idx_closed_date`
- `idx_assignment_group`
- `idx_state`
- `idx_close_code`

#### `incident_monthly_summary`
Caching table for monthly summaries

#### `non_compliance_log`
Tracks non-compliance violations

#### `repetitive_incidents_log`
Logs repetitive incident occurrences

## Stored Procedures

1. **sp_GetMonthlyIncidentCount** - Returns monthly counts by group
2. **sp_GetYoYComparison** - Returns YoY analysis
3. **sp_GetRepetitiveIncidents** - Returns repetitive incidents
4. **sp_GetDailyNonCompliance** - Returns daily compliance violations

## Project Structure

```
ReportAutomation/
├── Controllers/
│   └── ReportController.cs          # API endpoints
├── Models/
│   └── IncidentReport.cs            # Data models
├── Services/
│   ├── DatabaseConnection.cs        # DB connection manager
│   └── IncidentReportService.cs     # Business logic
├── SQL/
│   └── CreateIncidentSchema.sql     # Database schema
├── Program.cs                        # Entry point
├── Startup.cs                        # Configuration
├── appsettings.json                 # Configuration
├── ReportAutomation.csproj          # Project file
└── README.md                        # Documentation
```

## Configuration

### appsettings.json

```json
{
  "ConnectionStrings": {
    "SnowmirrorDB": "Server=ustcas74.kcc.com;Database=snowmirror;User Id=sa;Password=YOUR_PASSWORD;..."
  },
  "ReportSettings": {
    "DefaultPageSize": 100,
    "MaxPageSize": 1000,
    "CacheDurationMinutes": 60
  }
}
```

## Error Handling

All endpoints return a consistent response format:

**Success:**
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {...},
  "timestamp": "2026-05-15T10:30:00Z"
}
```

**Error:**
```json
{
  "success": false,
  "message": "Error description here",
  "timestamp": "2026-05-15T10:30:00Z"
}
```

## Logging

Logs are configured in `appsettings.json`:
- Information level for general operations
- Warning level for Microsoft libraries
- All logs output to console

## Swagger UI

Access interactive API documentation at:
```
https://localhost:5001/swagger/index.html
```

## Troubleshooting

### Connection String Issues
- Verify SQL Server is accessible from your machine
- Check credentials in `appsettings.json`
- Ensure `snowmirror` database exists

### Database Schema Not Found
- Run `CreateIncidentSchema.sql` script
- Verify script executed without errors
- Check user permissions on SQL Server

### Port Already in Use
```bash
# Change port in Startup.cs or use environment variable
set ASPNETCORE_URLS=https://localhost:5002
```

## License

Internal Use Only - ReportAutomation Team

## Support

Contact: ramtechie08@example.com
````
