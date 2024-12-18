# To get a list of groups without a member – this gives all groups (security, distribution and built in)
Get-ADGroup -Filter {Members -notlike "*"} -Properties Members | Select-Object Name | Export-csv -Path "C:\Temp\ADGrpsWithoutMembers_Jan2024.csv"

# To get a list of groups without a member – this gives security and built in groups
Get-ADGroup -Filter {groupcategory -eq 'Security' -and Members -notlike "*"} -Properties Members | Select-Object Name | Export-csv -Path "C:\Temp\ADSecGrpsWithoutMembers_Jan2024.csv"
