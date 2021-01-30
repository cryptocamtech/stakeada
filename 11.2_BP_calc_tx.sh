#!/bin/bash

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/hot-env/stake.cert" ]; then
	echo "no stake.cert!"
	exit 1
fi

if [ ! -f "$ADA_USB_MNT/hot-env/payment.addr" ]; then
	echo "no payment.addr!"
	exit 1
fi

# described in section 10
cardano-cli query protocol-parameters \
    --mainnet \
    --allegra-era \
    --out-file pool-files/params.json

cp $ADA_USB_MNT/hot-env/stake.cert hot-env/
cp $ADA_USB_MNT/hot-env/payment.addr hot-env/
mkdir -p pool-files

currentSlot=$(cardano-cli query tip --mainnet | jq -r '.slotNo')
echo Current Slot: $currentSlot

cardano-cli query utxo \
    --address $(cat hot-env/payment.addr) \
    --allegra-era \
    --mainnet > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out
cat balance.out

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
done < balance.out
txcnt=$(cat balance.out | wc -l)
rm balance.out
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}

# for testing
if [ -z "$tx_in" ]; then
	echo "NOTE: 0 balance - using test account"
	tx_in="--tx-in aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa#0"
	total_balance="5000000000"
fi

keyDeposit=$(cat pool-files/params.json | jq -r '.keyDeposit')
echo keyDeposit: $keyDeposit

cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat hot-env/payment.addr)+0 \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --out-file tx.tmp \
    --allegra-era \
    --certificate hot-env/stake.cert

fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file pool-files/params.json | awk '{ print $1 }')
echo fee: $fee

txOut=$((${total_balance}-${keyDeposit}-${fee}))
echo new balance: ${txOut}

cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat hot-env/payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file hot-env/stake.cert \
    --allegra-era \
    --out-file $ADA_USB_MNT/offline-files/tx.raw

echo "--- tx.raw"
cat $ADA_USB_MNT/offline-files/tx.raw

rm fullUtxo.out
rm tx.tmp

