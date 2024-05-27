#!/bin/bash
#################################################################
#
# Build script template for ConFlow.
#
# See the build scripts in the "/build_examples" 
# folder for examples of what to insert here.
# Please do not edit this file, rather copy it to a new 
# file with your own configuration options inserted.
# If your configuration is unique, feel free to add it to the 
# /build_examples folder.
# Note that your build script must be launched from 
# this lowest level directory (not from the build_examples folder).
#
#################################################################
#################################################################
# Enter your compiler (e.g. gfortran, ifx, nvfortran, etc.).
#################################################################

FC=

#################################################################
# Please set the location of the HDF5 include & library files. 
# Make sure the HDF5 LIBRARY is COMPILED with 
# the SAME COMPILER used here, and is in the run-time environment.
#################################################################

HDF5_INCLUDE_DIR=
HDF5_LIB_DIR=

##################################################################
# Please set the HDF5 linker flags to match the installed version.
##################################################################

HDF5_LIB_FLAGS=

###########################################################################
# Please set the compile flags based on your compiler and hardware setup.
###########################################################################

FFLAGS=

###########################################################################
#             END OF USER CONFIG.  DO NOT EDIT BELOW.                     #
###########################################################################
###########################################################################
###########################################################################
###########################################################################
###########################################################################
###########################################################################

CONFLOW_HOME=$PWD

cX="\033[0m"
cR="\033[1;31m"
cB="\033[1;34m"
cG="\033[32m"
cC="\033[1;96m"
cM="\033[35m"
cY="\033[1;93m"
Bl="\033[1;5;96m"
echo="echo -e"

if [ -z "${OMP_NUM_THREADS}" ]
then
  ${echo} "${cR}ERROR!  OMP_NUM_THREADS is not set!${cX}"
  ${echo} "${cR}        For GCC, this is required at compile time in order to run in${cX}"
  ${echo} "${cR}        parallel across CPU threads.  Set to 1 for single threaded runs.${cX}"
  exit 1
fi

${echo} "${cG}=== STARTING CONFLOW BUILD ===${cX}"
${echo} "==> Entering src directory..."
pushd ${CONFLOW_HOME}/src > /dev/null
${echo} "==> Removing old Makefile..."
if [ -e Makefile ]; then
  \rm Makefile
fi 
${echo} "==> Generating Makefile from Makefile.template..."
sed \
  -e "s#<FC>#${FC}#g" \
  -e "s#<FFLAGS>#${FFLAGS}#g" \
  -e "s#<HDF5_INCLUDE_DIR>#${HDF5_INCLUDE_DIR}#g" \
  -e "s#<HDF5_LIB_DIR>#${HDF5_LIB_DIR}#g" \
  -e "s#<HDF5_LIB_FLAGS>#${HDF5_LIB_FLAGS}#g" \
  Makefile.template > Makefile
${echo} "==> Compiling code..."
make clean 1>/dev/null 2>/dev/null ; make 1>build.log 2>build.err
if [ ! -e conflow ]; then
  ${echo} "${cR}!!> ERROR!  conflow executable not found.  Build most likely failed."
  ${echo} "            Contents of src/build.err:"
  cat build.err
  ${echo} "${cX}"
  exit 1
fi
$echo "==> Copying conflow executable to: ${CONFLOW_HOME}/bin/conflow"
cp conflow ${CONFLOW_HOME}/bin/conflow
${echo} "${cG}==> Build complete!${cX}"
${echo}      "    Please add the following to your shell startup (e.g. .bashrc, .profile, etc.):"
${echo} "${cC}    export PATH=${CONFLOW_HOME}/bin:\$PATH${cX}"

