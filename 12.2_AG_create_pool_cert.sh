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
	echo "can't find vrf.vkey"
	exit 1
fi

if [ -z "$4" ]; then
	echo "Usage: $0 <pledge> <relay host> <relay ip> <short url>"
	exit 1
fi

# back-up this file on the AG (created back in 9.3)
cp $ADA_USB_MNT/offline-files/vrf.vkey offline-files/vrf.vkey

cardano-cli stake-pool registration-certificate \
    --cold-verification-key-file offline-files/node.vkey \
    --vrf-verification-key-file offline-files/vrf.vkey \
    --pool-pledge $1 \
    --pool-cost 340000000 \
    --pool-margin 0.02 \
    --pool-reward-account-verification-key-file pool-files/stake.vkey \
    --pool-owner-stake-verification-key-file pool-files/stake.vkey \
    --mainnet \
    --single-host-pool-relay $2 \
    --pool-relay-port $3 \
    --metadata-url $4 \
    --metadata-hash $(cat $ADA_USB_MNT/offline-files/poolMetaDataHash.txt) \
    --out-file $ADA_USB_MNT/hot-env/pool.cert

echo "--- pool.cert"
cat $ADA_USB_MNT/hot-env/pool.cert

cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file pool-files/stake.vkey \
    --cold-verification-key-file offline-files/node.vkey \
    --out-file $ADA_USB_MNT/hot-env/deleg.cert

echo "--- deleg.cert"
cat $ADA_USB_MNT/hot-env/deleg.cert

