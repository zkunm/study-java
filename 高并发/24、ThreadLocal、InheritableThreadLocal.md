> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933186&idx=1&sn=079567e8799e43cb734b833c44055c01&chksm=88621b7cbf15926aace88777445822314d6eed2c1f5559b36cb6a6e181f0e543ee14d832ebc2&token=1963100670&lang=zh_CN&scene=21#wechat_redirect)

java 高并发系列第 24 篇文章。

环境：jdk1.8。

本文内容
----

1.  需要解决的问题
    
2.  介绍 ThreadLocal
    
3.  介绍 InheritableThreadLocal
    

需要解决的问题
-------

> 我们还是以解决问题的方式来引出`ThreadLocal`、`InheritableThreadLocal`，这样印象会深刻一些。

目前 java 开发 web 系统一般有 3 层，controller、service、dao，请求到达 controller，controller 调用 service，service 调用 dao，然后进行处理。

我们写一个简单的例子，有 3 个方法分别模拟 controller、service、dao。代码如下：

```
package com.itsoku.chat24;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo1 {

    static AtomicInteger threadIndex = new AtomicInteger(1);
    //创建处理请求的线程池子
    static ThreadPoolExecutor disposeRequestExecutor = new ThreadPoolExecutor(3,
            3,
            60,
            TimeUnit.SECONDS,
            new LinkedBlockingDeque<>(),
            r -> {
                Thread thread = new Thread(r);
                thread.setName("disposeRequestThread-" + threadIndex.getAndIncrement());
                return thread;
            });

    //记录日志
    public static void log(String msg) {
        StackTraceElement stack[] = (new Throwable()).getStackTrace();
        System.out.println("****" + System.currentTimeMillis() + ",[线程:" + Thread.currentThread().getName() + "]," + stack[1] + ":" + msg);
    }

    //模拟controller
    public static void controller(List<String> dataList) {
        log("接受请求");
        service(dataList);
    }

    //模拟service
    public static void service(List<String> dataList) {
        log("执行业务");
        dao(dataList);
    }

    //模拟dao
    public static void dao(List<String> dataList) {
        log("执行数据库操作");
        //模拟插入数据
        for (String s : dataList) {
            log("插入数据" + s + "成功");
        }
    }

    public static void main(String[] args) {
        //需要插入的数据
        List<String> dataList = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            dataList.add("数据" + i);
        }

        //模拟5个请求
        int requestCount = 5;
        for (int i = 0; i < requestCount; i++) {
            disposeRequestExecutor.execute(() -> {
                controller(dataList);
            });
        }

        disposeRequestExecutor.shutdown();
    }
}


```

运行结果：

```
****1565338891286,[线程:disposeRequestThread-2],com.itsoku.chat24.Demo1.controller(Demo1.java:36):接受请求
****1565338891286,[线程:disposeRequestThread-1],com.itsoku.chat24.Demo1.controller(Demo1.java:36):接受请求
****1565338891287,[线程:disposeRequestThread-2],com.itsoku.chat24.Demo1.service(Demo1.java:42):执行业务
****1565338891287,[线程:disposeRequestThread-1],com.itsoku.chat24.Demo1.service(Demo1.java:42):执行业务
****1565338891287,[线程:disposeRequestThread-3],com.itsoku.chat24.Demo1.controller(Demo1.java:36):接受请求
****1565338891287,[线程:disposeRequestThread-1],com.itsoku.chat24.Demo1.dao(Demo1.java:48):执行数据库操作
****1565338891287,[线程:disposeRequestThread-1],com.itsoku.chat24.Demo1.dao(Demo1.java:51):插入数据数据0成功
****1565338891287,[线程:disposeRequestThread-1],com.itsoku.chat24.Demo1.dao(Demo1.java:51):插入数据数据1成功
****1565338891287,[线程:disposeRequestThread-2],com.itsoku.chat24.Demo1.dao(Demo1.java:48):执行数据库操作
****1565338891287,[线程:disposeRequestThread-1],com.itsoku.chat24.Demo1.dao(Demo1.java:51):插入数据数据2成功
****1565338891287,[线程:disposeRequestThread-3],com.itsoku.chat24.Demo1.service(Demo1.java:42):执行业务
****1565338891288,[线程:disposeRequestThread-1],com.itsoku.chat24.Demo1.controller(Demo1.java:36):接受请求
****1565338891287,[线程:disposeRequestThread-2],com.itsoku.chat24.Demo1.dao(Demo1.java:51):插入数据数据0成功
****1565338891288,[线程:disposeRequestThread-1],com.itsoku.chat24.Demo1.service(Demo1.java:42):执行业务
****1565338891288,[线程:disposeRequestThread-3],com.itsoku.chat24.Demo1.dao(Demo1.java:48):执行数据库操作
****1565338891288,[线程:disposeRequestThread-1],com.itsoku.chat24.Demo1.dao(Demo1.java:48):执行数据库操作
****1565338891288,[线程:disposeRequestThread-2],com.itsoku.chat24.Demo1.dao(Demo1.java:51):插入数据数据1成功
****1565338891288,[线程:disposeRequestThread-1],com.itsoku.chat24.Demo1.dao(Demo1.java:51):插入数据数据0成功
****1565338891288,[线程:disposeRequestThread-3],com.itsoku.chat24.Demo1.dao(Demo1.java:51):插入数据数据0成功
****1565338891288,[线程:disposeRequestThread-1],com.itsoku.chat24.Demo1.dao(Demo1.java:51):插入数据数据1成功
****1565338891288,[线程:disposeRequestThread-2],com.itsoku.chat24.Demo1.dao(Demo1.java:51):插入数据数据2成功


```

