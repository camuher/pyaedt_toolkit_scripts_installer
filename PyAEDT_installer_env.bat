@echo off
setlocal enableExtensions EnableDelayedExpansion
REM Author: Carlos A. Mulero Hernandez
REM This file installs pyaedt and adds a launcher for PyAEDT scripts into the toolkits

set argCount=0
for %%x in (%*) do (
   set /a argCount+=1
   set "argVec[!argCount!]=%%~x"
)
set specified_python=n
set update_pyaedt=n
for /L %%i in (1,1,%argCount%) do (
	if [!argVec[%%i]!]==[-u] set update_pyaedt=y
	if [!argVec[%%i]!]==[--update] set update_pyaedt=y
	if [!argVec[%%i]!]==[-p] (
	    set specified_python=y
		set /A python_path_index=%%i+1
	)
)


REM Select what installed version of ansys to install pyAEDT for.
set ENV_VARS=ANSYSEM_ROOT222 ANSYSEM_ROOT221 ANSYSEM_ROOT212 ANSYSEM_ROOT211
set /A choice_index=1
for %%c in (%env_vars%) do (
    set env_var_name=%%c
    if defined !env_var_name! (
        set root_var[!choice_index!]=!env_var_name!
        set version=!env_var_name:ANSYSEM_ROOT=!
        set versions[!choice_index!]=!version!
        set version_pretty=20!version:~0,2! R!version:~2,1!
        echo [!choice_index!]!version_pretty!
	    set /A choice_index=!choice_index!+1
    )
)
REM If choice_index wasn't incremented then it means none of the variables are installed
if [%choice_index%]==1 (
    echo AEDT 2021 R1 or later must be installed.
    pause
    EXIT /B
)
set /p chosen_index="Select Version to Install PyAEDT for (number in bracket): "
set chosen_root=!root_var[%chosen_index%]!
set version=!versions[%chosen_index%]!
echo Selected %version% at !%chosen_root%!

REM find CPython
REM specify the -p flag in order to use a different python. Use an absolute path,
REM -p C:\Python39 for example
REM Do not include python.exe in the python_path.
REM do not include trailing \ in the python_path
set python_path=potato
if [%specified_python%]==[y] (
    python_path=!argVec[%python_path_index%]!
) else (
    set python_path=!%chosen_root%!\commonfiles\CPython\3_7\winx64\Release\python
    echo Built-in python is !python_path!
)
set python_path=!python_path:"=!
@REM set old_dir=%cd%
@REM REM Jump to python directory to install pyaedt from PyPi.
@REM cd "%python_path%"
REM python -m pip install pyaedt
@REM cd %old_dir%

REM if user doens't specify python then it tries to create a virtual environment and sets python_path to this environ
if [%specified_python%]==[n] (
    echo Python Not Specified
    if not exist "%APPDATA%\pyaedt_env\v%version%" (
        echo creating virtual environment at "%APPDATA%\pyaedt_env\v%version%"
        "!python_path!\python.exe" -m venv "%APPDATA%\pyaedt_env\v%version%
        set python_path="%APPDATA%\pyaedt_env\v%version%\Scripts"
        set python_path=!python_path:"=!
    ) else (
        echo Found environment for this version at "%APPDATA%\pyaedt_env\v%version%"
        set python_path="%APPDATA%\pyaedt_env\v%version%\Scripts"
        set python_path=!python_path:"=!
    )
)
echo ------------------------------------------------------
echo Working with python_path: !python_path!
echo -------------------------------------------------------

echo Upgrading pip
"!python_path!\python.exe" -m pip install --upgrade pip
if [!update_pyaedt!]==[y] (
    echo Update-Installing PyAEDT
    "!python_path!\python.exe" -m pip install pyaedt -U
) else (
    echo installing PyAEDT
    "!python_path!\python.exe" -m pip install pyaedt
)
echo Update-Installing IPython
"!python_path!\python.exe" -m pip install ipython -U
"!python_path!\python.exe" -m pip install ipyvtklink

echo -------------------------------------------------

REM create the extra directory in the toolkits
for %%t in (2DExtractor CircuitDesign Emit HFSS HFSS-IE HFSS3DLayoutDesign Icepak Lib Maxwell2D Maxwell3D Q3DExtractor TwinBuilder) do (
@REM for %%t in (HFSS Emit) do (
    set tool_dir=!%chosen_root%:"=!\syslib\Toolkits\%%t\PyAEDT\
    if exist "!tool_dir!" rd /q /s "!tool_dir!"
    mkdir "!tool_dir!"
    REM Creat python_interpreter.bat in the Toolkits\HFSS\PyAEDT directory
    REM This file is used as a config file by cpython_console.py and Run_PyAEDT_Script.py
    cd "!tool_dir!"
    echo Copying Files to !tool_dir!
    echo !python_path!\python.exe> python_interpreter.bat

    REM Copy the other scripts to this directory
    echo Copying console_setup from "%~dp0" to "!cd!"
    xcopy "%~dp0console_setup" "!cd!" /y

    echo Building cpython_console.py
    "!python_path!\python.exe" "%~dp0builder.py" "%~dp0cpython_console.py_build" "!cd!"
    echo Building Run_PyAEDT_Script.py
    "!python_path!\python.exe" "%~dp0builder.py" "%~dp0Run_PyAEDT_Script.py_build" "!cd!"
@REM     for /f %%i in ('Type "%~dp0cpython_console.py_build"') do (
@REM         set line=!%%i:##INSTALL_DIR##=%%t!
@REM         set line=!%%i:##PYTHON_EXE##=%python_path%\python.exe!
@REM         echo writting to "!cd!\cpython_console.py"
@REM         echo !line!>>"!cd!\cpython_console.py"
@REM     )
    REM xcopy "%~dp0Run_PyAEDT_Script.py" "%cd%" /y
)
ECHO *********************
ECHO Installation Complete
ECHO *********************
pause








