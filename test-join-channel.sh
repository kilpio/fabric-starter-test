ource ../lib/util/util.sh
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



orgs=("$first_org" "$second_org")
current_peer0_port=7051

for current_org in ${orgs[*]}; do

    PEER0_PORT=$current_peer0_port ORG="$current_org" ./channel-join.sh $TEST_CHANNEL_NAME 2>&1 >$output

    current_peer0_port=$((current_peer0_port + 1000))

    result=$(docker exec cli.$current_org.$DOMAIN /bin/bash -c \
        'source container-scripts/lib/container-lib.sh; \
        peer channel list -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS 2>/dev/null |\
        grep -E "^'$TEST_CHANNEL_NAME'$"')

    if [ "$result" = "$TEST_CHANNEL_NAME" ]; then
        echo
        printYellow "OK: <$current_org> sucsessfuly joined the <$TEST_CHANNEL_NAME> channel."
    else
        echo
        printError "ERROR: <$current_org> failed to join the <$TEST_CHANNEL_NAME> channel!"
        printError "See logs above.                                   "
    fi
done