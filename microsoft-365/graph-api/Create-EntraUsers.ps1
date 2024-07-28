## Connect to Graph API to with the correct scope to write new user objects in Entra ID.
Connect-MgGraph -Scopes "User.ReadWrite.All"

## Import user details from UserDetails.csv

$userList = Import-Csv -Path $PSScriptRoot\UserDetails.csv

## Create the parameters needed for user creation from the imported CSV file.
foreach ($user in $userList) {

    $passwordParams = @{
        Password                                = $user.Password
        ForceChangePasswordNextSignIn           = $true
        ForceChangePasswordNextSignInWithMfa    = $true
    }

    $employeeDataParams = @{
        CostCenter  = $user.CostCenter
        Division    = $user.Division
    }

    $userHireDate = [System.DateTime]::Parse($user.EmployeeHireDate)

    $userParams = @{
        BusinessPhones      = $user.BusinessPhones
        City                = $user.City
        CompanyName         = $user.CompanyName
        Country             = $user.Country
        DisplayName         = $user.DisplayName
        Department          = $user.Department
        EmployeeHireDate    = $userHireDate
        EmployeeId          = $user.EmployeeID
        EmployeeOrgData     = $employeeDataParams
        EmployeeType        = $user.EmployeeType
        GivenName           = $user.GivenName
        JobTitle            = $user.JobTitle
        Mail                = $user.Mail
        MailNickName        = $user.MailNickName
        MobilePhone         = $user.MobilePhone
        OfficeLocation      = $user.OfficeLocation
        PostalCode          = $user.PostalCode
        UserPrincipalName   = $user.UserPrincipalName
        State               = $user.State
        StreetAddress       = $user.StreetAddress
        Surname             = $user.Surname
        PasswordProfile     = $passwordParams
        AccountEnabled      = $true
    }

    try {
        $null = New-MgUser @userParams -ErrorAction Stop
        Write-Host ("Successfully created the account for {0}" -f $user.DisplayName) -ForegroundColor Green
    }
    catch {
        Write-Host ("Failed to create the account for {0}. Error: {1}" -f $user.DisplayName, $_.Exception.Message) -ForegroundColor Red
    }

}