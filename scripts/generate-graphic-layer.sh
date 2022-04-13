#!/bin/sh
#
# i.MX8 Graphic Layer Generation Script
#
# Copyright (C) 2020 WindRiver
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


CWD=`pwd`
BSP_NAME=nxp-imx8
echo "\nGenerate graphic layer for BSP" $BSP_NAME
echo

usage()
{
    echo "Usage: source generate-graphic-layer.sh
    Optional parameters: [-s source-dir] [-d destination-dir] [-p platform-type] [-h]"
    echo "
    * [-s source-dir]: Source directory where the graphic layer come from
    * [-d destination-dir]: Destination directory where the graphic will be merged into
    * [-p platform-type]: Indicate the platform where the graphic will be used
			  Value: imx8mq imx8qm imx8mm imx8qxp
    * [-h]: help
    "
}

clean_up()
{
    unset CWD GRAPHIC_SRC GRAPHIC_DTS PLATFORM_TYPE
    unset usage clean_up
}


cat <<EOF
Warning: Once customer generates imx8 graphic layer, and then build with this layer.
There are some libraries and packages which are covered by Freescale's End User
License Agreement (EULA). To have the right to use these binaries in your images,
please read EULA carefully firstly.
WindRiver doesn't support imx8's GPU or VPU hardware acceleration feature in product
release. Customers who want to enable graphic hardware acceleration feature need to
run this script on their own PC to generate imx8-graphic layer.
EOF

echo
REPLY=
while [ -z "$REPLY" ]; do
	echo -n "Do you read the WARNING carefully? (y/n) "
	read REPLY
	case "$REPLY" in
		y|Y)
		echo "WARNING has been read."
		;;
		n|N)
		echo "WARNING has not been read."
		exit 1
		;;
		*)
		echo "WARNING has not been read."
		exit 1
		;;
	esac
done

# get command line options
OLD_OPTIND=$OPTIND
while getopts "s:d:p:h" fsl_setup_flag
do
    case $fsl_setup_flag in
        s) GRAPHIC_SRC="$OPTARG";
           echo "Graphic source directory is " $GRAPHIC_SRC
           ;;
        d) GRAPHIC_DTS="$OPTARG";
           echo "Graphic destination directory is " $GRAPHIC_DTS
           ;;
        p) PLATFORM_TYPE="$OPTARG";
           echo "Graphic destination directory is " $PLATFORM_TYPE
           ;;
        h) fsl_setup_help='true';
           ;;
        \?) fsl_setup_error='true';
           ;;
    esac
