Set-ExecutionPolicy RemoteSigned
&netsh advfirewall set allprofiles state off
md C:\gs
$xap_download_url = (C:\CloudifyAgent\Scripts\ctx node properties xap_download_url)
Invoke-WebRequest $xap_download_url -OutFile C:\gs\gs.zip
function unzip($filename)
{
    $shell_app = new-object -com shell.application
    $zip_file = $shell_app.namespace((Get-Location).Path + "\$filename")
    $destination = $shell_app.namespace((Get-Location).Path)
    $destination.Copyhere($zip_file.items())
}
cd C:\gs
unzip("gs.zip")
$license_key = (C:\CloudifyAgent\Scripts\ctx node properties license_key)
(Get-Content C:\gs\gigaspaces-xap-premium-10.1.1-ga\gslicense.xml) -replace 'Enter Your License Here....',$license_key | Set-Content C:\gs\gigaspaces-xap-premium-10.1.1-ga\gslicense.xml
$locator_ip = (C:\CloudifyAgent\Scripts\ctx node properties locator_ip)
$gs_agent_args = (C:\CloudifyAgent\Scripts\ctx node properties gs_agent_args)
C:\CloudifyAgent\nssm\nssm.exe install xapgs 'C:\gs\gigaspaces-xap-premium-10.1.1-ga\bin\gs-agent.bat'
C:\CloudifyAgent\nssm\nssm.exe set xapgs AppParameters "${gs_agent_args}"
C:\CloudifyAgent\nssm\nssm.exe set xapgs AppEnvironmentExtra "LOOKUPLOCATORS=${locator_ip}:4174"
C:\CloudifyAgent\nssm\nssm.exe install xapweb 'C:\gs\gigaspaces-xap-premium-10.1.1-ga\bin\gs-webui.bat'
C:\CloudifyAgent\nssm\nssm.exe set xapweb AppEnvironmentExtra "LOOKUPLOCATORS=${locator_ip}:4174"
