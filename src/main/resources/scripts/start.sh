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
    docker container stop ${docker_name}
    docker rm ${docker_name}
    docker rmi ${docker_name}
    docker build -t ${docker_name} -f Dockerfile .
    docker run -d --name ${docker_name} -p ${port}:8080 ${docker_name}
    echo "Builded JDK:${docker_name}"
}

function install_prometheus() {
    mkdir -p /data1/opdir/etc/
    mkdir -p /data1/opdir/var/data/prometheus

    \cp prometheus.yml /data1/opdir/etc/prometheus.yml

    docker run -d --name=grafana -p 3000:3000 grafana/grafana
    docker run -d --name=prometheus -p 9090:9090 -m 500M -v /data1/opdir/etc/prometheus.yml:/prometheus.yml -v /data1/opdir/var/data/prometheus:/data prom/prometheus --config.file=/prometheus.yml --log.level=info
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
    result=$(curl -s http://127.0.0.1:${port}/load)
    echo "RESULT:load ${result}"
}

function start_qps() {
    port=$1
    result=$(ab -c 100 -n 10000 http://127.0.0.1:${port}/qps | grep "Requests per second:" | awk '{print $4}')
    echo "RESULT:qps ${result}"
}

function start_bench() {
    port=$1
    result=$(curl -s http://127.0.0.1:${port}/bench)
    echo "RESULT:bench ${result}"
}

function restart_server() {
    docker_name="jdk-bench-$1"
    port=$2

    result=$(docker container stop ${docker_name})
    if [[ $result != ${docker_name} ]]; then
        echo ${result}
        exit 0
    fi

    result=$(docker container start ${docker_name})
    if [[ $result != ${docker_name} ]]; then
        echo ${result}
        exit 0
    fi

    while :; do
        health=$(curl -s http://127.0.0.1:${port}/health)
        if [[ $health = "OK" ]]; then
            break
        fi

        sleep 1
    done

    times=$(docker logs ${docker_name} | grep "Started BenchApplication" | awk '{print $13 "," substr($18,0,length($18)-1)}')
    echo "${docker_name},${times}"
}

function bench() {
    name=$1
    port=$(printf -- '%s\n' ${JDKS[*]} | grep ",${name}," | cut -d',' -f3)
    if [[ -x $port ]]; then
        echo "JDK ${name} is not exists."
        exit 0
    fi

    for api in bench qps load; do
        echo "${name} ${api} started"
        restart_server $name $port
        start_${api} $port
    done
}

function bench_all() {
    for jdk in "${JDKS[@]}" ; do
        name=$(echo $jdk | cut -d',' -f2)
        port=$(echo $jdk | cut -d',' -f3)

        for api in bench qps load; do
            echo "${name} ${api} started"
            restart_server $name $port
            start_${api} $port
        done
    done
}

function show_help() {
    echo "JDK 性能压力测试脚本。
用法： start.sh [选项]...
  -h, --help 显示帮助
  -b, --bench 开始执行指定脚本
  -a, --bench_all 开始执行所有脚本
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
            bench $2
            ;;
        -a|--bench_all)
            bench_all
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
