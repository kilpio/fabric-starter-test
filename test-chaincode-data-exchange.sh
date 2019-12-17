#!/bin/bash

source ../lib/util/util.sh
source ../lib.sh

#TEST_CHANNEL_NAME='testlocal'$RANDOM
#CHAINCODE_NAME=${CHAINCODE_NAME:-reference}
DEBUG=${DEBUG:-false}
ORG=${ORG:-org1}
ORG1=${ORG1:-org1}
ORG2=${ORG2:-org2}

DOMAIN=${DOMAIN:-example.com}
#PEER0_PORT=${PEER0_PORT:7051}

if [ "$DEBUG" = "false" ]; then
    output='/dev/null'
else
    output='/dev/stdout'
fi

echo
echo

printInColor "1;36" "Testing put/query operations with <$CHAINCODE_NAME> chaincode to the <${TEST_CHANNEL_NAME}> channel..."
cd ..

#put from $first_org
printInColor "1;36" "Invoke the <$CHAINCODE_NAME> chaincode with 'put' function to the <$TEST_CHANNEL_NAME> on the <$ORG1> org with value <$TEST_CHANNEL_NAME>..."
PEER0_PORT=7051 ORG=org1 ./chaincode-invoke.sh $TEST_CHANNEL_NAME $CHAINCODE_NAME '["put","'$TEST_CHANNEL_NAME'","'$TEST_CHANNEL_NAME'"]' 2>&1 >$output
printInColor "1;36" "5 seconds delay..."
sleep 5
#query from $second_org
printInColor "1;36" "Querring the <$CHAINCODE_NAME> for the <$TEST_CHANNEL_NAME> key on the <$ORG2> org expecting value <$TEST_CHANNEL_NAME>..."

PEER0_PORT=8051 ORG=org2 ./chaincode-query.sh $TEST_CHANNEL_NAME $CHAINCODE_NAME '["get","'$TEST_CHANNEL_NAME'"]' 2>&1 | tee /tmp/$TEST_CHANNEL_NAME 2>&1 >$output

result=$(tail -1 /tmp/$TEST_CHANNEL_NAME | sed -e 's/\n//g' -e 's/\r//g')
rm /tmp/$TEST_CHANNEL_NAME

if [ "$result" = "$TEST_CHANNEL_NAME" ]; then
    
    printGreen "OK: put <$TEST_CHANNEL_NAME>, got <$result> as expected."
else

    printError "ERROR: put <$TEST_CHANNEL_NAME>, got <$result>!"
    printError "See logs above."
fi

