function CopyVCFilesOrFoldersToDrop{

    foreach ($folder in $buildConfig.drop.CopyVCFilesOrFoldersToDrop) {
      
        if((Get-Item $folder.From) -is [System.IO.DirectoryInfo])
        {
            Write-Host "Copy Directory - From: $($folder.From) To $($folder.From)"
            ROBOCOPY $folder.From $folder.To /E
        }
        else
        {
            Write-Host "Copy File - From: $($folder.From) To $($folder.From)"
            $from=Split-Path -Path $folder.From
            $to=Split-Path -Path $folder.To
            $fileName=Split-Path -Path $folder.From -Leaf -Resolve
            ROBOCOPY $from $to $fileName
           
        }
       
    }
}