#!/bin/bash

# Get the directory where this script is located (project root)
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create python_libs directory if it doesn't exist
mkdir -p "${PROJECT_DIR}/python_libs"

# Set pip to use --user by default
export PIP_USER=1
# Add user-installed scripts to PATH
export PATH="/project/python_libs/bin:$PATH"

# Launch container
singularity exec \
        --bind "${PROJECT_DIR}:/project" \
            --bind "${PROJECT_DIR}/python_libs:/project/python_libs" \
                "${PROJECT_DIR}"/scanpy.sif \
                    python "$@"