代码中调用 controller、service、dao 3 个方法时，来模拟处理一个请求。main 方法中循环了 5 次模拟发起 5 次请求，然后交给线程池去处理请求，dao 中模拟循环插入传入的 dataList 数据。

**问题来了：开发者想看一下哪些地方耗时比较多，想通过日志来分析耗时情况，想追踪某个请求的完整日志，怎么搞？**

上面的请求采用线程池的方式处理的，多个请求可能会被一个线程处理，通过日志很难看出那些日志是同一个请求，我们能不能给请求加一个唯一标志，日志中输出这个唯一标志，当然可以。

如果我们的代码就只有上面示例这么简单，我想还是很容易的，上面就 3 个方法，给每个方法加个 traceId 参数，log 方法也加个 traceId 参数，就解决了，代码如下：

```
package com.itsoku.chat24;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo2 {

    static AtomicInteger threadIndex = new AtomicInteger(1);
    //创建处理请求的线程池子
    static ThreadPoolExecutor disposeRequestExecutor = new ThreadPoolExecutor(3,
            3,
            60,
            TimeUnit.SECONDS,
            new LinkedBlockingDeque<>(),
            r -> {
                Thread thread = new Thread(r);
                thread.setName("disposeRequestThread-" + threadIndex.getAndIncrement());
                return thread;
            });

    //记录日志
    public static void log(String msg, String traceId) {
        StackTraceElement stack[] = (new Throwable()).getStackTrace();
        System.out.println("****" + System.currentTimeMillis() + "[traceId:" + traceId + "],[线程:" + Thread.currentThread().getName() + "]," + stack[1] + ":" + msg);
    }

    //模拟controller
    public static void controller(List<String> dataList, String traceId) {
        log("接受请求", traceId);
        service(dataList, traceId);
    }

    //模拟service
    public static void service(List<String> dataList, String traceId) {
        log("执行业务", traceId);
        dao(dataList, traceId);
    }

    //模拟dao
    public static void dao(List<String> dataList, String traceId) {
        log("执行数据库操作", traceId);
        //模拟插入数据
        for (String s : dataList) {
            log("插入数据" + s + "成功", traceId);
        }
    }

    public static void main(String[] args) {
        //需要插入的数据
        List<String> dataList = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            dataList.add("数据" + i);
        }

        //模拟5个请求
        int requestCount = 5;
        for (int i = 0; i < requestCount; i++) {
            String traceId = String.valueOf(i);
            disposeRequestExecutor.execute(() -> {
                controller(dataList, traceId);
            });
        }

        disposeRequestExecutor.shutdown();
    }
}


```

输出：

```
****1565339559773[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo2.controller(Demo2.java:36):接受请求
****1565339559773[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo2.controller(Demo2.java:36):接受请求
****1565339559773[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo2.controller(Demo2.java:36):接受请求
****1565339559774[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo2.service(Demo2.java:42):执行业务
****1565339559774[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo2.service(Demo2.java:42):执行业务
****1565339559774[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo2.dao(Demo2.java:48):执行数据库操作
****1565339559774[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo2.service(Demo2.java:42):执行业务
****1565339559774[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo2.dao(Demo2.java:51):插入数据数据0成功
****1565339559774[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo2.dao(Demo2.java:48):执行数据库操作
****1565339559774[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo2.dao(Demo2.java:51):插入数据数据1成功
****1565339559774[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo2.dao(Demo2.java:48):执行数据库操作
****1565339559774[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo2.dao(Demo2.java:51):插入数据数据2成功
****1565339559774[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo2.dao(Demo2.java:51):插入数据数据0成功
****1565339559775[traceId:3],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo2.controller(Demo2.java:36):接受请求
****1565339559775[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo2.dao(Demo2.java:51):插入数据数据0成功
****1565339559775[traceId:3],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo2.service(Demo2.java:42):执行业务
****1565339559775[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo2.dao(Demo2.java:51):插入数据数据1成功
****1565339559775[traceId:3],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo2.dao(Demo2.java:48):执行数据库操作
****1565339559775[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo2.dao(Demo2.java:51):插入数据数据1成功
****1565339559775[traceId:3],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo2.dao(Demo2.java:51):插入数据数据0成功


```

