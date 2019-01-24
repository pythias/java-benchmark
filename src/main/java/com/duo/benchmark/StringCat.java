package com.duo.benchmark;

/**
 * Created by pythias on 2019/1/24.
 */
public class StringCat extends Base {
    private long count = 200_000;

    @Override
    protected void run() {
        String s = "";
        while (count-- > 0) {
            s.concat("hello\n");
        }
        long l = s.length();
    }
}
