####################################################################################################################################################################################
####################################################################################################################################################################################
#
#  Name                     : Set_Consultant_Permissions_DEV_v1.ps1
#  Type                     : Script
#  Purpose                  : Set consultant access permssions for projects
#  Author                   : Kevin Takala
#  Creation Date            : 1/10/2019
#  Modified By              :
#  Modified Date            :
#  Script Version           : 2.1.0
#  PowerShell Version       : 5.1.16299.820
#  ProjectWise Version      : 10.00.03.140
#  PWPS Module Version      : 10.0.2.1
#  PWPS_DAB Module Version  : 1.8.0.0
#
#  Requirements:
#  - Ability to log into a ProjectWise Datasource with Administrative privileges.
#  - pwps_dab module version 1.20.0.0
#
####################################################################################################################################################################################
##
##  Description/Notes:
##  -
##  - This script sets the permissions for consutants for multiple folders 
##  - The consultant will automatically get read access to the Current Drawings, Archive, and all Project Design subfolders
##    if any folders are checked for write access
##  - If read access is checked they only get read access to the selected folders.
##  - The script will automatically add read only access for the consultant for the project folder, and the Project Design folder for projects created with the new template
##  -
##  Update Notes
##  -
##  - Added functionality to give read access to all folders that aren't checked if write box is checked
##  - Added some error handling
##  - Fixed permissions so that folder and document permissions are added seperately
##  - Chage to GUI ProjectWise Login
##  - Only get immediate child folders for old projects
##  -Fixed bug so won't break inheritance on Project Design folder
####################################################################################################################################################################################

#list of global variables that will be used throughout the project
param(
    $global:dFolder,
    $global:bFolder,
    $global:eFolder,
    $global:hFolder,
    $global:lFolder,
    $global:mFolder,
    $global:rFolder,
    $global:sFolder,
    $global:tFolder,
    $global:uFolder,
    $global:archFolder,
    $global:cdFolder,
    $global:prpslFolder,
    $global:pdFolder,
    $global:Project,
    [string]$global:TempType = "Orig"
)

