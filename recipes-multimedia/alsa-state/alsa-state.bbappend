# Append path for freescale layer to include alsa-state asound.conf
FILESEXTRAPATHS:prepend:nxp-imx8 := "${THISDIR}/${PN}:"

SRC_URI:append:nxp-imx8 = " \
	file://asound.state \
	file://asound.conf \
"

PACKAGE_ARCH:nxp-imx8 = "${MACHINE_ARCH}"
