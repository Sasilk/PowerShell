#Script to get the list domain admins in AD - Can be used for any other AD groups by changing group name below
# Define the group name
$GroupName = "Domain Admins"

# Get the members of the group
Get-ADGroupMember -Identity $GroupName -Recursive | Where-Object { $_.objectClass -eq "user" } | ForEach-Object {
    Get-ADUser -Identity $_.DistinguishedName -Properties DisplayName, DistinguishedName, Enabled | Select-Object @{
        Name = 'Username'; Expression = {$_.SamAccountName}
    }, @{
        Name = 'FullName'; Expression = {$_.DisplayName}
    }, @{
        Name = 'OUName'; Expression = {
            # Extract the Organizational Unit (OU) part from the DistinguishedName
            ($_.DistinguishedName -split ',OU=')[1..($_.DistinguishedName.Count)] -join ',OU='
        }
    },@{
        Name = 'OUFullPath'; Expression = {$_.DistinguishedName}
    },@{
        Name = 'AccountStatus'; Expression = {
            # Check if the account is enabled or disabled
            if ($_.Enabled -eq $true) { "Enabled" } else { "Disabled" }
        }
    }
} | Export-Csv -Path C:\temp\ADDomainAdminMembers.csv -NoTypeInformation -Encoding UTF8
