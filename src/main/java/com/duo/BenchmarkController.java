package com.duo;

import com.duo.benchmark.Base;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider;
import org.springframework.core.type.filter.RegexPatternTypeFilter;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.*;
import java.util.regex.Pattern;

/**
 * Created by pythias on 2019/1/23.
 */
@RestController
public class BenchmarkController {

    @RequestMapping("/health")
    public String health() {
        return "OK";
    }

    @RequestMapping("/qps")
    public long qps() {
        return System.nanoTime();
    }

    @RequestMapping("/bench")
    public Map<String, Map<String, Double>> bench() {
        long sum = 0;
        Map<String, Map<String, Double>> results = new HashMap<>();

        final ClassPathScanningCandidateComponentProvider provider = new ClassPathScanningCandidateComponentProvider(false);
        provider.addIncludeFilter(new RegexPatternTypeFilter(Pattern.compile("com.duo.benchmark.*")));
        final Set<BeanDefinition> classes = provider.findCandidateComponents("com.duo.benchmark");
        for (BeanDefinition bean: classes) {
            if (bean.isAbstract()) {
                continue;
            }

            try {
                final Class<?> benchClass = Class.forName(bean.getBeanClassName());
                Base bench = (Base)benchClass.newInstance();
                long nanoTime = bench.bench();
                long count = bench.getCount();
                Map<String, Double> result = new HashMap<>();
                result.put("time", nanoTime / 1_000.0);
                result.put("qps", count / (nanoTime / 1_000_000.0));
                results.put(bean.getBeanClassName().substring(18).toLowerCase(), result);
            } catch (Exception ex) {

            }
        }

        return results;
    }

    @RequestMapping("/load")
    public long load() {
        long before = System.currentTimeMillis();

        Random random = new Random();

        for(int i = 0; i < 400; i++) {
            long[] data = new long[1_000_000];
            for(int l = 0; l < data.length; l++) {
                data[l] = random.nextLong();
            }
            Arrays.sort(data);
        }

        return System.currentTimeMillis() - before;
    }
}
