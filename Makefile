

ROOT_SSL_KEY=rootCA.key
ROOT_SSL_CERTIFICATE=rootCA.pem
ROOT_SSL_CERTIFICATE_CFG=root.cnf
DOMAIN_SSL_CFG=server.cnf
X509_V3_CFG=v3.ext
DOMAIN_SSL_CSR=server.csr
DOMAIN_SSL_KEY=server.key
DOMAIN_SSL_CERTIFICATE=server.crt
ROOT_SSL_SRL=rootCA.srl
HOST=localhost
OPENSSL_CMD=openssl

all: WELCOME_TO_HTTPS USE_YOUR_NEW_SSL_CERTIFICATE
.PHONY: all clean USE_YOUR_NEW_SSL_CERTIFICATE TRUST_THE_ROOT_SSL_CERTIFICATE WELCOME_TO_HTTPS
FORCE:



USE_YOUR_NEW_SSL_CERTIFICATE: $(DOMAIN_SSL_KEY) $(DOMAIN_SSL_CERTIFICATE) TRUST_THE_ROOT_SSL_CERTIFICATE
	@echo "---------------------------------------------------"
	@#http://patorjk.com/software/taag/#p=display&c=echo&f=Standard&t=FINISHED
	@echo "  _____ ___ _   _ ___ ____  _   _ _____ ____  "
	@echo " |  ___|_ _| \ | |_ _/ ___|| | | | ____|  _ \ "
	@echo " | |_   | ||  \| || |\___ \| |_| |  _| | | | |"
	@echo " |  _|  | || |\  || | ___) |  _  | |___| |_| |"
	@echo " |_|   |___|_| \_|___|____/|_| |_|_____|____/ "
	@echo "                                              "
	@echo "You're now ready to secure your localhost with HTTPS."
	@echo "Move the '$(DOMAIN_SSL_KEY)' and '$(DOMAIN_SSL_CERTIFICATE)' files to an accessible location on your server and include them when starting your server."

TRUST_THE_ROOT_SSL_CERTIFICATE: $(ROOT_SSL_CERTIFICATE)
	@echo "---------------------------------------------------"
	@echo "You need to manually trust '$(ROOT_SSL_CERTIFICATE)' in your browser." 


$(DOMAIN_SSL_CERTIFICATE) $(ROOT_SSL_SRL): $(ROOT_SSL_CERTIFICATE) $(ROOT_SSL_KEY) $(DOMAIN_SSL_CSR) $(X509_V3_CFG)
	@echo "---------------------------------------------------"
	@echo "Generate domain ssl certificate"
	@echo "---------------------------------------------------"
	$(OPENSSL_CMD) x509 -req -in $(DOMAIN_SSL_CSR) -CA $(ROOT_SSL_CERTIFICATE) -CAkey $(ROOT_SSL_KEY) -CAcreateserial -out $(DOMAIN_SSL_CERTIFICATE) -days 500 -sha256 -extfile $(X509_V3_CFG)

$(DOMAIN_SSL_CSR) $(DOMAIN_SSL_KEY): $(DOMAIN_SSL_CFG)
	@echo "---------------------------------------------------"
	@echo "Generate domain ssl key "
	@echo "---------------------------------------------------"
	$(OPENSSL_CMD) req -new -sha256 -nodes -out $(DOMAIN_SSL_CSR) -newkey rsa:2048 -keyout $(DOMAIN_SSL_KEY) -config "$(DOMAIN_SSL_CFG)"


$(ROOT_SSL_CERTIFICATE): $(ROOT_SSL_KEY) $(ROOT_SSL_CERTIFICATE_CFG)
	@echo "---------------------------------------------------"
	@echo "Generate root ssl certificate"
	@echo "---------------------------------------------------"
	$(OPENSSL_CMD) req -x509 -new -nodes -key $(ROOT_SSL_KEY) -sha256 -days 1024 -out $(ROOT_SSL_CERTIFICATE) -config "$(ROOT_SSL_CERTIFICATE_CFG)"

$(ROOT_SSL_KEY):
	@echo "---------------------------------------------------"
	@echo "Generate root secure sockets layer certificate"
	@echo "   passphrase needs at least 4 characters"
	@echo "---------------------------------------------------"
	$(OPENSSL_CMD) genrsa -des3 -out $(ROOT_SSL_KEY) 2048

WELCOME_TO_HTTPS: FORCE
	@#http://patorjk.com/software/taag/#p=display&c=echo&f=Standard&t=GET%20%20%20HTTPS
	@echo "   ____ _____ _____     _   _ _____ _____ ____  ____  "
	@echo "  / ___| ____|_   _|   | | | |_   _|_   _|  _ \/ ___| "
	@echo " | |  _|  _|   | |     | |_| | | |   | | | |_) \___ \ "
	@echo " | |_| | |___  | |     |  _  | | |   | | |  __/ ___) |"
	@echo "  \____|_____| |_|     |_| |_| |_|   |_| |_|   |____/ "
	@echo "                                                      "
	@echo " inspired by "
	@echo "https://www.freecodecamp.org/news/how-to-get-https-"
	@echo "working-on-your-local-development-environment-in-5-"
	@echo "minutes-7af615770eec/                              "

$(DOMAIN_SSL_CFG):
	@echo "\
[req]                         \n\
default_bits = 2048           \n\
prompt = no                   \n\
default_md = sha256           \n\
distinguished_name = dn       \n\
                              \n\
[dn]                          \n\
C=DE                          \n\
ST=RandomState                \n\
L=RandomCity                  \n\
O=RandomOrganization          \n\
OU=RandomOrganizationUnit     \n\
emailAddress=hello@example.com\n\
CN = $(HOST)                  \n\
" > $(DOMAIN_SSL_CFG)

$(ROOT_SSL_CERTIFICATE_CFG):
	@echo "\
[req]                                       \n\
prompt = no                                 \n\
distinguished_name = req_distinguished_name \n\
                                            \n\
[req_distinguished_name]                    \n\
C=DE                                        \n\
ST=RandomState                              \n\
L=RandomCity                                \n\
O=RandomOrganization                        \n\
OU=RandomOrganizationUnit                   \n\
emailAddress=hello@example.com              \n\
CN = $(HOST)                                \n\
                                            \n\
" > $(ROOT_SSL_CERTIFICATE_CFG)

$(X509_V3_CFG):
	@echo "\
authorityKeyIdentifier=keyid,issuer                                            \n\
basicConstraints=CA:FALSE                                                      \n\
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment \n\
subjectAltName = @alt_names                                                    \n\
                                                                               \n\
[alt_names]                                                                    \n\
DNS.1 = $(HOST)                                                                \n\
" > $(X509_V3_CFG)

clean:
	@echo "---------------------------------------------------"
	rm $(ROOT_SSL_KEY) $(ROOT_SSL_CERTIFICATE) $(DOMAIN_SSL_CSR) $(DOMAIN_SSL_KEY) $(DOMAIN_SSL_CERTIFICATE) $(ROOT_SSL_SRL) $(ROOT_SSL_CERTIFICATE_CFG) $(DOMAIN_SSL_CFG) $(X509_V3_CFG)
