> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933130&idx=1&sn=cecc6bd906e79a86510c1fbb0e66cd21&chksm=88621b34bf159222042da8ed4b633e94ca04a614d290d54a952a668459a339ebec0c754d562d&token=702505185&lang=zh_CN&scene=21#wechat_redirect)

**java 高并发系列第 15 篇文章**

Semaphore（信号量）为多线程协作提供了更为强大的控制方法，前面的文章中我们学了 synchronized 和重入锁 ReentrantLock，这 2 种锁一次都只能允许一个线程访问一个资源，而信号量可以控制有多少个线程可以访问特定的资源。

**Semaphore 常用场景：限流**

举个例子：

比如有个停车场，有 5 个空位，门口有个门卫，手中 5 把钥匙分别对应 5 个车位上面的锁，来一辆车，门卫会给司机一把钥匙，然后进去找到对应的车位停下来，出去的时候司机将钥匙归还给门卫。停车场生意比较好，同时来了 100 两车，门卫手中只有 5 把钥匙，同时只能放 5 辆车进入，其他车只能等待，等有人将钥匙归还给门卫之后，才能让其他车辆进入。

上面的例子中门卫就相当于 Semaphore，车钥匙就相当于许可证，车就相当于线程。

Semaphore 主要方法
--------------

**Semaphore(int permits)**：构造方法，参数表示许可证数量，用来创建信号量

**Semaphore(int permits,boolean fair)**：构造方法，当 fair 等于 true 时，创建具有给定许可数的计数信号量并设置为公平信号量

**void acquire() throws InterruptedException**：从此信号量获取 1 个许可前线程将一直阻塞，相当于一辆车占了一个车位，此方法会响应线程中断，表示调用线程的 interrupt 方法，会使该方法抛出 InterruptedException 异常  

**void acquire(int permits) throws InterruptedException** ：和 acquire() 方法类似，参数表示需要获取许可的数量；比如一个大卡车要入停车场，由于车比较大，需要申请 3 个车位才可以停放

**void acquireUninterruptibly(int permits)** ：和 acquire(int permits) 方法类似，只是不会响应线程中断  

**boolean tryAcquire()**：尝试获取 1 个许可，不管是否能够获取成功，都立即返回，true 表示获取成功，false 表示获取失败

**boolean tryAcquire(int permits)**：和 tryAcquire()，表示尝试获取 permits 个许可

**boolean tryAcquire(long timeout, TimeUnit unit) throws InterruptedException**：尝试在指定的时间内获取 1 个许可，获取成功返回 true，指定的时间过后还是无法获取许可，返回 false

**boolean tryAcquire(int permits, long timeout, TimeUnit unit) throws InterruptedException**：和 tryAcquire(long timeout, TimeUnit unit) 类似，多了一个 permits 参数，表示尝试获取 permits 个许可

**void release()**：释放一个许可，将其返回给信号量，相当于车从停车场出去时将钥匙归还给门卫

**void release(int n)**：释放 n 个许可

**int availablePermits()**：当前可用的许可数

示例 1：Semaphore 简单的使用
--------------------

```
package com.itsoku.chat12;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo1 {
    static Semaphore semaphore = new Semaphore(2);
    public static class T extends Thread {
        public T(String name) {
            super(name);
        }
        @Override
        public void run() {
            Thread thread = Thread.currentThread();
            try {
                semaphore.acquire();
                System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",获取许可!");
                TimeUnit.SECONDS.sleep(3);
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                semaphore.release();
                System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",释放许可!");
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        for (int i = 0; i < 10; i++) {
            new T("t-" + i).start();
        }
    }
}

```

输出：

```
1563715791327,t-0,获取许可!
1563715791327,t-1,获取许可!
1563715794328,t-0,释放许可!
1563715794328,t-5,获取许可!
1563715794328,t-1,释放许可!
1563715794328,t-2,获取许可!
1563715797328,t-2,释放许可!
1563715797328,t-6,获取许可!
1563715797328,t-5,释放许可!
1563715797328,t-3,获取许可!
1563715800329,t-6,释放许可!
1563715800329,t-9,获取许可!
1563715800329,t-3,释放许可!
1563715800329,t-7,获取许可!
1563715803330,t-7,释放许可!
1563715803330,t-8,获取许可!
1563715803330,t-9,释放许可!
1563715803330,t-4,获取许可!
1563715806330,t-8,释放许可!
1563715806330,t-4,释放许可!

```

