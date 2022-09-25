Write-Host -ForegroundColor yellow "#######################################################"
#########################
Write-Host -ForegroundColor Green "SECTION 1: Getting the list of users"
# Write Information to the screen
Write-Host -ForegroundColor yellow "Exporting the list of users to c:\users\%username%\users.csv"
# List the users in c:\users and export to the local profile for calling later
dir C:\Users | select Name | Export-Csv -Path C:\Windows\Temp\users.csv -NoTypeInformation
$list=Test-Path C:\Windows\Temp\users.csv
Write-Host -ForegroundColor Green "SECTION 2: Clearing caches..."
if ($list) {
    Write-Host -ForegroundColor cyan
    Import-CSV -Path C:\Windows\Temp\users.csv -Header Name | foreach {
        #Clear Mozilla Firefox Cache
        Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\* -Recurse -Force -EA SilentlyContinue
        Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\*.* -Recurse -Force -EA SilentlyContinue
	    Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\*.* -Recurse -Force -EA SilentlyContinue
        Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\* -Recurse -Force -EA SilentlyContinue
#        Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cookies.sqlite -Recurse -Force -EA SilentlyContinue
#        Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\webappsstore.sqlite -Recurse -Force -EA SilentlyContinue
#        Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\chromeappsstore.sqlite -Recurse -Force -EA SilentlyContinue

        # Clear Google Chrome 
        Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue
        Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue
#        Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cookies" -Recurse -Force -EA SilentlyContinue
        Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -EA SilentlyContinue
#        Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -EA SilentlyContinue
        # Comment out the following line to remove the Chrome Write Font Cache too.
        # Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\ChromeDWriteFontCache" -Recurse -Force -EA SilentlyContinue
        
        # Clear Internet Explorer
        Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -EA SilentlyContinue
        Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\WER\*" -Recurse -Force -EA SilentlyContinue
	    Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Temp\*" -Recurse -Force -EA SilentlyContinue
		

		# Clear Telegram cache (only files more than 30 days old)
		if (Test-Path -Path "C:\Users\$($_.Name)\AppData\Roaming\Telegram Desktop\tdata\user_data\cache") {
			Get-ChildItem -Path  "C:\Users\$($_.Name)\AppData\Roaming\Telegram Desktop\tdata\user_data\cache" -Recurse | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Recurse -Force -EA SilentlyContinue
			Get-ChildItem -Path  "C:\Users\$($_.Name)\AppData\Roaming\Telegram Desktop\tdata\user_data\media_cache" -Recurse | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Recurse -Force -EA SilentlyContinue
		}
		
		# Clear Viber cache (only files more than 30 days old)
		if (Test-Path -Path "C:\Users\$($_.Name)\Documents\ViberDownloads") {
			Get-ChildItem -Path  "C:\Users\$($_.Name)\Documents\ViberDownloads" -Recurse | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Recurse -Force -EA SilentlyContinue
		}
    }

    # Clear Windows caches
    Remove-Item -path "C:\Windows\Temp\*" -Recurse -Force -EA SilentlyContinue
    Remove-Item -path "C:\`$recycle.bin\" -Recurse -Force -EA SilentlyContinue
	
	# Remove temporary M$ office files
	Get-ChildItem -Path "C:\Users" -Recurse -Hidden -EA SilentlyContinue | where{$_.Name -like "~*"} | Remove-Item -Force -EA SilentlyContinue 

    Write-Host -ForegroundColor yellow "Done..."
} else {
   	Write-Host -ForegroundColor Yellow "Session Cancelled"	
    Exit
}