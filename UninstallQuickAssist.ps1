# Check if MicrosoftCorporationII.QuickAssist exists
$package = Get-AppxPackage -Name MicrosoftCorporationII.QuickAssist

# If the package exists, uninstall it
if ($package)
{
    $package | Remove-AppxPackage -AllUsers
} 
else
{
    # If the package has different name, find/remove any other packages containing the word “QuickAssist”
    Get-AppxPackage *QuickAssist* | Remove-AppxPackage -AllUsers
}
