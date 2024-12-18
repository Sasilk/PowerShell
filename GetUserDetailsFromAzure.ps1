# Script to export a list of users from Azure containing their DisplayName, Username, CloudUPN, AccountEnabled, CreatedDate, OnPremisesSyncStatus, AssignedLicenses, MailboxType
# NOTE: I commented out the part to have LastInteractiveSignInDate because it doesn't work like this. I didn't have a chnace to look into it.

# Install the Microsoft Graph module if not already installed
Install-Module Microsoft.Graph -Scope CurrentUser -Force

# Import necessary modules
Import-Module ExchangeOnlineManagement
Import-Module Microsoft.Graph

# Connect to Microsoft Graph and Exchange Online - IMPORTANT: Make sure you connect to MSGraph first and then connect to EXO. Otherwise it gives an error due to a glitch
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All" -NoWelcome
Connect-ExchangeOnline -UserPrincipalName AdminUserName@wyourdomain.com #-UseDeviceAuthentication

# Retrieve all user mailboxes
$mailboxes = Get-EXOMailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited
$mailboxDetails = @()

foreach ($mailbox in $mailboxes) {
    # Filter for users whose username ends with @yourdomain.com
    if ($mailbox.UserPrincipalName -like "*@yourdomain.com") {
        # Retrieve user details from Microsoft Graph
        $user = Get-MgUser -UserId $mailbox.ExternalDirectoryObjectId -Property "accountEnabled, createdDateTime, onPremisesSyncEnabled, userPrincipalName, assignedLicenses"

        # Check if user was found
        if (-not $user) {
            Write-Host "User not found for ID: $($mailbox.ExternalDirectoryObjectId)"
            continue
        }

        # Retrieve last sign-in activity
      #  $signInLogs = Get-MgAuditLogSignIn -Filter "userId eq '$($mailbox.ExternalDirectoryObjectId)'" -Top 1 | Sort-Object -Property createdDateTime -Descending

        # Create a custom object with the desired properties
        $mailboxDetails += [PSCustomObject]@{
            DisplayName          = $mailbox.DisplayName
            Username             = $mailbox.UserPrincipalName
            CloudUPN             = $user.UserPrincipalName
            AccountEnabled       = if ($user.AccountEnabled) { "Yes" } else { "No" }
            CreatedDate          = $user.CreatedDateTime
            OnPremisesSyncStatus = if ($user.OnPremisesSyncEnabled) { "Synced" } else { "Cloud Only" }
            AssignedLicenses     = if ($user.AssignedLicenses.Count -gt 0) { "Yes" } else { "No" } # Indicate if licensed
            MailboxType          = $mailbox.RecipientTypeDetails
          #  LastSignIn            = if ($signInLogs) { $signInLogs[0].createdDateTime } else { "N/A" }
        }
    }
}
# Define the file path for the CSV export. Change it for your path and if you use Windows machine make sure you put \ instead of \ as mine is a Linux path
$FilePath = "/home/sasil/SEVCAN/WTCC/AzureUserAccountDetails.csv"

# Export the mailbox details to a CSV file
$mailboxDetails | Export-Csv -Path $FilePath -NoTypeInformation -Encoding UTF8

# Output results to the console (optional)
#$mailboxDetails
