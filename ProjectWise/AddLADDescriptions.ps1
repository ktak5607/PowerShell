$ErrorActionPreference = "Stop"
If(New-PWLogin -UseGui){
    $templates = Get-PWFoldersImmediateChildren -FolderPath "_Standards\Templates - New\LAD"
                 
    If($templates -ne $null){    
        Foreach($templ in $templates){
            Write-Host $templ.Name
            Get-PWFoldersImmediateChildren -FolderPath $templ.FullPath | ForEach-Object{
                $_.Name
                if($_.Name -eq "00 Submittals"){
                   $desc = "All documents initially are received here before PC moves to the permanent folders below. Currently in ProjectWise this Submittals folder is called Current Drawings." 
                    Update-PWFolderNameProps -FolderPath $_.FullPath -NewDescription $desc
                }
                elseif($_.Name -eq "01 Invoices and Reimbursements"){
                    $desc = "Project Invoices, Reimbursement Requests, Closeout Financials, Special Expenditure Certifications"
                    Update-PWFolderNameProps -FolderPath $_.FullPath -NewDescription $desc
                    
                }

                 elseif($_.Name -eq "02 Agreements and Authorizations"){
                    $desc = "Applications, Signed Agreement/App-A/RTA, Phase Authorizations, PIM Docs, Audits"
                    Update-PWFolderNameProps -FolderPath $_.FullPath -NewDescription $desc

                }

                elseif($_.Name -eq "03 Consultant Award"){
                    $desc = "RFP, Consultant Award Package/Contract, Pre-Award Reviews"
                    Update-PWFolderNameProps -FolderPath $_.FullPath -NewDescription $desc

                }

                elseif($_.Name -eq "04 Project Developement and Plans"){
                    $desc = "Scoping documents, Estimates, Schedules, Right of Way, Survey, VE, Plan Reviews, All Project Plans"
                    Update-PWFolderNameProps -FolderPath $_.FullPath -NewName "04 Project Development and Plans" -NewDescription $desc

                }

                elseif($_.Name -eq "05 Civil Rights"){
                    $desc = "All Civil Rights Documents"
                    Update-PWFolderNameProps -FolderPath $_.FullPath -NewDescription $desc

                }

                elseif($_.Name -eq "06 Environmental"){
                    $desc = "All Environmental Documents (however CEDAR is the official repository for Environmental documentation)"
                    Update-PWFolderNameProps -FolderPath $_.FullPath -NewDescription $desc

                }

                elseif($_.Name -eq "07 Public Involvement"){
                    $desc = "Public Hearing AD/Transcript/Brochure"
                    Update-PWFolderNameProps -FolderPath $_.FullPath -NewDescription $desc

                }

                
                elseif($_.Name -eq "08 Advertisement and Award"){
                    $desc = "Bid documents, Signed Contract, Prequalification"
                    Update-PWFolderNameProps -FolderPath $_.FullPath -NewDescription $desc

                }

                elseif($_.Name -eq "09 Construction and Closeout"){
                    $desc = "Inspection, Materials, Change Orders, C-5 Start/End, Claims"
                    Update-PWFolderNameProps -FolderPath $_.FullPath -NewDescription $desc
                    $faPath = $_.FullPath + "\Final Acceptance"
                    $fa = Get-PWFolders -FolderPath $faPath -JustOne
                    $faDesc = "Final Acceptance (Final Punchlist, Final Inspection, Acceptances, Materials Certification,  Design Plan Changes)"
                    Update-PWFolderNameProps -FolderPath $fa.FullPath -NewDescription $faDesc
                    

                }
            }#end loop through disctrict template subfolders
            
        }#end loop through district templates
    }#end check to make sure got templates
    Undo-PWLogin
}#end login to PW check