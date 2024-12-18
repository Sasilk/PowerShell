# To export a list of groups syncing to 365 via AAD Connect (eg. Directory Sync Enabled)
Get-AzureADGroup | Where-Object { $_.DirSyncEnabled -eq $true } | Export-Csv -Path "C:\temp\ExportedData\SecurityGroupsSyncedFromADs.csv"
