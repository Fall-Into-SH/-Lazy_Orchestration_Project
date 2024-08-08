@echo off
REM 관리자 권한 확인
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo This script requires administrative privileges. Please run as administrator.
    pause
    exit /b
)

REM 프라이빗 네트워크 프로파일 확인 및 설정
echo Checking and setting network profile to Private...
powershell -Command "Get-NetConnectionProfile | Where-Object {$_.NetworkCategory -ne 'Private'} | Set-NetConnectionProfile -NetworkCategory Private"

REM 방화벽 인바운드 규칙 추가 (SMB 포트 445 허용)
echo Allowing SMB port 445 through firewall...
netsh advfirewall firewall add rule name="SMB Port 445" dir=in action=allow protocol=TCP localport=445

REM 입력
set /p SHARE_FOLDER="Enter the path to the directory you want to share (e.g., C:\share_dir): "
set /p SHARE_NAME="Enter the name of the share (e.g., test_share): "
set /p SHARE_DESCRIPTION="Enter the description of the share (e.g., test_share_dir): "

REM 공유 디렉터리 생성 (필요한 경우)
if not exist "%SHARE_FOLDER%" (
    echo Creating directory %SHARE_FOLDER%...
    mkdir "%SHARE_FOLDER%"
)

REM 디렉터리 공유 설정
echo Setting up share...
net share %SHARE_NAME%=%SHARE_FOLDER% /GRANT:everyone,FULL /REMARK:"%SHARE_DESCRIPTION%"

REM 공유 상태 확인
echo Current share status:
net share

echo Share setup complete.
pause
