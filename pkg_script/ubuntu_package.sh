#!/bin/sh

if test "x${DEBIAN}" = "x"; then
	DEBIAN=debian
fi
if test "x${DIR_SRC}" = "x"; then
	DIR_SRC=.src
fi
if test "x${PKG_TARGET}" = "x"; then
	echo "Please set PKG_TARGET"
	exit 1
fi
if test "x${SECT}" = "x"; then
	echo "Please set SECT"
	exit 1
fi
if test "x${PROJ}" = "x"; then
	echo "Please set PROJ"
	exit 1
fi
if test "x${PROJ_ORG}" = "x"; then
	PROJ_ORG=${PROJ}
	exit 1
fi
if test "x${VER}" = "x"; then
	echo "Please set VER"
	exit 1
fi


echo "DEBIAN    : ${DEBIAN}"
echo "DIR_SRC   : ${DIR_SRC}"
echo "PKG_TARGET: ${PKG_TARGET}"
echo "SECT      : ${SECT}"
echo "PROJ      : ${PROJ}"
echo "PROJ_ORG  : ${PROJ_ORG}"
echo "VER       : ${VER}"

set -ex

WORK=pkg_${PKG_TARGET}
ARCH=${DIR_SRC}/${PROJ_ORG}-${VER}.tar.xz

# Create original source archive
#git archive --format=tar HEAD > ${ARCH}
mkdir -p ${WORK}/${PROJ}-${VER} && cd ${WORK}/${PROJ}-${VER}
tar xf ../../${ARCH}

# Move sources to top working directory
mv ${PROJ_ORG}-${VER}/* ./
rmdir ${PROJ_ORG}-${VER}

# Copy debian, remove CI files
cp -a ../../${DEBIAN} ./debian
#rm -rf .gitlab-ci.yml pkg_tools

# For nightly
if [ x${SECT} = "xnightly" ]; then
	REV=`date +%Y%m%d%H%M%S`-`git rev-parse --short HEAD`;
	sed -i -e "0,/)/ s/)/-${REV})/" debian/changelog;
	PKGVER=${REV}
else
	PKGVER=${VER}-`git rev-parse --short HEAD`;
fi
echo -n "${PKGVER}" > PKGVERSION

cd ../
cp -a ${PROJ}-${VER} ${PROJ}-${VER}.orig

# Make package
cd ${PROJ}-${VER}
debuild -uc -us
cd ../

# Clean
rm -rf ${PROJ}-${VER}
