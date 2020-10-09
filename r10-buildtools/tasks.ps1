param(
	$configuration = (property configuration "Release")
)

Enter-Build {
	try {
		$jfrogCli = (Get-Item ".\Tools\jfrogCLI\jfrog.exe").FullName
		Set-Alias -Name JFROGCLI -Value $jfrogCli
		$isBuildServer = (![String]::IsNullOrEmpty($env:BUILD_NUMBER)) -or (![String]::IsNullOrEmpty($env:GITHUB_RUN_ID))
		$buildConfig = Get-Content ..\buildConfig.json -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
		$PrerequisitesFolder = ".\Prerequisites"
		if ($isBuildServer -eq $False) {
			Set-Alias -Name MSBuild -Value (Resolve-MSBuild -Version "12.0")	
			Set-Alias -Name MSTest -Value "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"
		}else {
			Set-Alias -Name MSBuild -Value $ENV:MSBUILD
			Set-Alias -Name MSTest -Value $ENV:MSTEST
		}
	}
	catch {
		Write-Error $_
	}
}

Exit-Build {
}

task Clean {
	Set-Location "$BuildRoot\..\"
	foreach($sln in $buildConfig.solutionsToBuild.Path){
		$sln = (Get-Item $sln).FullName
		$projects = Get-SolutionProjects $sln
		foreach ($project in $projects) {
			if (Test-Path "$($project.Directory)\bin") {
				Remove-Item "$($project.Directory)\bin" -Recurse -Force -Verbose	
			}
			if (Test-Path "$($project.Directory)\obj") {
				Remove-Item "$($project.Directory)\obj" -Recurse -Force -Verbose	
			}
		}
	}
}
task GetPrerequisites -If {$buildConfig.Prerequisites} {
	Set-Location "$BuildRoot\..\"
	Get-Prerequisites
	
}

task SetAssemblyVersion -If {($isBuildServer -eq $True) -and ($ENV:BRANCH_NAME -like "release-*")} {
	Set-Location "$BuildRoot\..\"
	$MajorMinorPatch = ($ENV:BRANCH_NAME -split '-')[-1]
	$Build = $ENV:BUILD_NUMBER
	$NewVersion = "$MajorMinorPatch.$Build"
	Set-AssemblyVersion -NewVersion $NewVersion
}

task Compile {
	Set-Location "$BuildRoot\..\"
	foreach($sln in $buildConfig.solutionsToBuild.Path){
		$logFile = Split-Path $sln -leaf
		$sln = (Get-Item $sln).FullName
		Write-Host "solution: $sln"
		 exec{
		 	& MSBuild $sln /p:Configuration=$configuration /P:WarningLevel=1 /nologo /p:DebugType=None /verbosity:normal /p:SkipInvalidConfigurations=true /p:Platform="Any CPU" /nr:False /fl /flp:"logfile=.\$logFile.log;encoding=Unicode;verbosity=normal"
		 }
	}
}
task NugetRestore {
	Set-Location "$BuildRoot\..\"
	$nugetConfig = (Get-Item ".\r10-buildtools\nuget.config").FullName
	NuGet sources update -Name Artifactory -User $ENV:JFROG_USER -Pass $ENV:JFROG_ENCRYPTED_PASS -ConfigFile $nugetConfig
	foreach($sln in $buildConfig.solutionsToBuild.Path){
		$sln = (Get-Item $sln).FullName
		Write-Host "nuget restore solution: $sln"
		 exec{
		 	& nuget.exe restore $sln -ConfigFile $nugetConfig
		 }
	}
}
task PublishWebProjects {
	Set-Location "$BuildRoot\..\"
	
	foreach($webProject in $buildConfig.webProjects){
	
		$outPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("$($webProject.pathToOutput)")
		$proj = (Get-Item $webProject.webProjectPath).FullName
		$logFile = Split-Path $proj -leaf
		Write-Host "proj : $($proj)"
		Write-Host "pathToOutput:$outPath"
		Write-Host "DeployPackage: $($webProject.DeployPackage)"
		if($webProject.DeployPackage)
		{
			& MSBuild $proj /p:DeployOnBuild=True /nologo /nr:False /p:SkipInvalidConfigurations=True /p:DefaultPackageOutputDir=$outPath /p:OutputPath=".\PkgTmp" /p:Configuration=$configuration /p:Platform="Any CPU" /P:WarningLevel=1 /nr:False /fl /flp:"logfile=.\$logFile.WebProject.log;encoding=Unicode;verbosity=normal"
		}
		else {
			& MSBuild $proj /nologo /nr:False /p:SkipInvalidConfigurations=True /p:OutDir=$outPath /p:OutputPath=".\WebTmp" /p:Configuration=$configuration /p:Platform="Any CPU" /nr:False /fl /flp:"logfile=.\$logFile.WebProject.log;encoding=Unicode;verbosity=normal"
		}
	}
}
task UnitTests {
	Set-Location "$BuildRoot\..\"
	RunUnitTests
}
task TrxConvertor {
	Set-Location "$BuildRoot\..\"
	ConvertTrxToHtml
}
task Drop {
	Set-Location "$BuildRoot\..\"
	CopyVCFilesOrFoldersToDrop
	CopyLocalFoldersToBin
	CopyBuildOutputToDrop
}
task CompressArtifacts {
	Set-Location "$BuildRoot\..\"
	Remove-Item -Path .\$ENV:jfrogArtifactId.zip -ErrorAction Ignore
	foreach ($folder in $buildConfig.foldersToArchive) {
		Write-Host "copy To Artifact Folder - $($folder.Path)"
		#$fullPath = Resolve-Path -Path $folder.Path
		Compress-Archive -Path $folder.Path -DestinationPath .\$ENV:jfrogArtifactId.zip -Update
	}
}

