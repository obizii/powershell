# PowerShell Scripts

I'm not expert when it comes to PowerShell, but I do find it quite useful to leverage the awesome power to perform every-day repeatable tasks leveraging scripts.  Included in this repository are some of my most used scripts that I hope you find useful as well.

**Create an Active Directory User Object**
> create-ad-user

This script will create an active directory user account, add it to the appropriate OU, and set perameters like password expiration, password string, address, and phone number.  Simply fill out the *create-ad-user.csv* file with the requisite information, and run the *create-ad-user.ps1* file with a user account with appropriate permissions in Active Directory.
