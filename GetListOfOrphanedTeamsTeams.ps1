Connect-ExchangeOnline -UserPrincipalName sevcan.asilkan@yourdomain.com
Get-UnifiedGroup | Where-Object {-Not $_.ManagedBy}  
