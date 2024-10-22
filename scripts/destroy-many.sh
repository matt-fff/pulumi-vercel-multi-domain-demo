#!/bin/sh

# Check if any arguments were provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <slug1> <slug2> <slug3> ..."
    exit 1
fi

# Loop through all provided slugs
for slug in "$@"
do
    echo "Destroying for organization: $slug"
    
    # Run deploy.sh with the current slug as a parameter
    ./scripts/destroy.sh "$slug"
    
    # Check the exit status of deploy.sh
    if [ $? -eq 0 ]; then
        echo "Destruction successful for $slug"
    else
        echo "Destruction failed for $slug"
    fi
    
    echo "-----------------------------------"
done

echo "All destructions completed."

