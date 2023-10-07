<#
.SYNOPSIS
Disable Sweet32 Vulnderable Cipher Suites used in SSL/TLS

.DESCRIPTION
The script identifies active 3DES and RC4 cipher suites in Windows Server 2012 R2 through Windows Server 2022 versions.
The script, when complete, will restart the computer.

.INPUTS
NONE

.OUTPUTS
- Detailed log file for script
Log: C:\logs\disable-insecurecipher.log
- List of previous registry entries in case of backup
File: C:\logs\registry-cipher-list.txt

.EXAMPLE
.\Disable-InsecureCipher.ps1 

.NOTES
Author: Chris O'Brien
Email: chris@obizii.com

.LINK
https://nvd.nist.gov/vuln/detail/CVE-2016-2183
#>

# Create logging for the script
$logPath = 'C:\logs'
$logFile = "$logPath\disable-insecurecipher.log"
$regValues = "$logPath\registry-cipher-list.txt"

# Verify logging path exists, and create one if it does not.
try{
    if (-not (Test-Path -Path $logPath -ErrorAction Stop)) {
        New-Item -ItemType Directory -Path $logPath -ErrorAction Stop | Out-Null
        New-Item -ItemType File -Path $logFile -ErrorAction Stop | Out-Null
        New-Item -ItemType File -Path $regValues -ErrorAction Stop | Out-Null
    }
}
catch {
    throw
}

# Add log entry that script is running
Add-Content -Path $logFile -Value "[INFO] Running $PSCommandPath"

# Verify that a registry key exists for the insecure ciphers.
try {
    Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\00010002" -Name Functions -ErrorAction Stop | Out-Null
    Add-Content -Path $logFile -Value "[INFO] Registry Keys for SSL/TLS Ciphers found."
}
catch {
    Add-Content -Path $logFile -Value "[ERROR] Registry Keys for SSL/TLS Ciphers not found."
    throw
}

# Get registry value for Functions entry, export list of current values to text file.
$cipherList = @((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\00010002" -Name Functions).Functions)

# Write the current values to a text file for use in case of recovery.
foreach ($regValue in $cipherList) {
    Add-Content -Path $regValues -Value "$regValue"
    Add-Content -Path $logFile -Value "[INFO] Registry value '$regValue' written to '$regValues'."
}

# Create an array containing a list of the insecure ciphers
$cipherBad = @($cipherList -match "3DES|RC4")

try {
    # Identify if cryptography registry contains 3DES values
    if ($cipherBad -match "3DES") {
        Add-Content -Path $logFile -Value "[INFO] Triple DES cipher found in registry key for cryptographic functions."
    }
    else {
        #Write to log file that 3DES not found
        Add-Content -Path $logFile -Value "[INFO] Triple DES cipher not found in registry key for cryptographic functions."
    }

    # Identify if cryptography registry contains RC4 values
    if ($cipherBad -match "RC4") {
        Add-Content -Path $logFile -Value "[INFO] RC4 cipher found in registry key for cryptographic functions."
    }
    else {
        #Write to log file that 3DES not found
        Add-Content -Path $logFile -Value "[INFO] RC4 cipher not found in registry key for cryptographic functions."
    }
}
catch {
    Add-Content -Path $logFile -Value "[INFO] Exiting script. No bad ciphers found."
    throw
}

# Remove the insecure ciphers from the final list of good ciphers
try {
    $cipherList = $cipherList | Where-Object {$cipherBad -notcontains $_}
    Add-Content -Path $logFile -Value "[INFO] Removed insecure ciphers from array."
}
catch {
    Add-Content -Path $logFile -Value "[ERROR] Exiting script. Unable to modify array."
    throw
}


# Identify version of operating system to perform removal of insecure ciphers
$osVersion = [System.Environment]::OSVersion.Version

# Log the operating system version
if ($osVersion.Major -ge 10){
    foreach ($insecureCipher in $cipherBad) {
        Disable-TlsCipherSuite -Name $insecureCipher
        Add-Content -Path $logFile -Value "[INFO] TLS Cipher Suite $insecureCipher removed from registry."
    }
}
else {
    Add-Content -Path $logFile -Value "[INFO] Operating system is Windows Server 2012 or below."
}

# Export copy of registry key hosting insecure ciphers for use in case of an error
Add-Content -Path $logFile -Value "[INFO] Registry key exported to $exportRegFile."

# Disable insecure ciphers previously found.
try {
    if ($osVersion.Major -ge 10) {
        foreach ($cipher in $cipherBad) {
            Disable-TlsCipherSuite -Name $cipher
            Add-Content -Path $logFile -Value "[INFO] Disabled $cipher using TlsCipherSuite cmdlet."
        }
    }
    else {
        Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\00010002" -Name Functions -Value $cipherList
        Add-Content -Path $logFile -Value "[INFO] Disabled ciphers using registry modification cmdlet."    }
}
catch {
    Add-Content -Path $logFile -Value "[ERROR] Unable to remove insecure ciphers using TlsCipherSuite cmdlet."
}

Restart-Computer -Confirm:$true
