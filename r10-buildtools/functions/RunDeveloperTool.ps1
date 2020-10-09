function RunDeveloperTool{
	param(
		[int]$RunPhaze
	)
	Write-Host "RunPhaze: $RunPhaze"
	$processIdArray = @()	
		foreach ($devTool in $buildConfig.DeveloperTool.Where({$_.RunPhaze -eq $RunPhaze})) 
		{	
			$fileToExecute= "$($devTool.FileToExecute)"
			if("$($devTool.FileToExecute)" -like "Retalix.Developer.Console.exe")
			{		
				$fileToExecute = (Get-Item "$($devTool.FileToExecute)").FullName	
			}
			$location = Get-Location
			$argsFull="$($devTool.Arguments)".replace('${WORKSPACE}',$location) 
			Write-Host "$fileToExecute $argsFull"
			$proc = Start-Process -FilePath $fileToExecute -NoNewWindow -ArgumentList $argsFull -PassThru
			$processIdArray+=$proc.id				
			foreach($procId in $processIdArray)
			{
				$proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
				if($proc)
				{	
					$proc.WaitForExit()
				}
			}
		}
}