# https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/onboard-windows-multi-session-device?view=o365-worldwide
param(
    [Parameter(Mandatory = $true)]
    [string]$FSLogixProfileStorageURI,
    [Parameter()]
    [switch]$FSLogixCloudCache,
    [Parameter()]
    [hashtable]$DefenderTags
)
if ($PSBoundParameters.ContainsKey('DefenderGroupTag')) {
    # https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/machine-tags?view=o365-worldwide#add-device-tags-by-setting-a-registry-key-value
    $mdeTagRagistryPath = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection\DeviceTagging\'
    foreach ($tag in $DefenderTags.GetEnumerator()) {
        if ($tag.Value.Length -gt 200) {
            Write-Warning "Tag '$($tag.Key)' has value that exceeds 200 characters. The value will be truncated."
            $tag.Value = $tag.Value.Substring(0, 200)
        }
        New-ItemProperty -Path $mdeTagRagistryPath -Name $tag.Key -PropertyType String -Value $tag.Value -Force
    }
}
# Defender Exclusions for FSLogix
$filelist = @(
    "%ProgramFiles%\FSLogix\Apps\frxdrv.sys",
    "%ProgramFiles%\FSLogix\Apps\frxdrvvt.sys",
    "%ProgramFiles%\FSLogix\Apps\frxccd.sys",
    "%TEMP%\*.VHD",
    "%TEMP%\*.VHDX",
    "%Windir%\TEMP\*.VHD",
    "%Windir%\TEMP\*.VHDX",
    "$FSLogixProfileStorageURI\*.VHD",
    "$FSLogixProfileStorageURI\*.VHDX"
)
$processlist = @(
    "%ProgramFiles%\FSLogix\Apps\frxccd.exe",
    "%ProgramFiles%\FSLogix\Apps\frxccds.exe",
    "%ProgramFiles%\FSLogix\Apps\frxsvc.exe"
)
foreach ($file in $filelist) {
    Add-MpPreference -ExclusionPath $file
}
foreach ($process in $processlist) {
    Add-MpPreference -ExclusionProcess $process
}
If ($FSLogixCloudCache) {
    Add-MpPreference -ExclusionPath "%ProgramData%\FSLogix\Cache\*.VHD"
    Add-MpPreference -ExclusionPath "%ProgramData%\FSLogix\Cache\*.VHDX"
    Add-MpPreference -ExclusionPath "%ProgramData%\FSLogix\Proxy\*.VHD"
    Add-MpPreference -ExclusionPath "%ProgramData%\FSLogix\Proxy\*.VHDX"
}