上面我们通过修改代码的方式，把问题解决了，但前提是你们的系统都像上面这么简单，功能很少，需要改的代码很少，可以这么去改。但事与愿违，我们的系统一般功能都是比较多的，如果我们都一个个去改，岂不是要疯掉，改代码还涉及到重新测试，风险也不可控。那有什么好办法么？

ThreadLocal
-----------

还是拿上面的问题，我们来分析一下，每个请求都是由一个线程处理的，线程就相当于一个人一样，每个请求相当于一个任务，任务来了，人来处理，处理完毕之后，再处理下一个请求任务。人身上是不是有很多口袋，人刚开始准备处理任务的时候，我们把任务的编号放在处理者的口袋中，然后处理中一路携带者，处理过程中如果需要用到这个编号，直接从口袋中获取就可以了。那么刚好 java 中线程设计的时候也考虑到了这些问题，Thread 对象中就有很多口袋，用来放东西。Thread 类中有这么一个变量：

```
ThreadLocal.ThreadLocalMap threadLocals = null;


```

这个就是用来操作 Thread 中所有口袋的东西，`ThreadLocalMap`源码中有一个数组（有兴趣的可以去看一下源码），对应处理者身上很多口袋一样，数组中的每个元素对应一个口袋。

如何来操作 Thread 中的这些口袋呢，java 为我们提供了一个类`ThreadLocal`，ThreadLocal 对象用来操作 Thread 中的某一个口袋，可以向这个口袋中放东西、获取里面的东西、清除里面的东西，这个口袋一次性只能放一个东西，重复放东西会将里面已经存在的东西覆盖掉。

常用的 3 个方法：

```
//向Thread中某个口袋中放东西
public void set(T value);
//获取这个口袋中目前放的东西
public T get();
//清空这个口袋中放的东西
public void remove()


```

我们使用 ThreadLocal 来改造一下上面的代码，如下：

```
package com.itsoku.chat24;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo3 {

    //创建一个操作Thread中存放请求任务追踪id口袋的对象
    static ThreadLocal<String> traceIdKD = new ThreadLocal<>();

    static AtomicInteger threadIndex = new AtomicInteger(1);
    //创建处理请求的线程池子
    static ThreadPoolExecutor disposeRequestExecutor = new ThreadPoolExecutor(3,
            3,
            60,
            TimeUnit.SECONDS,
            new LinkedBlockingDeque<>(),
            r -> {
                Thread thread = new Thread(r);
                thread.setName("disposeRequestThread-" + threadIndex.getAndIncrement());
                return thread;
            });

    //记录日志
    public static void log(String msg) {
        StackTraceElement stack[] = (new Throwable()).getStackTrace();
        //获取当前线程存放tranceId口袋中的内容
        String traceId = traceIdKD.get();
        System.out.println("****" + System.currentTimeMillis() + "[traceId:" + traceId + "],[线程:" + Thread.currentThread().getName() + "]," + stack[1] + ":" + msg);
    }

    //模拟controller
    public static void controller(List<String> dataList) {
        log("接受请求");
        service(dataList);
    }

    //模拟service
    public static void service(List<String> dataList) {
        log("执行业务");
        dao(dataList);
    }

    //模拟dao
    public static void dao(List<String> dataList) {
        log("执行数据库操作");
        //模拟插入数据
        for (String s : dataList) {
            log("插入数据" + s + "成功");
        }
    }

    public static void main(String[] args) {
        //需要插入的数据
        List<String> dataList = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            dataList.add("数据" + i);
        }

        //模拟5个请求
        int requestCount = 5;
        for (int i = 0; i < requestCount; i++) {
            String traceId = String.valueOf(i);
            disposeRequestExecutor.execute(() -> {
                //把traceId放入口袋中
                traceIdKD.set(traceId);
                try {
                    controller(dataList);
                } finally {
                    //将tranceId从口袋中移除
                    traceIdKD.remove();
                }
            });
        }

        disposeRequestExecutor.shutdown();
    }
}


```

输出：

