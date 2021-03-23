> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936253&idx=2&sn=fe74d8130a85dd70405a80092b2ba48c&scene=21#wechat_redirect)

本文主要详解 spring 中缓存的使用。

背景
--

缓存大家都有了解过吧，主要用来提升系统查询速度。

比如电商中商品详情信息，这些信息通常不会经常变动但是会高频访问，我们可以将这些信息从 db 中拿出来放在缓存中（比如 redis 中、本地内存中），当获取的时候，先从缓存中获取，缓存中没有的时候，再从 db 中获取，然后将其再丢到缓存中，当商品信息被变更之后，可以将缓存中的信息剔除或者将最新的数据丢到缓存中。

Spring 中提供了一整套的缓存解决方案，使用起来特别的容易，主要通过注解的方式使用缓存，常用的有 5 个注解，我们一个个来介绍。

本文中会大量用到 spel 表达式，对这块不熟悉的建议先看一下：[Spring 中 Spel 详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936152&idx=2&sn=5d5dcaa28fe5aec867ce05bf5119829e&scene=21#wechat_redirect)

@EnableCaching：启用缓存功能
---------------------

开启缓存功能，配置类中需要加上这个注解，有了这个注解之后，spring 才知道你需要使用缓存的功能，其他和缓存相关的注解才会有效，spring 中主要是通过 aop 实现的，通过 aop 来拦截需要使用缓存的方法，实现缓存的功能。

@Cacheable：赋予缓存功能
-----------------

### 作用

@Cacheable 可以标记在一个方法上，也可以标记在一个类上。当标记在一个方法上时表示该方法是支持缓存的，当标记在一个类上时则表示该类所有的方法都是支持缓存的。对于一个支持缓存的方法，Spring 会在其被调用后将其返回值缓存起来，以保证下次利用同样的参数来执行该方法时可以直接从缓存中获取结果，而不需要再次执行该方法。Spring 在缓存方法的返回值时是以键值对进行缓存的，值就是方法的返回结果，至于键的话，Spring 又支持两种策略，默认策略和自定义策略，这个稍后会进行说明。需要注意的是当一个支持缓存的方法在对象内部被调用时是不会触发缓存功能的。@Cacheable 可以指定三个属性，value、key 和 condition。

```
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
@Documented
public @interface Cacheable {
 String[] value() default {};
 String[] cacheNames() default {};
 String key() default "";
 String condition() default "";
 String unless() default "";
}


```

### value 属性：指定 Cache 名称

value 和 cacheNames 属性作用一样，必须指定其中一个，表示当前方法的返回值是会被缓存在哪个 Cache 上的，对应 Cache 的名称。其可以是一个 Cache 也可以是多个 Cache，当需要指定多个 Cache 时其是一个数组。

可以将 Cache 想象为一个 HashMap，系统中可以有很多个 Cache，每个 Cache 有一个名字，你需要将方法的返回值放在哪个缓存中，需要通过缓存的名称来指定。

#### 案例 1

下面 list 方法加上了缓存的功能，将其结果放在缓存`cache1`中。

```
package com.javacode2018.cache.demo1;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
public class ArticleService {

    @Cacheable(cacheNames = {"cache1"})
    public List<String> list() {
        System.out.println("获取文章列表!");
        return Arrays.asList("spring", "mysql", "java高并发", "maven");
    }
}


```

下面来个配置类`MainConfig1`，必须加上`@EnableCaching`注解用来启用缓存功能。

然后在配置类中需要定义一个 bean：缓存管理器，类型为`CacheManager`，`CacheManager`这个是个接口，有好几个实现（比如使用 redis、ConcurrentMap 来存储缓存信息），此处我们使用`ConcurrentMapCacheManager`，内部使用 ConcurrentHashMap 将缓存信息直接存储在本地 jvm 内存中，不过线上环境一般是集群的方式，可以通过 redis 实现，下一篇文章介绍 spring 缓存集成 redis。

```
package com.javacode2018.cache.demo1;

import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@EnableCaching //@0
@ComponentScan
@Configuration
public class MainConfig1 {

    //@1：缓存管理器
    @Bean
    public CacheManager cacheManager() {
        //创建缓存管理器(ConcurrentMapCacheManager：其内部使用ConcurrentMap实现的)，构造器用来指定缓存的名称，可以指定多个
        ConcurrentMapCacheManager cacheManager = new ConcurrentMapCacheManager("cache1");
        return cacheManager;
    }

}


```

来个测试类，2 次调用`list`方法看看效果

```
package com.javacode2018.cache;

import com.javacode2018.cache.demo1.ArticleService;
import com.javacode2018.cache.demo1.MainConfig1;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class CacheTest {

    @Test
    public void test1() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(MainConfig1.class);
        context.refresh();
        ArticleService articleService = context.getBean(ArticleService.class);
        System.out.println(articleService.list());
        System.out.println(articleService.list());
    }

}


```

输出

```
获取文章列表!
[spring, mysql, java高并发, maven]
[spring, mysql, java高并发, maven]


```

从第一行可以看出，第一次进入到 list 方法内部了，第二次没有进入 list 方法内部，而是从缓存中获取的。

### key 属性：自定义 key

key 属性用来指定 Spring 缓存方法的返回结果时对应的 key 的，上面说了你可以将 Cache 理解为一个 hashMap，缓存以 key->value 的形式存储在 hashmap 中，value 就是需要缓存值（即方法的返回值）

key 属性支持 SpEL 表达式；当我们没有指定该属性时，Spring 将使用默认策略生成 key（org.springframework.cache.interceptor.SimpleKeyGenerator），默认会方法参数创建 key。

自定义策略是指我们可以通过 SpEL 表达式来指定我们的 key，这里的 SpEL 表达式可以使用方法参数及它们对应的属性，使用方法参数时我们可以直接使用 “# 参数名” 或者“#p 参数 index”。

Spring 还为我们提供了一个 root 对象可以用来生成 key，通过该 root 对象我们可以获取到以下信息。

<table data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)"><thead data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)"><tr data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183067841="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">属性名称</th><th data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183067841="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">描述</th><th data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183067841="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">示例</th></tr></thead><tbody data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)"><tr data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">methodName</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">当前方法名</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">#root.methodName</td></tr><tr data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">method</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">当前方法</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">#root.method.name</td></tr><tr data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">target</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">当前被调用的对象</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">#root.target</td></tr><tr data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">targetClass</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">当前被调用的对象的 class</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">#root.targetClass</td></tr><tr data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">args</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">当前方法参数组成的数组</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183067841="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">#root.args[0]</td></tr><tr data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">caches</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">当前被调用的方法使用的 Cache</td><td data-darkmode-color-16079183067841="rgb(163, 163, 163)" data-darkmode-original-color-16079183067841="rgb(0,0,0)" data-darkmode-bgcolor-16079183067841="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183067841="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">#root.caches[0].name</td></tr></tbody></table>

