> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933134&idx=1&sn=65c2b9982bb6935c54ff33082f9c111f&chksm=88621b30bf159226d41607292a1dc83186f8928744dbc44acfda381266fa2cdc006177b44095&token=773938509&lang=zh_CN&scene=21#wechat_redirect)

这是 java 高并发系列第 16 篇文章。

本篇内容
----

1.  **介绍 CountDownLatch 及使用场景**
    
2.  **提供几个示例介绍 CountDownLatch 的使用**
    
3.  **手写一个并行处理任务的工具类**
    

假如有这样一个需求，当我们需要解析一个 Excel 里多个 sheet 的数据时，可以考虑使用多线程，每个线程解析一个 sheet 里的数据，等到所有的 sheet 都解析完之后，程序需要统计解析总耗时。分析一下：解析每个 sheet 耗时可能不一样，总耗时就是最长耗时的那个操作。

我们能够想到的最简单的做法是使用 join，代码如下：

```
package com.itsoku.chat13;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：javacode2018，获取年薪50万课程
 */
public class Demo1 {
    public static class T extends Thread {
        //休眠时间（秒）
        int sleepSeconds;
        public T(String name, int sleepSeconds) {
            super(name);
            this.sleepSeconds = sleepSeconds;
        }
        @Override
        public void run() {
            Thread ct = Thread.currentThread();
            long startTime = System.currentTimeMillis();
            System.out.println(startTime + "," + ct.getName() + ",开始处理!");
            try {
                //模拟耗时操作，休眠sleepSeconds秒
                TimeUnit.SECONDS.sleep(this.sleepSeconds);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            long endTime = System.currentTimeMillis();
            System.out.println(endTime + "," + ct.getName() + ",处理完毕,耗时:" + (endTime - startTime));
        }
    }
    public static void main(String[] args) throws InterruptedException {
        long starTime = System.currentTimeMillis();
        T t1 = new T("解析sheet1线程", 2);
        t1.start();
        T t2 = new T("解析sheet2线程", 5);
        t2.start();
        t1.join();
        t2.join();
        long endTime = System.currentTimeMillis();
        System.out.println("总耗时:" + (endTime - starTime));
    }
}

```

输出：

```
1563767560271,解析sheet1线程,开始处理!
1563767560272,解析sheet2线程,开始处理!
1563767562273,解析sheet1线程,处理完毕,耗时:2002
1563767565274,解析sheet2线程,处理完毕,耗时:5002
总耗时:5005

```

代码中启动了 2 个解析 sheet 的线程，第一个耗时 2 秒，第二个耗时 5 秒，最终结果中总耗时：5 秒。上面的关键技术点是线程的 `join()`方法，此方法会让当前线程等待被调用的线程完成之后才能继续。可以看一下 join 的源码，内部其实是在 synchronized 方法中调用了线程的 wait 方法，最后被调用的线程执行完毕之后，由 jvm 自动调用其 notifyAll() 方法，唤醒所有等待中的线程。这个 notifyAll() 方法是由 jvm 内部自动调用的，jdk 源码中是看不到的，需要看 jvm 源码，有兴趣的同学可以去查一下。所以 JDK 不推荐在线程上调用 wait、notify、notifyAll 方法。

而在 JDK1.5 之后的并发包中提供的 CountDownLatch 也可以实现 join 的这个功能。

CountDownLatch 介绍
-----------------

CountDownLatch 称之为闭锁，它可以使一个或一批线程在闭锁上等待，等到其他线程执行完相应操作后，闭锁打开，这些等待的线程才可以继续执行。确切的说，闭锁在内部维护了一个倒计数器。通过该计数器的值来决定闭锁的状态，从而决定是否允许等待的线程继续执行。

**常用方法：**

**public CountDownLatch(int count)**：构造方法，count 表示计数器的值，不能小于 0，否者会报异常。

**public void await() throws InterruptedException**：调用 await() 会让当前线程等待，直到计数器为 0 的时候，方法才会返回，此方法会响应线程中断操作。

**public boolean await(long timeout, TimeUnit unit) throws InterruptedException**：限时等待，在超时之前，计数器变为了 0，方法返回 true，否者直到超时，返回 false，此方法会响应线程中断操作。

**public void countDown()**：让计数器减 1

CountDownLatch 使用步骤：

1.  创建 CountDownLatch 对象
    
2.  调用其实例方法 `await()`，让当前线程等待
    
