@echo off
REM run.bat - Run doer_app with environment variables on Windows
REM Usage: scripts\run.bat

cd /d "%~dp0\.."

REM Check if .env file exists
if not exist ".env" (
    echo Error: .env file not found!
    echo Please create a .env file with the required environment variables.
    exit /b 1
)

REM Load environment variables from .env file
for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
    if not "%%a"=="" if not "%%a:~0,1%"=="#" set %%a=%%b
)

REM Verify required environment variables
if "%SUPABASE_URL%"=="" (
    echo Error: SUPABASE_URL not set in .env file
    exit /b 1
)

if "%SUPABASE_ANON_KEY%"=="" (
    echo Error: SUPABASE_ANON_KEY not set in .env file
    exit /b 1
)

REM Build dart-define arguments
set DART_DEFINES=--dart-define=SUPABASE_URL=%SUPABASE_URL%
set DART_DEFINES=%DART_DEFINES% --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY%

REM Add Google Web Client ID if configured
if not "%GOOGLE_WEB_CLIENT_ID%"=="" (
    set DART_DEFINES=%DART_DEFINES% --dart-define=GOOGLE_WEB_CLIENT_ID=%GOOGLE_WEB_CLIENT_ID%
)

echo Running doer_app with environment variables...
flutter run %DART_DEFINES%
