# Define the OU from which to retrieve computers
$ou = "OU=Desktops,OU=My Domain,DC=local"

# Define the path for the CSV file. It will put the OU path to the file name
$FilePath = "C:\temp\ComputersIn-$ou.csv"

# Get the list of computers in the specified OU, including additional properties such as lastLogonTimestamp
Get-ADComputer -Filter * -SearchBase $ou -Properties lastLogonTimestamp, operatingSystem, operatingSystemVersion |
    Select-Object Name, 
                  distinguishedName, 
                  @{Name='LastLogon'; Expression={[datetime]::FromFileTime($_.lastLogon)}}, 
                  @{Name='LastLogonTimestamp'; Expression={[datetime]::FromFileTime($_.lastLogonTimestamp)}}, 
                  operatingSystem, 
                  operatingSystemVersion |
    Export-Csv -Path $FilePath -NoTypeInformation

# Output a message indicating completion
Write-Host "Export complete. The list of computers has been saved to $FilePath"
