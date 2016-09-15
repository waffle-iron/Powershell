<#

Test to check QA environment configuration

    Log all Future systems receiving builds
    Log all Current systems receiving builds
    Log all ServicePack systems receiving builds
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

    Future-Check
    Current-Check
    SP-Check
    Active-BuildsCheck
    Active-Check

}  # <--- END OF MAIN 


Function Future-Check
{
    <#
        Check to see what systems are active and receiving Future builds

        *** Must use SQL query function ***
    #>
        $a = Query-Database "Select s.DeploymentName, ss.ServerName from System s JOIN SoftwareServer ss on ss.SoftwareServerID = s.SoftwareServerID where s.IsActive = 1 and s.BuildID = 1 and s.IsActiveBuilds = 1 Order By s.DeploymentName Asc"
        Log-Line "Future Systems"
        Log-Line "-----------------"
        ForEach ($onea in $a)
        {
            $deploymentname = $onea.DeploymentName
            $servername = $onea.ServerName
            Log-Line "$deploymentname  -  $servername"
        }
        Log-Line ""

}


Function Current-Check
{
    <#
        Check to see what systems are active and receiving Current builds

        *** Must use SQL query function ***
    #>
        $a = Query-Database "Select s.DeploymentName, ss.ServerName from System s JOIN SoftwareServer ss on ss.SoftwareServerID = s.SoftwareServerID where s.IsActive = 1 and s.BuildID = 2 and s.IsActiveBuilds = 1 Order By s.DeploymentName Asc"
        Log-Line "Current Systems"
        Log-Line "-----------------"
        ForEach ($onea in $a)
        {
            $deploymentname = $onea.DeploymentName
            $servername = $onea.ServerName
            Log-Line "$deploymentname  -  $servername"
        }
        Log-Line ""

}


Function SP-Check
{
    <#
        Check to see what systems are active and receiving ServicePack builds

        *** Must use SQL query function ***
    #>
        $a = Query-Database "Select s.DeploymentName, ss.ServerName from System s JOIN SoftwareServer ss on ss.SoftwareServerID = s.SoftwareServerID where s.IsActive = 1 and s.BuildID = 3 and s.IsActiveBuilds = 1 Order By s.DeploymentName Asc"
        Log-Line "Service Pack Systems"
        Log-Line "--------------------"
        ForEach ($onea in $a)
        {
            $deploymentname = $onea.DeploymentName
            $servername = $onea.ServerName
            Log-Line "$deploymentname  -  $servername"
        }
        Log-Line ""

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
        Log-Line ""
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