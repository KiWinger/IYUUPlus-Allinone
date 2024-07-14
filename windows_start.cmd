@echo off
setlocal enabledelayedexpansion
title IYUUPlus-Dev
cd /d "%~dp0"
echo.
goto :ping

:ping
ping -n 1 iyuu.cn >nul
if %errorlevel% equ 0 (
    echo ��������������
	goto :checkEnv
) else (
    echo ��������ʧ�ܣ������������Ӻ�����������
	pause
    goto :end
)

:checkEnv
echo "���.env.example�ļ��Ƿ����..."
if exist "%~dp0iyuuplus-dev\.env.example" goto :checkGit
echo "���GIT�����԰�װԴ��..."
git --version|find "git version">nul&&goto :installGit
cls
goto :installError

:installGit
echo "����ʹ��GIT����Դ��..."
git clone https://gitee.com/ledc/iyuuplus-dev.git %~dp0iyuuplus-dev
echo "ͨ��GIT��װ��ɣ���ʼ���phpִ�г���..."
REM cd iyuuplus-dev
goto :checkPHP

:installError
cls
echo "��ǰ���л���δ��⵽GIT����Դ�밲װʧ�ܣ����ֶ�����"
echo "Gitee: https://gitee.com/ledc/iyuuplus-dev"
echo "Github: https://github.com/ledccn/iyuuplus-dev"
pause
goto :end

:checkGit
echo "���GIT����..."
git --version|find "git version">nul&&goto :pull
cls
echo "��ǰIYUUPlus���л���δ��⵽git����"
echo "����ʹ��git�����д���⣡"
echo "������ص��ļ������ԣ�"
echo "git clone https://gitee.com/ledc/iyuuplus-dev.git"
pause
goto :end

:pull
goto :checkPHP

:checkPHP
if exist "%~dp0php\php.exe" (set PHP_BINARY=%~dp0php\php.exe) else (set PHP_BINARY=php.exe)
echo "PHP�����Ƴ���"%PHP_BINARY%
%PHP_BINARY% -v|find "PHP Group">nul&&goto :start
cls
echo "û�м�⵽PHPִ�г���"
echo "������ص��ļ������ԣ�"
echo "�ű�������ֹ��"
pause
goto :end

:start
%PHP_BINARY% -v
echo.
echo "�������Ҫֹͣ�����밴����ϼ���CTRL + C ������ Y ��س�"
echo "������Ϊ��������һ������Ϊ���ݿ⣬����ϸ�Ķ���ʾ�����"
echo "���Զ�Ϊ����������"
start "" "http://localhost:8787"
%PHP_BINARY% %~dp0iyuuplus-dev\windows.php
pause
goto :end

:end
rem ����
echo.
