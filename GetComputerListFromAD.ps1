# It is handful to be able to get a list of computers in a particular OU in AD, you can use the PowerShell script below I created.
# Please note you need to edit it with your OU name. Basically copy the lines below in a txt file, amend the OU name and save it as GetComputerListFromAD.ps1. And run.

# Define the OU from which to retrieve computers. Please note OUs here is in reverse order. You can copy&paste the OU Distinguished name from AD — Right click on AD and Properties > Attribute Editor and find distinguishedName
$ou = “OU=A1,OU=ATeams,OU=ADepartment,OU=Departments,OU=Computer Locations,DC=xyz,DC=local”

# Define the path for the CSV file. It will create a new file for each OU
$FilePath = “C:\temp\ComputersIn$ou.csv”

# Get the list of computers in the specified OU and export to CSV
Get-ADComputer -Filter * -SearchBase $ou | Select-Object Name | Export-Csv -Path $FilePath -NoTypeInformation

# Output a message indicating completion
Write-Host “Export complete. The list of computers has been saved to $FilePath”