```
****1565339644214[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo3.controller(Demo3.java:41):接受请求
****1565339644214[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.controller(Demo3.java:41):接受请求
****1565339644214[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.controller(Demo3.java:41):接受请求
****1565339644214[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.service(Demo3.java:47):执行业务
****1565339644214[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo3.service(Demo3.java:47):执行业务
****1565339644214[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.dao(Demo3.java:53):执行数据库操作
****1565339644214[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.service(Demo3.java:47):执行业务
****1565339644214[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据0成功
****1565339644214[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.dao(Demo3.java:53):执行数据库操作
****1565339644214[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo3.dao(Demo3.java:53):执行数据库操作
****1565339644215[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据0成功
****1565339644215[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据1成功
****1565339644215[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据1成功
****1565339644215[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据0成功
****1565339644215[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据2成功
****1565339644215[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据2成功
****1565339644215[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据1成功
****1565339644215[traceId:4],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.controller(Demo3.java:41):接受请求
****1565339644215[traceId:3],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.controller(Demo3.java:41):接受请求
****1565339644215[traceId:4],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.service(Demo3.java:47):执行业务
****1565339644215[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据2成功
****1565339644215[traceId:4],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.dao(Demo3.java:53):执行数据库操作
****1565339644215[traceId:3],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.service(Demo3.java:47):执行业务
****1565339644215[traceId:4],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据0成功
****1565339644215[traceId:3],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.dao(Demo3.java:53):执行数据库操作
****1565339644215[traceId:4],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据1成功
****1565339644215[traceId:3],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据0成功
****1565339644215[traceId:4],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据2成功
****1565339644215[traceId:3],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据1成功
****1565339644215[traceId:3],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo3.dao(Demo3.java:56):插入数据数据2成功


```

可以看出输出和刚才使用 traceId 参数的方式结果一致，但是却简单了很多。不用去修改 controller、service、dao 代码了，风险也减少了很多。

代码中创建了一个`ThreadLocal traceIdKD`，这个对象用来操作 Thread 中一个口袋，用这个口袋来存放 tranceId。在 main 方法中通过`traceIdKD.set(traceId)`方法将 traceId 放入口袋，log 方法中通`traceIdKD.get()`获取口袋中的 traceId，最后任务处理完之后，main 中的 finally 中调用`traceIdKD.remove();`将口袋中的 traceId 清除。

**ThreadLocal 的官方 API 解释为：**

> “该类提供了线程局部 (thread-local) 变量。这些变量不同于它们的普通对应物，因为访问某个变量（通过其 get 或 set 方法）的每个线程都有自己的局部变量，它独立于变量的初始化副本。ThreadLocal 实例通常是类中的 private static 字段，它们希望将状态与某一个线程（例如，用户 ID 或事务 ID）相关联。”

InheritableThreadLocal
----------------------

继续上面的实例，dao 中循环处理 dataList 的内容，假如 dataList 处理比较耗时，我们想加快处理速度有什么办法么？大家已经想到了，用多线程并行处理`dataList`，那么我们把代码改一下，如下：

```
package com.itsoku.chat24;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo4 {

    //创建一个操作Thread中存放请求任务追踪id口袋的对象
    static ThreadLocal<String> traceIdKD = new ThreadLocal<>();

    static AtomicInteger threadIndex = new AtomicInteger(1);
    //创建处理请求的线程池子
    static ThreadPoolExecutor disposeRequestExecutor = new ThreadPoolExecutor(3,
            3,
            60,
            TimeUnit.SECONDS,
            new LinkedBlockingDeque<>(),
            r -> {
                Thread thread = new Thread(r);
                thread.setName("disposeRequestThread-" + threadIndex.getAndIncrement());
                return thread;
            });

    //记录日志
    public static void log(String msg) {
        StackTraceElement stack[] = (new Throwable()).getStackTrace();
        //获取当前线程存放tranceId口袋中的内容
        String traceId = traceIdKD.get();
        System.out.println("****" + System.currentTimeMillis() + "[traceId:" + traceId + "],[线程:" + Thread.currentThread().getName() + "]," + stack[1] + ":" + msg);
    }

    //模拟controller
    public static void controller(List<String> dataList) {
        log("接受请求");
        service(dataList);
    }

    //模拟service
    public static void service(List<String> dataList) {
        log("执行业务");
        dao(dataList);
    }

    //模拟dao
    public static void dao(List<String> dataList) {
        CountDownLatch countDownLatch = new CountDownLatch(dataList.size());

        log("执行数据库操作");
        String threadName = Thread.currentThread().getName();
        //模拟插入数据
        for (String s : dataList) {
            new Thread(() -> {
                try {
                    //模拟数据库操作耗时100毫秒
                    TimeUnit.MILLISECONDS.sleep(100);
                    log("插入数据" + s + "成功,主线程：" + threadName);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
                    countDownLatch.countDown();
                }
            }).start();
        }
        //等待上面的dataList处理完毕
        try {
            countDownLatch.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        //需要插入的数据
        List<String> dataList = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            dataList.add("数据" + i);
        }

        //模拟5个请求
        int requestCount = 5;
        for (int i = 0; i < requestCount; i++) {
            String traceId = String.valueOf(i);
            disposeRequestExecutor.execute(() -> {
                //把traceId放入口袋中
                traceIdKD.set(traceId);
                try {
                    controller(dataList);
                } finally {
                    //将tranceId从口袋中移除
                    traceIdKD.remove();
                }
            });
        }

        disposeRequestExecutor.shutdown();
    }
}


```

