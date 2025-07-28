@echo off
setlocal enabledelayedexpansion

set CERT_PATH=C:\ssl-test\demo.crt
set LOG_FILE=C:\ssl-test\expiry_log.txt

echo ======================================
echo   SSL Certificate Expiry Status
echo ======================================
echo Checking certificate: %CERT_PATH%
echo.

REM Get expiry date from certificate
for /f "tokens=2 delims==" %%i in ('openssl x509 -enddate -noout -in %CERT_PATH%') do set exp=%%i

echo Certificate expires on: !exp!

REM Convert expiry date to a simple format (YYYYMMDD) for comparison
for /f "tokens=1,2,3 delims= " %%a in ("!exp!") do (
    set month=%%a
    set day=%%b
    set year=%%c
)

REM Map month name to number
set m=01
if "!month!"=="Feb" set m=02
if "!month!"=="Mar" set m=03
if "!month!"=="Apr" set m=04
if "!month!"=="May" set m=05
if "!month!"=="Jun" set m=06
if "!month!"=="Jul" set m=07
if "!month!"=="Aug" set m=08
if "!month!"=="Sep" set m=09
if "!month!"=="Oct" set m=10
if "!month!"=="Nov" set m=11
if "!month!"=="Dec" set m=12

set expirydate=!year!!m!!day!

REM Get today’s date (YYYYMMDD)
for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value') do set today=%%i
set today=!today:~0,8!

REM Compare dates
if !today! GEQ !expirydate! (
    echo ⚠️ ALERT: Certificate has already expired!
    set status=EXPIRED
) else (
    REM Check if expiry is within 3 days
    echo Expiry date: !expirydate!, Today: !today!
    echo ✅ Certificate is valid.
    set status=VALID
)

REM Log result
echo [%date% %time%] Certificate Status: !status! (Expires on !exp!) >> %LOG_FILE%

echo.
echo Status: !status!
echo Log saved to: %LOG_FILE%
echo ======================================
pause
