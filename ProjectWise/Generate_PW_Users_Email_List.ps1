#attempt to log in to ProjectWise, if it fails exit the program
 if(New-PWLogin -UseGui) {
    Write-Output 'Successfully logged into ProjectWise datasource.'
    $outputPath = Read-Host -Prompt "Enter the folder you wish to save the file to."
    $outputFile = $outputPath + "\PW_Users.csv"
    $children = Get-ChildItem -Path $outputPath
    Foreach($child in $children){
        If($child.Name -eq "PW_Users.csv"){
            Remove-Item -Path ($outputPath + "\PW_Users.csv")
        }
    }
    Add-Content -Path $outputFile -Value ("First Name,LastName,Email")
    $userList = Get-PWUsersInUserList -UserList "PW_Users"

    Foreach($user in $userList){
        If($user.Email -ne "" -And $user.IsDisabled -eq $false){
            $names = $user.UserName.Split('.')
            Add-Content -Path $outputFile -Value ($names[0] + "," + $names[1] + "," + $user.Email + ",")
        }
        Else{
            $userNam = $user.Name
            Write-Host "WARNING! No email found for $userNam."
        }
    }
    Undo-PWLogin
} 
    else {
        Write-Output -Message 'Failed to log into ProjectWise datasource.'
        break
    }




