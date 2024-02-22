#!/bin/bash

# Define the IP address prefix and the range of the last octet
prefix="192.168.107."
start=101
end=106

# Loop through the range and run the SSH command in the background
for i in $(seq $start $end); do
  ip="${prefix}${i}"
  ssh -o StrictHostKeyChecking=no $ip "sudo apt update && sudo apt install -y python3" &
done

# Wait for all background processes to finish
wait

echo "Python installation completed on all nodes."
