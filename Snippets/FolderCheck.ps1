Function Main
{
    $folder = Get-Location
    $Global:log = "$folder\log.txt"
    $date = Get-Date
    "Log started - $date" | Out-File $log
    Log-Line ""

    Folder-Check
}

Function Folder-Check
{
    <#
        Check to see if all the folder paths in the database are valid.

        *** Must use SQL query function ***
    #>
        
        $count = 0
        $sysIDs = Query-Database "Select SystemID from System Where IsActive = 1 and IsActiveBuilds = 1"

        ForEach($id in $sysIDs.SystemID)
        {
            $server = Query-Database "Select ServerName from SoftwareServer ss join System sy on sy.SoftwareServerID = ss.SoftwareServerID where sy.SystemID = $id"
            $servername = $server.ServerName
            $configarr = Query-Database "Select ServiceName from Service Where SystemID = $id and ServiceTypeID = 2"
            $servicename = $configarr.ServiceName
            $rptFolder = Query-Database "Select FolderPath from Folder where SystemID = $id"
            $foldername = $rptFolder.FolderPath
            
            ForEach ($folder in $foldername)
            {
                If (!(Test-Path ($folder))) 
                {
                    If ($count -eq 0)
                    {
                        Log-Line "Invalid folder paths"
                        Log-Line "--------------------"
                        Log-Line "$folder"
                        Log-Line ""
                        $count++
                    }
                    Else
                    {
                        Log-Line "$folder"
                        Log-Line ""
                        $count++
                    }
                }
            }
            
        }
        
        If ($count -eq 0)
        {
            $message = @("All folders pass! :)", "All good! :)", "Perfection! :)", "No problemo! :)", "100% :)" )
            $random = Get-Random -Minimum 0 -Maximum 4
            Log-Line $message[$random]
            Log-Line ""
        }
        Else
        {
            $message = @("Uh oh. :(", "I hope you're sitting down. :(", "Houston, we have a problem. :(", "That didn't go as planned. :(", "Bad news.. :(" )
            $random = Get-Random -Minimum 0 -Maximum 4
            Log-Line $message[$random]
            Log-Line "There were $count path failures."
            Log-Line ""
        }
}

Function Query-Database ($q)
{
    Invoke-Sqlcmd -ServerInstance "Karmak_Internal" -Database "QA" -Query $q
}

Function Log-Line ($message)
{
    ## Make sure you define the log file variable in the Main function
    
    $message | Out-File $log -Append
}

Function Log-Error ($message)
{
    ## This function is dependent on the Log-Line function
    Log-Line "***ERROR***" 
    Log-Line $message 
    Log-Line "***********" 
}

Main