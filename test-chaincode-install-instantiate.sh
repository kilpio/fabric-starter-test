#!/bin/bash

source ../lib/util/util.sh
source ../lib.sh

#TEST_CHANNEL_NAME='testlocal'$RANDOM
#CHAINCODE_NAME=${CHAINCODE_NAME:-reference}
DEBUG=${DEBUG:-false}
ORG=${ORG:-org1}
first_org=${1:-org1}
second_org=${2:-org2}

DOMAIN=${DOMAIN:-example.com}
#PEER0_PORT=${PEER0_PORT:7051}

if [ "$DEBUG" = "false" ]; then
    output='/dev/null'
else
    output='/dev/stdout'
fi

echo
echo

printInColor "1;36" "Installing and instantiating the <$CHAINCODE_NAME> to the <${TEST_CHANNEL_NAME}> channel..."
cd ..




PEER0_PORT=$PEER0_PORT ORG=$ORG ./chaincode-instantiate.sh $TEST_CHANNEL_NAME $CHAINCODE_NAME 2>&1 >$output

#Wait for the chaincode to instantiate
sleep 5


    result=$(docker exec cli.$ORG.$DOMAIN /bin/bash -c \
        'source container-scripts/lib/container-lib.sh; \
        peer chaincode list --instantiated -C '$TEST_CHANNEL_NAME' -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS 2>/dev/null' |
        tail -n+2 | cut -d ':' -f 2 | cut -d ',' -f 1 | sed -Ee 's/ |\n|\r//g')

    if [ "$result" = "$CHAINCODE_NAME" ]; then
        
        printGreen "OK: $ORG reports the <$CHAINCODE_NAME> chaincode is sucsessfuly instantiated on the <$TEST_CHANNEL_NAME> channel."
    else
        
        printError "ERROR: $ORG reports the <$CHAINCODE_NAME> chaincode failed to instantiate on the <$TEST_CHANNEL_NAME> channel."
        printError "See logs above."
    fi
