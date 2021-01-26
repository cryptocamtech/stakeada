#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/offline-files/poolMetaDataHash.txt" ]; then
	echo "can't find pool hash!"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/offline-files/vrf.vkey" ]; then
	echo "can't find pool hash!"
	exit 1
fi

cardano-cli stake-pool registration-certificate \
    --cold-verification-key-file offline-files/node.vkey \
    --vrf-verification-key-file $ADA_USB_MNT/offline-files/vrf.vkey \
    --pool-pledge 20000000000 \
    --pool-cost 340000000 \
    --pool-margin 0.02 \
    --pool-reward-account-verification-key-file pool-keys/stake.vkey \
    --pool-owner-stake-verification-key-file pool-keys/stake.vkey \
    --mainnet \
    --single-host-pool-relay hodlwith.cam \
    --pool-relay-port 6000 \
    --metadata-url https://git.io/Jtk3h \
    --metadata-hash $(cat $ADA_USB_MNT/offline-files/poolMetaDataHash.txt) \
    --out-file $ADA_USB_MNT/hot-env/pool.cert

echo "pool.cert"
cat $ADA_USB_MNT/hot-env/pool.cert

cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file pool-keys/stake.vkey \
    --cold-verification-key-file offline-files/node.vkey \
    --out-file $ADA_USB_MNT/hot-env/deleg.cert

echo "deleg.cert"
cat $ADA_USB_MNT/hot-env/deleg.cert

# clean up
rm $ADA_USB_MNT/offline-files/poolMetaDataHash.txt

