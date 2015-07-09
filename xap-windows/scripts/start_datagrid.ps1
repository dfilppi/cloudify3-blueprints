$locator_ip = (C:\CloudifyAgent\Scripts\ctx node properties locator_ip)
$env:LOOKUPLOCATORS="${locator_ip}:4174"
C:\gs\gigaspaces-xap-premium-10.1.1-ga\bin\gs.bat deploy-space -cluster 'total_members=2,0' -initialization-timeout 120000 myGrid 2>&1 | Out-File C:\log.txt -Append
