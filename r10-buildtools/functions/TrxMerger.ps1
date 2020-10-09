function TrxMerger{

    $totalSum = 0
	$executedSum = 0
	$passedSum = 0
	$failedSum = 0
	$trxFiles = (Get-ChildItem .\TestResults | Where-Object {($_.FullName -like "*IntegrationTests*.trx" -and $_.FullName -notlike "*IntegrationTests.SelfScan*.trx")}).FullName
	$html = '<html><head><style>table, th, td {border: 1px solid black;border-collapse: collapse;}table.center {margin-left:auto; margin-right:auto;}</style></head><body><h2>Integration Tests Results</h2><table class="table1"><tr><th>Total</th><th>Executed</th><th>Passed</th><th>Failed</th></tr>'
	$secondTable = '<table class="table2"><tr><th>Assemblie</th><th>Total</th><th>Executed</th><th>Passed</th><th>Failed</th></tr>'

	foreach ($trxFile in $trxFiles) {
		[xml]$XmlDocument = Get-Content $trxFile
		$total = $XmlDocument.TestRun.ResultSummary.Counters.total
		$executed = $XmlDocument.TestRun.ResultSummary.Counters.executed
		$passed = $XmlDocument.TestRun.ResultSummary.Counters.passed
		$failed = $XmlDocument.TestRun.ResultSummary.Counters.failed 
		Write-Host "Total: " $total
		Write-Host "Passed: " $passed

		$totalSum += $total
		$executedSum += $executed
		$passedSum += $passed
		$failedSum += $failed
		$trxFile = Split-Path $trxFile -leaf

		$secondTable += "<tr><td>$trxFile</td><td>$totaL</td><td>$executed</td><td>$passed</td><td>$failed</td></tr>" 
	}

	$html += "<tr><td>$totalSum</td><td>$executedSum</td><td>$passedSum</td><td>$failedSum</td></tr></table></body></html>"
	$html += "$secondTable</table></table></body></html>"
	$html | Out-File -FilePath .\TestResults\IntegrationTestsReport.html

	Write-Host $html
}