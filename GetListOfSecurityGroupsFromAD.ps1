#To get a list of security groups from an AD
Get-ADGroup -filter {groupcategory -eq 'Security'} | Export-Csv -Path "C:\Temp\ADSecGrps_Jan2024.csv"