输出：

```
****1565339904279[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.controller(Demo4.java:42):接受请求
****1565339904279[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.service(Demo4.java:48):执行业务
****1565339904279[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo4.controller(Demo4.java:42):接受请求
****1565339904279[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo4.service(Demo4.java:48):执行业务
****1565339904279[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo4.controller(Demo4.java:42):接受请求
****1565339904279[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo4.service(Demo4.java:48):执行业务
****1565339904279[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.dao(Demo4.java:56):执行数据库操作
****1565339904279[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo4.dao(Demo4.java:56):执行数据库操作
****1565339904279[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo4.dao(Demo4.java:56):执行数据库操作
****1565339904281[traceId:null],[线程:Thread-3],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据0成功,主线程：disposeRequestThread-1
****1565339904281[traceId:null],[线程:Thread-5],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据0成功,主线程：disposeRequestThread-2
****1565339904281[traceId:null],[线程:Thread-4],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据0成功,主线程：disposeRequestThread-3
****1565339904281[traceId:null],[线程:Thread-6],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据1成功,主线程：disposeRequestThread-3
****1565339904281[traceId:null],[线程:Thread-9],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据2成功,主线程：disposeRequestThread-3
****1565339904282[traceId:null],[线程:Thread-8],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据1成功,主线程：disposeRequestThread-1
****1565339904282[traceId:null],[线程:Thread-10],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据2成功,主线程：disposeRequestThread-1
****1565339904282[traceId:3],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo4.controller(Demo4.java:42):接受请求
****1565339904282[traceId:null],[线程:Thread-7],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据1成功,主线程：disposeRequestThread-2
****1565339904282[traceId:null],[线程:Thread-11],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据2成功,主线程：disposeRequestThread-2
****1565339904282[traceId:3],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo4.service(Demo4.java:48):执行业务
****1565339904282[traceId:4],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.controller(Demo4.java:42):接受请求
****1565339904283[traceId:3],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo4.dao(Demo4.java:56):执行数据库操作
****1565339904283[traceId:4],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.service(Demo4.java:48):执行业务
****1565339904283[traceId:4],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.dao(Demo4.java:56):执行数据库操作
****1565339904283[traceId:null],[线程:Thread-12],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据0成功,主线程：disposeRequestThread-3
****1565339904283[traceId:null],[线程:Thread-13],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据1成功,主线程：disposeRequestThread-3
****1565339904283[traceId:null],[线程:Thread-14],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据0成功,主线程：disposeRequestThread-1
****1565339904284[traceId:null],[线程:Thread-15],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据2成功,主线程：disposeRequestThread-3
****1565339904284[traceId:null],[线程:Thread-17],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据2成功,主线程：disposeRequestThread-1
****1565339904284[traceId:null],[线程:Thread-16],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:62):插入数据数据1成功,主线程：disposeRequestThread-1


```

看一下上面的输出，有些 traceId 为 null，这是为什么呢？这是因为 dao 中为了提升处理速度，创建了子线程来并行处理，子线程调用 log 的时候，去自己的存放 traceId 的口袋中拿去东西，肯定是空的了。

那有什么办法么？可不可以这样？

父线程相当于主管，子线程相当于干活的小弟，主管让小弟们干活的时候，将自己兜里面的东西复制一份给小弟们使用，主管兜里面可能有很多牛逼的工具，为了提升小弟们的工作效率，给小弟们都复制一个，丢到小弟们的兜里，然后小弟就可以从自己的兜里拿去这些东西使用了，也可以清空自己兜里面的东西。

`Thread`对象中有个`inheritableThreadLocals`变量，代码如下：

```
ThreadLocal.ThreadLocalMap inheritableThreadLocals = null;


```

inheritableThreadLocals 相当于线程中另外一种兜，这种兜有什么特征呢，当创建子线程的时候，子线程会将父线程这种类型兜的东西全部复制一份放到自己的`inheritableThreadLocals`兜中，使用`InheritableThreadLocal`对象可以操作线程中的`inheritableThreadLocals`兜。

`InheritableThreadLocal`常用的方法也有 3 个：

```
//向Thread中某个口袋中放东西
public void set(T value);
//获取这个口袋中目前放的东西
public T get();
//清空这个口袋中放的东西
public void remove()


```

