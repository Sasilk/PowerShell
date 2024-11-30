#Script to export members of all distribution groups (It will create a separate csv for each DL  under C:\Temp\DLMembers\)

#You need to have a list of DLs in a csv and give it to the script as input
$DLFile = "C:\Scripts\SecurityGroupsForQDriveFolderACLs\AllDLs.csv"
$DLs = Import-Csv -Path $DLFile
foreach ($DL in $DLs) {
    $DL = $($DL.'SamAccountName')
    $file = "C:\Temp\DLMembers\$DL - Members.csv"
    Get-ADGroupMember -Identity $DL | Select-Object Name, SamAccountName | Sort-Object Name | Export-Csv -Path $file -NoTypeInformation
}
