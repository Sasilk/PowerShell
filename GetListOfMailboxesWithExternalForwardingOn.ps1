# To get a list of mailboxes that external email forwarding is enabled, also gives the forwarding address
Connect-ExchangeOnline -UserPrincipalName sevcan.asilkan@yourdomain.com
Get-Mailbox | Where {($_.ForwardingSmtpAddress -ne $null) -and ($_.ForwardingAddress -eq $null)} | Select Name, ForwardingSmtpAddress