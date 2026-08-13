@echo off
setlocal

set "ROOT=%~dp0"
if "%PACKAGE_VERSION%"=="" set "PACKAGE_VERSION=3.4.1-radium.1"
if "%LOG4NET_DLL%"=="" set "LOG4NET_DLL=%ROOT%packages\log4net.3.3.1\lib\net462\log4net.dll"

if not exist "%LOG4NET_DLL%" if "%LOG4NET_DLL%"=="%ROOT%packages\log4net.3.3.1\lib\net462\log4net.dll" (
  echo Restoring log4net 3.3.1...
  "%ROOT%tools\nuget\NuGet.exe" install log4net -Version 3.3.1 -OutputDirectory "%ROOT%packages" -NonInteractive
  if errorlevel 1 exit /b 1
)

if not exist "%LOG4NET_DLL%" (
  echo log4net.dll was not found: %LOG4NET_DLL%
  echo Set LOG4NET_DLL to the path of the log4net assembly to use.
  exit /b 1
)

if "%MSBUILD_EXE%"=="" (
  for /f "delims=" %%I in ('where msbuild.exe 2^>nul') do (
    set "MSBUILD_EXE=%%I"
    goto :msbuild-found
  )
)

:msbuild-found
if "%MSBUILD_EXE%"=="" (
  echo MSBuild was not found. Set MSBUILD_EXE to the full path of MSBuild.exe.
  exit /b 1
)

call "%MSBUILD_EXE%" "%ROOT%src\Common.Logging.Log4Net1213\Common.Logging.Log4Net1213.2010-net40.csproj" ^
  /t:Rebuild /p:Configuration=Release /p:Log4NetReferencePath="%LOG4NET_DLL%" /v:minimal
if errorlevel 1 exit /b 1

if not exist "%ROOT%package-nuget" mkdir "%ROOT%package-nuget"

"%ROOT%tools\nuget\NuGet.exe" pack "%ROOT%src\Common.Logging.Log4Net1213\Common.Logging.Log4Net1213.nuspec" ^
  -Version "%PACKAGE_VERSION%" -OutputDirectory "%ROOT%package-nuget" -NoPackageAnalysis
if errorlevel 1 exit /b 1

echo Created RADIUM.Common.Logging.Log4Net1213.%PACKAGE_VERSION%.nupkg
endlocal
