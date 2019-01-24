#!/bin/bash

JDKS=(
"java:8,jdk,8081"
"oracle\/graalvm-ce:1.0.0-rc11,graalvm,8082"
"openjdk:8u181,openjdk,8083"
"adoptopenjdk\/openjdk8-openj9:jdk8u181-b13_openj9-0.9.0,openj9,8084"
"azul\/zulu-openjdk:8u181,zulu,8085"
"ibmjava:8,ibm,8086"
)

function build_docker() {
    docker_name="jdk-bench-$1"
    port=$2

    echo "Building JDK:${docker_name}"
    docker build -t ${docker_name} -f Dockerfile .
    docker run -d --name ${docker_name} -p ${port}:8080 ${docker_name}
    echo "Builded JDK:${docker_name}"
}

function install() {
    for jdk in "${JDKS[@]}" ; do
        pull=$(echo $jdk | cut -d',' -f1)
        name=$(echo $jdk | cut -d',' -f2)
        port=$(echo $jdk | cut -d',' -f3)
        sed -i "1s/.*/FROM ${pull}/" Dockerfile
        build_docker $name $port
    done
}

function start_load() {
    port=$1
    curl http://127.0.0.1:$port/load
}

function start_hello() {
    port=$1
    ab -c 100 -n 10000 http://127.0.0.1:$port/duration
}

function start_base() {
    port=$1
    curl http://127.0.0.1:$port/base
}

function restart_server() {
    docker_name=$1
    port=$2

    docker stop ${docker_name}
    docker run -d --name ${docker_name} -p ${port}:8080 ${docker_name}
    while :; do
        health=$(curl http://127.0.0.1:${port}/health)
        if [[ $health = "OK"]]; then
            break
        fi

        sleep 1
    done

    echo "${docker_name}:${port} started"
}

function start_bench() {
    name=$1
    port=$(printf -- '%s\n' ${JDKS[*]} | grep ",${name}," | cut -d',' -f3)
    if [[ -x $port ]]; then
        echo "JDK ${name} is not exists."
        exit 0
    fi

    docker_name="jdk-bench-${name}"
    for api in (base hello load); do
        restart_server $docker_name $port
        start_${api} $port
    done
}

function show_help() {
    echo "JDK 性能压力测试脚本。
用法： start.sh [选项]...
  -h, --help 显示帮助
  -b, --bench 开始执行脚本
  -i, --install 初始化Docker列表
"
}

HOST=10.41.14.204
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DIR="$DIR/../../../../"
cd $DIR

while :; do
    case $1 in
        -h|-\?|--help)
            show_help
            exit
            ;;
        -b|--bench)
            start_bench $2
            ;;
        -i|--install)
            install
            ;;
        --)
            shift
            break
            ;;
        -?*)
            log_info "无法识别的参数: $1"
            ;;
        *)
            break
    esac

    shift
done
