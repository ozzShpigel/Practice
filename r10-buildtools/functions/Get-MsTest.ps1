function Get-MsTest
{
	$MsTest = "$(Get-VsCommonTools)..\IDE\MsTest.exe"
	if (Test-Path $MsTest) {$MsTest}
	else {Write-Error "Unable to find MsTest.exe"}
}