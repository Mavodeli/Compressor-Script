@echo off
echo %cd%
echo:

echo Choose mode - regular(cpu)/experimental(gpu)
set /p mode="Type 'r' / 'e' to choose: "
echo:
if "%mode%" == "r" goto :regular
if "%mode%" == "R" goto :regular
if "%mode%" == "e" goto :experimental
if "%mode%" == "E" goto :experimental
echo No mode selected.
echo Aborting...
pause
exit

:experimental
echo Experimental (GPU) mode
echo:
echo This has a high chance of failing, test it on a copy first!

call :experimentalUserInput
call :experimentalCompressItems
goto :end

:regular
echo Regular (CPU) mode
echo:
call :userInput
call :compressItems
goto :end

:userInput
echo Choose the constant rate factor. 
echo Higher values result in smaller files but worse quality.
echo I found 24 to be the highest value with basically no impact on quality. 
echo Reasonable values range from 18 to 28. I use 24 for my clips.
set /p userCRF="I recommend staying within 22 to 26 (whole numbers only): "

call :fileExtensionPickAndConfirm
exit /b

:experimentalUserInput
call :fileExtensionPickAndConfirm
exit /b

:fileExtensionPickAndConfirm
echo: 
set /p fileExtension="File type to search for (like mp4): "
echo:
call :listItems
echo:
echo This will run on all files listed above.

set /p confirm="Type 'Yes' or 'Y' to proceed: "

if "%confirm%" == "y" exit /b
if "%confirm%" == "Y" exit /b
if "%confirm%" == "yes" exit /b
if "%confirm%" == "Yes" exit /b

echo:
echo Aborting...
pause
exit

:listItems
for %%f in (*.%fileExtension%) do (
    (echo "%%f" | FIND /I "_compressed_" 1>NUL) || (
        echo "%%f"
    )
)
for /D %%d in (*) do (
    cd %%d
    call :listItems
    cd ..
)
exit /b

:compressItems
for %%f in (*.%fileExtension%) do (
    (echo "%%f" | FIND /I "_compressed_" 1>NUL) || (
        ffmpeg -n -i "%%f" -vcodec libx264 -crf %userCRF% "_compressed_%%~nf.mp4"
    )
)
for /D %%d in (*) do (
    cd %%d
    call :compressItems
    cd ..
)
exit /b

:experimentalCompressItems
for %%f in (*.%fileExtension%) do (
    (echo "%%f" | FIND /I "_compressed_" 1>NUL) || (
        ffmpeg -n -vsync 0 -extra_hw_frames 8 -hwaccel cuda -hwaccel_output_format cuda -i "%%f" -c:v h264_nvenc -preset p7 -tune hq -b:v 6M -bufsize 6M -maxrate 10M -qmin 0 -g 250 -bf 3 -b_ref_mode middle -temporal-aq 1 -rc-lookahead 20 -i_qfactor 0.75 -b_qfactor 1.1 "_compressed_%%~nf.mp4"
    )
)
for /D %%d in (*) do (
    cd %%d
    call :experimentalCompressItems
    cd ..
)
exit /b

:end
pause
exit