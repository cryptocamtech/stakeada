#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/offline-files/key.vkey" ]; then
	echo "can't find kes.vkey"
	exit 1
fi

if [ -z "$1" ]; then
	echo "usage: $0 <start KES period>"
	exit 1
fi

mkdir -p offline-files
mkdir -p hot-env

cardano-cli node key-gen \
    --cold-verification-key-file offline-files/node.vkey \
    --cold-signing-key-file offline-files/node.skey \
    --operational-certificate-issue-counter offline-files/node.counter

# backup only
cp offline-files/node.* $ADA_USB_MNT/offline-files

cp $ADA_USB_MNT/offline-files/kes.vkey offline-files

cardano-cli node issue-op-cert \
    --kes-verification-key-file offline-files/kes.vkey \
    --cold-signing-key-file offline-files/node.skey \
    --operational-certificate-issue-counter offline-files/node.counter \
    --kes-period $1 \
    --out-file hot-env/node.cert

cp hot-env/node.cert $ADA_USB_MNT/hot-env

# backups
cp offline-files/node.skey $ADA_USB_MNT/offline-files
cp offline-files/node.vkey $ADA_USB_MNT/offline-files
cp offline-files/node.counter $ADA_USB_MNT/offline-files
