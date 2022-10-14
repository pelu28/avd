param(
    [Parameter(Mandatory)]
    [string]$FSLogixProfileStorageURI

#    [Parameter(Mandatory)]
#    [string]$FSLogixRedirFolder
)
$ProgressPreference = 'SilentlyContinue'
Write-Output "Starting FSLogix configuration."
#FSLogix registry settings
$registryPath = "HKLM:\SOFTWARE\FSLogix\Profiles"
$registryValues = New-Object System.Collections.Generic.List[System.Object]
# Path to file share containing profiles
$registryValues.Add(@{key = 'VHDLocations'; value = $FSLogixProfileStorageURI; type = 'String'; path = $registryPath })
# Enable the FSLogix profiles
$registryValues.Add(@{key = 'Enabled'; value = 1; type = 'DWORD'; path = $registryPath })
# Deletes existing local profiles before logon – this avoids errors
$registryValues.Add(@{key = 'DeleteLocalProfileWhenVHDShouldApply'; value = 1; type = 'DWORD'; path = $registryPath })
# Changes the folder name to USERNAME-SID which is much easier during troubleshooting or maintenance search-related work.
$registryValues.Add(@{key = 'FlipFlopProfileDirectoryName'; value = 1; type = 'DWORD'; path = $registryPath })
# Sets profile VHDx to dynamic size does not use max size but expands 
$registryValues.Add(@{key = 'IsDynamic'; value = 1; type = 'DWORD'; path = $registryPath })
# Ensures that VHDx is used with fslogix profiles 
$registryValues.Add(@{key = 'VolumeType'; value = 'vhdx'; type = 'String'; path = $registryPath })
# Add redir config source folder
# $registryValues.Add(@{key = 'RedirXMLSourceFolder'; value = $FSLogixRedirFolder; type = 'String'; path = $registryPath })

# Install FSLogix
$fslogixTemp = $env:TEMP
$fslogixUrl = 'https://aka.ms/fslogix_download'
$fslogixZip = "$fslogixTemp\FSLogix_Apps.zip"
$fslogixDir = "$fslogixTemp\FSLogix_Apps"
Write-Output "Downloading installer from $fslogixUrl"
Invoke-WebRequest -Uri $fslogixUrl -OutFile $fslogixZip
Expand-Archive -Path $fslogixZip -DestinationPath  $fslogixDir -Force -Verbose
# Import the GPOs
Write-Output "Copying GPOs to place"
Copy-Item -Path "${fslogixDir}\fslogix.admx" -Destination 'C:\Windows\PolicyDefinitions' -Verbose
Copy-Item -Path "${fslogixDir}\fslogix.adml" -Destination 'C:\Windows\PolicyDefinitions\en-US' -Verbose
$appName = 'FSLogix Apps'
Write-Output "Starting $appName installer."
$process = Start-Process -FilePath "${fslogixDir}\x64\Release\FSLogixAppsSetup.exe" -ArgumentList '/install /passive /quiet /norestart' -Verb RunAs -Wait -PassThru
if ($process.ExitCode -eq 0) {
    Write-Output "$appName installed successfully."
}
else {
    Write-Error "$appName installer failed."
    exit 2
}
$appName = 'FSLogix Apps RuleEditor'
Write-Output "Starting $appName installer."
$process = Start-Process -FilePath "${fslogixDir}\x64\Release\FSLogixAppsRuleEditorSetup.exe" -ArgumentList '/install /passive /quiet /norestart' -Verb RunAs -Wait -PassThru
if ($process.ExitCode -eq 0) {
    Write-Output "$appName installed successfully."
}
else {
    Write-Error "$appName installer failed."
    exit 2
}
# Write-Output "Ensuring redir-rule directory '$FSLogixRedirFolder' exists."
# New-Item $FSLogixRedirFolder -ItemType Directory -Force
Write-Output "Settings registry values."
# Set registry values
foreach ($regval in $registryValues) {
    if (! (Test-Path -Path $regval.path)) {
        New-Item -Path $regval.path -Force | Out-Null
    }
    New-ItemProperty -Path $regval.path -Name $regval.key -Value $regval.value -PropertyType $regval.type -Force
}
# Install PowerShell module for manipulating FXA/FXR files
Write-Output "Installing FSLogix Powershell modules/scripts."
try {
    Install-Module -Name FSLogix.PowerShell.Rules -Force -Scope CurrentUser -ErrorAction Stop
}
catch {
    Write-Error "Module 'FSLogix.PowerShell.Rules' failed to install."
    exit 2
}
Write-Output "Module 'FSLogix.PowerShell.Rules' installed successfully."
try {
    Install-Script -Name Get-ApplicationRegistryKey -Force -Scope CurrentUser -ErrorAction Stop
}
catch {
    Write-Error "Script 'Get-ApplicationRegistryKey' failed to install."
    exit 2
}
Write-Output "Script 'Get-ApplicationRegistryKey' installed successfully."