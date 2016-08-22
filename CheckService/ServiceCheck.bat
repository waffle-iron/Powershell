@echo off
E:
CD E:\Scripts\ServiceCheck
Powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'E:\Scripts\ServiceCheck\ServiceCheck.ps1'"