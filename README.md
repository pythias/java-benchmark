# JVM Benchmarks

An JVM benchmark which includes Oracle JDK, OpenJDK, Zulu OpenJDK, Adopt OpenJDK, Graalvm and IBM J9.

## The benchmark script

```bash

# install dockers
sh src/main/resources/scripts/start.sh -i

# run benchmark(jdk/openjdk/graalvm/openj9/zulu/ibm)
sh src/main/resources/scripts/start.sh -b jdk

# run all benchmark
sh src/main/resources/scripts/start.sh -a

```