## Download the MSI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Invoke-WebRequest -Uri https://github.com/git-for-windows/git/releases/latest -OutFile .\GitBash.exe
 
## Invoke the MSI installer suppressing all output
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
Start-Process GitBash.exe -Wait -ArgumentList '/Silent'

##Remove the MSI installer
Remove-Item -Path .\AzureCLI.msi
Remove-Item -Path .\GitBash.exe