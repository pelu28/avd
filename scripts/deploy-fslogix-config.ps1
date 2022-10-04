[CmdletBinding()]
param (
    [Parameter()]
    [string]$FSLogixProfileStorageURI
)

try {
    if ($FSLogixProfileStorageURI) {
        # Fslogix profile container
        $fslogixPath = "HKLM:\Software\FSLogix\Profiles"
        if (!(Test-Path $fslogixPath)) {
            New-Item -Path $fslogixPath -Force | Out-Null
        }
        New-ItemProperty -Path $fslogixPath -Name Enabled -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $fslogixPath -Name VHDLocations -Value $FSLogixProfileStorageURI -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $fslogixPath -Name DeleteLocalProfileWhenVHDShouldApply -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $fslogixPath -Name FlipFlopProfileDirectoryName -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $fslogixPath -Name IsDynamic -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $fslogixPath -Name VolumeType -Value VHDx -PropertyType String -Force | Out-Null

        Write-Information "Configuring fslogix profile location"
    }
}
catch {
    Throw "Configuring FSLogix profile location not succesfully, $_"
}