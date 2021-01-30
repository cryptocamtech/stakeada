#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/hot-env/stakepoolid.txt" ]; then
	echo "no stakepool id!"
	exit 1
fi

cardano-cli query ledger-state --mainnet --allegra-era | grep publicKey | grep $(cat $ADA_USB_MNT/hot-env/stakepoolid.txt)


