#!/bin/sh

# Check if exactly one argument (the slug) is provided
if [ $# -ne 1 ]; then
    echo "Error: Incorrect usage. Please provide exactly one organization slug."
    echo "Usage: $0 <org_slug>"
    exit 1
fi

# Store the org slug
ORG_SLUG=$1

# Create the environment file
echo "Creating environment file for $ORG_SLUG..."
pulumi env open codefold/vercel-multi-domain/${ORG_SLUG}-vite --format dotenv > ./demo-site/.env

# Check if the environment file creation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to create environment file for $ORG_SLUG"
    exit 1
fi

# Change to the demo-site directory
cd ./demo-site || exit 1

# Install dependencies
echo "Installing dependencies..."
pnpm install

# Check if installation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies"
    exit 1
fi

# Build the demo-site
echo "Building the demo-site..."
pnpm build

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to build the demo-site"
    exit 1
fi

echo "Build for $ORG_SLUG completed successfully!"
