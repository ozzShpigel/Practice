function  Get-Prerequisites{
    foreach($prereq in $buildConfig.Prerequisites)
	{
		$Script:results = Get-Artifacts -Repo $prereq.repo -Groupid $prereq.groupid -Artifactid $prereq.artifactid -Version $prereq.buildVersion
		foreach($folder in $prereq.files)
		{
			
			Write-Host "Copy-Item :$($folder.source) To $($folder.target)"
            $src = "$PrerequisitesFolder\$($folder.source)"
            if((Get-Item $src) -is [System.IO.DirectoryInfo])
            {
              
                ROBOCOPY $src $folder.target /E
            }
            else
            {
                $from=Split-Path -Path $src
                $to=Split-Path -Path $folder.target
                $fileName=Split-Path -Path $src -Leaf -Resolve
                ROBOCOPY $from $to $fileName
            }
			
		}
		Remove-Item -Path $PrerequisitesFolder\* -Recurse -Exclude *.zip
	
	}
}