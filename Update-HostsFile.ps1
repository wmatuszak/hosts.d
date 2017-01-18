# Update-HostsFile.ps1

$pathRoot = $PSScriptRoot + "\"
$pathHostsRoot = $pathRoot + "hosts.d\"

$pathBaseHosts = $pathRoot + "base.hosts"
$pathCacheHosts = $pathRoot + "hosts.cache"

$pathHosts = $pathRoot + "hosts"
$pathHostsWorking = $pathHosts + ".working"
$pathHostsBackup = $pathHosts + ".backup"

$staticHosts = Get-ChildItem -Path $pathHostsRoot\*.hosts
$dynamicHosts = Get-ChildItem -Path $pathHostsRoot\*.dhosts

$flagGenerateNewHosts = $false

if(-not(Test-Path $pathHostsRoot)){Write-Host "Error - No hosts.d folder found. Exiting..."; exit(1);}
if(-not(Test-Path $pathBaseHosts)){Write-Host "Error - No hosts.d folder found. Exiting..."; exit(1);}

# Check if any files differ from the cache and a new hosts file needs generated
if(Test-Path $pathCacheHosts)
{   
    $oldHostsCache = Import-Clixml $pathCacheHosts

    # Check if hosts file has been altered
    if($oldHostsCache["hosts"] -ne (Get-FileHash $pathHosts -Algorithm MD5).Hash)
    {
        # If so, parse out altered lines and create a separate static hosts
        $pathNewHostsDiff = $pathHostsRoot + "diff-" + (Get-Date).Ticks + ".hosts"

        $currentHosts = Get-Content $pathHosts
        $lastHosts = Get-Content $pathHostsBackup

        $diffHosts = Compare-Object $currentHosts $lastHosts

        foreach($diff in $diffHosts)
        {
            if($diff.SideIndicator -eq "<=")
            {
                Out-File -InputObject $diff.InputObject -FilePath $pathNewHostsDiff -Append -Encoding ascii
            }
        }

        # Replace the modified hosts with the last backup
        Copy-Item -Path $pathHostsBackup -Destination $pathHosts -Force

        $flagGenerateNewHosts = $true
    }
    
    # Check if any .hosts files have changed
    foreach($sFile in $staticHosts){ if($oldHostsCache[$sFile.Name] -ne (Get-FileHash $sFile.FullName -Algorithm MD5).Hash) { $flagGenerateNewHosts = $true } }
    foreach($sFile in $dynamicHosts){ if($oldHostsCache[$sFile.Name] -ne (Get-FileHash ($sFile.FullName + ".download") -Algorithm MD5).Hash) { $flagGenerateNewHosts = $true } }
}
else
{
    $flagGenerateNewHosts = $false
}

# Initialize a new hosts file cache
$newHostsCache = @{};

# Create new working hosts file
Copy-Item -Path $pathBaseHosts -Destination $pathHostsWorking -Force
$newHostsCache.Add("base.hosts",(Get-FileHash $pathBaseHosts -Algorithm MD5).Hash)

# Append contents of static hosts files
foreach($sFile in $staticHosts)
{
    $header = "#  -- Begin Hosts Entry: " + $sFile.Name + " -- "
    $footer = "#  -- End Hosts Entry: " + $sFile.Name + " -- "
    $content = Get-Content $sFile.FullName

    Out-File -InputObject $header -FilePath $pathHostsWorking -Encoding ascii -Append
    Out-File -InputObject $content -FilePath $pathHostsWorking -Encoding ascii -Append
    Out-File -InputObject $footer -FilePath $pathHostsWorking -Encoding ascii -Append

    $newHostsCache.Add($sFile.Name,(Get-FileHash $sFile.FullName -Algorithm MD5).Hash)
}
# Download each dynamic hosts file and append
foreach($sFile in $dynamicHosts)
{
    $header = "#  -- Begin Hosts Entry: " + $sFile.Name + " -- "
    $footer = "#  -- End Hosts Entry: " + $sFile.Name + " -- "
    $url = Get-Content $sFile.FullName

    $pathTempDhost = $sFile.FullName + ".temp"
    $pathDownloadDhost = $sFile.FullName + ".download"

    # Download main script
    try { Invoke-WebRequest -Uri $url -OutFile $pathTempDhost; Move-Item -Path $pathTempDhost -Destination $pathDownloadDhost -Force; } catch { Write-Error "Unable to download updated dhosts entry!! Skipping..."; }

    if(Test-Path $pathDownloadDhost)
    {
        $content = Get-Content $pathDownloadDhost
        Out-File -InputObject $header -FilePath $pathHostsWorking -Encoding ascii -Append
        Out-File -InputObject $content -FilePath $pathHostsWorking -Encoding ascii -Append
        Out-File -InputObject $footer -FilePath $pathHostsWorking -Encoding ascii -Append
    }

    $newHostsCache.Add($sFile.Name,(Get-FileHash $pathDownloadDhost -Algorithm MD5).Hash)
}

# Remplace hosts file with new one
Move-Item -Path $pathHostsWorking -Destination $pathHosts -Force
Copy-Item -Path $pathHosts -Destination $pathHostsBackup -Force
$newHostsCache.Add("hosts",(Get-FileHash $pathHosts -Algorithm MD5).Hash)

# Update the cache of file hashes for hosts files
Export-Clixml -InputObject $newHostsCache -Path $pathCacheHosts -Force
