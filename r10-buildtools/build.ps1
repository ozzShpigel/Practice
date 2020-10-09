param(
    $Task = '.',
    $File = "tasks.ps1"
) 

try {
    Import-Module ".\invokeBuild\*\InvokeBuild.psd1" -Force -ErrorAction Stop
    Get-ChildItem .\functions -Filter *.ps1 -Recurse | ForEach-Object {. $_.FullName}
    Invoke-Build -File $File -Task $Task -Result Result
}
catch {
    $_
	throw
}finally{
    $Result.Tasks | Format-Table Elapsed, Name, Error -AutoSize
	$Result.Tasks
}