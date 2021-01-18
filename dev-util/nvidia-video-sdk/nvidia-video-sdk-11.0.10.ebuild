EAPI=7

inherit eutils

DESCRIPTION="NVIDIA Video Codec SDK (NVDECODE and NVENCODE APIs) (needs registration at upstream URL and manual download)"
HOMEPAGE="https://developer.nvidia.com/nvidia-video-codec-sdk/"
SRC_URI="Video_Codec_SDK_${PV}.zip"

LICENSE="custom"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="fetch"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	app-text/poppler
	>=x11-drivers/nvidia-drivers-450.57"

S="${WORKDIR}/Video_Codec_SDK_${PV}"

pkg_nofetch() {
	einfo "You need to download the SDK file from NVIDIA's website (registration required)"
	einfo "Download website:"
	einfo "${HOMEPAGE}"
}

src_prepare() {
	default
	pdftotext -layout LicenseAgreement.pdf
}

src_install() {
#	insinto /usr/include/${PN}
	insinto /usr/include
	# encoder header
	doins Interface/nvEncodeAPI.h

	# decoder headers
	doins Interface/cuviddec.h
	doins Interface/nvcuvid.h

	# documentation
	dodoc Doc/*
    
	# license
	insinto usr/share/licenses/${PN}
	cp LicenseAgreement.txt LICENSE
	doins LICENSE
}
