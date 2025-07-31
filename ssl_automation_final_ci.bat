@echo off
setlocal enabledelayedexpansion

set CERT_PATH=demo.crt
set KEY_PATH=demo.key
set LOG_FILE=ssl_automation_log.txt

echo =========================================
echo 🔐 Running SSL Automation in CI/CD Environment
echo =========================================

:: STEP 1: Generate a short-lived certificate (1-day validity)
openssl req -x509 -nodes -days 1 -newkey rsa:2048 -keyout %KEY_PATH% -out %CERT_PATH% -subj "/CN=localhost"
if errorlevel 1 (
    echo ❌ OpenSSL failed to generate certificate.
    exit /b 1
)

echo ✅ Certificate created.
for /f "tokens=2 delims==" %%i in ('openssl x509 -enddate -noout -in %CERT_PATH%') do set exp=%%i
echo Certificate Expires On: !exp!

:: Simulate days left for testing
set daysleft=3

:: STEP 2: Log warnings if needed
if !daysleft! LEQ 5 if !daysleft! GTR 2 (
    echo ⚠️ WARNING: Certificate will expire soon (!daysleft! days left)
    echo. >> %LOG_FILE%
    echo [!date! !time!] WARNING - !daysleft! days left >> %LOG_FILE%
)

if !daysleft! LEQ 2 if !daysleft! GTR 0 (
    echo 🔴 CRITICAL: Certificate is near expiry (!daysleft! days left)
    echo. >> %LOG_FILE%
    echo [!date! !time!] CRITICAL - !daysleft! days left >> %LOG_FILE%
)

:: STEP 3: Simulate auto-renewal
echo 🔄 Auto-renewal triggered...
openssl req -x509 -nodes -days 5 -newkey rsa:2048 -keyout %KEY_PATH% -out %CERT_PATH% -subj "/CN=localhost"
echo ✅ New certificate generated.
echo. >> %LOG_FILE%
echo [!date! !time!] EXPIRED - Auto-renewed successfully >> %LOG_FILE%

echo =========================================
echo ✅ Log saved to %LOG_FILE%
