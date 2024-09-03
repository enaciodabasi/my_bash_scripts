#!/usr/bin/env bash

## Set script to fail after any errors
set -Eeuo pipefail

function script_usage() {
    cat << EOF
Usage:
     -h|--help                  Displays this help
     -v|--verbose               Displays verbose output
     -p|--package               Name of the ROS 2 package to build 
EOF
}

function script_exit() {
  echo $1
}
package_name=""
function parse_params() {
    local param
    while [[ $# -gt 0 ]]; do
        param="$1"
        shift
        case $param in
            -h | --help)
                script_usage
                exit 0
                ;;
            -v | --verbose)
                verbose=true
                ;;
            -p | --package)
                package_name=$1 && shift
                ;;
            *)
                script_exit "Invalid parameter was provided: $param" 1
                ;;
        esac
    done
}

parse_params "$@"

pwd_output="$(pwd)"
installation_file_path="${pwd_output}/install"

if [ ! -d "${pwd_output}/src" ]; then
  echo "Could not locate src file in the current directory. Exiting..."
  exit 1
fi

## Check if install directory exists
if [ ! -d $installation_file_path ]; then
  echo "Could not find workspace/install file. Creating it via colcon build."
fi

## Check if setup.bash file exists
if [ ! -e $installation_file_path/setup.bash ]; then
  echo "Could not locate setup.bash file"
  echo "Building the single package..."
fi

## Source the ROS implementation
ros_distro=$ROS_DISTRO 
if [ -z "${ros_distro}" ]; then
  echo "Could not get ROS 2 distribution. Please source the setup file."
  exit 1
fi

ros_setup_file="/opt/ros/${ros_distro}/setup.bash"

cd "${pwd_output}"
## If package name is empty, build all packages that are found in ./src directory
if [ -z "${package_name}" ]; then
  colcon build --symlink-install
else
  colcon build --packages-select "${package_name}" --symlink-install
fi
exit 0



