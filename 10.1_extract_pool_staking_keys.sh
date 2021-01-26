#!/bin/bash 

if [ -z "$ADA_USB_MNT" ]; then
	echo "ADA_USB_MNT NOT set"
	exit 1
fi

if [ -z "$1" ]; then
	echo "usage: $0 <list of mnemonics>"
	exit 1
fi

CADDR=${CADDR:=$( which cardano-address )}
[[ -z "$CADDR" ]] && ( echo "cardano-address cannot be found, exiting..." >&2 ; exit 127 )

CCLI=${CCLI:=$( which cardano-cli )}
[[ -z "$CCLI" ]] && ( echo "cardano-cli cannot be found, exiting..." >&2 ; exit 127 )

rm -fr pool-keys
OUT_DIR="pool-keys"
mkdir -p "$OUT_DIR" && pushd "$OUT_DIR" > /dev/null
MNEMONIC="$*"

# Generate the master key from mnemonics and derive the stake account keys 
# as extended private and public keys (xpub, xprv)
echo "$MNEMONIC" |"$CADDR" key from-recovery-phrase Shelley > root.prv

cat root.prv |"$CADDR" key child 1852H/1815H/0H/2/0 > stake.xprv

cat root.prv |"$CADDR" key child 1852H/1815H/0H/0/0 > payment.xprv

TESTNET=0
MAINNET=1
NETWORK=$MAINNET

cat payment.xprv |"$CADDR" key public --with-chain-code| tee payment.xpub |"$CADDR" address payment --network-tag $NETWORK |"$CADDR" address delegation $(cat stake.xprv | "$CADDR" key public --with-chain-code| tee stake.xpub) |tee base.addr_candidate |"$CADDR" address inspect
echo "Generated from 1852H/1815H/0H/{0,2}/0"
cat base.addr_candidate
echo

# XPrv/XPub conversion to normal private and public key, keep in mind the 
# keypars are not a valind Ed25519 signing keypairs.
TESTNET_MAGIC="--testnet-magic 42"
MAINNET_MAGIC="--mainnet"
MAGIC="$MAINNET_MAGIC"

SESKEY=$( cat stake.xprv | bech32 | cut -b -128 )$( cat stake.xpub | bech32)
PESKEY=$( cat payment.xprv | bech32 | cut -b -128 )$( cat payment.xpub | bech32)

cat << EOF > stake.skey
{
    "type": "StakeExtendedSigningKeyShelley_ed25519_bip32",
    "description": "",
    "cborHex": "5880$SESKEY"
}
EOF

cat << EOF > payment.skey
{
    "type": "PaymentExtendedSigningKeyShelley_ed25519_bip32",
    "description": "Payment Signing Key",
    "cborHex": "5880$PESKEY"
}
EOF

"$CCLI" key verification-key --signing-key-file stake.skey --verification-key-file stake.evkey
"$CCLI" key verification-key --signing-key-file payment.skey --verification-key-file payment.evkey

"$CCLI" key non-extended-key --extended-verification-key-file payment.evkey --verification-key-file payment.vkey
"$CCLI" key non-extended-key --extended-verification-key-file stake.evkey --verification-key-file stake.vkey


"$CCLI" stake-address build --stake-verification-key-file stake.vkey $MAGIC > stake.addr
"$CCLI" address build --payment-verification-key-file payment.vkey $MAGIC > payment.addr
"$CCLI" address build     --payment-verification-key-file payment.vkey     --stake-verification-key-file stake.vkey     $MAGIC > base.addr

diff -w base.addr base.addr_candidate
cp base.addr $ADA_USB_MNT/hot-env/payment.addr

#cp stake.vkey stake.skey stake.addr payment.vkey payment.skey payment.addr $ADA_USB_MNT/pool-keys

# remove mnemonic phrase


popd >/dev/null

