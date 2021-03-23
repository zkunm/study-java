> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935642&idx=2&sn=6b9ac2b42f5c5da424a424ec909392fe&scene=21#wechat_redirect)

1、本文内容
------

详解 @EnableAsync & @Async，主要分下面几个点进行介绍。

1.  **作用**
    
2.  **用法**
    
3.  **获取异步执行结果**
    
4.  **自定义异步执行的线程池**
    
5.  **自定义异常处理**
    
6.  **线程隔离**
    
7.  **源码 & 原理**
    

2、作用
----

**spring 容器中实现 bean 方法的异步调用。**

比如有个 logService 的 bean，logservice 中有个 log 方法用来记录日志，当调用`logService.log(msg)`的时候，希望异步执行，那么可以通过`@EnableAsync & @Async`来实现。

3、用法
----

### 2 步

1.  需要异步执行的方法上面使用`@Async`注解标注，若 bean 中所有的方法都需要异步执行，可以直接将`@Async`加载类上。
    
2.  将`@EnableAsync`添加在 spring 配置类上，此时`@Async`注解才会起效。
    

### 常见 2 种用法

1.  无返回值的
    
2.  可以获取返回值的
    

4、无返回值的
-------

### 用法

方法返回值不是`Future`类型的，被执行时，会立即返回，并且无法获取方法返回值，如：

```
@Async
public void log(String msg) throws InterruptedException {
    System.out.println("开始记录日志," + System.currentTimeMillis());
    //模拟耗时2秒
    TimeUnit.SECONDS.sleep(2);
    System.out.println("日志记录完毕," + System.currentTimeMillis());
}


```

### 案例

实现日志异步记录的功能。

LogService.log 方法用来异步记录日志，需要使用`@Async`标注

```
package com.javacode2018.async.demo1;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Component
public class LogService {
    @Async
    public void log(String msg) throws InterruptedException {
        System.out.println(Thread.currentThread() + "开始记录日志," + System.currentTimeMillis());
        //模拟耗时2秒
        TimeUnit.SECONDS.sleep(2);
        System.out.println(Thread.currentThread() + "日志记录完毕," + System.currentTimeMillis());
    }
}


```

来个 spring 配置类，需要加上`@EnableAsync`开启 bean 方法的异步调用.

```
package com.javacode2018.async.demo1;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.scheduling.annotation.EnableAsync;

@ComponentScan
@EnableAsync
public class MainConfig1 {
}


```

测试代码

```
package com.javacode2018.async;

import com.javacode2018.async.demo1.LogService;
import com.javacode2018.async.demo1.MainConfig1;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import java.util.concurrent.TimeUnit;

public class AsyncTest {

    @Test
    public void test1() throws InterruptedException {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(MainConfig1.class);
        context.refresh();
        LogService logService = context.getBean(LogService.class);
        System.out.println(Thread.currentThread() + " logService.log start," + System.currentTimeMillis());
        logService.log("异步执行方法!");
        System.out.println(Thread.currentThread() + " logService.log end," + System.currentTimeMillis());

        //休眠一下，防止@Test退出
        TimeUnit.SECONDS.sleep(3);
    }

}


```

运行输出

```
Thread[main,5,main] logService.log start,1595223990417
Thread[main,5,main] logService.log end,1595223990432
Thread[SimpleAsyncTaskExecutor-1,5,main]开始记录日志,1595223990443
Thread[SimpleAsyncTaskExecutor-1,5,main]日志记录完毕,1595223992443


```

前 2 行输出，可以看出`logService.log`立即就返回了，后面 2 行来自于 log 方法，相差 2 秒左右。

前面 2 行在主线程中执行，后面 2 行在异步线程中执行。

5、获取异步返回值
---------

### 用法

若需取异步执行结果，方法返回值必须为`Future`类型，使用 spring 提供的静态方法`org.springframework.scheduling.annotation.AsyncResult#forValue`创建返回值，如：

```
public Future<String> getGoodsInfo(long goodsId) throws InterruptedException {
    return AsyncResult.forValue(String.format("商品%s基本信息!", goodsId));
}


```

### 案例

场景：电商中商品详情页通常会有很多信息：商品基本信息、商品描述信息、商品评论信息，通过 3 个方法来或者这几个信息。

这 3 个方法之间无关联，所以可以采用异步的方式并行获取，提升效率。

下面是商品服务，内部 3 个方法都需要异步，所以直接在类上使用`@Async`标注了，每个方法内部休眠 500 毫秒，模拟一下耗时操作。

