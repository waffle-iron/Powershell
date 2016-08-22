Function Log-Line ($message)
{
    $message | Out-File $log -Append
}

Function Log-Error ($message)
{
    Log-Line "***ERROR***" 
    Log-Line $message 
    Log-Line "***********" 
}