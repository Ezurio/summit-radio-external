#! /bin/bash

set -e -o pipefail

err_report() {
    [ $? -eq 0 ] || echo "Error calculating hashes" > /dev/stderr
}

prefix="/var/www/html/builds/linux"
cmd="ssh -o ControlMaster=auto -o ControlPersist=5s -o ControlPath=/tmp/ssh-fileshare fileshare@files.devops.rfpros.com"

calc_hash() {
  ${cmd} "set -e; cd ${prefix} && sha256sum ${1}" | \
    sed -r "s/([0-9a-f]+)  .*\/(.*-[0-9.]+\.tar.*)/sha256  \1  \2/"
}

hash_file() {
	echo "package/${1}/${1}.hash"
}

version=${1}
sed -i -r "s/(.+=).*/\1 ${1}/g" versions.mk

LICENSE_SUMMIT='sha256  ff126d9b0f7f474b2652064d045c6b25a015eb94f9d0ac29c96d053c94577343  LICENSE.ezurio'

# Calculate hashes for the summit-adaptive_ww package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} adaptive_ww/laird/${version}/adaptive_ww-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-adaptive_ww)"

# Calculate hashes for the summit-adaptive_bt package
{
	files="adaptive_bt/src/${version}/adaptive_bt-src-${version}.tar.gz"
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-adaptive_bt)"

# Calculate hashes for the summit-supplicant-libs package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} summit_supplicant/laird/${version}/summit_supplicant_libs-${i}-${version}.tar.bz2"
	done

	for i in arm-eabi arm-eabihf
	do
		files="${files} summit_supplicant/laird/${version}/summit_supplicant_libs_legacy-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-supplicant-libs)"

# Calculate hashes for the summit-supplicant package
{
	files="summit_supplicant/laird/${version}/summit_supplicant-src-${version}.tar.gz"
	calc_hash "${files}"

	echo "sha256  f1b5992bbdd015c3ccb7faaadd62ef58ed821e15b9329bf2ceb27511ccc3f562  README"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-supplicant)"

# Calculate hashes for the summit-hostapd package
cp -f "$(hash_file summit-supplicant)" "$(hash_file summit-hostapd)"

# Calculate hashes for the summit-linux-backports package
{
	files="backports/laird/${version}/summit-backports-${version}.tar.bz2"
	calc_hash "${files}"

	echo "sha256  fb5a425bd3b3cd6071a3a9aff9909a859e7c1158d54d32e07658398cd67eb6a0  COPYING"
	echo "sha256  8e378ab93586eb55135d3bc119cce787f7324f48394777d00c34fa3d0be3303f  LICENSES/exceptions/Linux-syscall-note"
	echo "sha256  8780e78a1a737e127f25a65f6d95269bffd36158dc261114de7859b490bfc5aa  LICENSES/preferred/GPL-2.0"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-linux-backports)"

# Calculate hashes for the summit-network-manager package
{
	files="lrd-network-manager/src/${version}/summit-network-manager-src-${version}.tar.xz"
	calc_hash "${files}"

	echo "sha256  8177f97513213526df2cf6184d8ff986c675afb514d4e68a404010521b880643  COPYING"
	echo "sha256  dc626520dcd53a22f727af3ee42c770e56c97a64fe3adb063799d8ab032fe551  COPYING.LGPL"
	echo "sha256  1213e0d2a9c2365ce03db244ea3cd1097682b15fd434c1221db42b26d39b8f9e  CONTRIBUTING.md"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-network-manager)"

# Calculate hashes for the summit-firmware-60 package
{
	files=
	for i in pcie-uart pcie-usb sdio-uart sdio-sdio usb-usb usb-uart
	do
		files="${files} firmware/${version}/summit-60-radio-firmware-${i}-${version}.tar.bz2"
	done
	files="${files} firmware/${version}/summit-som8mp-radio-firmware-${version}.tar.bz2"
	calc_hash "${files}"

	echo "sha256  2accdbff2dfad766f2533a8976f15f550625253987b6ee75c06f80a8227822c2  LICENSE.nxp1"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-60)"

# Calculate hashes for the summit-firmware-bdsdmac package
{
	files="firmware/${version}/summit-bdsdmac-firmware-${version}.tar.bz2"
	calc_hash "${files}"

	echo "sha256  4ea56b251222f9d121c22f92e5d860750ab1b29a1d743be83b0f3af311d4972c  LICENSE.qca_firmware"
} > "$(hash_file summit-firmware-bdsdmac)"

