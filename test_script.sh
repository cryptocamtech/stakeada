#!/bin/bash

# will show up some failes transactions due to an empty/invalid wallet

if [ -z "$NODE_HOME" ]; then
	echo "NODE_HOME NOT set"
	exit 1
fi

if [ -z "$NODE_GENESIS" ]; then
	echo "NODE_GENESIS NOT set"
	exit 1
fi

export ADA_USB_MNT=`pwd`/test
rm -fr $ADA_USB_MNT
rm -fr hot-env
rm -fr offline-files
rm -fr pool-files
rm -fr pool-dir

echo "### 09.1_BP_make_KES.sh"
./09.1_BP_make_KES.sh
echo "### 09.2_AG_make_node.sh"
./09.2_AG_make_node.sh 200
echo "### 09.3_BP_make_VRF.sh"
./09.3_BP_make_VRF.sh

# note: invalid wallet!
echo "### 10.1_extract_pool_staking_keys.sh"
./10.1_extract_pool_staking_keys.sh behind parent body slush pond guilt purchase fossil safe urge buddy vacuum royal chief wood
echo "### 10.2_BP_check_payment.sh"
./10.2_BP_check_payment.sh

echo "### 11.1_create_stake_cert.sh"
./11.1_create_stake_cert.sh
echo "### 11.2_BP_register_pool.sh"
./11.2_BP_register_pool.sh
echo "### 11.3_sign_tx.sh"
./11.3_sign_tx.sh
echo "### 11.4_submit_tx.sh"
./11.4_submit_tx.sh

echo "### 12.1_BP_calculate_pool_hash.sh"
./12.1_BP_calculate_pool_hash.sh https://raw.githubusercontent.com/cryptocamtech/stakeada/main/poolMetaData.json
echo "### 12.2_AG_create_pool_cert.sh"
./12.2_AG_create_pool_cert.sh 100000000 hodlwith.cam 6000 https://git.io/Jtk3h 

echo "### 12.3_calc_tx.sh"
./12.3_calc_tx.sh
echo "### 12.4_AG_sign_tx.sh"
./12.4_AG_sign_tx.sh
echo "### 12.5_BP_submit_tx.sh"
./12.5_BP_submit_tx.sh
echo "### 13.1_stakepool_id.sh"

./13.1_stakepool_id.sh
echo "### 13.2_BP_check_stakings.sh"
./13.2_BP_check_stakings.sh

