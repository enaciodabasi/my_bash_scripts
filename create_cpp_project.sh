#!/bin/bash

create_and_setup_project_dir()
{

  # Check if directory already exists.
  if [ -d $1/$2 ];
    then
      # Ask user for permission to delete and recreate the directory.
      echo "Directory already exists. Delete and recreate?"
      read delete

      if [ "$delete" == "y" ];
        then
          rm -rf $1/$2;
        else
          exit 1;
      fi 

  fi

  mkdir -p $1/$2/include/$2 $1/$2/src

  touch $1/$2/CMakeLists.txt
  touch $1/$2/${nameArg}.cmake.in
  
}

fill_cmake_files()
{
  cat << EOF > $1/$2/CMakeLists.txt
cmake_minimum_required(VERSION 3.1.0)
project(${nameArg} VERSION 0.0.1 LANGUAGES C CXX)

if(CMAKE_CXX_COMPILER_ID MATCHES "(GNU|Clang)")
  add_compile_options(-Wall -Wextra -Werror=conversion -Werror=unused-but-set-variable -Werror=return-type)
endif()

set(SOURCES

)

add_library(
  \${CMAKE_PROJECT_NAME}
  SHARED
  \${SOURCES}
)
target_compile_features(
  \${CMAKE_PROJECT_NAME}
  PUBLIC cxx_std_23
)
target_include_directories(
  \${CMAKE_PROJECT_NAME}
  PUBLIC
  include/
)
target_link_libraries(
  \${CMAKE_PROJECT_NAME}
)

set(GENERAL_INSTALL_DIR /usr/local)
set(INCLUDE_INSTALL_DIR \${GENERAL_INSTALL_DIR}/include)
set(LIBS_INSTALL_DIR \${GENERAL_INSTALL_DIR}/lib) 

install(
  TARGETS \${CMAKE_PROJECT_NAME}
  ARCHIVE DESTINATION \${LIBS_INSTALL_DIR}/\${CMAKE_PROJECT_NAME}
  LIBRARY DESTINATION \${LIBS_INSTALL_DIR}/\${CMAKE_PROJECT_NAME}
)

install(
  DIRECTORY include/
  DESTINATION \${INCLUDE_INSTALL_DIR}/\${CMAKE_PROJECT_NAME}
)

include(CMakePackageConfigHelpers)
set(INCLUDE_INSTALL_DIR \${INCLUDE_INSTALL_DIR}/\${CMAKE_PROJECT_NAME})
set(LIB_INSTALL_DIR \${LIBS_INSTALL_DIR}/\${CMAKE_PROJECT_NAME})
set(SH_LIB_FILE_NAME lib\${CMAKE_PROJECT_NAME}.so)
set(LIBS \${LIB_INSTALL_DIR}/\${SH_LIB_FILE_NAME})

configure_package_config_file(
\${CMAKE_PROJECT_NAME}.cmake.in
  \${CMAKE_CURRENT_BINARY_DIR}/\${CMAKE_PROJECT_NAME}Config.cmake
  INSTALL_DESTINATION /usr/local/lib/cmake/\${CMAKE_PROJECT_NAME}
  PATH_VARS INCLUDE_INSTALL_DIR LIB_INSTALL_DIR LIBS
)
write_basic_package_version_file(
  \${CMAKE_CURRENT_BINARY_DIR}/\${CMAKE_PROJECT_NAME}ConfigVersion.cmake
  VERSION 1.0.0
  COMPATIBILITY AnyNewerVersion
)

install(FILES \${CMAKE_CURRENT_BINARY_DIR}/\${CMAKE_PROJECT_NAME}Config.cmake \${CMAKE_CURRENT_BINARY_DIR}/\${CMAKE_PROJECT_NAME}ConfigVersion.cmake
  DESTINATION /usr/local/lib/cmake/\${CMAKE_PROJECT_NAME})

EOF

cat << EOF > $1/$2/${nameArg}.cmake.in

set(${nameArg} 1.0.0)

@PACKAGE_INIT@

set_and_check(${nameArg}_INCLUDE_DIR "@PACKAGE_INCLUDE_INSTALL_DIR@")
set_and_check(${nameArg}_LIB_INSTALL_DIR "@PACKAGE_LIB_INSTALL_DIR@")
set_and_check(${nameArg}_LIBRARIES "@PACKAGE_LIBS@")

check_required_components(${nameArg})


EOF

}


OPTSTRING=":p:n:t:"

while getopts ${OPTSTRING} opt; do

    case ${opt} in
        
        p)
            pathArg=${OPTARG}
        ;;
        n)
            nameArg=${OPTARG}
        ;;
        t)
            projectType=${OPTARG}
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
fill_cmake_files ${path} ${project_name}
exit 0



