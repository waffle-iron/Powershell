## Random positive and negative messages.

$message = @("All folders pass! :)", "All good! :)", "Perfection! :)", "No problem! :)", "100% :)" )
$random = Get-Random -Minimum 0 -Maximum 4
Log-Line $message[$random]

$message = @("Uh oh. :(", "I hope you're sitting down. :(", "Houston, we have a problem. :(", "That didn't go as planned. :(", "Bad news.. :(" )
$random = Get-Random -Minimum 0 -Maximum 4
Log-Line $message[$random]
