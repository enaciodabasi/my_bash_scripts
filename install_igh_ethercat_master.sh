#!/bin/bash

set -e ### Terminates the script if the output of an operation is not 0

required_packages_str=("git", "build-essential", "libtool", "automake", "nasm", "pkgconf")

check_requirements()
{
  for package in ${required_packages_str[@]}; do
    if [ $(dpkg-query -W -f='${Status}' ${package} 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
      apt install $package;
    fi
  done
}

options="$(getopt --name $0 --option p:b:c:n: --longoptions downloadPath:,branchName:,configOptions:,networkInterface: -- "$@")"
eval set -- $params

download_path="/home/${USER}/"
branch_name=
config_options=

while [ $# -gt 0]
do
  case ${1} in

    -p | --downloadPath)
      download_path=$2 && shift
    ;;
    -b | branchName)
      branch_name=$2 && shift
    ;;
    -c | --configOptions
      config_options=$2 && shift
    ;;
    --)
      break;
    ;;
  esac
done

download_link="https://gitlab.com/etherlab.org/ethercat.git"

cd $download_path;

## Check if a branch name is specified
if [[ -z "${branch_name}" ]]; then
  git clone $download_link
else
  git clone -b $branch_name $download_link
fi

if [ ! -d ${download_path}/ethercat ] then
  echo "Could not clone the repository. Aborting..."
  exit -1
fi

cd ${download_path}/ethercat

if [[ -e booststrap ]]; then
  ./booststrap
else
  exit -1
fi

if [[ -e configure]]; then
  ./configure ${config_options}
else
  exit -1
fi

make

make modules

make modules_install isntall

depmod

### If necessary files are installed by IgH, create symbolic links to them in the root /etc directory
if [[ -d /usr/local/etc/sysconfig && -e /usr/local/etc/init.d/ethercat.conf && -e /usr/local/etc/ethercat.conf ]]; then
  
  ## Check if sysconfig exists
  if [[ -d /etc/sysconfig ]]; then

  else
    mkdir /etc/sysconfig
  fi
  ## Link sysconfigs contents
  ln /usr/local/etc/sysconfig/ethercat /etc/sysconfig/ethercat

  ## Check if init.d exists
  if [[ -d /etc/sysconfig ]]; then

  else
    mkdir /etc/init.d
  fi
  ## link the service file
  ln /usr/local/etc/init.d/ethercat /etc/init.d/ethercat

  ## link the config file
  ln /usr/local/etc/ethercat.conf /etc/ethercat.conf

  ## get MAC address of the ethernet device
  mac_addr="$(ip add | grep link/ether | grep -o  '\([a-fA-F0-9]\{2\}:\)\{5\}[a-fA-F0-9]\{2\}[[:space:]]')"

  if [[ -n ${mac_addr} ]]; then
    sed -i "s/MASTER0_DEVICE=""/MASTER0_DEVICE="${mac_addr}"/"
    sed -i "s/DEVICE_MODULES=""/DEVICE_MODULES="generic"/"
  else
    echo "Coult not get MAC address, skipping..."
  fi
  
  echo "KERNEL==EtherCAT[0-9]*, MODE=0664, GROUP=users" > /etc/udev/rules.d/99-EtherCAT.rule ;

else
  echo "IgH could not install the necesarry files. Please try again"
  exit 1
fi

echo "Succesfuly installed IgH EtherCAT master."
exit 0