代码中 `newSemaphore(2)`创建了许可数量为 2 的信号量，每个线程获取 1 个许可，同时允许两个线程获取许可，从输出中也可以看出，同时有两个线程可以获取许可，其他线程需要等待已获取许可的线程释放许可之后才能运行。为获取到许可的线程会阻塞在 `acquire()`方法上，直到获取到许可才能继续。

示例 2：获取许可之后不释放
--------------

门卫（Semaphore）有点呆，司机进去的时候给了钥匙，出来的时候不归还，门卫也不会说什么。最终结果就是其他车辆都无法进入了。

如下代码：

```
package com.itsoku.chat12;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo2 {
    static Semaphore semaphore = new Semaphore(2);
    public static class T extends Thread {
        public T(String name) {
            super(name);
        }
        @Override
        public void run() {
            Thread thread = Thread.currentThread();
            try {
                semaphore.acquire();
                System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",获取许可!");
                TimeUnit.SECONDS.sleep(3);
                System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",运行结束!");
                System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",当前可用许可数量:" + semaphore.availablePermits());
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        for (int i = 0; i < 10; i++) {
            new T("t-" + i).start();
        }
    }
}

```

输出：

```
1563716603924,t-0,获取许可!
1563716603924,t-1,获取许可!
1563716606925,t-0,运行结束!
1563716606925,t-0,当前可用许可数量:0
1563716606925,t-1,运行结束!
1563716606925,t-1,当前可用许可数量:0

```

上面程序运行后一直无法结束，观察一下代码，代码中获取许可后，没有释放许可的代码，最终导致，可用许可数量为 0，其他线程无法获取许可，会在 `semaphore.acquire();`处等待，导致程序无法结束。

示例 3：释放许可正确的姿势
--------------

示例 1 中，在 finally 里面释放锁，会有问题么？

如果获取锁的过程中发生异常，导致获取锁失败，最后 finally 里面也释放了许可，最终会怎么样，导致许可数量凭空增长了。

示例代码：

```
package com.itsoku.chat12;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo3 {
    static Semaphore semaphore = new Semaphore(1);
    public static class T extends Thread {
        public T(String name) {
            super(name);
        }
        @Override
        public void run() {
            Thread thread = Thread.currentThread();
            try {
                semaphore.acquire();
                System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",获取许可,当前可用许可数量:" + semaphore.availablePermits());
                //休眠100秒
                TimeUnit.SECONDS.sleep(100);
                System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",运行结束!");
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                semaphore.release();
            }
            System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",当前可用许可数量:" + semaphore.availablePermits());
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T t1 = new T("t1");
        t1.start();
        //休眠1秒
        TimeUnit.SECONDS.sleep(1);
        T t2 = new T("t2");
        t2.start();
        //休眠1秒
        TimeUnit.SECONDS.sleep(1);
        T t3 = new T("t3");
        t3.start();
        //给t2和t3发送中断信号
        t2.interrupt();
        t3.interrupt();
    }
}

```

输出：

```
1563717279058,t1,获取许可,当前可用许可数量:0
java.lang.InterruptedException
1563717281060,t2,当前可用许可数量:1
    at java.util.concurrent.locks.AbstractQueuedSynchronizer.doAcquireSharedInterruptibly(AbstractQueuedSynchronizer.java:998)
1563717281060,t3,当前可用许可数量:2
    at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquireSharedInterruptibly(AbstractQueuedSynchronizer.java:1304)
    at java.util.concurrent.Semaphore.acquire(Semaphore.java:312)
    at com.itsoku.chat12.Demo3$T.run(Demo3.java:21)
java.lang.InterruptedException
    at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquireSharedInterruptibly(AbstractQueuedSynchronizer.java:1302)
    at java.util.concurrent.Semaphore.acquire(Semaphore.java:312)
    at com.itsoku.chat12.Demo3$T.run(Demo3.java:21)

```

