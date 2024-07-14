@echo off

:: 检查脚本是否以管理员权限运行
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)
set PATH=%~dp0mysql\bin;%path%
:: Your commands go here
echo 此脚本正在以管理员权限运行。
echo.
setlocal enabledelayedexpansion

:: 定义颜色和样式的ANSI转义序列
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
REM echo 哈哈哈哈我是第一排
goto :checkini

:checkini
:: 定义 ini 文件路径
set ini_file=%~dp0mysql\my.ini

:: 检查是否存在 my.ini 文件
if exist "%ini_file%" (
    echo my.ini 文件存在，继续执行...
    goto :checkmysql
) else (
    echo my.ini 文件不存在，请检查下载的文件完整性。
	pause
    goto :end
)

:checkmysql
:: 获取当前批处理文件所在的目录
set current_path=%~dp0

:: 将路径中的反斜杠 \ 替换为斜杠 /
set "current_path_slash=!current_path:\=/!"

:: 获取 basedir 和 datadir 的路径
set basedir_path=!current_path_slash!mysql
set datadir_path=!current_path_slash!mysql/data

:: 定义 ini 文件路径
set ini_file=%~dp0mysql\my.ini

:: 读取 ini 文件并检查 basedir 和 datadir 的值
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

:: 去除读取值两端的引号和空格
set "ini_basedir=!ini_basedir:"=!"
set "ini_datadir=!ini_datadir:"=!"
set "ini_basedir=!ini_basedir: =!"
set "ini_datadir=!ini_datadir: =!"

:: 检查路径是否匹配
set match=1

:: 比较 ini_basedir 和 basedir_path
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

:: 比较 ini_datadir 和 datadir_path
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

:: 如果两个路径都匹配，跳转到 :install
goto :install

:update_ini
:: 如果路径不匹配，则进行替换
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

:: 替换原始 ini 文件为新的临时文件
move /y "!temp_file!" "!ini_file!"

echo INI 文件更新完成。
goto :install

:install
@echo off
REM 检查 MySQL 服务是否已安装
sc query mysql | findstr /I /C:"does not exist" /C:"未安装" >nul 2>&1
if %errorlevel% equ 0 (
    echo MySQL 服务未安装，正在初始化并安装...
    mysqld --initialize-insecure --user=mysql
    mysqld -install
) else (
    echo MySQL 服务正在启动中...
)

REM 尝试启动 MySQL 服务
net start mysql >nul 2>&1
if %errorlevel% equ 2 (
    echo MySQL 服务已在运行。
	goto :createmysql
) else (
    if %errorlevel% equ 0 (
        echo MySQL 服务已成功启动。
		goto :createmysql
    ) else (
        echo 无法启动 MySQL 服务，请检查错误。
		pause
		goto :end
    )
)

:createmysql
echo 正在创建数据库...

REM 检查名为 iyuu 的数据库是否存在
echo 检查数据库是否存在...
mysql -u root -e "SHOW DATABASES LIKE 'iyuu';" | findstr /I "iyuu" >nul 2>&1
if %errorlevel% equ 0 (
    echo 数据库 iyuu 已存在，跳过创建操作。
) else (
    echo 数据库 iyuu 不存在，正在创建数据库和用户...
    
    REM 创建一个临时的 SQL 文件
    echo CREATE DATABASE iyuu; > temp.sql
    echo CREATE USER 'iyuu'@'localhost' IDENTIFIED BY 'iyuu'; >> temp.sql
    echo GRANT ALL PRIVILEGES ON iyuu.* TO 'iyuu'@'localhost'; >> temp.sql
    echo FLUSH PRIVILEGES; >> temp.sql

    REM 执行临时的 SQL 文件
    mysql -u root < temp.sql

    REM 删除临时的 SQL 文件
    del temp.sql
	
	echo 数据库 iyuu 创建完成。
)

echo.
echo ============  MySQL数据库已启动  ============
echo =     %GREEN%数据库名称、用户名、密码都为：%BOLD%iyuu%RESET%    =
echo =        请注意填写数据库时是否正确         =
echo = 一般默认都是iyuu，直接添加Token下一步即可 =
echo =============================================
echo.
goto :input

:input
REM cmd /k
echo.
echo %BOLD%本脚本为 MySQL 数据库提供服务，为 IYUUPlus-Dev 的其中一环，
echo 直接点击右上角 X 关闭本窗口时 MySQL 数据库将保持后台运行，
echo 如需终止后台服务请使用键盘按下 Y 键以确认关闭数据库。
echo 如需卸载 MySQL 服务请使用键盘按下 D 键以确认卸载。%RESET%
echo.
echo %RED%%BOLD%请先读完上面的提示，再进行下面的操作！%RESET%
echo.
goto :loop

:deletemysql
REM 删除MySQL服务
taskkill /F /IM mysqld.exe
net stop mysql
sc delete MySQL
rem 获取当前批处理文件的路径
set dataDir=%~dp0
rem 设置目标文件夹路径
set targetdataDir=%dataDir%mysql\data
rem 确保目标文件夹存在
if exist "%targetdataDir%" (
    rem 删除目标文件夹内的所有文件和子目录
    for /d %%x in ("%targetdataDir%\*") do rd /s /q "%%x"
    del /q "%targetdataDir%\*.*"
) else (
    echo 目标文件夹不存在: %targetdataDir%
)

REM 查询注册表中包含 "MySQL" 的项，并将结果保存到一个临时文件中
reg query HKLM\SYSTEM /s /f MySQL /k /e > reg_results.txt

REM 使用findstr命令来过滤掉不需要的行
findstr /v "搜索结束" reg_results.txt > filtered_results.txt

REM 读取过滤后的文件中的每一行，并使用 reg delete 删除对应的注册表项
for /f "tokens=*" %%a in (filtered_results.txt) do (
    echo Deleting registry key: %%a
    reg delete "%%a" /f
)

REM 删除临时文件
del reg_results.txt
del filtered_results.txt

echo.
echo ===============================================
echo =    %BOLD%已停止并删除相关服务，成功清理注册表。%RESET%   =
echo =    %BOLD% 卸载MySQL已完成，可以自由操作文件夹。%RESET%   =
echo ===============================================
echo.
pause
goto :end

:loop
echo %REVERSE%%BOLD%请选择操作%RESET%: 
choice /C YD /M "  "
if %errorlevel% equ 1 (
    REM 用户选择了 Y，关闭窗口
	taskkill /F /IM mysqld.exe
	net stop mysql
    exit
) else if %errorlevel% equ 2 (
    REM 用户选择了 D，继续等待
    goto :deletemysql
)

:end
echo.