#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

cardano-cli stake-address registration-certificate \
    --stake-verification-key-file pool-files/stake.vkey \
    --out-file hot-env/stake.cert

cp hot-env/stake.cert $ADA_USB_MNT/hot-env