这里我们主要看一下自定义策略。

#### 案例 2

ArticleService 加入下面代码

```
@Cacheable(cacheNames = {"cache1"}, key = "#root.target.class.name+'-'+#page+'-'+#pageSize")
public String getPage(int page, int pageSize) {
    String msg = String.format("page-%s-pageSize-%s", page, pageSize);
    System.out.println("从db中获取数据：" + msg);
    return msg;
}


```

`com.javacode2018.cache.CacheTest`新增测试用例

```
@Test
public void test2() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig1.class);
    context.refresh();
    ArticleService articleService = context.getBean(ArticleService.class);
    
    //page=1,pageSize=10调用2次
    System.out.println(articleService.getPage(1, 10));
    System.out.println(articleService.getPage(1, 10));
    
    //page=2,pageSize=10调用2次
    System.out.println(articleService.getPage(2, 10));
    System.out.println(articleService.getPage(2, 10));

    {
        System.out.println("下面打印出cache1缓存中的key列表");
        ConcurrentMapCacheManager cacheManager = context.getBean(ConcurrentMapCacheManager.class);
        ConcurrentMapCache cache1 = (ConcurrentMapCache) cacheManager.getCache("cache1");
        cache1.getNativeCache().keySet().stream().forEach(System.out::println);
    }
}


```

运行输出

```
从db中获取数据：page-1-pageSize-10
page-1-pageSize-10
page-1-pageSize-10
从db中获取数据：page-2-pageSize-10
page-2-pageSize-10
page-2-pageSize-10
下面打印出cache1缓存中的key列表
com.javacode2018.cache.demo1.ArticleService-getPage-1-10
com.javacode2018.cache.demo1.ArticleService-getPage-2-10


```

### condition 属性：控制缓存的使用条件

有时候，可能我们希望查询不走缓存，同时返回的结果也不要被缓存，那么就可以通过 condition 属性来实现，condition 属性默认为空，表示将缓存所有的调用情形，其值是通过 spel 表达式来指定的，当为 true 时表示先尝试从缓存中获取；若缓存中不存在，则只需方法，并将方法返回值丢到缓存中；当为 false 的时候，不走缓存、直接执行方法、并且返回结果也不会丢到缓存中。

其值 spel 的写法和 key 属性类似。

#### 案例 3

ArticleService 添加下面代码，方法的第二个参数 cache 用来控制是否走缓存，将 condition 的值指定为`#cache`

```
/**
 * 通过文章id获取文章
 *
 * @param id    文章id
 * @param cache 是否尝试从缓存中获取
 * @return
 */
@Cacheable(cacheNames = "cache1", key = "'getById'+#id", condition = "#cache")
public String getById(Long id, boolean cache) {
    System.out.println("获取数据!");
    return "spring缓存:" + UUID.randomUUID().toString();
}


```

来个测试用例，4 次调用 getById 方法，前面 2 次和最后一次 cache 参数都是 true，第 3 次为 false

```
@Test
public void test3() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig1.class);
    context.refresh();
    ArticleService articleService = context.getBean(ArticleService.class);

    System.out.println(articleService.getById(1L, true));
    System.out.println(articleService.getById(1L, true));
    System.out.println(articleService.getById(1L, false));
    System.out.println(articleService.getById(1L, true));
}


```

