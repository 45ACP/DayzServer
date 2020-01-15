@echo off
TITLE DayZ SA Server - Status
COLOR 0A
	:: DEFINE the following variables where applicable to your install
    SET SteamCMDPath="C:\Games\SteamCMD"
    SET STEAM_WORKSHOP=C:\Games\SteamCMD\steamapps\workshop\content\221100\
    SET SteamLogin=<username> <password>
    set STEAMCMD_DEL=5
    SET DayZBranch=223350
    SET DayZGameBranch=221100
    SET DayZServerPath="C:\Games\DayzServer"
    SET BECPath=C:\Games\DayzServer\BEC
    
    set BEpath="C:\Games\DayzServer\battleye"
    set serverName="My cool Dayz server"
    set profile="C:\Games\DayzServer\ServerProfile"
    set IP=0.0.0.0
    set serverPort=2302
    set serverConfig=serverDZ.cfg
    set serverCPU=2
    set MOD_LIST=(C:\Games\DayzServer\modlist.txt)
    SET modupdate=0
    SET rconPass=<password>

    SETLOCAL EnableDelayedExpansion
	:: _______________________________________________________________

goto checkServer
pause

:: This function checks if the server is running by looking for the 'port' number in the 
:: apps 'windowtitle'. DayZServer_x64.exe automatically sets windowtitle for you.
:checkServer
for /f "tokens=2 delims=," %%a in ('
    tasklist /fi "imagename eq DayZServer_x64.exe" /v /fo:csv /nh 
    ^| findstr /r /c:"port %serverPort%"
') do goto checkBEC 
echo Server is not running, taking care of it..
goto killServer


:: This function checks if BEC is running. Here, we have manually renamed the BEC.exe file 
:: to include the port number in the filename, so we can search for it here. The BEC.exe was
:: renamed BEC2302.exe
:checkBEC
tasklist /fi "imagename eq BEC%serverPort%.exe" 2>NUL | find /i /n "BEC%serverPort%.exe">NUL
if "%ERRORLEVEL%"=="0" goto loopServer
echo Bec is not running, taking care of it..
goto startBEC


:: This function checks if DayZServer is running every 30s, and performs a game/mod update
:: check every 20 lots of 30s (ie. every ~10 mins)
:loopServer
FOR /L %%s IN (30,-1,0) DO (
	echo Server is running. Checking again in %%s seconds.. 
	timeout 1 >nul
)
IF /I %modupdate% GEQ 20 (
    SET modupdate=0
    goto checkUpdates
)
SET /A modupdate=modupdate+1
echo Modupdate incriment: %modupdate%
goto checkServer


:: This function kills the BEC and DayZServer executables if they are running.
:killServer
taskkill /f /im Bec%serverPort%.exe
rem taskkill /f /im DayZServer_x64.exe
for /f "tokens=2 delims=," %%a in ('
    tasklist /fi "imagename eq DayZServer_x64.exe" /v /fo:csv /nh 
    ^| findstr /r /c:"port %serverPort%"
') do taskkill /pid %%a
goto updateServer


:: This function checks for a game update by geting DayZServer app status and looking for the text
:: 'Update Required' in the output. It then checks for mod upates by downloading all the mods into
:: steaem workshop folder, and comparing the workshop files those in the DayZServer folder. If either
:: game update or mod update is found, it triggers server to stop and update:
:checkUpdates
SET UPDATE_REQ=0
echo Checking for game update...
cd %SteamCMDPath%
>output.txt (
    steamcmd.exe +login %SteamLogin% +force_install_dir %DayZServerPath% +"app_status %DayZBranch%" +quit 
)
FINDSTR /x /RC:".*Update Required.*" output.txt
IF !ERRORLEVEL! == 0 (
    set UPDATE_REQ=1
    echo Game Update required!
) ELSE (
    echo No game update required...
    )
echo Reading in MOD_LIST. Updating Steam Workshop mods...
set "MODS_UPDATE="
echo looping over mods list
for /f "tokens=1,2 delims=," %%g in %MOD_LIST% do (
    set "MODS_UPDATE=!MODS_UPDATE! +workshop_download_item 221100 %%g"
    )
steamcmd.exe +login %SteamLogin% !MODS_UPDATE!% +quit
echo Steam Workshop files up to date!
echo Check for mod updates...
@ for /f "tokens=1,2 delims=," %%g in %MOD_LIST% do (
    robocopy "%STEAM_WORKSHOP%\%%g" "%DayZServerPath%\%%h" *.* /mir /l 2>NUL | FINDSTR /RC:"^   Bytes : *[0-9]*[.]*[0-9]* *[a-z] *[1-9][0-9]*.*">NUL
    if !ERRORLEVEL! == 0 set UPDATE_REQ=1
    )
if !UPDATE_REQ! == 1 goto UpdateWarning
echo No Mod updates!
goto checkServer


:: This function begins a 5 min warning of server restart for an update.
:UpdateWarning
echo Server update required, beginning 5 min warning...
cd "%DayZServerPath%"
for %%t in (5 4 3 2 1) do (
    start BERCon.exe -host %IP% -port %serverPort% -pw %rconPass% -cmd "say -1 Restart in %%t mins for Server/Mod update" -cmd exit
    timeout 60 >NUL
)
goto killServer

:: This function updates the game and copies Mod files from workshop folder. Thus updating both
:: game and mods if there is any update required.
:updateServer
echo Updating DayZ server...
cd %SteamCMDPath%
steamcmd.exe +login %SteamLogin% +force_install_dir %DayZServerPath% +"app_update %DayZBranch%" +quit
echo Syncing Workshop source with server destination...
@ timeout 2 >nul
@ for /f "tokens=1,2 delims=," %%g in %MOD_LIST% do robocopy "%STEAM_WORKSHOP%\%%g" "%DayZServerPath%\%%h" *.* /mir
@ for /f "tokens=1,2 delims=," %%g in %MOD_LIST% do forfiles /p "%DayZServerPath%\%%h" /m *.bikey /s /c "cmd /c copy @path %DayZServerPath%\keys"
echo Sync complete! If sync not completed correctly, verify configuration file.
@ timeout 3 >nul
set "MODS_TO_LOAD="
for /f "tokens=1,2 delims=," %%g in %MOD_LIST% do (
    set "MODS_TO_LOAD=!MODS_TO_LOAD!%%h;"
    )
set "MODS_TO_LOAD=!MODS_TO_LOAD:~0,-1!"
ECHO Will start DayZ with the following mods: !MODS_TO_LOAD!%
goto startServer


:: This function starts DayZServer through DZSALauncher, waits 20s and forces DZSALauncher to update 
:: serverlist for the server
:startServer
echo Starting DayZ SA Server...
cd "%DayZServerPath%"
start DZSALModServer.exe -config=%serverConfig% -ip=%IP% -port=%serverPort% -cpuCount=%serverCPU% -dologs -adminlog -netlog -freezecheck -scrAllowFileWrite -profiles=%profile% -BEPath=%BEpath% "-mod=!MODS_TO_LOAD!%"
FOR /l %%s IN (20,-1,0) DO (
	echo Initializing server, wait %%s seconds to initialize BEC.. 
	timeout 1 >nul
)
:: Alter the following to your ip and query port per server config
start https://dayzsalauncher.com/#/servercheck/%IP%:27016
goto startBEC


:: This function starts BEC
:startBEC
echo Starting BEC...
timeout 1 >nul
cd "%BECPath%"
start "BEC port %serverPort%" "Bec%serverPort%.exe" -f Config.cfg --dsc
goto checkServer