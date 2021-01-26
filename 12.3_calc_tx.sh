#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/hot-env/stake.cert" ]; then
	echo "no stake.cert!"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/hot-env/deleg.cert" ]; then
	echo "no deleg.cert!"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/hot-env/payment.addr" ]; then
	echo "no payment.addr!"
	exit 1
fi

cp $ADA_USB_MNT/hot-env/payment.addr hot-env/
mkdir -p pool-keys

cardano-cli query protocol-parameters \
    --mainnet \
    --allegra-era \
    --out-file pool-keys/params.json

currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slotNo')
echo Current Slot: $currentSlot

cardano-cli query utxo \
    --address $(cat hot-env/payment.addr) \
    --allegra-era \
    --mainnet > pool-keys/fullUtxo.out

tail -n +3 pool-keys/fullUtxo.out | sort -k3 -nr > pool-keys/balance.out
cat pool-keys/balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < pool-keys/balance.out

txcnt=$(cat pool-keys/balance.out | wc -l)
rm pool-keys/balance.out
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}

poolDeposit=$(cat pool-keys/params.json | jq -r '.poolDeposit')
echo poolDeposit: $poolDeposit

cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat hot-env/payment.addr)+0 \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --out-file pool-keys/tx.tmp \
    --allegra-era \
    --certificate $ADA_USB_MNT/hot-env/stake.cert

fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file pool-keys/tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file pool-keys/params.json | awk '{ print $1 }')
echo fee: $fee

# for changing after initial submission
txOut=$((${total_balance}-${fee}))

# initial transaction
#txOut=$((${total_balance}-${poolDeposit}-${fee}))
echo txOut: ${txOut}

cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat hot-env/payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file $ADA_USB_MNT/hot-env/pool.cert \
    --certificate-file $ADA_USB_MNT/hot-env/deleg.cert \
    --allegra-era \
    --out-file $ADA_USB_MNT/offline-files/tx.raw

echo "tx.raw"
echo "==================================="
cat $ADA_USB_MNT/offline-files/tx.raw

rm pool-keys/fullUtxo.out
rm pool-keys/tx.tmp
rm $ADA_USB_MNT/hot-env/pool.cert
rm $ADA_USB_MNT/hot-env/stake.cert
rm $ADA_USB_MNT/hot-env/deleg.cert

