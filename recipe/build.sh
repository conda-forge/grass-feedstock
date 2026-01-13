#!/bin/sh
set -e

export CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"

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

	for tool in \
		include \
		lib/datetime \
		lib/gis \
		utils \
		general/g.parser \
		general/g.mkfontcap \
	; do
		make -j$CPU_COUNT -C $tool
	done
	)

	dist_build="$(pwd)/dist.$BUILD"
	sed -Ei 's#(\tPATH=")#\1'"$dist_build"'/bin:#' include/Make/Rules.make
fi

case "$target_platform" in
osx-*)
	with_others="
		--with-opengl=osx
		--with-x=no
	"
	;;
esac

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
