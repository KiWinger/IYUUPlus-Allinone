@echo off
setlocal enabledelayedexpansion
title IYUUPlus-Dev
cd /d "%~dp0"
echo.
goto :ping

:ping
ping -n 1 iyuu.cn >nul
if %errorlevel% equ 0 (
    echo 网络连接正常。
	goto :checkEnv
) else (
    echo 网络连接失败，请检查网络连接后重新启动。
	pause
    goto :end
)

:checkEnv
echo "检查.env.example文件是否存在..."
if exist "%~dp0iyuuplus-dev\.env.example" goto :checkGit
echo "检查GIT，尝试安装源码..."
git --version|find "git version">nul&&goto :installGit
cls
goto :installError

:installGit
echo "正在使用GIT载入源码..."
git clone https://gitee.com/ledc/iyuuplus-dev.git %~dp0iyuuplus-dev
echo "通过GIT安装完成，开始检测php执行程序..."
REM cd iyuuplus-dev
goto :checkPHP

:installError
cls
echo "当前运行环境未检测到GIT程序，源码安装失败！请手动下载"
echo "Gitee: https://gitee.com/ledc/iyuuplus-dev"
echo "Github: https://github.com/ledccn/iyuuplus-dev"
pause
goto :end

:checkGit
echo "检查GIT程序..."
git --version|find "git version">nul&&goto :pull
cls
echo "当前IYUUPlus运行环境未检测到git程序。"
echo "必须使用git来运行代码库！"
echo "检查下载的文件完整性？"
echo "git clone https://gitee.com/ledc/iyuuplus-dev.git"
pause
goto :end

:pull
goto :checkPHP

:checkPHP
if exist "%~dp0php\php.exe" (set PHP_BINARY=%~dp0php\php.exe) else (set PHP_BINARY=php.exe)
echo "PHP二进制程序："%PHP_BINARY%
%PHP_BINARY% -v|find "PHP Group">nul&&goto :start
cls
echo "没有检测到PHP执行程序，"
echo "检查下载的文件完整性？"
echo "脚本运行终止。"
pause
goto :end

:start
%PHP_BINARY% -v
echo.
echo "如果您需要停止程序，请按下组合键：CTRL + C ，输入 Y 后回车"
echo "本窗口为主程序，另一个窗口为数据库，请仔细阅读提示后操作"
echo "已自动为你打开了浏览器"
start "" "http://localhost:8787"
%PHP_BINARY% %~dp0iyuuplus-dev\windows.php
pause
goto :end

:end
rem 结束
echo.
