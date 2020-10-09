function Get-VsCommonTools
{	
	$VsCommonToolsPaths = @(@($env:VS120COMNTOOLS,$env:VS100COMNTOOLS) | Where-Object {$_ -ne $null})
	if ($VsCommonToolsPaths.Count -ne 0) {$VsCommonToolsPaths[0]}
	else {Write-Error "Unable to find Visual Studio Common Tool Path."}
}