#!/bin/sh

# Check if exactly one argument (the slug) is provided
if [ $# -ne 1 ]; then
    echo "Error: Incorrect usage. Please provide exactly one organization slug."
    echo "Usage: $0 <org_slug>"
    exit 1
fi

# Store the org slug
ORG_SLUG=$1
PULUMI_ORG="${PULUMI_ORG}"
PULUMI_IAC_PROJECT="${PULUMI_IAC_PROJECT}"
PULUMI_ESC_PROJECT="${PULUMI_ESC_PROJECT}"

# Check if all required environment variables are set
if [ -z "$PULUMI_ORG" ] || [ -z "$PULUMI_IAC_PROJECT" ] || [ -z "$PULUMI_ESC_PROJECT" ]; then
    echo "Error: One or more required environment variables are not set."
    echo "Please ensure PULUMI_ORG, PULUMI_IAC_PROJECT, and PULUMI_ESC_PROJECT are set."
    exit 1
fi

# Create the environment file
echo "Creating environment file for ${ORG_SLUG}..."
pulumi env open ${PULUMI_ORG}/${PULUMI_ESC_PROJECT}/${ORG_SLUG}-iac --format dotenv > ./iac/.env

# Check if the environment file creation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to create environment file for ${ORG_SLUG}"
    exit 1
fi

# Change to the iac directory
cd ./iac || exit 1

# Create a virtual environment
echo "Creating virtual environment..."
python3 -m venv venv

# Activate the virtual environment
echo "Activating virtual environment..."
. venv/bin/activate

# Install requirements
echo "Installing requirements..."
pip install -r requirements.txt

# Check if installation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to install requirements"
    deactivate
    exit 1
fi

# Copy Pulumi.template.yaml to Pulumi.yaml
echo "Generating Pulumi.yaml..."
sed 's|<PULUMI_IAC_PROJECT>|'"${PULUMI_IAC_PROJECT}"'|g' Pulumi.template.yaml > Pulumi.yaml

# Check if the file update was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to update Pulumi.yaml"
    deactivate
    exit 1
fi



# Select the stack
echo "Selecting stack..."
pulumi stack select -c \
            --stack "${PULUMI_ORG}/${PULUMI_IAC_PROJECT}/${ORG_SLUG}"

# Check if the stack selection was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to select stack"
    deactivate
    exit 1
fi

# Run Pulumi up
echo "Running Pulumi up..."
pulumi env run "${PULUMI_ORG}/${PULUMI_ESC_PROJECT}/${ORG_SLUG}-iac" -- pulumi up --yes --non-interactive

# Check if Pulumi up was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to run Pulumi up"
    deactivate
    exit 1
fi

# Deactivate the virtual environment
deactivate

# Change back to the original directory
cd ../demo-site || exit 1


echo "Deployment for ${ORG_SLUG} completed successfully!"

