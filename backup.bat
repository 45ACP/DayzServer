@echo off
TITLE Backup: PANDEMIC GAMING AUS-2: Port 2702 - Status
	:: DEFINE the following variables where applicable to your install
    SET DayZServerPath="C:\Games\DayzServerAUSMain"
    SET destination=C:\Games\Backup
    SET "zipPath=C:\Program Files\7-Zip"
    SET "excludeFile=*.iso *.log *.ADM *.RPT *.mdmp"
    SET "excludeDir=@* dayzOffline.chernarusplus dayzOffline.enoch bliss addons"
    SETLOCAL EnableDelayedExpansion
	:: _______________________________________________________________

GOTO backupServer

:backupServer
:: Create date string for log file name
set "LocalDate=%DATE:~-4%%DATE:~-10,2%%DATE:~-7,2%"
:: Get log file name from Server folder name.
for %%f in (%DayZServerPath%) do set folder=%%~nxf

echo testing if a backup exists for today...
if EXIST "%destination%\%folder%_%LocalDate%.zip" (
    echo Backup for today exists, no backup performed.
    GOTO updateServer
)

echo Performing full server backup...
:: Copy all server files excluding log files, mod folders and unused missions.
robocopy %DayZServerPath% %destination%\temp /MIR /Z /LOG:%destination%\%folder%_%LocalDate%.log /XF %excludeFile% /XD %excludeDir%

:: Compress all files into a single backup zip
echo Zipping files to %destination%\%folder%_%LocalDate%.zip
cd %zipPath%
7z.exe a -stl -sdel -r %destination%\%folder%_%LocalDate%.zip %destination%\temp\*
echo Finished backup!
GOTO updateServer

:updateServer
PAUSE