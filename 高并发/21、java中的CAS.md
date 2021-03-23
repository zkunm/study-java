> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933166&idx=1&sn=15e614500676170b76a329efd3255c12&chksm=88621b10bf1592064befc5c9f0d78c56cda25c6d003e1711b85e5bfeb56c9fd30d892178db87&token=1033016931&lang=zh_CN&scene=21#wechat_redirect)

这是 java 高并发系列第 21 篇文章。

本文主要内容
------

1.  从网站计数器实现中一步步引出 CAS 操作
    
2.  介绍 java 中的 CAS 及 CAS 可能存在的问题
    
3.  悲观锁和乐观锁的一些介绍及数据库乐观锁的一个常见示例
    
4.  使用 java 中的原子操作实现网站计数器功能
    

我们需要解决的问题
---------

**需求：我们开发了一个网站，需要对访问量进行统计，用户每次发一次请求，访问量 + 1，如何实现呢？**

下面我们来模仿有 100 个人同时访问，并且每个人对咱们的网站发起 10 次请求，最后总访问次数应该是 1000 次。实现访问如下。

### 方式 1

代码如下：

```
package com.itsoku.chat20;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo1 {
    //访问次数
    static int count = 0;

    //模拟访问一次
    public static void request() throws InterruptedException {
        //模拟耗时5毫秒
        TimeUnit.MILLISECONDS.sleep(5);
        count++;
    }

    public static void main(String[] args) throws InterruptedException {
        long starTime = System.currentTimeMillis();
        int threadSize = 100;
        CountDownLatch countDownLatch = new CountDownLatch(threadSize);
        for (int i = 0; i < threadSize; i++) {
            Thread thread = new Thread(() -> {
                try {
                    for (int j = 0; j < 10; j++) {
                        request();
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
                    countDownLatch.countDown();
                }
            });
            thread.start();
        }

        countDownLatch.await();
        long endTime = System.currentTimeMillis();
        System.out.println(Thread.currentThread().getName() + "，耗时：" + (endTime - starTime) + ",count=" + count);
    }
}


```

输出：

```
main，耗时：138,count=975


```

代码中的 count 用来记录总访问次数，`request()`方法表示访问一次，内部休眠 5 毫秒模拟内部耗时，request 方法内部对 count++ 操作。程序最终耗时 1 秒多，执行还是挺快的，但是 count 和我们期望的结果不一致，我们期望的是 1000，实际输出的是 973（每次运行结果可能都不一样）。

**分析一下问题出在哪呢？**

**代码中采用的是多线程的方式来操作 count，count++ 会有线程安全问题，count++ 操作实际上是由以下三步操作完成的：**

1.  获取 count 的值，记做 A：A=count
    
2.  将 A 的值 + 1，得到 B：B = A+1
    
3.  让 B 赋值给 count：count = B
    

如果有 A、B 两个线程同时执行 count++，他们同时执行到上面步骤的第 1 步，得到的 count 是一样的，3 步操作完成之后，count 只会 + 1，导致 count 只加了一次，从而导致结果不准确。

**那么我们应该怎么做的呢？**

对 count++ 操作的时候，我们让多个线程排队处理，多个线程同时到达 request() 方法的时候，只能允许一个线程可以进去操作，其他的线程在外面候着，等里面的处理完毕出来之后，外面等着的再进去一个，这样操作 count++ 就是排队进行的，结果一定是正确的。

**我们前面学了 synchronized、ReentrantLock 可以对资源加锁，保证并发的正确性，多线程情况下可以保证被锁的资源被串行访问，那么我们用 synchronized 来实现一下。**

### 使用 synchronized 实现

代码如下：

```
package com.itsoku.chat20;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo2 {
    //访问次数
    static int count = 0;

    //模拟访问一次
    public static synchronized void request() throws InterruptedException {
        //模拟耗时5毫秒
        TimeUnit.MILLISECONDS.sleep(5);
        count++;
    }

    public static void main(String[] args) throws InterruptedException {
        long starTime = System.currentTimeMillis();
        int threadSize = 100;
        CountDownLatch countDownLatch = new CountDownLatch(threadSize);
        for (int i = 0; i < threadSize; i++) {
            Thread thread = new Thread(() -> {
                try {
                    for (int j = 0; j < 10; j++) {
                        request();
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
                    countDownLatch.countDown();
                }
            });
            thread.start();
        }

        countDownLatch.await();
        long endTime = System.currentTimeMillis();
        System.out.println(Thread.currentThread().getName() + "，耗时：" + (endTime - starTime) + ",count=" + count);
    }
}


```

