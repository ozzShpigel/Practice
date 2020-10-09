function Get-SolutionProjects{
	Param(
		$sln
	)

	try {
		
		$MSBuildDir = Resolve-MSBuild | Split-Path -Parent
		$MSBuildDllPath = ($MSBuildDir | Join-Path -ChildPath 'Microsoft.Build.dll')
		Add-Type -Path $MSBuildDllPath
		$solution = [Microsoft.Build.Construction.SolutionFile] $sln
	
	
		return $solution.ProjectsInOrder | 
			Where-Object {$_.ProjectType -eq 'KnownToBeMSBuildFormat'} |
			ForEach-Object {
			$isWebProject = (Select-String -pattern "<UseIISExpress>.+</UseIISExpress>" -path $_.AbsolutePath) -ne $null
			$isTestProject = ($_.ProjectName -like '*Tests*' ) 
			@{
				Path = $_.AbsolutePath;
				Name = $_.ProjectName;
				Directory = "$(Split-Path -Path $_.AbsolutePath -Resolve)";
				IsWebProject = $isWebProject;
				PackageId = $_.ProjectName -replace "\.", "-";
				IsTestProject  = $isTestProject;
			}
		}	

	}
	catch {
		throw $Error[0]	
	}


}