package com.duo.benchmark;

/**
 * Created by pythias on 2019/1/24.
 */
public class SimpleCall extends Base {
    private long count = 1_000_000;

    @Override
    protected void run() {
        String a = "hello";
        for (int i = 0; i < count; i++) {
            a.length();
        }
    }

    @Override
    public long getCount() {
        return this.count;
    }
}
