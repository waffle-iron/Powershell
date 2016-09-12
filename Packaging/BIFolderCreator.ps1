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
$distro = "C:\DistroTest\BI\"
## $distro = "\\fp_server\Public\Distribution\RPM\BI 3.0 Releases\"

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

Try {

    Log-Line "Creating new folder" 

    ## copy everything from the old version to the new version folder
    Copy-Item $old\ -Destination "$new\" -Force -Recurse -ErrorVariable e
    Log-Line $e 

    Log-Line "New folder created" 

    ## update Upgrade folder
    Copy-Item $build\ -Destination "$new\Upgrade\Application\" -Force -Recurse -ErrorVariable e
    Log-Line $e 

    Log-Line "Build copied out" 

    ## delete zip files
    Remove-Item -Include *.zip -Path "$new\" -Recurse

    Log-Line "Zip files deleted" 

    ## update New Install folder
    Copy-Item "$new\Upgrade\Application\" -Destination "$new\New Install\Application\" -Force -Recurse -ErrorVariable e
    Log-Line $e 

    Log-Line "New Install updated" 

## ================================================================================================================================================================+

    ## zip application folder
    $za = "C:\DistroTest\2.0.0.0\Upgrade\Application.zip"
    $sa = "C:\DistroTest\2.0.0.0\Upgrade\Application\"

    Zip-Files $za $sa

    Log-Line "Application folder zipped" 

    ## zip process data folder
    $zp = "C:\DistroTest\2.0.0.0\Upgrade\Application\ProcessData.zip"
    $sp = "C:\DistroTest\2.0.0.0\Upgrade\Application\ProcessData"

    Zip-Files $zp $sp

    Log-Line "Process Data folder zipped" 

    ## zip web folder
    $zw = "C:\DistroTest\2.0.0.0\Upgrade\Application\Web.zip"
    $sw = "C:\DistroTest\2.0.0.0\Upgrade\Application\Web"

    Zip-Files $zw $sw

    Log-Line "Web folder zipped" 

    Get-Date | Out-File $log -Append

    Write-Host "=== BI Packaging Complete ==="

}
Catch {

    Error-Exit

}

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
    Error-Exit 
}


Main

