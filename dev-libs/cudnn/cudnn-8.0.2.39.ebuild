EAPI=7

CUDA_PV=11.0

DESCRIPTION="NVIDIA Accelerated Deep Learning on GPU library"
HOMEPAGE="https://developer.nvidia.com/cuDNN"

SRC_URI="cudnn-${CUDA_PV}-linux-x64-v${PV}.tgz"
# https://developer.nvidia.com/compute/machine-learning/cudnn/secure/8.0.2.39/11.0_20200724/cudnn-11.0-linux-x64-v8.0.2.39.tgz

SLOT="0/8"
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
