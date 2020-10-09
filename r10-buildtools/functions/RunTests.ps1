function RunUnitTests{

    $testFiles = (Get-ChildItem $buildConfig.UnitTestFolder -Recurse |Where-Object {($_.FullName -like "**\*tests.dll") -or ($_.FullName -like "**\*test.dll")}).FullName
	$exitCodes = @()
	foreach ($testFile in $testFiles) {
		Write-Host "Running tests in $($testFile.ToString()) "
			& MSTest "$testFile" "/TestAdapterPath:OzTest"
			$trxFile = (Get-ChildItem .\TestResults -Recurse | Where-Object {($_.FullName -like "*.trx") -and ($_.FullName -notlike "*.dll.trx")}).FullName
			if($trxFile){Rename-Item -Path $trxFile -NewName "$($testFile | split-path -Leaf).trx"}
            $exitCodes += $LASTEXITCODE
	}
}