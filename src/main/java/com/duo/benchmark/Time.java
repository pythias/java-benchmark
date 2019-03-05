package com.duo.benchmark;

/**
 * Created by pythias on 2019/3/4.
 */
public class Time extends Base {
    private long count = 1_000_000;

    @Override
    protected void run() {
        for (int i = 0; i < count; i++) {
            System.currentTimeMillis();
        }
    }

    @Override
    public long getCount() {
        return this.count;
    }
}