运行输出

```
获取数据!
spring缓存:27e7c11a-26ed-4c8b-8444-78257daafed5
spring缓存:27e7c11a-26ed-4c8b-8444-78257daafed5
获取数据!
spring缓存:05ff7612-29cb-4863-b8bf-d1b7c2c192b7
spring缓存:27e7c11a-26ed-4c8b-8444-78257daafed5


```

从输出中可以看出，第 1 次和第 3 次，都进到方法里面去了，而 2 和 4 走了缓存，第一次执行完毕之后结果被丢到了缓存中，所以 2 和 4 这 2 次获取的结果和第 1 次是一样的。

### unless 属性：控制是否需要将结果丢到缓存中

用于否决方法缓存的 SpEL 表达式。 与 condition 不同，此表达式是在调用方法后计算的，因此可以引用结果。 默认值为 “”，这意味着缓存永远不会被否决。

**前提是 condition 为空或者为 true 的情况下，unless 才有效，condition 为 false 的时候，unless 无效，unless 为 true，方法返回结果不会丢到缓存中；unless 为 false，方法返回结果会丢到缓存中。**

其值 spel 的写法和 key 属性类似。

#### 案例 4

下面来个案例，当返回结果为 null 的时候，不要将结果进行缓存，ArticleService 添加下面代码

```
Map<Long, String> articleMap = new HashMap<>();
/**
 * 获取文章，先从缓存中获取，如果获取的结果为空，不要将结果放在缓存中
 *
 * @param id
 * @return
 */
@Cacheable(cacheNames = "cache1", key = "'findById'+#id", unless = "#result==null")
public String findById(Long id) {
    this.articleMap.put(1L, "spring系列");
    System.out.println("----获取文章:" + id);
    return articleMap.get(id);
}


```

来个测试用例，4 次调用 findById，前面 2 次有数据，后面 2 次返回 null，并将缓存中的 key 打印了出来

```
@Test
public void test4() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig1.class);
    context.refresh();
    ArticleService articleService = context.getBean(ArticleService.class);

    System.out.println(articleService.findById(1L));
    System.out.println(articleService.findById(1L));
    System.out.println(articleService.findById(3L));
    System.out.println(articleService.findById(3L));

    {
        System.out.println("下面打印出缓cache1缓存中的key列表");
        ConcurrentMapCacheManager cacheManager = context.getBean(ConcurrentMapCacheManager.class);
        ConcurrentMapCache cache1 = (ConcurrentMapCache) cacheManager.getCache("cache1");
        cache1.getNativeCache().keySet().stream().forEach(System.out::println);
    }
}


```

运行输出

```
----获取文章:1
spring系列
spring系列
----获取文章:3
null
----获取文章:3
null
下面打印出缓cache1缓存中的key列表
findById1


```

可以看出文章 id 为 1 的结果被缓存了，文件 id 为 3 的没有被缓存。

### condition 和 unless 对比

缓存的使用过程中有 2 个点：

1.  查询缓存中是否有数据
    
2.  如果缓存中没有数据，则去执行目标方法，然后将方法结果丢到缓存中。
    

spring 中通过 condition 和 unless 对这 2 点进行干预。

condition 作用域上面 2 个过程，当为 true 的时候，会尝试从缓存中获取数据，如果没有，会执行方法，然后将方法返回值丢到缓存中；如果为 false，则直接调用目标方法，并且结果不会放在缓存中。

而 unless 在 condition 为 true 的情况下才有效，用来判断上面第 2 点中，是否不要将结果丢到缓存中，如果为 true，则结果不会丢到缓存中，如果为 false，则结果会丢到缓存中，并且 unless 中可以使用 spel 表达式通过 #result 来获取方法返回值。

@CachePut：将结果放入缓存
-----------------

### 作用

@CachePut 也可以标注在类或者方法上，被标注的方法每次都会被调用，然后方法执行完毕之后，会将方法结果丢到缓存中；当标注在类上，相当于在类的所有方法上标注了 @CachePut。

有 3 种情况，结果不会丢到缓存

1.  当方法向外抛出的时候
    
2.  condition 的计算结果为 false 的时候
    
3.  unless 的计算结果为 true 的时候
    

源码和 Cacheable 类似，包含的参数类似的。

```
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
@Documented
public @interface CachePut {
 String[] value() default {};
 String[] cacheNames() default {};
 String key() default "";
 String condition() default "";
 String unless() default "";
}


```

*   value 和 cacheNames：用来指定缓存名称，可以指定多个
    
*   key：缓存的 key，spel 表达式，写法参考 @Cacheable 中的 key
    
*   condition：spel 表达式，写法和 @Cacheable 中的 condition 一样，当为空或者计算结果为 true 的时候，方法的返回值才会丢到缓存中；否则结果不会丢到缓存中
    
*   unless：当 condition 为空或者计算结果为 true 的时候，unless 才会起效；true：结果不会被丢到缓存，false：结果会被丢到缓存。
    

