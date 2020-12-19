EAPI=7

inherit cmake cuda unpacker

DESCRIPTION="NVIDIA Ray Tracing Engine"
HOMEPAGE="https://developer.nvidia.com/optix"
SRC_URI="NVIDIA-OptiX-SDK-${PV}-linux64-x86_64.sh"

SLOT="0/7"
KEYWORDS="amd64"
RESTRICT="fetch network-sandbox"
LICENSE="NVIDIA-r2"

RDEPEND="
	dev-util/nvidia-cuda-toolkit
	media-libs/freeglut
	virtual/opengl
	>=media-libs/imgui-1.77
	>=media-libs/glfw-3.3.2
	>=dev-python/glad-0.1.33"
DEPEND="${RDEPEND}"

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
	insinto /opt/${PN}
	dodoc -r doc
	doins -r include SDK

	dolib.so ${P}_build/lib/{libglad,libsutil_7_sdk}.so
	dobin ${P}_build/bin/*

	chrpath --delete ${D}/usr/lib64/*.so
	chrpath --delete ${D}/usr/bin/*
}
