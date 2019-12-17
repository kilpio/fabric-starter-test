#!/bin/bash

source ../lib/util/util.sh
source ../lib.sh

#TEST_CHANNEL_NAME='testlocal'$RANDOM
#CHAINCODE_NAME=${CHAINCODE_NAME:-reference}
DEBUG=${DEBUG:-false}
ORG=${ORG:-org1}
#first_org=${1:-org1}
#second_org=${2:-org2}

DOMAIN=${DOMAIN:-example.com}
PEER0_PORT=${PEER0_PORT:7051}

if [ "$DEBUG" = "false" ]; then
    output='/dev/null'
else
    output='/dev/stdout'
fi

printInColor "1;36" "Creating the <$TEST_CHANNEL_NAME> channel..."

#Creating the $TEST_CHANNEL_NAME channel
cd ..
./channel-create.sh $TEST_CHANNEL_NAME 2>&1 >$output

#Check if the channe been created

result=`docker exec cli.$ORG.$DOMAIN /bin/bash -c \
       'source container-scripts/lib/container-lib.sh; \
       peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS \
       -c '$TEST_CHANNEL_NAME' $ORDERER_TLSCA_CERT_OPTS 2>/dev/null  | \
       configtxlator  proto_decode --type "common.Block" | \
       jq .data.data[0].payload.data.last_update.payload.header.channel_header.channel_id' | \
       sed -E -e 's/\"|\n|\r//g'`

#the $result should contain the exact channel name created on the previuos step

#echo $result

if [ "$result" = "$TEST_CHANNEL_NAME" ]; then
    printGreen "OK: Test channel <$TEST_CHANNEL_NAME> created sucsessfully."
else
    printError "ERROR: Creating channel <$TEST_CHANNEL_NAME> failed!"
    printError "See logs above.                                   "
fi
