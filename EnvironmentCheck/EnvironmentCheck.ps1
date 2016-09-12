<#

Test to check QA environment configuration

    Test the folder paths listed in the QA database to make sure they exists

    Log all systems that are active in the database

    Log all systems that are set to receive builds in the database

#>

Function Main
{
    $folder = Get-Location
    $Global:log = "$folder\log.txt"
    $date = Get-Date
    "Log started - $date" | Out-File $log
    Log-Line ""

    Folder-Check
    Active-Check
    Active-BuildsCheck

}  # <--- END OF MAIN 





Function Folder-Check
{
    <#
        Check to see if all the folder paths in the database are valid.

        *** Must use SQL query function ***
    #>
        
        $count = "0"
        $sysIDs = Query-Database "Select SystemID from System Where IsActive = 1 and IsActiveBuilds = 1"

        ForEach($id in $sysIDs.SystemID)
        {
            $server = Query-Database "Select ServerName from SoftwareServer ss join System sy on sy.SoftwareServerID = ss.SoftwareServerID where sy.SystemID = $id"
            $servername = $server.ServerName
            $configarr = Query-Database "Select ServiceName from Service Where SystemID = $id and ServiceTypeID = 2"
            $servicename = $configarr.ServiceName
            $rptFolder = Query-Database "Select FolderPath from Folder where FolderTypeID = 2 and SystemID = $id"
            $foldername = $rptFolder.FolderPath

            If (!(Test-Path ($foldername))) 
                {
                Log-Line "Invalid folder paths"
                Log-Line "--------------------"
                Log-Line "$foldername"
                Log-Line ""
                $count++
                }
        }
        
        If ($count -eq 0)
        {
            $message = @("All folders pass! :)", "All good! :)", "Nothing to report here. :)", "Everything checked out fine. :)", "100% :)" )
            $random = Get-Random -Minimum 0 -Maximum 4
            Log-Line "Invalid folder paths"
            Log-Line "--------------------"
            Log-Line $message[$random]
            Log-Line ""
        }
        Else
        {
            Log-Line "There were $count path failures.  :("
            Log-Line ""
        }
}

Function Active-Check
{
    <#
        Check to see what systems are active and what systems are receiving builds

        *** Must use SQL query function ***
    #>
        $a = Query-Database "Select s.DeploymentName, ss.ServerName from System s JOIN SoftwareServer ss on ss.SoftwareServerID = s.SoftwareServerID where s.IsActive = 0 Order By s.DeploymentName Asc"
        Log-Line "System Not Active"
        Log-Line "-----------------"
        ForEach ($onea in $a)
        {
            $deploymentname = $onea.DeploymentName
            $servername = $onea.ServerName
            Log-Line "$deploymentname  -  $servername"
        }
        Log-Line ""

}

Function Active-BuildsCheck
{
    <#
        Check to see what systems are active and what systems are receiving builds

        *** Must use SQL query function ***
    #>
    
        $b = Query-Database "Select s.DeploymentName, ss.ServerName from System s JOIN SoftwareServer ss on ss.SoftwareServerID = s.SoftwareServerID where s.IsActiveBuilds = 0 and s.IsActive = 1 Order By s.DeploymentName Asc"
        Log-Line "Not Receiving Builds"
        Log-Line "--------------------"
        ForEach ($oneb in $b)
        {
            $deploymentname = $oneb.DeploymentName
            $servername = $oneb.ServerName
            Log-Line "$deploymentname  -  $servername"
        }
}

Function Query-Database ($q)
{
    Invoke-Sqlcmd -ServerInstance "Karmak_Internal" -Database "QA" -Query $q
}

Function Log-Line ($message)
{
    <# Make sure you define the log file variable in the Main function

    #>
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