# Certificate generation scripts

Developed by: [https://github.com/emanuelpalm](https://github.com/emanuelpalm)

Root certificates are downloaded from: [https://github.com/eclipse-arrowhead/core-java-spring/tree/master/certificates](https://github.com/eclipse-arrowhead/core-java-spring/tree/master/certificates)

```sh
wget https://raw.githubusercontent.com/eclipse-arrowhead/core-java-spring/master/certificates/master.crt
wget https://raw.githubusercontent.com/eclipse-arrowhead/core-java-spring/master/certificates/master.p12
```


## Usage

### Variable definition

At first, create a bash file containing variables used for certificate generation. They are in a separate file in order to have some boundary between public and private files.

Example:

```bash
#!/bin/bash

##
# When not set, $PASSWORD is used instead.
export MASTER_PASSWORD="PASSWORD USED FOR THE MASTER CERTIFICATE"
export CLOUD_KEYSTORE_PASSWORD="PASSWORD USED FOR CLOUD KEYSTORE"
export CLOUD_TRUSTSTORE_PASSWORD="PASSWORD USED FOR CLOUD TRUSTSTORE"
##

export PASSWORD="PASSWORD USED FOR THE CERTIFICATES"
export DOMAIN="ltu"
export CLOUD="relay"
export FOLDER="./certificates/"

##
# Subject Alternative Names
# Set here hostnames/IPs of the computers. Wildcards are allowed.
# When not set, following line is used instead.
export SAN="dns:localhost,ip:127.0.0.1"
##
```

### System certificates generation

Certificates for the main components of Arrowhead can be created by executing:

```
bash generate.sh "authorization" "contract_proxy" "data_consumer" "event_handler" "gatekeeper" "gateway" "orchestrator" "service_registry"
```

### Custom certificate generation

Any other certificates (for your own producers and consumers) are created by:

```
bash generate.sh [SERVICE NAME]
```

### PEM certificate generation

While generating certificates you can also generate `.PEM` files that are used by our Arrowhead Library ([https://github.com/CTU-IIG/ah-prem-scheduler](https://github.com/CTU-IIG/ah-prem-scheduler)).

```
bash generate.sh -a [SERVICE NAME]
```