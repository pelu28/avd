#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
#Install required apps
choco install git.install azure-cli --force -y
#set git bin folder to path
$Env:PATH += ";C:\Program Files\Git\bin"

