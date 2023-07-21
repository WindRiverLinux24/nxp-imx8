require linux-yocto-nxp-imx8.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:nxp-imx8 = " \
    file://ocotp.cfg \
    "

KBRANCH:nxp-imx8  = "v6.1/standard/nxp-sdk-6.1/nxp-soc"
