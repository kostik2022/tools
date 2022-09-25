# Script intend to copy files from local profile to RDS user profile disk at file server (UPD).
# Auto-create VHD from template is supported

$sourceServer = "RDS.domain.local"
$localProfilePath = "\\$sourceServer\C$\Users"
$updPath = "\\FS.domain.local\profiles$\"
# $forUseOnSourceServer = $true  #UPD being set up is for same server that local profile was on

$templateUpd = "$updPath\UVHD-template.vhdx"

#try to determine users from local profiles
$profileFolders = @(get-childitem -Path $localProfilePath -Directory | Out-GridView -Title "Select Profiles to copy to UPD" -PassThru)

foreach($folder in $profileFolders)
{
    $name= $folder.name
    #try to find user account for the name
    write-host "__________________________________________________________________"
    write-host "Profile folder $name" -ForegroundColor Cyan 
    
    $user = @(Get-ADUser -Identity $name -Properties objectSid)
    $sid = $user.objectSid
    if($sid)
    {
        $userUpd = "$updPath\UVHD-$sid.vhdx"
        #see if UPD already exists
        if(test-path $userUpd)
        {
            #upd already exists
            Write-Host "Found UPD for $name - $sid" -ForegroundColor Cyan
        }
        else {
            #UPD does not exist, copy template to new file
            Write-Host "Make UPD for $name - $sid" -ForegroundColor Cyan
            Copy-Item -Path $templateUpd -Destination $userUpd
        }
        #mount UPD for copying data
        write-host "Mount vhd for $name" -ForegroundColor Cyan
        Mount-DiskImage -ImagePath $userUpd
        #get drive letter
        $Drive = Get-Partition (Get-DiskImage -ImagePath $userUpd).Number | Get-Volume
        $drivePath = $Drive.DriveLetter + ":\"
        Write-Host ("Drive path is " + $drivePath)
        #now run robocopy from old profile path to new UPD path
        write-host "Copy $($folder.fullname) to $drivePath"
        robocopy "$($folder.fullname)" "$drivePath" /copy:datso /r:0 /mt:64 /xj /xo /fft /xd "Application Data*" "Code Cache" /s /z /nfl /ndl /njh /eta /nc /ns /np

        #dismount before continuing
        write-host "dismount vhd for $name " -ForegroundColor Cyan
        Dismount-DiskImage -ImagePath $userUpd
#        if($forUseOnSourceServer)
#        {
#            write-host "rename $($folder.fullname) folder " -ForegroundColor Cyan
#            Rename-Item -path $folder.fullname -newname ($folder.fullname + "-Copied")
#            #clear the HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\{SID} key by renaming it
#            write-host "rename ProfileList Registry Key " -ForegroundColor Cyan
#            Invoke-Command -ComputerName $sourceServer -ArgumentList $sid -ScriptBlock {  param($sid); Rename-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid" -NewName ($sid + "-OLD") }
#        }
    }
}