使用`InheritableThreadLocal`解决上面子线程中无法输出 traceId 的问题，只需要将上一个示例代码中的`ThreadLocal`替换成`InheritableThreadLocal`即可，代码如下：

```
package com.itsoku.chat24;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo4 {

    //创建一个操作Thread中存放请求任务追踪id口袋的对象,子线程可以继承父线程中内容
    static InheritableThreadLocal<String> traceIdKD = new InheritableThreadLocal<>();

    static AtomicInteger threadIndex = new AtomicInteger(1);
    //创建处理请求的线程池子
    static ThreadPoolExecutor disposeRequestExecutor = new ThreadPoolExecutor(3,
            3,
            60,
            TimeUnit.SECONDS,
            new LinkedBlockingDeque<>(),
            r -> {
                Thread thread = new Thread(r);
                thread.setName("disposeRequestThread-" + threadIndex.getAndIncrement());
                return thread;
            });

    //记录日志
    public static void log(String msg) {
        StackTraceElement stack[] = (new Throwable()).getStackTrace();
        //获取当前线程存放tranceId口袋中的内容
        String traceId = traceIdKD.get();
        System.out.println("****" + System.currentTimeMillis() + "[traceId:" + traceId + "],[线程:" + Thread.currentThread().getName() + "]," + stack[1] + ":" + msg);
    }

    //模拟controller
    public static void controller(List<String> dataList) {
        log("接受请求");
        service(dataList);
    }

    //模拟service
    public static void service(List<String> dataList) {
        log("执行业务");
        dao(dataList);
    }

    //模拟dao
    public static void dao(List<String> dataList) {
        CountDownLatch countDownLatch = new CountDownLatch(dataList.size());

        log("执行数据库操作");
        String threadName = Thread.currentThread().getName();
        //模拟插入数据
        for (String s : dataList) {
            new Thread(() -> {
                try {
                    //模拟数据库操作耗时100毫秒
                    TimeUnit.MILLISECONDS.sleep(100);
                    log("插入数据" + s + "成功,主线程：" + threadName);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
                    countDownLatch.countDown();
                }
            }).start();
        }
        //等待上面的dataList处理完毕
        try {
            countDownLatch.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        //需要插入的数据
        List<String> dataList = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            dataList.add("数据" + i);
        }

        //模拟5个请求
        int requestCount = 5;
        for (int i = 0; i < requestCount; i++) {
            String traceId = String.valueOf(i);
            disposeRequestExecutor.execute(() -> {
                //把traceId放入口袋中
                traceIdKD.set(traceId);
                try {
                    controller(dataList);
                } finally {
                    //将tranceId从口袋中移除
                    traceIdKD.remove();
                }
            });
        }

        disposeRequestExecutor.shutdown();
    }
}


```

输出：

```
****1565341611454[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo4.controller(Demo4.java:42):接受请求
****1565341611454[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo4.controller(Demo4.java:42):接受请求
****1565341611454[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.controller(Demo4.java:42):接受请求
****1565341611454[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo4.service(Demo4.java:48):执行业务
****1565341611454[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo4.service(Demo4.java:48):执行业务
****1565341611454[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.service(Demo4.java:48):执行业务
****1565341611454[traceId:2],[线程:disposeRequestThread-3],com.itsoku.chat24.Demo4.dao(Demo4.java:56):执行数据库操作
****1565341611454[traceId:1],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo4.dao(Demo4.java:56):执行数据库操作
****1565341611454[traceId:0],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.dao(Demo4.java:56):执行数据库操作
****1565341611557[traceId:2],[线程:Thread-5],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据0成功,主线程：disposeRequestThread-3
****1565341611557[traceId:0],[线程:Thread-4],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据0成功,主线程：disposeRequestThread-1
****1565341611557[traceId:1],[线程:Thread-11],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据2成功,主线程：disposeRequestThread-2
****1565341611557[traceId:1],[线程:Thread-3],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据0成功,主线程：disposeRequestThread-2
****1565341611557[traceId:1],[线程:Thread-8],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据1成功,主线程：disposeRequestThread-2
****1565341611557[traceId:0],[线程:Thread-6],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据1成功,主线程：disposeRequestThread-1
****1565341611557[traceId:0],[线程:Thread-10],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据2成功,主线程：disposeRequestThread-1
****1565341611557[traceId:3],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo4.controller(Demo4.java:42):接受请求
****1565341611557[traceId:2],[线程:Thread-9],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据2成功,主线程：disposeRequestThread-3
****1565341611558[traceId:2],[线程:Thread-7],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据1成功,主线程：disposeRequestThread-3
****1565341611557[traceId:3],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo4.service(Demo4.java:48):执行业务
****1565341611557[traceId:4],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.controller(Demo4.java:42):接受请求
****1565341611558[traceId:3],[线程:disposeRequestThread-2],com.itsoku.chat24.Demo4.dao(Demo4.java:56):执行数据库操作
****1565341611558[traceId:4],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.service(Demo4.java:48):执行业务
****1565341611558[traceId:4],[线程:disposeRequestThread-1],com.itsoku.chat24.Demo4.dao(Demo4.java:56):执行数据库操作
****1565341611659[traceId:3],[线程:Thread-15],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据2成功,主线程：disposeRequestThread-2
****1565341611659[traceId:4],[线程:Thread-14],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据0成功,主线程：disposeRequestThread-1
****1565341611659[traceId:3],[线程:Thread-13],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据1成功,主线程：disposeRequestThread-2
****1565341611659[traceId:3],[线程:Thread-12],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据0成功,主线程：disposeRequestThread-2
****1565341611660[traceId:4],[线程:Thread-16],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据1成功,主线程：disposeRequestThread-1
****1565341611660[traceId:4],[线程:Thread-17],com.itsoku.chat24.Demo4.lambda$dao$1(Demo4.java:64):插入数据数据2成功,主线程：disposeRequestThread-1


```

