<#

    Check to see if all the folder paths in the database are valid.

    *** Must use SQL query function ***
    
    Function Query-Database ($q)
    {
        Invoke-Sqlcmd -ServerInstance "Karmak_Internal" -Database "QA" -Query $q
    }


#>

        $sysIDs = Query-Database "Select SystemID from System Where IsActive = 1 and IsActiveBuilds = 1"

        ForEach($id in $sysIDs.SystemID)
        {
            $server = Query-Database "Select ServerName from SoftwareServer ss join System sy on sy.SoftwareServerID = ss.SoftwareServerID where sy.SystemID = $id"
            $servername = $server.ServerName
            $configarr = Query-Database "Select ServiceName from Service Where SystemID = $id and ServiceTypeID = 2"
            $servicename = $configarr.ServiceName
            $rptFolder = Query-Database "Select FolderPath from Folder where FolderTypeID = 2 and SystemID = $id"
            $foldername = $rptFolder.FolderPath

            If (!(Test-Path ($foldername))) {Write-Host "Invalid folder path: *** $foldername ***"}

        }