```
package com.javacode2018.async.demo2;

import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

@Async
@Component
public class GoodsService {
    //模拟获取商品基本信息，内部耗时500毫秒
    public Future<String> getGoodsInfo(long goodsId) throws InterruptedException {
        TimeUnit.MILLISECONDS.sleep(500);
        return AsyncResult.forValue(String.format("商品%s基本信息!", goodsId));
    }

    //模拟获取商品描述信息，内部耗时500毫秒
    public Future<String> getGoodsDesc(long goodsId) throws InterruptedException {
        TimeUnit.MILLISECONDS.sleep(500);
        return AsyncResult.forValue(String.format("商品%s描述信息!", goodsId));
    }

    //模拟获取商品评论信息列表，内部耗时500毫秒
    public Future<List<String>> getGoodsComments(long goodsId) throws InterruptedException {
        TimeUnit.MILLISECONDS.sleep(500);
        List<String> comments = Arrays.asList("评论1", "评论2");
        return AsyncResult.forValue(comments);
    }
}


```

来个 spring 配置类，需要加上`@EnableAsync`开启 bean 方法的异步调用.

```
package com.javacode2018.async.demo2;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableAsync;

@ComponentScan
@EnableAsync
public class MainConfig2 {
}


```

测试代码

```
@Test
public void test2() throws InterruptedException, ExecutionException {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig2.class);
    context.refresh();
    GoodsService goodsService = context.getBean(GoodsService.class);

    long starTime = System.currentTimeMillis();
    System.out.println("开始获取商品的各种信息");

    long goodsId = 1L;
    Future<String> goodsInfoFuture = goodsService.getGoodsInfo(goodsId);
    Future<String> goodsDescFuture = goodsService.getGoodsDesc(goodsId);
    Future<List<String>> goodsCommentsFuture = goodsService.getGoodsComments(goodsId);

    System.out.println(goodsInfoFuture.get());
    System.out.println(goodsDescFuture.get());
    System.out.println(goodsCommentsFuture.get());

    System.out.println("商品信息获取完毕,总耗时(ms)：" + (System.currentTimeMillis() - starTime));

    //休眠一下，防止@Test退出
    TimeUnit.SECONDS.sleep(3);
}


```

运行输出

```
开始获取商品的各种信息
商品1基本信息!
商品1描述信息!
[评论1, 评论2]
商品信息获取完毕,总耗时(ms)：525


```

3 个方法总计耗时 500 毫秒左右。

如果不采用异步的方式，3 个方法会同步执行，耗时差不多 1.5 秒，来试试，将`GoodsService`上的`@Async`去掉，然后再次执行测试案例，输出

```
开始获取商品的各种信息
商品1基本信息!
商品1描述信息!
[评论1, 评论2]
商品信息获取完毕,总耗时(ms)：1503


```

这个案例大家可以借鉴一下，**按照这个思路可以去优化一下你们的代码，方法之间无关联的可以采用异步的方式，并行去获取，最终耗时为最长的那个方法，整体相对于同步的方式性能提升不少。**

6、自定义异步执行的线程池
-------------

默认情况下，`@EnableAsync`使用内置的线程池来异步调用方法，不过我们也可以自定义异步执行任务的线程池。

### 有 2 种方式来自定义异步处理的线程池

#### 方式 1

**在 spring 容器中定义一个线程池类型的 bean，bean 名称必须是 taskExecutor**

```
@Bean
public Executor taskExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
    executor.setCorePoolSize(10);
    executor.setMaxPoolSize(100);
    executor.setThreadNamePrefix("my-thread-");
    return executor;
}


```

#### 方式 2

定义一个 bean，实现`AsyncConfigurer接口中的getAsyncExecutor方法`，这个方法需要返回自定义的线程池，案例代码：

```
package com.javacode2018.async.demo3;

import com.javacode2018.async.demo1.LogService;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.lang.Nullable;
import org.springframework.scheduling.annotation.AsyncConfigurer;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

@EnableAsync
public class MainConfig3 {

    @Bean
    public LogService logService() {
        return new LogService();
    }

    /**
     * 定义一个AsyncConfigurer类型的bean，实现getAsyncExecutor方法，返回自定义的线程池
     *
     * @param executor
     * @return
     */
    @Bean
    public AsyncConfigurer asyncConfigurer(@Qualifier("logExecutors") Executor executor) {
        return new AsyncConfigurer() {
            @Nullable
            @Override
            public Executor getAsyncExecutor() {
                return executor;
            }
        };
    }

    /**
     * 定义一个线程池，用来异步处理日志方法调用
     *
     * @return
     */
    @Bean
    public Executor logExecutors() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(10);
        executor.setMaxPoolSize(100);
        //线程名称前缀
        executor.setThreadNamePrefix("log-thread-"); //@1
        return executor;
    }

}


```

