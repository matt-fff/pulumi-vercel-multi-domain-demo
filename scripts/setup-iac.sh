#!/bin/sh

# Error handling function
handle_error() {
    echo "Error: $1"
    if [ -n "$2" ] && command -v deactivate >/dev/null 2>&1; then
        deactivate
    fi
    exit 1
}

# Check if exactly one argument (the slug) is provided
if [ $# -ne 1 ]; then
    handle_error "Incorrect usage. Please provide exactly one organization slug.\nUsage: $0 <org_slug>"
fi

# Store the org slug
ORG_SLUG=$1
PULUMI_ORG="${PULUMI_ORG}"
PULUMI_IAC_PROJECT="${PULUMI_IAC_PROJECT}"
PULUMI_ESC_PROJECT="${PULUMI_ESC_PROJECT}"

# Check if all required environment variables are set
if [ -z "$PULUMI_ORG" ] || [ -z "$PULUMI_IAC_PROJECT" ] || [ -z "$PULUMI_ESC_PROJECT" ]; then
    handle_error "One or more required environment variables are not set.\nPlease ensure PULUMI_ORG, PULUMI_IAC_PROJECT, and PULUMI_ESC_PROJECT are set."
fi

# Create a virtual environment
echo "Creating virtual environment..."
python3 -m venv venv

# Activate the virtual environment
echo "Activating virtual environment..."
. venv/bin/activate

# Install requirements
echo "Installing requirements..."
pip install -r requirements.txt || handle_error "Failed to install requirements" true

# Copy Pulumi.template.yaml to Pulumi.yaml
echo "Generating Pulumi.yaml..."
sed 's|<PULUMI_IAC_PROJECT>|'"${PULUMI_IAC_PROJECT}"'|g' Pulumi.template.yaml > Pulumi.yaml || handle_error "Failed to update Pulumi.yaml" true

# Select the stack
echo "Selecting stack..."
pulumi stack select -c \
            --stack "${PULUMI_ORG}/${PULUMI_IAC_PROJECT}/${ORG_SLUG}" || handle_error "Failed to select stack" 

deactivate
echo "IAC setup for ${ORG_SLUG} completed successfully!"
