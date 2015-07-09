Set-ExecutionPolicy RemoteSigned
$jdk_download_url = (C:\CloudifyAgent\Scripts\ctx node properties jdk_download_url)
Invoke-WebRequest $jdk_download_url -OutFile C:\CloudifyAgent\jdk.zip
function unzip($filename)
{
    $shell_app = new-object -com shell.application
    $zip_file = $shell_app.namespace((Get-Location).Path + "\$filename")
    $destination = $shell_app.namespace((Get-Location).Path)
    $destination.Copyhere($zip_file.items())
}
cd C:\CloudifyAgent
unzip("jdk.zip")
Start-Process -FilePath msiexec -ArgumentList /i, C:\CloudifyAgent\jdk\jdk1.7.0_79.msi, /quiet -Wait
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk1.7.0_79", "Machine")
