package com.duo.benchmark;

/**
 * Created by pythias on 2019/3/5.
 */
public class StringBuilder extends Base {
    private long count = 200_000;

    @Override
    protected void run() {
        java.lang.StringBuilder sb = new java.lang.StringBuilder();
        for (int i = 0; i < this.count; i++) {
            sb.append("hello\n");
        }
        long l = sb.toString().length();
    }

    @Override
    public long getCount() {
        return this.count;
    }
}