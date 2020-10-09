
function CopyLocalFoldersToBin{

    foreach ($folder in $buildConfig.drop.CopyLocalFoldersToBin) {
        Write-Host "copyLocalFoldersToBin - from:$($folder.From) To $($folder.To)"
        #$src = "$PrerequisitesFolder\$($folder.From)"
        
        if((Get-Item $folder.From) -is [System.IO.DirectoryInfo])
        {
            ROBOCOPY $folder.From $folder.To /E
        }
        else
        {
            $from=Split-Path -Path $folder.From
            $to=Split-Path -Path $folder.target
            $fileName=Split-Path -Path $folder.From -Leaf -Resolve
            ROBOCOPY $from $to $fileName
        }
        
       
    }
    }