BEGIN{
#import the WPF framework to create the GUI
Add-Type -AssemblyName PresentationFramework

#This function sets all of the permissions for the selected folders
function ClearVars(){
    Clear-Variable *Folder -Scope Global
    Clear-Variable -Name "Project" -Scope Global
}
function SetPermissions(){
  
   #give consultant read access to the main projet folder
   Update-PWFolderSecurity -InputFolder $Project -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess "r" -FolderSecurity -IncludeInheritance 
   Update-PWFolderSecurity -InputFolder $Project -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess ("r","fr") -DocumentSecurity -IncludeInheritance 
   #give read access to project documents folder if the new template type was used
   If(($global:TempType -eq "New") -and ($Project.FullPath.Contains("Nova"))){
      Update-PWFolderSecurity -InputFolder $global:pdFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess "r" -FolderSecurity -IncludeInheritance  
      Update-PWFolderSecurity -InputFolder $global:pdFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess ("r", "fr") -DocumentSecurity -IncludeInheritance  
   }

   #list used to store access flags (see documentation for Update-PWFolderSecurity for flag meanings)
   $prjAccess = @()
   $docAccess = @()  
   #if write access is checked give read access to all folders by defualt and check for write access later
   If($WrtBtn.IsChecked){
    #put access rights flags for write permissions into access list
    $prjAccess = @("r", "w")
    $docAccess = @("c", "d", "r", "w", "cw", "fr", "fw")
    #list of folders and names, names are used for error handling
    $folders = @($global:dFolder, "design"), @($global:bFolder, "bridge"), @($global:eFolder, "environmental"), @($global:hFolder, "hydraulics"), @($global:lFolder, "landscape"),
        @($global:mFolder, "materials"), @($global:rFolder, "right of way"), @($global:sFolder, "survey"), @($global:tFolder, "traffic"), @($global:uFolder, "utilities"), 
        @($global:archFolder, "archive"), @($global:cdFolder, "current drawings"), @($global:prpslFolder, "proposal")
    #loop through folders to setup read access to all
    For($f = 0; $f -lt $folders.Count; $f += 1){
        
        if($folders[$f][0] -ne $null){
            Update-PWFolderSecurity -InputFolder $folders[$f][0] -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess "r" -FolderSecurity -IncludeInheritance
            Update-PWFolderSecurity -InputFolder $folders[$f][0] -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess ("r", "fr") -DocumentSecurity -IncludeInheritance
        }#end folder existed
        else{
            $foldername = $folders[$f][1]
            Write-Host "The $foldername doesn't exist so read access won't be added."
        }
        
    }#end loop through folders to give read access
   }#end WrtBtn checked

   ElseIf($RdBtn.IsChecked){
    #put access rights flags for read permissions into access list
    $prjAccess = @("r")
    $docAccess = @("r", "fr")
    if($global:prpslFolder -ne $null){
        Update-PWFolderSecurity -InputFolder $global:prpslFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess "r" -FolderSecurity -IncludeInheritance 
        Update-PWFolderSecurity -InputFolder $global:prpslFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess ("r", "fr") -DocumentSecurity -IncludeInheritance 
    }
   }#end RdBtn checked

   #variable for catching problems setting final permissions
   $errorFolder = ""
   #loop through all of the folder check boxes in the window
    Foreach($c in $FldrPnl.Children){
        #see if box is checked, if it is add permissions for that folder
        If($c.IsChecked){
            try{
                If($c.Name -eq "RdWyChk"){
                    $errorFolder = "design folder"
                    Update-PWFolderSecurity -InputFolder $global:dFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:dFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end design
                ElseIf($c.Name -eq "BrdgChk"){
                    $errorFolder = "bridge folder"
                    Update-PWFolderSecurity -InputFolder $global:bFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:bFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end bridge
                ElseIf($c.Name -eq "EnvChk"){
                    $errorFolder = "environmental folder"
                    Update-PWFolderSecurity -InputFolder $global:eFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:eFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end environmental
                ElseIf($c.Name -eq "HydroChk"){
                    $errorFolder = "hydraulics folder"
                    Update-PWFolderSecurity -InputFolder $global:hFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:hFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end hydraulics
                ElseIf($c.Name -eq "LndscpChk"){
                    $errorFolder = "landscape folder"
                    Update-PWFolderSecurity -InputFolder $global:lFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:lFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end landscape
                ElseIf($c.Name -eq "MtrlsChk"){
                    $errorFolder = "materials folder"
                    Update-PWFolderSecurity -InputFolder $global:mFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:mFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end materials
                ElseIf($c.Name -eq "RowChk"){
                    $errorFolder = "right of way folder"
                    Update-PWFolderSecurity -InputFolder $global:rFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:rFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end right of way
                ElseIf($c.Name -eq "SrvChk"){
                    $errorFolder = "survey folder"
                    Update-PWFolderSecurity -InputFolder $global:sFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:sFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end survey
                ElseIf($c.Name -eq "TrafChk"){
                    $errorFolder = "traffic folder"
                    Update-PWFolderSecurity -InputFolder $global:tFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:tFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end traffic
                ElseIf($c.Name -eq "UtlChk"){
                    $errorFolder = "utility folder" 
                    Update-PWFolderSecurity -InputFolder $global:uFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:uFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end utilities
                ElseIf($c.Name -eq "ArchChk"){
                    $errorFolder = "archive folder"
                    Update-PWFolderSecurity -InputFolder $global:archFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:archFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end archive
                ElseIf($c.Name -eq "CDChk"){
                    $errorFolder = "current drawings folder"
                    Update-PWFolderSecurity -InputFolder $global:cdFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $prjAccess -FolderSecurity -IncludeInheritance
                    Update-PWFolderSecurity -InputFolder $global:cdFolder -MemberType "g" -MemberName $CnsltLst.SelectedItem -MemberAccess $docAccess -DocumentSecurity -IncludeInheritance
                }#end current drawings

            }#end try
            catch{
                Write-Host "Error setting permissions for $errorFolder."
            }#end catch
        }#end box checked check
    }#end foreach loop through folder check boxes
    ClearVars
    Write-Host "Complete"
}#end SetPermissions function

#This functions finds the folders for the project and assigns them to the correct global variable above
function SetFolders(){
    #set the folders to the correct global variable above if the original project template was used
    If($global:TempType -eq "Orig"){
        #gets all of the subfolders in a project or folder
        $Folders = Get-PWFoldersImmediateChildren -FolderPath $global:Project.FullPath
        Foreach($folder in $Folders){
            If($folder.Name -eq "d" + $Project.Name){
                $global:dFolder = $folder
            }#end was d folder
            ElseIf($folder.Name -eq "b" + $Project.Name){
                $global:bFolder = $folder
            }#end was b folder
            ElseIf($folder.Name -eq "e" + $Project.Name){
                $global:eFolder = $folder
            }#end was e folder
            ElseIf($folder.Name -eq "h" + $Project.Name){
                $global:hFolder = $folder
            }#end was h folder
            ElseIf($folder.Name -eq "l" + $Project.Name){
                $global:lFolder = $folder
            }#end was l folder
            ElseIf($folder.Name -eq "m" + $Project.Name){
                $global:mFolder = $folder
            }#end was m folder
            ElseIf($folder.Name -eq "r" + $Project.Name){
                $global:rFolder = $folder
            }#end was rw folder
            ElseIf($folder.Name -eq "s" + $Project.Name){
                $global:sFolder = $folder
            }#end was s folder
            ElseIf($folder.Name -eq "t" + $Project.Name){
                $global:tFolder = $folder
            }#end was t folder
            ElseIf($folder.Name -eq "u" + $Project.Name){
                $global:uFolder = $folder
            }#end was u folder
            ElseIf($folder.Name -eq "_Archive"){
                $global:archFolder = $folder
            }#end was archive folder
            ElseIf($folder.Name -eq "_Current Drawings"){
                $global:cdFolder = $folder
            }#end was current drawings folder
            ElseIf($folder.Name -eq "_Proposal"){
                $global:prpslFolder = $folder
            }#end was proposal folder
        }#end foreach loop through folders in project
    }#end original template folders

    #set the folders to the correct global variable above if the original project template was used
    ElseIf($global:TempType -eq "New"){
        $Folders = Get-PWFolders -FolderPath $global:Project.FullPath
        ForEach($folder in $Folders){
            $f = Get-PWFolderPathAndProperties -InputFolder $folder
            If($folder.Name -eq "Roadway" -And $f.FullPath.Contains("Project Design")){
                $global:dFolder = $folder
            }#end roadway folder
            ElseIf($folder.Name -eq "Bridge" -And $f.FullPath.Contains("Project Design")){
                $global:bFolder = $folder
            }#end bridge folder
            ElseIf($folder.Name -eq "Environmental" -And $f.FullPath.Contains("Project Design")){
                $global:eFolder = $folder
            }#end environmental folder
            ElseIf($folder.Name -eq "Hydraulics" -And $f.FullPath.Contains("Project Design")){
                $global:hFolder = $folder
            }#end hydraulics folder
            ElseIf($folder.Name -eq "Landscape" -And $f.FullPath.Contains("Project Design")){
                $global:lFolder = $folder
            }#end landscape folder
            ElseIf($folder.Name -eq "Materials" -And $f.FullPath.Contains("Project Design")){
                $global:mFolder = $folder
            }#end materials folder
            ElseIf($folder.Name -eq "Right of Way" -And $f.FullPath.Contains("Project Design")){
                $global:rFolder = $folder
            }#end row folder
            ElseIf($folder.Name -eq "Survey" -And $f.FullPath.Contains("Project Design")){
                $global:sFolder = $folder
            }#end survey folder
            ElseIf($folder.Name -eq "Traffic" -And $f.FullPath.Contains("Project Design")){
                $global:tFolder = $folder
            }#end traffic folder
            ElseIf($folder.Name -eq "Utilities" -And $f.FullPath.Contains("Project Design")){
                $global:uFolder = $folder
            }#end utilities folder
            ElseIf($folder.Name -eq "Current Drawings"){
                $global:cdFolder = $folder
            }#end current drawings folder
            ElseIf($folder.Name -eq "Archive"){
                $global:archFolder = $folder
            }#end archive folder
            ElseIf($folder.Name -eq "Project Design"){
                $global:pdFolder = $folder
            }#end Project Design folder
        }#end foreach loop through project folders
   }#end new template folders
}#end SetFolders function

#function called when the OK button is clicked
function Ok_Click(){
   SetFolders
   SetPermissions
}#end Ok_Click function


#function called when the browse button is clicked
function Browse_Click(){
    #store the project in a global variable for later
    $global:Project = Show-PWFolderBrowserDialog
    #displays the UPC number in the text box on the window
    $ProjectBox.Text = $global:Project.Name

    #get all of the subfolders in the project and loop through them looking for the project design folder
    #if the project design folder exists the new template was used to create the project so set the TempType to New
    $Folders = Get-PWFolders -FolderPath $global:Project.FullPath
    Foreach($folder in $Folders){
        If($folder.Name -eq "Project Design"){
            $global:TempType = "New"
            break
        }#end if Name is Project Design
        Else{
            $global:TempType = "Orig"
        }
    }#end foreach
}#end Browse_Click function

#attempt to log in to ProjectWise, if it fails exit the program
 if(New-PWLogin -UseGui) {
        Write-Output 'Successfully logged into ProjectWise datasource.'
    } 
    else {
        Write-Output -Message 'Failed to log into ProjectWise datasource.'
        break
    }

#code to create and layout the GUI window
[xml] $xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        Title="MainWindow" Height="462" Width="525">
 <Grid x:Name = "Grid">
        <Grid.RowDefinitions>
            <RowDefinition Height="50"/>
            <RowDefinition Height = "2*"/>
            <RowDefinition Height = "45"/>
            <RowDefinition Height = "*"/>
            <RowDefinition Height = "*"/>
        </Grid.RowDefinitions>
        <Label Content="Project" Grid.Row="0" Height="25" Margin="134,17,328,8"/>
        <TextBox x:Name="ProjBox" Grid.Row="0" Height="25" VerticalAlignment="Top" Margin="205,17,206,0" IsEnabled="False"/>
        <Button x:Name="BrwsBtn" Content="..." HorizontalAlignment="Left" Margin="330,20,0,0" VerticalAlignment="Top" Width="20" Height="20" RenderTransformOrigin="0.834,0.411"/>
        <ListBox x:Name="CnsltLst" Grid.Row="1" HorizontalAlignment="Center" VerticalAlignment="Center" Height="100" Width="300"/>
        <StackPanel x:Name="StckPnl" Grid.Row="2" Orientation="Horizontal" Margin="0,0,0,0">
            <RadioButton x:Name="WrtBtn" Content="Write" HorizontalAlignment="Center" Margin="175,5,0,0"></RadioButton>
            <RadioButton x:Name="RdBtn" Content="Read" HorizontalAlignment="Center" Margin="50,5,0,0"></RadioButton>
        </StackPanel>
        <WrapPanel x:Name="FldrPnl" Grid.Row="3">
            <CheckBox x:Name="RdWyChk" Content="Roadway/Design" Margin="10,0,0,0"></CheckBox>
            <CheckBox x:Name="BrdgChk" Content="Bridge" Margin="15,0,0,0"></CheckBox>
            <CheckBox x:Name="EnvChk" Content="Environmental" Margin="15,0,0,0"></CheckBox>
            <CheckBox x:Name="HydroChk" Content="Hydraulics" Margin="15,0,0,0"></CheckBox>
            <CheckBox x:Name="LndscpChk" Content="Landscape" Margin="15,0,0,0"></CheckBox>
            <CheckBox x:Name="MtrlsChk" Content="Materials" Margin="10,15,0,0"></CheckBox>
            <CheckBox x:Name="RowChk" Content="Right of Way" Margin="15,15,0,0"></CheckBox>
            <CheckBox x:Name="SrvChk" Content="Survey" Margin="15,15,0,0"></CheckBox>
            <CheckBox x:Name="TrafChk" Content="Traffic" Margin="15,15,0,0"></CheckBox>
            <CheckBox x:Name="UtlChk" Content="Utilities" Margin="15,15,0,0"></CheckBox>
            <CheckBox x:Name="ArchChk" Content="Archive" Margin="15,15,0,0"/>
            <CheckBox x:Name="CDChk" Content="Current Drawings" Margin="10,15,5,0"/>
        </WrapPanel>
        <StackPanel Grid.Row="4" Orientation="Horizontal" >
            <Button x:Name="OKBttn" Content="OK"  Height="30" Width="70" Margin="170,0,0,0"/>
            <Button x:Name="ClsBttn" Content="Close" Height="30" Width="70" Margin="10,0,0,0"/>
        </StackPanel>
    </Grid>
</Window>
"@ #end code to setup the window

    #create reader object to read the xaml used to create the window
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    #load the window
    $Window = [Windows.Markup.XamlReader]::Load($reader)

    #link the OK button to a variable
    $OkButton = $Window.FindName("OKBttn")
    #link the OK button to a function for when it is clicked
    $OkButton.Add_Click({Ok_Click})

    $ClsButton = $Window.FindName("ClsBttn")
    $ClsButton.Add_Click({$Window.Close()})

    $ProjectBox = $Window.FindName("ProjBox")

    $Browse = $Window.FindName("BrwsBtn")
    $Browse.Add_Click({Browse_Click})

    $FldrPnl = $Window.FindName("FldrPnl")

    #get all of the consultants/contractors in ProjectWise
    $Consultants = Get-PWGroupNames
    $CnsltLst = $Window.FindName("CnsltLst")

    #loop through all of the consultants/contractors and put them in the listbox in the window
    Foreach($consultant in $Consultants){
        $CnsltLst.Items.Add($consultant) > $null
    }

    $WrtBtn = $Window.FindName("WrtBtn")
    $RdBtn = $Window.FindName("RdBtn")

    #display the window
    $Window.ShowDialog()
}#end BEGIN


END{
    Write-Output 'Logging out of ProjectWise.'
    #log out of ProjectWise when done
    Undo-PWLogin
}
