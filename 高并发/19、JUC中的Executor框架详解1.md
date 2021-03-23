> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933156&idx=1&sn=30f7d67b44a952eae98e688bc6035fbd&chksm=88621b1abf15920c7a0705fbe34c4ce92b94b88e08f8ecbcad3827a0950cfe4d95814b61f538&token=995072421&lang=zh_CN&scene=21#wechat_redirect)

这是 java 高并发系列第 19 篇文章。

本文主要内容
------

1.  介绍 Executor 框架相关内容
    
2.  介绍 Executor
    
3.  介绍 ExecutorService
    
4.  介绍线程池 ThreadPoolExecutor 及案例
    
5.  介绍定时器 ScheduledExecutorService 及案例
    
6.  介绍 Excecutors 类的使用
    
7.  介绍 Future 接口
    
8.  介绍 Callable 接口
    
9.  介绍 FutureTask 的使用
    
10.  获取异步任务的执行结果的几种方法
    

### Executors 框架介绍

Executors 框架是 Doug Lea 的神作，通过这个框架，可以很容易的使用线程池高效地处理并行任务。

**Excecutor 框架主要包含 3 部分的内容：**

1.  任务相关的：包含被执行的任务要实现的接口：**Runnable** 接口或 **Callable** 接口
    
2.  任务的执行相关的：包含任务执行机制的**核心接口 Executor**，以及继承自`Executor`的`ExecutorService`接口。Executor 框架中有两个关键的类实现了 ExecutorService 接口（`ThreadPoolExecutor`和`ScheduleThreadPoolExecutor`）
    
3.  异步计算结果相关的：包含**接口 Future** 和**实现 Future 接口的 FutureTask 类**
    

**Executors 框架包括：**

*   Executor
    
*   ExecutorService
    
*   ThreadPoolExecutor
    
*   Executors
    
*   Future
    
*   Callable
    
*   FutureTask
    
*   CompletableFuture
    
*   CompletionService
    
*   ExecutorCompletionService
    

下面我们来一个个介绍其用途和使用方法。

Executor 接口
-----------

Executor 接口中定义了方法 execute(Runable able) 接口，该方法接受一个 Runable 实例，他来执行一个任务，任务即实现一个 Runable 接口的类。

ExecutorService 接口
------------------

ExecutorService 继承于 Executor 接口，他提供了更为丰富的线程实现方法，比如 ExecutorService 提供关闭自己的方法，以及为跟踪一个或多个异步任务执行状况而生成 Future 的方法。

ExecutorService 有三种状态：运行、关闭、终止。创建后便进入运行状态，当调用了 shutdown() 方法时，便进入了关闭状态，此时意味着 ExecutorService 不再接受新的任务，但是他还是会执行已经提交的任务，当所有已经提交了的任务执行完后，便达到终止状态。如果不调用 shutdown 方法，ExecutorService 方法会一直运行下去，系统一般不会主动关闭。

ThreadPoolExecutor 类
--------------------

