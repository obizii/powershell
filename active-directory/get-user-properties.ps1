# Get all Active Directory properties for a user by SamAccountName. Useful when needing to compare one or two user accounts for differences and troubleshooting.
# Change output path to a directory that is accessible to the user running this command.
Import-Module ActiveDirectory
Get-ADUser <SamAccountName> -Properties * | Out-File -FilePath "C:\Some\Folder\<SamAccountName>.txt"
