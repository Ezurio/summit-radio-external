#!/bin/sh

set -e

err_report() {
    [ $? -eq 0 ] || echo "Error calculating hashes" > /dev/stderr
}

trap 'err_report $LINENO "$BASH_COMMAND"' EXIT

get_version() {
	sed -En "s,.*$1.*=\s*([0-9.]+),\1,p" versions.mk
}

calc_file () {
	/usr/bin/wget -T4 -t1 ${prefix}/${1}
	echo -n "sha256 " >> ${2}
	sha256sum ${1##*/} >> ${2}
	rm -f ${1##*/}
}

unique() {
	echo "$@" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

hash_file() {
	echo package/$1/$1.hash
}

prefix="https://files.devops.rfpros.com/builds/linux"

version_60=$(get_version "60")
version_bdsdmac=$(get_version "BDSDMAC")
version_lwb=$(get_version "LWB")
version_msd=$(get_version "MSD")
version_nx=$(get_version "NX")
version_ti=$(get_version "TI")

version_all=$(unique ${version_60} ${version_bdsdmac} ${version_lwb} ${version_msd} ${version_nx} ${version_ti})

# Calculate hashes for the summit-adaptive_ww package
rm -f $(hash_file summit-adaptive_ww)
for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
do
	calc_file "adaptive_ww/laird/${version_60}/adaptive_ww-${i}-${version_60}.tar.bz2" $(hash_file summit-adaptive_ww)
done

# Calculate hashes for the summit-adaptive_bt package
rm -f $(hash_file summit-adaptive_bt)
calc_file "adaptive_bt/src/${version_60}/adaptive_bt-src-${version_60}.tar.gz" $(hash_file summit-adaptive_bt)

# Calculate hashes for the summit-supplicant-libs package
rm -f $(hash_file summit-supplicant-libs)
for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
do
	calc_file "summit_supplicant/laird/${version_60}/summit_supplicant_libs-${i}-${version_60}.tar.bz2" $(hash_file summit-supplicant-libs)
done

if [ "${version_msd}" != "${version_60}" ]; then
	for i in arm-eabi arm-eabihf
	do
		calc_file "summit_supplicant/laird/${version_msd}/summit_supplicant_libs-${i}-${version_msd}.tar.bz2" $(hash_file summit-supplicant-libs)
	done
fi

for i in arm-eabi arm-eabihf
do
	calc_file "summit_supplicant/laird/${version_msd}/summit_supplicant_libs_legacy-${i}-${version_msd}.tar.bz2" $(hash_file summit-supplicant-libs)
done

# Calculate hashes for the summit-supplicant package
rm -f $(hash_file summit-supplicant)
for v in ${version_all}
do
	calc_file "summit_supplicant/laird/${v}/summit_supplicant-src-${v}.tar.gz" $(hash_file summit-supplicant)
done

# Calculate hashes for the summit-hostapd package
cp -f $(hash_file summit-supplicant) $(hash_file summit-hostapd)

# Calculate hashes for the summit-linux-backports package
rm -f $(hash_file summit-linux-backports)
for v in ${version_all}
do
	calc_file "backports/laird/${v}/summit-backports-${v}.tar.bz2" $(hash_file summit-linux-backports)
done

# Calculate hashes for the summit-network-manager package
rm -f $(hash_file summit-network-manager)
for v in ${version_all}
do
	calc_file "lrd-network-manager/src/${v}/summit-network-manager-src-${v}.tar.xz" $(hash_file summit-network-manager)
done

# Calculate hashes for the summit-firmware-60 package
rm -f $(hash_file summit-firmware-60)
for i in pcie-uart pcie-usb sdio-uart sdio-sdio usb-usb usb-uart
do
	calc_file "firmware/${version_60}/summit-60-radio-firmware-${i}-${version_60}.tar.bz2" $(hash_file summit-firmware-60)
done
calc_file "firmware/${version_60}/summit-som8mp-radio-firmware-${version_60}.tar.bz2" $(hash_file summit-firmware-60)

# Calculate hashes for the summit-firmware-bdsdmac package
rm -f $(hash_file summit-firmware-bdsdmac)
calc_file "firmware/${version_bdsdmac}/summit-bdsdmac-firmware-${version_bdsdmac}.tar.bz2" $(hash_file summit-firmware-bdsdmac)

# Calculate hashes for the summit-firmware-lwb package
rm -f $(hash_file summit-firmware-lwb-if)
for i in etsi fcc jp
do
	calc_file "firmware/${version_lwb}/summit-lwb-${i}-firmware-${version_lwb}.tar.bz2" $(hash_file summit-firmware-lwb-if)
done

for i in etsi fcc ic jp
do
  	calc_file "firmware/${version_lwb}/summit-lwb5-${i}-firmware-${version_lwb}.tar.bz2" $(hash_file summit-firmware-lwb-if)
done

for i in sdio-div sdio-sa sdio-sa-m2 usb-div usb-sa usb-sa-m2
do
  	calc_file "firmware/${version_lwb}/summit-lwb5plus-${i}-firmware-${version_lwb}.tar.bz2" $(hash_file summit-firmware-lwb-if)
done

calc_file "firmware/${version_lwb}/summit-lwbplus-firmware-${version_lwb}.tar.bz2" $(hash_file summit-firmware-lwb-if)

for i in sdio pcie
do
  	calc_file "firmware/${version_lwb}/summit-if573-${i}-firmware-${version_lwb}.tar.bz2" $(hash_file summit-firmware-lwb-if)
done

calc_file "firmware/${version_lwb}/summit-if513-sdio-firmware-${version_lwb}.tar.bz2" $(hash_file summit-firmware-lwb-if)

# Calculate hashes for the summit-firmware-msd package
rm -f $(hash_file summit-firmware-msd)
for i in 6003 6004
do
	calc_file "firmware/${version_msd}/summit-ath6k-${i}-firmware-${version_msd}.tar.bz2" $(hash_file summit-firmware-msd)
done

# Calculate hashes for the summit-firmware-nx package
rm -f $(hash_file summit-firmware-nx)
calc_file "firmware/${version_nx}/sona-nx61x-firmware-${version_nx}.tar.bz2" $(hash_file summit-firmware-nx)

# Calculate hashes for the summit-firmware-ti package
rm -f $(hash_file summit-firmware-ti)
for i in WW US JP EU CA AU
do
	calc_file "firmware/${version_ti}/summit-ti351-${i}-firmware-${version_ti}.tar.bz2" $(hash_file summit-firmware-ti)
done

# Calculate hashes for the summit-mfg60n package
rm -f $(hash_file summit-mfg60n)
for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
do
	calc_file "mfg60n/laird/${version_60}/mfg60n-${i}-${version_60}.tar.bz2" $(hash_file summit-mfg60n)
done

# Calculate hashes for the summit-reg45n package
rm -f $(hash_file summit-reg45n)
for i in arm-eabi arm-eabihf
do
	calc_file "reg45n/laird/${version_msd}/reg45n-${i}-${version_msd}.tar.bz2" $(hash_file summit-reg45n)
done

# Calculate hashes for the summit-reg50n package
rm -f $(hash_file summit-reg50n)
for i in arm-eabi arm-eabihf
do
	calc_file "reg50n/laird/${version_msd}/reg50n-${i}-${version_msd}.tar.bz2" $(hash_file summit-reg50n)
done

# Calculate hashes for the summit-regcypress package
rm -f $(hash_file summit-regcypress)
for i in arm-eabi arm-eabihf aarch64
do
	calc_file "regCypress/laird/${version_lwb}/regCypress-${i}-${version_lwb}.tar.bz2" $(hash_file summit-regcypress)
done

# Calculate hashes for the summit-reglwb5plus package
rm -f $(hash_file summit-reglwb5plus)
for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
do
	calc_file "regLWB5plus/laird/${version_lwb}/regLWB5plus-${i}-${version_lwb}.tar.bz2" $(hash_file summit-reglwb5plus)
done

# Calculate hashes for the summit-reglwbplus package
rm -f $(hash_file summit-reglwbplus)
for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
do
	calc_file "regLWBplus/laird/${version_lwb}/regLWBplus-${i}-${version_lwb}.tar.bz2" $(hash_file summit-reglwbplus)
done

# Calculate hashes for the summit-regif573 package
rm -f $(hash_file summit-regif573)
for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
do
	calc_file "regIF573/laird/${version_lwb}/regIF573-${i}-${version_lwb}.tar.bz2" $(hash_file summit-regif573)
done

# Calculate hashes for the summit-regif513 package
rm -f $(hash_file summit-regif513)
for i in x86 x86_64 arm-eabi arm-eabihf aarch64 powerpc64-e5500
do
	calc_file "regIF513/laird/${version_lwb}/regIF513-${i}-${version_lwb}.tar.bz2" $(hash_file summit-regif513)
done
