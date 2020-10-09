function CopyBuildOutputToDrop{
	foreach($prereq in $buildConfig.drop.CopyBuildOutputToDrop)
	{
		$Script:results = Get-Artifacts -Repo $prereq.repo -Groupid $prereq.groupid -Artifactid $prereq.artifactid -Version $prereq.buildVersion
		foreach($folder in $prereq.files)
		{
            $src = "$PrerequisitesFolder\$($folder.source)"
            Write-Host "Copy-Item :$src To $($folder.target)"
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