输出：

```
main，耗时：5563,count=1000


```

程序中 request 方法使用 synchronized 关键字，保证了并发情况下，request 方法同一时刻只允许一个线程访问，request 加锁了相当于串行执行了，count 的结果和我们预期的结果一致，只是耗时比较长，5 秒多。

### 方式 3

我们在看一下 count++ 操作，count++ 操作实际上是被拆分为 3 步骤执行：

```
1. 获取count的值，记做A：A=count
2. 将A的值+1，得到B：B = A+1
3. 让B赋值给count：count = B


```

方式 2 中我们通过加锁的方式让上面 3 步骤同时只能被一个线程操作，从而保证结果的正确性。

我们是否可以只在第 3 步加锁，减少加锁的范围，对第 3 步做以下处理：

```
获取锁
第三步获取一下count最新的值，记做LV
判断LV是否等于A，如果相等，则将B的值赋给count，并返回true，否者返回false
释放锁


```

如果我们发现第 3 步返回的是 false，我们就再次去获取 count，将 count 赋值给 A，对 A+1 赋值给 B，然后再将 A、B 的值带入到上面的过程中执行，直到上面的结果返回 true 为止。

我们用代码来实现，如下：

```
package com.itsoku.chat20;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo3 {
    //访问次数
    volatile static int count = 0;

    //模拟访问一次
    public static void request() throws InterruptedException {
        //模拟耗时5毫秒
        TimeUnit.MILLISECONDS.sleep(5);
        int expectCount;
        do {
            expectCount = getCount();
        } while (!compareAndSwap(expectCount, expectCount + 1));
    }

    /**
     * 获取count当前的值
     *
     * @return
     */
    public static int getCount() {
        return count;
    }

    /**
     * @param expectCount 期望count的值
     * @param newCount    需要给count赋的新值
     * @return
     */
    public static synchronized boolean compareAndSwap(int expectCount, int newCount) {
        //判断count当前值是否和期望的expectCount一样，如果一样将newCount赋值给count
        if (getCount() == expectCount) {
            count = newCount;
            return true;
        }
        return false;
    }

    public static void main(String[] args) throws InterruptedException {
        long starTime = System.currentTimeMillis();
        int threadSize = 100;
        CountDownLatch countDownLatch = new CountDownLatch(threadSize);
        for (int i = 0; i < threadSize; i++) {
            Thread thread = new Thread(() -> {
                try {
                    for (int j = 0; j < 10; j++) {
                        request();
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
                    countDownLatch.countDown();
                }
            });
            thread.start();
        }

        countDownLatch.await();
        long endTime = System.currentTimeMillis();
        System.out.println(Thread.currentThread().getName() + "，耗时：" + (endTime - starTime) + ",count=" + count);
    }
}


```

输出：

```
main，耗时：116,count=1000


```

