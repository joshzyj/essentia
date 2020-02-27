#!/bin/sh
. ../build_config.sh

rm -rf tmp
mkdir tmp
cd tmp

echo "Building taglib $TAGLIB_VERSION"

curl -SLO http://taglib.github.io/releases/$TAGLIB_VERSION.tar.gz
tar -xf $TAGLIB_VERSION.tar.gz
cd $TAGLIB_VERSION/

TAGLIB_TOOLCHAIN="
SET(CMAKE_SYSTEM_NAME Windows)
SET(CMAKE_C_COMPILER $HOST-gcc)
SET(CMAKE_CXX_COMPILER $HOST-g++)
SET(CMAKE_RC_COMPILER $HOST-windres)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
"
echo "$TAGLIB_TOOLCHAIN" > $TAGLIB_VERSION_toolchain.cmake

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=$TAGLIB_VERSION_toolchain.cmake \
    -DBUILD_SHARED_LIBS=OFF \
    -DZLIB_ROOT=$PREFIX \
	. 
make
# patch taglib.cp (missing -lz flag)
sed -i 's/-ltag/-ltag -lz/g' taglib.pc
make install

cd ../..
rm -r tmp

mv $PREFIX/bin/libtag.dll $PREFIX/lib
