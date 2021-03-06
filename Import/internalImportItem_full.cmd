REM @ECHO OFF
REM cvsImportEx.cmd internal-use <importEx> <user> <id> <tag> <root> <from> [<to>]

REM GET_USE
IF "%1" == "include" GOTO GET_USE_INCLUDE
IF "%1" == "runtime" GOTO GET_USE_RUNTIME
GOTO SHOW_INTERNAL_USE

:RETURN_GET_USE

REM PARAMETROS
SET CVS_PARENT_IMPORTEX=%2
SET CVS_USER=%3
SET CVS_ID=%4
SET CVS_TAG=%5
SET CVS_ROOT=%6
SET CVS_FROM=%7
SET CVS_TO=%8
SET CVS_TO_LAST_DIR=%~n8
SET CVS_CVSROOT=:pserver:%CVS_USER%@taurus:2401:%CVS_ROOT%
SET CVS_LOGIN_CMD=cvs -d%CVS_CVSROOT% login
IF "%CVS_TO%"=="" (
  SET CVS_CHECKOUT_CMD=cvs -d%CVS_CVSROOT% -r -q export -r %CVS_TAG% -d %CVS_STD_DEST_FOLDER% %CVS_FROM%
) ELSE (
  SET CVS_CHECKOUT_CMD=cvs -d%CVS_CVSROOT% -r -q export -r %CVS_TAG% -d %CVS_TO_LAST_DIR% %CVS_FROM%
)

ECHO --- Download (%1) %CVS_ID% %CVS_ROOT% %CVS_FROM% %CVS_TAG% (%CVS_USER%)

REM RUTINA BAJADA DEPENDENCIA GLOBAL
pushd %CVS_PARENT_IMPORTEX%
if not exist %CVS_STD_DEST_PATH% md %CVS_STD_DEST_PATH%
cd %CVS_STD_DEST_PATH%\..
if "%CVS_TO%"=="" goto NOT_DO_CVS_TO
cd %CVS_STD_DEST_FOLDER%
if not exist %~f8 md %~f8
cd %~f8\..
:NOT_DO_CVS_TO
%CVS_CHECKOUT_CMD%
if %ERRORLEVEL% NEQ 1 goto NOT_DO_LOGIN
%CVS_LOGIN_CMD%
%CVS_CHECKOUT_CMD%
:NOT_DO_LOGIN
popd
GOTO END

:GET_USE_INCLUDE
SET CVS_STD_DEST_PATH=ImportEx
SET CVS_STD_DEST_FOLDER=ImportEx
GOTO RETURN_GET_USE

:GET_USE_RUNTIME
SET CVS_STD_DEST_PATH=ImportEx\Runtime
SET CVS_STD_DEST_FOLDER=Runtime
GOTO RETURN_GET_USE

REM RUTINA AVISO SOLO USO INTERNO
:SHOW_INTERNAL_USE
PAUSE internalImportItem.cmd ONLY FOR INTERNAL USE
GOTO END

REM LIBERAR PARAMETROS
:END
SET CVS_STD_DEST_PATH=
SET CVS_STD_DEST_FOLDER=
SET CVS_PARENT_IMPORTEX=
SET CVS_USER=
SET CVS_ID=
SET CVS_ROOT=
SET CVS_TAG=
SET CVS_FROM=
SET CVS_TO=
SET CVS_TO_LAST_DIR=
SET CVS_CVSROOT=
SET CVS_LOGIN_CMD=
SET CVS_CHECKOUT_CMD=