FROM java:8
ADD /target/bench-0.0.1-SNAPSHOT.jar bench.jar
ENTRYPOINT ["java", "-jar", "/bench.jar"]