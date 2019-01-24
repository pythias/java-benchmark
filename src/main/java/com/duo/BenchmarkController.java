package com.duo;

import com.duo.benchmark.Base;
import com.duo.benchmark.Fibonacci;
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
    public String qps() {
        return "Hello World!";
    }

    @RequestMapping("/bench")
    public Map<String, Long> bench() {
        Map<String, Long> results = new HashMap<>();

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
                results.put(bean.getBeanClassName().substring(18).toLowerCase(), bench.bench());
            } catch (Exception ex) {

            }
        }

        return results;
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
