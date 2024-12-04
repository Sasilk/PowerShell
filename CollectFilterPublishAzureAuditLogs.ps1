function Get-UserPrincipalName {
    param (
        [Parameter(Mandatory=$true)]
        [string]$String
    )

    $start_index = $String.IndexOf('"userPrincipalName":"') + ('"userPrincipalName":"').Length
    $end_index = $String.IndexOf('"', $start_index)
    $user_principal_name = $String.Substring($start_index, $end_index - $start_index)

    return $user_principal_name
}

function Get-UserPrincipalNameAndGroupDisplayName {
    param (
        [Parameter(Mandatory=$true)]
        [string]$String
    )
    # Extract userPrincipalName
    $user_principal_name = ($String | ConvertFrom-Json).userPrincipalName

    # Extract Group.DisplayName
    # $group_display_name = ($String | ConvertFrom-Json | Where-Object {$_.type -eq "User"}).modifiedProperties | Where-Object {$_.displayName -eq "Group.DisplayName"} | Select-Object -ExpandProperty newValue
    $group_display_name = ($String | ConvertFrom-Json | Where-Object {$_.type -eq "User"}).modifiedProperties | Where-Object {$_.displayName -eq "Group.DisplayName"} | ForEach-Object {$_.oldValue, $_.newValue -join " "}

    # Return the extracted values
    $result = "User: $user_principal_name  /  Group: $group_display_name"
    return $result
}


$DST = Get-Date -Format "dddd dd/MM/yyyy hh:mm"

$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Audit Logs</title>
    <link rel="icon" href="log-query.png" type="image/x-icon">
    <meta http-equiv="refresh" content="60">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f2f2f2;
        }
        .container {
            max-width: 2000px;
            margin: 0 auto;
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }
        .header {
            font-size: 24px;
            text-align: center;
            margin-bottom: 20px;
        }
        h3 {
            font-size: 20px;
            margin-top: 10px;
            margin-bottom: 20px;
            text-align: center;
        }
        .row-container {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }
        .table-container {
            width: 32%;
            margin-bottom: 20px;
        }
        table {
            border-collapse: collapse;
            width: 100%;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
            font-weight: bold;
        }

    </style>
</head>
<body>
    <div class="container">
        <h3>$DST</h3>
"@
$htmlContent += "<h3>Azure Admins' Audit Logs</h3>"


$logFile = "C:\Scripts\AzureAuditLogs\LogFile.csv"
$htmlFile = "C:\Program Files (x86)\Lansweeper\Website\AuditLogs.html"

# Use the encrypted file for the credential
# $credentials = Import-Clixml -Path C:\Scripts\AzureAuditLogs\creds.xml

# Install the necessary Az PS modules
# Install-Module -Name Az -AllowClobber -Scope AllUsers
# Import-Module Az.OperationalInsights

# Connect to Azure Cloud
# Connect-AzAccount -Credential $credentials
Connect-AzAccount #-Credential sevcan.asilkan@mydomain.co.uk

# Connect to Azure Cloud via certificate authentication to an Azure app
# The PowerShell_audit app has been registered to Azure for this and created self-signed certificate for the app. And installed that certificate to this machine
Connect-AzAccount -ApplicationId 456f61be-3ca0-4ad5-a1ad-638e0d5d41a0 -TenantId 55687bf5-4348-4b9e-aac5-560b8ebadbb5 -CertificateThumbprint 1D12C5EF50F8C305373EC7CC53F2AF4F2692A560

#
$workspace = Get-AzoperationalInsightsWorkspace -Name DefaultWorkspace-be12cre9-9d1b-4299-bb67-c811af35fa37-EUS -ResourceGroupName DefaultResourceGroup-EUS
$resourceGroup = "DefaultResourceGroup-EUS"
$query = @"
AuditLogs 
| where TimeGenerated >= ago(1d) and InitiatedBy contains "adm-"
| project ActivityDateTime, AADOperationType, OperationName, InitiatedBy, TargetResources
| order by ActivityDateTime asc
"@

# Run the query and get the results
$auditLogs = $(Invoke-AzOperationalInsightsQuery -WorkspaceId $workspace.CustomerId -Query $query).Results


If ($auditLogs -ne "") {
    # Export the logs to a CSV
    $auditLogs | Export-Csv -Path $logFile -NoTypeInformation

    # Read log file content
    $logContent = Import-Csv -Path $logFile

    # Create HTML content
    # HTML formatting starts
    $htmlContent += "<table>"

    # Add table headers
    $htmlContent += "<tr>"
    foreach ($header in $logContent[0].PSObject.Properties.Name) {
        $htmlContent += "<th>$header</th>"
    }
    $htmlContent += "</tr>"

    # Add table rows
    foreach ($row in $logContent) {

        $htmlContent += "<tr>"
    
        foreach ($property in $row.PSObject.Properties.Value) {
   
           # If log data contains both username and group name, call second funtion to remove uncessary bits and extract only username and groupname
           if ($property -match "userPrincipalName" -and $property -match "Group.DisplayName"){
                $property = Get-UserPrincipalNameAndGroupDisplayName -String $property
           } 
           # If log data contains only username, call first funtion to remove uncessary bits and extract only username          
           if ($property -match "userPrincipalName"){
                $property = Get-UserPrincipalName -String $property
           }
            $htmlContent += "<td>$property</td>"
        }
        $htmlContent += "</tr>"
    }

    $htmlContent += "</table>"
    # HTML formatting ends

# If no logs found in 24hrs
} else {
    $message = "No audit logs found for the last 24hrs!"
    $message | Out-File $logFile
    $htmlContent_temp = Get-Content -Path $logFile
    $htmlContent += $htmlContent_temp
}

# Write HTML content to the HTML file
$htmlContent | Out-File -FilePath $htmlFile
