if(New-PWLogin -UseGui){
    #variable to use if Project Documents folder was found
    $PDExists = $false
    $Districts = "Bristol", "Culpeper", "Fredericksburg", "Hampton Roads", "Lynchburg", "Nova", "Richmond", "Salem", "Staunton"

    #start loop through all of the district folders
    foreach($dist in $Districts){
        $TemplatePath = "_Standards\Templates\000000 " +  $dist + " IPM\Project Documents"
        $TemplateFolder = Get-PWFolders -FolderPath $TemplatePath -JustOne
        $Security = Get-PWFolderSecurity -InputFolder $TemplateFolder
        $Projects = Get-PWRichProjects -FolderPath "_Projects\$dist"
        Write-Host "Got Permissions from template folder"

        #start loop through all of the projects in the district
        Write-Host "Accuqiring all of the projects in $dist"
        foreach($project in $Projects){
            $Subs = Get-PWFoldersImmediateChildren -FolderPath $project.FullPath

            #start loop through all of the subfolders in the root of the project
            Write-Host "Searching for the Project Documents folder in" $project.Name
            foreach($folder in $Subs){
                #if the folder name is _Project Documents or Project Documents set the PDExists variable to true
                if($folder.Name -eq "_Project Documents" -or $folder.Name -eq "Project Documents"){
                    $PDExists = $true
                }
            }#end loop through sub folders of project

            #if the Project Documents folder wasn't found add it and assign correct permissions
            if($PDExists -eq $false){
                $Path = $project.FullPath + "\Project Documents"
                New-PWFolder -FolderPath $Path -StorageArea "PW_DEV_Salem01" -Environment "VDOT"
                Write-Host "Folder created"

                $PDFolder = Get-PWFolders -FolderPath $Path -JustOne

                foreach($sec in $Security){
                   if($sec.Workflow.ToString() -eq ""){
                        Write-Host "Updating folder permissions for "$sec.Name
                        $secList = New-Object System.Collections.ArrayList

                        if($sec.Access_Control_Settings.Contains('F')) {
                            $secList.Add("fc")
                        }
                        if($sec.Access_Control_Settings.Contains('P')) {
                            $secList.Add("cp") 
                        }
                        if($sec.Access_Control_Settings.Contains('C')) {
                            $secList.Add("c")
                        }
                        if($sec.Access_Control_Settings.Contains('D')) {
                            $secList.Add("d")
                        }
                        if($sec.Access_Control_Settings.Contains('r')) {
                            $secList.Add("r")
                        }
                        if($sec.Access_Control_Settings.Contains('w')) {
                            $secList.Add("w") 
                        }
                        if($sec.Access_Control_Settings.Contains('S')) {
                            $secList.Add("cw")  
                        }
                        if($sec.Access_Control_Settings.Contains('R')) {
                            $secList.Add("fr")
                        }
                        if($sec.Access_Control_Settings.Contains('W')) {
                            $secList.Add("fw")
                        }
                        if($sec.Access_Control_Settings.Contains('f')) {
                            $secList.Add("f")
                        }                           
                        if($sec.Access_Control_Settings.Contains('NA')) {
                            $secList.Add("na")
                        }
                                                
                        if($sec.SecurityType.ToLower() -eq "document"){
                            Update-PWFolderSecurity -InputFolder $PDFolder -MemberType $sec.Type  -MemberAccess $secList -MemberName $sec.Name -DocumentSecurity
                        }
                        elseif($sec.SecurityType.ToLower() -eq "project"){
                            Update-PWFolderSecurity -InputFolder $PDFolder -MemberType $sec.Type  -MemberAccess $secList -MemberName $sec.Name -FolderSecurity
                        }
                    
                    }#end check to see if permissions weren't from workflow   
                }#end loop through permissions
                #get Project Documents sub folders at root
                $SubFolders = Get-PWFoldersImmediateChildren -FolderPath $TemplatePath
                    #start loop through sub folders
                    foreach($sub in $SubFolders){
                        Copy-PWFolder -FolderPath $PDFolder.FullPath -FolderToCopy $sub.FullPath -IncludeSubFolders -IncludeAccessControl
                    }#end loop through sub folders
            }#end check to see if Project Documents folder existed

            elseif($PDExists -eq $true){
                $PDExists = $false
            }#end Project Documents folder was found
        }#end loop through projects in each district
    }#end loop through districts
    Write-Host "Logging out of ProjectWise"
    Undo-PWLogin
}#end successfull login to ProjectWise
else{
    Write-Host "Failed to login to ProjectWise with the given username and password"
}#end failed to login to ProjectWise