done
shift $((OPTIND-1))
if [ $# -ne 0 ]; then
    fsl_setup_error=true
    echo "Invalid command line ending: '$@'"
fi
OPTIND=$OLD_OPTIND
if test $fsl_setup_help; then
    usage && clean_up && exit 1
elif test -z "$GRAPHIC_SRC"; then
    usage && clean_up && exit 1
elif test -z "$GRAPHIC_DTS"; then
    usage && clean_up && exit 1
elif test -z "$PLATFORM_TYPE"; then
    usage && clean_up && exit 1
elif test $fsl_setup_error; then
    clean_up && exit 1
fi

mkdir -p $GRAPHIC_DTS/imx8-graphic/conf
if [ ! -f $GRAPHIC_DTS/imx8-graphic/conf/layer.conf ]; then
cat > $GRAPHIC_DTS/imx8-graphic/conf/layer.conf << "EOF"
#
# Copyright (C) 2019-2020 Wind River Systems, Inc.
#

# We have a conf and classes directory, add to BBPATH
BBPATH .= ":${LAYERDIR}"

EXTENDED_WRLINUX_RECIPES_LIST = '${LAYERDIR}/conf/third_party_build.inc'

require imx8-graphic.inc

# We have a packages directory, add to BBFILES
BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
	${LAYERDIR}/recipes-*/*/*.bbappend \
	${LAYERDIR}/classes/*.bbclass"

BBFILE_COLLECTIONS += "imx8-graphic-layer"
BBFILE_PATTERN_imx8-graphic-layer := "^${LAYERDIR}/"
BBFILE_PRIORITY_imx8-graphic-layer = "7"

INHERIT += "machine-overrides-extender"
MACHINE_SOCARCH = "nxp_imx8"
MACHINE_HAS_VIVANTE_KERNEL_DRIVER_SUPPORT = "1"

BANNER[nxp-imx8_default] = "The nxp-imx8 layer includes third party components, where additional third party licenses may apply."

IMX_MIRROR ?= "https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/"
FSL_MIRROR ?= "${IMX_MIRROR}"
FSL_EULA_FILE_GRAPHIC = "${LAYERDIR}/EULA"

LAYERSERIES_COMPAT_imx8-graphic-layer = "wrl honister kirkstone"
DISTRO_FEATURES:append = " imx8-graphic"
EOF
fi

file_modify()
{
	file_name=$1
	shift

	while test -n "$1"; do
		sed -i "$1" $file_name
		shift
	done
}

if [ $PLATFORM_TYPE = "imx8mq" ]; then
file_modify $GRAPHIC_DTS/imx8-graphic/conf/layer.conf \
			"20iMACHINEOVERRIDES_EXTENDER:nxp-imx8   = \"imx:mx8:mx8m:mx8mq:imxdrm:imxdcss:imxvpu:imxvpuhantro:imxgpu:imxgpu3d\"" \
			"24iIMAGE_INSTALL += \"assimp devil imx-vpu-hantro imx-gpu-viv imx-gpu-sdk imx-gpu-viv-demos\""
elif [ $PLATFORM_TYPE = "imx8mm" ]; then
file_modify $GRAPHIC_DTS/imx8-graphic/conf/layer.conf \
			"20iMACHINEOVERRIDES_EXTENDER:nxp-imx8   = \"imx:mx8:mx8m:mx8mm:imxdrm:imxvpu:imxvpuhantro:imxgpu:imxgpu2d:imxgpu3d\"" \
			"24iIMAGE_INSTALL += \"assimp devil imx-vpu-hantro imx-gpu-viv imx-gpu-sdk imx-gpu-viv-demos\""
elif [ $PLATFORM_TYPE = "imx8qm" ]; then
file_modify $GRAPHIC_DTS/imx8-graphic/conf/layer.conf \
			"20iMACHINEOVERRIDES_EXTENDER:nxp-imx8   = \"imx:mx8:mx8qm:imxdrm:imxdpu:imxgpu:imxgpu2d:imxgpu3d\"" \
			"24iIMAGE_INSTALL += \"assimp devil imx-gpu-viv imx-gpu-sdk imx-gpu-viv-demos armnn tensorflow-lite onnxruntime\""
elif [ $PLATFORM_TYPE = "imx8qxp" ]; then
file_modify $GRAPHIC_DTS/imx8-graphic/conf/layer.conf \
			"20iMACHINEOVERRIDES_EXTENDER:nxp-imx8   = \"imx:mx8:mx8qxp:imxdrm:imxdpu:imxgpu:imxgpu2d:imxgpu3d\"" \
			"24iIMAGE_INSTALL += \"assimp devil imx-gpu-viv imx-gpu-sdk imx-gpu-viv-demos\""
fi

if [ ! -f $GRAPHIC_DTS/imx8-graphic/conf/imx8-graphic.inc ]; then
cat > $GRAPHIC_DTS/imx8-graphic/conf/imx8-graphic.inc << EOF
PREFERRED_PROVIDER_virtual/egl:imxgpu        ?= "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgl:imxgpu3d    ?= "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgles1:imxgpu3d ?= "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgles2:imxgpu3d ?= "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libg2d            ?= "imx-gpu-g2d"
PREFERRED_PROVIDER_virtual/libg2d:imxdpu     ?= "imx-dpu-g2d"
PREFERRED_VERSION_imx-vpu = "5.4.39.1"
PREFERRED_VERSION_wayland-protocols = "1.18.imx"
PREFERRED_VERSION_libdrm = "2.4.99.imx"
PREFERRED_VERSION_weston = "9.0.0.imx"

PREFERRED_PROVIDER_opencl-headers:nxp-imx8 = "imx-gpu-viv"

DISTRO_FEATURES:remove = "directfb "
DISTRO_FEATURES:append = " x11 wayland pam"

WRL_RECIPES:openembedded-layer += 'freeglut'
WRL_RECIPES:imx8-graphic-layer += 'imx-gpu-viv'
WRL_RECIPES:imx8-graphic-layer += 'imx-gpu-viv-demos'
WRL_RECIPES:imx8-graphic-layer += 'imx-gpu-sdk'
WRL_RECIPES:imx8-graphic-layer += 'assimp'
WRL_RECIPES:imx8-graphic-layer += 'devil'
WRL_RECIPES:imx8-graphic-layer += 'weston'
WRL_RECIPES:imx8-graphic-layer += 'imx-gpu-apitrace'
WRL_RECIPES:imx8-graphic-layer += 'systemd-gpuconfig'
WRL_RECIPES:imx8-graphic-layer += 'spirv-tools'
WRL_RECIPES:imx8-graphic-layer += 'glslang'
WRL_RECIPES:imx8-graphic-layer += 'wayland-protocols'
WRL_RECIPES:imx8-graphic-layer += 'libdrm'
WRL_RECIPES:openembedded-layer += 'fmt'
WRL_RECIPES:openembedded-layer += 'googletest'
WRL_RECIPES:openembedded-layer += 'rapidjson'
WRL_RECIPES:openembedded-layer += 'glm'
WRL_RECIPES:imx8-graphic-layer += 'stb'
WRL_RECIPES:imx8-graphic-layer += 'rapidvulkan'
WRL_RECIPES:imx8-graphic-layer += 'rapidopencl'
WRL_RECIPES:imx8-graphic-layer += 'half'
WRL_RECIPES:imx8-graphic-layer += 'gli'
WRL_RECIPES:imx8-graphic-layer += 'rapidopenvx'
WRL_RECIPES:imx8-graphic-layer += 'vulkan-validationlayers'
WRL_RECIPES:imx8-graphic-layer += 'linux-imx-headers'
WRL_RECIPES:imx8-graphic-layer += 'vulkan-headers'
WRL_RECIPES:imx8-graphic-layer += 'vulkan-loader'
WRL_RECIPES:imx8-graphic-layer += 'vulkan-tools'
WRL_RECIPES:imx8-graphic-layer += 'weston-init'
WRL_RECIPES:imx8-graphic-layer += 'weston'
WRL_RECIPES:openembedded-layer += 'libxaw'
WRL_RECIPES:openembedded-layer += 'xterm'
WRL_RECIPES:meta-python += 'python3-wheel'
WRL_RECIPES:meta-python += 'python3-pybind11'

IMAGE_INSTALL += " \\
    \${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston-init', '', d)} \\
    \${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland xterm', '', d)} \\
"


IMAGE_FEATURES:remove = "\${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'x11-base  x11-sato', '', d)}"

# QA check settings - a little stricter than the OE-Core defaults
WARN_TO_ERROR_QA = "already-stripped compile-host-path install-host-path \\
                    installed-vs-shipped ldflags pn-overrides rpaths staticdev \\
                    useless-rpaths"
WARN_QA:remove = "\${WARN_TO_ERROR_QA}"
ERROR_QA:append = " \${WARN_TO_ERROR_QA}"

EOF
fi

if [ ! -f $GRAPHIC_DTS/imx8-graphic/conf/third_party_build.inc ]; then
	cat > $GRAPHIC_DTS/imx8-graphic/conf/third_party_build.inc << EOF
WRLINUX_SUPPORTED_RECIPE:pn-imx-gpu-sdk ?= "0 "
WRLINUX_SUPPORTED_RECIPE:pn-imx-gpu-viv ?= "0 "
WRLINUX_SUPPORTED_RECIPE:pn-imx-gpu-g2d ?= "0 "
WRLINUX_SUPPORTED_RECIPE:pn-imx-gpu-apitrace ?= "0 "
WRLINUX_SUPPORTED_RECIPE:pn-imx-dpu-g2d ?= "0 "
EOF
fi

if [ $PLATFORM_TYPE = "imx8mq" ]; then
file_modify $GRAPHIC_DTS/imx8-graphic/conf/imx8-graphic.inc \
			"21iWRL_RECIPES:imx8-graphic-layer += 'imx-vpu-hantro'"

elif [ $PLATFORM_TYPE = "imx8mm" ]; then
file_modify $GRAPHIC_DTS/imx8-graphic/conf/imx8-graphic.inc \
                        "21iWRL_RECIPES:imx8-graphic-layer += 'imx-vpu-hantro'" \
			"22iWRL_RECIPES:imx8-graphic-layer += 'imx-gpu-g2d'"

elif [ $PLATFORM_TYPE = "imx8qm" ]; then
file_modify $GRAPHIC_DTS/imx8-graphic/conf/imx8-graphic.inc \
			"21iWRL_RECIPES:imx8-graphic-layer += 'imx-gpu-g2d'" \
			"22iWRL_RECIPES:imx8-graphic-layer += 'imx-dpu-g2d'"

elif [ $PLATFORM_TYPE = "imx8qxp" ]; then
file_modify $GRAPHIC_DTS/imx8-graphic/conf/imx8-graphic.inc \
			"21iWRL_RECIPES:imx8-graphic-layer += 'imx-dpu-g2d'"
fi

file_copy()
{
	src_file=$SOURCE_DIR/$1
	dts_file=$DESTINATION_DIR/$1

	if [ -f $dts_file ]; then
		return 1
	fi

	if [ ! -f $src_file ]; then
		echo "No file $src_file"
		return 1
	fi

	mkdir -p $DESTINATION_DIR/`dirname $1`
	shift

	cp $src_file $dts_file

	while test -n "$1"; do
		sed -i "$1" $dts_file
		shift
	done
}

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
DESTINATION_DIR=$GRAPHIC_DTS/imx8-graphic/

file_copy classes/fsl-eula-unpack.bbclass \
			"s/FSL_EULA_FILE/FSL_EULA_FILE_GRAPHIC/g" \
			'30i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V13 = \"1b4db4b25c3a1e422c0c0ed64feb65d2\"' \
			'31i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V15 = \"983e4c77621568488dd902b27e0c2143\"' \
			'32i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V16 = \"e9e880185bda059c90c541d40ceca922\"' \
			'33i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V17 = \"cf3f9b8d09bc3926b1004ea71f7a248a\"' \
			'34i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V18 = \"231e11849a4331fcbb19d7f4aab4a659\"' \
			'35i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V19 = \"a632fefd1c359980434f9389833cab3a\"' \
			'57a\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V13} \\' \
			'58a\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V15} \\' \
			'59a\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V16} \\' \
                        '60a\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V17} \\' \
			'64i\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V18} \\' \
                        '65i\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V19} \\' \
			'70d' \
			'70i\    "${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V19}"'
mv $GRAPHIC_DTS/imx8-graphic/classes/fsl-eula-unpack.bbclass $GRAPHIC_DTS/imx8-graphic/classes/fsl-eula-unpack-graphic.bbclass

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-sdk/

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/

file_copy classes/machine-overrides-extender.bbclass
file_copy classes/use-imx-headers.bbclass

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/

file_copy recipes-bsp/imx-vpu-hantro/imx-vpu-hantro_1.21.0.bb
file_copy recipes-bsp/imx-vpu-hantro/imx-vpu-hantro.inc \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"

file_copy recipes-core/systemd/systemd/0020-logind.conf-Set-HandlePowerKey-to-ignore.patch
file_copy recipes-core/systemd/systemd_%.bbappend \
			"4d"

file_copy recipes-core/systemd/systemd-gpuconfig/gpuconfig
file_copy recipes-core/systemd/systemd-gpuconfig/gpuconfig.service
file_copy recipes-core/systemd/systemd-gpuconfig_1.0.bb \
			"s/GPL-2.0/GPL-2.0-only/g"

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-sdk/

file_copy recipes-devtools/half/half_2.1.0.bb
file_copy recipes-devtools/stb/stb_git.bb

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/

file_copy recipes-graphics/cairo/cairo_%.bbappend


SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-sdk/

file_copy recipes-graphics/devil/devil_1.8.0.bb \
			"s/LGPL-2.1/LGPL-2.1-only/g"
file_copy recipes-graphics/devil/devil_%.bbappend
file_copy recipes-graphics/devil/devil/0001-CMakeLists-Use-CMAKE_INSTALL_LIBDIR-for-install-libs.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/

file_copy recipes-graphics/drm/libdrm_2.4.99.imx.bb
file_copy recipes-graphics/drm/libdrm/0001-meson-add-libdrm-vivante-to-the-meson-meta-data.patch
file_copy recipes-graphics/drm/libdrm/musl-ioctl.patch
touch $GRAPHIC_DTS/imx8-graphic/recipes-graphics/drm/libdrm/0001-meson-add-libdrm-vivante-to-the-meson-meta-data.patch
echo "From 45f48f8a5de59c04b0510c23853772bc970f411e Mon Sep 17 00:00:00 2001
From: Max Krummenacher <max.krummenacher@toradex.com>
Date: Thu, 9 Jan 2020 01:01:35 +0000
Subject: [PATCH] meson: add libdrm-vivante to the meson meta data

Upstream libdrm added the option to use meason as the buildsystem.
Integrate Vivante into the relevant meson build information.

Upstream-Status: Pending

Signed-off-by: Max Krummenacher <max.krummenacher@toradex.com>
---
 meson.build         | 14 +++++++++++++
 meson_options.txt   |  7 +++++++
 vivante/meson.build | 50 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 71 insertions(+)
 create mode 100644 vivante/meson.build

diff --git a/meson.build b/meson.build
index e292554a..f4740634 100644
--- a/meson.build
+++ b/meson.build
@@ -157,6 +157,15 @@ if _vc4 != 'false'
   with_vc4 = _vc4 == 'true' or ['arm', 'aarch64'].contains(host_machine.cpu_family())
 endif

+with_vivante = false
+_vivante = get_option('vivante')
+if _vivante == 'true'
+  if not with_atomics
+    error('libdrm_vivante requires atomics.')
+  endif
+  with_vivante = true
+endif
+
 # XXX: Apparently only freebsd and dragonfly bsd actually need this (and
 # gnu/kfreebsd), not openbsd and netbsd
 with_libkms = false
@@ -312,6 +321,7 @@ install_headers(
   'include/drm/savage_drm.h', 'include/drm/sis_drm.h',
   'include/drm/tegra_drm.h', 'include/drm/vc4_drm.h',
   'include/drm/via_drm.h', 'include/drm/virtgpu_drm.h',
+  'include/drm/vivante_drm.h',
   subdir : 'libdrm',
 )
 if with_vmwgfx
@@ -362,6 +372,9 @@ endif
 if with_etnaviv
   subdir('etnaviv')
 endif
+if with_vivante
+  subdir('vivante')
+endif
 if with_man_pages
   subdir('man')
 endif
 @@ -382,5 +395,6 @@ message('  EXYNOS API     @0@'.format(with_exynos))
 message('  Freedreno API  @0@ (kgsl: @1@)'.format(with_freedreno, with_freedreno_kgsl))
 message('  Tegra API      @0@'.format(with_tegra))
 message('  VC4 API        @0@'.format(with_vc4))
+message('  Vivante API    @0@'.format(with_etnaviv))
 message('  Etnaviv API    @0@'.format(with_etnaviv))
 message('')
diff --git a/meson_options.txt b/meson_options.txt
index 8af33f1c..dc69563d 100644
--- a/meson_options.txt
+++ b/meson_options.txt
@@ -95,6 +95,13 @@ option(
   choices : ['true', 'false', 'auto'],
   description : '''Enable support for vc4's KMS API.''',
 )
+option(
+  'vivante',
+  type : 'combo',
+  value : 'false',
+  choices : ['true', 'false', 'auto'],
+  description : '''Enable support for vivante's propriatary experimental KMS API.''',
+)
 option(
   'etnaviv',
   type : 'combo',
diff --git a/vivante/meson.build b/vivante/meson.build
new file mode 100644
index 00000000..f6adb598
--- /dev/null
+++ b/vivante/meson.build
@@ -0,0 +1,50 @@
+# Copyright © 2017-2018 Intel Corporation
+
+# Permission is hereby granted, free of charge, to any person obtaining a copy
+# of this software and associated documentation files (the "Software"), to deal
+# in the Software without restriction, including without limitation the rights
+# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
+# copies of the Software, and to permit persons to whom the Software is
+# furnished to do so, subject to the following conditions:
+
+# The above copyright notice and this permission notice shall be included in
+# all copies or substantial portions of the Software.
+
+# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
+# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+# SOFTWARE.
+
+
+libdrm_vivante = shared_library(
+  'drm_vivante',
+  [
+    files(
+      'vivante_bo.c',
+    ),
+    config_file
+  ],
+  include_directories : [inc_root, inc_drm],
+  link_with : libdrm,
+  c_args : libdrm_c_args,
+  dependencies : [dep_pthread_stubs, dep_rt, dep_atomic_ops],
+  version : '1.0.0',
+  install : true,
+)
+
+pkg.generate(
+  name : 'libdrm_vivante',
+  libraries : libdrm_vivante,
+  subdirs : ['.', 'libdrm'],
+  version : meson.project_version(),
+  requires_private : 'libdrm',
+  description : 'Userspace interface to Vivante kernel DRM services',
+)
+
+ext_libdrm_vivante = declare_dependency(
+  link_with : [libdrm, libdrm_vivante],
+  include_directories : [inc_drm, include_directories('.')],
+)" > $GRAPHIC_DTS/imx8-graphic/recipes-graphics/drm/libdrm/0001-meson-add-libdrm-vivante-to-the-meson-meta-data.patch 

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-sdk/
file_copy recipes-graphics/gli/gli_0.8.2.0.bb \
				'15i\    file://0001-Fix-build-error-Ordered-comparison-of-pointer-with-i.patch \\'
file_copy recipes-graphics/gli/gli/0001-Set-C-standard-through-CMake-standard-options.patch
file_copy recipes-graphics/glm/glm_0.9.8.5.bb
file_copy recipes-graphics/glm/glm/Fixed-GCC-7.3-compile.patch
mkdir -p $GRAPHIC_DTS/imx8-graphic/recipes-graphics/gli/files
touch $GRAPHIC_DTS/imx8-graphic/recipes-graphics/gli/gli/0001-Fix-build-error-Ordered-comparison-of-pointer-with-i.patch
echo "From e19ce2b0a962c51f7a2562ef52e379c7459d4f9d Mon Sep 17 00:00:00 2001
From: Xiaolei Wang <xiaolei.wang@windriver.com>
Date: Fri, 23 Jul 2021 14:43:38 +0800
Subject: [PATCH] Fix build error Ordered comparison of pointer with integer

Signed-off-by: Xiaolei Wang <xiaolei.wang@windriver.com>
---
 test/core/core_convert.cpp | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/core/core_convert.cpp b/test/core/core_convert.cpp
index 66af62fb..c003fef6 100644
--- a/test/core/core_convert.cpp
+++ b/test/core/core_convert.cpp
@@ -32,7 +32,7 @@ bool convert_rgb32f_rgb9e5(const char* FilenameSrc, const char* FilenameDst)
 {
 	if(FilenameDst == NULL)
 		return false;
-	if(std::strstr(FilenameDst, \".dds\") > 0 || std::strstr(FilenameDst, \".ktx\") > 0)
+	if(std::strstr(FilenameDst, \".dds\") != 0 || std::strstr(FilenameDst, \".ktx\") != 0)
 		return false;
 
 	gli::texture2d TextureSource(gli::load(FilenameSrc));
-- 
2.25.1" > $GRAPHIC_DTS/imx8-graphic/recipes-graphics/gli/gli/0001-Fix-build-error-Ordered-comparison-of-pointer-with-i.patch
mkdir -p $GRAPHIC_DTS/imx8-graphic/recipes-graphics/rapidjson
touch $GRAPHIC_DTS/imx8-graphic/recipes-graphics/rapidjson/rapidjson_git.bbappend
echo "FILES:\${PN}-dev += \"\${libdir_native}/*\"" > $GRAPHIC_DTS/imx8-graphic/recipes-graphics/rapidjson/rapidjson_git.bbappend

if [ $PLATFORM_TYPE = "imx8qm" ]; then
SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/imx-dpu-g2d/imx-dpu-g2d_1.9.0.bb \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"
SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/imx-dpu-g2d/imx-dpu-g2d_1.8.7.bb \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-g2d/imx-gpu-g2d_6.4.3.p1.2.bb \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"
SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/imx-gpu-g2d/imx-gpu-g2d_6.4.0.p2.4.bb \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"

elif [ $PLATFORM_TYPE = "imx8mm" ]; then
SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-g2d/imx-gpu-g2d_6.4.3.p1.2.bb \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"
SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/imx-gpu-g2d/imx-gpu-g2d_6.4.0.p2.4.bb \
                        "s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"

elif [ $PLATFORM_TYPE = "imx8qxp" ]; then
SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/imx-dpu-g2d/imx-dpu-g2d_1.8.12.bb
SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/imx-dpu-g2d/imx-dpu-g2d_1.7.0.bb \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"
fi

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-apitrace/imx-gpu-apitrace_9.0.0.bb

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-sdk/
file_copy recipes-graphics/imx-gpu-sdk/imx-gpu-sdk_5.6.2.bb \
                        "/glslang-native rapidvulkan vulkan-headers vulkan-loader/d" \
			"44i\SRC_URI += \"file://0001-Fix-build-warning-for-C-11.patch \"" \	
mkdir -p $GRAPHIC_DTS/imx8-graphic/recipes-graphics/imx-gpu-sdk/files
touch $GRAPHIC_DTS/imx8-graphic/recipes-graphics/imx-gpu-sdk/files/0001-Fix-build-warning-for-C-11.patch
echo "From e6732b1bf9e0b44daf92d7b12075c8d3ccc70c81 Mon Sep 17 00:00:00 2001
From: Xiaolei Wang <xiaolei.wang@windriver.com>
Date: Thu, 22 Jul 2021 11:27:31 +0800
Subject: [PATCH] Fix build warning for C++ 11

Signed-off-by: Xiaolei Wang <xiaolei.wang@windriver.com>
---
 .../include/Shared/ObjectSelection/BoundingBoxUtil.hpp        | 1 +
 .../source/Shared/ObjectSelection/BoundingBoxUtil.cpp         | 1 +
 .../source/FslGraphics3D/SceneFormat/Conversion.cpp           | 1 +
 .../Base/source/FslSimpleUI/Base/Layout/GridLayout.cpp        | 4 ++--
 4 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/DemoApps/Shared/ObjectSelection/include/Shared/ObjectSelection/BoundingBoxUtil.hpp b/DemoApps/Shared/ObjectSelection/include/Shared/ObjectSelection/BoundingBoxUtil.hpp
index 03cb940f..56cd0583 100644
--- a/DemoApps/Shared/ObjectSelection/include/Shared/ObjectSelection/BoundingBoxUtil.hpp
+++ b/DemoApps/Shared/ObjectSelection/include/Shared/ObjectSelection/BoundingBoxUtil.hpp
@@ -34,6 +34,7 @@
 #include <FslBase/Math/BoundingBox.hpp>
 #include <FslBase/Math/Matrix.hpp>
 #include <vector>
+#include <limits>
 
 namespace Fsl
 {
diff --git a/DemoApps/Shared/ObjectSelection/source/Shared/ObjectSelection/BoundingBoxUtil.cpp b/DemoApps/Shared/ObjectSelection/source/Shared/ObjectSelection/BoundingBoxUtil.cpp
index 029f56eb..cd854641 100644
--- a/DemoApps/Shared/ObjectSelection/source/Shared/ObjectSelection/BoundingBoxUtil.cpp
+++ b/DemoApps/Shared/ObjectSelection/source/Shared/ObjectSelection/BoundingBoxUtil.cpp
@@ -32,6 +32,7 @@
 #include <Shared/ObjectSelection/BoundingBoxUtil.hpp>
 #include <FslBase/Math/Vector4.hpp>
 #include <array>
+#include <limits>
 
 namespace Fsl
 {
diff --git a/DemoFramework/FslGraphics3D/SceneFormat/source/FslGraphics3D/SceneFormat/Conversion.cpp b/DemoFramework/FslGraphics3D/SceneFormat/source/FslGraphics3D/SceneFormat/Conversion.cpp
index a916929a..4247926e 100644
--- a/DemoFramework/FslGraphics3D/SceneFormat/source/FslGraphics3D/SceneFormat/Conversion.cpp
+++ b/DemoFramework/FslGraphics3D/SceneFormat/source/FslGraphics3D/SceneFormat/Conversion.cpp
@@ -34,6 +34,7 @@
 #include <algorithm>
 #include <cassert>
 #include <vector>
+#include <limits>
 
 namespace Fsl
 {
diff --git a/DemoFramework/FslSimpleUI/Base/source/FslSimpleUI/Base/Layout/GridLayout.cpp b/DemoFramework/FslSimpleUI/Base/source/FslSimpleUI/Base/Layout/GridLayout.cpp
index fc718ea0..953176d1 100644
--- a/DemoFramework/FslSimpleUI/Base/source/FslSimpleUI/Base/Layout/GridLayout.cpp
+++ b/DemoFramework/FslSimpleUI/Base/source/FslSimpleUI/Base/Layout/GridLayout.cpp
@@ -163,7 +163,7 @@ namespace Fsl
         m_definitionCache.HasEntriesX = true;
       }
 
-      return m_definitionsX.emplace_back(definition);
+      m_definitionsX.emplace_back(definition);
     }
 
     void GridLayout::AddRowDefinition(const GridRowDefinition& definition)
@@ -175,7 +175,7 @@ namespace Fsl
         m_definitionCache.HasEntriesY = true;
       }
 
-      return m_definitionsY.emplace_back(definition);
+      m_definitionsY.emplace_back(definition);
     }
 
 
-- 
2.25.1" > $GRAPHIC_DTS/imx8-graphic/recipes-graphics/imx-gpu-sdk/files/0001-Fix-build-warning-for-C-11.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv/Add-dummy-libgl.patch
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv_6.4.3.p1.2-aarch64.bb
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv-6.inc \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g" \
			"/kernel-module-imx-gpu-viv/d"
			

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/mesa/mesa_%.bbappend \
			"s/'DISTRO_FEATURES', 'wayland'/'DISTRO_FEATURES', 'weston-demo'/g" \
			"\$a\\\n# Undo customization in meta-freescale that doesn't apply to 8DXL" \
			"28,36d" \
                        "\$aPACKAGECONFIG_remove_mx8dxl = \"osmesa\"" \
                        "\$aDRIDRIVERS_remove = \"swrast\""

file_copy recipes-graphics/mesa/mesa-demos/Add-OpenVG-demos-to-support-wayland.patch
file_copy recipes-graphics/mesa/mesa-demos/fix-clear-build-break.patch
file_copy recipes-graphics/mesa/mesa-demos/Replace-glWindowPos2iARB-calls-with-glWindowPos2i.patch
file_copy recipes-graphics/mesa/mesa-demos_%.bbappend
file_copy recipes-graphics/mesa/mesa-gl_%.bbappend

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-sdk/

file_copy recipes-graphics/rapidopencl/rapidopencl_1.1.0.1.bb
file_copy recipes-graphics/rapidopenvx/rapidopenvx_1.1.0.bb
file_copy recipes-graphics/rapidvulkan/rapidvulkan_1.2.141.2001.bb

file_copy recipes-graphics/vulkan/spirv-tools_git.bb \
				'13i\    file://0001-Fix-build-error-range-loop-analysis-diagnostic.patch \\' \
				"24i\CXXFLAGS += \"-Wno-stringop-truncation\""
file_copy recipes-graphics/vulkan/spirv-tools/0001-Avoid-GCC8-warning-in-text_handler.cpp.-2197.patch
file_copy recipes-graphics/vulkan/spirv-tools/0001-tools-lesspipe-Allow-generic-shell.patch
mkdir -p $GRAPHIC_DTS/imx8-graphic/recipes-graphics/vulkan/spirv-tools/files
touch $GRAPHIC_DTS/imx8-graphic/recipes-graphics/vulkan/spirv-tools/0001-Fix-build-error-range-loop-analysis-diagnostic.patch
echo "From c1a1cf55531d431234d7f42520635303b522a18a Mon Sep 17 00:00:00 2001
From: Xiaolei Wang <xiaolei.wang@windriver.com>
Date: Wed, 14 Jul 2021 19:00:38 +0800
Subject: [PATCH] Fix build error 'range-loop-analysis' diagnostic

Signed-off-by: Xiaolei Wang <xiaolei.wang@windriver.com>
---
 source/val/validate.cpp         | 4 ++--
 source/val/validation_state.cpp | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/source/val/validate.cpp b/source/val/validate.cpp
index 6f1a26c6..477e4f17 100644
--- a/source/val/validate.cpp
+++ b/source/val/validate.cpp
@@ -142,7 +142,7 @@ spv_result_t ValidateEntryPointNameUnique(ValidationState_t& _,
   for (const auto other_id : _.entry_points()) {
     if (other_id == id) continue;
     const auto other_id_names = CalculateNamesForEntryPoint(_, other_id);
-    for (const auto other_id_name : other_id_names) {
+    for (const auto &other_id_name : other_id_names) {
       if (names.find(other_id_name) != names.end()) {
         return _.diag(SPV_ERROR_INVALID_BINARY, _.FindDef(id))
                << "Entry point name \"" << other_id_name
@@ -410,7 +410,7 @@ spv_result_t ValidateBinaryUsingContextAndValidationState(
   if (auto error = ValidateBuiltIns(*vstate)) return error;
   // These checks must be performed after individual opcode checks because
   // those checks register the limitation checked here.
-  for (const auto inst : vstate->ordered_instructions()) {
+  for (const auto &inst : vstate->ordered_instructions()) {
     if (auto error = ValidateExecutionLimitations(*vstate, &inst)) return error;
     if (auto error = ValidateSmallTypeUses(*vstate, &inst)) return error;
   }
diff --git a/source/val/validation_state.cpp b/source/val/validation_state.cpp
index 794d0f7b..91421edd 100644
--- a/source/val/validation_state.cpp
+++ b/source/val/validation_state.cpp
@@ -1057,7 +1057,7 @@ void ValidationState_t::ComputeFunctionToEntryPointMapping() {
 }

 void ValidationState_t::ComputeRecursiveEntryPoints() {
-  for (const Function func : functions()) {
+  for (const Function &func : functions()) {
     std::stack<uint32_t> call_stack;
     std::set<uint32_t> visited;

--
2.25.1" > $GRAPHIC_DTS/imx8-graphic/recipes-graphics/vulkan/spirv-tools/0001-Fix-build-error-range-loop-analysis-diagnostic.patch

file_copy recipes-graphics/vulkan/vkmark_1.0.bb
file_copy recipes-graphics/vulkan/vkmark/0001-scenes-Use-depth-format-supported-by-i.MX.patch

file_copy recipes-graphics/vulkan/vulkan-loader_1.1.121.bb
file_copy recipes-graphics/vulkan/vulkan-loader_1.1.121.bbappend
file_copy recipes-graphics/vulkan/vulkan-loader/0001-STDIO-844-No-need-to-change-the-App-s-apiVersion-to-.patch

file_copy recipes-graphics/vulkan/vulkan-validationlayers_1.1.121.bb
file_copy recipes-graphics/vulkan/vulkan-validationlayers_%.bbappend
file_copy recipes-graphics/vulkan/vulkan-validationlayers/0001-CMakeLists.txt-Change-the-installation-path-of-JSON-.patch
file_copy recipes-graphics/vulkan/vulkan-validationlayers/icd_VSI.json

file_copy recipes-graphics/vulkan/glslang_git.bb

file_copy recipes-graphics/vulkan/vulkan-headers_%.bbappend
file_copy recipes-graphics/vulkan/vulkan-headers_1.1.121.bb

file_copy recipes-graphics/vulkan/vulkan-demos_%.bbappend

file_copy recipes-graphics/vulkan/vulkan-tools_1.1.121.bb
file_copy recipes-graphics/vulkan/vulkan-tools_%.bbappend

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/vulkan/assimp_5.0.1.bb
file_copy recipes-graphics/vulkan/assimp/0001-closes-https-github.com-assimp-assimp-issues-2733-up.patch
file_copy recipes-graphics/vulkan/assimp/0001-Use-ASSIMP_LIB_INSTALL_DIR-to-search-library.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/wayland/weston-init.bbappend \
			"44i\    install -Dm0755 \${WORKDIR}/profile \${D}\${sysconfdir}/profile.d/weston.sh" \
			"\$a\\\nSRC_URI += \"file://profile\""

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/wayland/weston-init/imx/weston.ini
file_copy recipes-graphics/wayland/weston-init/profile
SOURCE_DIR=$GRAPHIC_SRC/poky/meta/
file_copy recipes-graphics/wayland/weston-init.bb \
                '72i\COMPATIBLE_MACHINE_nxp-imx8 = \"nxp-imx8\"'
file_copy recipes-graphics/wayland/weston-init/weston-start
file_copy recipes-graphics/wayland/weston-init/weston@.service
echo "[Unit]
Description=Weston Wayland Compositor (on tty7)
RequiresMountsFor=/run
Conflicts=getty@tty7.service plymouth-quit.service
After=systemd-user-sessions.service getty@tty7.service plymouth-quit-wait.service

[Service]
User=%i
PermissionsStartOnly=true

# Log us in via PAM so we get our XDG & co. environment and
# are treated as logged in so we can use the tty:
PAMName=login

# Grab tty7
UtmpIdentifier=tty7
TTYPath=/dev/tty7
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes

# stderr to journal so our logging doesn't get thrown into /dev/null
StandardOutput=tty
StandardInput=tty
StandardError=journal

EnvironmentFile=-/etc/default/weston

# Weston does not successfully change VT, nor does systemd place us on
# the VT it just activated for us. Switch manually:
ExecStartPre=/usr/bin/chvt 7
ExecStart=/usr/bin/weston --log=\${XDG_RUNTIME_DIR}/weston.log \$OPTARGS

IgnoreSIGPIPE=no

#[Install]
#Alias=multi-user.target.wants/weston.service" > $GRAPHIC_DTS/imx8-graphic/recipes-graphics/wayland/weston-init/weston@.service
file_copy recipes-graphics/wayland/weston-init/weston.env
file_copy recipes-graphics/wayland/weston-init/weston@.socket
file_copy recipes-graphics/wayland/weston-init/weston-autologin
file_copy recipes-graphics/wayland/weston-init/init
file_copy recipes-graphics/wayland/weston-init/71-weston-drm.rules
SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/wayland/weston-init/mx6sl/weston.config

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/wayland/weston_9.0.0.imx.bb
sed -i "s/weston_9.0.0.bb/weston_9.0.0.sdk.bb/g" $DESTINATION_DIR/recipes-graphics/wayland/weston_9.0.0.imx.bb
SOURCE_DIR=$GRAPHIC_SRC/poky/meta/
file_copy recipes-graphics/wayland/weston_9.0.0.bb
mv $DESTINATION_DIR/recipes-graphics/wayland/weston_9.0.0.bb $DESTINATION_DIR/recipes-graphics/wayland/weston_9.0.0.sdk.bb
file_copy recipes-graphics/wayland/weston/0001-weston-launch-Provide-a-default-version-that-doesn-t.patch
file_copy recipes-graphics/wayland/weston/0001-tests-include-fcntl.h-for-open-O_RDWR-O_CLOEXEC-and-.patch
file_copy recipes-graphics/wayland/weston/weston.desktop
file_copy recipes-graphics/wayland/weston/weston.png
file_copy recipes-graphics/wayland/weston/xwayland.weston-start
echo "From a2ba4714a6872e547621d29d9ddcb0f374b88cf6 Mon Sep 17 00:00:00 2001
From: Chen Qi <Qi.Chen@windriver.com>
Date: Tue, 20 Apr 2021 20:42:18 -0700
Subject: [PATCH] meson.build: fix incorrect header

The wayland.c actually include 'xdg-shell-client-protocol.h' instead of
the server one, so fix it. Otherwise, it's possible to get build failure
due to race condition.

Upstream-Status: Pending

Signed-off-by: Chen Qi <Qi.Chen@windriver.com>
---
 libweston/backend-wayland/meson.build | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libweston/backend-wayland/meson.build b/libweston/backend-wayland/meson.build
index 7e82513..29270b5 100644
--- a/libweston/backend-wayland/meson.build
+++ b/libweston/backend-wayland/meson.build
@@ -10,7 +10,7 @@ srcs_wlwl = [
 	fullscreen_shell_unstable_v1_protocol_c,
 	presentation_time_protocol_c,
 	presentation_time_server_protocol_h,
-	xdg_shell_server_protocol_h,
+	xdg_shell_client_protocol_h,
 	xdg_shell_protocol_c,
 ]
 
-- 
2.30.2" >$GRAPHIC_DTS/imx8-graphic/recipes-graphics/wayland/weston/0001-meson.build-fix-incorrect-header.patch

file_copy recipes-graphics/wayland/wayland-protocols_1.20.bb
SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/wayland/wayland-protocols_1.20.imx.bb
SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/wayland/wayland-protocols_1.18.imx.bb

file_copy recipes-graphics/xorg-xserver/xserver-xorg_%.bbappend \
			"\$a# Trailing space is intentional due to a bug in meta-freescale" \
			"\$aSRC_URI += \"file://0001-glamor-Use-CFLAGS-for-EGL-and-GBM.patch \"" \
			"8d"
SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0001-glamor-Use-CFLAGS-for-EGL-and-GBM.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg_1.20.8.bb
file_copy recipes-graphics/xorg-xserver/xserver-xorg.inc
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0001-drmmode_display.c-add-missing-mi.h-include.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0001-prefer-to-use-GLES2-for-glamor-EGL-config.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0001-glamor-Use-CFLAGS-for-EGL-and-GBM.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0002-MGS-5186-Per-Specification-EGL_NATIVE_PIXMAP_KHR-req.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0001-MGS-5186-Per-Specification-EGL_NATIVE_PIXMAP_KHR-req.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0003-Remove-GL-library-and-dependency-from-xwayland.patch
file_copy recipes-graphics/xorg-xserver/files/0001-test-xtest-Initialize-array-with-braces.patch
file_copy recipes-graphics/xorg-xserver/files/0001-xf86pciBus.c-use-Intel-ddx-only-for-pre-gen4-hardwar.patch
file_copy recipes-graphics/xorg-xserver/files/pkgconfig.patch
file_copy recipes-graphics/xorg-xserver/files/sdksyms-no-build-path.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config_%.bbappend
SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config/imx/xorg.conf
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config/imxdrm/xorg.conf

file_copy recipes-kernel/linux/linux-imx-headers_5.10.bb \
			"9iDEPENDS += \"rsync-native\"" \
			"11,16d" \
			"11iSRCBRANCH = \"v5.10/standard/nxp-sdk-5.10/nxp-soc\"" \
			"12iKERNEL_SRC ?= \"git://\${LAYER_PATH_wrlinux}/git/linux-yocto.git;protocol=file\"" \
			"13iSRC_URI = \"\${KERNEL_SRC};branch=\${SRCBRANCH}\"" \
			"14iSRCREV = \"\${AUTOREV}\""

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/waffle/waffle_%.bbappend
file_copy recipes-graphics/waffle/waffle/0001-meson-Add-missing-wayland-dependency-on-EGL.patch
file_copy recipes-graphics/waffle/waffle/0002-meson-Separate-surfaceless-option-from-x11.patch

# Add machine learning package
SOURCE_DIR=$GRAPHIC_SRC/meta-openembedded/meta-python/
file_copy recipes-devtools/python/python3-pybind11/0001-Do-not-check-pointer-size-when-cross-compiling.patch
file_copy recipes-devtools/python/python3-pybind11/0001-Do-not-strip-binaries.patch
file_copy recipes-devtools/python/python3-pybind11_2.5.0.bb
file_copy recipes-devtools/python/python3-pybind11-json_0.2.6.bb
file_copy recipes-devtools/python/python3-wheel_0.35.1.bb
mkdir -p $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python3-pybind11
mkdir -p $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python3-pybind11/python3-pybind11
mv $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python3-pybind11/0001-Do-not-check-pointer-size-when-cross-compiling.patch $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python3-pybind11/python3-pybind11/
mv $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python3-pybind11/0001-Do-not-strip-binaries.patch $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python3-pybind11/python3-pybind11/
mv $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python3-pybind11_2.5.0.bb $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python3-pybind11
mv $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python3-pybind11-json_0.2.6.bb $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python3-pybind11
mkdir -p $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python-wheel
mv $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python3-wheel_0.35.1.bb $GRAPHIC_DTS/imx8-graphic/recipes-devtools/python/python-wheel

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-ml/
file_copy recipes-devtools/armnn-swig/armnn-swig/0001-configure-use-pkg-config-for-pcre-detection.patch
file_copy recipes-devtools/armnn-swig/armnn-swig_4.0.2.bb
file_copy recipes-devtools/armnn-swig/armnn-swig.inc \
			"N;68aFILES:\${PN}-dev += \"\${datadir_native\}/*\""
file_copy recipes-devtools/flatbuffers/flatbuffers_1.11.0.bb
file_copy recipes-devtools/flatbuffers/flatbuffers-native_1.11.0.bb
file_copy recipes-libraries/arm-compute-library/arm-compute-library_git-imx.bb \
			"s/a700d9de43fc22e998001a63c3feb1d2/9598101cf48c5f479cfda9f3fc6fc566/g" \
			"s/lf-5.10.y_1.0.0/lf-5.10.y_2.0.0/g" \
			"s/203f466760aa584913ff11d744078f817d9efee5/34e527e5a7d3df85560ec89f68b61207b8a030df/g" \
			"38i\	cp \$CP_ARGS \${S}/src \${D}\${includedir}"
file_copy recipes-libraries/armnn/armnn/0001-AIR-3570_pyarmnn-yocto-cross-compile.patch
file_copy recipes-libraries/armnn/armnn_20.08.bb \
			"s/lf-5.10.y_1.0.0/lf-5.10.y_2.0.0/g" \
			"s/a9de15b5faed05dfa8f94030060bac1e0df0f21d/77ec2f724585ae3de2bc866c3d14e7501e158396/g" \
			"20d" \
			"s/-fopenmp/-fopenmp -Wno-uninitialized/g" \
			"s/armnn-onnx/armnn-onnx-protobuf/g"
file_copy recipes-libraries/armnn/armnn-caffe_1.0.bb
file_copy recipes-libraries/armnn/armnn-onnx_1.3.0.bb
mv $GRAPHIC_DTS/imx8-graphic/recipes-libraries/armnn/armnn-onnx_1.3.0.bb $GRAPHIC_DTS/imx8-graphic/recipes-libraries/armnn/armnn-onnx-protobuf_1.6.0.bb
echo "# Copyright 2020-2021 NXP
SUMMARY = \"ONNX protobuf files - used in Arm NN for ONNX parser\"
LICENSE = \"MIT\"
LIC_FILES_CHKSUM = \"file://LICENSE;md5=efff5c5110f124a1e2163814067b16e7\"

SRC_URI = \"git://github.com/onnx/onnx.git;branch=rel-1.6.0\"
SRCREV = \"553df22c67bee5f0fe6599cff60f1afc6748c635\"
DEPENDS = \"protobuf-native\"

inherit cmake

S = \"\${WORKDIR}/git\"

do_configure[noexec] = \"1\"

do_compile() {
    \${STAGING_BINDIR_NATIVE}/protoc \\
    \${S}/onnx/onnx.proto \\
    --proto_path=\${S} \\
    --proto_path=\${STAGING_INCDIR_NATIVE} \\
    --cpp_out \${S}
}

do_install() {
    install -d \${D}\${datadir}/\${BPN}/onnx/
    for file in \${S}/onnx/onnx.pb.*
    do
        install -m 0644 \$file \${D}\${datadir}/\${BPN}/onnx/
    done
}" > $GRAPHIC_DTS/imx8-graphic/recipes-libraries/armnn/armnn-onnx-protobuf_1.6.0.bb
file_copy recipes-libraries/armnn/armnn-tensorflow_1.15.0.bb
file_copy recipes-libraries/nn-imx/nn-imx_1.1.9.bb
file_copy recipes-libraries/onnxruntime/onnxruntime_1.5.3.bb \
			"s/lf-5.10.y_1.0.0/lf-5.10.y_2.0.0/g" \
			"s/e9ddc224126e678723260adb7eb10ad89dd6ea68/0a15796c7108521f91c6ae3ecd870fd173491250/g" \
			'15i\    file://0001-Fix-a-build-error-sleep_for-number-for-thread.patch \\' \
			'16i\    file://0002-Fix-a-build-error-about-header-file-reference-error.patch \\'
file_copy recipes-libraries/onnxruntime/onnxruntime-native_1.5.3.bb
mkdir -p $GRAPHIC_DTS/imx8-graphic/recipes-libraries/onnxruntime/onnxruntime
echo "From d9ecb52f701dc7b9c54b41527780ca0b4ec94edb Mon Sep 17 00:00:00 2001
From: Xiaolei Wang <xiaolei.wang@windriver.com>
Date: Tue, 7 Sep 2021 12:46:17 +0800
Subject: [PATCH] Fix a build error sleep_for number for thread

include thread header file

Signed-off-by: Xiaolei Wang <xiaolei.wang@windriver.com>
---
 onnxruntime/test/providers/cpu/controlflow/loop_test.cc | 1 +
 1 file changed, 1 insertion(+)

diff --git a/onnxruntime/test/providers/cpu/controlflow/loop_test.cc b/onnxruntime/test/providers/cpu/controlflow/loop_test.cc
index 9a6ce3f7..30d0d705 100644
--- a/onnxruntime/test/providers/cpu/controlflow/loop_test.cc
+++ b/onnxruntime/test/providers/cpu/controlflow/loop_test.cc
@@ -12,6 +12,7 @@
 #include \"test/providers/provider_test_utils.h\"
 #include \"test/util/include/default_providers.h\"
 #include \"test/framework/test_utils.h\"
+#include <thread>

 using namespace ONNX_NAMESPACE;

--
2.25.1" > $GRAPHIC_DTS/imx8-graphic/recipes-libraries/onnxruntime/onnxruntime/0001-Fix-a-build-error-sleep_for-number-for-thread.patch
echo "From 30705f2f45a6dd8caea9ca52e87d7c9c2f4eb7c0 Mon Sep 17 00:00:00 2001
From: Xiaolei Wang <xiaolei.wang@windriver.com>
Date: Tue, 7 Sep 2021 13:22:24 +0800
Subject: [PATCH] Fix a build error about header file reference error

Signed-off-by: Xiaolei Wang <xiaolei.wang@windriver.com>
---
 onnxruntime/core/providers/acl/nn/conv.cc | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/onnxruntime/core/providers/acl/nn/conv.cc b/onnxruntime/core/providers/acl/nn/conv.cc
index 9e1af467..aa48051f 100644
--- a/onnxruntime/core/providers/acl/nn/conv.cc
+++ b/onnxruntime/core/providers/acl/nn/conv.cc
@@ -18,10 +18,11 @@
 #include \"core/providers/acl/acl_fwd.h\"

 // ACL
+#include \"src/core/helpers/WindowHelpers.h\"
 #include \"arm_compute/core/TensorInfo.h\"
 #include \"arm_compute/core/utils/misc/ShapeCalculator.h\"
 #if defined(ACL_2008)
-#include \"arm_compute/core/AccessWindowStatic.h\"
+#include \"src/core/AccessWindowStatic.h\"
 #endif
 // NEON
 #include \"arm_compute/runtime/NEON/functions/NEConvolutionLayer.h\"
--
2.25.1" > $GRAPHIC_DTS/imx8-graphic/recipes-libraries/onnxruntime/onnxruntime/0002-Fix-a-build-error-about-header-file-reference-error.patch
file_copy recipes-libraries/tensorflow-lite/tensorflow-lite_2.4.0.bb \
			"s/51c167ba94488ae1d7599ad20c985c93484bac92/1c1ed6663a73d5d47a5a96e0e9fa85d2db280954/g" \
			"s/lf-5.10.y_1.0.0/lf-5.10.y_2.0.0/g" \
			"s/SSTATE_DUPWHITELIST/SSTATE_ALLOW_OVERLAP_FILES/g" \
			"32i\do_compile:prepend () {" \
			"33i\    sed -i 'N;30i\\\#include <limits>' \${S}/tensorflow/lite/tools/make/downloads/ruy/ruy/block_map.cc" \
			"34i\    sed -i 'N;30i\\\#include <limits>' \${S}/../build/abseil-cpp/absl/synchronization/internal/graphcycles.cc" \
			"35i\    sed -i 'N;30i\\\#include <limits>' \${S}/../build/ruy/ruy/block_map.cc" \
			"36i\}"


SOURCE_DIR=$GRAPHIC_SRC/meta-imx/
file_copy EULA.txt
mv $GRAPHIC_DTS/imx8-graphic/EULA.txt $GRAPHIC_DTS/imx8-graphic/EULA

convert_override(){
	if [ $PLATFORM_TYPE = "imx8qm" ];then
		patchdir="`dirname $1`/patch"
		patch -p2 -d $GRAPHIC_DTS/imx8-graphic < $patchdir/0001-nxp-imx8-imx8-graphic-convert-to-use-new-override.patch 2>&1 > /dev/null
		if [ $? != 0 ];then
                        echo "Error: apply patch1 failed"
                fi
		patch -p1 -d $GRAPHIC_DTS/imx8-graphic < $patchdir/0002-nxp-imx8-generate-graphic-layer.sh-add-machine-learn.patch 2>&1 > /dev/null
		if [ $? != 0 ];then
			echo "Error: apply patch2 failed"
		fi
	fi
}

convert_override $0

echo "Graphic layer is generated successfully!"
clean_up && exit 1
