#!/bin/bash


cd "$(dirname "$0")" || exit
source "variables.sh"
source "lib_certs.sh"


## Variables
# DOMAIN
# FOLDER = "./certificates/"
# CLOUD

if ! test -d ${FOLDER}; then
    mkdir -p "$FOLDER"
fi

if test "$1" == "-a"; then
    GENERATE_ALL=1
    shift
else
    GENERATE_ALL=0
fi

if test $# -gt 0; then
    SYSTEM=$1;
else
    echo "Usage: bash generate.sh [-a] SYSTEM_NAMES" >&2
    echo "Use '-a' to generate also 'pem' certificates required by the Arrowhead library." >&2
    exit 2;
fi


# Create folder if does not exist
if ! test -d "${FOLDER}"; then
    echo "Creating folder for certificates..."
    mkdir -p "${FOLDER}"
fi


# Generating certificates for SYSTEM.CLOUD.DOMAIN.arrowhead.eu

## 1) Generate root certificate keystore
echo -n "Step 1: Root (master) certificate "

if test -f "master.p12"; then
    echo "FOUND";
else
    # Can be generated using:
    # create_root_keystore \
    #     "${FOLDER}master.p12" "arrowhead.eu"
    # echo "GENERATED";
    echo "Download 'master.p12' and 'master.crt' (also called 'root') from arrowhead-f repository." >&2
    exit 1;
fi


## 2) Generate truststore
## This is not needed?
#echo -n "Step 2: Truststore "
#
#if test -f "${FOLDER}truststore.p12"; then
#    echo "FOUND";
#else
#    create_truststore \
#        "${FOLDER}truststore.p12" "root.crt" "arrowhead.eu"
#    echo "GENERATED";
#fi


## 2) Generate cloud keystore
echo -n "Step 2: Cloud keystore "

if test -f "${FOLDER}${CLOUD}.p12" && test -f "${FOLDER}${CLOUD}.crt"; then
    echo "FOUND";
else
    create_cloud_keystore \
        "master.p12" "arrowhead.eu" \
        "${FOLDER}${CLOUD}.p12" "${CLOUD}.${DOMAIN}.arrowhead.eu"

    if test $? -ne 0; then
        echo "NOT GENERATED";
        exit 3;
    else
        echo "GENERATED";
    fi
fi


## 3) Generate system certificate
echo -n "Step 3: System certificates "

while test $# -gt 0; do
    SYSTEM=$1

    if test -f "${FOLDER}${SYSTEM}.p12"; then
        echo "${SYSTEM} : FOUND";
    else
        create_system_keystore \
            "master.p12" "arrowhead.eu" \
            "${FOLDER}${CLOUD}.p12" "${CLOUD}.${DOMAIN}.arrowhead.eu" \
            "${FOLDER}${SYSTEM}.p12" "${SYSTEM}.${CLOUD}.${DOMAIN}.arrowhead.eu" \
            "dns:localhost,ip:127.0.0.1"

        if test $? -ne 0; then
            echo "${SYSTEM} : NOT GENERATED";
            shift
            continue
        fi

        if test $GENERATE_ALL -eq 1; then
            openssl pkcs12 -in "${FOLDER}${SYSTEM}.p12" -out "${FOLDER}${SYSTEM}.cacert.pem" -cacerts -nokeys -password pass:"${PASSWORD}"
            openssl pkcs12 -in "${FOLDER}${SYSTEM}.p12" -out "${FOLDER}${SYSTEM}.clcert.pem" -clcerts -nokeys -password pass:"${PASSWORD}"
            openssl pkcs12 -in "${FOLDER}${SYSTEM}.p12" -out "${FOLDER}${SYSTEM}.privkey.pem" -nocerts -password pass:"${PASSWORD}" -passout pass:"${PASSWORD}"
            openssl rsa    -in "${FOLDER}${SYSTEM}.privkey.pem" -pubout -out "${FOLDER}${SYSTEM}.publickey.pem" -passin pass:"${PASSWORD}"
            openssl pkcs12 -in "${FOLDER}${SYSTEM}.p12" -out "${FOLDER}${SYSTEM}.key" -nodes -nocerts -password pass:"${PASSWORD}"
            openssl pkcs12 -in "${FOLDER}${SYSTEM}.p12" -out "${FOLDER}${SYSTEM}.crt" -nodes -password pass:"${PASSWORD}"
        fi
        echo "${SYSTEM} : GENERATED";
    fi
    shift
done


## 4) Generate sysop certificate
echo -n "Step 4: Sysop certificate "

if test -f "${FOLDER}sysop.p12"; then
    echo "FOUND";
else
    create_sysop_keystore \
        "master.p12" "arrowhead.eu" \
        "${FOLDER}${CLOUD}.p12" "${CLOUD}.${DOMAIN}.arrowhead.eu" \
        "${FOLDER}sysop.p12" "sysop.${CLOUD}.${DOMAIN}.arrowhead.eu"
    echo "GENERATED";
fi


## 5) Generate cloud truststore
echo -n "Step 5: Cloud truststore "

if test -f "${FOLDER}truststore.p12"; then
    echo "FOUND";
else
    create_truststore \
        "${FOLDER}truststore.p12" \
        "${FOLDER}${CLOUD}.crt" "${CLOUD}.${DOMAIN}.arrowhead.eu" \
        "master.crt" "arrowhead.eu"
    echo "GENERATED";
fi