### 案例 5

来个案例，实现新增文章的操作，然后将文章丢到缓存中，注意下面 @CachePut 中的 cacheNames、key 2 个参数和案例 4 中 findById 方法上 @Cacheable 中的一样，说明他们共用一个缓存，key 也是一样的，那么当 add 方法执行完毕之后，再去调用 findById 方法，则可以从缓存中直接获取到数据。

```
@CachePut(cacheNames = "cache1", key = "'findById'+#id")
public String add(Long id, String content) {
    System.out.println("新增文章:" + id);
    this.articleMap.put(id, content);
    return content;
}


```

测试用例

```
@Test
public void test5() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig1.class);
    context.refresh();
    ArticleService articleService = context.getBean(ArticleService.class);

    //新增3个文章，由于add方法上面有@CachePut注解，所以新增之后会自动丢到缓存中
    articleService.add(1L, "java高并发系列");
    articleService.add(2L, "Maven高手系列");
    articleService.add(3L, "MySQL高手系列");

    //然后调用findById获取，看看是否会走缓存
    System.out.println("调用findById方法，会尝试从缓存中获取");
    System.out.println(articleService.findById(1L));
    System.out.println(articleService.findById(2L));
    System.out.println(articleService.findById(3L));

    {
        System.out.println("下面打印出cache1缓存中的key列表");
        ConcurrentMapCacheManager cacheManager = context.getBean(ConcurrentMapCacheManager.class);
        ConcurrentMapCache cache1 = (ConcurrentMapCache) cacheManager.getCache("cache1");
        cache1.getNativeCache().keySet().stream().forEach(System.out::println);
    }
}


```

运行输出

```
新增文章:1
新增文章:2
新增文章:3
调用findById方法，会尝试从缓存中获取
java高并发系列
Maven高手系列
MySQL高手系列
下面打印出缓cache1缓存中的key列表
findById3
findById2
findById1


```

看几眼输出结果，然后再来看一下 findById 方法的代码

```
@Cacheable(cacheNames = "cache1", key = "'findById'+#id", unless = "#result==null")
public String findById(Long id) {
    this.articleMap.put(1L, "spring系列");
    System.out.println("----获取文章:" + id);
    return articleMap.get(id);
}


```

输出中并没有`----`这样的内容，说明调用 findById 方法获取结果是从缓存中得到的。

@CacheEvict：缓存清理
----------------

### 作用

用来清除缓存的，@CacheEvict 也可以标注在类或者方法上，被标注在方法上，则目标方法被调用的时候，会清除指定的缓存；当标注在类上，相当于在类的所有方法上标注了 @CacheEvict。

来看一下源码，每个参数的注释大家详细看一下。

```
public @interface CacheEvict {

    /**
     * cache的名称，和cacheNames效果一样
     */
    String[] value() default {};

    /**
     * cache的名称，和cacheNames效果一样
     */
    String[] cacheNames() default {};

    /**
     * 缓存的key，写法参考上面@Cacheable注解的key
     */
    String key() default "";

    /**
     * @CacheEvict 注解生效的条件，值为spel表达式，写法参考上面 @Cacheable注解中的condition
     */
    String condition() default "";

    /**
     * 是否清理 cacheNames 指定的缓存中的所有缓存信息，默认是false
     * 可以将一个cache想象为一个HashMap，当 allEntries 为true的时候，相当于HashMap.clear()
     * 当 allEntries 为false的时候，只会干掉key对应的数据，相当于HashMap.remove(key)
     */
    boolean allEntries() default false;

    /**
     * 何事执行清除操作（方法执行前 or 方法执行成功之后）
     * true：@CacheEvict 标注的方法执行之前，执行清除操作
     * false：@CacheEvict 标注的方法执行成功之后，执行清除操作，当方法弹出异常的时候，不会执行清除操作
     */
    boolean beforeInvocation() default false;
}


```

### condition 属性

@CacheEvict 注解生效的条件，值为 spel 表达式，写法参考上面 @Cacheable 注解中的 condition

### 会清除哪些缓存？

默认情况下会清除 cacheNames 指定的缓存中 key 参数指定的缓存信息。

但是当 allEntries 为 true 的时候，会清除 cacheNames 指定的缓存中的所有缓存信息。

### 具体什么时候清除缓存？

这个是通过 beforeInvocation 参数控制的，这个参数默认是 false，默认会在目标方法成功执行之后执行清除操作，若方法向外抛出了异常，不会执行清理操作；

如果 beforeInvocation  为 true，则方法被执行之前就会执行缓存清理操作，方法执行之后不会再执行了。

### 案例 6

ArticleService 中新增个方法，使用 @CacheEvict 标注，这个方法执行完毕之后，会清理 cache1 中`key=findById+参数id`的缓存信息，注意 cacheNames 和 key 两个参数的值和 findById 中这 2 个参数的值一样。

```
@CacheEvict(cacheNames = "cache1", key = "'findById'+#id") //@1
public void delete(Long id) {
    System.out.println("删除文章：" + id);
    this.articleMap.remove(id);
}


```