输出中都有 traceId 了，和期望的结果一致。

希望通过这篇文章可以学会使用`InheritableThreadLocal`和`InheritableThreadLocal`。有问题可以加我微信`itsoku`交流，也可以留言，谢谢。

java 高并发系列目录
------------

1.  **[第 1 天: 必须知道的几个概念](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933019&idx=1&sn=3455877c451de9c61f8391ffdc1eb01d&chksm=88621aa5bf1593b377e2f090bf37c87ba60081fb782b2371b5f875e4a6cadc3f92ff6d747e32&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
2.  **[第 2 天: 并发级别](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933024&idx=1&sn=969bfa5e2c3708e04adaf6401503c187&chksm=88621a9ebf1593886dd3f0f5923b6f929eade0b43204b98a8d0622a5f542deff4f6a633a13c8&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
3.  **[第 3 天: 有关并行的两个重要定律](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933041&idx=1&sn=82af7c702f737782118a9141858117d1&chksm=88621a8fbf159399be1d4834f6f845fa530b94a4ca7c0eaa61de508f725ad0fab74b074d73be&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
4.  **[第 4 天: JMM 相关的一些概念](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933050&idx=1&sn=497c4de99086f95bed11a4317a51e6a6&chksm=88621a84bf159392c9e3e243355313c397e0658df6b88769cdd182cb5d39b6f25686c86beffc&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
5.  **[第 5 天: 深入理解进程和线程](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933069&idx=1&sn=82105bb5b759ec8b1f3a69062a22dada&chksm=88621af3bf1593e5ece7c1da3df3b4be575271a2eaca31c784591ed0497252caa1f6a6ec0545&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
6.  **[第 6 天: 线程的基本操作](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933082&idx=1&sn=e940c4f94a8c1527b6107930eefdcd00&chksm=88621ae4bf1593f270991e6f6bac5769ea850fa02f11552d1aa91725f4512d4f1ff8f18fcdf3&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
7.  **[第 7 天: volatile 与 Java 内存模型](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933088&idx=1&sn=f1d666dd799664b1989c77441b9d12c5&chksm=88621adebf1593c83501ac33d6a0e0de075f2b2e30caf986cf276cbb1c8dff0eac2a0a648b1d&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
8.  **[第 8 天: 线程组](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933095&idx=1&sn=d32242a5ec579f45d1e9becf44bff069&chksm=88621ad9bf1593cf00b574a8e0feeffbb2c241c30b01ebf5749ccd6b7b64dcd2febbd3000581&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
9.  **[第 9 天：用户线程和守护线程](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933102&idx=1&sn=5255e94dc2649003e01bf3d61762c593&chksm=88621ad0bf1593c6905e75a82aaf6e39a0af338362366ce2860ee88c1b800e52f5c6529c089c&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
10.  **[第 10 天: 线程安全和 synchronized 关键字](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933107&idx=1&sn=6b9fbdfa180c2ca79703e0ca1b524b77&chksm=88621acdbf1593dba5fa5a0092d810004362e9f38484ffc85112a8c23ef48190c51d17e06223&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
11.  **[第 11 天: 线程中断的几种方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933111&idx=1&sn=0a3592e41e59d0ded4a60f8c1b59e82e&chksm=88621ac9bf1593df5f8342514d6750cc8a833ba438aa208cf128493981ba666a06c4037d84fb&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
12.  **[第 12 天 JUC:ReentrantLock 重入锁](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933116&idx=1&sn=83ae2d1381e3b8a425e65a9fa7888d38&chksm=88621ac2bf1593d4de1c5f6905c31c7d88ac4b53c0c5c071022ba2e25803fc734078c1de589c&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)**
    
13.  **[第 13 天: JUC 中的 Condition 对象](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933120&idx=1&sn=63ffe3ff64dcaf0418816febfd1e129a&chksm=88621b3ebf159228df5f5a501160fafa5d87412a4f03298867ec9325c0be57cd8e329f3b5ad1&token=476165288&lang=zh_CN&scene=21#wechat_redirect)**
    
14.  **[第 14 天: JUC 中的 LockSupport 工具类，必备技能](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933125&idx=1&sn=382528aeb341727bafb02bb784ff3d4f&chksm=88621b3bbf15922d93bfba11d700724f1e59ef8a74f44adb7e131a4c3d1465f0dc539297f7f3&token=1338873010&lang=zh_CN&scene=21#wechat_redirect)**
    
15.  **[第 15 天：JUC 中的 Semaphore（信号量）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933130&idx=1&sn=cecc6bd906e79a86510c1fbb0e66cd21&chksm=88621b34bf159222042da8ed4b633e94ca04a614d290d54a952a668459a339ebec0c754d562d&token=702505185&lang=zh_CN&scene=21#wechat_redirect)**
    
16.  **[第 16 天：JUC 中等待多线程完成的工具类 CountDownLatch，必备技能](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933134&idx=1&sn=65c2b9982bb6935c54ff33082f9c111f&chksm=88621b30bf159226d41607292a1dc83186f8928744dbc44acfda381266fa2cdc006177b44095&token=773938509&lang=zh_CN&scene=21#wechat_redirect)**
    
17.  **[第 17 天：JUC 中的循环栅栏 CyclicBarrier 的 6 种使用场景](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933144&idx=1&sn=7f0cddc92ff39835ea6652ebb3186dbf&chksm=88621b26bf15923039933b127c19f39a76214fb1d5daa7ad0eee77f961e2e3ab5f5ca3f48740&token=773938509&lang=zh_CN&scene=21#wechat_redirect)**
    
18.  **[第 18 天：JAVA 线程池，这一篇就够了](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933151&idx=1&sn=2020066b974b5f4c0823abd419e8adae&chksm=88621b21bf159237bdacfb47bd1a344f7123aabc25e3607e78d936dd554412edce5dd825003d&token=995072421&lang=zh_CN&scene=21#wechat_redirect)**
    
19.  **[第 19 天：JUC 中的 Executor 框架详解 1](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933156&idx=1&sn=30f7d67b44a952eae98e688bc6035fbd&chksm=88621b1abf15920c7a0705fbe34c4ce92b94b88e08f8ecbcad3827a0950cfe4d95814b61f538&token=995072421&lang=zh_CN&scene=21#wechat_redirect)**
    
20.  **[第 20 天：JUC 中的 Executor 框架详解 2](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933160&idx=1&sn=62649485b065f68c0fc59bb502ed42df&chksm=88621b16bf159200d5e25d11ab7036c60e3f923da3212ae4dd148753d02593a45ce0e9b886c4&token=42900009&lang=zh_CN&scene=21#wechat_redirect)**
    
21.  **[第 21 天：java 中的 CAS，你需要知道的东西](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933166&idx=1&sn=15e614500676170b76a329efd3255c12&chksm=88621b10bf1592064befc5c9f0d78c56cda25c6d003e1711b85e5bfeb56c9fd30d892178db87&token=1033016931&lang=zh_CN&scene=21#wechat_redirect)**
    
22.  **[第 22 天：JUC 底层工具类 Unsafe，高手必须要了解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933173&idx=1&sn=80eb550294677b0042fc030f90cce109&chksm=88621b0bbf15921d2274a7bf6afde912fec02a4c3ade9cfb50d03cdce73e07e33d08d35a3b27&token=1033016931&lang=zh_CN&scene=21#wechat_redirect)**
    
23.  **[第 23 天：JUC 中原子类，一篇就够了](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933181&idx=1&sn=a1e254365d405cdc2e3b8372ecda65ee&chksm=88621b03bf159215ca696c9f81e228d0544a7598b03fe30436babc95c6a95e848161f61b868c&token=743622661&lang=zh_CN&scene=21#wechat_redirect)**
    

**java 高并发系列连载中，总计估计会有四五十篇文章。**

**阿里 p7 一起学并发，公众号：路人甲 java，每天获取最新文章！**

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06AG3aFXEO3ibJoe3FtCsfx46XsxR5HXsftmmSibOqSndicnnF2opyib08dZPLHY0ZCnUyUoRX4biaf2zJA/640?wx_fmt=png)