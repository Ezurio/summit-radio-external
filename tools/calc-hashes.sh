#! /bin/bash

set -e -o pipefail

err_report() {
    [ $? -eq 0 ] || echo "Error calculating hashes" > /dev/stderr
}

get_version() {
	sed -rn "s,.*${1}.*=\s*([0-9.]+),\1,p" versions.mk
}

prefix="/var/www/html/builds/linux"
cmd="ssh -o ControlMaster=auto -o ControlPersist=5s -o ControlPath=/tmp/ssh-fileshare fileshare@files.devops.rfpros.com"

calc_hash() {
  ${cmd} "set -e; cd ${prefix} && sha256sum ${1}" | \
    sed -r "s/([0-9a-f]+)  .*\/(.*-[0-9.]+\.tar.*)/sha256  \1  \2/"
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

version_60=$(get_version "60")
version_bdsdmac=$(get_version "BDSDMAC")
version_lwb=$(get_version "LWB")
version_msd=$(get_version "MSD")
version_nx=$(get_version "NX")
version_ti=$(get_version "TI")

version_all=$(unique "${version_60}" "${version_bdsdmac}" "${version_lwb}" "${version_msd}" "${version_nx}" "${version_ti}")

# Calculate hashes for the summit-adaptive_ww package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} adaptive_ww/laird/${version_60}/adaptive_ww-${i}-${version_60}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-adaptive_ww)"

# Calculate hashes for the summit-adaptive_bt package
{
	files=
	files="${files} adaptive_bt/src/${version_60}/adaptive_bt-src-${version_60}.tar.gz"
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-adaptive_bt)"

# Calculate hashes for the summit-supplicant-libs package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} summit_supplicant/laird/${version_60}/summit_supplicant_libs-${i}-${version_60}.tar.bz2"
	done

	if [ "${version_msd}" != "${version_60}" ]; then
		for i in arm-eabi arm-eabihf
		do
			files="${files} summit_supplicant/laird/${version_msd}/summit_supplicant_libs-${i}-${version_msd}.tar.bz2"
		done
	fi

	for i in arm-eabi arm-eabihf
	do
		files="${files} summit_supplicant/laird/${version_msd}/summit_supplicant_libs_legacy-${i}-${version_msd}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-supplicant-libs)"

# Calculate hashes for the summit-supplicant package
{
	files=
	for v in ${version_all}
	do
		files="${files}summit_supplicant/laird/${v}/summit_supplicant-src-${v}.tar.gz"
	done
	calc_hash "${files}"

	echo "sha256  f1b5992bbdd015c3ccb7faaadd62ef58ed821e15b9329bf2ceb27511ccc3f562  README"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-supplicant)"

# Calculate hashes for the summit-hostapd package
cp -f "$(hash_file summit-supplicant)" "$(hash_file summit-hostapd)"

# Calculate hashes for the summit-linux-backports package
{
	files=
	for v in ${version_all}
	do
		files="${files} backports/laird/${v}/summit-backports-${v}.tar.bz2"
	done
	calc_hash "${files}"

	echo "sha256  fb5a425bd3b3cd6071a3a9aff9909a859e7c1158d54d32e07658398cd67eb6a0  COPYING"
	echo "sha256  8e378ab93586eb55135d3bc119cce787f7324f48394777d00c34fa3d0be3303f  LICENSES/exceptions/Linux-syscall-note"
	echo "sha256  f6b78c087c3ebdf0f3c13415070dd480a3f35d8fc76f3d02180a407c1c812f79  LICENSES/preferred/GPL-2.0"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-linux-backports)"

# Calculate hashes for the summit-network-manager package
{
	files=
	for v in ${version_all}
	do
		files="${files} lrd-network-manager/src/${v}/summit-network-manager-src-${v}.tar.xz"
	done
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
		files="${files} firmware/${version_60}/summit-60-radio-firmware-${i}-${version_60}.tar.bz2"
	done
	files="${files} firmware/${version_60}/summit-som8mp-radio-firmware-${version_60}.tar.bz2"
	calc_hash "${files}"

	echo "sha256  2accdbff2dfad766f2533a8976f15f550625253987b6ee75c06f80a8227822c2  LICENSE.nxp1"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-60)"

# Calculate hashes for the summit-firmware-bdsdmac package
{
	files=
	files="${files} firmware/${version_bdsdmac}/summit-bdsdmac-firmware-${version_bdsdmac}.tar.bz2"
	calc_hash "${files}"

	echo "sha256  4ea56b251222f9d121c22f92e5d860750ab1b29a1d743be83b0f3af311d4972c  LICENSE.qca_firmware"
} > "$(hash_file summit-firmware-bdsdmac)"

# Calculate hashes for the summit-firmware-lwb package
{
	files=
	files="${files} firmware/${version_lwb}/summit-lwb-firmware-${version_lwb}.tar.bz2"
	files="${files} firmware/${version_lwb}/summit-lwbplus-firmware-${version_lwb}.tar.bz2"

	for i in sdio-div sdio-sa sdio-sa-m2 usb-div usb-sa usb-sa-m2
	do
		files="${files} firmware/${version_lwb}/summit-lwb5plus-${i}-firmware-${version_lwb}.tar.bz2"
	done

	for i in sdio pcie
	do
		files="${files} firmware/${version_lwb}/summit-if573-${i}-firmware-${version_lwb}.tar.bz2"
	done

	for i in sdio-div sdio-sa
	do
		files="${files} firmware/${version_lwb}/summit-if513-${i}-firmware-${version_lwb}.tar.bz2"
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
		files="${files} firmware/${version_msd}/summit-ath6k-${i}-firmware-${version_msd}.tar.bz2"
	done
	calc_hash "${files}"

	echo "sha256  802b7014b26c606cf6248ae8b0ab1ce6d2d1b0db236d38dd269e676cd70710f2  LICENSE.atheros"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-msd)"


# Calculate hashes for the summit-firmware-nx packages
{
	files=
	files="${files} firmware/${version_nx}/summit-nx61x-firmware-${version_nx}.tar.bz2"
	files="${files} firmware/${version_nx}/summit-nx61x-1218-firmware-${version_nx}.tar.bz2"
	calc_hash "${files}"

	echo "sha256  3dd8aa2ede25fcc34b72754473dc3d3924a57b550bfcafe3a48d8bd951abf383  LICENSE.nxp2"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-nx)"

# Calculate hashes for the summit-firmware-ti package
{
	files=
	for i in WW US JP EU CA AU
	do
		files="${files} firmware/${version_ti}/summit-ti351-${i}-firmware-${version_ti}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-firmware-ti)"

# Calculate hashes for the summit-mfg60n package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} mfg60n/laird/${version_60}/mfg60n-${i}-${version_60}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-mfg60n)"

# Calculate hashes for the summit-mfg611 package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} mfg611/laird/${version_nx}/mfg611-${i}-${version_nx}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-mfg611)"

# Calculate hashes for the summit-reg45n package
{
	files=
	for i in arm-eabi arm-eabihf
	do
		files="${files} reg45n/laird/${version_msd}/reg45n-${i}-${version_msd}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-reg45n)"

# Calculate hashes for the summit-reg50n package
{
	files=
	for i in arm-eabi arm-eabihf
	do
		files="${files} reg50n/laird/${version_msd}/reg50n-${i}-${version_msd}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-reg50n)"

# Calculate hashes for the summit-regcypress package
{
	files=
	for i in arm-eabi arm-eabihf aarch64
	do
		files="${files} regCypress/laird/${version_lwb}/regCypress-${i}-${version_lwb}.tar.bz2"
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
		files="${files} regLWB5plus/laird/${version_lwb}/regLWB5plus-${i}-${version_lwb}.tar.bz2"
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
		files="${files} regLWBplus/laird/${version_lwb}/regLWBplus-${i}-${version_lwb}.tar.bz2"
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
		files="${files} regIF573/laird/${version_lwb}/regIF573-${i}-${version_lwb}.tar.bz2"
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
		files="${files} regIF513/laird/${version_lwb}/regIF513-${i}-${version_lwb}.tar.bz2"
	done
	calc_hash "${files}"

	echo "sha256  34c3cec7451f3a1f5d42f282358ed564bdbb3bc582073873428c3d31cc643782  FOSS_README.txt"
	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-regif513)"

{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} regTI351/laird/${version_ti}/regTI351-${i}-${version_ti}.tar.bz2"
	done
	calc_hash "${files}"

	echo "${LICENSE_SUMMIT}"
} > "$(hash_file summit-regti351)"
