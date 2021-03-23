> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933116&idx=1&sn=83ae2d1381e3b8a425e65a9fa7888d38&chksm=88621ac2bf1593d4de1c5f6905c31c7d88ac4b53c0c5c071022ba2e25803fc734078c1de589c&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)

**java 高并发系列第 12 篇文章**
----------------------

本篇文章开始将 juc 中常用的一些类，估计会有十来篇。  

synchronized 的局限性
-----------------

synchronized 是 java 内置的关键字，它提供了一种独占的加锁方式。synchronized 的获取和释放锁由 jvm 实现，用户不需要显示的释放锁，非常方便，然而 synchronized 也有一定的局限性，例如：

1.  当线程尝试获取锁的时候，如果获取不到锁会一直阻塞，这个阻塞的过程，用户无法控制
    
2.  如果获取锁的线程进入休眠或者阻塞，除非当前线程异常，否则其他线程尝试获取锁必须一直等待
    

JDK1.5 之后发布，加入了 Doug Lea 实现的 java.util.concurrent 包。包内提供了 Lock 类，用来提供更多扩展的加锁功能。Lock 弥补了 synchronized 的局限，提供了更加细粒度的加锁功能。

ReentrantLock
-------------

ReentrantLock 是 Lock 的默认实现，在聊 ReentranLock 之前，我们需要先弄清楚一些概念：

1.  可重入锁：可重入锁是指同一个线程可以多次获得同一把锁；ReentrantLock 和关键字 Synchronized 都是可重入锁
    
2.  可中断锁：可中断锁时只线程在获取锁的过程中，是否可以相应线程中断操作。synchronized 是不可中断的，ReentrantLock 是可中断的
    
3.  公平锁和非公平锁：公平锁是指多个线程尝试获取同一把锁的时候，获取锁的顺序按照线程到达的先后顺序获取，而不是随机插队的方式获取。synchronized 是非公平锁，而 ReentrantLock 是两种都可以实现，不过默认是非公平锁
    

ReentrantLock 基本使用
------------------

我们使用 3 个线程来对一个共享变量 ++ 操作，先使用 **synchronized** 实现，然后使用 **ReentrantLock** 实现。

**synchronized 方式**：

```
package com.itsoku.chat06;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo2 {
    private static int num = 0;
    private static synchronized void add() {
        num++;
    }
    public static class T extends Thread {
        @Override
        public void run() {
            for (int i = 0; i < 10000; i++) {
                Demo2.add();
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T t1 = new T();
        T t2 = new T();
        T t3 = new T();
        t1.start();
        t2.start();
        t3.start();
        t1.join();
        t2.join();
        t3.join();
        System.out.println(Demo2.num);
    }
}

```

ReentrantLock 方式：

```
package com.itsoku.chat06;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo3 {
    private static int num = 0;
    private static ReentrantLock lock = new ReentrantLock();
    private static void add() {
        lock.lock();
        try {
            num++;
        } finally {
            lock.unlock();
        }
    }
    public static class T extends Thread {
        @Override
        public void run() {
            for (int i = 0; i < 10000; i++) {
                Demo3.add();
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T t1 = new T();
        T t2 = new T();
        T t3 = new T();
        t1.start();
        t2.start();
        t3.start();
        t1.join();
        t2.join();
        t3.join();
        System.out.println(Demo3.num);
    }
}

```

**ReentrantLock 的使用过程：**

1.  **创建锁：ReentrantLock lock = new ReentrantLock();**
    
2.  **获取锁：lock.lock()**
    
3.  **释放锁：lock.unlock();**
    

对比上面的代码，与关键字 synchronized 相比，ReentrantLock 锁有明显的操作过程，开发人员必须手动的指定何时加锁，何时释放锁，正是因为这样手动控制，ReentrantLock 对逻辑控制的灵活度要远远胜于关键字 synchronized，上面代码需要注意 **lock.unlock()** 一定要放在 finally 中，否则，若程序出现了异常，锁没有释放，那么其他线程就再也没有机会获取这个锁了。

ReentrantLock 是可重入锁
-------------------

来验证一下 ReentrantLock 是可重入锁，实例代码：

```
package com.itsoku.chat06;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo4 {
    private static int num = 0;
    private static ReentrantLock lock = new ReentrantLock();
    private static void add() {
        lock.lock();
        lock.lock();
        try {
            num++;
        } finally {
            lock.unlock();
            lock.unlock();
        }
    }
    public static class T extends Thread {
        @Override
        public void run() {
            for (int i = 0; i < 10000; i++) {
                Demo4.add();
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T t1 = new T();
        T t2 = new T();
        T t3 = new T();
        t1.start();
        t2.start();
        t3.start();
        t1.join();
        t2.join();
        t3.join();
        System.out.println(Demo4.num);
    }
}

```

