#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

source $NODE_HOME/scripts/env

if [ -z "POOL_NAME" ]; then
	echo "POOL_NAME NOT set"
	exit 1
fi

cardano-cli node key-gen-VRF \
    --verification-key-file $ADA_USB_MNT/offline-files/vrf.vkey \
    --signing-key-file hot-env/vrf.skey

mkdir -p pool-dir
echo "--- copy these files from pool-dir to $POOL_DIR"

echo "pool-dir/hot.skey"
cp hot-env/kes.skey pool-dir/hot.skey

echo "pool-dir/op.cert"
cp $ADA_USB_MNT/hot-env/node.cert pool-dir/op.cert

echo "pool-dir/vrf.skey (needs a chmod 400)"
rm -f pool-dir/vrf.skey
cp ./hot-env/vrf.skey pool-dir/vrf.skey
chmod 400 pool-dir/vrf.skey

# needed for ptsendtip
echo "pool-dir/vrf.vkey"
cp $ADA_USB_MNT/offline-files/vrf.vkey pool-dir