新增测试用例，注释比较清晰，就不解释了

```
@Test
public void test6() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig1.class);
    context.refresh();
    ArticleService articleService = context.getBean(ArticleService.class);

    //第1次调用findById，缓存中没有，则调用方法，将结果丢到缓存中
    System.out.println(articleService.findById(1L));
    //第2次调用findById，缓存中存在，直接从缓存中获取
    System.out.println(articleService.findById(1L));

    //执行删除操作，delete方法上面有@CacheEvict方法，会清除缓存
    articleService.delete(1L);

    //再次调用findById方法，发现缓存中没有了，则会调用目标方法
    System.out.println(articleService.findById(1L));
}


```

运行输出

```
----获取文章:1
spring系列
spring系列
删除文章：1
----获取文章:1
spring系列


```

调用了 3 次 findById，第 1 次，缓存中没有，所以进到方法内部了，然后将结果丢到缓存了，第 2 次缓存中有，所以从缓存获取，然后执行了 delete 方法，这个方法执行完毕之后，会清除缓存中文章 id 为 1L 的文章信息，最后执行第三次 findById 方法，此时缓存中没有发现数据，然后进到目标方法内部了，目标方法内部输出了`----`内容。

@Caching：缓存注解组
--------------

当我们在类上或者同一个方法上同时使用 @Cacheable、@CachePut 和 @CacheEvic 这几个注解中的多个的时候，此时可以使用 @Caching 这个注解来实现。

```
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
@Documented
public @interface Caching {

 Cacheable[] cacheable() default {};

 CachePut[] put() default {};

 CacheEvict[] evict() default {};

}


```

@CacheConfig：提取公共配置
-------------------

这个注解标注在类上，可以将其他几个缓存注解（@Cacheable、@CachePut 和 @CacheEvic）的公共参数给提取出来放在 @CacheConfig 中。

比如当一个类中有很多方法都需要使用（@Cacheable、@CachePut 和 @CacheEvic）这些缓存注解的时候，大家可以看一下这 3 个注解的源码，他们有很多公共的属性，比如：cacheNames、keyGenerator、cacheManager、cacheResolver，若这些属性值都是一样的，可以将其提取出来，放在 @CacheConfig 中，不过这些注解（@Cacheable、@CachePut 和 @CacheEvic）中也可以指定属性的值对 @CacheConfig 中的属性值进行覆盖。

```
@CacheConfig(cacheNames = "cache1")
public class ArticleService {
    @Cacheable(key = "'findById'+#id")
    public String findById(Long id) {
        this.articleMap.put(1L, "spring系列");
        System.out.println("----获取文章:" + id);
        return articleMap.get(id);
    }
}


```

原理
--

spring 中的缓存主要是利用 spring 中 aop 实现的，通过 Aop 对需要使用缓存的 bean 创建代理对象，通过代理对象拦截目标方法的执行，实现缓存功能。

重点在于`@EnableCaching`这个注解，可以从`@Import`这个注解看起

```
@Import(CachingConfigurationSelector.class)
public @interface EnableCaching {
}


```

最终会给需要使用缓存的 bean 创建代理对象，并且会在代理中添加一个拦截器`org.springframework.cache.interceptor.CacheInterceptor`，这个类中的`invoke`方法是关键，会拦截所有缓存相关的目标方法的执行，大家可以去细看一下。

总结
--

**Spring 系列到此已经 40 篇了，能和我一起坚持到现在的，真的不容易。**

**还没有看完的朋友，建议大家按序都看一遍，文章最好按顺序看，前后知识点是有依赖的。**

**如果前面的文章都看过了，那么本文的原理，不用我介绍了，大家自己很容易就搞懂了。**

案例源码
----

```
https://gitee.com/javacode2018/spring-series


```

**路人甲 java 所有案例代码以后都会放到这个上面，大家 watch 一下，可以持续关注动态。**

Spring 系列
---------

