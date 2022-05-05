#!/bin/bash


if [ -z "$1" ]; then
   mvn clean package install -DskipTests -Dmaven.javadoc.skip=true
else
   mvn clean package install -DskipTests -Dmaven.javadoc.skip=true -P$1
fi

