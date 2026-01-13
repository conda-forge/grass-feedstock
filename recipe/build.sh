#!/bin/sh
set -e

echo "===== conda-build env ====="
echo "CONDA_BUILD_CROSS_COMPILATION=${CONDA_BUILD_CROSS_COMPILATION}"
echo "target_platform=${target_platform}"
echo "BUILD=${BUILD}"
echo "HOST=${HOST}"
echo "PREFIX=${PREFIX}"
echo "BUILD_PREFIX=${BUILD_PREFIX}"
echo "CC=${CC}"
echo "CXX=${CXX}"
echo "CC_FOR_BUILD=${CC_FOR_BUILD}"
echo "CXX_FOR_BUILD=${CXX_FOR_BUILD}"
echo "CFLAGS_FOR_BUILD=${CFLAGS_FOR_BUILD}"
echo "CXXFLAGS_FOR_BUILD=${CXXFLAGS_FOR_BUILD}"
echo "LDFLAGS_FOR_BUILD=${LDFLAGS_FOR_BUILD}"
echo "AR_FOR_BUILD=${AR_FOR_BUILD}"
echo "RANLIB_FOR_BUILD=${RANLIB_FOR_BUILD}"

export CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"

case "$target_platform" in
osx-*)
	with_others="
		--with-opengl=osx
		--with-x=no
	"
	;;
esac

if [ "$CONDA_BUILD_CROSS_COMPILATION" = "1" ]; then
	(
	export CC="${CC_FOR_BUILD}"
	export CXX="${CXX_FOR_BUILD}"
	export AR="${AR_FOR_BUILD}"
	export RANLIB="${RANLIB_FOR_BUILD}"

	export CPPFLAGS="-I${BUILD_PREFIX}/include ${CPPFLAGS}"
	export LDFLAGS="-L${BUILD_PREFIX}/lib ${LDFLAGS}"

	./configure \
		--host="$BUILD" \
		--without-cairo \
		--without-fftw \
		--without-freetype \
		--without-opengl \
		--without-pdal \
		--without-regex \
		--without-sqlite \
		--without-tiff \
		--without-zstd \
		|| (
			echo "===== build-tools config.log ====="
			cat config.log
			exit 1
		)

	for tool in include lib/datetime lib/gis utils general/g.parser; do
		make -j$CPU_COUNT -C $tool
	done)
	ls -al "$(pwd)/dist.$BUILD/bin"
fi

./configure \
	--prefix=$PREFIX \
	--with-blas \
	--with-bzlib \
	--with-lapack \
	--with-nls \
	--with-openmp \
	--with-postgres \
	--with-pthread \
	--with-readline \
	$with_others || (
		echo "===== config.log ====="
		cat config.log
		exit 1
	)
sed -Ei 's/^(ICONVLIB *= *$)/\1-liconv/' include/Make/Platform.make

make -j$CPU_COUNT
make install
