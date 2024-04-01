#!/usr/bin/env bash

#BD keytool documentation
# https://docs.oracle.com/en/java/javase/17/docs/specs/man/keytool.html
#
set -xeu

pw=changeit
keyStore=keystore.p12
caCert=selfsignedRootCa.cer
serverCsr=serverCsr.csr
serverCert=serverCert.cer
clientCsr=clientCsr.csr
clientCert=clientCert.cer

warFile=RestRXBasicAuthenticationHTTP.war

glassFishZip=./web-7.0.11.zip
glassFishDir=./glassfish7
glassFishTrustStore=$glassFishDir/glassfish/domains/domain1/config/cacerts.jks

source createenv.sh


rm -rf "$keyStore" "$caCert" "$serverCsr" "$serverCert" "$clientCsr" "$clientCert" "$glassFishDir"

unzip "$glassFishZip"


#BD *************************************************************************
#BD CA
#BD *************************************************************************


#BD create ca
keytool -genkeypair -v -alias selfsignedca \
  -dname "cn=myca,ou=mygroup,o=mycompany,l=mylocation,s=bavaria,c=DE" \
  -keyalg RSA -storetype PKCS12 -keystore "$keyStore" \
  -validity 3650 \
  -ext BasicConstraints:critical=ca:true,PathLen:3 \
  -ext KeyUsage:critical=keyCertSign,cRLSign \
  -storepass "$pw" -keypass "$pw"  

keytool -list -v -keystore "$keyStore"  -storepass "$pw" -keypass "$pw"


#BD *************************************************************************
#BD Server
#BD *************************************************************************


#BD create server keypair
keytool -genkeypair -v -alias server \
  -dname "cn=mycserver,ou=mygroup,o=mycompany,l=mylocation,s=bavaria,c=DE" \
  -keyalg RSA -storetype PKCS12 -keystore "$keyStore" \
  -validity 3650 \
  -ext KeyUsage:critical=digitalSignature,keyEncipherment \
  -ext ExtendedKeyUsage=serverAuth \
  -ext "SAN=dns:fedora,dns:localhost,ip:192.168.178.40,ip:127.0.0.1" \
  -storepass "$pw" -keypass "$pw"  

keytool -list -v -keystore "$keyStore"  -storepass "$pw" -keypass "$pw"

#BD from https://www.ibm.com/docs/en/sdk-java-technology/8?topic=notes-common-options#commonoptions
#
# -ext {name{:critical} {=value}}
#  Denotes an X.509 certificate extension. The option can be used
#  in -genkeypair and -gencert operations to embed extensions into
#  the certificate generated. The option can also be used in -certreq
#  operations to show which extensions are requested in the certificate
#  request. The option can appear multiple times. The name argument can
#  be a supported extension name (see Named Extensions) or an arbitrary
#  OID number. The value variable, when provided, denotes the argument
#  for the extension. When value is omitted, the default value of
#  the extension or the extension requires no argument. The :critical
#  argument, when provided, means that the isCritical attribute of the
#  extension is true; otherwise, it is false. You can use :c in place
#  of :critical.
#

#BD create server csr
keytool -certreq -keystore "$keyStore"  \
  -alias server -file "$serverCsr" \
  -ext KeyUsage:critical=digitalSignature,keyEncipherment \
  -ext ExtendedKeyUsage=serverAuth \
  -ext "SAN=dns:fedora,dns:localhost,ip:192.168.178.40,ip:127.0.0.1" \
  -storepass "$pw" -keypass "$pw"

#BD sign server csr by ca -> create server cert
keytool -gencert -keystore "$keyStore" \
  -alias selfsignedca -infile "$serverCsr" -outfile "$serverCert" \
  -ext KeyUsage:critical=digitalSignature,keyEncipherment \
  -ext ExtendedKeyUsage=serverAuth \
  -ext "SAN=dns:fedora,dns:localhost,ip:192.168.178.40,ip:127.0.0.1" \
  -storepass "$pw" -keypass "$pw"
keytool -printcert -file "$serverCert"

#BD import server cert into keystore
keytool -importcert -keystore "$keyStore" \
  -alias server -file "$serverCert" \
  -storepass "$pw" -keypass "$pw"

#BD remove signing request and certificate file
rm "$serverCsr" "$serverCert"

#BD *************************************************************************
#BD Client
#BD *************************************************************************


