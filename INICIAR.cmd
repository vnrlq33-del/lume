@echo off
setlocal
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo Instale Node.js 24 ou superior em https://nodejs.org e execute novamente.
  pause
  exit /b 1
)
if not exist "node_modules\electron\dist\electron.exe" (
  call npm ci
  if errorlevel 1 (
    echo Nao foi possivel preparar o aplicativo. Confira sua conexao.
    pause
    exit /b 1
  )
)
call npm start
if errorlevel 1 pause
