do_image_wic[postfuncs] += "nxp_imx8_wic"

nxp_imx8_wic() {
    if [ "${CUSTOMER_BUILD_BOOTLOADER}" = "1" ]; then
        for config in ${UBOOT_CONFIG}; do
            cd "${DEPLOY_DIR_IMAGE}"

            ofname=${IMAGE_LINK_NAME}-${config}${IMAGE_VERSION_SUFFIX}.rootfs.wic
            cp ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.wic ${IMGDEPLOYDIR}/$ofname
            dd if=imx-boot-nxp-imx8-${UBOOT_CONFIG}.bin-flash_spl of=${IMGDEPLOYDIR}/$ofname bs=512 seek=64 conv=fsync,notrunc

            cd "${IMGDEPLOYDIR}"
            bmaptool create "$ofname" -o "${ofname}.bmap"
            linkname="${IMAGE_LINK_NAME}-${config}.wic"
            ln -sf $ofname $linkname
        done
	# Remove the default wic file
        rm -rf "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.wic"
        rm -rf "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.wic.bmap"
        rm -rf "${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic"
        rm -rf "${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic.bmap"
    fi

}
