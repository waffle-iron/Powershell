## Fusion Report Writer Distirbution folder creator

<#

Adam Griffith

March, 2016

ToDo:
        

#>

## =================================================================================================================================================================

Function Main
{
	## set the log
	$folder = Get-Location
	$Global:log = "$folder\log.txt"
	$date = Get-Date
	"Log started - $date" | Out-File $log

	## define the build branch
	$count = 0
	$choices = "PM_3_Current", "PM_3_ServicePack"
	Do {
	cls
	If ($count -gt 0) {Write-Host "Please select a valid option. Failed attempts:" $count}
	$branch = Read-Host -Prompt "
		1- Current
		2- Service Pack
		Which branch are you releasing out of?"
		IF ($branch -eq '1') {$branch = $choices[0]}
		IF ($branch -eq '2') {$branch = $choices[1]}
		IF ($branch -eq 'exit') {Exit}
	Else {$count++}
	} until ($choices -contains $branch)

	Write-Host "You have selected branch: "$branch

	## define the build branch folder
	$build = "\\pmdevsql\Builds\$branch\Cumulative\Analytics\FusionSelfService\"

	## define the distribution folder
	## $distro = "C:\DistroTest\FRW\"
	$distro = "\\fp_server\Public\Distribution\FusionReportWriter\"


	## define the previous version folder
	Do{
		$oldVersion = Read-Host -Prompt "
		What is the OLD version number?"
	} until ($oldVersion -ne "" )

	## define the new version folder
	Do{
		$newVersion = Read-Host -Prompt "
		What is the NEW version number?"
	} until ($newVersion -ne "")

    ## create the new version folder
    Try {
    new-item $distro -name "$newVersion" -type directory
    }
    Catch {
    Error-Exit
    }

    ## define the copy from and copy to folders
    $old = "$distro$oldVersion\"
    $new = "$distro$newVersion\"
    
    ## create the new folder structure
    Try {
    Log-Line "Creating folders"
    new-item -path $new -name "Complete Build" -type directory
    new-item -path $new -name "Cumulative" -type directory
    new-item -path $new -name "Service Pack" -type directory
    Log-Line "Folders created"
    }
    Catch {
    Error-Exit
    }

    ## copy the complete build folder to the new version folder
    Try {
    Log-Line "Copying Complete Build"
    Copy-Item "$old\Complete Build" -Destination "$new" -Force -Recurse 
    Log-Line "Finished copying Complete Build"
    }
    Catch {
    Error-Exit
    }

    Try {
    Log-Line "Copying Cumulative"
    Copy-Item "$old\Cumulative" -Destination "$new" -Force -Recurse 
    Log-Line "Finished copying Cumulative"
    }
    Catch {
    Error-Exit
    }

    Try {
    Log-Line "Copying Service Pack"
    Copy-Item "$build\*" -Destination "$new\Service Pack" -Force -Recurse 
    Log-Line "Finished copying Service Pack"
    }
    Catch {
    Error-Exit
    }
}


}  # <----- End of Main


## FUNCTIONS

## Logging function
Function Log-Line ($message)
{
    <# Make sure you define the log file variable in the Main function
        $folder = Get-Location
        $Global:log = "$folder\log.txt"
        $date = Get-Date
        "Log started - $date" | Out-File $log
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

fuction Error-Exit
{
    Log-Line "***ERROR***" $log
    Log-Line $_.Exception.Message $log
    Exit 
}
