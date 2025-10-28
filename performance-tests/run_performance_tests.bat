@echo off
REM E-commerce Microservices Performance Testing Script for Windows
REM This script runs various performance tests using Locust

setlocal enabledelayedexpansion

REM Configuration
set HOST=http://127.0.0.1:49941
set RESULTS_DIR=performance-tests\results
set LOG_DIR=performance-tests\logs

REM Create directories
if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo 🚀 Starting E-commerce Microservices Performance Tests
echo ==================================================

REM Check if Locust is installed
where locust >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Locust is not installed. Please install it first:
    echo pip install locust
    exit /b 1
)

REM Check if the API Gateway is running
echo 🔍 Checking if API Gateway is running...
curl -s %HOST%/app/api/products >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ API Gateway is not running at %HOST%
    echo Please start the microservices first using Minikube or Docker Compose
    exit /b 1
)
echo ✅ API Gateway is running
echo.

REM Function to run a performance test
:run_test
set test_name=%1
set users=%2
set spawn_rate=%3
set duration=%4
set description=%5

echo 📊 Running: %description%
echo Users: %users%, Spawn Rate: %spawn_rate%/s, Duration: %duration%s

locust --host=%HOST% --users=%users% --spawn-rate=%spawn_rate% --run-time=%duration% --headless --csv=%RESULTS_DIR%\%test_name% --html=%RESULTS_DIR%\%test_name%_report.html --logfile=%LOG_DIR%\%test_name%.log --loglevel=INFO -f locustfile.py

echo ✅ Completed: %description%
echo.
goto :eof

REM Test 1: Light Load Test
echo 📈 Test 1: Light Load Test
call :run_test "light_load" 5 1 60 "Light load test with 5 users for 1 minute"

REM Test 2: Medium Load Test
echo 📈 Test 2: Medium Load Test
call :run_test "medium_load" 20 2 120 "Medium load test with 20 users for 2 minutes"

REM Test 3: Heavy Load Test
echo 📈 Test 3: Heavy Load Test
call :run_test "heavy_load" 50 5 180 "Heavy load test with 50 users for 3 minutes"

REM Test 4: Stress Test
echo 📈 Test 4: Stress Test
call :run_test "stress_test" 100 10 300 "Stress test with 100 users for 5 minutes"

REM Test 5: Endurance Test
echo 📈 Test 5: Endurance Test
call :run_test "endurance_test" 30 3 600 "Endurance test with 30 users for 10 minutes"

echo.
echo 🎉 All Performance Tests Completed!
echo ==================================================
echo 📁 Results saved in: %RESULTS_DIR%
echo 📁 Logs saved in: %LOG_DIR%
echo.
echo 📊 To view detailed reports, open the HTML files in your browser:
echo    - Light Load: %RESULTS_DIR%\light_load_report.html
echo    - Medium Load: %RESULTS_DIR%\medium_load_report.html
echo    - Heavy Load: %RESULTS_DIR%\heavy_load_report.html
echo    - Stress Test: %RESULTS_DIR%\stress_test_report.html
echo    - Endurance Test: %RESULTS_DIR%\endurance_test_report.html
echo.
echo ✅ Performance testing completed successfully!

pause
