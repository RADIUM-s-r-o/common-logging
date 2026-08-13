@echo off
setlocal

set "ROOT=%~dp0"
if "%PACKAGE_VERSION%"=="" set "PACKAGE_VERSION=3.4.1-radium.1"
if "%LOG4NET_DLL%"=="" set "LOG4NET_DLL=%ROOT%packages\log4net.3.3.1\lib\net462\log4net.dll"
if "%FRAMEWORK_PATH%"=="" set "FRAMEWORK_PATH=%ROOT%packages\Microsoft.NETFramework.ReferenceAssemblies.net462.1.0.3\build\.NETFramework\v4.6.2"
if "%COMMON_LOGGING_DLL%"=="" set "COMMON_LOGGING_DLL=%ROOT%packages\Common.Logging.3.4.1\lib\net40\Common.Logging.dll"
if "%COMMON_LOGGING_CORE_DLL%"=="" set "COMMON_LOGGING_CORE_DLL=%ROOT%packages\Common.Logging.Core.3.4.1\lib\net40\Common.Logging.Core.dll"

if not exist "%LOG4NET_DLL%" if "%LOG4NET_DLL%"=="%ROOT%packages\log4net.3.3.1\lib\net462\log4net.dll" (
  echo Restoring log4net 3.3.1...
  "%ROOT%tools\nuget\NuGet.exe" install log4net -Version 3.3.1 -OutputDirectory "%ROOT%packages" -NonInteractive
  if errorlevel 1 exit /b 1
)

if not exist "%FRAMEWORK_PATH%" if "%FRAMEWORK_PATH%"=="%ROOT%packages\Microsoft.NETFramework.ReferenceAssemblies.net462.1.0.3\build\.NETFramework\v4.6.2" (
  echo Restoring .NET Framework 4.6.2 reference assemblies...
  "%ROOT%tools\nuget\NuGet.exe" install Microsoft.NETFramework.ReferenceAssemblies.net462 -Version 1.0.3 -OutputDirectory "%ROOT%packages" -NonInteractive
  if errorlevel 1 exit /b 1
)

if not exist "%COMMON_LOGGING_DLL%" if "%COMMON_LOGGING_DLL%"=="%ROOT%packages\Common.Logging.3.4.1\lib\net40\Common.Logging.dll" (
  echo Restoring Common.Logging 3.4.1...
  "%ROOT%tools\nuget\NuGet.exe" install Common.Logging -Version 3.4.1 -OutputDirectory "%ROOT%packages" -NonInteractive
  if errorlevel 1 exit /b 1
)

if not exist "%COMMON_LOGGING_CORE_DLL%" if "%COMMON_LOGGING_CORE_DLL%"=="%ROOT%packages\Common.Logging.Core.3.4.1\lib\net40\Common.Logging.Core.dll" (
  echo Restoring Common.Logging.Core 3.4.1...
  "%ROOT%tools\nuget\NuGet.exe" install Common.Logging.Core -Version 3.4.1 -OutputDirectory "%ROOT%packages" -NonInteractive
  if errorlevel 1 exit /b 1
)

if not exist "%LOG4NET_DLL%" (
  echo log4net.dll was not found: %LOG4NET_DLL%
  echo Set LOG4NET_DLL to the path of the log4net assembly to use.
  exit /b 1
)

if not exist "%FRAMEWORK_PATH%" (
  echo .NET Framework reference assemblies were not found: %FRAMEWORK_PATH%
  echo Set FRAMEWORK_PATH to the directory containing the v4.6.2 reference assemblies.
  exit /b 1
)

if not exist "%COMMON_LOGGING_DLL%" (
  echo Common.Logging.dll was not found: %COMMON_LOGGING_DLL%
  exit /b 1
)

if not exist "%COMMON_LOGGING_CORE_DLL%" (
  echo Common.Logging.Core.dll was not found: %COMMON_LOGGING_CORE_DLL%
  exit /b 1
)

if "%MSBUILD_EXE%"=="" (
  for /f "delims=" %%I in ('where msbuild.exe 2^>nul') do (
    set "MSBUILD_EXE=%%I"
    goto :msbuild-found
  )
)

:find-msbuild-with-vswhere
if "%MSBUILD_EXE%"=="" if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
  for /f "delims=" %%I in ('"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe') do (
    set "MSBUILD_EXE=%%I"
    goto :msbuild-found
  )
)

:msbuild-found
if "%MSBUILD_EXE%"=="" (
  echo MSBuild was not found. Install Visual Studio Build Tools or set MSBUILD_EXE.
  exit /b 1
)

call "%MSBUILD_EXE%" "%ROOT%src\Common.Logging.Log4Net1213\Common.Logging.Log4Net1213.2010-net40.csproj" ^
  /t:Rebuild /p:Configuration=Release /p:FrameworkPathOverride="%FRAMEWORK_PATH%" ^
  /p:Log4NetReferencePath="%LOG4NET_DLL%" /p:CommonLoggingReferencePath="%COMMON_LOGGING_DLL%" ^
  /p:CommonLoggingCoreReferencePath="%COMMON_LOGGING_CORE_DLL%" /v:minimal
if errorlevel 1 exit /b 1

if not exist "%ROOT%package-nuget" mkdir "%ROOT%package-nuget"

"%ROOT%tools\nuget\NuGet.exe" pack "%ROOT%src\Common.Logging.Log4Net1213\Common.Logging.Log4Net1213.nuspec" ^
  -Version "%PACKAGE_VERSION%" -OutputDirectory "%ROOT%package-nuget" -NoPackageAnalysis
if errorlevel 1 exit /b 1

echo Created RADIUM.Common.Logging.Log4Net1213.%PACKAGE_VERSION%.nupkg
endlocal
