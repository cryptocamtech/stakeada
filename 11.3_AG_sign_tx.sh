#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/offline-files/tx.raw" ]; then
	echo "can't find tx.raw"
	exit 1
fi

cardano-cli transaction sign \
    --tx-body-file $ADA_USB_MNT/offline-files/tx.raw \
    --signing-key-file pool-files/payment.skey \
    --signing-key-file offline-files/node.skey \
    --signing-key-file pool-files/stake.skey \
    --mainnet \
    --out-file $ADA_USB_MNT/offline-files/tx.signed

# cleanup
rm "$ADA_USB_MNT/offline-files/tx.raw"