3.  调用 `countDown()`方法，让计数器减 1
    
4.  当计数器变为 0 的时候， `await()`方法会返回
    

### 示例 1：一个简单的示例

我们使用 CountDownLatch 来完成上面示例中使用 join 实现的功能，代码如下：

```
package com.itsoku.chat13;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：javacode2018，获取年薪50万课程
 */
public class Demo2 {
    public static class T extends Thread {
        //休眠时间（秒）
        int sleepSeconds;
        CountDownLatch countDownLatch;
        public T(String name, int sleepSeconds, CountDownLatch countDownLatch) {
            super(name);
            this.sleepSeconds = sleepSeconds;
            this.countDownLatch = countDownLatch;
        }
        @Override
        public void run() {
            Thread ct = Thread.currentThread();
            long startTime = System.currentTimeMillis();
            System.out.println(startTime + "," + ct.getName() + ",开始处理!");
            try {
                //模拟耗时操作，休眠sleepSeconds秒
                TimeUnit.SECONDS.sleep(this.sleepSeconds);
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                countDownLatch.countDown();
            }
            long endTime = System.currentTimeMillis();
            System.out.println(endTime + "," + ct.getName() + ",处理完毕,耗时:" + (endTime - startTime));
        }
    }
    public static void main(String[] args) throws InterruptedException {
        System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + "线程 start!");
        CountDownLatch countDownLatch = new CountDownLatch(2);
        long starTime = System.currentTimeMillis();
        T t1 = new T("解析sheet1线程", 2, countDownLatch);
        t1.start();
        T t2 = new T("解析sheet2线程", 5, countDownLatch);
        t2.start();
        countDownLatch.await();
        System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + "线程 end!");
        long endTime = System.currentTimeMillis();
        System.out.println("总耗时:" + (endTime - starTime));
    }
}

```

输出：

```
1563767580511,main线程 start!
1563767580513,解析sheet1线程,开始处理!
1563767580513,解析sheet2线程,开始处理!
1563767582515,解析sheet1线程,处理完毕,耗时:2002
1563767585515,解析sheet2线程,处理完毕,耗时:5002
1563767585515,main线程 end!
总耗时:5003

```

从结果中看出，效果和 join 实现的效果一样，代码中创建了计数器为 2 的 `CountDownLatch`，主线程中调用 `countDownLatch.await();`会让主线程等待，t1、t2 线程中模拟执行耗时操作，最终在 finally 中调用了 `countDownLatch.countDown();`, 此方法每调用一次，CountDownLatch 内部计数器会减 1，当计数器变为 0 的时候，主线程中的 await() 会返回，然后继续执行。注意：上面的 `countDown()`这个是必须要执行的方法，所以放在 finally 中执行。

示例 2：等待指定的时间
------------

还是上面的示例，2 个线程解析 2 个 sheet，主线程等待 2 个 sheet 解析完成。主线程说，我等待 2 秒，你们还是无法处理完成，就不等待了，直接返回。如下代码：

```
package com.itsoku.chat13;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：javacode2018，获取年薪50万课程
 */
public class Demo3 {
    public static class T extends Thread {
        //休眠时间（秒）
        int sleepSeconds;
        CountDownLatch countDownLatch;
        public T(String name, int sleepSeconds, CountDownLatch countDownLatch) {
            super(name);
            this.sleepSeconds = sleepSeconds;
            this.countDownLatch = countDownLatch;
        }
        @Override
        public void run() {
            Thread ct = Thread.currentThread();
            long startTime = System.currentTimeMillis();
            System.out.println(startTime + "," + ct.getName() + ",开始处理!");
            try {
                //模拟耗时操作，休眠sleepSeconds秒
                TimeUnit.SECONDS.sleep(this.sleepSeconds);
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                countDownLatch.countDown();
            }
            long endTime = System.currentTimeMillis();
            System.out.println(endTime + "," + ct.getName() + ",处理完毕,耗时:" + (endTime - startTime));
        }
    }
    public static void main(String[] args) throws InterruptedException {
        System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + "线程 start!");
        CountDownLatch countDownLatch = new CountDownLatch(2);
        long starTime = System.currentTimeMillis();
        T t1 = new T("解析sheet1线程", 2, countDownLatch);
        t1.start();
        T t2 = new T("解析sheet2线程", 5, countDownLatch);
        t2.start();
        boolean result = countDownLatch.await(2, TimeUnit.SECONDS);
        System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + "线程 end!");
        long endTime = System.currentTimeMillis();
        System.out.println("主线程耗时:" + (endTime - starTime) + ",result:" + result);
    }
}

```

