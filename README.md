# Preface

This is an minimal sample app showing the use of _JAX-RS_ on Glassfish 7.

# Branches

At the moment there are four branches:

* GlassFish-BasicAuthenticationHTTP
* GlassFish-BasicAuthenticationHTTPS
* GlassFish-CertAuthenticationHTTPS

Each branch has a deployment directory that contains a zipped version of glassfish an a bash script to install glassfish and deploy this sample app with it

To implement more sophisticated cert authentication schemes see: 

* https://docs.payara.fish/community/docs/documentation/payara-server/server-configuration/security/certificate-realm-groups.html
* https://docs.payara.fish/community/docs/documentation/payara-server/server-configuration/security/certificate-realm-certificate-validation.html

<!--

# Application

The application consists only of  three classes

* ModelClass the domain model
* ModelService the data access class
* RestTestService the real REST service class 
* RestRXTomcatApplication (descendant of javax.ws.rs.core.Application) _JAX-RS_ application class

The RestRXTomcatApplication class is not present in all branches because it is not necessary in all scenarios. It is possible to create a _JAX-RS_ application only with annotations in the code.

-->
