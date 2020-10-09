function Get-Artifacts {
    param(
        $Repo        = '',
        $Groupid    = '',
        $Artifactid = '',
        $Version    = '' 
    )
$WorkFold = 'Prerequisites'
$apiKey      = 'AKCp5ekHX1bsufGVDw5Jfg9RHgBUsRttduqsWufq2ETarps93bLyAmrmZQDihoXaQndJEtRgS'

Write-Host "Get-Artifacts :"$Url
Write-Host "Artifcats Versions:"$allVersions.Links.innerHTML
Write-Host "Latest Version:$latestVersion"

New-Item -ItemType Directory -Force -Path .\$WorkFold
JFROGCLI rt download  "$Repo/$Groupid/$Artifactid/$Version/" $WorkFold/$Artifactid.zip --sort-by=created --sort-order=desc --limit=1 --apikey=$apiKey --url=https://ncr.jfrog.io/artifactory --threads=6 --flat=true

Expand-Archive -Path ".\$WorkFold\$Artifactid.zip" -DestinationPath .\$WorkFold\ -Force
}
