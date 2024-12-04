#Script to export members of all security groups (It will create a csv file for each SG under C:\Temp\SecGrpMembers\ folder in your PC)

#You need to have the list of security groups name in a file and give it as the input
$secGrpsFile = "C:\Scripts\SecurityGroupsForQDriveFolderACLs\AllSecGrps.csv"
$secGrps = Import-Csv -Path $secGrpsFile
foreach ($secGrp in $secGrps) {
    $secGrp = $($secGrp.'Security Group Name')
    $file = "C:\Temp\SecGrpMembers\$secGrp - Members.csv"
    Get-ADGroupMember -Identity $secGrp | Select-Object Name, SamAccountName | Sort-Object Name | Export-Csv -Path $file -NoTypeInformation
}
