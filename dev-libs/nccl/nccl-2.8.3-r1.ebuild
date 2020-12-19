EAPI=7

inherit cuda

CUDA_PV=11.1

DESCRIPTION="Library for NVIDIA multi-GPU and multi-node collective communication primitives"
HOMEPAGE="https://developer.nvidia.com/nccl/"

MY_PV=${PVR/-r/-}
SRC_URI="https://github.com/NVIDIA/${PN}/archive/v${MY_PV}.tar.gz -> ${PN}-${MY_PV}.tar.gz"

SLOT="0"
KEYWORDS="amd64"
LICENSE="BSD"

DEPEND=">=dev-util/nvidia-cuda-toolkit-${CUDA_PV}"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/common.mk.patch" )

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	default
	# rename BUILDDIR Makefile variable to avoid conflict with makepkg's one
	local _file
	local _filelist
	_filelist="$(find . -type f -exec grep 'BUILDDIR' {} + | awk -F':' '{ print $1 }' | uniq)"
	for _file in $_filelist
	do
		sed -i 's/BUILDDIR/_BUILDPATH/g' "$_file"
	done
}

src_compile() {
	emake CUDA_HOME='/opt/cuda' src.build
}

src_install() {
	insinto /opt/cuda/shared/licenses
	doins LICENSE.txt

	cd build

	insinto /opt/cuda/targets/x86_64-linux/include
	doins include/*

	insinto /opt/cuda/targets/x86_64-linux/lib
	doins -r lib/libnccl.so*
}
