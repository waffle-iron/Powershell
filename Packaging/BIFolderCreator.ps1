## Business Intelligence Distirbution folder creator

<#

Adam Griffith

March, 2016

ToDo:
        

#>

## =================================================================================================================================================================

Function Main
{

    ## log file creation
    $folder = Get-Location
    $Global:log = "$folder\log.txt"
    $date = Get-Date
    "Log started - $date" | Out-File $log
    
    ## define the build branch
    $count = 0
    $choices = "PM_3_Current", "PM_3_ServicePack"
    Do{
    cls
    If ($count -gt 0) {Write-Host "Please select a valid option. Failed attempts:" $count}
        $branch = Read-Host -Prompt "
        1- Current
        2- Service Pack
        Which branch are you releasing out of?"
        If ($branch -eq '1') {$branch = $choices[0]}
        If ($branch -eq '2') {$branch = $choices[1]}
        If ($branch -eq 'exit') {Exit}
    Else {$count++}
    } until ($choices -contains $branch)

    Log-Line "You have selected branch: $branch"

    ## define the build branch folder
    $build = "\\pmdevsql\Builds\$branch\*"

    ## define the distribution folder
    ## $distro = "C:\DistroTest\BI\"
    $distro = "\\fp_server\Public\Distribution\RPM\BI 3.0 Releases\"

## =================================================================================================================================================================

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

    ## define the copy from and copy to folders
    $old = "$distro$oldVersion"
    $new = "$distro$newVersion"

## =================================================================================================================================================================

    ## copy everything from the old version to the new version folder
    Try {
    Log-Line "Creating new folder" 
    Copy-Item $old\ -Destination "$new\" -Force -Recurse
    Log-Line "New folder created"
    }
    Catch {
    Error-Exit
    }

    
    ## deletes the files from the new upgrade folder
    Try {
    Log-Line "Deleting upgrade files"
    Remove-Item -Path "$new\Upgrade\*"
    Log-Line "Upgrade folder cleared" 
    }
    Catch {
    Error-Exit
    }


    ## update Upgrade folder
    Try {
    Copy-Item $build\ -Destination "$new\Upgrade\Application\" -Force -Recurse
    Log-Line "Build copied out" 
    }
    Catch {
    Error-Exit
    }
    

    ## delete zip files
    Try {
    Remove-Item -Include *.zip -Path "$new\" -Recurse
    Log-Line "Zip files deleted"
    }
    Catch {
    Error-Exit
    }


    ## update New Install folder
    Try {
    Copy-Item "$new\Upgrade\Application\" -Destination "$new\New Install\Application\" -Force -Recurse
    Log-Line "New Install updated" 
    }
    Catch {
    Error-Exit
    }


    ## zip process data folder
    Try{
    $zp = "$new\Application\ProcessData.zip"
    $sp = "$new\Application\ProcessData"
    Zip-Files $zp $sp
    Log-Line "Process Data folder zipped" 
    }
    Catch {
    Error-Exit
    }


    ## zip web folder
    Try {
    $zw = "$new\Application\Web.zip"
    $sw = "$new\Application\Web"
    Zip-Files $zw $sw
    Log-Line "Web folder zipped" 
    }
    Catch {
    Error-Exit
    }


    Get-Date | Out-File $log -Append
    Write-Host "=== BI Packaging Complete ==="


}  #  <----- End of Main

## FUNCTIONS

## Zip fuction
function Zip-Files( $zipfilename, $sourcedir )
{
   Add-Type -Assembly System.IO.Compression.FileSystem
   $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
   [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir,
        $zipfilename, $compressionLevel, $false)
}

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
    Log-Line "***ERROR***" 
    Log-Line $_.Exception.Message 
    Exit 
}


Main

