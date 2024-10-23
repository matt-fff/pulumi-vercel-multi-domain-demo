#!/bin/sh

# Check if exactly one argument (the slug) is provided
if [ $# -ne 1 ]; then
    echo "Error: Incorrect usage. Please provide exactly one organization slug."
    echo "Usage: $0 <org_slug>"
    exit 1
fi

# Store the org slug
ORG_SLUG=$1
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
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
cd "${SCRIPT_DIR}/../iac"

if [ $? -ne 0 ]; then
    echo "Error: Failed to change to iac directory"
    exit 1
fi

# Run setup-iac.sh script
if ! "${SCRIPT_DIR}/setup-iac.sh" "${ORG_SLUG}"; then
    echo "Error: Failed to setup IAC for ${ORG_SLUG}"
    echo "${SCRIPT_DIR}/setup-iac.sh ${ORG_SLUG}"
    cd ..
    exit 1
fi

# Run Pulumi up
echo "Running Pulumi up..."
pulumi env run "${PULUMI_ORG}/${PULUMI_ESC_PROJECT}/${ORG_SLUG}-iac" -- pulumi up --yes --non-interactive

# Check if Pulumi up was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to run Pulumi up"
    cd ..
    exit 1
fi

cd ..

echo "Deployment for ${ORG_SLUG} completed successfully!"