上面代码中 add() 方法中，当一个线程进入的时候，会执行 2 次获取锁的操作，运行程序可以正常结束，并输出和期望值一样的 30000，假如 ReentrantLock 是不可重入的锁，那么同一个线程第 2 次获取锁的时候由于前面的锁还未释放而导致死锁，程序是无法正常结束的。ReentrantLock 命名也挺好的 Re entrant Lock，和其名字一样，可重入锁。

代码中还有几点需要注意：

1.  **lock() 方法和 unlock() 方法需要成对出现，锁了几次，也要释放几次，否则后面的线程无法获取锁了；可以将 add 中的 unlock 删除一个事实，上面代码运行将无法结束**
    
2.  **unlock() 方法放在 finally 中执行，保证不管程序是否有异常，锁必定会释放**
    

ReentrantLock 实现公平锁
-------------------

在大多数情况下，锁的申请都是非公平的，也就是说，线程 1 首先请求锁 A，接着线程 2 也请求了锁 A。那么当锁 A 可用时，是线程 1 可获得锁还是线程 2 可获得锁呢？这是不一定的，系统只是会从这个锁的等待队列中随机挑选一个，因此不能保证其公平性。这就好比买票不排队，大家都围在售票窗口前，售票员忙的焦头烂额，也顾及不上谁先谁后，随便找个人出票就完事了，最终导致的结果是，有些人可能一直买不到票。而公平锁，则不是这样，它会按照到达的先后顺序获得资源。公平锁的一大特点是：它不会产生饥饿现象，只要你排队，最终还是可以等到资源的；synchronized 关键字默认是有 jvm 内部实现控制的，是非公平锁。而 ReentrantLock 运行开发者自己设置锁的公平性。

看一下 jdk 中 ReentrantLock 的源码，2 个构造方法：

```
public ReentrantLock() {
    sync = new NonfairSync();
}
public ReentrantLock(boolean fair) {
    sync = fair ? new FairSync() : new NonfairSync();
}

```

默认构造方法创建的是非公平锁。

第 2 个构造方法，有个 fair 参数，当 fair 为 true 的时候创建的是公平锁，公平锁看起来很不错，不过要实现公平锁，系统内部肯定需要维护一个有序队列，因此公平锁的实现成本比较高，性能相对于非公平锁来说相对低一些。因此，在默认情况下，锁是非公平的，如果没有特别要求，则不建议使用公平锁。

公平锁和非公平锁在程序调度上是很不一样，来一个公平锁示例看一下：

```
package com.itsoku.chat06;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo5 {
    private static int num = 0;
    private static ReentrantLock fairLock = new ReentrantLock(true);
    public static class T extends Thread {
        public T(String name) {
            super(name);
        }
        @Override
        public void run() {
            for (int i = 0; i < 5; i++) {
                fairLock.lock();
                try {
                    System.out.println(this.getName() + "获得锁!");
                } finally {
                    fairLock.unlock();
                }
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T t1 = new T("t1");
        T t2 = new T("t2");
        T t3 = new T("t3");
        t1.start();
        t2.start();
        t3.start();
        t1.join();
        t2.join();
        t3.join();
    }
}

```

运行结果输出：

```
t1获得锁!
t2获得锁!
t3获得锁!
t1获得锁!
t2获得锁!
t3获得锁!
t1获得锁!
t2获得锁!
t3获得锁!
t1获得锁!
t2获得锁!
t3获得锁!
t1获得锁!
t2获得锁!
t3获得锁!

```

看一下输出的结果，锁时按照先后顺序获得的。

修改一下上面代码，改为非公平锁试试，如下：

```
ReentrantLock
 fairLock 
=
 
new
 
ReentrantLock
(
false
);
```

运行结果如下：

```
t1获得锁!
t3获得锁!
t3获得锁!
t3获得锁!
t3获得锁!
t1获得锁!
t1获得锁!
t1获得锁!
t1获得锁!
t2获得锁!
t2获得锁!
t2获得锁!
t2获得锁!
t2获得锁!
t3获得锁!

```

可以看到 t3 可能会连续获得锁，结果是比较随机的，不公平的。

ReentrantLock 获取锁的过程是可中断的
-------------------------

对于 synchronized 关键字，如果一个线程在等待获取锁，最终只有 2 种结果：

1.  要么获取到锁然后继续后面的操作
    
