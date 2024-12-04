Get-ADUser -filter * -Properties "LastLogonDate" | select name, LastLogonDate | Export-Csv C:\temp\UsersLastLogonDates.csv