程序中信号量许可数量为 1，创建了 3 个线程获取许可，线程 t1 获取成功了，然后休眠 100 秒。其他两个线程阻塞在 `semaphore.acquire();`方法处，代码中对线程 t2、t3 发送中断信号，我们看一下 Semaphore 中 acquire 的源码：

```
public
 
void
 acquire
()
 
throws
 
InterruptedException
```

这个方法会响应线程中断，主线程中对 t2、t3 发送中断信号之后， `acquire()`方法会触发 `InterruptedException`异常，t2、t3 最终没有获取到许可，但是他们都执行了 finally 中的释放许可的操作，最后导致许可数量变为了 2，导致许可数量增加了。所以程序中释放许可的方式有问题。需要改进一下，获取许可成功才去释放锁。

**正确的释放锁的方式，如下：**

```
package com.itsoku.chat12;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo4 {
    static Semaphore semaphore = new Semaphore(1);
    public static class T extends Thread {
        public T(String name) {
            super(name);
        }
        @Override
        public void run() {
            Thread thread = Thread.currentThread();
            //获取许可是否成功
            boolean acquireSuccess = false;
            try {
                semaphore.acquire();
                acquireSuccess = true;
                System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",获取许可,当前可用许可数量:" + semaphore.availablePermits());
                //休眠100秒
                TimeUnit.SECONDS.sleep(5);
                System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",运行结束!");
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                if (acquireSuccess) {
                    semaphore.release();
                }
            }
            System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",当前可用许可数量:" + semaphore.availablePermits());
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T t1 = new T("t1");
        t1.start();
        //休眠1秒
        TimeUnit.SECONDS.sleep(1);
        T t2 = new T("t2");
        t2.start();
        //休眠1秒
        TimeUnit.SECONDS.sleep(1);
        T t3 = new T("t3");
        t3.start();
        //给t2和t3发送中断信号
        t2.interrupt();
        t3.interrupt();
    }
}

```

输出：

```
1563717751655,t1,获取许可,当前可用许可数量:0
1563717753657,t3,当前可用许可数量:0
java.lang.InterruptedException
1563717753657,t2,当前可用许可数量:0
    at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquireSharedInterruptibly(AbstractQueuedSynchronizer.java:1302)
    at java.util.concurrent.Semaphore.acquire(Semaphore.java:312)
    at com.itsoku.chat12.Demo4$T.run(Demo4.java:23)
java.lang.InterruptedException
    at java.util.concurrent.locks.AbstractQueuedSynchronizer.doAcquireSharedInterruptibly(AbstractQueuedSynchronizer.java:998)
    at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquireSharedInterruptibly(AbstractQueuedSynchronizer.java:1304)
    at java.util.concurrent.Semaphore.acquire(Semaphore.java:312)
    at com.itsoku.chat12.Demo4$T.run(Demo4.java:23)
1563717756656,t1,运行结束!
1563717756656,t1,当前可用许可数量:1

```

程序中增加了一个变量 `acquireSuccess`用来标记获取许可是否成功，在 finally 中根据这个变量是否为 true，来确定是否释放许可。

示例 4：在规定的时间内希望获取许可
------------------

司机来到停车场，发现停车场已经满了，只能在外等待内部的车出来之后才能进去，但是要等多久，他自己也不知道，他希望等 10 分钟，如果还是无法进去，就不到这里停车了。

Semaphore 内部 2 个方法可以提供超时获取许可的功能：

```
public boolean tryAcquire(long timeout, TimeUnit unit) throws InterruptedException
public boolean tryAcquire(int permits, long timeout, TimeUnit unit)
        throws InterruptedException 

```

在指定的时间内去尝试获取许可，如果能够获取到，返回 true，获取不到返回 false。

**示例代码：**

