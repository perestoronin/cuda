EAPI=7

inherit cmake cuda unpacker

DESCRIPTION="NVIDIA Ray Tracing Engine"
HOMEPAGE="https://developer.nvidia.com/optix"
SRC_URI="NVIDIA-OptiX-SDK-${PV}-linux64-x86_64.sh"
# https://developer.download.nvidia.com/designworks/optix/secure/7.1.0/ga/NVIDIA-OptiX-SDK-7.1.0-linux64-x86_64.sh

SLOT="0/7"
KEYWORDS="amd64"
RESTRICT="fetch network-sandbox"
LICENSE="NVIDIA-r2"

RDEPEND="dev-util/nvidia-cuda-toolkit
	virtual/opengl
	media-libs/freeglut
	>=media-libs/imgui-1.77
	>=media-libs/glfw-3.3.2
	>=dev-python/glad-0.1.33"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/cmake.patch"
)

S="${WORKDIR}"

CMAKE_USE_DIR=${S}/SDK

src_unpack() {
	unpack_makeself "${DISTDIR}"/${A} 223 tail
}

src_prepare() {
	cmake_src_prepare
	rm -rf SDK-precompiled-samples || die
	export PATH=$(cuda_gccdir):${PATH}
}

src_install() {
	dodoc -r doc

	insinto /usr/include/optix

	doins -r include/*
	doins -r ${P}_build/include/*

	dolib.so ${P}_build/lib/{libglad,libsutil_7_sdk}.so
	dobin ${P}_build/bin/*
}
