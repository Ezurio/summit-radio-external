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

calc_license_hash() {
	local tarfile="${1}" licensefile="${2}" strip="${3:-1}"
	${cmd} "set -e; cd ${prefix};
		case ${tarfile} in
			*.tar.gz|*.tgz) comp=-z ;;
			*.tar.bz2)      comp=-j ;;
			*.tar.xz)       comp=-J ;;
			*.tar.zst)      comp=--zstd ;;
			*)              comp=  ;;
		esac;
		if [ ${strip} -eq 0 ]; then
			if ! tar \${comp} -xOf ${tarfile} ${licensefile} 2>/dev/null; then
				shfile=\$(basename ${tarfile} .tar.bz2).sh;
				tar \${comp} -xOf ${tarfile} \"\${shfile}\" | sed '1,/^exit 0\$/d' | tar -xjOf - ${licensefile};
			fi;
		else
			tar \${comp} --strip-components=${strip} --occurrence=1 --wildcards -xOf ${tarfile} '*/${licensefile}';
		fi | sha256sum" | \
		awk -v lf="${licensefile}" '{print "sha256  " $1 "  " lf}'
}

get_license_files() {
	local pkg="${1}"
	local varname
	varname=$(echo "${pkg}" | tr 'a-z-' 'A-Z_')
	make --no-print-directory \
		-f "package/${pkg}/${pkg}.mk" \
		-f <(printf 'print-license-files:\n\t@echo $(%s_LICENSE_FILES)\n' "${varname}") \
		print-license-files 2>/dev/null
}

get_strip_components() {
	local pkg="${1}"
	local varname
	varname=$(echo "${pkg}" | tr 'a-z-' 'A-Z_')
	make --no-print-directory \
		-f "package/${pkg}/${pkg}.mk" \
		-f <(printf 'print-strip:\n\t@echo $(%s_STRIP_COMPONENTS)\n' "${varname}") \
		print-strip 2>/dev/null
}

calc_license_hashes() {
	local tarfile="${1}"
	local pkg="${2}"
	local strip
	echo "Calculating license hashes for ${pkg}..." >&2
	strip=$(get_strip_components "${pkg}")
	for lf in $(get_license_files "${pkg}"); do
		calc_license_hash "${tarfile}" "${lf}" "${strip}"
	done
}

version=${1}
sed -i -r "s/(.+=).*/\1 ${1}/g" versions.mk

# Calculate hashes for the summit-adaptive_ww package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} adaptive_ww/laird/${version}/adaptive_ww-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "adaptive_ww/laird/${version}/adaptive_ww-x86-${version}.tar.bz2" "summit-adaptive_ww"
} > "$(hash_file summit-adaptive_ww)"

# Calculate hashes for the summit-adaptive_bt package
{
	files="adaptive_bt/src/${version}/adaptive_bt-src-${version}.tar.gz"
	calc_hash "${files}"

	calc_license_hashes "adaptive_bt/src/${version}/adaptive_bt-src-${version}.tar.gz" "summit-adaptive_bt"
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

	calc_license_hashes "summit_supplicant/laird/${version}/summit_supplicant_libs-x86-${version}.tar.bz2" "summit-supplicant-libs"
} > "$(hash_file summit-supplicant-libs)"

# Calculate hashes for the summit-supplicant package
{
	files="summit_supplicant/laird/${version}/summit_supplicant-src-${version}.tar.gz"
	calc_hash "${files}"

	calc_license_hashes "summit_supplicant/laird/${version}/summit_supplicant-src-${version}.tar.gz" "summit-supplicant"
} > "$(hash_file summit-supplicant)"

# Calculate hashes for the summit-hostapd package
cp -f "$(hash_file summit-supplicant)" "$(hash_file summit-hostapd)"

# Calculate hashes for the summit-linux-backports package
{
	files="backports/laird/${version}/summit-backports-${version}.tar.bz2"
	calc_hash "${files}"

	calc_license_hashes "backports/laird/${version}/summit-backports-${version}.tar.bz2" "summit-linux-backports"
} > "$(hash_file summit-linux-backports)"

# Calculate hashes for the summit-network-manager package
{
	files="lrd-network-manager/src/${version}/summit-network-manager-src-${version}.tar.xz"
	calc_hash "${files}"

	calc_license_hashes "lrd-network-manager/src/${version}/summit-network-manager-src-${version}.tar.xz" "summit-network-manager"
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

	calc_license_hashes "firmware/${version}/summit-60-radio-firmware-pcie-uart-${version}.tar.bz2" "summit-firmware-60"
} > "$(hash_file summit-firmware-60)"

