#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/pool-keys/payment.addr" ]; then
	echo "no payment addr!"
	exit 1
fi

cardano-cli query utxo \
    --address $(cat $ADA_USB_MNT/pool-keys/payment.addr) \
    --allegra-era \
    --mainnet
