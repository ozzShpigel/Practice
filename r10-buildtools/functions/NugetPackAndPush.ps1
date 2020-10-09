function NugetPackAndPush {
    $nugetConfig = (Get-Item ".\r10-buildtools\nuget.config").FullName
    NuGet sources update -Name Artifactory -User $ENV:JFROG_USER -Pass $ENV:JFROG_ENCRYPTED_PASS -ConfigFile $nugetConfig
    $nuspecFiles = Get-ChildItem -Filter "*.nuspec" | Select-Object -ExpandProperty FullName
    $creds="$($ENV:JFROG_USER):$($ENV:JFROG_ENCRYPTED_PASS)"
    foreach($nuspec in $nuspecFiles)
    {
        NuGet pack $nuspec -OutputDirectory .\
    }
    $nupkgFiles = Get-ChildItem . -Filter *.nupkg | Select-Object -ExpandProperty Fullname
    foreach($nupkg in $nupkgFiles)
    {
        NuGet push $nupkg $creds -source Artifactory -ConfigFile $nugetConfig
    }

}