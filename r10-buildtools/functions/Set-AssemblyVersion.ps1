function Set-AssemblyVersion {
    param (
        $NewVersion
    )
    Write-Host $NewVersion
    Get-ChildItem -Include assemblyinfo.cs, assemblyinfo.vb -Recurse | 
    ForEach-Object {
        $_.IsReadOnly = $false
        (Get-Content -Path $_) -replace '(?<=Assembly(?:File)?Version\(")[^"]*(?="\))', $NewVersion |
            Set-Content -Path $_ -Verbose
        (Get-Content -Path $_) -replace '(?<=AssemblyInformationalVersion\(")[^"]*(?="\))', $NewVersion |
            Set-Content -Path $_ -Verbose
    }    
}