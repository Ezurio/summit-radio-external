#!/bin/sh

set -e

err_report() {
    [ $? -eq 0 ] || echo "Error calculating hashes" > /dev/stderr
}

trap 'err_report ${LINENO} "${BASH_COMMAND}"' EXIT

get_version() {
	sed -rn "s,.*${1}.*=\s*([0-9.]+),\1,p" versions.mk
}

calc_file () {
	hash=$(/usr/bin/wget -T4 -t1 -O- "${prefix}/${1}" | sha256sum)
	printf "sha256  %s  %s\n" "${hash%% *}" "${1##*/}"
}

unique() {
	echo "$@" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

hash_file() {
	echo "package/${1}/${1}.hash"
}

if [ -n "${1}" ]; then
	sed -i -r "s/(.+=).*/\1 ${1}/g" versions.mk
fi

LICENSE_SUMMIT='sha256  ff126d9b0f7f474b2652064d045c6b25a015eb94f9d0ac29c96d053c94577343  LICENSE.ezurio'

prefix="https://files.devops.rfpros.com/builds/linux"

version_60=$(get_version "60")
version_bdsdmac=$(get_version "BDSDMAC")
version_lwb=$(get_version "LWB")
version_msd=$(get_version "MSD")
version_nx=$(get_version "NX")
version_ti=$(get_version "TI")

version_all=$(unique "${version_60}" "${version_bdsdmac}" "${version_lwb}" "${version_msd}" "${version_nx}" "${version_ti}")

# Calculate hashes for the summit-adaptive_ww package
{
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		calc_file "adaptive_ww/laird/${version_60}/adaptive_ww-${i}-${version_60}.tar.bz2"
	done
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-adaptive_ww)"

# Calculate hashes for the summit-adaptive_bt package
{
	calc_file "adaptive_bt/src/${version_60}/adaptive_bt-src-${version_60}.tar.gz"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-adaptive_bt)"

# Calculate hashes for the summit-supplicant-libs package
{
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		calc_file "summit_supplicant/laird/${version_60}/summit_supplicant_libs-${i}-${version_60}.tar.bz2"
	done

	if [ "${version_msd}" != "${version_60}" ]; then
		for i in arm-eabi arm-eabihf
		do
			calc_file "summit_supplicant/laird/${version_msd}/summit_supplicant_libs-${i}-${version_msd}.tar.bz2"
		done
	fi

	for i in arm-eabi arm-eabihf
	do
		calc_file "summit_supplicant/laird/${version_msd}/summit_supplicant_libs_legacy-${i}-${version_msd}.tar.bz2"
	done
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-supplicant-libs)"

# Calculate hashes for the summit-supplicant package
{
	for v in ${version_all}
	do
		calc_file "summit_supplicant/laird/${v}/summit_supplicant-src-${v}.tar.gz"
	done

	echo "sha256  af01e1d1ee065a1054d20ebe8a78a016f1fb1133b73e6a9d50801b165bb280c7  README"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-supplicant)"

# Calculate hashes for the summit-hostapd package
cp -f "$(hash_file summit-supplicant)" "$(hash_file summit-hostapd)"

# Calculate hashes for the summit-linux-backports package
{
	for v in ${version_all}
	do
		calc_file "backports/laird/${v}/summit-backports-${v}.tar.bz2"
	done

	echo "sha256  fb5a425bd3b3cd6071a3a9aff9909a859e7c1158d54d32e07658398cd67eb6a0  COPYING"
	echo "sha256  8e378ab93586eb55135d3bc119cce787f7324f48394777d00c34fa3d0be3303f  LICENSES/exceptions/Linux-syscall-note"
	echo "sha256  f6b78c087c3ebdf0f3c13415070dd480a3f35d8fc76f3d02180a407c1c812f79  LICENSES/preferred/GPL-2.0"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-linux-backports)"

# Calculate hashes for the summit-network-manager package
{
	for v in ${version_all}
	do
		calc_file "lrd-network-manager/src/${v}/summit-network-manager-src-${v}.tar.xz"
	done

	echo "sha256  8177f97513213526df2cf6184d8ff986c675afb514d4e68a404010521b880643  COPYING"
	echo "sha256  dc626520dcd53a22f727af3ee42c770e56c97a64fe3adb063799d8ab032fe551  COPYING.LGPL"
	echo "sha256  9f7f0d40116e5a0f1566b9da71e9c95738c99364e4b5437d8115aa614490372b  CONTRIBUTING.md"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-network-manager)"

# Calculate hashes for the summit-firmware-60 package
{
	for i in pcie-uart pcie-usb sdio-uart sdio-sdio usb-usb usb-uart
	do
		calc_file "firmware/${version_60}/summit-60-radio-firmware-${i}-${version_60}.tar.bz2"
	done
	calc_file "firmware/${version_60}/summit-som8mp-radio-firmware-${version_60}.tar.bz2"

	echo "sha256  2accdbff2dfad766f2533a8976f15f550625253987b6ee75c06f80a8227822c2  LICENSE.nxp1"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-60)"

# Calculate hashes for the summit-firmware-bdsdmac package
{
	calc_file "firmware/${version_bdsdmac}/summit-bdsdmac-firmware-${version_bdsdmac}.tar.bz2"

	echo "sha256  4ea56b251222f9d121c22f92e5d860750ab1b29a1d743be83b0f3af311d4972c  LICENSE.qca_firmware"
} > "$(hash_file summit-firmware-bdsdmac)"

# Calculate hashes for the summit-firmware-lwb package
{
	for i in etsi fcc jp
	do
		calc_file "firmware/${version_lwb}/summit-lwb-${i}-firmware-${version_lwb}.tar.bz2"
	done

	for i in etsi fcc ic jp
	do
		calc_file "firmware/${version_lwb}/summit-lwb5-${i}-firmware-${version_lwb}.tar.bz2"
	done

	for i in sdio-div sdio-sa sdio-sa-m2 usb-div usb-sa usb-sa-m2
	do
		calc_file "firmware/${version_lwb}/summit-lwb5plus-${i}-firmware-${version_lwb}.tar.bz2"
	done

	calc_file "firmware/${version_lwb}/summit-lwbplus-firmware-${version_lwb}.tar.bz2"

	for i in sdio pcie
	do
		calc_file "firmware/${version_lwb}/summit-if573-${i}-firmware-${version_lwb}.tar.bz2"
	done

	calc_file "firmware/${version_lwb}/summit-if513-sdio-firmware-${version_lwb}.tar.bz2"

	echo "sha256  3a892759b73e8b459f1a750954b316118b0061fd9d1868d11fa258c104ee7e0c  LICENSE.cypress"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-lwb-if)"

# Calculate hashes for the summit-firmware-msd package
{
	for i in 6003 6004
	do
		calc_file "firmware/${version_msd}/summit-ath6k-${i}-firmware-${version_msd}.tar.bz2"
	done

	echo "sha256  802b7014b26c606cf6248ae8b0ab1ce6d2d1b0db236d38dd269e676cd70710f2  LICENSE.atheros"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-msd)"


# Calculate hashes for the summit-firmware-nx package
{
	calc_file "firmware/${version_nx}/sona-nx61x-firmware-${version_nx}.tar.bz2"

	echo "sha256  3dd8aa2ede25fcc34b72754473dc3d3924a57b550bfcafe3a48d8bd951abf383  LICENSE.nxp2"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-nx)"

# Calculate hashes for the summit-firmware-ti package
{
	for i in WW US JP EU CA AU
	do
		calc_file "firmware/${version_ti}/summit-ti351-${i}-firmware-${version_ti}.tar.bz2"
	done

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-ti)"

# Calculate hashes for the summit-mfg60n package
{
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		calc_file "mfg60n/laird/${version_60}/mfg60n-${i}-${version_60}.tar.bz2"
	done

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-mfg60n)"

# Calculate hashes for the summit-reg45n package
{
	for i in arm-eabi arm-eabihf
	do
		calc_file "reg45n/laird/${version_msd}/reg45n-${i}-${version_msd}.tar.bz2"
	done

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-reg45n)"

# Calculate hashes for the summit-reg50n package
{
	for i in arm-eabi arm-eabihf
	do
		calc_file "reg50n/laird/${version_msd}/reg50n-${i}-${version_msd}.tar.bz2"
	done

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-reg50n)"

# Calculate hashes for the summit-regcypress package
{
	for i in arm-eabi arm-eabihf aarch64
	do
		calc_file "regCypress/laird/${version_lwb}/regCypress-${i}-${version_lwb}.tar.bz2"
	done

	echo "sha256  34c3cec7451f3a1f5d42f282358ed564bdbb3bc582073873428c3d31cc643782  FOSS_README.txt"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-regcypress)"

# Calculate hashes for the summit-reglwb5plus package
{
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		calc_file "regLWB5plus/laird/${version_lwb}/regLWB5plus-${i}-${version_lwb}.tar.bz2"
	done

	echo "sha256  34c3cec7451f3a1f5d42f282358ed564bdbb3bc582073873428c3d31cc643782  FOSS_README.txt"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-reglwb5plus)"

# Calculate hashes for the summit-reglwbplus package
{
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		calc_file "regLWBplus/laird/${version_lwb}/regLWBplus-${i}-${version_lwb}.tar.bz2"
	done

	echo "sha256  34c3cec7451f3a1f5d42f282358ed564bdbb3bc582073873428c3d31cc643782  FOSS_README.txt"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-reglwbplus)"

# Calculate hashes for the summit-regif573 package
{
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		calc_file "regIF573/laird/${version_lwb}/regIF573-${i}-${version_lwb}.tar.bz2"
	done

	echo "sha256  34c3cec7451f3a1f5d42f282358ed564bdbb3bc582073873428c3d31cc643782  FOSS_README.txt"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-regif573)"

# Calculate hashes for the summit-regif513 package
{
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		calc_file "regIF513/laird/${version_lwb}/regIF513-${i}-${version_lwb}.tar.bz2"
	done

	echo "sha256  34c3cec7451f3a1f5d42f282358ed564bdbb3bc582073873428c3d31cc643782  FOSS_README.txt"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-regif513)"