输出：

```
1563767637316,main线程 start!
1563767637320,解析sheet1线程,开始处理!
1563767637320,解析sheet2线程,开始处理!
1563767639321,解析sheet1线程,处理完毕,耗时:2001
1563767639322,main线程 end!
主线程耗时:2004,result:false
1563767642322,解析sheet2线程,处理完毕,耗时:5002

```

从输出结果中可以看出，线程 2 耗时了 5 秒，主线程耗时了 2 秒，主线程中调用 `countDownLatch.await(2,TimeUnit.SECONDS);`，表示最多等 2 秒，不管计数器是否为 0，await 方法都会返回，若等待时间内，计数器变为 0 了，立即返回 true，否则超时后返回 false。

### 示例 3：2 个 CountDown 结合使用的示例

有 3 个人参见跑步比赛，需要先等指令员发指令枪后才能开跑，所有人都跑完之后，指令员喊一声，大家跑完了。

示例代码：

```
package com.itsoku.chat13;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：javacode2018，获取年薪50万课程
 */
public class Demo4 {
    public static class T extends Thread {
        //跑步耗时（秒）
        int runCostSeconds;
        CountDownLatch commanderCd;
        CountDownLatch countDown;
        public T(String name, int runCostSeconds, CountDownLatch commanderCd, CountDownLatch countDown) {
            super(name);
            this.runCostSeconds = runCostSeconds;
            this.commanderCd = commanderCd;
            this.countDown = countDown;
        }
        @Override
        public void run() {
            //等待指令员枪响
            try {
                commanderCd.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            Thread ct = Thread.currentThread();
            long startTime = System.currentTimeMillis();
            System.out.println(startTime + "," + ct.getName() + ",开始跑!");
            try {
                //模拟耗时操作，休眠runCostSeconds秒
                TimeUnit.SECONDS.sleep(this.runCostSeconds);
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                countDown.countDown();
            }
            long endTime = System.currentTimeMillis();
            System.out.println(endTime + "," + ct.getName() + ",跑步结束,耗时:" + (endTime - startTime));
        }
    }
    public static void main(String[] args) throws InterruptedException {
        System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + "线程 start!");
        CountDownLatch commanderCd = new CountDownLatch(1);
        CountDownLatch countDownLatch = new CountDownLatch(3);
        long starTime = System.currentTimeMillis();
        T t1 = new T("小张", 2, commanderCd, countDownLatch);
        t1.start();
        T t2 = new T("小李", 5, commanderCd, countDownLatch);
        t2.start();
        T t3 = new T("路人甲", 10, commanderCd, countDownLatch);
        t3.start();
        //主线程休眠5秒,模拟指令员准备发枪耗时操作
        TimeUnit.SECONDS.sleep(5);
        System.out.println(System.currentTimeMillis() + ",枪响了，大家开始跑");
        commanderCd.countDown();
        countDownLatch.await();
        long endTime = System.currentTimeMillis();
        System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + "所有人跑完了，主线程耗时:" + (endTime - starTime));
    }
}

```

输出：

```
1563767691087,main线程 start!
1563767696092,枪响了，大家开始跑
1563767696092,小张,开始跑!
1563767696092,小李,开始跑!
1563767696092,路人甲,开始跑!
1563767698093,小张,跑步结束,耗时:2001
1563767701093,小李,跑步结束,耗时:5001
1563767706093,路人甲,跑步结束,耗时:10001
1563767706093,main所有人跑完了，主线程耗时:15004

```

代码中，t1、t2、t3 启动之后，都阻塞在 `commanderCd.await();`，主线程模拟发枪准备操作耗时 5 秒，然后调用 `commanderCd.countDown();`模拟发枪操作，此方法被调用以后，阻塞在 `commanderCd.await();`的 3 个线程会向下执行。主线程调用 `countDownLatch.await();`之后进行等待，每个人跑完之后，调用 `countDown.countDown();`通知一下 `countDownLatch`让计数器减 1，最后 3 个人都跑完了，主线程从 `countDownLatch.await();`返回继续向下执行。

### 手写一个并行处理任务的工具类

