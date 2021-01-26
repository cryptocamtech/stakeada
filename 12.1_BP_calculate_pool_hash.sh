#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

wget https://raw.githubusercontent.com/cryptocamtech/stakeada/main/poolMetaData.json
cardano-cli stake-pool metadata-hash --pool-metadata-file poolMetaData.json > $ADA_USB_MNT/offline-files/poolMetaDataHash.txt

minPoolCost=$(cat pool-files/params.json | jq -r .minPoolCost)
echo minPoolCost: ${minPoolCost}

echo poolMetaDataHash.txt
cat $ADA_USB_MNT/offline-files/poolMetaDataHash.txt
rm poolMetaData.json

