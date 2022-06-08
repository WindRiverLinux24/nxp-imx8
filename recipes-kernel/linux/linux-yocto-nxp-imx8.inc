#
# Copyright (C) 2020 Wind River Systems, Inc.
#

COMPATIBLE_MACHINE:nxp-imx8 = "nxp-imx8"
TARGET_SUPPORTED_KTYPES:nxp-imx8 = "standard preempt-rt"

KERNEL_VERSION_SANITY_SKIP = "1"
SRCREV_machine:nxp-imx8 ?= "${AUTOREV}"
SRCREV_meta:nxp-imx8 ?= "${AUTOREV}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append:nxp-imx8 = " \
        file://0001-mxc-vpu_windsor-Drop-the-redundant-NULL-check-in-vpu.patch \
"
