@echo off

:: ���ű��Ƿ��Թ���ԱȨ������
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)
set PATH=%~dp0mysql\bin;%path%
:: Your commands go here
echo �˽ű������Թ���ԱȨ�����С�
echo.
setlocal enabledelayedexpansion

:: ������ɫ����ʽ��ANSIת������
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
REM echo �����������ǵ�һ��
goto :checkini

:checkini
:: ���� ini �ļ�·��
set ini_file=%~dp0mysql\my.ini

:: ����Ƿ���� my.ini �ļ�
if exist "%ini_file%" (
    echo my.ini �ļ����ڣ�����ִ��...
    goto :checkmysql
) else (
    echo my.ini �ļ������ڣ��������ص��ļ������ԡ�
	pause
    goto :end
)

:checkmysql
:: ��ȡ��ǰ�������ļ����ڵ�Ŀ¼
set current_path=%~dp0

:: ��·���еķ�б�� \ �滻Ϊб�� /
set "current_path_slash=!current_path:\=/!"

:: ��ȡ basedir �� datadir ��·��
set basedir_path=!current_path_slash!mysql
set datadir_path=!current_path_slash!mysql/data

:: ���� ini �ļ�·��
set ini_file=%~dp0mysql\my.ini

:: ��ȡ ini �ļ������ basedir �� datadir ��ֵ
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

:: ȥ����ȡֵ���˵����źͿո�
set "ini_basedir=!ini_basedir:"=!"
set "ini_datadir=!ini_datadir:"=!"
set "ini_basedir=!ini_basedir: =!"
set "ini_datadir=!ini_datadir: =!"

:: ���·���Ƿ�ƥ��
set match=1

:: �Ƚ� ini_basedir �� basedir_path
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

:: �Ƚ� ini_datadir �� datadir_path
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

:: �������·����ƥ�䣬��ת�� :install
goto :install

:update_ini
:: ���·����ƥ�䣬������滻
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

:: �滻ԭʼ ini �ļ�Ϊ�µ���ʱ�ļ�
move /y "!temp_file!" "!ini_file!"

echo INI �ļ�������ɡ�
goto :install

:install
@echo off
REM ��� MySQL �����Ƿ��Ѱ�װ
sc query mysql | findstr /I /C:"does not exist" /C:"δ��װ" >nul 2>&1
if %errorlevel% equ 0 (
    echo MySQL ����δ��װ�����ڳ�ʼ������װ...
    mysqld --initialize-insecure --user=mysql
    mysqld -install
) else (
    echo MySQL ��������������...
)

REM �������� MySQL ����
net start mysql >nul 2>&1
if %errorlevel% equ 2 (
    echo MySQL �����������С�
	goto :createmysql
) else (
    if %errorlevel% equ 0 (
        echo MySQL �����ѳɹ�������
		goto :createmysql
    ) else (
        echo �޷����� MySQL �����������
		pause
		goto :end
    )
)

:createmysql
echo ���ڴ������ݿ�...

REM �����Ϊ iyuu �����ݿ��Ƿ����
echo ������ݿ��Ƿ����...
mysql -u root -e "SHOW DATABASES LIKE 'iyuu';" | findstr /I "iyuu" >nul 2>&1
if %errorlevel% equ 0 (
    echo ���ݿ� iyuu �Ѵ��ڣ���������������
) else (
    echo ���ݿ� iyuu �����ڣ����ڴ������ݿ���û�...
    
    REM ����һ����ʱ�� SQL �ļ�
    echo CREATE DATABASE iyuu; > temp.sql
    echo CREATE USER 'iyuu'@'localhost' IDENTIFIED BY 'iyuu'; >> temp.sql
    echo GRANT ALL PRIVILEGES ON iyuu.* TO 'iyuu'@'localhost'; >> temp.sql
    echo FLUSH PRIVILEGES; >> temp.sql

    REM ִ����ʱ�� SQL �ļ�
    mysql -u root < temp.sql

    REM ɾ����ʱ�� SQL �ļ�
    del temp.sql
	
	echo ���ݿ� iyuu ������ɡ�
)

echo.
echo ============  MySQL���ݿ�������  ============
echo =     %GREEN%���ݿ����ơ��û��������붼Ϊ��%BOLD%iyuu%RESET%    =
echo =        ��ע����д���ݿ�ʱ�Ƿ���ȷ         =
echo = һ��Ĭ�϶���iyuu��ֱ�����Token��һ������ =
echo =============================================
echo.
goto :input

:input
REM cmd /k
echo.
echo %BOLD%���ű�Ϊ MySQL ���ݿ��ṩ����Ϊ IYUUPlus-Dev ������һ����
echo ֱ�ӵ�����Ͻ� X �رձ�����ʱ MySQL ���ݿ⽫���ֺ�̨���У�
echo ������ֹ��̨������ʹ�ü��̰��� Y ����ȷ�Ϲر����ݿ⡣
echo ����ж�� MySQL ������ʹ�ü��̰��� D ����ȷ��ж�ء�%RESET%
echo.
echo %RED%%BOLD%���ȶ����������ʾ���ٽ�������Ĳ�����%RESET%
echo.
goto :loop

:deletemysql
REM ɾ��MySQL����
taskkill /F /IM mysqld.exe
net stop mysql
sc delete MySQL
rem ��ȡ��ǰ�������ļ���·��
set dataDir=%~dp0
rem ����Ŀ���ļ���·��
set targetdataDir=%dataDir%mysql\data
rem ȷ��Ŀ���ļ��д���
if exist "%targetdataDir%" (
    rem ɾ��Ŀ���ļ����ڵ������ļ�����Ŀ¼
    for /d %%x in ("%targetdataDir%\*") do rd /s /q "%%x"
    del /q "%targetdataDir%\*.*"
) else (
    echo Ŀ���ļ��в�����: %targetdataDir%
)

REM ��ѯע����а��� "MySQL" �������������浽һ����ʱ�ļ���
reg query HKLM\SYSTEM /s /f MySQL /k /e > reg_results.txt

REM ʹ��findstr���������˵�����Ҫ����
findstr /v "��������" reg_results.txt > filtered_results.txt

REM ��ȡ���˺���ļ��е�ÿһ�У���ʹ�� reg delete ɾ����Ӧ��ע�����
for /f "tokens=*" %%a in (filtered_results.txt) do (
    echo Deleting registry key: %%a
    reg delete "%%a" /f
)

REM ɾ����ʱ�ļ�
del reg_results.txt
del filtered_results.txt

echo.
echo ===============================================
echo =    %BOLD%��ֹͣ��ɾ����ط��񣬳ɹ�����ע���%RESET%   =
echo =    %BOLD% ж��MySQL����ɣ��������ɲ����ļ��С�%RESET%   =
echo ===============================================
echo.
pause
goto :end

:loop
echo %REVERSE%%BOLD%��ѡ�����%RESET%: 
choice /C YD /M "  "
if %errorlevel% equ 1 (
    REM �û�ѡ���� Y���رմ���
	taskkill /F /IM mysqld.exe
	net stop mysql
    exit
) else if %errorlevel% equ 2 (
    REM �û�ѡ���� D�������ȴ�
    goto :deletemysql
)

:end
echo.