`@1`自定义的线程池中线程名称前缀为`log-thread-`，运行下面测试代码

```
@Test
public void test3() throws InterruptedException {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig3.class);
    context.refresh();
    LogService logService = context.getBean(LogService.class);
    System.out.println(Thread.currentThread() + " logService.log start," + System.currentTimeMillis());
    logService.log("异步执行方法!");
    System.out.println(Thread.currentThread() + " logService.log end," + System.currentTimeMillis());

    //休眠一下，防止@Test退出
    TimeUnit.SECONDS.sleep(3);
}


```

输出

```
Thread[main,5,main] logService.log start,1595228732914
Thread[main,5,main] logService.log end,1595228732921
Thread[log-thread-1,5,main]开始记录日志,1595228732930
Thread[log-thread-1,5,main]日志记录完毕,1595228734931


```

最后 2 行日志中线程名称是`log-thread-`，正是我们自定义线程池中的线程。

7、自定义异常处理
---------

异步方法若发生了异常，我们如何获取异常信息呢？此时可以通过自定义异常处理来解决。

### 异常处理分 2 种情况

1.  当返回值是 Future 的时候，方法内部有异常的时候，异常会向外抛出，可以对 Future.get 采用 try..catch 来捕获异常
    
2.  当返回值不是 Future 的时候，可以自定义一个 bean，实现 AsyncConfigurer 接口中的 getAsyncUncaughtExceptionHandler 方法，返回自定义的异常处理器
    

### 情况 1：返回值为 Future 类型

#### 用法

通过 try..catch 来捕获异常，如下

```
try {
    Future<String> future = logService.mockException();
    System.out.println(future.get());
} catch (ExecutionException e) {
    System.out.println("捕获 ExecutionException 异常");
    //通过e.getCause获取实际的异常信息
    e.getCause().printStackTrace();
} catch (InterruptedException e) {
    e.printStackTrace();
}


```

#### 案例

LogService 中添加一个方法，返回值为 Future，内部抛出一个异常，如下：

```
@Async
public Future<String> mockException() {
    //模拟抛出一个异常
    throw new IllegalArgumentException("参数有误!");
}


```

测试代码如下

```
@Test
public void test5() throws InterruptedException {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig1.class);
    context.refresh();
    LogService logService = context.getBean(LogService.class);
    try {
        Future<String> future = logService.mockException();
        System.out.println(future.get());
    } catch (ExecutionException e) {
        System.out.println("捕获 ExecutionException 异常");
        //通过e.getCause获取实际的异常信息
        e.getCause().printStackTrace();
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
    //休眠一下，防止@Test退出
    TimeUnit.SECONDS.sleep(3);
}


```

运行输出

```
java.lang.IllegalArgumentException: 参数有误!
捕获 ExecutionException 异常
 at com.javacode2018.async.demo1.LogService.mockException(LogService.java:23)
 at com.javacode2018.async.demo1.LogService$$FastClassBySpringCGLIB$$32a28430.invoke(<generated>)
 at org.springframework.cglib.proxy.MethodProxy.invoke(MethodProxy.java:218)


```

### 情况 2：无返回值异常处理

#### 用法

当返回值不是 Future 的时候，可以自定义一个 bean，实现`AsyncConfigurer接口中的getAsyncUncaughtExceptionHandler方法`，返回自定义的异常处理器，当目标方法执行过程中抛出异常的时候，此时会自动回调`AsyncUncaughtExceptionHandler#handleUncaughtException`这个方法，可以在这个方法中处理异常，如下：

```
@Bean
public AsyncConfigurer asyncConfigurer() {
    return new AsyncConfigurer() {
        @Nullable
        @Override
        public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
            return new AsyncUncaughtExceptionHandler() {
                @Override
                public void handleUncaughtException(Throwable ex, Method method, Object... params) {
                    //当目标方法执行过程中抛出异常的时候，此时会自动回调这个方法，可以在这个方法中处理异常
                }
            };
        }
    };
}


```

#### 案例

LogService 中添加一个方法，内部抛出一个异常，如下：

```
@Async
public void mockNoReturnException() {
    //模拟抛出一个异常
    throw new IllegalArgumentException("无返回值的异常!");
}


```