线程池类，实现了`ExecutorService`接口中所有方法，该类也是我们经常要用到的，非常重要，关于此类有详细的介绍，可以移步：[**[玩转 java 中的线程池]**](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933151&idx=1&sn=2020066b974b5f4c0823abd419e8adae&chksm=88621b21bf159237bdacfb47bd1a344f7123aabc25e3607e78d936dd554412edce5dd825003d&scene=21#wechat_redirect)

ScheduleThreadPoolExecutor 定时器
------------------------------

ScheduleThreadPoolExecutor 继承自`ScheduleThreadPoolExecutor`，他主要用来延迟执行任务，或者定时执行任务。功能和 Timer 类似，但是 ScheduleThreadPoolExecutor 更强大、更灵活一些。Timer 后台是单个线程，而 ScheduleThreadPoolExecutor 可以在创建的时候指定多个线程。

常用方法介绍：

### schedule: 延迟执行任务 1 次

使用`ScheduleThreadPoolExecutor的schedule方法`，看一下这个方法的声明：

```
public ScheduledFuture<?> schedule(Runnable command, long delay, TimeUnit unit)


```

> 3 个参数：
> 
> command：需要执行的任务
> 
> delay：需要延迟的时间
> 
> unit：参数 2 的时间单位，是个枚举，可以是天、小时、分钟、秒、毫秒、纳秒等

**示例代码：**

```
package com.itsoku.chat18;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo1 {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        System.out.println(System.currentTimeMillis());
        ScheduledExecutorService scheduledExecutorService = Executors.newScheduledThreadPool(10);
        scheduledExecutorService.schedule(() -> {
            System.out.println(System.currentTimeMillis() + "开始执行");
            //模拟任务耗时
            try {
                TimeUnit.SECONDS.sleep(3);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(System.currentTimeMillis() + "执行结束");
        }, 2, TimeUnit.SECONDS);
    }
}


```

输出：

```
1564575180457
1564575185525开始执行
1564575188530执行结束


```

### scheduleAtFixedRate: 固定的频率执行任务

使用`ScheduleThreadPoolExecutor的scheduleAtFixedRate`方法，该方法设置了执行周期，下一次执行时间相当于是上一次的执行时间加上 period，任务每次执行完毕之后才会计算下次的执行时间。

看一下这个方法的声明：

```
public ScheduledFuture<?> scheduleAtFixedRate(Runnable command,
                                                  long initialDelay,
                                                  long period,
                                                  TimeUnit unit);


```

> 4 个参数：
> 
> command：表示要执行的任务
> 
> initialDelay：表示延迟多久执行第一次
> 
> period：连续执行之间的时间间隔
> 
> unit：参数 2 和参数 3 的时间单位，是个枚举，可以是天、小时、分钟、秒、毫秒、纳秒等

假设系统调用 scheduleAtFixedRate 的时间是 T1，那么执行时间如下：

第 1 次：T1+initialDelay

第 2 次：T1+initialDelay+period

第 3 次：T1+initialDelay+2*period

第 n 次：T1+initialDelay+(n-1)*period

**示例代码：**

```
package com.itsoku.chat18;

import java.sql.Time;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo2 {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        System.out.println(System.currentTimeMillis());
        //任务执行计数器
        AtomicInteger count = new AtomicInteger(1);
        ScheduledExecutorService scheduledExecutorService = Executors.newScheduledThreadPool(10);
        scheduledExecutorService.scheduleAtFixedRate(() -> {
            int currCount = count.getAndIncrement();
            System.out.println(Thread.currentThread().getName());
            System.out.println(System.currentTimeMillis() + "第" + currCount + "次" + "开始执行");
            try {
                TimeUnit.SECONDS.sleep(2);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(System.currentTimeMillis() + "第" + currCount + "次" + "执行结束");
        }, 1, 1, TimeUnit.SECONDS);
    }
}


```

前面 6 次输出结果：

```
1564576404181
pool-1-thread-1
1564576405247第1次开始执行
1564576407251第1次执行结束
pool-1-thread-1
1564576407251第2次开始执行
1564576409252第2次执行结束
pool-1-thread-2
1564576409252第3次开始执行
1564576411255第3次执行结束
pool-1-thread-1
1564576411256第4次开始执行
1564576413260第4次执行结束
pool-1-thread-3
1564576413260第5次开始执行
1564576415265第5次执行结束
pool-1-thread-2
1564576415266第6次开始执行
1564576417269第6次执行结束


```

代码中设置的任务第一次执行时间是系统启动之后延迟一秒执行。后面每次时间间隔 1 秒，从输出中可以看出系统启动之后过了 1 秒任务第一次执行（1、3 行输出），输出的结果中可以看到任务第一次执行结束时间和第二次的结束时间一样，为什么会这样？前面有介绍，任务当前执行完毕之后会计算下次执行时间，下次执行时间为上次执行的开始时间 + period，第一次开始执行时间是 1564576405247，加 1 秒为 1564576406247，这个时间小于第一次结束的时间了，说明小于系统当前时间了，会立即执行。

### scheduleWithFixedDelay: 固定的间隔执行任务

使用`ScheduleThreadPoolExecutor的scheduleWithFixedDelay`方法，该方法设置了执行周期，与 scheduleAtFixedRate 方法不同的是，下一次执行时间是上一次任务执行完的系统时间加上 period，因而具体执行时间不是固定的，但周期是固定的，是采用相对固定的延迟来执行任务。看一下这个方法的声明：

```
public ScheduledFuture<?> scheduleWithFixedDelay(Runnable command,
                                                     long initialDelay,
                                                     long delay,
                                                     TimeUnit unit);


```

> 4 个参数：
> 
> command：表示要执行的任务
> 
> initialDelay：表示延迟多久执行第一次
> 
> period：表示下次执行时间和上次执行结束时间之间的间隔时间
> 
> unit：参数 2 和参数 3 的时间单位，是个枚举，可以是天、小时、分钟、秒、毫秒、纳秒等

假设系统调用 scheduleAtFixedRate 的时间是 T1，那么执行时间如下：

第 1 次：T1+initialDelay，执行结束时间：E1

第 2 次：E1+period，执行结束时间：E2

第 3 次：E2+period，执行结束时间：E3

第 4 次：E3+period，执行结束时间：E4

第 n 次：上次执行结束时间 + period

**示例代码：**

```
package com.itsoku.chat18;

import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo3 {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        System.out.println(System.currentTimeMillis());
        //任务执行计数器
        AtomicInteger count = new AtomicInteger(1);
        ScheduledExecutorService scheduledExecutorService = Executors.newScheduledThreadPool(10);
        scheduledExecutorService.scheduleWithFixedDelay(() -> {
            int currCount = count.getAndIncrement();
            System.out.println(Thread.currentThread().getName());
            System.out.println(System.currentTimeMillis() + "第" + currCount + "次" + "开始执行");
            try {
                TimeUnit.SECONDS.sleep(2);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(System.currentTimeMillis() + "第" + currCount + "次" + "执行结束");
        }, 1, 3, TimeUnit.SECONDS);
    }
}


```

前几次输出如下：

```
1564578510983
pool-1-thread-1
1564578512087第1次开始执行
1564578514091第1次执行结束
pool-1-thread-1
1564578517096第2次开始执行
1564578519100第2次执行结束
pool-1-thread-2
1564578522103第3次开始执行
1564578524105第3次执行结束
pool-1-thread-1
1564578527106第4次开始执行
1564578529106第4次执行结束


```

延迟 1 秒之后执行第 1 次，后面每次的执行时间和上次执行结束时间间隔 3 秒。

`scheduleAtFixedRate`和`scheduleWithFixedDelay`示例建议多看 2 遍。

### 定时任务有异常会怎么样？

示例代码：

```
package com.itsoku.chat18;

import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo4 {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        System.out.println(System.currentTimeMillis());
        //任务执行计数器
        AtomicInteger count = new AtomicInteger(1);
        ScheduledExecutorService scheduledExecutorService = Executors.newScheduledThreadPool(10);
        ScheduledFuture<?> scheduledFuture = scheduledExecutorService.scheduleWithFixedDelay(() -> {
            int currCount = count.getAndIncrement();
            System.out.println(Thread.currentThread().getName());
            System.out.println(System.currentTimeMillis() + "第" + currCount + "次" + "开始执行");
            System.out.println(10 / 0);
            System.out.println(System.currentTimeMillis() + "第" + currCount + "次" + "执行结束");
        }, 1, 1, TimeUnit.SECONDS);

        TimeUnit.SECONDS.sleep(5);
        System.out.println(scheduledFuture.isCancelled());
        System.out.println(scheduledFuture.isDone());

    }
}


```

系统输出如下内容就再也没有输出了：

```
1564578848143
pool-1-thread-1
1564578849226第1次开始执行
false
true


```

**先说补充点知识**：schedule、scheduleAtFixedRate、scheduleWithFixedDelay 这几个方法有个返回值 ScheduledFuture，通过`ScheduledFuture`可以对执行的任务做一些操作，如判断任务是否被取消、是否执行完成。

再回到上面代码，任务中有个 10/0 的操作，会触发异常，发生异常之后没有任何现象，被 ScheduledExecutorService 内部给吞掉了，然后这个任务再也不会执行了，`scheduledFuture.isDone()`输出 true，表示这个任务已经结束了，再也不会被执行了。**所以如果程序有异常，开发者自己注意处理一下，不然跑着跑着发现任务怎么不跑了，也没有异常输出。**

### 取消定时任务的执行

可能任务执行一会，想取消执行，可以调用`ScheduledFuture`的`cancel`方法，参数表示是否给任务发送中断信号。

```
package com.itsoku.chat18;

import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo5 {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        System.out.println(System.currentTimeMillis());
        //任务执行计数器
        AtomicInteger count = new AtomicInteger(1);
        ScheduledExecutorService scheduledExecutorService = Executors.newScheduledThreadPool(1);
        ScheduledFuture<?> scheduledFuture = scheduledExecutorService.scheduleWithFixedDelay(() -> {
            int currCount = count.getAndIncrement();
            System.out.println(Thread.currentThread().getName());
            System.out.println(System.currentTimeMillis() + "第" + currCount + "次" + "开始执行");
            try {
                TimeUnit.SECONDS.sleep(2);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(System.currentTimeMillis() + "第" + currCount + "次" + "执行结束");
        }, 1, 1, TimeUnit.SECONDS);

        TimeUnit.SECONDS.sleep(5);
        scheduledFuture.cancel(false);
        TimeUnit.SECONDS.sleep(1);
        System.out.println("任务是否被取消："+scheduledFuture.isCancelled());
        System.out.println("任务是否已完成："+scheduledFuture.isDone());
    }
}


```

输出：

```
1564579843190
pool-1-thread-1
1564579844255第1次开始执行
1564579846260第1次执行结束
pool-1-thread-1
1564579847263第2次开始执行
任务是否被取消：true
任务是否已完成：true
1564579849267第2次执行结束


```

输出中可以看到任务被取消成功了。

Executors 类
-----------

Executors 类，提供了一系列工厂方法用于创建线程池，返回的线程池都实现了 ExecutorService 接口。常用的方法有：

**newSingleThreadExecutor**

```
public static ExecutorService newSingleThreadExecutor()
public static ExecutorService newSingleThreadExecutor(ThreadFactory threadFactory)


```

> 创建一个单线程的线程池。这个线程池只有一个线程在工作，也就是相当于单线程串行执行所有任务。如果这个唯一的线程因为异常结束，那么会有一个新的线程来替代它。此线程池保证所有任务的执行顺序按照任务的提交顺序执行。内部使用了无限容量的 LinkedBlockingQueue 阻塞队列来缓存任务，任务如果比较多，单线程如果处理不过来，会导致队列堆满，引发 OOM。

**newFixedThreadPool**

```
public static ExecutorService newFixedThreadPool(int nThreads)
public static ExecutorService newFixedThreadPool(int nThreads, ThreadFactory threadFactory)


```

> 创建固定大小的线程池。每次提交一个任务就创建一个线程，直到线程达到线程池的最大大小。线程池的大小一旦达到最大值就会保持不变，在提交新任务，任务将会进入等待队列中等待。如果某个线程因为执行异常而结束，那么线程池会补充一个新线程。内部使用了无限容量的 LinkedBlockingQueue 阻塞队列来缓存任务，任务如果比较多，如果处理不过来，会导致队列堆满，引发 OOM。

**newCachedThreadPool**

```
public static ExecutorService newCachedThreadPool()
public static ExecutorService newCachedThreadPool(ThreadFactory threadFactory)


```

> 创建一个可缓存的线程池。如果线程池的大小超过了处理任务所需要的线程，
> 
> 那么就会回收部分空闲（60 秒处于等待任务到来）的线程，当任务数增加时，此线程池又可以智能的添加新线程来处理任务。此线程池的最大值是 Integer 的最大值 (2^31-1)。内部使用了 SynchronousQueue 同步队列来缓存任务，此队列的特性是放入任务时必须要有对应的线程获取任务，任务才可以放入成功。如果处理的任务比较耗时，任务来的速度也比较快，会创建太多的线程引发 OOM。

**newScheduledThreadPool**

```
public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize)
public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize, ThreadFactory threadFactory)


```

> 创建一个大小无限的线程池。此线程池支持定时以及周期性执行任务的需求。

在《阿里巴巴 java 开发手册》中指出了线程资源必须通过线程池提供，不允许在应用中自行显示的创建线程，这样一方面是线程的创建更加规范，可以合理控制开辟线程的数量；另一方面线程的细节管理交给线程池处理，优化了资源的开销。而线程池不允许使用 Executors 去创建，而要通过 ThreadPoolExecutor 方式，这一方面是由于 jdk 中 Executor 框架虽然提供了如 newFixedThreadPool()、newSingleThreadExecutor()、newCachedThreadPool() 等创建线程池的方法，但都有其局限性，不够灵活；另外由于前面几种方法内部也是通过 ThreadPoolExecutor 方式实现，使用 ThreadPoolExecutor 有助于大家明确线程池的运行规则，创建符合自己的业务场景需要的线程池，避免资源耗尽的风险。

Future、Callable 接口
------------------

`Future`接口定义了操作异步异步任务执行一些方法，**如获取异步任务的执行结果、取消任务的执行、判断任务是否被取消、判断任务执行是否完毕**等。

`Callable`接口中定义了需要有返回的任务需要实现的方法。

```
@FunctionalInterface
public interface Callable<V> {
    V call() throws Exception;
}


```

比如主线程让一个子线程去执行任务，子线程可能比较耗时，启动子线程开始执行任务后，主线程就去做其他事情了，过了一会才去获取子任务的执行结果。

### 获取异步任务执行结果

**示例代码：**

```
package com.itsoku.chat18;

import java.util.concurrent.*;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo6 {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        ExecutorService executorService = Executors.newFixedThreadPool(1);
        Future<Integer> result = executorService.submit(() -> {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName()+",start!");
            TimeUnit.SECONDS.sleep(5);
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName()+",end!");
            return 10;
        });
        System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName());
        System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + ",结果：" + result.get());
    }
}


```

输出：

```
1564581941442,main
1564581941442,pool-1-thread-1,start!
1564581946447,pool-1-thread-1,end!
1564581941442,main,结果：10


```

代码中创建了一个线程池，调用线程池的`submit`方法执行任务，submit 参数为`Callable`接口：表示需要执行的任务有返回值，submit 方法返回一个`Future`对象，Future 相当于一个凭证，可以在任意时间拿着这个凭证去获取对应任务的执行结果（调用其`get`方法），代码中调用了`result.get()`方法之后，此方法会阻塞当前线程直到任务执行结束。

### 超时获取异步任务执行结果

可能任务执行比较耗时，比如耗时 1 分钟，我最多只能等待 10 秒，如果 10 秒还没返回，我就去做其他事情了。

刚好 get 有个超时的方法，声明如下：

```
V get(long timeout, TimeUnit unit)
        throws InterruptedException, ExecutionException, TimeoutException;


```

**示例代码：**

```
package com.itsoku.chat18;

import java.util.concurrent.*;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo8 {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        ExecutorService executorService = Executors.newFixedThreadPool(1);
        Future<Integer> result = executorService.submit(() -> {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName()+",start!");
            TimeUnit.SECONDS.sleep(5);
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName()+",end!");
            return 10;
        });
        System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName());
        try {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + ",结果：" + result.get(3,TimeUnit.SECONDS));
        } catch (TimeoutException e) {
            e.printStackTrace();
        }
        executorService.shutdown();
    }
}


```

输出：

```
1564583177139,main
1564583177139,pool-1-thread-1,start!
java.util.concurrent.TimeoutException
    at java.util.concurrent.FutureTask.get(FutureTask.java:205)
    at com.itsoku.chat18.Demo8.main(Demo8.java:19)
1564583182142,pool-1-thread-1,end!


```

任务执行中休眠了 5 秒，get 方法获取执行结果，超时时间是 3 秒，3 秒还未获取到结果，get 触发了`TimeoutException`异常，当前线程从阻塞状态苏醒了。

**`Future`其他方法介绍一下**

**cancel**：取消在执行的任务，参数表示是否对执行的任务发送中断信号，方法声明如下：

```
boolean cancel(boolean mayInterruptIfRunning);


```

**isCancelled**：用来判断任务是否被取消

**isDone**：判断任务是否执行完毕。

**cancel 方法来个示例：**

```
package com.itsoku.chat18;

import java.util.concurrent.*;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo7 {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        ExecutorService executorService = Executors.newFixedThreadPool(1);
        Future<Integer> result = executorService.submit(() -> {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName()+",start!");
            TimeUnit.SECONDS.sleep(5);
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName()+",end!");
            return 10;
        });

        executorService.shutdown();

        TimeUnit.SECONDS.sleep(1);
        result.cancel(false);
        System.out.println(result.isCancelled());
        System.out.println(result.isDone());

        TimeUnit.SECONDS.sleep(5);
        System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName());
        System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + ",结果：" + result.get());
        executorService.shutdown();
    }
}


```

输出：

```
1564583031646,pool-1-thread-1,start!
true
true
1564583036649,pool-1-thread-1,end!
1564583037653,main
Exception in thread "main" java.util.concurrent.CancellationException
    at java.util.concurrent.FutureTask.report(FutureTask.java:121)
    at java.util.concurrent.FutureTask.get(FutureTask.java:192)
    at com.itsoku.chat18.Demo7.main(Demo7.java:24)


```

输出 2 个 true，表示任务已被取消，已完成，最后调用 get 方法会触发`CancellationException`异常。

**总结：从上面可以看出 Future、Callable 接口需要结合 ExecutorService 来使用，需要有线程池的支持。**

FutureTask 类
------------

FutureTask 除了实现 Future 接口，还实现了 Runnable 接口，因此 FutureTask 可以交给 Executor 执行，也可以交给线程执行执行（**Thread 有个 Runnable 的构造方法**），**FutureTask** 表示带返回值结果的任务。

上面我们演示的是通过线程池执行任务然后获取执行结果。

这次我们通过 FutureTask 类，自己启动一个线程来获取执行结果，示例如下：

```
package com.itsoku.chat18;

import java.util.concurrent.*;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo9 {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        FutureTask<Integer> futureTask = new FutureTask<Integer>(()->{
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName()+",start!");
            TimeUnit.SECONDS.sleep(5);
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName()+",end!");
            return 10;
        });
        System.out.println(System.currentTimeMillis()+","+Thread.currentThread().getName());
        new Thread(futureTask).start();
        System.out.println(System.currentTimeMillis()+","+Thread.currentThread().getName());
        System.out.println(System.currentTimeMillis()+","+Thread.currentThread().getName()+",结果:"+futureTask.get());
    }
}


```

输出：

```
1564585122547,main
1564585122547,main
1564585122547,Thread-0,start!
1564585127549,Thread-0,end!
1564585122547,main,结果:10


```

**大家可以回过头去看一下上面用线程池的 submit 方法返回的 Future 实际类型正是 FutureTask 对象，有兴趣的可以设置个断点去看看。**

**FutureTask 类还是相当重要的，标记一下。**

下面 3 个类，下一篇文章进行详解
-----------------

1.  介绍 CompletableFuture
    
2.  介绍 CompletionService
    
3.  介绍 ExecutorCompletionService
    

java 高并发系列目录
------------

[1.java 高并发系列 - 第 1 天: 必须知道的几个概念](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933019&idx=1&sn=3455877c451de9c61f8391ffdc1eb01d&chksm=88621aa5bf1593b377e2f090bf37c87ba60081fb782b2371b5f875e4a6cadc3f92ff6d747e32&scene=21#wechat_redirect)  
[2.java 高并发系列 - 第 2 天: 并发级别](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933024&idx=1&sn=969bfa5e2c3708e04adaf6401503c187&chksm=88621a9ebf1593886dd3f0f5923b6f929eade0b43204b98a8d0622a5f542deff4f6a633a13c8&scene=21#wechat_redirect)  
[3.java 高并发系列 - 第 3 天: 有关并行的两个重要定律](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933041&idx=1&sn=82af7c702f737782118a9141858117d1&chksm=88621a8fbf159399be1d4834f6f845fa530b94a4ca7c0eaa61de508f725ad0fab74b074d73be&scene=21#wechat_redirect)  
[4.java 高并发系列 - 第 4 天: JMM 相关的一些概念](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933050&idx=1&sn=497c4de99086f95bed11a4317a51e6a6&chksm=88621a84bf159392c9e3e243355313c397e0658df6b88769cdd182cb5d39b6f25686c86beffc&scene=21#wechat_redirect)  
[5.java 高并发系列 - 第 5 天: 深入理解进程和线程](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933069&idx=1&sn=82105bb5b759ec8b1f3a69062a22dada&chksm=88621af3bf1593e5ece7c1da3df3b4be575271a2eaca31c784591ed0497252caa1f6a6ec0545&scene=21#wechat_redirect)  
[6.java 高并发系列 - 第 6 天: 线程的基本操作](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933082&idx=1&sn=e940c4f94a8c1527b6107930eefdcd00&chksm=88621ae4bf1593f270991e6f6bac5769ea850fa02f11552d1aa91725f4512d4f1ff8f18fcdf3&scene=21#wechat_redirect)  
[7.java 高并发系列 - 第 7 天: volatile 与 Java 内存模型](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933088&idx=1&sn=f1d666dd799664b1989c77441b9d12c5&chksm=88621adebf1593c83501ac33d6a0e0de075f2b2e30caf986cf276cbb1c8dff0eac2a0a648b1d&scene=21#wechat_redirect)  
[8.java 高并发系列 - 第 8 天: 线程组](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933095&idx=1&sn=d32242a5ec579f45d1e9becf44bff069&chksm=88621ad9bf1593cf00b574a8e0feeffbb2c241c30b01ebf5749ccd6b7b64dcd2febbd3000581&scene=21#wechat_redirect)  
[9.java 高并发系列 - 第 9 天: 用户线程和守护线程](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933102&idx=1&sn=5255e94dc2649003e01bf3d61762c593&chksm=88621ad0bf1593c6905e75a82aaf6e39a0af338362366ce2860ee88c1b800e52f5c6529c089c&scene=21#wechat_redirect)  
[10.java 高并发系列 - 第 10 天: 线程安全和 synchronized 关键字](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933107&idx=1&sn=6b9fbdfa180c2ca79703e0ca1b524b77&chksm=88621acdbf1593dba5fa5a0092d810004362e9f38484ffc85112a8c23ef48190c51d17e06223&scene=21#wechat_redirect)  
[11.java 高并发系列 - 第 11 天: 线程中断的几种方式](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933111&idx=1&sn=0a3592e41e59d0ded4a60f8c1b59e82e&chksm=88621ac9bf1593df5f8342514d6750cc8a833ba438aa208cf128493981ba666a06c4037d84fb&scene=21#wechat_redirect)  
[12.java 高并发系列 - 第 12 天 JUC:ReentrantLock 重入锁](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933116&idx=1&sn=83ae2d1381e3b8a425e65a9fa7888d38&chksm=88621ac2bf1593d4de1c5f6905c31c7d88ac4b53c0c5c071022ba2e25803fc734078c1de589c&scene=21#wechat_redirect)  
[13.java 高并发系列 - 第 13 天: JUC 中的 Condition 对象](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933120&idx=1&sn=63ffe3ff64dcaf0418816febfd1e129a&chksm=88621b3ebf159228df5f5a501160fafa5d87412a4f03298867ec9325c0be57cd8e329f3b5ad1&scene=21#wechat_redirect)  
[14.java 高并发系列 - 第 14 天: JUC 中的 LockSupport 工具类](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933125&idx=1&sn=382528aeb341727bafb02bb784ff3d4f&chksm=88621b3bbf15922d93bfba11d700724f1e59ef8a74f44adb7e131a4c3d1465f0dc539297f7f3&scene=21#wechat_redirect)  
[15.java 高并发系列 - 第 15 天：](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933130&idx=1&sn=cecc6bd906e79a86510c1fbb0e66cd21&chksm=88621b34bf159222042da8ed4b633e94ca04a614d290d54a952a668459a339ebec0c754d562d&scene=21#wechat_redirect)[JUC 中的 Semaphore（信号量）](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933130&idx=1&sn=cecc6bd906e79a86510c1fbb0e66cd21&chksm=88621b34bf159222042da8ed4b633e94ca04a614d290d54a952a668459a339ebec0c754d562d&scene=21#wechat_redirect)  
[16.java 高并发系列 - 第 16 天：](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933134&idx=1&sn=65c2b9982bb6935c54ff33082f9c111f&chksm=88621b30bf159226d41607292a1dc83186f8928744dbc44acfda381266fa2cdc006177b44095&scene=21#wechat_redirect)[JUC 中等待多线程完成的工具类 CountDownLatch](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933134&idx=1&sn=65c2b9982bb6935c54ff33082f9c111f&chksm=88621b30bf159226d41607292a1dc83186f8928744dbc44acfda381266fa2cdc006177b44095&scene=21#wechat_redirect)  
[17.java 高并发系列 - 第 17 天：](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933144&idx=1&sn=7f0cddc92ff39835ea6652ebb3186dbf&chksm=88621b26bf15923039933b127c19f39a76214fb1d5daa7ad0eee77f961e2e3ab5f5ca3f48740&scene=21#wechat_redirect)[JUC 中的循环栅栏 CyclicBarrier 的 6 种使用场景](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933144&idx=1&sn=7f0cddc92ff39835ea6652ebb3186dbf&chksm=88621b26bf15923039933b127c19f39a76214fb1d5daa7ad0eee77f961e2e3ab5f5ca3f48740&scene=21#wechat_redirect)

[18.java 高并发系列 - 第 18 天：](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933151&idx=1&sn=2020066b974b5f4c0823abd419e8adae&chksm=88621b21bf159237bdacfb47bd1a344f7123aabc25e3607e78d936dd554412edce5dd825003d&scene=21#wechat_redirect)[JAVA 线程池，这一篇就够了](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933151&idx=1&sn=2020066b974b5f4c0823abd419e8adae&chksm=88621b21bf159237bdacfb47bd1a344f7123aabc25e3607e78d936dd554412edce5dd825003d&scene=21#wechat_redirect)

**java 高并发系列连载中，总计估计会有四五十篇文章。**

**跟着阿里 p7 学并发，微信公众号：****javacode2018**

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06AcmgEdFkkWEgWeMkg0tpVAH0UK9CMukCQEk0KdnicBdPCgg2sEXr6nG0NKGDGZcrcj7ZaHF8Dnudw/640?wx_fmt=jpeg)