# Calculate hashes for the summit-firmware-bdsdmac package
{
	files="firmware/${version}/summit-bdsdmac-firmware-${version}.tar.bz2"
	calc_hash "${files}"

	calc_license_hashes "firmware/${version}/summit-bdsdmac-firmware-${version}.tar.bz2" "summit-firmware-bdsdmac"
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

	calc_license_hashes "firmware/${version}/summit-lwb-firmware-${version}.tar.bz2" "summit-firmware-lwb-if"
} > "$(hash_file summit-firmware-lwb-if)"

# Calculate hashes for the summit-firmware-msd package
{
	files=
	for i in 6003 6004
	do
		files="${files} firmware/${version}/summit-ath6k-${i}-firmware-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "firmware/${version}/summit-ath6k-6003-firmware-${version}.tar.bz2" "summit-firmware-msd"
} > "$(hash_file summit-firmware-msd)"


# Calculate hashes for the summit-firmware-nx packages
{
	files=
	files="${files} firmware/${version}/summit-nx61x-firmware-${version}.tar.bz2"
	files="${files} firmware/${version}/summit-nx61x-1218-firmware-${version}.tar.bz2"
	calc_hash "${files}"

	calc_license_hashes "firmware/${version}/summit-nx61x-firmware-${version}.tar.bz2" "summit-firmware-nx"
} > "$(hash_file summit-firmware-nx)"

# Calculate hashes for the summit-firmware-ti package
{
	files=
	for i in WW US JP EU CA AU
	do
		files="${files} firmware/${version}/summit-ti351-${i}-firmware-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "firmware/${version}/summit-ti351-WW-firmware-${version}.tar.bz2" "summit-firmware-ti"
} > "$(hash_file summit-firmware-ti)"

# Calculate hashes for the summit-mfg60n package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} mfg60n/laird/${version}/mfg60n-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "mfg60n/laird/${version}/mfg60n-x86-${version}.tar.bz2" "summit-mfg60n"
} > "$(hash_file summit-mfg60n)"

# Calculate hashes for the summit-mfg611 package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} mfg611/laird/${version}/mfg611-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "mfg611/laird/${version}/mfg611-x86-${version}.tar.bz2" "summit-mfg611"
} > "$(hash_file summit-mfg611)"

# Calculate hashes for the summit-reg45n package
{
	files=
	for i in arm-eabi arm-eabihf
	do
		files="${files} reg45n/laird/${version}/reg45n-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "reg45n/laird/${version}/reg45n-arm-eabi-${version}.tar.bz2" "summit-reg45n"
} > "$(hash_file summit-reg45n)"

# Calculate hashes for the summit-reg50n package
{
	files=
	for i in arm-eabi arm-eabihf
	do
		files="${files} reg50n/laird/${version}/reg50n-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "reg50n/laird/${version}/reg50n-arm-eabi-${version}.tar.bz2" "summit-reg50n"
} > "$(hash_file summit-reg50n)"

# Calculate hashes for the summit-regcypress package
{
	files=
	for i in arm-eabi arm-eabihf aarch64
	do
		files="${files} regCypress/laird/${version}/regCypress-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "regCypress/laird/${version}/regCypress-arm-eabi-${version}.tar.bz2" "summit-regcypress"
} > "$(hash_file summit-regcypress)"

# Calculate hashes for the summit-reglwb5plus package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} regLWB5plus/laird/${version}/regLWB5plus-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "regLWB5plus/laird/${version}/regLWB5plus-x86-${version}.tar.bz2" "summit-reglwb5plus"
} > "$(hash_file summit-reglwb5plus)"

# Calculate hashes for the summit-reglwbplus package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} regLWBplus/laird/${version}/regLWBplus-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "regLWBplus/laird/${version}/regLWBplus-x86-${version}.tar.bz2" "summit-reglwbplus"
} > "$(hash_file summit-reglwbplus)"

# Calculate hashes for the summit-regif573 package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} regIF573/laird/${version}/regIF573-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "regIF573/laird/${version}/regIF573-x86-${version}.tar.bz2" "summit-regif573"
} > "$(hash_file summit-regif573)"

# Calculate hashes for the summit-regif513 package
{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} regIF513/laird/${version}/regIF513-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "regIF513/laird/${version}/regIF513-x86-${version}.tar.bz2" "summit-regif513"
} > "$(hash_file summit-regif513)"

{
	files=
	for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
	do
		files="${files} regTI351/laird/${version}/regTI351-${i}-${version}.tar.bz2"
	done
	calc_hash "${files}"

	calc_license_hashes "regTI351/laird/${version}/regTI351-x86-${version}.tar.bz2" "summit-regti351"
} > "$(hash_file summit-regti351)"