# Calculate hashes for the summit-firmware-lwb package
{
	files=
	files="${files} firmware/${version}/summit-lwb-firmware-${version}.tar.bz2"
	files="${files} firmware/${version}/summit-lwbplus-firmware-${version}.tar.bz2"

	for i in sdio-div sdio-sa sdio-sa-m2 usb-div usb-sa usb-sa-m2
	do
		files="${files} firmware/${version}/summit-lwb5plus-${i}-firmware-${version}.tar.bz2"
	done

	for i in sdio pcie
	do
		files="${files} firmware/${version}/summit-if573-${i}-firmware-${version}.tar.bz2"
	done

	for i in sdio-div sdio-sa
	do
		files="${files} firmware/${version}/summit-if513-${i}-firmware-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "sha256  3a892759b73e8b459f1a750954b316118b0061fd9d1868d11fa258c104ee7e0c  LICENSE.cypress"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-lwb-if)"

# Calculate hashes for the summit-firmware-msd package
{
	files=
	for i in 6003 6004
	do
		files="${files} firmware/${version}/summit-ath6k-${i}-firmware-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "sha256  802b7014b26c606cf6248ae8b0ab1ce6d2d1b0db236d38dd269e676cd70710f2  LICENSE.atheros"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-msd)"


# Calculate hashes for the summit-firmware-nx packages
{
	files=
	files="${files} firmware/${version}/summit-nx61x-firmware-${version}.tar.bz2"
	files="${files} firmware/${version}/summit-nx61x-1218-firmware-${version}.tar.bz2"
	calc_hash "${files}"

	echo "sha256  3dd8aa2ede25fcc34b72754473dc3d3924a57b550bfcafe3a48d8bd951abf383  LICENSE.nxp2"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-nx)"

# Calculate hashes for the summit-firmware-ti package
{
	files=
	for i in WW US JP EU CA AU
	do
		files="${files} firmware/${version}/summit-ti351-${i}-firmware-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-ti)"

# Calculate hashes for the summit-mfg60n package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} mfg60n/laird/${version}/mfg60n-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-mfg60n)"

# Calculate hashes for the summit-mfg611 package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} mfg611/laird/${version}/mfg611-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-mfg611)"

# Calculate hashes for the summit-reg45n package
{
	files=
	for i in arm-eabi arm-eabihf
	do
		files="${files} reg45n/laird/${version}/reg45n-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-reg45n)"

# Calculate hashes for the summit-reg50n package
{
	files=
	for i in arm-eabi arm-eabihf
	do
		files="${files} reg50n/laird/${version}/reg50n-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-reg50n)"

# Calculate hashes for the summit-regcypress package
{
	files=
	for i in arm-eabi arm-eabihf aarch64
	do
		files="${files} regCypress/laird/${version}/regCypress-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "sha256  34c3cec7451f3a1f5d42f282358ed564bdbb3bc582073873428c3d31cc643782  FOSS_README.txt"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-regcypress)"

# Calculate hashes for the summit-reglwb5plus package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} regLWB5plus/laird/${version}/regLWB5plus-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "sha256  34c3cec7451f3a1f5d42f282358ed564bdbb3bc582073873428c3d31cc643782  FOSS_README.txt"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-reglwb5plus)"

# Calculate hashes for the summit-reglwbplus package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} regLWBplus/laird/${version}/regLWBplus-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "sha256  34c3cec7451f3a1f5d42f282358ed564bdbb3bc582073873428c3d31cc643782  FOSS_README.txt"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-reglwbplus)"

# Calculate hashes for the summit-regif573 package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} regIF573/laird/${version}/regIF573-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "sha256  34c3cec7451f3a1f5d42f282358ed564bdbb3bc582073873428c3d31cc643782  FOSS_README.txt"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-regif573)"

# Calculate hashes for the summit-regif513 package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} regIF513/laird/${version}/regIF513-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "sha256  34c3cec7451f3a1f5d42f282358ed564bdbb3bc582073873428c3d31cc643782  FOSS_README.txt"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-regif513)"

{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} regTI351/laird/${version}/regTI351-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-regti351)"
