Set-ExecutionPolicy RemoteSigned
Start-Process -FilePath msiexec -ArgumentList /x, C:\CloudifyAgent\jdk\jdk1.7.0_79.msi, /quiet -Wait
rm -r C:\CloudifyAgent\jdk
rm C:\CloudifyAgent\jdk.zip
[Environment]::SetEnvironmentVariable("JAVA_HOME", $null, "Machine")