#BD create client keypair
keytool -genkeypair -v -alias client \
  -dname "cn=myclient,ou=mygroup,o=mycompany,l=mylocation,s=bavaria,c=DE" \
  -keyalg RSA -storetype PKCS12 -keystore "$keyStore" \
  -validity 3650 \
  -ext KeyUsage:critical=keyEncipherment \
  -ext ExtendedKeyUsage=clientAuth \
  -storepass "$pw" -keypass "$pw"  

keytool -list -v -keystore "$keyStore"  -storepass "$pw" -keypass "$pw"

#BD from https://www.ibm.com/docs/en/sdk-java-technology/8?topic=notes-common-options#commonoptions
#
# -ext {name{:critical} {=value}}
#  Denotes an X.509 certificate extension. The option can be used
#  in -genkeypair and -gencert operations to embed extensions into
#  the certificate generated. The option can also be used in -certreq
#  operations to show which extensions are requested in the certificate
#  request. The option can appear multiple times. The name argument can
#  be a supported extension name (see Named Extensions) or an arbitrary
#  OID number. The value variable, when provided, denotes the argument
#  for the extension. When value is omitted, the default value of
#  the extension or the extension requires no argument. The :critical
#  argument, when provided, means that the isCritical attribute of the
#  extension is true; otherwise, it is false. You can use :c in place
#  of :critical.

#BD create client csr
keytool -certreq -keystore "$keyStore"  \
  -alias client -file "$clientCsr" \
  -ext KeyUsage:critical=digitalSignature,keyEncipherment \
  -ext ExtendedKeyUsage=clientAuth \
  -storepass "$pw" -keypass "$pw"

#BD sign client csr by ca -> create client cert
keytool -gencert -keystore "$keyStore" \
  -alias selfsignedca -infile "$clientCsr" -outfile "$clientCert" \
  -ext KeyUsage:critical=digitalSignature,keyEncipherment \
  -ext ExtendedKeyUsage=clientAuth \
  -storepass "$pw" -keypass "$pw"
keytool -printcert -file "$clientCert"

#BD import client cert into keystore
keytool -importcert -keystore "$keyStore" \
  -alias client -file "$clientCert" \
  -storepass "$pw" -keypass "$pw"

#BD remove signing request and certificate file
rm "$clientCsr" "$clientCert"

#BD *************************************************************************
#BD Exports
#BD *************************************************************************

#BD export root cert
keytool -export -alias selfsignedca -keystore "$keyStore" -storetype PKCS12 -storepass "$pw" -rfc -file "$caCert"
keytool -printcert -file "$caCert" 


#BD import ca cert to glassfish truststore
keytool -import -file "$caCert" -keystore "$glassFishTrustStore" -keypass "$pw" -storepass "$pw" <<EOF
Ja
EOF

cat >> "$glassFishDir/glassfish/domains/domain1/config/login.conf" <<EOF
RestRX {
  com.sun.enterprise.security.auth.login.FileLoginModule required;
};
EOF


#BD Glassfish starten
export AS_START_TIMEOUT=$(expr 2 \* 60 \* 1000)
asadmin start-domain 

asadmin create-auth-realm --classname com.sun.enterprise.security.auth.realm.file.FileRealm \
  --property file=\${com.sun.aas.instanceRoot}/config/RestRXKeyFile:jaas-context=RestRX \
  RestRX

asadmin create-file-user --passwordfile=passwordfile --authrealmname RestRX --groups testusers testuser


#BD Glassfish konfigurieren
asadmin set server.network-config.protocols.protocol.http-listener-2.ssl.tls13-enabled=false
asadmin set server.network-config.protocols.protocol.http-listener-2.http.http2-enabled=false


#BD Glassfish stoppen
asadmin stop-domain


cat <<EOF


**********************************************************************************************************************

Glassfish Admin Console:
  http://localhost:4848/common/index.jsf

App:
  https://localhost:8181/certificaterealm/

glassfish starten:
  asadmin start-domain

glassfish stoppen:
  asadmin stop-domain


-> Rest Service abrufen: <-
  curl -u "testuser:testpassword" http://fedora.fritz.box:8080/RestRXBasicAuthenticationHTTP/apppath/resttest/modelclass

**********************************************************************************************************************



weiter mit Enter - glassfish wird dann mit der App im Vordergrund gestartet
EOF

read

#BD Applikation deployen
pushd ..
./gradlew war && {
  ls -l build/libs/RestRX.war 
  cp build/libs/RestRX.war deployment/"$warFile"
}
popd 
cp "$warFile"  "$glassFishDir/glassfish/domains/domain1/autodeploy/"

#BD Glasfish mit Consolenoutput
startserv
