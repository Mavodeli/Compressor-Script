@echo off
echo %cd%
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

:end
pause
exit