```
package com.itsoku.chat13;
import org.springframework.util.CollectionUtils;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.function.Consumer;
import java.util.stream.Collectors;
import java.util.stream.Stream;
/**
 * 微信公众号：javacode2018，获取年薪50万课程
 */
public class TaskDisposeUtils {
    //并行线程数
    public static final int POOL_SIZE;
    static {
        POOL_SIZE = Integer.max(Runtime.getRuntime().availableProcessors(), 5);
    }
    /**
     * 并行处理，并等待结束
     *
     * @param taskList 任务列表
     * @param consumer 消费者
     * @param <T>
     * @throws InterruptedException
     */
    public static <T> void dispose(List<T> taskList, Consumer<T> consumer) throws InterruptedException {
        dispose(true, POOL_SIZE, taskList, consumer);
    }
    /**
     * 并行处理，并等待结束
     *
     * @param moreThread 是否多线程执行
     * @param poolSize   线程池大小
     * @param taskList   任务列表
     * @param consumer   消费者
     * @param <T>
     * @throws InterruptedException
     */
    public static <T> void dispose(boolean moreThread, int poolSize, List<T> taskList, Consumer<T> consumer) throws InterruptedException {
        if (CollectionUtils.isEmpty(taskList)) {
            return;
        }
        if (moreThread && poolSize > 1) {
            poolSize = Math.min(poolSize, taskList.size());
            ExecutorService executorService = null;
            try {
                executorService = Executors.newFixedThreadPool(poolSize);
                CountDownLatch countDownLatch = new CountDownLatch(taskList.size());
                for (T item : taskList) {
                    executorService.execute(() -> {
                        try {
                            consumer.accept(item);
                        } finally {
                            countDownLatch.countDown();
                        }
                    });
                }
                countDownLatch.await();
            } finally {
                if (executorService != null) {
                    executorService.shutdown();
                }
            }
        } else {
            for (T item : taskList) {
                consumer.accept(item);
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        //生成1-10的10个数字，放在list中，相当于10个任务
        List<Integer> list = Stream.iterate(1, a -> a + 1).limit(10).collect(Collectors.toList());
        //启动多线程处理list中的数据，每个任务休眠时间为list中的数值
        TaskDisposeUtils.dispose(list, item -> {
            try {
                long startTime = System.currentTimeMillis();
                TimeUnit.SECONDS.sleep(item);
                long endTime = System.currentTimeMillis();
                System.out.println(System.currentTimeMillis() + ",任务" + item + "执行完毕，耗时:" + (endTime - startTime));
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });
        //上面所有任务处理完毕完毕之后，程序才能继续
        System.out.println(list + "中的任务都处理完毕!");
    }
}

```

运行代码输出：

```
1563769828130,任务1执行完毕，耗时:1000
1563769829130,任务2执行完毕，耗时:2000
1563769830131,任务3执行完毕，耗时:3001
1563769831131,任务4执行完毕，耗时:4001
1563769832131,任务5执行完毕，耗时:5001
1563769833130,任务6执行完毕，耗时:6000
1563769834131,任务7执行完毕，耗时:7001
1563769835131,任务8执行完毕，耗时:8001
1563769837131,任务9执行完毕，耗时:9001
1563769839131,任务10执行完毕，耗时:10001
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]中的任务都处理完毕!

```

**TaskDisposeUtils 是一个并行处理的工具类，可以传入 n 个任务内部使用线程池进行处理，等待所有任务都处理完成之后，方法才会返回。比如我们发送短信，系统中有 1 万条短信，我们使用上面的工具，每次取 100 条并行发送，待 100 个都处理完毕之后，再取一批按照同样的逻辑发送。**

**码子不易，感觉还可以的，帮忙分享一下，谢谢！**

**java 高并发系列目录：**
-----------------

