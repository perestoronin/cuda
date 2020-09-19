EAPI=7

CUDA_PV=10.2

DESCRIPTION="NVIDIA Accelerated Deep Learning on GPU library"
HOMEPAGE="https://developer.nvidia.com/cuDNN"

SRC_URI="cudnn-${CUDA_PV}-linux-x64-v${PV}.tgz"

SLOT="0/7"
KEYWORDS="amd64"
RESTRICT="fetch"
LICENSE="NVIDIA-cuDNN"
QA_PREBUILT="*"

IUSE="static-libs"

S="${WORKDIR}"

DEPEND=">=dev-util/nvidia-cuda-toolkit-${CUDA_PV}"
RDEPEND="${DEPEND}"

src_install() {
	insinto /opt/cuda
	doins cuda/NVIDIA_SLA_cuDNN_Support.txt

	insinto /opt/cuda/targets/x86_64-linux/include
	doins -r cuda/include/*

	insinto /opt/cuda/targets/x86_64-linux/lib
	doins -r cuda/lib*/*.so*
	use static-libs && doins cuda/lib*/*.a
}
