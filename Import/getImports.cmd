@ECHO OFF
REM Change to batch path
rem PUSHD %~dp0

REM getImports.cmd [<user>]

GOTO :START
REM ============================================================================
REM VARIABLES IMPORTEX

:START
SET CVS_IMPORTEX=..

set /p RESP="FULL INSTALL o PASO A PASO ? [F/S] :" %=%


if  "%RESP%"=="F" ( goto FULL_REMOVE) else ( goto STEP_REMOVE) 

:FULL_REMOVE

	FOR /d %%i IN ( "%CVS_IMPORTEX%\ImportEx\*" ) DO (
	ECHO Purgue %%i folders...
	RMDIR  %CVS_IMPORTEX%\ImportEx\%%i
	)
 GOTO GET_USUARIO

:STEP_REMOVE

FOR /d %%i IN ( "%CVS_IMPORTEX%\ImportEx\*" ) DO (
	ECHO Purgue %%i folders...
	RMDIR /S  %CVS_IMPORTEX%\ImportEx\%%i
  )
  
GOTO GET_USUARIO

REM ============================================================================
REM GET USUARIO

:RETURN_GET_USUARIO
	if  "%RESP%"=="F" ( goto RETURN_GET_USUARIO_FULL) else ( goto RETURN_GET_USUARIO_STEP) 
	
:RETURN_GET_USUARIO_FULL

SET CVS_INCLUDE=CALL internalImportItem_full.cmd include %CVS_IMPORTEX% %CVS_USERNAME%  
SET CVS_RUNTIME=CALL internalImportItem_full.cmd runtime %CVS_IMPORTEX% %CVS_USERNAME%  

copy /Y imports.txt temp_imports_txt.cmd
CALL temp_imports_txt.cmd
del temp_imports_txt.cmd

REM ============================================================================
REM Purge other OS (not Win32) folders
FOR %%i IN (unix Linux-x86-2.4 Linux-x86-2.6 SunOS-i86pc SunOS-sun4v Linux-i686 Linux-i686-2.4 Linux-i686-2.6) DO (
  ECHO Purgue %%i folders...
  FOR /r %CVS_IMPORTEX%\ImportEx %%f IN (%%i) DO @RD /s/q %%f >NUL 2>NUL
)
GOTO END


:RETURN_GET_USUARIO_STEP

SET CVS_INCLUDE=CALL internalImportItem.cmd include %CVS_IMPORTEX% %CVS_USERNAME%  
SET CVS_RUNTIME=CALL internalImportItem.cmd runtime %CVS_IMPORTEX% %CVS_USERNAME%  

copy /Y imports.txt temp_imports_txt.cmd
CALL temp_imports_txt.cmd
del temp_imports_txt.cmd

REM ============================================================================
REM Purge other OS (not Win32) folders
FOR %%i IN (unix Linux-x86-2.4 Linux-x86-2.6 SunOS-i86pc SunOS-sun4v Linux-i686 Linux-i686-2.4 Linux-i686-2.6) DO (
  ECHO Purgue %%i folders...
  FOR /r %CVS_IMPORTEX%\ImportEx %%f IN (%%i) DO @RD /s/q %%f >NUL 2>NUL
)
GOTO END

REM ============================================================================
:GET_USUARIO
set CVS_USERNAME=%USERNAME%
if "%1" == "" (
  set CVS_USERNAME=%USERNAME%
) else (
  set CVS_USERNAME=%1
)
if "%CVS_USERNAME%" NEQ "" GOTO RETURN_GET_USUARIO
ECHO Unknown user for cvs
GOTO SHOW_SYNTAX

REM ============================================================================
:SHOW_SYNTAX
ECHO getImports [user]
GOTO END

REM ============================================================================
:END
SET CVS_IMPORTEX=
SET CVS_USERNAME=
SET CVS_INCLUDE=
SET CVS_RUNTIME=
REM Change to initial path
POPD

ECHO ...process finished
PAUSE