#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module add  argtable
module  add  gcc/${GCC_VERSION}
echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}
echo "All tests have passed, will now build into ${SOFT_DIR}"
export CFLAGS="$CFLAGS -I${ARGTABLE_DIR}/include"
export LDFLAGS="$LDFLAGS -L${ARGTABLE_DIR}/lib"

./configure \
--with-gnu-ld \
--enable-shared \
--enable-static \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION}
make install

echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module add gcc/${GCC_VERSION}
module add argtable

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/CLUSTAL_OMEGA-deploy"
setenv CLUSTAL_OMEGA_VERSION       $VERSION
setenv CLUSTAL_OMEGA_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
prepend-path PATH                           $::env(CLUSTAL_OMEGA_DIR)/bin
prepend-path LD_LIBRARY_PATH   $::env(CLUSTAL_OMEGA_DIR)/lib
setenv CFLAGS            "$CFLAGS -I$::env(CLUSTAL_OMEGA_DIR)/include"
setenv LDFLAGS           "$LDFLAGS -L$::env(CLUSTAL_OMEGA_DIR)/lib"
MODULE_FILE
) > modules/$VERSION-gcc-${GCC_VERSION}

mkdir -vp ${BIOINFORMATICS}/${NAME}
cp -v modules/$VERSION-gcc-${GCC_VERSION} ${BIOINFORMATICS}/${NAME}

echo "checking module"
module avail ${NAME}
echo "adding module"
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}
which clustalo
