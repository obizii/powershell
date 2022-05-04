# This will add a line to the hosts file with the preferred IP and URL.  Change the IP address (after `n) and URL (after `t).
Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n192.30.255.113`tgithub.com" -Force
