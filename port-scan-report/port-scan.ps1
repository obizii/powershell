# If parameters are not specified at run-time, the script will search in 
# the same directory as the script for the input files.

param(
    [string]$NodesFile  = "$PSScriptRoot\nodes.csv",
    [string]$PortsFile  = "$PSScriptRoot\ports.csv",
    [string]$ServerFile = "$PSScriptRoot\servers.csv"
)



# Clear any lingering jobs as they may corrupt the output.
Get-Job | Remove-Job


# Read input file contents
try{
    # Import CSV with nodes to test
    $Nodes = Get-Content $NodesFile

    # Import CSV with ports to scan
    $Ports = Get-Content $PortsFile

    # Import CSV with servers to scan
    $Servers = Get-Content $ServerFile
}
catch{
    Write-Error "Please verify the files nodes.csv, ports.csv and servers.csv exist in the current directory"
    exit
}


foreach($Node in $Nodes){
    Invoke-Command -ComputerName $Node { 
        Param($portsCmd,$serversCmd,$Node)       
        foreach($server in $serversCmd) {
            Start-Sleep -Seconds (Get-Random -Minimum 2 -Maximum 10)
            foreach($port in $portsCmd){
                $result = Test-NetConnection -Port $port -ComputerName $server
                New-Object -TypeName PSCustomObject -Property @{
                    'Host'       = $Node
                    'Server'     = $server
                    'Port'       = $port
                    'Successful' = $result.TcpTestSucceeded
                }
            }  
        }          
    } -ArgumentList $ports,$servers,$Node -AsJob
}

# Wait for all jobs to finish
$finishedJobs = Get-Job | Wait-Job

# Export output to time-stamped csv file
$exportFilePath = "$PSScriptRoot\Results_$(Get-Date -Format yyMMddhhmmss).csv"
$finishedJobs.ChildJobs.Output | Select Host,Server,Port,Successful | Export-Csv -Path $exportFilePath  -NoTypeInformation

# Configure email settings
$mailSubject = "Port Connection Test Results - $(Get-Date -Format yyMMddhhmmss)"
$mailRecipient = "recipient@mail.com"
$mailFrom = "your@mail.com"
$smtpServer = "your.mail.server"
$smtpPort = "12345"
$emailBody = "What ever text you want in the email body"
$emailServerUserName = "your@email.com"
$emailServerPassword = "yourpassword"

$password = ConvertTo-SecureString $emailServerPassword -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ($emailServerUserName, $password)

# Send mail message
Send-MailMessage -To $mailRecipient -from $mailFrom -Subject $MailSubject -SmtpServer $smtpServer -UseSsl -Credential $Credentials -Body $emailBody -Port $smtpPort -Attachments $exportFilePath
