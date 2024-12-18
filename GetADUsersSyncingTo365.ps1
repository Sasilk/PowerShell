# To export a list of users syncing to 365 via AAD Connect (eg. Directory Sync Enabled)
Get-AzureADUser | Where-Object { $_.DirSyncEnabled -eq $true } | Export-Csv -Path "C:\temp\ExportedData\UsersSyncedFromADs.csv"
