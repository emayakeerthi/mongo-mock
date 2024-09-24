#!/bin/bash

# Number of concurrent users (simultaneous executions)
concurrent_users=70

# Number of repetitions (how many times each user executes the script)
repetitions=1

# Function to run the index.js script
run_test() {
  for i in $(seq 1 $repetitions);  # Fixed: Added $ before repetitions and corrected loop syntax
  do
    node index.js
  done
}

# Export the function so it can be run in parallel
export -f run_test

# Run the test function in parallel with specified concurrent users
seq $concurrent_users | xargs -n1 -P$concurrent_users bash -c 'run_test'
