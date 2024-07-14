@echo off

:: ¼ì²é½Å±¾ÊÇ·ñÒÔ¹ÜÀíÔ±È¨ÏŞÔËĞĞ
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)
set PATH=%~dp0mysql\bin;%path%
:: Your commands go here
echo ´Ë½Å±¾ÕıÔÚÒÔ¹ÜÀíÔ±È¨ÏŞÔËĞĞ¡£
echo.
setlocal enabledelayedexpansion

:: ¶¨ÒåÑÕÉ«ºÍÑùÊ½µÄANSI×ªÒåĞòÁĞ
set "RESET=[0m"
set "BOLD=[1m"
set "UNDERLINE=[4m"
set "BLINK=[5m"
set "REVERSE=[7m"
set "HIDDEN=[8m"

set "BLACK=[30m"
set "RED=[31m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "MAGENTA=[35m"
set "CYAN=[36m"
set "WHITE=[37m"

:: Your existing code here
REM echo ¹ş¹ş¹ş¹şÎÒÊÇµÚÒ»ÅÅ
goto :checkini

:checkini
:: ¶¨Òå ini ÎÄ¼şÂ·¾¶
set ini_file=%~dp0mysql\my.ini

:: ¼ì²éÊÇ·ñ´æÔÚ my.ini ÎÄ¼ş
if exist "%ini_file%" (
    echo my.ini ÎÄ¼ş´æÔÚ£¬¼ÌĞøÖ´ĞĞ...
    goto :checkmysql
) else (
    echo my.ini ÎÄ¼ş²»´æÔÚ£¬Çë¼ì²éÏÂÔØµÄÎÄ¼şÍêÕûĞÔ¡£
	pause
    goto :end
)

:checkmysql
:: »ñÈ¡µ±Ç°Åú´¦ÀíÎÄ¼şËùÔÚµÄÄ¿Â¼
set current_path=%~dp0

:: ½«Â·¾¶ÖĞµÄ·´Ğ±¸Ü \ Ìæ»»ÎªĞ±¸Ü /
set "current_path_slash=!current_path:\=/!"

:: »ñÈ¡ basedir ºÍ datadir µÄÂ·¾¶
set basedir_path=!current_path_slash!mysql
set datadir_path=!current_path_slash!mysql/data

:: ¶¨Òå ini ÎÄ¼şÂ·¾¶
set ini_file=%~dp0mysql\my.ini

:: ¶ÁÈ¡ ini ÎÄ¼ş²¢¼ì²é basedir ºÍ datadir µÄÖµ
set ini_basedir=
set ini_datadir=

for /f "tokens=1* delims==" %%i in ('findstr /b /c:"basedir" /c:"datadir" "!ini_file!"') do (
    if "%%i"=="basedir" (
        set "ini_basedir=%%j"
    )
    if "%%i"=="datadir" (
        set "ini_datadir=%%j"
    )
)

:: È¥³ı¶ÁÈ¡ÖµÁ½¶ËµÄÒıºÅºÍ¿Õ¸ñ
set "ini_basedir=!ini_basedir:"=!"
set "ini_datadir=!ini_datadir:"=!"
set "ini_basedir=!ini_basedir: =!"
set "ini_datadir=!ini_datadir: =!"

:: ¼ì²éÂ·¾¶ÊÇ·ñÆ¥Åä
set match=1

:: ±È½Ï ini_basedir ºÍ basedir_path
for /l %%i in (0,1,255) do (
    set c1=!ini_basedir:~%%i,1!
    set c2=!basedir_path:~%%i,1!
    if "!c1!" neq "!c2!" (
        set match=0
        goto :break_loop
    )
    if "!c1!"=="" if "!c2!"=="" goto :break_loop
)

:break_loop
if !match! neq 1 goto :update_ini

set match=1

:: ±È½Ï ini_datadir ºÍ datadir_path
for /l %%i in (0,1,255) do (
    set c1=!ini_datadir:~%%i,1!
    set c2=!datadir_path:~%%i,1!
    if "!c1!" neq "!c2!" (
        set match=0
        goto :break_loop2
    )
    if "!c1!"=="" if "!c2!"=="" goto :break_loop2
)

:break_loop2
if !match! neq 1 goto :update_ini

:: Èç¹ûÁ½¸öÂ·¾¶¶¼Æ¥Åä£¬Ìø×ªµ½ :install
goto :install

:update_ini
:: Èç¹ûÂ·¾¶²»Æ¥Åä£¬Ôò½øĞĞÌæ»»
set temp_file=%~dp0mysql\my_temp.ini

(for /f "usebackq tokens=* delims=" %%i in ("%ini_file%") do (
    set line=%%i
    if "!line:~0,8!"=="basedir=" (
        echo basedir="!basedir_path!" >> "!temp_file!"
    ) else if "!line:~0,8!"=="datadir=" (
        echo datadir="!datadir_path!" >> "!temp_file!"
    ) else (
        echo %%i >> "!temp_file!"
    )
))

:: Ìæ»»Ô­Ê¼ ini ÎÄ¼şÎªĞÂµÄÁÙÊ±ÎÄ¼ş
move /y "!temp_file!" "!ini_file!"

echo INI ÎÄ¼ş¸üĞÂÍê³É¡£
goto :install

:install
@echo off
REM ¼ì²é MySQL ·şÎñÊÇ·ñÒÑ°²×°
sc query mysql | findstr /I /C:"does not exist" /C:"Î´°²×°" >nul 2>&1
if %errorlevel% equ 0 (
    echo MySQL ·şÎñÎ´°²×°£¬ÕıÔÚ³õÊ¼»¯²¢°²×°...
    mysqld --initialize-insecure --user=mysql
    mysqld -install
) else (
    echo MySQL ·şÎñÕıÔÚÆô¶¯ÖĞ...
)

REM ³¢ÊÔÆô¶¯ MySQL ·şÎñ
net start mysql >nul 2>&1
if %errorlevel% equ 2 (
    echo MySQL ·şÎñÒÑÔÚÔËĞĞ¡£
	goto :createmysql
) else (
    if %errorlevel% equ 0 (
        echo MySQL ·şÎñÒÑ³É¹¦Æô¶¯¡£
		goto :createmysql
    ) else (
        echo ÎŞ·¨Æô¶¯ MySQL ·şÎñ£¬Çë¼ì²é´íÎó¡£
		pause
		goto :end
    )
)

:createmysql
echo ÕıÔÚ´´½¨Êı¾İ¿â...

REM ¼ì²éÃûÎª iyuu µÄÊı¾İ¿âÊÇ·ñ´æÔÚ
echo ¼ì²éÊı¾İ¿âÊÇ·ñ´æÔÚ...
mysql -u root -e "SHOW DATABASES LIKE 'iyuu';" | findstr /I "iyuu" >nul 2>&1
if %errorlevel% equ 0 (
    echo Êı¾İ¿â iyuu ÒÑ´æÔÚ£¬Ìø¹ı´´½¨²Ù×÷¡£
) else (
    echo Êı¾İ¿â iyuu ²»´æÔÚ£¬ÕıÔÚ´´½¨Êı¾İ¿âºÍÓÃ»§...
    
    REM ´´½¨Ò»¸öÁÙÊ±µÄ SQL ÎÄ¼ş
    echo CREATE DATABASE iyuu; > temp.sql
    echo CREATE USER 'iyuu'@'localhost' IDENTIFIED BY 'iyuu'; >> temp.sql
    echo GRANT ALL PRIVILEGES ON iyuu.* TO 'iyuu'@'localhost'; >> temp.sql
    echo FLUSH PRIVILEGES; >> temp.sql

    REM Ö´ĞĞÁÙÊ±µÄ SQL ÎÄ¼ş
    mysql -u root < temp.sql

    REM É¾³ıÁÙÊ±µÄ SQL ÎÄ¼ş
    del temp.sql
	
	echo Êı¾İ¿â iyuu ´´½¨Íê³É¡£
)

echo.
echo ============  MySQLÊı¾İ¿âÒÑÆô¶¯  ============
echo =     %GREEN%Êı¾İ¿âÃû³Æ¡¢ÓÃ»§Ãû¡¢ÃÜÂë¶¼Îª£º%BOLD%iyuu%RESET%    =
echo =        Çë×¢ÒâÌîĞ´Êı¾İ¿âÊ±ÊÇ·ñÕıÈ·         =
echo = Ò»°ãÄ¬ÈÏ¶¼ÊÇiyuu£¬Ö±½ÓÌí¼ÓTokenÏÂÒ»²½¼´¿É =
echo =============================================
echo.
goto :input

:input
REM cmd /k
echo.
echo %BOLD%±¾½Å±¾Îª MySQL Êı¾İ¿âÌá¹©·şÎñ£¬Îª IYUUPlus-Dev µÄÆäÖĞÒ»»·£¬
echo Ö±½Óµã»÷ÓÒÉÏ½Ç X ¹Ø±Õ±¾´°¿ÚÊ± MySQL Êı¾İ¿â½«±£³ÖºóÌ¨ÔËĞĞ£¬
echo ÈçĞèÖÕÖ¹ºóÌ¨·şÎñÇëÊ¹ÓÃ¼üÅÌ°´ÏÂ Y ¼üÒÔÈ·ÈÏ¹Ø±ÕÊı¾İ¿â¡£
echo ÈçĞèĞ¶ÔØ MySQL ·şÎñÇëÊ¹ÓÃ¼üÅÌ°´ÏÂ D ¼üÒÔÈ·ÈÏĞ¶ÔØ¡£%RESET%
echo.
echo %RED%%BOLD%ÇëÏÈ¶ÁÍêÉÏÃæµÄÌáÊ¾£¬ÔÙ½øĞĞÏÂÃæµÄ²Ù×÷£¡%RESET%
echo.
goto :loop

:deletemysql
REM É¾³ıMySQL·şÎñ
taskkill /F /IM mysqld.exe
net stop mysql
sc delete MySQL
rem »ñÈ¡µ±Ç°Åú´¦ÀíÎÄ¼şµÄÂ·¾¶
set dataDir=%~dp0
rem ÉèÖÃÄ¿±êÎÄ¼ş¼ĞÂ·¾¶
set targetdataDir=%dataDir%mysql\data
rem È·±£Ä¿±êÎÄ¼ş¼Ğ´æÔÚ
if exist "%targetdataDir%" (
    rem É¾³ıÄ¿±êÎÄ¼ş¼ĞÄÚµÄËùÓĞÎÄ¼şºÍ×ÓÄ¿Â¼
    for /d %%x in ("%targetdataDir%\*") do rd /s /q "%%x"
    del /q "%targetdataDir%\*.*"
) else (
    echo Ä¿±êÎÄ¼ş¼Ğ²»´æÔÚ: %targetdataDir%
)

REM ²éÑ¯×¢²á±íÖĞ°üº¬ "MySQL" µÄÏî£¬²¢½«½á¹û±£´æµ½Ò»¸öÁÙÊ±ÎÄ¼şÖĞ
reg query HKLM\SYSTEM /s /f MySQL /k /e > reg_results.txt

REM Ê¹ÓÃfindstrÃüÁîÀ´¹ıÂËµô²»ĞèÒªµÄĞĞ
findstr /v "ËÑË÷½áÊø" reg_results.txt > filtered_results.txt

REM ¶ÁÈ¡¹ıÂËºóµÄÎÄ¼şÖĞµÄÃ¿Ò»ĞĞ£¬²¢Ê¹ÓÃ reg delete É¾³ı¶ÔÓ¦µÄ×¢²á±íÏî
for /f "tokens=*" %%a in (filtered_results.txt) do (
    echo Deleting registry key: %%a
    reg delete "%%a" /f
)

REM É¾³ıÁÙÊ±ÎÄ¼ş
del reg_results.txt
del filtered_results.txt

echo.
echo ===============================================
echo =    %BOLD%ÒÑÍ£Ö¹²¢É¾³ıÏà¹Ø·şÎñ£¬³É¹¦ÇåÀí×¢²á±í¡£%RESET%   =
echo =    %BOLD% Ğ¶ÔØMySQLÒÑÍê³É£¬¿ÉÒÔ×ÔÓÉ²Ù×÷ÎÄ¼ş¼Ğ¡£%RESET%   =
echo ===============================================
echo.
pause
goto :end

:loop
echo %REVERSE%%BOLD%ÇëÑ¡Ôñ²Ù×÷%RESET%: 
choice /C YD /M "  "
if %errorlevel% equ 1 (
    REM ÓÃ»§Ñ¡ÔñÁË Y£¬¹Ø±Õ´°¿Ú
	taskkill /F /IM mysqld.exe
	net stop mysql
    exit
) else if %errorlevel% equ 2 (
    REM ÓÃ»§Ñ¡ÔñÁË D£¬¼ÌĞøµÈ´ı
    goto :deletemysql
)

:end
echo.