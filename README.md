# Preface

This is an minimal sample app showing the use of _JAX-RS_ on Glassfish 7.

# Branches

At the Moment there is one Branch:

* GlassFish-BasicAuthenticationHTTP

Each branch has a deployment directory that contains a zipped version of glassfish an a bash script to install glassfish and deploy this sample app with it

<!--

# Application

The application consists only of  three classes

* ModelClass the domain model
* ModelService the data access class
* RestTestService the real REST service class 
* RestRXTomcatApplication (descendant of javax.ws.rs.core.Application) _JAX-RS_ application class

The RestRXTomcatApplication class is not present in all branches because it is not necessary in all scenarios. It is possible to create a _JAX-RS_ application only with annotations in the code.

-->
