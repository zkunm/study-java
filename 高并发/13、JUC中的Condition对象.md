> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933120&idx=1&sn=63ffe3ff64dcaf0418816febfd1e129a&chksm=88621b3ebf159228df5f5a501160fafa5d87412a4f03298867ec9325c0be57cd8e329f3b5ad1&token=476165288&lang=zh_CN&scene=21#wechat_redirect)

**java 高并发系列第 13 篇文章**  

本文内容
----

1.  synchronized 中实现线程等待和唤醒
    
2.  Condition 简介及常用方法介绍及相关示例
    
3.  使用 Condition 实现生产者消费者
    
4.  使用 Condition 实现同步阻塞队列
    

Object 对象中的 wait()，notify() 方法，用于线程等待和唤醒等待中的线程，大家应该比较熟悉，想再次了解的朋友可以移步到 [java 高并发系列 - 第 6 天: 线程的基本操作](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933082&idx=1&sn=e940c4f94a8c1527b6107930eefdcd00&chksm=88621ae4bf1593f270991e6f6bac5769ea850fa02f11552d1aa91725f4512d4f1ff8f18fcdf3&scene=21#wechat_redirect)

synchronized 中等待和唤醒线程示例
-----------------------

```
package com.itsoku.chat09;
import java.util.concurrent.TimeUnit;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo1 {
    static Object lock = new Object();
    public static class T1 extends Thread {
        @Override
        public void run() {
            System.out.println(System.currentTimeMillis() + "," + this.getName() + "准备获取锁!");
            synchronized (lock) {
                System.out.println(System.currentTimeMillis() + "," + this.getName() + "获取锁成功!");
                try {
                    lock.wait();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
            System.out.println(System.currentTimeMillis() + "," + this.getName() + "释放锁成功!");
        }
    }
    public static class T2 extends Thread {
        @Override
        public void run() {
            System.out.println(System.currentTimeMillis() + "," + this.getName() + "准备获取锁!");
            synchronized (lock) {
                System.out.println(System.currentTimeMillis() + "," + this.getName() + "获取锁成功!");
                lock.notify();
                System.out.println(System.currentTimeMillis() + "," + this.getName() + " notify!");
                try {
                    TimeUnit.SECONDS.sleep(5);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(System.currentTimeMillis() + "," + this.getName() + "准备释放锁!");
            }
            System.out.println(System.currentTimeMillis() + "," + this.getName() + "释放锁成功!");
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T1 t1 = new T1();
        t1.setName("t1");
        t1.start();
        TimeUnit.SECONDS.sleep(5);
        T2 t2 = new T2();
        t2.setName("t2");
        t2.start();
    }
}

```

输出：

```
1：1563530109234,t1准备获取锁!
2：1563530109234,t1获取锁成功!
3：1563530114236,t2准备获取锁!
4：1563530114236,t2获取锁成功!
5：1563530114236,t2 notify!
6：1563530119237,t2准备释放锁!
7：1563530119237,t2释放锁成功!
8：1563530119237,t1释放锁成功!

```

代码结合输出的结果我们分析一下：

1.  线程 t1 先获取锁，然后调用了 wait() 方法将线程置为等待状态，然后会释放 lock 的锁
    
2.  主线程等待 5 秒之后，启动线程 t2，t2 获取到了锁，结果中 1、3 行时间相差 5 秒左右
    
3.  t2 调用 lock.notify() 方法，准备将等待在 lock 上的线程 t1 唤醒，notify() 方法之后又休眠了 5 秒，看一下输出的 5、8 可知，notify() 方法之后，t1 并不能立即被唤醒，需要等到 t2 将 synchronized 块执行完毕，释放锁之后，t1 才被唤醒
    
4.  wait() 方法和 notify() 方法必须放在同步块内调用（synchronized 块内），否则会报错
    

Condition 使用简介
--------------

在了解 Condition 之前，需要先了解一下重入锁 ReentrantLock，可以移步到：[java 高并发系列 - 第 12 天 JUC:ReentrantLock 重入锁](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933116&idx=1&sn=83ae2d1381e3b8a425e65a9fa7888d38&chksm=88621ac2bf1593d4de1c5f6905c31c7d88ac4b53c0c5c071022ba2e25803fc734078c1de589c&scene=21#wechat_redirect)。

任何一个 java 对象都天然继承于 Object 类，在线程间实现通信的往往会应用到 Object 的几个方法，比如 wait()、wait(long timeout)、wait(long timeout, int nanos) 与 notify()、notifyAll() 几个方法实现等待 / 通知机制，同样的， 在 java Lock 体系下依然会有同样的方法实现等待 / 通知机制。

从整体上来看 **Object 的 wait 和 notify/notify 是与对象监视器配合完成线程间的等待 / 通知机制，而 Condition 与 Lock 配合完成等待通知机制，前者是 java 底层级别的，后者是语言级别的，具有更高的可控制性和扩展性**。两者除了在使用方式上不同外，在**功能特性**上还是有很多的不同：

1.  Condition 能够支持不响应中断，而通过使用 Object 方式不支持
    
2.  Condition 能够支持多个等待队列（new 多个 Condition 对象），而 Object 方式只能支持一个
    
3.  Condition 能够支持超时时间的设置，而 Object 不支持
    

Condition 由 ReentrantLock 对象创建，并且可以同时创建多个，Condition 接口在使用前必须先调用 ReentrantLock 的 lock() 方法获得锁，之后调用 Condition 接口的 await() 将释放锁，并且在该 Condition 上等待，直到有其他线程调用 Condition 的 signal() 方法唤醒线程，使用方式和 wait()、notify() 类似。

示例代码：

```
package com.itsoku.chat09;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo2 {
    static ReentrantLock lock = new ReentrantLock();
    static Condition condition = lock.newCondition();
    public static class T1 extends Thread {
        @Override
        public void run() {
            System.out.println(System.currentTimeMillis() + "," + this.getName() + "准备获取锁!");
            lock.lock();
            try {
                System.out.println(System.currentTimeMillis() + "," + this.getName() + "获取锁成功!");
                condition.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
            System.out.println(System.currentTimeMillis() + "," + this.getName() + "释放锁成功!");
        }
    }
    public static class T2 extends Thread {
        @Override
        public void run() {
            System.out.println(System.currentTimeMillis() + "," + this.getName() + "准备获取锁!");
            lock.lock();
            try {
                System.out.println(System.currentTimeMillis() + "," + this.getName() + "获取锁成功!");
                condition.signal();
                System.out.println(System.currentTimeMillis() + "," + this.getName() + " signal!");
                try {
                    TimeUnit.SECONDS.sleep(5);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(System.currentTimeMillis() + "," + this.getName() + "准备释放锁!");
            } finally {
                lock.unlock();
            }
            System.out.println(System.currentTimeMillis() + "," + this.getName() + "释放锁成功!");
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T1 t1 = new T1();
        t1.setName("t1");
        t1.start();
        TimeUnit.SECONDS.sleep(5);
        T2 t2 = new T2();
        t2.setName("t2");
        t2.start();
    }
}

```

输出：

```
1563532185827,t1准备获取锁!
1563532185827,t1获取锁成功!
1563532190829,t2准备获取锁!
1563532190829,t2获取锁成功!
1563532190829,t2 signal!
1563532195829,t2准备释放锁!
1563532195829,t2释放锁成功!
1563532195829,t1释放锁成功!

```

输出的结果和使用 synchronized 关键字的实例类似。

Condition.await() 方法和 Object.wait() 方法类似，当使用 Condition.await() 方法时，需要先获取 Condition 对象关联的 ReentrantLock 的锁，在 Condition.await() 方法被调用时，当前线程会释放这个锁，并且当前线程会进行等待（处于阻塞状态）。在 signal() 方法被调用后，系统会从 Condition 对象的等待队列中唤醒一个线程，一旦线程被唤醒，被唤醒的线程会尝试重新获取锁，一旦获取成功，就可以继续执行了。因此，在 signal 被调用后，一般需要释放相关的锁，让给其他被唤醒的线程，让他可以继续执行。

Condition 常用方法
--------------

Condition 接口提供的常用方法有：

> **和 Object 中 wait 类似的方法**

1.  void await() throws InterruptedException: 当前线程进入等待状态，如果其他线程调用 condition 的 signal 或者 signalAll 方法并且当前线程获取 Lock 从 await 方法返回，如果在等待状态中被中断会抛出被中断异常；
    
2.  long awaitNanos(long nanosTimeout)：当前线程进入等待状态直到被通知，中断或者**超时**；
    
3.  boolean await(long time, TimeUnit unit) throws InterruptedException：同第二种，支持自定义时间单位，false：表示方法超时之后自动返回的，true：表示等待还未超时时，await 方法就返回了（超时之前，被其他线程唤醒了）
    
4.  boolean awaitUntil(Date deadline) throws InterruptedException：当前线程进入等待状态直到被通知，中断或者**到了某个时间**
    
5.  void awaitUninterruptibly();：当前线程进入等待状态，不会响应线程中断操作，只能通过唤醒的方式让线程继续
    

> **和 Object 的 notify/notifyAll 类似的方法**

1.  void signal()：唤醒一个等待在 condition 上的线程，将该线程从**等待队列**中转移到**同步队列**中，如果在同步队列中能够竞争到 Lock 则可以从等待方法中返回。
    
2.  void signalAll()：与 1 的区别在于能够唤醒所有等待在 condition 上的线程
    

Condition.await() 过程中被打断
------------------------

```
package com.itsoku.chat09;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo4 {
    static ReentrantLock lock = new ReentrantLock();
    static Condition condition = lock.newCondition();
    public static class T1 extends Thread {
        @Override
        public void run() {
            lock.lock();
            try {
                condition.await();
            } catch (InterruptedException e) {
                System.out.println("中断标志：" + this.isInterrupted());
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T1 t1 = new T1();
        t1.setName("t1");
        t1.start();
        TimeUnit.SECONDS.sleep(2);
        //给t1线程发送中断信号
        System.out.println("1、t1中断标志：" + t1.isInterrupted());
        t1.interrupt();
        System.out.println("2、t1中断标志：" + t1.isInterrupted());
    }
}

```

输出：

```
1、t1中断标志：false
2、t1中断标志：true
中断标志：false
java.lang.InterruptedException
    at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.reportInterruptAfterWait(AbstractQueuedSynchronizer.java:2014)
    at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:2048)
    at com.itsoku.chat09.Demo4$T1.run(Demo4.java:19)

```

调用 condition.await() 之后，线程进入阻塞中，调用 t1.interrupt()，给 t1 线程发送中断信号，await() 方法内部会检测到线程中断信号，然后触发 `InterruptedException`异常，线程中断标志被清除。从输出结果中可以看出，线程 t1 中断标志的变换过程：false->true->false

await(long time, TimeUnit unit) 超时之后自动返回
----------------------------------------

```
package com.itsoku.chat09;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo5 {
    static ReentrantLock lock = new ReentrantLock();
    static Condition condition = lock.newCondition();
    public static class T1 extends Thread {
        @Override
        public void run() {
            lock.lock();
            try {
                System.out.println(System.currentTimeMillis() + "," + this.getName() + ",start");
                boolean r = condition.await(2, TimeUnit.SECONDS);
                System.out.println(r);
                System.out.println(System.currentTimeMillis() + "," + this.getName() + ",end");
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T1 t1 = new T1();
        t1.setName("t1");
        t1.start();
    }
}

```

输出：

```
1563541624082,t1,start
false
1563541626085,t1,end

```

t1 线程等待 2 秒之后，自动返回继续执行，最后 await 方法返回 false，**await 返回 false 表示超时之后自动返回**

await(long time, TimeUnit unit) 超时之前被唤醒
---------------------------------------

```
package com.itsoku.chat09;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo6 {
    static ReentrantLock lock = new ReentrantLock();
    static Condition condition = lock.newCondition();
    public static class T1 extends Thread {
        @Override
        public void run() {
            lock.lock();
            try {
                System.out.println(System.currentTimeMillis() + "," + this.getName() + ",start");
                boolean r = condition.await(5, TimeUnit.SECONDS);
                System.out.println(r);
                System.out.println(System.currentTimeMillis() + "," + this.getName() + ",end");
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T1 t1 = new T1();
        t1.setName("t1");
        t1.start();
        //休眠1秒之后，唤醒t1线程
        TimeUnit.SECONDS.sleep(1);
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
1563542046046,t1,start
true
1563542047048,t1,end

```

t1 线程中调用 `condition.await(5,TimeUnit.SECONDS);`方法会释放锁，等待 5 秒，主线程休眠 1 秒，然后获取锁，之后调用 signal() 方法唤醒 t1，输出结果中发现 await 后过了 1 秒（1、3 行输出结果的时间差），await 方法就返回了，并且返回值是 true。**true 表示 await 方法超时之前被其他线程唤醒了。**

long awaitNanos(long nanosTimeout) 超时返回
---------------------------------------

```
package com.itsoku.chat09;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo7 {
    static ReentrantLock lock = new ReentrantLock();
    static Condition condition = lock.newCondition();
    public static class T1 extends Thread {
        @Override
        public void run() {
            lock.lock();
            try {
                System.out.println(System.currentTimeMillis() + "," + this.getName() + ",start");
                long r = condition.awaitNanos(TimeUnit.SECONDS.toNanos(5));
                System.out.println(r);
                System.out.println(System.currentTimeMillis() + "," + this.getName() + ",end");
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T1 t1 = new T1();
        t1.setName("t1");
        t1.start();
    }
}

```

输出：

```
1563542547302,t1,start
-258200
1563542552304,t1,end

```

**awaitNanos 参数为纳秒，可以调用 TimeUnit 中的一些方法将时间转换为纳秒。**

t1 调用 await 方法等待 5 秒超时返回，返回结果为负数，表示超时之后返回的。

waitNanos(long nanosTimeout) 超时之前被唤醒
------------------------------------

```
package com.itsoku.chat09;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class Demo8 {
    static ReentrantLock lock = new ReentrantLock();
    static Condition condition = lock.newCondition();
    public static class T1 extends Thread {
        @Override
        public void run() {
            lock.lock();
            try {
                System.out.println(System.currentTimeMillis() + "," + this.getName() + ",start");
                long r = condition.awaitNanos(TimeUnit.SECONDS.toNanos(5));
                System.out.println(r);
                System.out.println(System.currentTimeMillis() + "," + this.getName() + ",end");
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
        }
    }
    public static void main(String[] args) throws InterruptedException {
        T1 t1 = new T1();
        t1.setName("t1");
        t1.start();
        //休眠1秒之后，唤醒t1线程
        TimeUnit.SECONDS.sleep(1);
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
1563542915991,t1,start
3999988500
1563542916992,t1,end

```

t1 中调用 await 休眠 5 秒，主线程休眠 1 秒之后，调用 signal() 唤醒线程 t1，await 方法返回正数，表示返回时距离超时时间还有多久，将近 4 秒，返回正数表示，线程在超时之前被唤醒了。

**其他几个有参的 await 方法和无参的 await 方法一样，线程调用 interrupt() 方法时，这些方法都会触发 InterruptedException 异常，并且线程的中断标志会被清除。**

同一个锁支持创建多个 Condition
--------------------

使用两个 Condition 来实现一个阻塞队列的例子：

```
package com.itsoku.chat09;
import java.util.LinkedList;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;
/**
 * 微信公众号：路人甲Java，专注于java技术分享（带你玩转 爬虫、分布式事务、异步消息服务、任务调度、分库分表、大数据等），喜欢请关注！
 */
public class BlockingQueueDemo<E> {
    int size;//阻塞队列最大容量
    ReentrantLock lock = new ReentrantLock();
    LinkedList<E> list = new LinkedList<>();//队列底层实现
    Condition notFull = lock.newCondition();//队列满时的等待条件
    Condition notEmpty = lock.newCondition();//队列空时的等待条件
    public BlockingQueueDemo(int size) {
        this.size = size;
    }
    public void enqueue(E e) throws InterruptedException {
        lock.lock();
        try {
            while (list.size() == size)//队列已满,在notFull条件上等待
                notFull.await();
            list.add(e);//入队:加入链表末尾
            System.out.println("入队：" + e);
            notEmpty.signal(); //通知在notEmpty条件上等待的线程
        } finally {
            lock.unlock();
        }
    }
    public E dequeue() throws InterruptedException {
        E e;
        lock.lock();
        try {
            while (list.size() == 0)//队列为空,在notEmpty条件上等待
                notEmpty.await();
            e = list.removeFirst();//出队:移除链表首元素
            System.out.println("出队：" + e);
            notFull.signal();//通知在notFull条件上等待的线程
            return e;
        } finally {
            lock.unlock();
        }
    }
    public static void main(String[] args) {
        BlockingQueueDemo<Integer> queue = new BlockingQueueDemo<>(2);
        for (int i = 0; i < 10; i++) {
            int data = i;
            new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        queue.enqueue(data);
                    } catch (InterruptedException e) {
                    }
                }
            }).start();
        }
        for (int i = 0; i < 10; i++) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        Integer data = queue.dequeue();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }).start();
        }
    }
}

```

代码非常容易理解，创建了一个阻塞队列，大小为 3，队列满的时候，会被阻塞，等待其他线程去消费，队列中的元素被消费之后，会唤醒生产者，生产数据进入队列。上面代码将队列大小置为 1，可以实现同步阻塞队列，生产 1 个元素之后，生产者会被阻塞，待消费者消费队列中的元素之后，生产者才能继续工作。

Object 的监视器方法与 Condition 接口的对比
------------------------------

<table width="743"><thead><tr><th data-style="box-sizing: border-box; padding: 0.5rem 1rem; text-align: left; border-top-width: 1px; border-color: rgb(233, 235, 236);">对比项</th><th data-style="box-sizing: border-box; padding: 0.5rem 1rem; text-align: left; border-top-width: 1px; border-color: rgb(233, 235, 236);">Object 监视器方法</th><th data-style="box-sizing: border-box; padding: 0.5rem 1rem; text-align: left; border-top-width: 1px; border-color: rgb(233, 235, 236);">Condition</th></tr></thead><tbody><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">前置条件</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">获取对象的锁</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">调用 Lock.lock 获取锁，调用 Lock.newCondition() 获取 Condition 对象</td></tr><tr data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; background-color: rgb(248, 248, 248);"><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">调用方式</td><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">直接调用，如：object.wait()</td><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">直接调用，如：condition.await()</td></tr><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">等待队列个数</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">一个</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">多个，使用多个 condition 实现</td></tr><tr data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; background-color: rgb(248, 248, 248);"><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">当前线程释放锁并进入等待状态</td><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td></tr><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">当前线程释放锁进入等待状态中不响应中断</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">不支持</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td></tr><tr data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; background-color: rgb(248, 248, 248);"><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">当前线程释放锁并进入超时等待状态</td><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td></tr><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">当前线程释放锁并进入等待状态到将来某个时间</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">不支持</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td></tr><tr data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; background-color: rgb(248, 248, 248);"><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">唤醒等待队列中的一个线程</td><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td><td data-darkmode-bgcolor-160791905917710="rgb(32, 32, 32)" data-darkmode-original-bgcolor-160791905917710="rgb(248, 248, 248)" data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td></tr><tr><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">唤醒等待队列中的全部线程</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td><td data-style="box-sizing: border-box; padding: 0.5rem 1rem; border-color: rgb(233, 235, 236);">支持</td></tr></tbody></table>

总结
--

1.  **使用 condition 的步骤：创建 condition 对象，获取锁，然后调用 condition 的方法**
    
2.  **一个 ReentrantLock 支持床多个 condition 对象**
    
3.  **`voidawait()throwsInterruptedException;`方法会释放锁，让当前线程等待，支持唤醒，支持线程中断**
    
4.  **`voidawaitUninterruptibly();`方法会释放锁，让当前线程等待，支持唤醒，不支持线程中断**
    
5.  **`longawaitNanos(longnanosTimeout)throwsInterruptedException;`参数为纳秒，此方法会释放锁，让当前线程等待，支持唤醒，支持中断。超时之后返回的，结果为负数；超时之前被唤醒返回的，结果为正数（表示返回时距离超时时间相差的纳秒数）**
    
6.  **`booleanawait(longtime,TimeUnitunit)throwsInterruptedException;`方法会释放锁，让当前线程等待，支持唤醒，支持中断。超时之后返回的，结果为 false；超时之前被唤醒返回的，结果为 true**
    
7.  **`booleanawaitUntil(Datedeadline)throwsInterruptedException;`参数表示超时的截止时间点，方法会释放锁，让当前线程等待，支持唤醒，支持中断。超时之后返回的，结果为 false；超时之前被唤醒返回的，结果为 true**
    
8.  **`voidsignal();`会唤醒一个等待中的线程，然后被唤醒的线程会被加入同步队列，去尝试获取锁**
    
9.  **`voidsignalAll();`会唤醒所有等待中的线程，将所有等待中的线程加入同步队列，然后去尝试获取锁**
    

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

**java 高并发系列连载中，总计估计会有四五十篇文章，可以关注公众号：javacode2018，获取最新文章。**

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06BvKtvNz52fglTy1VbMPApsVKKxWl8sL9gcKO32icd0l8kWbcVL79RAGqt3UpsPX5OExmHaz50qy5g/640?wx_fmt=jpeg)