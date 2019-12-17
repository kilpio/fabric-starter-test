#!/bin/bash

source ../lib/util/util.sh
source ../lib.sh
#echo $0

#set debug
#Do not be too much verbose
DEBUG=${DEBUG:-true}
if [ "$DEBUG" = "false" ]; then
    output=/dev/null
else
    output='/dev/stdout'
fi

#Random channel name to test channel creation
export TEST_CHANNEL_NAME='testlocal'$RANDOM
echo "Test channel name= $TEST_CHANNEL_NAME" > "${output}"

#use 'reference' chaincode for testing
CHAINCODE_NAME=${CHAINCODE_NAME:-reference}
echo "Chaincode name = $CHAINCODE_NAME" > "${output}"


export DOMAIN=${DOMAIN:-example.com}
export ORG=${ORG:-org1}
export PEER0_PORT=${PEER0_PORT:7051}

echo "Chaincode name = Running test for ${ORG}.${DOMAIN}" > "${output}"
echo; echo; echo; 

#
# Running unit tests
#
printYellow "------------------" 
printYellow "Running unit tests" 
printYellow "------------------" 
echo

TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ./test-create-channel_org1.sh


TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG2='org2' ./test-add-to-org1.sh
  
PEER0_PORT=7051 TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG=org1 ./test-join-channel.sh 
PEER0_PORT=8051 TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG=org2 ./test-join-channel.sh 

PEER0_PORT=7051 CHAINCODE_NAME=$CHAINCODE_NAME TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG=org1 ./test-chaincode-install-instantiate.sh
PEER0_PORT=8051 CHAINCODE_NAME=$CHAINCODE_NAME TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG=org2 ./test-chaincode-install-instantiate.sh

CHAINCODE_NAME=$CHAINCODE_NAME TEST_CHANNEL_NAME=$TEST_CHANNEL_NAME ORG1=org1 ORG2=org2 ./test-chaincode-data-exchange.sh