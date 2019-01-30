package com.duo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableAutoConfiguration
public class BenchApplication {

    public static void main(String[] args) {
        SpringApplication.run(BenchApplication.class, args);
    }
}

