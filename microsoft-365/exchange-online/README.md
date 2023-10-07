# Exchange Online

This folder contains PowerShell scripts and on-liners for most Exchange Online management. Before you begin with your Exchange Online management journey, there are a couple things you'll want to get setup first. First, install the Exchange Online Management module for PowerShell. 

*Notes*

A couple things to keep in mind:

- Replace all content starting with < and ending with >.

### Install Exchange Online PowerShell Module

From an elevated PowerShell (Run as Administrator), run the following commandlets:

```powershell
Install-Module -Name ExchangeOnlineManagement
```
## *Almost* Scripts

Below is a list of useful commands I like to call *almost* scripts. There isn't a need to run these as scripts, instead, run these from your PowerShell console when managing your Exchange environment.

#### Create a Dynamic Distribution List

Dynamic distribution lists are really helpful for administrators who just want to create the user account, and let the systems they manage do the work for them. In this case, a Dynamic Distribution Group can take inputs from a set of common user attributes (readable by Exchange), and create distribution groups based on the user objects attributes.

**Create a Dynamic Distribution Group based on the user's department and title**

```powershell
# Create the Dynamic Distribution Group
New-DynamicDistributionGroup -Name '<IDENTITY>' -RecipientFilter {
    (RecipientType -eq 'UserMailbox') -and (Title -eq '<TITLE>') -and (Department -eq '<DEPARTMENT>')
}

# Configure the Dynamic Distribution Group for email
Set-DynamicDistributionGroup -Identity '<IDENTITY>' -PrimarySmtpAddress "<EMAIL_ADDRESS>" 

# View members of the Dynamic Distribution Group
$groupMem = Get-DynamicDistributionGroup -Identity "<IDENTITY>"

Get-Recipient -RecipientPreviewFilter ($groupMem.RecipientFilter)
```