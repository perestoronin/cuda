EAPI=7

inherit check-reqs cuda toolchain-funcs unpacker

DRIVER_PV="460.32.03"

DESCRIPTION="NVIDIA CUDA Toolkit (compiler and friends)"
HOMEPAGE="https://developer.nvidia.com/cuda-zone"
SRC_URI="https://developer.download.nvidia.com/compute/cuda/${PV}/local_installers/cuda_${PV}_${DRIVER_PV}_linux.run"
LICENSE="NVIDIA-CUDA"
SLOT="0/${PV}"
KEYWORDS="amd64"
IUSE="debugger doc eclipse profiler vis-profiler"
RESTRICT="bindist mirror"

BDEPEND=""
RDEPEND="
	>=sys-devel/gcc-10.2.0[cxx]
	>=x11-drivers/nvidia-drivers-${DRIVER_PV}[X,uvm]
	debugger? (
		dev-libs/openssl
		sys-libs/libtermcap
		sys-libs/ncurses[tinfo]
	)
	eclipse? (
		dev-libs/openssl
		>=virtual/jre-1.8
	)
	profiler? (
		dev-libs/openssl
		>=virtual/jre-1.8
	)"

S="${WORKDIR}"

QA_PREBUILT="opt/cuda/*"

CHECKREQS_DISK_BUILD="6800M"

pkg_setup() {
	# We don't like to run cuda_pkg_setup as it depends on us
	check-reqs_pkg_setup
}

src_prepare() {
	local cuda_supported_gcc

	cuda_supported_gcc="10.2"

	sed \
		-e "s:CUDA_SUPPORTED_GCC:${cuda_supported_gcc}:g" \
		"${FILESDIR}"/cuda-config.in > "${T}"/cuda-config || die

	default
}

src_install() {
	local i
	local cudadir=/opt/cuda
	local ecudadir="${EPREFIX}${cudadir}"

	cd builds

	rm -rf cuda_samples # install in nvidia-cuda-sdk

## TODO docs avaiable now online only
##	pushd cuda_documentation > /dev/null
##	if use doc; then
##		DOCS+=( doc/pdf/. )
##		HTML_DOCS+=( doc/html/. )
##	fi
##	einstalldocs
##	mv doc/man/man3/{,cuda-}deprecated.3 || die
##	doman doc/man/man*/*
##	popd > /dev/null
##	rm -rf cuda_documentation

	dodir ${cudadir}
	into ${cudadir}

	insinto ${cudadir}/bin
	doins cuda_nvcc/bin/nvcc.profile
	rm -f cuda_nvcc/bin/nvcc.profile

	exeinto ${cudadir}/nvvm/bin
	doexe cuda_nvcc/nvvm/bin/cicc
	rm -f cuda_nvcc/nvvm/bin/cicc

	exeinto ${cudadir}/bin

	for i in $(find cuda_*/bin/cuda-uninstaller -type f); do
		rm -f ${i}
	done

	for i in $(find bin/cuda-uninstaller -type f); do
		doexe ${i}
		rm -f ${i}
	done

	for i in $(find cuda_*/bin -maxdepth 1 -type f); do
		doexe ${i}
		rm -f ${i}
	done

	insinto ${cudadir}/extras
	pushd cuda_sanitizer_api > /dev/null
	doins -r *
	popd > /dev/null

	insinto ${cudadir}

	for i in $(find cuda_* -maxdepth 0 -type d); do
		pushd ${i} > /dev/null
		doins -r *
		popd > /dev/null
	done

	for i in $(find lib* -maxdepth 0 -type d); do
		pushd ${i} > /dev/null
		doins -r *
		popd > /dev/null
	done

	exeinto ${cudadir}/bin
	doexe "${T}"/cuda-config

# 	die TODO !!!

	# Add include and lib symlinks
	dosym "targets/x86_64-linux/include" ${cudadir}/include
	dosym "targets/x86_64-linux/lib" ${cudadir}/lib64

	newenvd - 99cuda <<-EOF
		PATH=${ecudadir}/bin$(usex vis-profiler ":${ecudadir}/libnvvp" "")
		ROOTPATH=${ecudadir}/bin
		LDPATH=${ecudadir}/lib64:${ecudadir}/nvvm/lib64$(usex profiler ":${ecudadir}/extras/CUPTI/lib64" "")
	EOF

	# Cuda prepackages libraries, don't revdep-build on them
	insinto /etc/revdep-rebuild
	newins - 80${PN} <<-EOF
		SEARCH_DIRS_MASK="${ecudadir}"
	EOF
}

pkg_postinst_check() {
	local a="$(${EROOT}/opt/cuda/bin/cuda-config -s)"
	local b="0.0"
	local v
	for v in ${a}; do
		ver_test "${v}" -gt "${b}" && b="${v}"
	done

	# if gcc and if not gcc-version is at least greatest supported
	if tc-is-gcc && \
		ver_test $(gcc-version) -gt "${b}"; then
			ewarn
			ewarn "gcc > ${b} will not work with CUDA"
			ewarn "Make sure you set an earlier version of gcc with gcc-config"
			ewarn "or append --compiler-bindir= pointing to a gcc bindir like"
			ewarn "--compiler-bindir=${EPREFIX}/usr/*pc-linux-gnu/gcc-bin/gcc${b}"
			ewarn "to the nvcc compiler flags"
			ewarn
	fi
}

pkg_postinst() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		pkg_postinst_check
	fi
}
