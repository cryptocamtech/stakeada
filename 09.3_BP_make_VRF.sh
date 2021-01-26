#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

cardano-cli node key-gen-VRF \
    --verification-key-file offline-files/vrf.vkey \
    --signing-key-file hot-env/vrf.skey
chmod 400 hot-env/vrf.skey

cp offline-files/vrf.vkey $ADA_USB_MNT/offline-files

echo "hot.skey"
echo "=================================================="
cat hot-env/kes.skey

echo "op.cert"
echo "=================================================="
cat $ADA_USB_MNT/hot-env/node.cert

echo "vrf.skey (needs a chmod 400)"
echo "=================================================="
cat ./hot-env/vrf.skey

echo "vrf.vkey"
echo "=================================================="
cat ./offline-files/vrf.vkey
