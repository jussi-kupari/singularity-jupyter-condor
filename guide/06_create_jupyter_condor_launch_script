#!/bin/bash

# Configuration
PROJECT_DIR=$(pwd)
SINGULARITY_NODE="monod10.mbb.ki.se"
PORT=$(shuf -i 8000-9000 -n 1)
CUSTOM_TOKEN=$(openssl rand -hex 32)

echo "=== Jupyter Lab Launcher ==="
echo "Compute node: $(hostname)"
echo "Singularity node: ${SINGULARITY_NODE}"
echo "Project directory: ${PROJECT_DIR}"
echo "Port: ${PORT}"
echo "Token: ${CUSTOM_TOKEN}"

# Create directories
mkdir -p python_libs

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

# Write connection info
cat > jupyter_connection_info.txt << INFO_EOF
Jupyter Lab Connection Information
==================================
Job started: $(date)
Compute node: $(hostname)
Singularity node: ${SINGULARITY_NODE}
Port: ${PORT}
Username: $(whoami)

To connect:
1. SSH tunnel: ssh -N -L ${PORT}:${SINGULARITY_NODE}:${PORT} $(whoami)@monod.mbb.ki.se
2. Browser: http://localhost:${PORT}
3. Use this token for authentication: ${CUSTOM_TOKEN}
   Or use the direct URL: http://localhost:${PORT}/?token=${CUSTOM_TOKEN}

Job will keep running until manually stopped.
==================================
INFO_EOF

echo "All tests passed. Starting Jupyter Lab..."
echo "Connection details written to: ${PROJECT_DIR}/jupyter_connection_info.txt"

# SSH to Singularity node and run Jupyter Lab
ssh -o StrictHostKeyChecking=no ${SINGULARITY_NODE} "
    echo 'Connected to ${SINGULARITY_NODE}';
    cd '${PROJECT_DIR}' || exit 1;
    mkdir -p python_libs;
    echo 'Starting Jupyter Lab...';
    singularity exec \
        --bind '${PROJECT_DIR}:/project' \
        --bind '${PROJECT_DIR}/python_libs:/project/python_libs' \
        scanpy.sif \
        jupyter lab --ip=0.0.0.0 --port=${PORT} --no-browser --allow-root --NotebookApp.token=${CUSTOM_TOKEN}
"
echo "Jupyter Lab session ended at $(date)"
