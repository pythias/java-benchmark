package com.duo.benchmark;

/**
 * Created by pythias on 2019/1/24.
 */
public class Simple extends Base {
    private long count = 1_000_000;

    @Override
    protected void run() {
        int a = 0;
        for (int i = 0; i < count; i++) {
            a++;
        }
    }

    @Override
    public long getCount() {
        return this.count;
    }
}
