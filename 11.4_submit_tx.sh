#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/offline-files/tx.signed" ]; then
	echo "no signed tx!"
	exit 1
fi

cardano-cli transaction submit \
    --tx-file $ADA_USB_MNT/offline-files/tx.signed \
    --mainnet

rm $ADA_USB_MNT/offline-files/tx.signed

