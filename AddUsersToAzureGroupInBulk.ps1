#Script to add a list of users (in a .csv) to a cloud security group in Azure

# Install-Module -Name AzureAD
# Install-Module -Name ImportExcel (optional for Excel reading)
#Import-Module AzureAD

Connect-AzureAD

$GroupName = 'Test Group'

# Path to the file containing user accounts. Make sure the CSV file has a column named 'UserPrincipalName' for the users' emails
$CSVFilePath = "C:\temp\UserList.csv"

if (-not (Test-Path -Path $CSVFilePath)) {
    Write-Error "The specified CSV file does not exist. Please check the file path."
    exit
}
$UserList = Import-Csv -Path $CSVFilePath
if (-not $UserList) {
    Write-Error "The CSV file is empty or could not be read. Please check the file path and format."
    exit
}
$Group = Get-AzureADGroup -Filter "displayName eq '$GroupName'"
if (-not $Group) {
    Write-Error "Group '$GroupName' not found in Azure AD."
    exit
}
foreach ($User in $UserList) {
    $UserPrincipalName = $User.UserPrincipalName
    if (-not $UserPrincipalName) {
        Write-Warning "A row in the CSV file is missing the 'UserPrincipalName' value. Skipping."
        continue
    }
    $AzureADUser = Get-AzureADUser -Filter "UserPrincipalName eq '$UserPrincipalName'"
    if ($AzureADUser) {
        # Add the user to the group
        try {
            Add-AzureADGroupMember -ObjectId $Group.ObjectId -RefObjectId $AzureADUser.ObjectId
            Write-Output "Added $UserPrincipalName to the group '$GroupName'."
        } catch {
            Write-Error "Failed to add $UserPrincipalName to the group. Error: $_"
        }
    } else {
        Write-Warning "User $UserPrincipalName not found in Azure AD. Skipping."
    }
}
