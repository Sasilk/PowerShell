# As an Exchange Online admin, you can grant user A calendar permissions on user B’s calendar by running the PowerShell commands below.
Install-Module –Name ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName AdminUserName@yourdomain.com
Add-MailboxFolderPermission -Identity target.user@mydomain.co.uk:\Calendar -User other.user@mydomain.co.uk -AccessRights Editor -SharingPermissionFlags Delegate


# To show calendar permissions
Get-MailboxFolderPermission -Identity target.user@mydomain.co.uk:\Calendar

# To see only a specific user’s permission on someone’s calendar (UserA’s permissions on UserB’s calendar)
Get-MailboxFolderPermission -Identity UserB@mydomain.co.uk:\Calendar -User UserA@mydomain.co.uk
