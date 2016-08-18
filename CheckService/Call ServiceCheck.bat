@echo off
schtasks /run /s qaserver5 /tn ServiceCheck
Powershell Start-Sleep -s 30
Start \\qaserver5\Scripts\ServiceCheck\log.txt