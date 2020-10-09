param(
    $Task = '.',
    $File = "r10-buildtools\tasks.ps1"
) 

try {
    Import-Module ".\r10-buildtools\invokeBuild\*\InvokeBuild.psd1" -Force -ErrorAction Stop
    Get-ChildItem .\r10-buildtools\functions -Filter *.ps1 -Recurse | ForEach-Object {. $_.FullName}
    Invoke-Build -File $File -Task $Task -Result Result
}
catch {
    $_
	throw
}finally{
    $Result.Tasks | Format-Table Elapsed, Name, Error -AutoSize
	$Result.Tasks
}