2.  要么一直等待，直到其他线程释放锁为止
    

而 ReentrantLock 提供了另外一种可能，就是在等的获取锁的过程中（**发起获取锁请求到还未获取到锁这段时间内**）是可以被中断的，也就是说在等待锁的过程中，程序可以根据需要取消获取锁的请求。有些使用这个操作是非常有必要的。比如：你和好朋友越好一起去打球，如果你等了半小时朋友还没到，突然你接到一个电话，朋友由于突发状况，不能来了，那么你一定达到回府。中断操作正是提供了一套类似的机制，如果一个线程正在等待获取锁，那么它依然可以收到一个通知，被告知无需等待，可以停止工作了。

示例代码：

```
package com.itsoku.chat06;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo6 {
    private static ReentrantLock lock1 = new ReentrantLock(false);
    private static ReentrantLock lock2 = new ReentrantLock(false);
    public static class T extends Thread {
        int lock;
        public T(String name, int lock) {
            super(name);
            this.lock = lock;
        }
        @Override
        public void run() {
            try {
                if (this.lock == 1) {
                    lock1.lockInterruptibly();
                    TimeUnit.SECONDS.sleep(1);
                    lock2.lockInterruptibly();
                } else {
                    lock2.lockInterruptibly();
                    TimeUnit.SECONDS.sleep(1);
                    lock1.lockInterruptibly();
                }
            } catch (InterruptedException e) {
                System.out.println("中断标志:" + this.isInterrupted());
                e.printStackTrace();
            } finally {
                if (lock1.isHeldByCurrentThread()) {
                    lock1.unlock();
                }
                if (lock2.isHeldByCurrentThread()) {
                    lock2.unlock();
                }
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T t1 = new T("t1", 1);
        T t2 = new T("t2", 2);
        t1.start();
        t2.start();
    }
}

```

先运行一下上面代码，发现程序无法结束，使用 jstack 查看线程堆栈信息，发现 2 个线程死锁了。

```
Found one Java-level deadlock:
=============================
"t2":
  waiting for ownable synchronizer 0x0000000717380c20, (a java.util.concurrent.locks.ReentrantLock$NonfairSync),
  which is held by "t1"
"t1":
  waiting for ownable synchronizer 0x0000000717380c50, (a java.util.concurrent.locks.ReentrantLock$NonfairSync),
  which is held by "t2"

```

lock1 被线程 t1 占用，lock2 倍线程 t2 占用，线程 t1 在等待获取 lock2，线程 t2 在等待获取 lock1，都在相互等待获取对方持有的锁，最终产生了死锁，如果是在 synchronized 关键字情况下发生了死锁现象，程序是无法结束的。

我们队上面代码改造一下，线程 t2 一直无法获取到 lock1，那么等待 5 秒之后，我们中断获取锁的操作。主要修改一下 main 方法，如下：

```
T t1 = new T("t1", 1);
T t2 = new T("t2", 2);
t1.start();
t2.start();
TimeUnit.SECONDS.sleep(5);
t2.interrupt();

```

新增了 2 行代码 `TimeUnit.SECONDS.sleep(5);t2.interrupt();`，程序可以结束了，运行结果：

```
java.lang.InterruptedException
    at java.util.concurrent.locks.AbstractQueuedSynchronizer.doAcquireInterruptibly(AbstractQueuedSynchronizer.java:898)
    at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquireInterruptibly(AbstractQueuedSynchronizer.java:1222)
    at java.util.concurrent.locks.ReentrantLock.lockInterruptibly(ReentrantLock.java:335)
    at com.itsoku.chat06.Demo6$T.run(Demo6.java:31)
中断标志:false

```

从上面信息中可以看出，代码的 31 行触发了异常，**中断标志输出：false**

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06Azyzk0YRj8kC2PcxA2GibvHstNJy2MRG3je2Z2jY6nrR5ibWIh7nt09NEibiaekaAdjWghSUib4ib7BpwQ/640?wx_fmt=png)

t2 在 31 行一直获取不到 lock1 的锁，主线程中等待了 5 秒之后，t2 线程调用了 `interrupt()`方法，将线程的中断标志置为 true，此时 31 行会触发 `InterruptedException`异常，然后线程 t2 可以继续向下执行，释放了 lock2 的锁，然后线程 t1 可以正常获取锁，程序得以继续进行。线程发送中断信号触发 InterruptedException 异常之后，中断标志将被清空。

关于获取锁的过程中被中断，注意几点:

1.  **ReentrankLock 中必须使用实例方法 `lockInterruptibly()`获取锁时，在线程调用 interrupt() 方法之后，才会引发 `InterruptedException`异常**
    