来个 spring 配置类，通过`AsyncConfigurer`来自定义异常处理器`AsyncUncaughtExceptionHandler`

```
package com.javacode2018.async.demo4;

import com.javacode2018.async.demo1.LogService;
import org.springframework.aop.interceptor.AsyncUncaughtExceptionHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.lang.Nullable;
import org.springframework.scheduling.annotation.AsyncConfigurer;
import org.springframework.scheduling.annotation.EnableAsync;

import java.lang.reflect.Method;
import java.util.Arrays;

@EnableAsync
public class MainConfig4 {

    @Bean
    public LogService logService() {
        return new LogService();
    }

    @Bean
    public AsyncConfigurer asyncConfigurer() {
        return new AsyncConfigurer() {
            @Nullable
            @Override
            public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
                return new AsyncUncaughtExceptionHandler() {
                    @Override
                    public void handleUncaughtException(Throwable ex, Method method, Object... params) {
                        String msg = String.format("方法[%s],参数[%s],发送异常了，异常详细信息:", method, Arrays.asList(params));
                        System.out.println(msg);
                        ex.printStackTrace();
                    }
                };
            }
        };
    }

}


```

运行输出

```
方法[public void com.javacode2018.async.demo1.LogService.mockNoReturnException()],参数[[]],发送异常了，异常详细信息:
java.lang.IllegalArgumentException: 无返回值的异常!
 at com.javacode2018.async.demo1.LogService.mockNoReturnException(LogService.java:29)
 at com.javacode2018.async.demo1.LogService$$FastClassBySpringCGLIB$$32a28430.invoke(<generated>)
 at org.springframework.cglib.proxy.MethodProxy.invoke(MethodProxy.java:218)


```

8、线程池隔离
-------

### 什么是线程池隔离？

一个系统中可能有很多业务，比如充值服务、提现服务或者其他服务，这些服务中都有一些方法需要异步执行，默认情况下他们会使用同一个线程池去执行，如果有一个业务量比较大，占用了线程池中的大量线程，此时会导致其他业务的方法无法执行，那么我们可以采用线程隔离的方式，对不同的业务使用不同的线程池，相互隔离，互不影响。

`@Async`注解有个`value`参数，用来指定线程池的 bean 名称，方法运行的时候，就会采用指定的线程池来执行目标方法。

### 使用步骤

1.  在 spring 容器中，自定义线程池相关的 bean
    
2.  @Async("线程池 bean 名称")
    

### 案例

模拟 2 个业务：异步充值、异步提现；2 个业务都采用独立的线程池来异步执行，互不影响。

##### 异步充值服务

```
package com.javacode2018.async.demo5;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

@Component
public class RechargeService {
    //模拟异步充值
    @Async(MainConfig5.RECHARGE_EXECUTORS_BEAN_NAME)
    public void recharge() {
        System.out.println(Thread.currentThread() + "模拟异步充值");
    }
}


```

##### 异步提现服务

```
package com.javacode2018.async.demo5;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

@Component
public class CashOutService {
    //模拟异步提现
    @Async(MainConfig5.CASHOUT_EXECUTORS_BEAN_NAME)
    public void cashOut() {
        System.out.println(Thread.currentThread() + "模拟异步提现");
    }
}


```

##### spring 配置类

注意`@0、@1、@2、@3、@4`这几个地方的代码，采用线程池隔离的方式，注册了 2 个线程池，分别用来处理上面的 2 个异步业务。

```
package com.javacode2018.async.demo5;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

@EnableAsync //@0：启用方法异步调用
@ComponentScan
public class MainConfig5 {

    //@1：值业务线程池bean名称
    public static final String RECHARGE_EXECUTORS_BEAN_NAME = "rechargeExecutors";
    //@2：提现业务线程池bean名称
    public static final String CASHOUT_EXECUTORS_BEAN_NAME = "cashOutExecutors";

    /**
     * @3：充值的线程池，线程名称以recharge-thread-开头
     * @return
     */
    @Bean(RECHARGE_EXECUTORS_BEAN_NAME)
    public Executor rechargeExecutors() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(10);
        executor.setMaxPoolSize(100);
        //线程名称前缀
        executor.setThreadNamePrefix("recharge-thread-");
        return executor;
    }

    /**
     * @4: 充值的线程池，线程名称以cashOut-thread-开头
     *
     * @return
     */
    @Bean(CASHOUT_EXECUTORS_BEAN_NAME)
    public Executor cashOutExecutors() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(10);
        executor.setMaxPoolSize(100);
        //线程名称前缀
        executor.setThreadNamePrefix("cashOut-thread-");
        return executor;
    }
}


```

