umask 022

BASE_CN="fish.dev.com"
EXPIRE_YEAR=10

read -p "put expire years (ex: 10): " EXPIRE_YEAR

EXPIRE_YEAR=$(expr 365 \* $EXPIRE_YEAR)

read -p "put your CN (ex: fish.dev.com): " BASE_CN

echo "expire days: $EXPIRE_YEAR"
echo "CN: $BASE_CN"

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd -P)"
cd $SCRIPTS_DIR

echo "create cert dir..."
mkdir cert

cd ./cert

INST_DIR=$(pwd)

HOST_IP=$(hostname -I)

SERVER_CONF=$INST_DIR/server.conf
SERVER_IP=
ADD_IP_TEMPL="IP:"

# only nat address
for i in $HOST_IP
    do
        SERVER_IP="$SERVER_IP$ADD_IP_TEMPL$i"
        ADD_IP_TEMPL=",IP:"
    done

# extra ip put this line
#SERVER_IP="$SERVER_IP,IP:<put your ip>"

openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -days $EXPIRE_YEAR -out ca.crt -subj "/CN=$BASE_CN"

rm -f "$SERVER_CONF"
touch "$SERVER_CONF"

echo "[req]" >> $SERVER_CONF
echo "req_extensions = v3_req" >> $SERVER_CONF
echo "distinguished_name = req_distinguished_name" >> $SERVER_CONF
echo "prompt = no" >> $SERVER_CONF
echo "[req_distinguished_name]" >> $SERVER_CONF
echo "CN = *.$BASE_CN" >> $SERVER_CONF
echo "[v3_req]" >> $SERVER_CONF
echo "basicConstraints = CA:FALSE" >> $SERVER_CONF
echo "keyUsage = nonRepudiation, digitalSignature, keyEncipherment" >> $SERVER_CONF
echo "extendedKeyUsage = clientAuth, serverAuth" >> $SERVER_CONF
echo "subjectAltName = $SERVER_IP" >> $SERVER_CONF

openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -config server.conf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days $EXPIRE_YEAR -extensions v3_req -extfile server.conf

echo "done. made by FISH."
