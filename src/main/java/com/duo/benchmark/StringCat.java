package com.duo.benchmark;

/**
 * Created by pythias on 2019/1/24.
 */
public class StringCat extends Base {
    private long count = 200_000;

    @Override
    protected void run() {
        String s = "";
        for (int i = 0; i < this.count; i++) {
            s.concat("hello\n");
        }
        long l = s.length();
    }

    @Override
    public long getCount() {
        return this.count;
    }
}
