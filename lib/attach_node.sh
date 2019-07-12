#!/bin/bash

source qm.variables
source lib/common.sh

function readParameters() {
    
    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            -n|--name)
            sNode="$2"
            shift # past argument
            shift # past value
            ;;
            --ip)
            pCurrentIp="$2"
            shift # past argument
            shift # past value
            ;;
            --pk)
            publickey="$2"
            shift # past argument
            shift # past value
            ;;
            -r|--rpc)
            rPort="$2"
            shift # past argument
            shift # past value
            ;;
            -w|--whisper)
            wPort="$2"
            shift # past argument
            shift # past value
            ;;
            -c|--constellation)
            cPort="$2"
            shift # past argument
            shift # past value
            ;;
            --nm)
            tgoPort="$2"
            shift # past argument
            shift # past value
            ;;          
            *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
        esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters

    if [[ -z "$sNode" && -z "$pCurrentIp" && -z "$publickey" && -z "$rPort" && -z "$rPort" && -z "$wPort" && -z "$cPort" && -z "$tgoPort" ]]; then
        return
    fi

    if [[ -z "$sNode" || -z "$pCurrentIp" || -z "$publickey" || -z "$rPort" || -z "$rPort" || -z "$wPort" || -z "$cPort" || -z "$tgoPort" ]]; then
        help
    fi

    NON_INTERACTIVE=true
}

function readInputs(){  
    
    if [ -z "$NON_INTERACTIVE" ]; then
                
        getInputWithDefault 'Please enter the IP Address of Geth' "" pCurrentIp $RED
        getInputWithDefault 'Please enter the Public Key of Constellation' "" publickey $BLUE
        getInputWithDefault 'Please enter the RPC Port of Geth' 22000 rPort $GREEN
        getInputWithDefault 'Please enter the Network Listening Port of Geth' $((rPort+1)) wPort $GREEN
        getInputWithDefault 'Please enter the Constellation Port' $((wPort+1)) cPort $GREEN
        getInputWithDefault 'Please enter the Node Manager Port of this node' $((cPort+1)) tgoPort $BLUE
   
    fi
    
}

#function to create start node script without --raftJoinExisting flag
function createStartNodeScript(){
    
    cp lib/attach/start_lition_template.sh ${sNode}/node/start_${sNode}.sh
    cp lib/attach/start_template.sh ${sNode}/start.sh
                
    chmod +x ${sNode}/start.sh
    chmod +x ${sNode}/node/start_${sNode}.sh
    
    cp lib/common.sh  ${sNode}/node
}

function createSetupScript() {
    echo 'NODENAME='${sNode} > ${sNode}/setup.conf
    echo 'WHISPER_PORT='${wPort} >> ${sNode}/setup.conf
    echo 'RPC_PORT='${rPort} >> ${sNode}/setup.conf
    echo 'CONSTELLATION_PORT='${cPort} >> ${sNode}/setup.conf
    echo 'THIS_NODEMANAGER_PORT='${tgoPort} >> ${sNode}/setup.conf
    echo 'CURRENT_IP='${pCurrentIp} >> ${sNode}/setup.conf
    echo 'PUBKEY='${publickey} >> ${sNode}/setup.conf
    echo 'REGISTERED=' >> ${sNode}/setup.conf
    echo 'CONTRACT_ADD=' >> ${sNode}/setup.conf    
    echo 'MODE='${mode} >> ${sNode}/setup.conf
    echo 'ROLE=non-validator' >> ${sNode}/setup.conf
    echo 'STATE=NI' >> ${sNode}/setup.conf
}

function cleanup() {
    echo $sNode > .nodename
    rm -rf ${sNode}
    
    mkdir -p ${sNode}/node/contracts

    #cp lib/attach/genesis_template.json ${sNode}/node/genesis.json
    
    cp qm.variables $sNode
}

function main(){   

    readParameters $@

    if [ -z "$NON_INTERACTIVE" ]; then 
        getInputWithDefault 'Please enter node name' "" sNode $GREEN
    fi

    cleanup
    readInputs
    
    createStartNodeScript
    createSetupScript
        
}

main $@
