CALL %ROOT%\build\helpers\setvars.cmd

IF NOT EXIST %DEPENDENCIES_BIN_DIR% (
  IF EXIST %DOWNLOADS_DIR%\%DEPS_ZIP% (
    7z x %DOWNLOADS_DIR%\%DEPS_ZIP% -o%DEPENDENCIES_BIN_DIR% -y
  ) ELSE (
    ECHO "You need to build PostgreSQL dependencies first!"
    EXIT /B 1 || GOTO :ERROR
  )
)

IF NOT EXIST %BUILD_DIR%\distr_%ARCH%_%PGVER%\postgresql (
  IF EXIST %DOWNLOADS_DIR%\pgsql_%ARCH%_%PGVER%.zip (
    7z x %DOWNLOADS_DIR%\pgsql_%ARCH%_%PGVER%.zip -o%BUILD_DIR%\distr_%ARCH%_%PGVER%\postgresql -y
  ) ELSE (
    ECHO "You need to build PostgreSQL first!"
    EXIT /B 1 || GOTO :ERROR
  )
)

:BUILD_ALL

:BUILD_WXWIDGETS
TITLE Building wxWidgets...
CD %DOWNLOADS_DIR%
wget --no-check-certificate -c https://sourceforge.net/projects/wxwindows/files/%WXWIDGETS_VER%/wxWidgets-%WXWIDGETS_VER%.tar.bz2 -O wxWidgets-%WXWIDGETS_VER%.tar.bz2
rm -rf %DEPENDENCIES_BIN_DIR%\wxwidgets %DEPENDENCIES_SRC_DIR%\wxWidgets-*
MKDIR %DEPENDENCIES_BIN_DIR%\wxwidgets
tar xf wxWidgets-%WXWIDGETS_VER%.tar.bz2 -C %DEPENDENCIES_SRC_DIR% || GOTO :ERROR
CD %DEPENDENCIES_SRC_DIR%\wxWidgets-*

IF %SDK% == SDK71 (
  IF %ARCH% == X86 msbuild build\msw\wx_vc10.sln  /m /p:Configuration="Release" /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
  IF %ARCH% == X86 msbuild build\msw\wx_vc10.sln  /m /p:Configuration="DLL Release" /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
  IF %ARCH% == X64 msbuild build\msw\wx_vc10.sln  /m /p:Configuration="Release" /p:Platform=x64 /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
  IF %ARCH% == X64 msbuild build\msw\wx_vc10.sln  /m /p:Configuration="DLL Release" /p:Platform=x64 /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
)

IF %SDK% == MSVC2013 (
  IF %ARCH% == X86 msbuild build\msw\wx_vc12.sln  /m /p:Configuration="Release" /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
  IF %ARCH% == X86 msbuild build\msw\wx_vc12.sln  /m /p:Configuration="DLL Release" /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
  IF %ARCH% == X64 msbuild build\msw\wx_vc12.sln  /m /p:Configuration="Release" /p:Platform=x64 /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
  IF %ARCH% == X64 msbuild build\msw\wx_vc12.sln  /m /p:Configuration="DLL Release" /p:Platform=x64 /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
)

IF %SDK% == MSVC2015 (
  IF %ARCH% == X86 msbuild build\msw\wx_vc12.sln  /m /p:Configuration="Release" /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
  IF %ARCH% == X86 msbuild build\msw\wx_vc12.sln  /m /p:Configuration="DLL Release" /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
  IF %ARCH% == X64 msbuild build\msw\wx_vc12.sln  /m /p:Configuration="Release" /p:Platform=x64 /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
  IF %ARCH% == X64 msbuild build\msw\wx_vc12.sln  /m /p:Configuration="DLL Release" /p:Platform=x64 /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
)