2.  **线程调用 interrupt() 之后，线程的中断标志会被置为 true**
    
3.  **触发 InterruptedException 异常之后，线程的中断标志有会被清空，即置为 false**
    
4.  **所以当线程调用 interrupt() 引发 InterruptedException 异常，中断标志的变化是: false->true->false**
    

ReentrantLock 锁申请等待限时
---------------------

申请锁等待限时是什么意思？一般情况下，获取锁的时间我们是不知道的，synchronized 关键字获取锁的过程中，只能等待其他线程把锁释放之后才能够有机会获取到所。所以获取锁的时间有长有短。如果获取锁的时间能够设置超时时间，那就非常好了。

ReentrantLock 刚好提供了这样功能，给我们提供了获取锁限时等待的方法 `tryLock()`，可以选择传入时间参数，表示等待指定的时间，无参则表示立即返回锁申请的结果：true 表示获取锁成功，false 表示获取锁失败。

### tryLock 无参方法

看一下源码中 tryLock 方法：

```
public
 
boolean
 tryLock
()
```

返回 boolean 类型的值，此方法会立即返回，结果表示获取锁是否成功，示例：

```
package com.itsoku.chat06;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo8 {
    private static ReentrantLock lock1 = new ReentrantLock(false);
    public static class T extends Thread {
        public T(String name) {
            super(name);
        }
        @Override
        public void run() {
            try {
                System.out.println(System.currentTimeMillis() + ":" + this.getName() + "开始获取锁!");
                //获取锁超时时间设置为3秒，3秒内是否能否获取锁都会返回
                if (lock1.tryLock()) {
                    System.out.println(System.currentTimeMillis() + ":" + this.getName() + "获取到了锁!");
                    //获取到锁之后，休眠5秒
                    TimeUnit.SECONDS.sleep(5);
                } else {
                    System.out.println(System.currentTimeMillis() + ":" + this.getName() + "未能获取到锁!");
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                if (lock1.isHeldByCurrentThread()) {
                    lock1.unlock();
                }
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T t1 = new T("t1");
        T t2 = new T("t2");
        t1.start();
        t2.start();
    }
}

```

代码中获取锁成功之后，休眠 5 秒，会导致另外一个线程获取锁失败，运行代码，输出：

```
1563356291081:t2开始获取锁!
1563356291081:t2获取到了锁!
1563356291081:t1开始获取锁!
1563356291081:t1未能获取到锁!

```

可以看到 t2 获取成功，t1 获取失败了，tryLock() 是立即响应的，中间不会有阻塞。

### tryLock 有参方法

可以明确设置获取锁的超时时间，该方法签名：

```
public
 
boolean
 tryLock
(
long
 timeout
,
 
TimeUnit
 unit
)
 
throws
 
InterruptedException
```

该方法在指定的时间内不管是否可以获取锁，都会返回结果，返回 true，表示获取锁成功，返回 false 表示获取失败。此方法由 2 个参数，第一个参数是时间类型，是一个枚举，可以表示时、分、秒、毫秒等待，使用比较方便，第 1 个参数表示在时间类型上的时间长短。此方法在执行的过程中，如果调用了线程的中断 interrupt() 方法，会触发 InterruptedException 异常。

示例：

```
package com.itsoku.chat06;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo7 {
    private static ReentrantLock lock1 = new ReentrantLock(false);
    public static class T extends Thread {
        public T(String name) {
            super(name);
        }
        @Override
        public void run() {
            try {
                System.out.println(System.currentTimeMillis() + ":" + this.getName() + "开始获取锁!");
                //获取锁超时时间设置为3秒，3秒内是否能否获取锁都会返回
                if (lock1.tryLock(3, TimeUnit.SECONDS)) {
                    System.out.println(System.currentTimeMillis() + ":" + this.getName() + "获取到了锁!");
                    //获取到锁之后，休眠5秒
                    TimeUnit.SECONDS.sleep(5);
                } else {
                    System.out.println(System.currentTimeMillis() + ":" + this.getName() + "未能获取到锁!");
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                if (lock1.isHeldByCurrentThread()) {
                    lock1.unlock();
                }
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T t1 = new T("t1");
        T t2 = new T("t2");
        t1.start();
        t2.start();
    }
}

```

程序中调用了 ReentrantLock 的实例方法 `tryLock(3,TimeUnit.SECONDS)`，表示获取锁的超时时间是 3 秒，3 秒后不管是否能否获取锁，该方法都会有返回值，获取到锁之后，内部休眠了 5 秒，会导致另外一个线程获取锁失败。

