#!/bin/bash

# E-commerce Microservices Performance Testing Script
# This script runs various performance tests using Locust

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
HOST="http://127.0.0.1:49941"
RESULTS_DIR="performance-tests/results"
LOG_DIR="performance-tests/logs"

# Create directories
mkdir -p $RESULTS_DIR
mkdir -p $LOG_DIR

echo -e "${BLUE}🚀 Starting E-commerce Microservices Performance Tests${NC}"
echo "=================================================="

# Function to run a performance test
run_test() {
    local test_name=$1
    local users=$2
    local spawn_rate=$3
    local duration=$4
    local description=$5
    
    echo -e "${YELLOW}📊 Running: $description${NC}"
    echo "Users: $users, Spawn Rate: $spawn_rate/s, Duration: ${duration}s"
    
    locust \
        --host=$HOST \
        --users=$users \
        --spawn-rate=$spawn_rate \
        --run-time=$duration \
        --headless \
        --csv=$RESULTS_DIR/${test_name} \
        --html=$RESULTS_DIR/${test_name}_report.html \
        --logfile=$LOG_DIR/${test_name}.log \
        --loglevel=INFO \
        -f locustfile.py
    
    echo -e "${GREEN}✅ Completed: $description${NC}"
    echo ""
}

# Check if Locust is installed
if ! command -v locust &> /dev/null; then
    echo -e "${RED}❌ Locust is not installed. Please install it first:${NC}"
    echo "pip install locust"
    exit 1
fi

# Check if the API Gateway is running
echo -e "${BLUE}🔍 Checking if API Gateway is running...${NC}"
if ! curl -s $HOST/app/api/products > /dev/null; then
    echo -e "${RED}❌ API Gateway is not running at $HOST${NC}"
    echo "Please start the microservices first using Minikube or Docker Compose"
    exit 1
fi
echo -e "${GREEN}✅ API Gateway is running${NC}"
echo ""

# Test 1: Light Load Test
echo -e "${BLUE}📈 Test 1: Light Load Test${NC}"
run_test "light_load" 5 1 60 "Light load test with 5 users for 1 minute"

# Test 2: Medium Load Test
echo -e "${BLUE}📈 Test 2: Medium Load Test${NC}"
run_test "medium_load" 20 2 120 "Medium load test with 20 users for 2 minutes"

# Test 3: Heavy Load Test
echo -e "${BLUE}📈 Test 3: Heavy Load Test${NC}"
run_test "heavy_load" 50 5 180 "Heavy load test with 50 users for 3 minutes"

# Test 4: Stress Test
echo -e "${BLUE}📈 Test 4: Stress Test${NC}"
run_test "stress_test" 100 10 300 "Stress test with 100 users for 5 minutes"

# Test 5: Spike Test
echo -e "${BLUE}📈 Test 5: Spike Test${NC}"
echo -e "${YELLOW}📊 Running: Spike test with varying load${NC}"
echo "This test will gradually increase load to simulate traffic spikes"

# Run spike test with increasing load
for i in {10,25,50,75,100,75,50,25,10}; do
    echo "Running with $i users for 30 seconds..."
    locust \
        --host=$HOST \
        --users=$i \
        --spawn-rate=5 \
        --run-time=30 \
        --headless \
        --csv=$RESULTS_DIR/spike_test_${i}users \
        --logfile=$LOG_DIR/spike_test_${i}users.log \
        --loglevel=INFO \
        -f locustfile.py
done

echo -e "${GREEN}✅ Completed: Spike test${NC}"
echo ""

# Test 6: Endurance Test
echo -e "${BLUE}📈 Test 6: Endurance Test${NC}"
run_test "endurance_test" 30 3 600 "Endurance test with 30 users for 10 minutes"

# Generate summary report
echo -e "${BLUE}📊 Generating Summary Report${NC}"
python3 << 'EOF'
import os
import glob
import pandas as pd
from datetime import datetime

# Get all CSV files
csv_files = glob.glob("performance-tests/results/*_stats.csv")
if not csv_files:
    print("No CSV files found")
    exit(1)

# Create summary
summary = []
for file in csv_files:
    try:
        df = pd.read_csv(file)
        test_name = os.path.basename(file).replace('_stats.csv', '')
        
        # Get the last row (final statistics)
        final_stats = df.iloc[-1]
        
        summary.append({
            'Test': test_name,
            'Users': final_stats.get('User Count', 'N/A'),
            'Requests/sec': round(final_stats.get('Requests/s', 0), 2),
            'Avg Response Time (ms)': round(final_stats.get('Average Response Time', 0), 2),
            '95th Percentile (ms)': round(final_stats.get('95%', 0), 2),
            'Failures': final_stats.get('Failure Count', 0),
            'Total Requests': final_stats.get('Request Count', 0)
        })
    except Exception as e:
        print(f"Error processing {file}: {e}")

if summary:
    summary_df = pd.DataFrame(summary)
    print("\n" + "="*80)
    print("PERFORMANCE TEST SUMMARY")
    print("="*80)
    print(summary_df.to_string(index=False))
    print("="*80)
    
    # Save summary to CSV
    summary_df.to_csv("performance-tests/results/summary.csv", index=False)
    print(f"\nSummary saved to: performance-tests/results/summary.csv")
else:
    print("No valid test results found")
EOF

echo ""
echo -e "${GREEN}🎉 All Performance Tests Completed!${NC}"
echo "=================================================="
echo -e "${BLUE}📁 Results saved in: $RESULTS_DIR${NC}"
echo -e "${BLUE}📁 Logs saved in: $LOG_DIR${NC}"
echo ""
echo -e "${YELLOW}📊 To view detailed reports, open the HTML files in your browser:${NC}"
echo "   - Light Load: $RESULTS_DIR/light_load_report.html"
echo "   - Medium Load: $RESULTS_DIR/medium_load_report.html"
echo "   - Heavy Load: $RESULTS_DIR/heavy_load_report.html"
echo "   - Stress Test: $RESULTS_DIR/stress_test_report.html"
echo "   - Endurance Test: $RESULTS_DIR/endurance_test_report.html"
echo ""
echo -e "${GREEN}✅ Performance testing completed successfully!${NC}"
