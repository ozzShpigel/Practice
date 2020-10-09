function Push-ZipArtifactToJfrog{
    $r=Get-Location
    write-host " $r"
    $jfrogSecuritySettings = (Get-Item ".\.m2\jfrog-maven-settings-security.xml").FullName
    $Dsettings = (Get-Item ".\.m2\jfrog-maven-settings.xml").FullName
	write-host "$jfrogSecuritySettings"
	$artifact = (Get-ChildItem .. | Where-Object {($_.Extension -eq '.zip') }).fullname
    $jfrogLog = '.\push_zip_to_jfrog.log'
    write-host " $artifact"
   <#  if ($ENV:TFS_PROJECTPATH -like '*/trunk/*' )
    {
        $PushVersion = "$Script:version-SNAPSHOT"
    }
    else
    {
        $PushVersion = "$Script:version"
    }
 #>
    $PushVersion = "99.99.99.99-SNAPSHOT"
    $mvnDeployFileCommand = "mvn deploy:deploy-file '-Dsettings.security=$jfrogSecuritySettings' '-Durl=$ENV:jfrogurl' '-DrepositoryId=$ENV:jfrogRepoID' '-Dfile=$artifact' '-DgroupId=$ENV:jfrogGroupId' '-DartifactId=$ENV:jfrogArtifactId' '-Dversion=$PushVersion' '-Dpackaging=zip' '-DgeneratePom=false' '-X' '-s=$Dsettings'"
    write-host "$mvnDeployFileCommand"
    
	Invoke-Expression $mvnDeployFileCommand | Tee-Object -FilePath $jfrogLog
    write-host (Get-Content $jfrogLog)
	$status = ((Get-Content $jfrogLog | Select-String '^.*INFO.*BUILD (SUCCESS|FAILURE)$') -split(' '))[-1]

    $url = ((Get-Content $jfrogLog | Select-String 'uploaded:*' | Select-Object -First 1) -replace ('uploaded: ','') -replace ('zip.*', 'zip'))
    $file = Split-Path -Path $url -Leaf

    [pscustomobject]@{Status = $status; Url = $url; File = $file}




}