1.  [Spring 系列第 1 篇：为何要学 spring？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933921&idx=1&sn=db7ff07c5d60283b456fb9cd2a60f960&chksm=88621e1fbf15970919e82f059815714545806dc7ca1c48ed7a609bc4d90c1f4bb52dfa0706d5&token=157089977&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [Spring 系列第 2 篇：控制反转（IoC）与依赖注入（DI）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933936&idx=1&sn=bd7fbbb66035ce95bc4fd11b8cb3bdf2&chksm=88621e0ebf15971872448086b445f56aef714d8597c4b61f1fbae2f7c04061754d4f5873c954&token=339287021&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Spring 系列第 3 篇：Spring 容器基本使用及原理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933940&idx=1&sn=6c8c6dc1d8f955663a9874c9f94de88e&chksm=88621e0abf15971c796248e35100c043dac0f5173a870c1d952d4d88a336fa4b76db6885a70c&token=339287021&lang=zh_CN&scene=21#wechat_redirect)
    
4.  [Spring 系列第 4 篇：xml 中 bean 定义详解 (-)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933945&idx=1&sn=f9a3355a60f33a0bbf56d013adbf94ca&chksm=88621e07bf1597119d8df91702f7bece9fa64659b5cbb8fed311b314fa64b0465eaa080712fc&token=298797737&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [Spring 系列第 5 篇：创建 bean 实例这些方式你们都知道？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933955&idx=2&sn=bbf4c1c9c996df9454b71a9f68d59779&chksm=88621e7dbf15976ba26c8919394b9049c3906223c4e97b88ccfed62e75ec4688668555dd200f&token=1045303334&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [Spring 系列第 6 篇：玩转 bean scope，避免跳坑里！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933960&idx=1&sn=f4308f8955f87d75963c379c2a0241f4&chksm=88621e76bf159760d404c253fa6716d3ffce4de8df0fc1d0d5dd0cf00a81bc170a30829ee58f&token=1314297026&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [Spring 系列第 7 篇：依赖注入之手动注入](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933967&idx=1&sn=3444809283b21222dd291a14dad0571b&chksm=88621e71bf159767f8e32e33488383d5841de7e13ca596d7c6572c8d97ba3ae143d3a3888463&token=1687118085&lang=zh_CN&scene=21#wechat_redirect)
    
8.  [Spring 系列第 8 篇：自动注入（autowire）详解，高手在于坚持](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933974&idx=2&sn=7c9cc4e1f2c0f4cb83e985b593f2b6fb&chksm=88621e68bf15977e9451262d440c21e0abf622e54162beef838ba8a9512c7eac0bb8b8852527&token=2030963208&lang=zh_CN&scene=21#wechat_redirect)
    
9.  [Spring 系列第 9 篇：depend-on 到底是干什么的？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933982&idx=1&sn=69a2906f5db1953030ff40225b3ac788&chksm=88621e60bf159776093398f89652fecc99fb78ddf6f7434afbe65f8511d3e41c65d729303507&token=880944996&lang=zh_CN&scene=21#wechat_redirect)
    
10.  [Spring 系列第 10 篇：primary 可以解决什么问题？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933997&idx=1&sn=755c93c5e1bef571ac108e9045444fdd&chksm=88621e53bf15974584bbc4c6bf706f1714cb86cd65ac3e467ccf81bb9853fc9854b9ceed1981&token=1156408467&lang=zh_CN&scene=21#wechat_redirect)
    
11.  [Spring 系列第 11 篇：bean 中的 autowire-candidate 又是干什么的？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934008&idx=1&sn=ac156fe2788c49e0014bb5056139206e&chksm=88621e46bf1597505eba3e716148efcd9acec72ee6c0d95cf3936be70241fd41b180f0de02b5&token=1248115129&lang=zh_CN&scene=21#wechat_redirect)
    
12.  [Spring 系列第 12 篇：lazy-init：bean 延迟初始化](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934052&idx=2&sn=96f821743a61d4645f32faa44b2b3087&chksm=88621e9abf15978cb11ad368523b7c98181744862c26020a5213db521040cd880347eb452af6&token=1656183666&lang=zh_CN&scene=21#wechat_redirect)
    
13.  [Spring 系列第 13 篇：使用继承简化 bean 配置 (abstract & parent)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934063&idx=1&sn=d529258a955ed5b53c9081219c8391e7&chksm=88621e91bf159787351880d2217b9f3fb7b06d251caa32995657cd2ca9613765bf87ff7e04a0&token=1656183666&lang=zh_CN&scene=21#wechat_redirect)
    
14.  [Spring 系列第 14 篇：lookup-method 和 replaced-method 比较陌生，怎么玩的？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934074&idx=1&sn=5b7ccbef079053d9af4027f0dc642c56&chksm=88621e84bf1597923127e459e11da5c27741f080a0bfd033019ccc52cf67915ec4999d76b6dd&token=1283885571&lang=zh_CN&scene=21#wechat_redirect)
    
15.  [Spring 系列第 15 篇：代理详解（Java 动态代理 & cglib 代理）？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934082&idx=1&sn=c919886400135a0152da23eaa1f276c7&chksm=88621efcbf1597eab943b064147b8fb8fd3dfbac0dc03f41d15d477ef94b60d4e8f78c66b262&token=1042984313&lang=zh_CN&scene=21#wechat_redirect)
    
16.  [Spring 系列第 16 篇：深入理解 java 注解及 spring 对注解的增强（预备知识）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934095&idx=1&sn=26d539ef61389bae5d293f1b2f5210b2&chksm=88621ef1bf1597e756ccaeb6c6c6f4b74c6e3ba22ca6adba496b05e81558cd3801c62b21b8d9&token=1042984313&lang=zh_CN&scene=21#wechat_redirect)
    
17.  [Spring 系列第 17 篇：@Configration 和 @Bean 注解详解 (bean 批量注册)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934137&idx=1&sn=3775d5d7a23c43616d1274b0b52a9f99&chksm=88621ec7bf1597d1b16d91cfb28e63bef485f10883c7ca30d09838667f65e3d214b9e1cebd47&token=1372043037&lang=zh_CN&scene=21#wechat_redirect)
    
18.  [Spring 系列第 18 篇：@ComponentScan、@ComponentScans 详解 (bean 批量注册)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934150&idx=1&sn=6e466720d78f212cbd7d003bc5c2eec2&chksm=88621f38bf15962e324888161d0b91f34c26e4b8a53da87f1364e5af7010dbdcabc9fb555476&token=1346356013&lang=zh_CN&scene=21#wechat_redirect)
    
19.  [Spring 系列第 18 篇：@import 详解 (bean 批量注册)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934173&idx=1&sn=60bb7d58fd408db985a785bfed6e1eb2&chksm=88621f23bf15963589f06b7ce4e521a7c8d615b1675788f383cbb0bcbb05b117365327e1941a&token=704646761&lang=zh_CN&scene=21#wechat_redirect)
    
20.  [Spring 系列第 20 篇：@Conditional 通过条件来控制 bean 的注册](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934205&idx=1&sn=5407aa7c49eb34f7fb661084b8873cfe&chksm=88621f03bf1596159eeb40d75620db03457f4aa831066052ebc6e1efc2d7b18802a49a7afe8a&token=332995799&lang=zh_CN&scene=21#wechat_redirect)
    
21.  [Spring 系列第 21 篇：注解实现依赖注入（@Autowired、@Resource、@Primary、@Qulifier）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934232&idx=1&sn=fd2f34d8d1342fe819c5a71059e440a7&chksm=88621f66bf159670a8268f8db74db075634a24a58b75589e4e7db2f06e6166c971074feae764&token=979575345&lang=zh_CN&scene=21#wechat_redirect)
    
22.  [Spring 系列第 22 篇：@Scope、@DependsOn、@ImportResource、@Lazy 详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934284&idx=1&sn=00126ad4b435cb31726a5ef10c31af25&chksm=88621fb2bf1596a41563db5c474873c62d552ec9a440037d913704f018742ffca9be9b598680&token=887127000&lang=zh_CN&scene=21#wechat_redirect)
    
23.  [Spring 系列第 23 篇：Bean 生命周期详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934322&idx=1&sn=647edffeedeb8978c18ad403b1f3d8d7&chksm=88621f8cbf15969af1c5396903dcce312c1f316add1af325327d287e90be49bbeda52bc1e736&token=718443976&lang=zh_CN&scene=21#wechat_redirect)
    
24.  [Spring 系列第 24 篇：父子容器详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934382&idx=1&sn=7d37aef61cd18ec295f268c902dfb84f&chksm=88621fd0bf1596c6c9f60c966eb325c6dfe0e200666ee0bcdd1ff418597691795ad209e444f2&token=749715143&lang=zh_CN&scene=21#wechat_redirect)
    
25.  [Spring 系列第 25 篇：@Value【用法、数据来源、动态刷新】](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934401&idx=1&sn=98e726ec9adda6d40663f624705ba2e4&chksm=8862103fbf15992981183abef03b4774ab1dfd990a203a183efb8d118455ee4b477dc6cba50d&token=636643900&lang=zh_CN&scene=21#wechat_redirect)
    
26.  [Spring 系列第 26 篇：国际化详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934484&idx=1&sn=ef0a704c891f318a7c23fe000d9003d5&chksm=8862106abf15997c39a3387ce7b2e044cfb3abd92b908eb0971d084c8238ff5f99af412d6054&token=1299257585&lang=zh_CN&scene=21#wechat_redirect)
    
27.  [Spring 系列第 27 篇：spring 事件机制详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934522&idx=1&sn=7653141d01b260875797bbf1305dd196&chksm=88621044bf15995257129e33068f66fc5e39291e159e5e0de367a14e0195595c866b3aaa1972&token=1081910573&lang=zh_CN&scene=21#wechat_redirect)
    
28.  [Spring 系列第 28 篇：Bean 循环依赖详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934550&idx=1&sn=2cf05f53a63d12f74e853a10a11dcc98&scene=21#wechat_redirect)
    
29.  [Spring 系列第 29 篇：BeanFactory 扩展（BeanFactoryPostProcessor、BeanDefinitionRegistryPostProcessor）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934655&idx=1&sn=5b6c360de7eda0ca83d38e9db3616761&chksm=886210c1bf1599d7c42919a8b883a7cd2dd8e42212627a32e6d91dfb1f6da1b9536079ec4f6d&token=1804011114&lang=zh_CN&scene=21#wechat_redirect)
    
30.  [Spring 系列第 30 篇：jdk 动态代理和 cglib 代理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934783&idx=1&sn=5531f14475a4addc6d4d47f0948b3208&chksm=88621141bf159857bc19d7bb545ed3ddc4152dcda9e126f27b83afc2e975dee1682de2d98ad6&token=690771459&lang=zh_CN&scene=21#wechat_redirect)
    
31.  [Spring 系列第 31 篇：aop 概念详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934876&idx=1&sn=7794b50e658e0ec3e0aff6cf5ed4aa2e&chksm=886211e2bf1598f4e0e636170a4b36a5a5edd8811c8b7c30d61135cb114b0ce506a6fa84df0b&token=690771459&lang=zh_CN&scene=21#wechat_redirect)
    
32.  [Spring 系列第 32 篇：AOP 核心源码、原理详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934930&idx=1&sn=4030960657cc72006122ef8b6f0de889&chksm=8862122cbf159b3a4823a7f6b93add5ae1ad0e60cdedf8ed2d558c0f67bd6b0158a900d270eb&scene=21#wechat_redirect)
    
33.  [Spring 系列第 33 篇：ProxyFactoryBean 创建 AOP 代理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934977&idx=1&sn=8e4caf6a17bf5e123884df81a6382214&chksm=8862127fbf159b699c4456afe35a17f0d7bed119a635b11c154751dd95f59917487c895ccb84&scene=21#wechat_redirect)
    
34.  [Spring 系列第 34 篇：@Aspect 中 @Pointcut 12 种用法](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935037&idx=2&sn=cf813ac4cdfa3a0a0d6b5ed770255779&chksm=88621243bf159b554be2fe75eda7f5631ca29eed54edbfb97b08244625e03957429f2414d1e3&token=883563940&lang=zh_CN&scene=21#wechat_redirect)
    
35.  [Spring 系列第 35 篇：@Aspect 中 5 中通知详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935466&idx=2&sn=f536d7a2834e6e590bc7af0527e4de1f&scene=21#wechat_redirect)
    
36.  [Spring 系列第 36 篇：@EnableAspectJAutoProxy、@Aspect 中通知顺序详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935500&idx=2&sn=5fb794139e476a275963432948e29362&scene=21#wechat_redirect)
    
37.  [Spring 系列第 37 篇：@EnableAsync & @Async 实现方法异步调用](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935642&idx=2&sn=6b9ac2b42f5c5da424a424ec909392fe&scene=21#wechat_redirect)
    
38.  [Spring 系列第 38 篇：@Scheduled & @EnableScheduling 定时器详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935890&idx=2&sn=f8a8e01e7399161621152b2e4caa8128&scene=21#wechat_redirect)
    
39.  [Spring 系列第 39 篇：强大的 Spel 表达式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936152&idx=2&sn=5d5dcaa28fe5aec867ce05bf5119829e&scene=21#wechat_redirect)
    

更多好文章
-----

1.  [Java 高并发系列（共 34 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933285&idx=1&sn=f5507c251b84c3405f2fe0f7fb1da97d&chksm=88621b9bbf15928dd4c26f52b2abb0e130cde02100c432f33f0e90123b5e4b20d43017c1030e&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [MySql 高手系列（共 27 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933461&idx=1&sn=67cd31469273b68a258d963e53b56325&chksm=88621c6bbf15957d7308d81cd8ba1761b356222f4c6df75723aee99c265bd94cc869faba291c&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Maven 高手系列（共 10 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933753&idx=1&sn=0b41083939980be87a61c4f573792459&chksm=88621d47bf1594516092b662c545abfac299d296e232bf25e9f50be97e002e2698ea78218828&scene=21#wechat_redirect)
    
4.  [Mybatis 系列（共 12 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933868&idx=1&sn=ed16ef4afcbfcb3423a261422ff6934e&chksm=88621dd2bf1594c4baa21b7adc47456e5f535c3358cd11ddafb1c80742864bb19d7ccc62756c&token=1400407286&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [聊聊 db 和缓存一致性常见的实现方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933452&idx=1&sn=48b3b1cbd27c50186122fef8943eca5f&chksm=88621c72bf159564e629ee77d180424274ae9effd8a7c2997f853135b28f3401970793d8098d&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [接口幂等性这么重要，它是什么？怎么实现？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933334&idx=1&sn=3a68da36e4e21b7339418e40ab9b6064&chksm=88621be8bf1592fe5301aab732fbed8d1747475f4221da341350e0cc9935225d41bf79375d43&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [泛型，有点难度，会让很多人懵逼，那是因为你没有看这篇文章！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933878&idx=1&sn=bebd543c39d02455456680ff12e3934b&chksm=88621dc8bf1594de6b50a760e4141b80da76442ba38fb93a91a3d18ecf85e7eee368f2c159d3&token=799820369&lang=zh_CN&scene=21#wechat_redirect)
    

```
世界上最好的关系是相互成就，点赞转发 感恩开心😃




```

路人甲 java  

![](https://mmbiz.qpic.cn/mmbiz_png/9Xne6pfLaexiaK8h8pVuFJibShbdbS0QEE9V2UuWiakgeMWbXLgrrT114RwXKZfEJicvtz3jsUslfVhpOGZS62mQvg/640?wx_fmt=png)

▲长按图片识别二维码关注

路人甲 Java：工作 10 年的前阿里 P7，所有文章以系列的方式呈现，带领大家成为 java 高手，目前已出：java 高并发系列、mysql 高手系列、Maven 高手系列、mybatis 系列、spring 系列，正在连载 springcloud 系列，欢迎关注！