@echo off
setlocal
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo Instale Node.js 24 ou superior em https://nodejs.org e execute novamente.
  pause
  exit /b 1
)
if not exist "node_modules\electron-builder" (
  call npm ci
  if errorlevel 1 exit /b 1
)
call npm run build:win
if errorlevel 1 (
  echo Nao foi possivel gerar o executavel. Consulte as mensagens acima.
) else (
  echo Aplicativo gerado na pasta release.
)
pause
