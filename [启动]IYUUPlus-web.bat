@echo off

attrib windows_start.cmd +s +h
echo IYUUPlus-Allinone for Win
echo ����Ŀ�� KiWinger ����
echo ��Դ��ַ��https://github.com/KiWinger/IYUUPlus-Allinone
echo.

setlocal enableextensions enabledelayedexpansion

set "max_length=260"
set "current_dir=%cd%"

if "!current_dir!"=="!current_dir:~,%max_length%!" (
    goto :go
	
) else (
    goto :stop
)

endlocal

:go
echo [OK] Ŀ¼·���ַ����޼��ͨ��

setlocal enabledelayedexpansion

set "current_dir=%cd%"
set "has_space=false"

if not "!current_dir: =!" == "!current_dir!" set "has_space=true"

if !has_space! == true (
    goto :stoo
) else (
    echo [OK] Ŀ¼·���ַ��޿ո���ͨ��
	goto :Az
)

endlocal

:Az
echo.
echo [ע��] �뱣֤��ǰ�ļ�����Ŀ¼�� �� �� · ��
echo ������Ӣ����ĸ A-Z a-z���Լ�����Ӣ���ַ� + - _
echo ��Ҫʹ�������ַ�����������޷�Ԥ֪�Ĵ���
echo.
set /p input=���� yes �س��Լ�����
if /i "%input%" == "yes" (
    goto :run
) else (
    goto :soop
)

:stop
echo.
echo [Error] Ŀ¼·���ַ����޼��δͨ��
echo [Error] ��鰲װĿ¼���ڵ�����·���ַ����ܹ�������260��
echo [Error] ����������ٴ����а�װ
goto :end

:stoo
echo.
echo [Error] Ŀ¼·���ַ��޿ո���δͨ��
echo [Error] ��鰲װĿ¼���ڵ�����·�����Ƿ���ڿո�
echo [Error] ��ɾ�����пո���ٴ����а�װ
goto :end

:soop
echo.
echo δ����yes���˳�
goto :end

:run
echo ins VC...
start /wait VC.exe /quiet /norestart
set PATH=%~dp0git\cmd;%path%
call windows_start.cmd

:end
echo.
pause