> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933125&idx=1&sn=382528aeb341727bafb02bb784ff3d4f&chksm=88621b3bbf15922d93bfba11d700724f1e59ef8a74f44adb7e131a4c3d1465f0dc539297f7f3&token=1338873010&lang=zh_CN&scene=21#wechat_redirect)

**java 高并发系列第 14 篇文章**

**本文主要内容：**

1.  **讲解 3 种让线程等待和唤醒的方法，每种方法配合具体的示例**
    
2.  **介绍 LockSupport 主要用法**
    
3.  **对比 3 种方式，了解他们之间的区别**
    

**LockSupport** 位于 **java.util.concurrent**（**简称 juc**）包中，算是 juc 中一个基础类，juc 中很多地方都会使用 LockSupport，非常重要，希望大家一定要掌握。

关于线程等待 / 唤醒的方法，前面的文章中我们已经讲过 2 种了：

1.  方式 1：使用 Object 中的 wait() 方法让线程等待，使用 Object 中的 notify() 方法唤醒线程
    
2.  方式 2：使用 juc 包中 Condition 的 await() 方法让线程等待，使用 signal() 方法唤醒线程
    

这 2 种方式，我们先来看一下示例。

使用 Object 类中的方法实现线程等待和唤醒
------------------------

### 示例 1：

```
package com.itsoku.chat10;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo1 {
    static Object lock = new Object();
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            synchronized (lock) {
                System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " start!");
                try {
                    lock.wait();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " 被唤醒!");
            }
        });
        t1.setName("t1");
        t1.start();
        //休眠5秒
        TimeUnit.SECONDS.sleep(5);
        synchronized (lock) {
            lock.notify();
        }
    }
}

```

输出：

```
1563592938744,t1 start!
1563592943745,t1 被唤醒!

```

t1 线程中调用 `lock.wait()`方法让 t1 线程等待，主线程中休眠 5 秒之后，调用 `lock.notify()`方法唤醒了 t1 线程，输出的结果中，两行结果相差 5 秒左右，程序正常退出。

### 示例 2

我们把上面代码中 main 方法内部改一下，删除了 `synchronized`关键字，看看有什么效果：

```
package com.itsoku.chat10;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo2 {
    static Object lock = new Object();
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " start!");
            try {
                lock.wait();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " 被唤醒!");
        });
        t1.setName("t1");
        t1.start();
        //休眠5秒
        TimeUnit.SECONDS.sleep(5);
        lock.notify();
    }
}

```

运行结果：

```
Exception in thread "t1" java.lang.IllegalMonitorStateException
1563593178811,t1 start!
    at java.lang.Object.wait(Native Method)
    at java.lang.Object.wait(Object.java:502)
    at com.itsoku.chat10.Demo2.lambda$main$0(Demo2.java:16)
    at java.lang.Thread.run(Thread.java:745)
Exception in thread "main" java.lang.IllegalMonitorStateException
    at java.lang.Object.notify(Native Method)
    at com.itsoku.chat10.Demo2.main(Demo2.java:26)

```

上面代码中将 **synchronized** 去掉了，发现调用 wait() 方法和调用 notify() 方法都抛出了 `IllegalMonitorStateException`异常，原因：**Object 类中的 wait、notify、notifyAll 用于线程等待和唤醒的方法，都必须在同步代码中运行（必须用到关键字 synchronized）**。

### 示例 3

唤醒方法在等待方法之前执行，线程能够被唤醒么？代码如下：

```
package com.itsoku.chat10;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo3 {
    static Object lock = new Object();
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            try {
                TimeUnit.SECONDS.sleep(5);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            synchronized (lock) {
                System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " start!");
                try {
                    //休眠3秒
                    lock.wait();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " 被唤醒!");
            }
        });
        t1.setName("t1");
        t1.start();
        //休眠1秒之后唤醒lock对象上等待的线程
        TimeUnit.SECONDS.sleep(1);
        synchronized (lock) {
            lock.notify();
        }
        System.out.println("lock.notify()执行完毕");
    }
}

```

运行代码，输出结果：

```
lock.notify()执行完毕
1563593869797,t1 start!

```

输出了上面 2 行之后，程序一直无法结束，t1 线程调用 wait() 方法之后无法被唤醒了，从输出中可见， `notify()`方法在 `wait()`方法之前执行了，等待的线程无法被唤醒了。说明：唤醒方法在等待方法之前执行，线程无法被唤醒。

