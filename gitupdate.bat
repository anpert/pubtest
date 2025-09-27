@echo off
setlocal EnableExtensions

rem %1 = START tai END (oletus START)
set "SUUNTA=%~1"
if /i "%SUUNTA%"=="" set "SUUNTA=START"
if /i not "%SUUNTA%"=="START" if /i not "%SUUNTA%"=="END" (
  echo Virhe: 1. parametri oltava START tai END
  exit /b 2
)

rem --- Vaihda mainiin ---
git switch main >nul 2>&1
if errorlevel 1 git checkout main >nul 2>&1
if errorlevel 1 (
  echo Branch 'main' ei saatavilla / vaihto epaonnistui
  exit /b 4
)

rem --- Vedä uusin (rebase) ---
git pull --rebase origin main
if errorlevel 1 (
  echo git pull --rebase epaonnistui
  exit /b 4
)


rem --- Jos START, lopeta tahan ---
if /i "%SUUNTA%"=="START" goto :done

rem --- END: add + mahdollinen commit + push ---
git add -A
if errorlevel 1 (
  echo git add epaonnistui
  exit /b 5
)

rem 0 = ei staged muutoksia, 1 = on muutoksia, 2 = virhe
git diff --cached --quiet
if errorlevel 2 (
  echo git diff --cached --quiet virhe
  exit /b 5
)
if errorlevel 1 goto :do_commit

echo Ei muutoksia staged, ei commit/push
goto :done

:do_commit
rem Hae repon nimi ilman polkua – varmistetaan ettei synny lohkosulku-ongelmia
for /f "delims=" %%R in ('git rev-parse --show-toplevel 2^>nul') do set "REPONAME=%%~nR"
if "%REPONAME%"=="" set "REPONAME=repo"

rem Varmuuden vuoksi ei käytetä sulkeita commit-viestissä
set "MSG=%date%-%time%-automaattinen-paivitys-%REPONAME%-"
git commit -m "%MSG%"
if errorlevel 1 (
  echo git commit epaonnistui
  exit /b 5
)

git push origin main
if errorlevel 1 (
  echo git push epaonnistui
  exit /b 6
)

:done
exit /b 0