task XmlConverter {
	Set-Location "$BuildRoot\..\"
	$dllpath = $buildConfig.ResourceConvertor.ConvertorDllPath
	Get-ChildItem -recurse $dllpath |Where-Object {($_.Extension -EQ ".dll")} | ForEach-Object { $AssemblyName=$_.FullName; Try {[Reflection.Assembly]::LoadFile($AssemblyName)} Catch{ "***ERROR*** Not .NET assembly: " + $AssemblyName}}
	New-Item -ItemType Directory -Force -Path "$BuildRoot\..\$($buildConfig.ResourceConvertor.RTIOutputPath)"
	New-Item -ItemType Directory -Force -Path "$BuildRoot\..\$($buildConfig.ResourceConvertor.ResxOutputPath)"
	if(($buildConfig.ResourceConvertor.Type) -eq "XmlToResx") {
		[Retalix.Commons.XML.Convertor.ResourceConvertor]::ConvertXmlToResx("$BuildRoot\..\$($buildConfig.ResourceConvertor.InputPath)", "$BuildRoot\..\$($buildConfig.ResourceConvertor.ResxOutputPath)", "")
	}
	elseIf(($buildConfig.ResourceConvertor.Type) -eq "ResxToRTI") {
		[Retalix.Commons.XML.Convertor.ResourceConvertor]::ConvertResxToRTIRequest($buildConfig.ResourceConvertor.Prefix, "", "$BuildRoot\..\$($buildConfig.ResourceConvertor.InputPath)", "$BuildRoot\..\$($buildConfig.ResourceConvertor.RTIOutputPath)")
	}
	elseIf(($buildConfig.ResourceConvertor.Type) -eq "All") {
		[Retalix.Commons.XML.Convertor.ResourceConvertor]::ConvertXmlToResxAndRTIRequest("$BuildRoot\..\$($buildConfig.ResourceConvertor.InputPath)", "$BuildRoot\..\$($buildConfig.ResourceConvertor.ResxOutputPath)", $buildConfig.ResourceConvertor.Prefix, "", "", "$BuildRoot\..\$($buildConfig.ResourceConvertor.RTIOutputPath)")
	}
}	

task PushJfrogMaven {
	$Script:results = Push-ZipArtifactToJfrog
	$results.status
	if (($results.status) -eq 'FAILURE') 
	{
		throw "Failed to upload to Jfrog."
	}
}
task BuildWixSource {
	Set-Location "$BuildRoot\..\"
	BuildWixSource
}
task DeveloperToolIntegration {
    Set-Location "$BuildRoot\..\"
    RunDeveloperTool -RunPhaze 1
}
task DeveloperToolUnitTest {
    Set-Location "$BuildRoot\..\"
    RunDeveloperTool -RunPhaze 2
}
task IntegrationTestSummery {
	Set-Location "$BuildRoot\..\"
	TrxMerger
}
task DigitalSignature{
	Set-Location "$BuildRoot\..\"
	$solutions = @()
	foreach($sln in $buildConfig.solutionsToBuild.Path){
		$solutions += @($sln) }
	$dllpath = ".\r10-buildtools\\Tools\\DigitalSign\\"
	Get-ChildItem -recurse $dllpath |Where-Object {($_.Extension -EQ ".dll")} | ForEach-Object { $AssemblyName=$_.FullName; Try {[Reflection.Assembly]::LoadFile($AssemblyName)} Catch{ "***ERROR*** Not .NET assembly: " + $AssemblyName}}
	$thumbprint = [DigitalSignature.CheckCertificateExistWrapper]::Check("","CN=NCR Corporation","")
	[DigitalSignature.DigitalSignatureWrapper]::Stamp("$thumbprint","C:\\Program Files (x86)\\Windows Kits\\8.1\\bin\\x64\\signtool.exe","99.99.99.99 - SNAPSHOT","","http://timestamp.verisign.com/scripts/timstamp.dll", "$BuildRoot\..\", $solutions)
}
task WhiteSourceProcess {
    Set-Location "$BuildRoot\..\"
}
task NugetPackAndPush {
	Set-Location "$BuildRoot\..\"
	NugetPackAndPush
}
task . Clean, GetPrerequisites, Compile, UnitTests