cp -va %DEPENDENCIES_SRC_DIR%/wxWidgets-3*/lib      %DEPENDENCIES_BIN_DIR%\wxwidgets  || GOTO :ERROR
IF %ARCH% == X64 (
  mv -v %DEPENDENCIES_BIN_DIR%/wxwidgets/lib/vc_*dll   %DEPENDENCIES_BIN_DIR%\wxwidgets\lib\vc_dll  || GOTO :ERROR
  mv -v %DEPENDENCIES_BIN_DIR%/wxwidgets/lib/vc_*lib   %DEPENDENCIES_BIN_DIR%\wxwidgets\lib\vc_lib  || GOTO :ERROR
)
cp -va %DEPENDENCIES_SRC_DIR%/wxWidgets-3*/include  %DEPENDENCIES_BIN_DIR%\wxwidgets\include  || GOTO :ERROR
7z a -r %DOWNLOADS_DIR%\%DEPS_ZIP% %DEPENDENCIES_BIN_DIR%\wxwidgets


:BUILD_PGADMIN
TITLE Building PgAdmin3...
CD %DOWNLOADS_DIR%
wget --no-check-certificate -c https://ftp.postgresql.org/pub/pgadmin3/release/v%PGADMIN_VERSION%/src/pgadmin3-%PGADMIN_VERSION%.tar.gz -O pgadmin3-%PGADMIN_VERSION%.tar.gz
rm -rf %BUILD_DIR%\pgadmin
MKDIR %BUILD_DIR%\pgadmin
tar xf pgadmin3-%PGADMIN_VERSION%.tar.gz -C %BUILD_DIR%\pgadmin
CD %BUILD_DIR%\pgadmin\pgadmin3-*
SET OPENSSL=%DEPENDENCIES_BIN_DIR%\openssl
SET WXWIN=%DEPENDENCIES_BIN_DIR%\wxwidgets
SET PGBUILD=%DEPENDENCIES_BIN_DIR%
SET PGDIR=%BUILD_DIR%\distr_%ARCH%_%PGVER%\postgresql
SET PROJECTDIR=
cp -a %DEPENDENCIES_BIN_DIR%/libssh2/include/* pgadmin\include\libssh2 || GOTO :ERROR
IF %ARCH% == X64 sed -i 's/Win32/x64/g' xtra\png2c\png2c.vcxproj
IF %ARCH% == X64 sed -i 's/Win32/x64/g' pgadmin\pgAdmin3.vcxproj
sed -i "/<Bscmake>/,/<\/Bscmake>/d" pgadmin\pgAdmin3.vcxproj
IF %ARCH% == X86 msbuild xtra/png2c/png2c.vcxproj /m /p:Configuration="Release (3.0)" /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
IF %ARCH% == X64 msbuild xtra/png2c/png2c.vcxproj /m /p:Configuration="Release (3.0)" /p:Platform=x64 /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
cp -va xtra pgadmin || GOTO :ERROR
IF %ARCH% == X86 msbuild pgadmin/pgAdmin3.vcxproj /m /p:Configuration="Release (3.0)" /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
IF %ARCH% == X64 msbuild pgadmin/pgAdmin3.vcxproj /m /p:Configuration="Release (3.0)" /p:Platform=x64 /p:PlatformToolset=%PlatformToolset% || GOTO :ERROR
rm -rf %BUILD_DIR%\distr_%ARCH%_%PGVER%\pgadmin
MKDIR %BUILD_DIR%\distr_%ARCH%_%PGVER%\pgadmin %BUILD_DIR%\distr_%ARCH%_%PGVER%\pgadmin\bin %BUILD_DIR%\distr_%ARCH%_%PGVER%\pgadmin\lib
cp -va pgadmin/Release*/*.exe %BUILD_DIR%\distr_%ARCH%_%PGVER%\pgadmin\bin  || GOTO :ERROR
cp -va i18n c:/pg/distr_%ARCH%_%PGVER%/pgadmin/bin  || GOTO :ERROR
cp -va c:/pg/distr_%ARCH%_%PGVER%/postgresql/bin/*.dll %BUILD_DIR%\distr_%ARCH%_%PGVER%\pgadmin\bin  || GOTO :ERROR
cp -va %DEPENDENCIES_BIN_DIR%/wxwidgets/lib/vc_dll/*.dll  %BUILD_DIR%\distr_%ARCH%_%PGVER%\pgadmin\bin  || GOTO :ERROR


GOTO :DONE

:ERROR
ECHO Failed with error #%errorlevel%.
PAUSE
EXIT /b %errorlevel%

:DONE
ECHO Done.
PAUSE