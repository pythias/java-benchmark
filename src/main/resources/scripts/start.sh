#!/bin/bash

function build() {
    docker_name="jdk-bench-$1"
    port=$2
    docker build -t ${docker_name} -f Dockerfile
    docker run -d --name ${docker_name} -p ${port}:8080 ${docker_name}
}

JDKS=(
"java:8,jdk,8081"
"oracle/graalvm-ce:1.0.0-rc11,graalvm,8082"
"openjdk:8u181,openjdk,8083"
"adoptopenjdk/openjdk8-openj9:jdk8u181-b13_openj9-0.9.0,openj9,8084"
"azul/zulu-openjdk:8u181,zulu,8085"
"ibmjava:8,ibm,8086"
)

for jdk in "${JDKS[@]}" ; do
    pull=$(echo $jdk | awk -F',' '{print $1}')
    name=$(echo $jdk | awk -F',' '{print $2}')
    port=$(echo $jdk | awk -F',' '{print $3}')
    sed -i "1s/.*/${pull}/" Dockerfile
    build $name $port
done
