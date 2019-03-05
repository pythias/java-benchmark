package com.duo.benchmark;

import org.springframework.stereotype.Component;

/**
 * Created by pythias on 2019/1/24.
 */
@Component
public class Fibonacci extends Base {
    private long count = 30;

    private long fib(long n) {
        return n < 2 ? 1 : fib(n-2) + fib(n-1);
    }

    @Override
    protected void run() {
        fib(count);
    }

    @Override
    public long getCount() {
        return this.count;
    }
}