运行程序，输出：

```
1563355512901:t2开始获取锁!
1563355512901:t1开始获取锁!
1563355512902:t2获取到了锁!
1563355515904:t1未能获取到锁!

```

输出结果中分析，t2 获取到锁了，然后休眠了 5 秒，t1 获取锁失败，t1 打印了 2 条信息，时间相差 3 秒左右。

**关于 tryLock() 方法和 tryLock(long timeout, TimeUnit unit) 方法，说明一下：**

1.  都会返回 boolean 值，结果表示获取锁是否成功
    
2.  tryLock() 方法，不管是否获取成功，都会立即返回；而有参的 tryLock 方法会尝试在指定的时间内去获取锁，中间会阻塞的现象，在指定的时间之后会不管是否能够获取锁都会返回结果
    
3.  tryLock() 方法不会响应线程的中断方法；而有参的 tryLock 方法会响应线程的中断方法，而出发 `InterruptedException`异常，这个从 2 个方法的声明上可以可以看出来
    

ReentrantLock 其他常用的方法
---------------------

1.  isHeldByCurrentThread：实例方法，判断当前线程是否持有 ReentrantLock 的锁，上面代码中有使用过。
    

获取锁的 4 种方法对比
------------

<table width="743"><thead><tr><th data-style="box-sizing: border-box; padding: 0.5rem 1rem; text-align: left; border-top-width: 1px; border-color: rgb(233, 235, 236);">获取锁的方法</th><th data-style="box-sizing: border-box; padding: 0.5rem 1rem; text-align: left; border-top-width: 1px; border-color: rgb(233, 235, 236);">是否立即响应 (不会阻塞)</th><th data-style="box-sizing: border-box; padding: 0.5rem 1rem; text-align: left; border-top-width: 1px; border-color: rgb(233, 235, 236);">是否响应中断</th></tr></thead><tbody><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">lock()</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">×</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">×</td></tr><tr data-darkmode-bgcolor-16079190581232="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190581232="rgb(248, 248, 248)" data-style="box-sizing: border-box; background-color: rgb(248, 248, 248);"><td data-darkmode-bgcolor-16079190581232="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190581232="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">lockInterruptibly()</td><td data-darkmode-bgcolor-16079190581232="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190581232="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">×</td><td data-darkmode-bgcolor-16079190581232="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190581232="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">√</td></tr><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">tryLock()</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">√</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">×</td></tr><tr data-darkmode-bgcolor-16079190581232="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190581232="rgb(248, 248, 248)" data-style="box-sizing: border-box; background-color: rgb(248, 248, 248);"><td data-darkmode-bgcolor-16079190581232="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190581232="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">tryLock(long timeout, TimeUnit unit)</td><td data-darkmode-bgcolor-16079190581232="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190581232="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">×</td><td data-darkmode-bgcolor-16079190581232="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190581232="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">√</td></tr></tbody></table>

总结
--

1.  ReentrantLock 可以实现公平锁和非公平锁
    
2.  ReentrantLock 默认实现的是非公平锁
    
3.  ReentrantLock 的获取锁和释放锁必须成对出现，锁了几次，也要释放几次
    
4.  释放锁的操作必须放在 finally 中执行
    
5.  lockInterruptibly() 实例方法可以相应线程的中断方法，调用线程的 interrupt() 方法时，lockInterruptibly() 方法会触发 `InterruptedException`异常
    
6.  关于 `InterruptedException`异常说一下，看到方法声明上带有 `throwsInterruptedException`，表示该方法可以相应线程中断，调用线程的 interrupt() 方法时，这些方法会触发 `InterruptedException`异常，触发 InterruptedException 时，线程的中断中断状态会被清除。所以如果程序由于调用 `interrupt()`方法而触发 `InterruptedException`异常，线程的标志由默认的 false 变为 ture，然后又变为 false
    
7.  实例方法 tryLock() 获会尝试获取锁，会立即返回，返回值表示是否获取成功
    
8.  实例方法 tryLock(long timeout, TimeUnit unit) 会在指定的时间内尝试获取锁，指定的时间内是否能够获取锁，都会返回，返回值表示是否获取锁成功，该方法会响应线程的中断
    

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

**java 高并发系列连载中，总计估计会有四五十篇文章，可以关注公众号：javacode2018，获取最新文章。**

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06BvKtvNz52fglTy1VbMPApsVKKxWl8sL9gcKO32icd0l8kWbcVL79RAGqt3UpsPX5OExmHaz50qy5g/640?wx_fmt=jpeg)