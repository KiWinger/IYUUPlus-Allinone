@echo off
setlocal
REM echo ins VC...
REM start /wait VC.exe /quiet /norestart
set PATH=%~dp0git\cmd;%path%
set PATH=%~dp0php;%path%
REM set PATH=%~dp0mysql\bin;%path%
echo 检查重要组件运行环境中...
:: 获取bat所在的目录
set "my_dir=%~dp0"
set "mysql_lib=%my_dir%mysql\lib\mysqlserver.lib"

:mysqllib
:: 检查mysqlserver.lib是否存在
if exist "%mysql_lib%" (
    goto :goooo
)

:: 下载并解压mysql
echo MySQL服务不存在，准备从官方渠道下载...
set "download_url=https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.26-winx64.zip"
set "download_myfile=%my_dir%mysql-5.7.26-winx64.zip"
set "mytemp_dir=%my_dir%mysql-5.7.26-winx64"
set "dest_dir=%my_dir%mysql"

:: 使用bitsadmin下载文件
powershell -Command "& {Start-BitsTransfer -Source '%download_url%' -Destination '%download_myfile%' -DisplayName '下载MySQL中...'}"

:: 检查下载是否成功
if exist "%download_myfile%" (
    echo MySQL下载完成，准备解压...
    
    :: 解压下载的文件到临时文件夹
    powershell -Command "Expand-Archive -Path '%download_myfile%' -DestinationPath '%my_dir%'"
    
    :: 移动解压后的文件到mysql文件夹
    robocopy "%mytemp_dir%" "%dest_dir%" /move /e /is

    :: 删除临时文件夹
    rd /s /q "%mytemp_dir%"

    :: 删除下载的压缩包
    del "%download_myfile%"

    echo MySQL解压完成.
	goto :mysqllib
) else (
    echo MySQL解压失败.
    goto :end
)

:end
echo 不存在MySQL环境，请检查网络后重新运行本脚本.
pause

:goooo
echo MySQL环境检测通过.
echo.
echo 本脚本开源地址（Ctrl+鼠标左键点击地址）：
echo https://github.com/KiWinger/IYUUPlus-Allinone
echo.
echo 本脚本会自动运行 IYUUPlus-Dev 并自动打开浏览器页面
echo.
echo ==========    并仔细阅读窗口中说明！    ==========
echo =                                                =
echo =       启动后会联动另一个脚本，共两个窗口       =
echo =     启动 IYUUPlus-Dev 需要两个窗口同时运行     =
echo =     （目前暂未启动，手动按下任意键以启动）     =
echo =     联动脚本需要管理员权限运行，请允许权限     =
echo =                                                =
echo ==================================================
echo.
pause
echo 3秒后继续...
timeout /t 3 >nul
start "" /min cmd /c "mysql.bat"
timeout /t 10 >nul
call windows_start.cmd