代码中用了`volatile`关键字修饰了 count，可以保证 count 在多线程情况下的可见性。**关于 volatile 关键字的使用，也是非常非常重要的**，前面有讲过，不太了解的朋友可以去看一下：[**volatile 与 Java 内存模型**](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933088&idx=1&sn=f1d666dd799664b1989c77441b9d12c5&chksm=88621adebf1593c83501ac33d6a0e0de075f2b2e30caf986cf276cbb1c8dff0eac2a0a648b1d&scene=21#wechat_redirect)

咱们再看一下代码，`compareAndSwap`方法，我们给起个简称吧叫`CAS`，这个方法有什么作用呢？这个方法使用`synchronized`修饰了，能保证此方法是线程安全的，多线程情况下此方法是串行执行的。方法由两个参数，expectCount：表示期望的值，newCount：表示要给 count 设置的新值。方法内部通过`getCount()`获取 count 当前的值，然后与期望的值 expectCount 比较，如果期望的值和 count 当前的值一致，则将新值 newCount 赋值给 count。

再看一下 request() 方法，方法中有个 do-while 循环，循环内部获取 count 当前值赋值给了 expectCount，循环结束的条件是`compareAndSwap`返回 true，也就是说如果 compareAndSwap 如果不成功，循环再次获取 count 的最新值，然后 + 1，再次调用 compareAndSwap 方法，直到`compareAndSwap`返回成功为止。

代码中相当于将 count++ 拆分开了，只对最后一步加锁了，减少了锁的范围，此代码的性能是不是比方式 2 快不少，还能保证结果的正确性。大家是不是感觉这个`compareAndSwap`方法挺好的，这东西确实很好，java 中已经给我们提供了 CAS 的操作，功能非常强大，我们继续向下看。

CAS
---

CAS,compare and swap 的缩写，中文翻译成比较并交换。

**CAS 操作包含三个操作数 —— 内存位置（V）、预期原值（A）和新值 (B)。如果内存位置的值与预期原值相匹配，那么处理器会自动将该位置值更新为新值 。否则，处理器不做任何操作。无论哪种情况，它都会在 CAS 指令之前返回该 位置的值。（在 CAS 的一些特殊情况下将仅返回 CAS 是否成功，而不提取当前 值。）CAS 有效地说明了 “我认为位置 V 应该包含值 A；如果包含该值，则将 B 放到这个位置；否则，不要更改该位置，只告诉我这个位置现在的值即可。”**

通常将 CAS 用于同步的方式是从地址 V 读取值 A，执行多步计算来获得新 值 B，然后使用 CAS 将 V 的值从 A 改为 B。如果 V 处的值尚未同时更改，则 CAS 操作成功。

> 很多地方说 CAS 操作是非阻塞的，其实系统底层进行 CAS 操作的时候，会判断当前系统是否为多核系统，如果是就给总线加锁，所以同一芯片上的其他处理器就暂时不能通过总线访问内存，保证了该指令在多处理器环境下的原子性。总线上锁的，其他线程执行 CAS 还是会被阻塞一下，只是时间可能会非常短暂，所以说 CAS 是非阻塞的并不正确，只能说阻塞的时间是非常短的。

java 中提供了对 CAS 操作的支持，具体在`sun.misc.Unsafe`类中，声明如下：

```
public final native boolean compareAndSwapObject(Object var1, long var2, Object var4, Object var5);
public final native boolean compareAndSwapInt(Object var1, long var2, int var4, int var5);
public final native boolean compareAndSwapLong(Object var1, long var2, long var4, long var6);


```

上面三个方法都是类似的，主要对 4 个参数做一下说明。

> var1：表示要操作的对象
> 
> var2：表示要操作对象中属性地址的偏移量
> 
> var4：表示需要修改数据的期望的值
> 
> var5：表示需要修改为的新值

JUC 包中大部分功能都是依靠 CAS 操作完成的，所以这块也是非常重要的，有关 Unsafe 类，下篇文章会具体讲解。

`synchronized`、`ReentrantLock`这种独占锁属于**悲观锁**，它是在假设需要操作的代码一定会发生冲突的，执行代码的时候先对代码加锁，让其他线程在外面等候排队获取锁。悲观锁如果锁的时间比较长，会导致其他线程一直处于等待状态，像我们部署的 web 应用，一般部署在 tomcat 中，内部通过线程池来处理用户的请求，如果很多请求都处于等待获取锁的状态，可能会耗尽 tomcat 线程池，从而导致系统无法处理后面的请求，导致服务器处于不可用状态。

除此之外，还有**乐观锁**，乐观锁的含义就是假设系统没有发生并发冲突，先按无锁方式执行业务，到最后了检查执行业务期间是否有并发导致数据被修改了，如果有并发导致数据被修改了 ，就快速返回失败，这样的操作使系统并发性能更高一些。cas 中就使用了这样的操作。

关于乐观锁这块，想必大家在数据库中也有用到过，给大家举个例子，可能以后会用到。

如果你们的网站中有调用支付宝充值接口的，支付宝那边充值成功了会回调商户系统，商户系统接收到请求之后怎么处理呢？假设用户通过支付宝在商户系统中充值 100，支付宝那边会从用户账户中扣除 100，商户系统接收到支付宝请求之后应该在商户系统中给用户账户增加 100，并且把订单状态置为成功。

处理过程如下：

```
开启事务
获取订单信息
if(订单状态==待处理){
    给用户账户增加100
    将订单状态更新为成功
}
返回订单处理成功
提交事务


```

由于网络等各种问题，可能支付宝回调商户系统的时候，回调超时了，支付宝又发起了一笔回调请求，刚好这 2 笔请求同时到达上面代码，最终结果是给用户账户增加了 200，这样事情就搞大了，公司蒙受损失，严重点可能让公司就此倒闭了。

那我们可以用乐观锁来实现，给订单表加个版本号 version，要求每次更新订单数据，将版本号 + 1，那么上面的过程可以改为：

```
获取订单信息,将version的值赋值给V_A
if(订单状态==待处理){
    开启事务
    给用户账户增加100
    update影响行数 = update 订单表 set version = version + 1 where id = 订单号 and version = V_A;
    if(update影响行数==1){
        提交事务
    }else{
        回滚事务
    }
}
返回订单处理成功


```

上面的 update 语句相当于我们说的 CAS 操作，执行这个 update 语句的时候，多线程情况下，数据库会对当前订单记录加锁，保证只有一条执行成功，执行成功的，影响行数为 1，执行失败的影响行数为 0，根据影响行数来决定提交还是回滚事务。上面操作还有一点是将事务范围缩小了，也提升了系统并发处理的性能。这个知识点希望你们能 get 到。

CAS 的问题
-------

cas 这么好用，那么有没有什么问题呢？还真有

**ABA 问题**

**CAS 需要在操作值的时候检查下值有没有发生变化，如果没有发生变化则更新，但是如果一个值原来是 A，变成了 B，又变成了 A，那么使用 CAS 进行检查时会发现它的值没有发生变化，但是实际上却变化了**。这就是 CAS 的 ABA 问题。常见的解决思路是使用版本号。在变量前面追加上版本号，每次变量更新的时候把版本号加一，那么`A-B-A` 就会变成`1A-2B-3A`。目前在 JDK 的 atomic 包里提供了一个类`AtomicStampedReference`来解决 ABA 问题。这个类的 compareAndSet 方法作用是首先检查当前引用是否等于预期引用，并且当前标志是否等于预期标志，如果全部相等，则以原子方式将该引用和该标志的值设置为给定的更新值。

**循环时间长开销大**

上面我们说过如果 CAS 不成功，则会原地循环（自旋操作），如果长时间自旋会给 CPU 带来非常大的执行开销。并发量比较大的情况下，CAS 成功概率可能比较低，可能会重试很多次才会成功。

使用 JUC 中的类实现计数器
---------------

juc 框架中提供了一些原子操作，底层是通过 Unsafe 类中的 cas 操作实现的。通过原子操作可以保证数据在并发情况下的正确性。

此处我们使用`java.util.concurrent.atomic.AtomicInteger`类来实现计数器功能，AtomicInteger 内部是采用 cas 操作来保证对 int 类型数据增减操作在多线程情况下的正确性。

计数器代码如下：

```
package com.itsoku.chat20;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo4 {
    //访问次数
    static AtomicInteger count = new AtomicInteger();

    //模拟访问一次
    public static void request() throws InterruptedException {
        //模拟耗时5毫秒
        TimeUnit.MILLISECONDS.sleep(5);
        //对count原子+1
        count.incrementAndGet();
    }

    public static void main(String[] args) throws InterruptedException {
        long starTime = System.currentTimeMillis();
        int threadSize = 100;
        CountDownLatch countDownLatch = new CountDownLatch(threadSize);
        for (int i = 0; i < threadSize; i++) {
            Thread thread = new Thread(() -> {
                try {
                    for (int j = 0; j < 10; j++) {
                        request();
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
                    countDownLatch.countDown();
                }
            });
            thread.start();
        }

        countDownLatch.await();
        long endTime = System.currentTimeMillis();
        System.out.println(Thread.currentThread().getName() + "，耗时：" + (endTime - starTime) + ",count=" + count);
    }
}


```

输出：

```
main，耗时：119,count=1000


```

耗时很短，并且结果和期望的一致。

关于原子类操作，都位于`java.util.concurrent.atomic`包中，下篇文章我们主要来介绍一下这些常用的类及各自的使用场景。

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
[16.java 高并发系列 - 第 16 天：](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933134&idx=1&sn=65c2b9982bb6935c54ff33082f9c111f&chksm=88621b30bf159226d41607292a1dc83186f8928744dbc44acfda381266fa2cdc006177b44095&scene=21#wechat_redirect)[JUC 中等待多线程完成的工具类 CountDownLatc](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933134&idx=1&sn=65c2b9982bb6935c54ff33082f9c111f&chksm=88621b30bf159226d41607292a1dc83186f8928744dbc44acfda381266fa2cdc006177b44095&scene=21#wechat_redirect)[h](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933134&idx=1&sn=65c2b9982bb6935c54ff33082f9c111f&chksm=88621b30bf159226d41607292a1dc83186f8928744dbc44acfda381266fa2cdc006177b44095&scene=21#wechat_redirect)  
[17.java 高并发系列 - 第 17 天：](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933144&idx=1&sn=7f0cddc92ff39835ea6652ebb3186dbf&chksm=88621b26bf15923039933b127c19f39a76214fb1d5daa7ad0eee77f961e2e3ab5f5ca3f48740&scene=21#wechat_redirect)[JUC 中的循环栅栏 CyclicBarrier 的 6 种使用场景](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933144&idx=1&sn=7f0cddc92ff39835ea6652ebb3186dbf&chksm=88621b26bf15923039933b127c19f39a76214fb1d5daa7ad0eee77f961e2e3ab5f5ca3f48740&scene=21#wechat_redirect)  
[18.java 高并发系列 - 第 18 天：](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933151&idx=1&sn=2020066b974b5f4c0823abd419e8adae&chksm=88621b21bf159237bdacfb47bd1a344f7123aabc25e3607e78d936dd554412edce5dd825003d&scene=21#wechat_redirect)[JAVA 线程池，这一篇就够了](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933151&idx=1&sn=2020066b974b5f4c0823abd419e8adae&chksm=88621b21bf159237bdacfb47bd1a344f7123aabc25e3607e78d936dd554412edce5dd825003d&scene=21#wechat_redirect)  
[19.java 高并发系列 - 第 19 天：](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933156&idx=1&sn=30f7d67b44a952eae98e688bc6035fbd&chksm=88621b1abf15920c7a0705fbe34c4ce92b94b88e08f8ecbcad3827a0950cfe4d95814b61f538&scene=21#wechat_redirect)[JUC 中的 Executor 框架详解 1](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933156&idx=1&sn=30f7d67b44a952eae98e688bc6035fbd&chksm=88621b1abf15920c7a0705fbe34c4ce92b94b88e08f8ecbcad3827a0950cfe4d95814b61f538&scene=21#wechat_redirect)

[20.java 高并发系列 - 第 20 天：](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933160&idx=1&sn=62649485b065f68c0fc59bb502ed42df&chksm=88621b16bf159200d5e25d11ab7036c60e3f923da3212ae4dd148753d02593a45ce0e9b886c4&scene=21#wechat_redirect)[JUC 中的 Executor 框架详解 2](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933160&idx=1&sn=62649485b065f68c0fc59bb502ed42df&chksm=88621b16bf159200d5e25d11ab7036c60e3f923da3212ae4dd148753d02593a45ce0e9b886c4&scene=21#wechat_redirect)

**java 高并发系列连载中，总计估计会有四五十篇文章。**

**跟着阿里 p7 学并发，微信公众号：****javacode2018**

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06AcmgEdFkkWEgWeMkg0tpVAH0UK9CMukCQEk0KdnicBdPCgg2sEXr6nG0NKGDGZcrcj7ZaHF8Dnudw/640?wx_fmt=jpeg)