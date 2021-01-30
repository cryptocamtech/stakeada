#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

cardano-cli stake-pool id --cold-verification-key-file offline-files/node.vkey --output-format hex > hot-env/stakepoolid.txt

cp hot-env/stakepoolid.txt $ADA_USB_MNT/hot-env
echo "--- stakepoolid.txt"
cat hot-env/stakepoolid.txt
