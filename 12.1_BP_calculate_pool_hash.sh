#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

if [ -z "$1" ]; then
	echo "usage: $0 <public pool metadata URL>"
	exit 1
fi

wget -c $1
cardano-cli stake-pool metadata-hash --pool-metadata-file poolMetaData.json > $ADA_USB_MNT/offline-files/poolMetaDataHash.txt

minPoolCost=$(cat pool-files/params.json | jq -r .minPoolCost)
echo minPoolCost: ${minPoolCost}

echo "--- poolMetaDataHash.txt"
cat $ADA_USB_MNT/offline-files/poolMetaDataHash.txt
rm poolMetaData.json