[1.java 高并发系列 - 第 1 天: 必须知道的几个概念](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933019&idx=1&sn=3455877c451de9c61f8391ffdc1eb01d&chksm=88621aa5bf1593b377e2f090bf37c87ba60081fb782b2371b5f875e4a6cadc3f92ff6d747e32&scene=21#wechat_redirect)

[2.java 高并发系列 - 第 2 天: 并发级别](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933024&idx=1&sn=969bfa5e2c3708e04adaf6401503c187&chksm=88621a9ebf1593886dd3f0f5923b6f929eade0b43204b98a8d0622a5f542deff4f6a633a13c8&scene=21#wechat_redirect)

[3.java 高并发系列 - 第 3 天: 有关并行的两个重要定律](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933041&idx=1&sn=82af7c702f737782118a9141858117d1&chksm=88621a8fbf159399be1d4834f6f845fa530b94a4ca7c0eaa61de508f725ad0fab74b074d73be&scene=21#wechat_redirect)

[4.java 高并发系列 - 第 4 天: JMM 相关的一些概念](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933050&idx=1&sn=497c4de99086f95bed11a4317a51e6a6&chksm=88621a84bf159392c9e3e243355313c397e0658df6b88769cdd182cb5d39b6f25686c86beffc&scene=21#wechat_redirect)

[5.java 高并发系列 - 第 5 天: 深入理解进程和线程](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933069&idx=1&sn=82105bb5b759ec8b1f3a69062a22dada&chksm=88621af3bf1593e5ece7c1da3df3b4be575271a2eaca31c784591ed0497252caa1f6a6ec0545&scene=21#wechat_redirect)

[6.java 高并发系列 - 第 6 天: 线程的基本操作](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933082&idx=1&sn=e940c4f94a8c1527b6107930eefdcd00&chksm=88621ae4bf1593f270991e6f6bac5769ea850fa02f11552d1aa91725f4512d4f1ff8f18fcdf3&scene=21#wechat_redirect)

[7.java 高并发系列 - 第 7 天: volatile 与 Java 内存模型](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933088&idx=1&sn=f1d666dd799664b1989c77441b9d12c5&chksm=88621adebf1593c83501ac33d6a0e0de075f2b2e30caf986cf276cbb1c8dff0eac2a0a648b1d&scene=21#wechat_redirect)

[8.java 高并发系列 - 第 8 天: 线程组](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933088&idx=1&sn=f1d666dd799664b1989c77441b9d12c5&chksm=88621adebf1593c83501ac33d6a0e0de075f2b2e30caf986cf276cbb1c8dff0eac2a0a648b1d&scene=21#wechat_redirect)

[9.java 高并发系列 - 第 9 天: 用户线程和守护线程](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933102&idx=1&sn=5255e94dc2649003e01bf3d61762c593&chksm=88621ad0bf1593c6905e75a82aaf6e39a0af338362366ce2860ee88c1b800e52f5c6529c089c&scene=21#wechat_redirect)

[10.java 高并发系列 - 第 10 天: 线程安全和 synchronized 关键字](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933107&idx=1&sn=6b9fbdfa180c2ca79703e0ca1b524b77&chksm=88621acdbf1593dba5fa5a0092d810004362e9f38484ffc85112a8c23ef48190c51d17e06223&scene=21#wechat_redirect)

[11.java 高并发系列 - 第 11 天: 线程中断的几种方式](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933107&idx=1&sn=6b9fbdfa180c2ca79703e0ca1b524b77&chksm=88621acdbf1593dba5fa5a0092d810004362e9f38484ffc85112a8c23ef48190c51d17e06223&scene=21#wechat_redirect)

[12.java 高并发系列 - 第 12 天 JUC:ReentrantLock 重入锁](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933116&idx=1&sn=83ae2d1381e3b8a425e65a9fa7888d38&chksm=88621ac2bf1593d4de1c5f6905c31c7d88ac4b53c0c5c071022ba2e25803fc734078c1de589c&scene=21#wechat_redirect)

[13.java 高并发系列 - 第 13 天: JUC 中的 Condition 对象](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933120&idx=1&sn=63ffe3ff64dcaf0418816febfd1e129a&chksm=88621b3ebf159228df5f5a501160fafa5d87412a4f03298867ec9325c0be57cd8e329f3b5ad1&scene=21#wechat_redirect)

[14.java 高并发系列 - 第 14 天: JUC 中的 LockSupport 工具类](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933125&idx=1&sn=382528aeb341727bafb02bb784ff3d4f&chksm=88621b3bbf15922d93bfba11d700724f1e59ef8a74f44adb7e131a4c3d1465f0dc539297f7f3&scene=21#wechat_redirect)

**java 高并发系列连载中，总计估计会有四五十篇文章，****可以关注公众号：javacode2018，送年薪 50 万 java 学习路线资料，获取最新文章。**

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06AcmgEdFkkWEgWeMkg0tpVAH0UK9CMukCQEk0KdnicBdPCgg2sEXr6nG0NKGDGZcrcj7ZaHF8Dnudw/640?wx_fmt=jpeg)