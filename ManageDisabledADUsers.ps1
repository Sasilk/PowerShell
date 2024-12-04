$moveToOU = "OU=Disabled Accounts,DC=my,DC=domain,DC=plc"

# Getting disabled users
$Users = Get-ADUser -filter {Enabled -eq $false } | Select DistinguishedName, SamAccountName
 
 ForEach ($User In $Users){

  # Move user to the DisabledAccountsOU
   Move-ADObject -Identity $User.DistinguishedName -TargetPath $moveToOU
  
   #Get group membership of the user
   $ExistingGroups = Get-ADPrincipalGroupMembership $User.SamAccountName | Select-Object name
  
   ForEach ($Group In $ExistingGroups){
        
    # Remove user from all groups  
    Remove-ADGroupMember -Identity $Group.name -Members $User.SamAccountName -Confirm:$false
   
    }
  }
