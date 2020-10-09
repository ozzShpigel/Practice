function ConvertTrxToHtml{

    if((Test-Path .\TestResults -PathType Container))
	{
		$trxFiles = (Get-ChildItem TestResults | Where-Object {($_.FullName -like "*.trx")}).FullName
		$TrxToHtml = (Get-Item .\r10-buildtools\Tools\TrxerConsole\TrxerConsole.exe).FullName
		Set-Alias -Name TrxToHtml -Value $TrxToHtml
		foreach ($trxFile in $trxFiles) {
			Write-Host "Running on trx files in $($trxFile) "
				& TrxToHtml "$trxFile" 
				$exitCodes += $LASTEXITCODE
		}
	}
	
	if (($exitCodes -contains 1) -and ($buildConfig.failBuildOnUnitTestsFailure -eq $True)) {
		throw
	}
}