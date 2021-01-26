#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

if [ -z "$NODE_HOME" ]; then
	echo "NODE_HOME NOT set"
	exit 1
fi

if [ -z "$NODE_GENESIS" ]; then
	echo "NODE_GENESIS NOT set"
	exit 1
fi

mkdir -p hot-env
mkdir -p offline-files

cardano-cli node key-gen-KES \
    --verification-key-file offline-files/kes.vkey \
    --signing-key-file hot-env/kes.skey

mkdir -p $ADA_USB_MNT/hot-env
mkdir -p $ADA_USB_MNT/offline-files

cp offline-files/kes.vkey $ADA_USB_MNT/offline-files

# backup only
cp hot-env/kes.skey $ADA_USB_MNT/hot-env

# calculate start kes period
slotsPerKESPeriod=$(cat $NODE_HOME/$NODE_GENESIS | jq -r '.slotsPerKESPeriod')
echo slotsPerKESPeriod: ${slotsPerKESPeriod}
slotNo=$(cardano-cli query tip --mainnet | jq -r '.slotNo')
echo slotNo: ${slotNo}
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
echo start KES period: ${kesPeriod}