**关于 Object 类中的用户线程等待和唤醒的方法，总结一下：**

1.  **wait()/notify()/notifyAll() 方法都必须放在同步代码（必须在 synchronized 内部执行）中执行，需要先获取锁**
    
2.  **线程唤醒的方法（notify、notifyAll）需要在等待的方法（wait）之后执行，等待中的线程才可能会被唤醒，否则无法唤醒**
    

使用 Condition 实现线程的等待和唤醒
-----------------------

Condition 的使用，前面的文章讲过，对这块不熟悉的可以移步：[java 高并发系列 - 第 12 天 JUC:ReentrantLock 重入锁](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933116&idx=1&sn=83ae2d1381e3b8a425e65a9fa7888d38&chksm=88621ac2bf1593d4de1c5f6905c31c7d88ac4b53c0c5c071022ba2e25803fc734078c1de589c&scene=21#wechat_redirect)，关于 Condition 我们准备了 3 个示例。

### 示例 1

```
package com.itsoku.chat10;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo4 {
    static ReentrantLock lock = new ReentrantLock();
    static Condition condition = lock.newCondition();
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            lock.lock();
            try {
                System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " start!");
                try {
                    condition.await();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " 被唤醒!");
            } finally {
                lock.unlock();
            }
        });
        t1.setName("t1");
        t1.start();
        //休眠5秒
        TimeUnit.SECONDS.sleep(5);
        lock.lock();
        try {
            condition.signal();
        } finally {
            lock.unlock();
        }
    }
}

```

输出：

```
1563594349632,t1 start!
1563594354634,t1 被唤醒!

```

t1 线程启动之后调用 `condition.await()`方法将线程处于等待中，主线程休眠 5 秒之后调用 `condition.signal()`方法将 t1 线程唤醒成功，输出结果中 2 个时间戳相差 5 秒。

### 示例 2

我们将上面代码中的 lock.lock()、lock.unlock() 去掉，看看会发生什么。代码：

```
package com.itsoku.chat10;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo5 {
    static ReentrantLock lock = new ReentrantLock();
    static Condition condition = lock.newCondition();
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " start!");
            try {
                condition.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " 被唤醒!");
        });
        t1.setName("t1");
        t1.start();
        //休眠5秒
        TimeUnit.SECONDS.sleep(5);
        condition.signal();
    }
}

```

输出：

```
Exception in thread "t1" java.lang.IllegalMonitorStateException
1563594654865,t1 start!
    at java.util.concurrent.locks.ReentrantLock$Sync.tryRelease(ReentrantLock.java:151)
    at java.util.concurrent.locks.AbstractQueuedSynchronizer.release(AbstractQueuedSynchronizer.java:1261)
    at java.util.concurrent.locks.AbstractQueuedSynchronizer.fullyRelease(AbstractQueuedSynchronizer.java:1723)
    at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:2036)
    at com.itsoku.chat10.Demo5.lambda$main$0(Demo5.java:19)
    at java.lang.Thread.run(Thread.java:745)
Exception in thread "main" java.lang.IllegalMonitorStateException
    at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.signal(AbstractQueuedSynchronizer.java:1939)
    at com.itsoku.chat10.Demo5.main(Demo5.java:29)

```

有异常发生， `condition.await();`和 `condition.signal();`都触发了 `IllegalMonitorStateException`异常。原因：**调用 condition 中线程等待和唤醒的方法的前提是必须要先获取 lock 的锁**。

### 示例 3

唤醒代码在等待之前执行，线程能够被唤醒么？代码如下：

```
package com.itsoku.chat10;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo6 {
    static ReentrantLock lock = new ReentrantLock();
    static Condition condition = lock.newCondition();
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            try {
                TimeUnit.SECONDS.sleep(5);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            lock.lock();
            try {
                System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " start!");
                try {
                    condition.await();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " 被唤醒!");
            } finally {
                lock.unlock();
            }
        });
        t1.setName("t1");
        t1.start();
        //休眠5秒
        TimeUnit.SECONDS.sleep(1);
        lock.lock();
        try {
            condition.signal();
        } finally {
            lock.unlock();
        }
        System.out.println(System.currentTimeMillis() + ",condition.signal();执行完毕");
    }
}

```

运行结果:

```
1563594886532,condition.signal();执行完毕
1563594890532,t1 start!

```

输出上面 2 行之后，程序无法结束，代码结合输出可以看出 signal() 方法在 await() 方法之前执行的，最终 t1 线程无法被唤醒，导致程序无法结束。

**关于 Condition 中方法使用总结：**

1.  **使用 Condtion 中的线程等待和唤醒方法之前，需要先获取锁。否者会报 `IllegalMonitorStateException`异常**
    
2.  **signal() 方法先于 await() 方法之前调用，线程无法被唤醒**
    

Object 和 Condition 的局限性
-----------------------

关于 Object 和 Condtion 中线程等待和唤醒的局限性，有以下几点：

1.  **2 中方式中的让线程等待和唤醒的方法能够执行的先决条件是：线程需要先获取锁**
    
2.  **唤醒方法需要在等待方法之后调用，线程才能够被唤醒**
    

关于这 2 点，LockSupport 都不需要，就能实现线程的等待和唤醒。下面我们来说一下 LockSupport 类。

LockSupport 类介绍
---------------

LockSupport 类可以阻塞当前线程以及唤醒指定被阻塞的线程。主要是通过 **park()** 和 **unpark(thread)** 方法来实现阻塞和唤醒线程的操作的。

> 每个线程都有一个许可 (permit)，**permit 只有两个值 1 和 0**，默认是 0。
> 
> 1.  当调用 unpark(thread) 方法，就会将 thread 线程的许可 permit 设置成 1(**注意多次调用 unpark 方法，不会累加，permit 值还是 1**)。
>     
> 2.  当调用 park() 方法，如果当前线程的 permit 是 1，那么将 permit 设置为 0，并立即返回。如果当前线程的 permit 是 0，那么当前线程就会阻塞，直到别的线程将当前线程的 permit 设置为 1 时，park 方法会被唤醒，然后会将 permit 再次设置为 0，并返回。
>     
> 
> 注意：因为 permit 默认是 0，所以一开始调用 park() 方法，线程必定会被阻塞。调用 unpark(thread) 方法后，会自动唤醒 thread 线程，即 park 方法立即返回。

### LockSupport 中常用的方法

**阻塞线程**

*   void park()：阻塞当前线程，如果调用 **unpark 方法**或者**当前线程被中断**，从能从 park() 方法中返回
    
*   void park(Object blocker)：功能同方法 1，入参增加一个 Object 对象，用来记录导致线程阻塞的阻塞对象，方便进行问题排查
    
*   void parkNanos(long nanos)：阻塞当前线程，最长不超过 nanos 纳秒，增加了超时返回的特性
    
*   void parkNanos(Object blocker, long nanos)：功能同方法 3，入参增加一个 Object 对象，用来记录导致线程阻塞的阻塞对象，方便进行问题排查
    
*   void parkUntil(long deadline)：阻塞当前线程，直到 deadline，deadline 是一个绝对时间，表示某个时间的毫秒格式
    
*   void parkUntil(Object blocker, long deadline)：功能同方法 5，入参增加一个 Object 对象，用来记录导致线程阻塞的阻塞对象，方便进行问题排查；
    

**唤醒线程**

*   void unpark(Thread thread): 唤醒处于阻塞状态的指定线程
    

### 示例 1

主线程线程等待 5 秒之后，唤醒 t1 线程，代码如下：

```
package com.itsoku.chat10;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.LockSupport;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo7 {
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " start!");
            LockSupport.park();
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " 被唤醒!");
        });
        t1.setName("t1");
        t1.start();
        //休眠5秒
        TimeUnit.SECONDS.sleep(5);
        LockSupport.unpark(t1);
        System.out.println(System.currentTimeMillis() + ",LockSupport.unpark();执行完毕");
    }
}

```

输出：

```
1563597664321,t1 start!
1563597669323,LockSupport.unpark();执行完毕
1563597669323,t1 被唤醒!

```

t1 中调用 `LockSupport.park();`让当前线程 t1 等待，主线程休眠了 5 秒之后，调用 `LockSupport.unpark(t1);`将 t1 线程唤醒，输出结果中 1、3 行结果相差 5 秒左右，说明 t1 线程等待 5 秒之后，被唤醒了。

`LockSupport.park();`无参数，内部直接会让当前线程处于等待中；unpark 方法传递了一个线程对象作为参数，表示将对应的线程唤醒。

### 示例 2

唤醒方法放在等待方法之前执行，看一下线程是否能够被唤醒呢？代码如下：

```
package com.itsoku.chat10;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.LockSupport;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo8 {
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            try {
                TimeUnit.SECONDS.sleep(5);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " start!");
            LockSupport.park();
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " 被唤醒!");
        });
        t1.setName("t1");
        t1.start();
        //休眠1秒
        TimeUnit.SECONDS.sleep(1);
        LockSupport.unpark(t1);
        System.out.println(System.currentTimeMillis() + ",LockSupport.unpark();执行完毕");
    }
}

```

输出：

```
1563597994295,LockSupport.unpark();执行完毕
1563597998296,t1 start!
1563597998296,t1 被唤醒!

```

代码中启动 t1 线程，t1 线程内部休眠了 5 秒，然后主线程休眠 1 秒之后，调用了 `LockSupport.unpark(t1);`唤醒线程 t1，此时 `LockSupport.park();`方法还未执行，说明唤醒方法在等待方法之前执行的；输出结果中 2、3 行结果时间一样，表示 `LockSupport.park();`没有阻塞了，是立即返回的。

说明：**唤醒方法在等待方法之前执行，线程也能够被唤醒，这点是另外 2 中方法无法做到的。Object 和 Condition 中的唤醒必须在等待之后调用，线程才能被唤醒。而 LockSupport 中，唤醒的方法不管是在等待之前还是在等待之后调用，线程都能够被唤醒。**

### 示例 3

park() 让线程等待之后，是否能够响应线程中断？代码如下：

```
package com.itsoku.chat10;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.LockSupport;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo9 {
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " start!");
            System.out.println(Thread.currentThread().getName() + ",park()之前中断标志：" + Thread.currentThread().isInterrupted());
            LockSupport.park();
            System.out.println(Thread.currentThread().getName() + ",park()之后中断标志：" + Thread.currentThread().isInterrupted());
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + " 被唤醒!");
        });
        t1.setName("t1");
        t1.start();
        //休眠5秒
        TimeUnit.SECONDS.sleep(5);
        t1.interrupt();
    }
}

```

输出：

```
1563598536736,t1 start!
t1,park()之前中断标志：false
t1,park()之后中断标志：true
1563598541736,t1 被唤醒!

```

t1 线程中调用了 park() 方法让线程等待，主线程休眠了 5 秒之后，调用 `t1.interrupt();`给线程 t1 发送中断信号，然后线程 t1 从等待中被唤醒了，输出结果中的 1、4 行结果相差 5 秒左右，刚好是主线程休眠了 5 秒之后将 t1 唤醒了。**结论：park 方法可以相应线程中断。**

**LockSupport.park 方法让线程等待之后，唤醒方式有 2 种：**

1.  **调用 LockSupport.unpark 方法**
    
2.  **调用等待线程的 `interrupt()`方法，给等待的线程发送中断信号，可以唤醒线程**
    

### 示例 4

LockSupport 有几个阻塞放有一个 blocker 参数，这个参数什么意思，上一个实例代码，大家一看就懂了：

```
package com.itsoku.chat10;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.LockSupport;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo10 {
    static class BlockerDemo {
    }
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(() -> {
            LockSupport.park();
        });
        t1.setName("t1");
        t1.start();
        Thread t2 = new Thread(() -> {
            LockSupport.park(new BlockerDemo());
        });
        t2.setName("t2");
        t2.start();
    }
}

```

运行上面代码，然后用 jstack 查看一下线程的堆栈信息：

```
"t2" #13 prio=5 os_prio=0 tid=0x00000000293ea800 nid=0x91e0 waiting on condition [0x0000000029c3f000]
   java.lang.Thread.State: WAITING (parking)
        at sun.misc.Unsafe.park(Native Method)
        - parking to wait for  <0x00000007180bfeb0> (a com.itsoku.chat10.Demo10$BlockerDemo)
        at java.util.concurrent.locks.LockSupport.park(LockSupport.java:175)
        at com.itsoku.chat10.Demo10.lambda$main$1(Demo10.java:22)
        at com.itsoku.chat10.Demo10$$Lambda$2/824909230.run(Unknown Source)
        at java.lang.Thread.run(Thread.java:745)
"t1" #12 prio=5 os_prio=0 tid=0x00000000293ea000 nid=0x9d4 waiting on condition [0x0000000029b3f000]
   java.lang.Thread.State: WAITING (parking)
        at sun.misc.Unsafe.park(Native Method)
        at java.util.concurrent.locks.LockSupport.park(LockSupport.java:304)
        at com.itsoku.chat10.Demo10.lambda$main$0(Demo10.java:16)
        at com.itsoku.chat10.Demo10$$Lambda$1/1389133897.run(Unknown Source)
        at java.lang.Thread.run(Thread.java:745)

```

代码中，线程 t1 和 t2 的不同点是，t2 中调用 park 方法传入了一个 BlockerDemo 对象，从上面的线程堆栈信息中，发现 t2 线程的堆栈信息中多了一行 `-parking to waitfor<0x00000007180bfeb0>(a com.itsoku.chat10.Demo10$BlockerDemo)`，刚好是传入的 BlockerDemo 对象，park 传入的这个参数可以让我们在线程堆栈信息中方便排查问题，其他暂无他用。

**LockSupport 的其他等待方法，包含有超时时间了，过了超时时间，等待方法会自动返回，让线程继续运行，这些方法在此就不提供示例了，有兴趣的朋友可以自己动动手，练一练。**

线程等待和唤醒的 3 种方式做个对比
------------------

到目前为止，已经说了 3 种让线程等待和唤醒的方法了

1.  方式 1：Object 中的 wait、notify、notifyAll 方法
    
2.  方式 2：juc 中 Condition 接口提供的 await、signal、signalAll 方法
    
3.  方式 3：juc 中的 LockSupport 提供的 park、unpark 方法
    

**3 种方式对比：**

<table width="752"><thead><tr><th data-style="box-sizing: border-box; padding: 0.5rem 1rem; text-align: left; border-top-width: 1px; border-color: rgb(233, 235, 236);"><br></th><th data-style="box-sizing: border-box; padding: 0.5rem 1rem; text-align: left; border-top-width: 1px; border-color: rgb(233, 235, 236);">Object</th><th data-style="box-sizing: border-box; padding: 0.5rem 1rem; text-align: left; border-top-width: 1px; border-color: rgb(233, 235, 236);">Condtion</th><th data-style="box-sizing: border-box; padding: 0.5rem 1rem; text-align: left; border-top-width: 1px; border-color: rgb(233, 235, 236);">LockSupport</th></tr></thead><tbody><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">前置条件</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">需要在 synchronized 中运行</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">需要先获取 Lock 的锁</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">无</td></tr><tr data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; background-color: rgb(248, 248, 248);"><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">无限等待</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td></tr><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">超时等待</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td></tr><tr data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; background-color: rgb(248, 248, 248);"><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">等待到将来某个时间返回</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">不支持</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td></tr><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">等待状态中释放锁</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">会释放</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">会释放</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">不会释放</td></tr><tr data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; background-color: rgb(248, 248, 248);"><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">唤醒方法先于等待方法执行，能否唤醒线程</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">否</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">否</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">可以</td></tr><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">是否能响应线程中断</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">是</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">是</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">是</td></tr><tr data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; background-color: rgb(248, 248, 248);"><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">线程中断是否会清除中断标志</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">是</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">是</td><td data-darkmode-bgcolor-16079190603197="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079190603197="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">否</td></tr><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">是否支持等待状态中不响应中断</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">不支持</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">不支持</td></tr></tbody></table>

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

[13.java 高并发系列 - 第 13 天: JUC 中的 Condition 对象](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933116&idx=1&sn=83ae2d1381e3b8a425e65a9fa7888d38&chksm=88621ac2bf1593d4de1c5f6905c31c7d88ac4b53c0c5c071022ba2e25803fc734078c1de589c&scene=21#wechat_redirect)

**java 高并发系列连载中，总计估计会有四五十篇文章，可以关注公众号：javacode2018，获取最新文章。**

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06AcmgEdFkkWEgWeMkg0tpVAH0UK9CMukCQEk0KdnicBdPCgg2sEXr6nG0NKGDGZcrcj7ZaHF8Dnudw/640?wx_fmt=jpeg)