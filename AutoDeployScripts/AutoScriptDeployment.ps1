
## Create logging file
$log = Get-Location
$log = "$log\Script_Deployment_log.txt"
$date = Get-Date
"Begin deployment - $date" | Out-File $log

## Setting variables
## vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

$directory = Get-Location
$BuildID = Get-Content $directory\BuildID.txt
$Build = Get-Content $directory\BuildName.txt
$scriptpath = "$directory\Scripts"
$script = Get-ChildItem -Path $scriptpath\*.sql

## ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Log-Line "Log = $log" $log
Log-Line "BuildID = $BuildID" $log
Log-Line "Build = $Build" $log
Log-Line "Script Path = $scriptpath" $log

IF (Test-Path $scriptpath\*.sql -eq True) {

	## Returns array of systems needing updated
	$systemarr = Invoke-Sqlcmd -ServerInstance "Karmak_Internal" -Database "QA" -Query "Select SystemID from System Where BuildID = $BuildID and IsActive = 1 and IsActiveBuilds = 1"
    Try {

	## Cycles through the systems, returns the QA config data, and runs the database script for each
	IF ($systemarr.SystemID -ne $null) {

		foreach ($system in $systemarr.SystemID) {
			$vararr = Invoke-Sqlcmd -ServerInstance "Karmak_Internal" -Database "QA" -Query "Select sy.DeploymentName as 'DatabaseName', ss.ServerIP as 'SoftwareServerIP', sq.ServerIP as 'SQLServerIP', sq.SQLInstance from System sy Join SoftwareServer ss on ss.SoftwareServerID = sy.SoftwareServerID Join SQLServer sq on sq.SQLServerID = sy.SQLServerID where SystemID = $System"

		    foreach ($one in $script) {
			    If ($vararr.SQLInstance -ne '') {
                        $s = $vararr.SQLServerIP+"\"+$vararr.SQLInstance
				    Deploy-DBScript $s $vararr.DatabaseName $one
			    } Else {
    			    Deploy-DBScript $vararr.SQLServerIP $vararr.DatabaseName $one
			    }
            }
        }
		    
            Try {
		        Remove-Item $scriptpath\*.sql
		        Log-Line "Scripts deleted successfully." $log
		    }
		    Catch {
    		    Log-Line "*** ERROR DELETING SCRIPTS ***" $log
		        Log-Line $_.Exception.Message $log
		        Error-Exit
		    }
	    
        Log-Line "Finished Successfully" $log

	} ELSE {
		Log-Line "*** ERROR ***" $log
		Log-Line "No Systems Selected." $log
        Error-Exit
	}
    }
    Catch {
        Log-Line "*** ERROR ***" $log
		Log-Line $_.Exception.Message $log
        Error-Exit
    }
} ELSE {
Log-Line "No Scripts" $log
Exit
}  #  <----- End of Main

## ===============================================================================================================================

## Functions
## Logging function
Function Log-Line ($message, $logfile)
{
    Write-Host $message
    $message | Out-File $logfile -Append
}

<# Calculate Date
Function Calc-Date
{
        $date = Get-Date
        $y = $date.year 
        $mo = $date.month 
        $d = $date.day
        $h = $date.hour
        $mi = $date.minute
        $s = $date.second
}
#>


## Deploy database scripts
Function Deploy-DBScript($sqlserver, $databasename, $runscript)
{
    Try {
        Invoke-Sqlcmd -ServerInstance $sqlserver -Database $databasename -InputFile $runscript -OutputSqlErrors $true -QueryTimeout 300 -AbortOnError -Verbose
        Log-Line "Database script $runscript has been ran on $sqlserver $databasename" $log
    }
    Catch {
        Log-Line "*** ERROR DATABASE SCRIPTS FAILED ***" $log
        Log-Line $_.Exception.Message $log
        Log-Line "SQL Server = $sqlserver" $log
        Log-Line "Database Name = $databasename" $log
        Log-Line "Script = $runscript" $log
        $date = Get-Date
        $y = $date.year 
        $mo = $date.month 
        $d = $date.day
        $h = $date.hour
        $mi = $date.minute
        $s = $date.second
        ## Rename-Item -Path $runscript -NewName $Build"_Script_Failed_"$y$mo$d$h$mi$s".txt"
        Error-Exit
    }
}

## Check to see if file exists
Function Test-Path($filepath)
{
    Get-ChildItem -Path $filepath
}

## Error exit
Function Error-Exit
{
    $date = Get-Date
    $y = $date.year 
    $mo = $date.month 
    $d = $date.day
    $h = $date.hour
    $mi = $date.minute
    $s = $date.second
    Rename-Item -Path $log -NewName $Build"_Failure_"$y$mo$d$h$mi$s".log"
    Exit
}

## ===============================================================================================================================

Main