#Install Chocolatey
$env:chocolateyVersion = '1.4.0'
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
#Install required apps
choco install git.install azure-cli --force -y
choco install pwsh --force -y
#Install az module 
Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force
Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force -AllowClobber
