# disable-insecureciphers.ps1

The testing for the insecure cipher suites is conducted to validate methods for corrective action and remediation. All fully patched versions of Windows Server (2012 through 2022)l contain active insecure ciphers (3DES & RC4). The registry entries for all versions must me modified to disable the use of the 64-bit ciphers. 

## Registry Location 

The registry key (REG_MULTI_SZ) contains multiple values.  

 - Registry Path: HKLM:\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\000100002 
 - Name: Functions 
 - Type: REG_MULTI_SZ 

## Script Build 

The script build has a few main requirements: 

 - Logging: Create a log of actions (INFO and ERROR) to capture the process 
 - Backup: A file containing the current set of registry entries should be captured before removing individual entries 
 - Targeting: When modifying the registry, it's important to only target the insecure ciphers, leaving secure versions in tact 
 - Operating System Validation: Because Server 2016 and above, and Server 2012 and below have different methods for removing the ciphers, the script must identify the correct version, and take action based on the version presented. 
 - Error Handling: If, in the process of running, the script encounters and error, it should stop processing and quit. 

## Logging 

The script will log a file called disable-insecurecipher.log to the C:\logs path on the machine where the script is running. If that location does not exist, the script will create the file path. 

## Backup 

Prior to removing any insecure ciphers from the registry, the script will create a backup text file of the Functions values and store them in a file called registry-cipher-list.txt in the log path (C:\logs). 

## Targeting 

The script will only search for ciphers stored in an object oriented array that contain the values "3DES" or "RC4" using regular expressions. Once found, it will store these values in a new array. Once called, the script will remove these values from the registry key called Functions. 

## Operating System Validation 

The script will verify the version by looking up the Major version value. If the version is identified as being for Server 2016 or above, the script will run the TlsCipherSuite cmdlets to remove the ciphers. If the version is identified as being for Server 2012 or below, the script will run the ItemProperty cmdlets to remove the values from the registry key called Functions. 

## Error Handling 

The script uses multiple try-catch functions to run processes, and if the process fails, it will throw the process, quitting the scripting process. 

## Testing 

Prior to running the script on any server version, the server was fully patched. The port chosen for the scan was 3389, RDP. The process for testing is as follows: 

 1. Perform a scan of the system's current available cipher suite using an nmap script (ssl-enum-ciphers).  The output of the scan was reviewed, then saved for each OS version (1-pre-fix-pre-reboot.xml) 
 2. Create a snapshot of the server called "sweet32-start". 
 3. Run the script on the server. The server automatically reboots. 
 4. Perform a post-fix scan on the systems newly available cipher suites using the same method. Output scan reviewed and validated. Saved the scan (2-post-fix-post-reboot). 

At each test, the values of the starting cipher suite and update cipher suites were compared.  It is noted that on all versions (2008 through 2022), the insecure cipher suite was disabled without issue. Also verified the output of the backup cipher file and the log file. 
