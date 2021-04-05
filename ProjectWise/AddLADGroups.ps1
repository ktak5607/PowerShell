$ErrorActionPreference = "Stop"
If(New-PWLogin -UseGui){
    $templates = Get-PWFoldersImmediateChildren -FolderPath "_Standards (Forms, Job Aids, Installs, Training)\Templates - New\LAD"
                 
    If($templates -ne $null){    
        Foreach($templ in $templates){
            $coordListBase = "_PW_LAD_ProjCoordinator"
            $teamListBase = "_PW_LAD_ProjTeam"
            $localityBase = "_PW_LAD_Locality"
            $distPrefix = ""

            If($templ.Name.Contains("Bristol")){
                $distPrefix = "BR"        
            }
            ElseIf($templ.Name.Contains("Culpeper")){
                $distPrefix = "CU"        
            }
            ElseIf($templ.Name.Contains("Fredericksburg")){

                $distPrefix = "FR"        
            }
            ElseIf($templ.Name.Contains("Hampton Roads")){
                $distPrefix = "HR"        
            }
            ElseIf($templ.Name.Contains("Lynchburg")){
                $distPrefix = "LY"        
            }
            ElseIf($templ.Name.Contains("Nova")){
                $distPrefix = "NV"        
            }
            
            ElseIf($templ.Name.Contains("Richmond")){
                $distPrefix = "RI"        
            }
            ElseIf($templ.Name.Contains("Salem")){
                $distPrefix = "SA"        
            }
            ElseIf($templ.Name.Contains("Staunton")){
                $distPrefix = "ST"        
            }
            Else{
                continue
            }

            $coordList = $distPrefix + $coordListBase
            $teamList = $distPrefix + $teamListBase
            $localityList = $distPrefix + $localityBase
            Write-Host $coordList
            Write-Host $teamList
            Write-Host $localityList
            Get-PWFoldersImmediateChildren -FolderPath ($templ.FullPath + "\Locally Administered Project") | ForEach-Object{
                Write-Host $_.Name
                ### If folders are still inheriting from the top need to add lines for PW_Admin and PW_Users
                ### If folders are still inheriting and you -IncludeInheritance inheritance won't be broken, but won't add/remove new permissions for existing groups/lists either.
                Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName $coordList  -MemberAccess ("c","d","r","w") -FolderSecurity -IncludeInheritance
                Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName $coordList  -MemberAccess ("c", "d", "r", "w", "cw", "fr", "fw", "f") -DocumentSecurity -IncludeInheritance
                
                Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName $localityList  -MemberAccess "r" -FolderSecurity
                Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName $localityList  -MemberAccess ("r", "fr") -DocumentSecurity

                Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName "PW_Admin"  -MemberAccess ("fc", "cp", "c","d","r","w") -FolderSecurity 
                Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName "PW_Admin"  -MemberAccess ("fc", "cp", "c", "d", "r", "w", "cw", "fr", "fw", "f") -DocumentSecurity
                Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName "PW_Users"  -MemberAccess "r" -FolderSecurity
                Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName "PW_Users"  -MemberAccess ("r", "fr") -DocumentSecurity



                If($_.Name -eq "00 Submittals"){
                    
                    Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName $teamList  -MemberAccess ("c","d","r","w") -FolderSecurity
                    Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName $teamList  -MemberAccess ("c", "d", "r", "w", "cw", "fr", "fw", "f") -DocumentSecurity
                    Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName "CO_PW_LAD_ProjTeam"  -MemberAccess ("c","d","r","w") -FolderSecurity
                    Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName "CO_PW_LAD_ProjTeam"  -MemberAccess ("c", "d", "r", "w", "cw", "fr", "fw", "f") -DocumentSecurity
                }
                else{
                    Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName $teamList  -MemberAccess ("r", "w") -FolderSecurity
                    Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName $teamList  -MemberAccess ("c", "d", "r", "w", "fr", "fw") -DocumentSecurity
                    Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName "CO_PW_LAD_ProjTeam"  -MemberAccess "r" -FolderSecurity
                    Update-PWFolderSecurity -InputFolder $_ -MemberType "ul" -MemberName "CO_PW_LAD_ProjTeam"  -MemberAccess ("r", "fr") -DocumentSecurity
                } 
                
            }
        
        }
    }
    Undo-PWLogin
}