@echo off
setlocal
REM echo ins VC...
REM start /wait VC.exe /quiet /norestart
set PATH=%~dp0git\cmd;%path%
set PATH=%~dp0php;%path%
REM set PATH=%~dp0mysql\bin;%path%
echo �����Ҫ������л�����...
:: ��ȡbat���ڵ�Ŀ¼
set "my_dir=%~dp0"
set "mysql_lib=%my_dir%mysql\lib\mysqlserver.lib"

:mysqllib
:: ���mysqlserver.lib�Ƿ����
if exist "%mysql_lib%" (
    goto :goooo
)

:: ���ز���ѹmysql
echo MySQL���񲻴��ڣ�׼���ӹٷ���������...
set "download_url=https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.26-winx64.zip"
set "download_myfile=%my_dir%mysql-5.7.26-winx64.zip"
set "mytemp_dir=%my_dir%mysql-5.7.26-winx64"
set "dest_dir=%my_dir%mysql"

:: ʹ��bitsadmin�����ļ�
powershell -Command "& {Start-BitsTransfer -Source '%download_url%' -Destination '%download_myfile%' -DisplayName '����MySQL��...'}"

:: ��������Ƿ�ɹ�
if exist "%download_myfile%" (
    echo MySQL������ɣ�׼����ѹ...
    
    :: ��ѹ���ص��ļ�����ʱ�ļ���
    powershell -Command "Expand-Archive -Path '%download_myfile%' -DestinationPath '%my_dir%'"
    
    :: �ƶ���ѹ����ļ���mysql�ļ���
    robocopy "%mytemp_dir%" "%dest_dir%" /move /e /is

    :: ɾ����ʱ�ļ���
    rd /s /q "%mytemp_dir%"

    :: ɾ�����ص�ѹ����
    del "%download_myfile%"

    echo MySQL��ѹ���.
	goto :mysqllib
) else (
    echo MySQL��ѹʧ��.
    goto :end
)

:end
echo ������MySQL����������������������б��ű�.
pause

:goooo
echo MySQL�������ͨ��.
echo.
echo ���ű���Դ��ַ��Ctrl+�����������ַ����
echo https://github.com/KiWinger/IYUUPlus-Allinone
echo.
echo ���ű����Զ����� IYUUPlus-Dev ���Զ��������ҳ��
echo.
echo ==========    ����ϸ�Ķ�������˵����    ==========
echo =                                                =
echo =       �������������һ���ű�������������       =
echo =     ���� IYUUPlus-Dev ��Ҫ��������ͬʱ����     =
echo =     ��Ŀǰ��δ�������ֶ������������������     =
echo =     �����ű���Ҫ����ԱȨ�����У�������Ȩ��     =
echo =                                                =
echo ==================================================
echo.
pause
echo 3������...
timeout /t 3 >nul
start "" /min cmd /c "mysql.bat"
timeout /t 10 >nul
call windows_start.cmd
