#!/bin/bash
# Configuration
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SINGULARITY_NODE="monod10.mbb.ki.se"
PORT=$(shuf -i 8000-9000 -n 1)
CUSTOM_TOKEN=$(openssl rand -hex 32)

echo "=== Jupyter Lab Launcher (Interactive) ==="
echo "Current node: $(hostname)"
echo "Singularity node: ${SINGULARITY_NODE}"
echo "Project directory: ${PROJECT_DIR}"
echo "Port: ${PORT}"
echo "Token: ${CUSTOM_TOKEN}"

# Create directories
mkdir -p "${PROJECT_DIR}/python_libs"

# Set pip to use --user by default
export PIP_USER=1

# Add user-installed scripts to PATH
export PATH="/project/python_libs/bin:$PATH"

# Test SSH connection
echo "Testing SSH connection to ${SINGULARITY_NODE}..."
if ! ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no ${SINGULARITY_NODE} "echo 'SSH connection successful'"; then
    echo "ERROR: Cannot SSH to ${SINGULARITY_NODE}"
    exit 1
fi

# Test if Singularity is available on target node
echo "Testing Singularity on ${SINGULARITY_NODE}..."
if ! ssh -o StrictHostKeyChecking=no ${SINGULARITY_NODE} "command -v singularity >/dev/null 2>&1"; then
    echo "ERROR: Singularity not found on ${SINGULARITY_NODE}"
    exit 1
fi

# Test if container exists
echo "Testing container access..."
if ! ssh -o StrictHostKeyChecking=no ${SINGULARITY_NODE} "test -f '${PROJECT_DIR}/scanpy.sif'"; then
    echo "ERROR: Container not found at ${PROJECT_DIR}/scanpy.sif on ${SINGULARITY_NODE}"
    exit 1
fi

echo ""
echo "All tests passed. Starting Jupyter Lab..."
echo ""
echo "To access Jupyter Lab:"
echo "1. Set up SSH tunnel: ssh -N -L ${PORT}:${SINGULARITY_NODE}:${PORT} $(whoami)@monod.mbb.ki.se"
echo "2. Open browser to: http://localhost:${PORT}"
echo "3. Use this token for authentication: ${CUSTOM_TOKEN}"
echo "   Or use direct URL: http://localhost:${PORT}/?token=${CUSTOM_TOKEN}"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# SSH to Singularity node and run Jupyter Lab
ssh -o StrictHostKeyChecking=no ${SINGULARITY_NODE} "
    echo 'Connected to ${SINGULARITY_NODE}';
    cd '${PROJECT_DIR}' || exit 1;
    mkdir -p python_libs;
    echo 'Starting Jupyter Lab with custom token...';
    singularity exec \
        --bind '${PROJECT_DIR}:/project' \
        --bind '${PROJECT_DIR}/python_libs:/project/python_libs' \
        scanpy.sif \
        jupyter lab --ip=0.0.0.0 --port=${PORT} --no-browser --allow-root \
        --NotebookApp.token='${CUSTOM_TOKEN}' --NotebookApp.password=''
"

echo "Jupyter Lab session ended at $(date)"
