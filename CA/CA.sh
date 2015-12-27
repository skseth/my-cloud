

info() {
	echo -e "\033[32m$1\033[0m"
}

error_exit()
{
	echo -e "\033[31m${1:-"Unknown Error"}\033[0m" 1>&2
	exit 1
}


create_ca_folders() {
	local CADIR=$1

	info "Creating folders for CA $CADIR"

	mkdir $CADIR 

	pushd $CADIR
	mkdir certs crl newcerts private
	chmod 700 private
	touch index.txt
	echo 1000 > serial

	if [ $CADIR != $ROOTCADIR ]; then
		mkdir csr
		echo 1000 > crlnumber	
	fi

	popd
	info "Done"
}

create_openssl_conf() {
	local CADIR=$1
	local CANAME=$2
	local CONFFILE=$3

	info "Creating openssl conf file $CONFFILE"

	if [ $CADIR != $ROOTCADIR ]; then
		POLICY=policy_loose
	else
		POLICY=policy_strict
	fi

	sed -e "s~\${CADIR}~$CADIR~" \
		-e "s~\${CANAME}~$CANAME~" \
		-e "s~\${POLICY}~$POLICY~" \
		openssl.cnf.template > $CONFFILE
	info "Done"
}

create_private_key() {
	local KEYFILE=$1
	local KEYSIZE=$2
	info "Creating private key $KEYFILE"
	openssl genrsa -aes256 -out $KEYFILE $KEYSIZE || error_exit "$LINENO:Cannot create key - exiting"
	chmod 400 $KEYFILE
	info "Done"
}

create_root_cert() {
	info "Creating root certificate $ROOTCERT"
	openssl req -config $ROOTCONF \
	      -key $ROOTKEY \
	      -new -x509 -days 7300 -sha256 -extensions v3_ca \
	      -out $ROOTCERT || error_exit "$LINENO:Cannot create root cert - exiting"

	chmod 444 $ROOTCERT
	info "Done"
}

create_csr() {
	local CONFFILE=$1
	local KEYFILE=$2
	local CSRFILE=$3

	info "Creating CSR $CSRFILE"

	openssl req -config $CONFFILE -new -sha256 \
	      -key $KEYFILE \
	      -out $CSRFILE || error_exit "$LINENO:Cannot create csr - exiting"

	info "Done"

}

create_cert() {
	local CONFFILE=$1
	local CSRFILE=$2
	local CERTFILE=$3
	local EXTENSIONS=$4

	info "Creating cert $CERTFILE \nfor csr $CSRFILE, \nusing $CONFFILE"

	openssl ca -config $CONFFILE -extensions $EXTENSIONS \
	      -days 3650 -notext -md sha256 \
	      -in $CSRFILE \
	      -out $CERTFILE || error_exit "$LINENO:Cannot create cert - exiting!"

	chmod 444 $CERTFILE
	info "Done"
}

create_cert_chain() {
	info "Creating cert chain $3"
	cat $1 $2 > $3
	info "Done"
}

verify_cert() {
	local CERTFILE=$1
	local CHAINFILE=$2
	info "Verifying certificate $CERTFILE\nAgainst Chain $CHAINFILE"
	openssl verify -CAfile $CHAINFILE $CERTFILE || error_exit "$LINENO:invalid cert - exiting!"
}

print_cert() {
	local CERTFILE=$1
	info "Certificate $CERTFILE:"
	openssl x509 -noout -text -in $CERTFILE	| sed "s/^/  /"
}

create_server_cert() {
	local DOMAINNAME=$1
	local KEYFILE=$CADIR/private/$DOMAINNAME.key.pem
	local CSRFILE=$CADIR/csr/$DOMAINNAME.csr.pem
	local CERTFILE=$CADIR/certs/$DOMAINNAME.cert.pem

	if [ ! -f $CSRFILE ]; then
		create_private_key $KEYFILE 2048
		create_csr $CACONF $KEYFILE $CSRFILE
	fi

	if [ ! -f $CERTFILE ]; then
		create_cert $CACONF $CSRFILE $CERTFILE "server_cert"
		print_cert $CERTFILE
		verify_cert $CERTFILE $CACHAIN
	else
		info "Certificate $CERTFILE already exists."
	fi
}

copy_chained_file() {
	info "Chaining $1 and $2 to $3"
	cat $1 $2 > $3 || error_exit "$LINENO:copy failed - exiting!"
	info "Done"
}

copy_key_unencrypted() {
	info "Copying encrypted key $1 to\nUnecnrypted $2"
	sudo openssl rsa -in $1 -out $2 || error_exit "$LINENO:copying private key failed - exiting!"
	info "Done"	
}

export_cert_files() {
	local DOMAINNAME=$1
	local OUTDIR=$2
	local KEYFILE=$CADIR/private/$DOMAINNAME.key.pem
	local OUTKEYFILE=$OUTDIR/$DOMAINNAME.key.pem
	local CERTFILE=$CADIR/certs/$DOMAINNAME.cert.pem
	local OUTCERTFILE=$OUTDIR/$DOMAINNAME.cert.chained.pem

	if [ -f $KEYFILE ]; then
		copy_key_unencrypted $KEYFILE $OUTKEYFILE
	fi

	copy_chained_file $CERTFILE $CACHAIN $OUTCERTFILE
}


init_RootCA() {
	create_ca_folders $ROOTCADIR
	create_openssl_conf $ROOTCADIR $ROOTCANAME $ROOTCONF
	create_private_key $ROOTKEY 4096
	create_root_cert		
}

init_CA() {
	ROOTCANAME=ca
	ROOTCERT=$ROOTCADIR/certs/$ROOTCANAME.cert.pem
	ROOTKEY=$ROOTCADIR/private/$ROOTCANAME.key.pem
	ROOTCONF=$ROOTCADIR/openssl.cnf

	if [ ! -d "$ROOTCADIR" ]; then
		info "Root CA does not exist - Creating"
		init_RootCA
		info "Done creating Root CA"
	fi

	if [ ! -d "$CADIR" ]; then
		info "Intermediate CA does not exist - Creating"
		create_ca_folders $CADIR
		create_openssl_conf $CADIR $CANAME $CACONF
		create_private_key $CAKEY 4096
		create_csr $CACONF $CAKEY $CACSR
		create_cert $ROOTCONF $CACSR $CACERT "v3_intermediate_ca"
		create_cert_chain $CACERT $ROOTCERT $CACHAIN
		info "Done creating intermediate CA"
	fi
}

if [ "$1" == "" ]; then
	info "Usage\nTo create a server certificate file run:\n\t.\CA.sh RootCAfolder domainname outputdir"
	info "\nTo initialize the CA, run:\n\t.\CA.sh RootCAfolder"
	exit 0
fi

ROOTCADIR=$1

CANAME=intermediate
CADIR=$ROOTCADIR/$CANAME
CACERT=$CADIR/certs/$CANAME.cert.pem
CACHAIN=$CADIR/certs/ca-chain.cert.pem
CAKEY=$CADIR/private/$CANAME.key.pem
CACSR=$CADIR/csr/$CANAME.csr.pem
CACONF=$CADIR/openssl.cnf

init_CA

if [ "$2" != "" ]; then
	create_server_cert $2 
	export_cert_files $2 ${3:-"."}
fi






