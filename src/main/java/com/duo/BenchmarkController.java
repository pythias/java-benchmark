package com.duo;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.Map;
import java.util.Random;

/**
 * Created by pythias on 2019/1/23.
 */
@RestController
public class BenchmarkController {

    @RequestMapping("/duration")
    public String duration() {
        return "Hello World!";
    }

    @RequestMapping("/base")
    public Map<String, Long> base() {
        return null;
    }

    @RequestMapping("/load")
    public long load() {
        long before = System.currentTimeMillis();

        Random random = new Random();

        for(int i = 0; i < 1000; i++) {
            long[] data = new long[1000000];
            for(int l = 0; l < data.length; l++) {
                data[l] = random.nextLong();
            }
            Arrays.sort(data);
        }

        return System.currentTimeMillis() - before;
    }
}
