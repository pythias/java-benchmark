package com.duo.benchmark;

public abstract class Base {
    public Long bench() {
        long beginTime = System.nanoTime();
        run();
        return System.nanoTime() - beginTime;
    }

    protected abstract void run();
}