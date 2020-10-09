function BuildWixSource{
	$BuildWixSource = (Get-Item ".\r10-buildtools\Tools\WixAutomationNew\BuildWixSource.exe").FullName
	$baseProductFolder = Resolve-Path -Path ".\Product"
	Set-Alias -Name BUILDWIXSOURCE -Value $BuildWixSource
	foreach ($WixAutomation in $buildConfig.Setup.ParametersForWixAutomation) 
	{	
		&BUILDWIXSOURCE /baseProjectFolder $($WixAutomation.ProjectFolder) /baseProductFolder $baseProductFolder /configFilePath $($WixAutomation.ConfigFile)
	}
	foreach ($WixProject in $buildConfig.Setup.BuildWixProjects) 
	{
		$projToBuild = (Get-Item $WixProject.ProjectToBuild).FullName
		New-Item -ItemType Directory -Force -Path ".\Install\$configuration\$($WixProject.Platform)"
		$outputPath = Resolve-Path -Path ".\Install\$configuration\$($WixProject.Platform)"
		Write-Host "baseProductFolder- $($baseProductFolder)"  	
			
		&MSBUILD "$projToBuild" /p:ProductPath="$baseProductFolder" /p:ProductCode="{$($WixProject.ProductGuid)}" /p:ProductVersion="14.0.0.8" /p:OutputPath="$outputPath" /p:cultures="en-us" /p:WixPath="C:\BuildTools\Wix\Default" /p:OutputName="$($WixProject.MsiPackageName)" /p:Configuration="$configuration" /p:Platform="$($WixProject.Platform)" /p:RunCodeAnalysis="False"
	}
	
}

    
   

