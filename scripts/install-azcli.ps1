## Download the MSI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
 
## Invoke the MSI installer suppressing all output
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

##Remove the MSI installer
Remove-Item -Path .\AzureCLI.msi