```
package com.itsoku.chat12;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo5 {
    static Semaphore semaphore = new Semaphore(1);
    public static class T extends Thread {
        public T(String name) {
            super(name);
        }
        @Override
        public void run() {
            Thread thread = Thread.currentThread();
            //获取许可是否成功
            boolean acquireSuccess = false;
            try {
                //尝试在1秒内获取许可，获取成功返回true，否则返回false
                System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",尝试获取许可,当前可用许可数量:" + semaphore.availablePermits());
                acquireSuccess = semaphore.tryAcquire(1, TimeUnit.SECONDS);
                //获取成功执行业务代码
                if (acquireSuccess) {
                    System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",获取许可成功,当前可用许可数量:" + semaphore.availablePermits());
                    //休眠5秒
                    TimeUnit.SECONDS.sleep(5);
                } else {
                    System.out.println(System.currentTimeMillis() + "," + thread.getName() + ",获取许可失败,当前可用许可数量:" + semaphore.availablePermits());
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                if (acquireSuccess) {
                    semaphore.release();
                }
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T t1 = new T("t1");
        t1.start();
        //休眠1秒
        TimeUnit.SECONDS.sleep(1);
        T t2 = new T("t2");
        t2.start();
        //休眠1秒
        TimeUnit.SECONDS.sleep(1);
        T t3 = new T("t3");
        t3.start();
    }
}

```

输出：

```
1563718410202,t1,尝试获取许可,当前可用许可数量:1
1563718410202,t1,获取许可成功,当前可用许可数量:0
1563718411203,t2,尝试获取许可,当前可用许可数量:0
1563718412203,t3,尝试获取许可,当前可用许可数量:0
1563718412204,t2,获取许可失败,当前可用许可数量:0
1563718413204,t3,获取许可失败,当前可用许可数量:0

```

代码中许可数量为 1， `semaphore.tryAcquire(1,TimeUnit.SECONDS);`：表示尝试在 1 秒内获取许可，获取成功立即返回 true，超过 1 秒还是获取不到，返回 false。线程 t1 获取许可成功，之后休眠了 5 秒，从输出中可以看出 t2 和 t3 都尝试了 1 秒，获取失败。

其他一些使用说明
--------

1.  Semaphore 默认创建的是非公平的信号量，什么意思呢？这个涉及到公平与非公平。举个例子：5 个车位，允许 5 个车辆进去，来了 100 辆车，只能进去 5 辆，其他 95 在外面排队等着。里面刚好出来了 1 辆，此时刚好又来了 10 辆车，这 10 辆车是直接插队到其他 95 辆前面去，还是到 95 辆后面去排队呢？让新来的去排队就表示公平，直接去插队争抢第一个，就表示不公平。对于停车场，排队肯定更好一些。不过对于信号量来说不公平的效率更高一些，所以默认是不公平的。
    
2.  建议阅读以下 Semaphore 的源码，对常用的方法有个了解，不需要都记住，用的时候也方便查询就好。
    
3.  方法中带有 `throwsInterruptedException`声明的，表示这个方法会响应线程中断信号，什么意思？表示调用线程的 `interrupt()`方法后，会让这些方法触发 `InterruptedException`异常，即使这些方法处于阻塞状态，也会立即返回，并抛出 `InterruptedException`异常，线程中断信号也会被清除。
    

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

[14.java 高并发系列 - 第 14 天: JUC 中的 LockSupport 工具类](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933125&idx=1&sn=382528aeb341727bafb02bb784ff3d4f&chksm=88621b3bbf15922d93bfba11d700724f1e59ef8a74f44adb7e131a4c3d1465f0dc539297f7f3&scene=21#wechat_redirect)[](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933116&idx=1&sn=83ae2d1381e3b8a425e65a9fa7888d38&chksm=88621ac2bf1593d4de1c5f6905c31c7d88ac4b53c0c5c071022ba2e25803fc734078c1de589c&scene=21#wechat_redirect)

**java 高并发系列连载中，总计估计会有四五十篇文章，可以关注公众号：javacode2018，获取最新文章。**

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06AcmgEdFkkWEgWeMkg0tpVAH0UK9CMukCQEk0KdnicBdPCgg2sEXr6nG0NKGDGZcrcj7ZaHF8Dnudw/640?wx_fmt=jpeg)