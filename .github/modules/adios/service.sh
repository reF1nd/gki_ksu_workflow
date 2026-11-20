#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/common.sh"

snapshot_original
[ -f "$ADIOS_SAFE" ] || apply_pref
update_desc

until [ "$(getprop sys.boot_completed)" = 1 ]; do
	sleep 2
done
sleep 30

rm -f "$ADIOS_BOOTING"
update_desc
