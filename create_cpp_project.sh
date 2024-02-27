#!/bin/bash

create_and_setup_project_dir()
{

  mkdir -p $1/$2/include/$2 $1/$2/src

  touch $1/$2/CMakeLists.txt
  
}

OPTSTRING=":p:n:"

while getopts ${OPTSTRING} opt; do

    case ${opt} in
        
        p)
            pathArg=${OPTARG}
        ;;
        n)
            nameArg=${OPTARG}
        ;;
        :)
            echo "Option -${opt} requires an argument."
            exit 1
        ;;  
        ?)
            echo "Invalid option."
            echo "Valid options are -p (Path) and -n (Project Name)"
            exit 1
        ;;
    esac
done

if [ -z ${nameArg+x} ];
  then
    echo "Project name not provided."
    exit 1;
  else
    project_name=${nameArg};
fi

if [ -z ${pathArg+x} ];
  then
    path="/home/$USER";
  else
    path=${pathArg};
fi

create_and_setup_project_dir ${path} ${project_name}

exit 0



