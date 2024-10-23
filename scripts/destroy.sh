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


# Run Pulumi destroy
echo "Running Pulumi destroy..."
pulumi env run "${PULUMI_ORG}/${PULUMI_ESC_PROJECT}/${ORG_SLUG}-iac" -- pulumi destroy --yes --non-interactive

# Check if Pulumi destroy was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to run Pulumi destroy"
    cd ..
    exit 1
fi

cd ..

echo "Destruction of ${ORG_SLUG} completed successfully!"

