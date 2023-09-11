#/bin/bash

mvn compile
mvn package
mvn verify
mvn install
mvn deploy