##### 测试代码

```
@Test
public void test7() throws InterruptedException {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig5.class);
    context.refresh();

    RechargeService rechargeService = context.getBean(RechargeService.class);
    rechargeService.recharge();
    CashOutService cashOutService = context.getBean(CashOutService.class);
    cashOutService.cashOut();

    //休眠一下，防止@Test退出
    TimeUnit.SECONDS.sleep(3);
}


```

##### 运行输出

```
Thread[recharge-thread-1,5,main]模拟异步充值
Thread[cashOut-thread-1,5,main]模拟异步提现


```

输出中可以看出 2 个业务使用的是不同的线程池执行的。

9、源码 & 原理
---------

内部使用 aop 实现的，@EnableAsync 会引入一个 bean 后置处理器：`AsyncAnnotationBeanPostProcessor`，将其注册到 spring 容器，这个 bean 后置处理器在所有 bean 创建过程中，判断 bean 的类上是否有 @Async 注解或者类中是否有 @Async 标注的方法，如果有，会通过 aop 给这个 bean 生成代理对象，会在代理对象中添加一个切面：org.springframework.scheduling.annotation.AsyncAnnotationAdvisor，这个切面中会引入一个拦截器：AnnotationAsyncExecutionInterceptor，方法异步调用的关键代码就是在这个拦截器的 invoke 方法中实现的，可以去看一下。

10、总结
-----

](img/@EnableAsync & @Async.png)

11、案例源码
-------

```
https://gitee.com/javacode2018/spring-series


```

**路人甲 java 所有案例代码以后都会放到这个上面，大家 watch 一下，可以持续关注动态。**

12、Spring 系列
------------

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
    

13、更多好文章
--------

1.  [Java 高并发系列（共 34 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933285&idx=1&sn=f5507c251b84c3405f2fe0f7fb1da97d&chksm=88621b9bbf15928dd4c26f52b2abb0e130cde02100c432f33f0e90123b5e4b20d43017c1030e&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [MySql 高手系列（共 27 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933461&idx=1&sn=67cd31469273b68a258d963e53b56325&chksm=88621c6bbf15957d7308d81cd8ba1761b356222f4c6df75723aee99c265bd94cc869faba291c&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Maven 高手系列（共 10 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933753&idx=1&sn=0b41083939980be87a61c4f573792459&chksm=88621d47bf1594516092b662c545abfac299d296e232bf25e9f50be97e002e2698ea78218828&scene=21#wechat_redirect)
    
4.  [Mybatis 系列（共 12 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933868&idx=1&sn=ed16ef4afcbfcb3423a261422ff6934e&chksm=88621dd2bf1594c4baa21b7adc47456e5f535c3358cd11ddafb1c80742864bb19d7ccc62756c&token=1400407286&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [聊聊 db 和缓存一致性常见的实现方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933452&idx=1&sn=48b3b1cbd27c50186122fef8943eca5f&chksm=88621c72bf159564e629ee77d180424274ae9effd8a7c2997f853135b28f3401970793d8098d&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [接口幂等性这么重要，它是什么？怎么实现？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933334&idx=1&sn=3a68da36e4e21b7339418e40ab9b6064&chksm=88621be8bf1592fe5301aab732fbed8d1747475f4221da341350e0cc9935225d41bf79375d43&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [泛型，有点难度，会让很多人懵逼，那是因为你没有看这篇文章！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933878&idx=1&sn=bebd543c39d02455456680ff12e3934b&chksm=88621dc8bf1594de6b50a760e4141b80da76442ba38fb93a91a3d18ecf85e7eee368f2c159d3&token=799820369&lang=zh_CN&scene=21#wechat_redirect)
    

世界上最好的关系是相互成就，点赞转发 感恩开心😃

路人甲 java  

![](https://mmbiz.qpic.cn/mmbiz_png/9Xne6pfLaexiaK8h8pVuFJibShbdbS0QEE9V2UuWiakgeMWbXLgrrT114RwXKZfEJicvtz3jsUslfVhpOGZS62mQvg/640?wx_fmt=png)

▲长按图片识别二维码关注

路人甲 Java：工作 10 年的前阿里 P7，所有文章以系列的方式呈现，带领大家成为 java 高手，目前已出：java 高并发系列、mysql 高手系列、Maven 高手系列、mybatis 系列、spring 系列，正在连载 springcloud 系列，欢迎关注！