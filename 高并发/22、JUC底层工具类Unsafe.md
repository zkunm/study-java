> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933173&idx=1&sn=80eb550294677b0042fc030f90cce109&chksm=88621b0bbf15921d2274a7bf6afde912fec02a4c3ade9cfb50d03cdce73e07e33d08d35a3b27&token=1033016931&lang=zh_CN&scene=21#wechat_redirect)

这是 java 高并发系列第 22 篇文章，文章基于 jdk1.8 环境。

本文主要内容
------

1.  Unsafe 基本介绍
    
2.  获取 Unsafe 实例
    
3.  Unsafe 中的 CAS 操作
    
4.  Unsafe 中原子操作相关方法介绍
    
5.  Unsafe 中线程调度相关方法介绍
    
6.  park 和 unpark 示例
    
7.  Unsafe 锁示例
    
8.  Unsafe 中对 volatile 的支持
    

基本介绍
----

最近我们一直在学习 java 高并发，java 高并发中主要涉及到类位于 java.util.concurrent 包中，简称 juc，juc 中大部分类都是依赖于 Unsafe 来实现的，主要用到了 Unsafe 中的 CAS、线程挂起、线程恢复等相关功能。所以如果打算深入了解 JUC 原理的，必须先了解一下 Unsafe 类。

先上一幅 Unsafe 类的功能图：

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06DDwr8wJxZBGZYicQqj5BLWD6Dac6p0RcSM0pYyRCNHN6aF5AKayPWYMEZU0rDl2VMfVUkEfStXenA/640?wx_fmt=png)

Unsafe 是位于 sun.misc 包下的一个类，主要提供一些用于执行低级别、不安全操作的方法，如直接访问系统内存资源、自主管理内存资源等，这些方法在提升 Java 运行效率、增强 Java 语言底层资源操作能力方面起到了很大的作用。但由于 Unsafe 类使 Java 语言拥有了类似 C 语言指针一样操作内存空间的能力，这无疑也增加了程序发生相关指针问题的风险。在程序中过度、不正确使用 Unsafe 类会使得程序出错的概率变大，使得 Java 这种安全的语言变得不再 “安全”，因此对 Unsafe 的使用一定要慎重。

从 Unsafe 功能图上看出，Unsafe 提供的 API 大致可分为**内存操作**、**CAS**、**Class 相关**、**对象操作**、**线程调度**、**系统信息获取**、**内存屏障**、**数组操作**等几类，**本文主要介绍 3 个常用的操作：CAS、线程调度、对象操作。**

看一下 UnSafe 的原码部分：

```
public final class Unsafe {
  // 单例对象
  private static final Unsafe theUnsafe;

  private Unsafe() {
  }
  @CallerSensitive
  public static Unsafe getUnsafe() {
    Class var0 = Reflection.getCallerClass();
    // 仅在引导类加载器`BootstrapClassLoader`加载时才合法
    if(!VM.isSystemDomainLoader(var0.getClassLoader())) {    
      throw new SecurityException("Unsafe");
    } else {
      return theUnsafe;
    }
  }
}


```

从代码中可以看出，Unsafe 类为单例实现，提供静态方法 getUnsafe 获取 Unsafe 实例，内部会判断当前调用者是否是由系统类加载器加载的，如果不是系统类加载器加载的，会抛出`SecurityException`异常。

那我们想使用这个类，如何获取呢？

可以把我们的类放在 jdk 的 lib 目录下，那么启动的时候会自动加载，这种方式不是很好。

我们学过反射，通过反射可以获取到`Unsafe`中的`theUnsafe`字段的值，这样可以获取到 Unsafe 对象的实例。

通过反射获取 Unsafe 实例
----------------

代码如下：

```
package com.itsoku.chat21;

import sun.misc.Unsafe;

import java.lang.reflect.Field;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo1 {
    static Unsafe unsafe;

    static {
        try {
            Field field = Unsafe.class.getDeclaredField("theUnsafe");
            field.setAccessible(true);
            unsafe = (Unsafe) field.get(null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        System.out.println(unsafe);
    }
}


```

输出：

```
sun.misc.Unsafe@76ed5528


```

Unsafe 中的 CAS 操作
----------------

看一下 Unsafe 中 CAS 相关方法定义：

```
/**
 * CAS 操作
 *
 * @param o        包含要修改field的对象
 * @param offset   对象中某field的偏移量
 * @param expected 期望值
 * @param update   更新值
 * @return true | false
 */
public final native boolean compareAndSwapObject(Object o, long offset, Object expected, Object update);

public final native boolean compareAndSwapInt(Object o, long offset, int expected,int update);

public final native boolean compareAndSwapLong(Object o, long offset, long expected, long update);


```

什么是 CAS? 即比较并替换，实现并发算法时常用到的一种技术。CAS 操作包含三个操作数——**内存位置、预期原值及新值**。**执行 CAS 操作的时候，将内存位置的值与预期原值比较，如果相匹配，那么处理器会自动将该位置值更新为新值，否则，处理器不做任何操作，多个线程同时执行 cas 操作，只有一个会成功**。我们都知道，CAS 是一条 CPU 的原子指令（cmpxchg 指令），不会造成所谓的数据不一致问题，Unsafe 提供的 CAS 方法（如 compareAndSwapXXX）底层实现即为 CPU 指令 cmpxchg。执行 cmpxchg 指令的时候，会判断当前系统是否为多核系统，如果是就给总线加锁，只有一个线程会对总线加锁成功，加锁成功之后会执行 cas 操作，也就是说 CAS 的原子性实际上是 CPU 实现的， 其实在这一点上还是有排他锁的，只是比起用 synchronized， 这里的排他时间要短的多， 所以在多线程情况下性能会比较好。

> 说一下 offset，offeset 为字段的偏移量，每个对象有个地址，offset 是字段相对于对象地址的偏移量，对象地址记为 baseAddress，字段偏移量记为 offeset，那么字段对应的实际地址就是 baseAddress+offeset，所以 cas 通过对象、偏移量就可以去操作字段对应的值了。

CAS 在 java.util.concurrent.atomic 相关类、Java AQS、JUC 中并发集合等实现上有非常广泛的应用，我们看一下`java.util.concurrent.atomic.AtomicInteger`类，这个类可以在多线程环境中对 int 类型的数据执行高效的原子修改操作，并保证数据的正确性，看一下此类中用到 Unsafe cas 的地方：

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06DDwr8wJxZBGZYicQqj5BLWDKbKzy9NMHruqeOqBbfYtosJ3XlXo8TkdNjdICfWKLPcrpABJZmQM8g/640?wx_fmt=png)

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06DDwr8wJxZBGZYicQqj5BLWDbzXZxRbjQHZrs6icwPujfibNITrWPYTeRJPlxv3WJozOeyHWInNMYGRg/640?wx_fmt=png)

JUC 中其他地方使用到 CAS 的地方就不列举了，有兴趣的可以去看一下源码。  

Unsafe 中原子操作相关方法介绍
------------------

5 个方法，看一下实现：

```
/**
 * int类型值原子操作，对var2地址对应的值做原子增加操作(增加var4)
 *
 * @param var1 操作的对象
 * @param var2 var2字段内存地址偏移量
 * @param var4 需要加的值
 * @return
 */
public final int getAndAddInt(Object var1, long var2, int var4) {
    int var5;
    do {
        var5 = this.getIntVolatile(var1, var2);
    } while (!this.compareAndSwapInt(var1, var2, var5, var5 + var4));

    return var5;
}

/**
 * long类型值原子操作，对var2地址对应的值做原子增加操作(增加var4)
 *
 * @param var1 操作的对象
 * @param var2 var2字段内存地址偏移量
 * @param var4 需要加的值
 * @return 返回旧值
 */
public final long getAndAddLong(Object var1, long var2, long var4) {
    long var6;
    do {
        var6 = this.getLongVolatile(var1, var2);
    } while (!this.compareAndSwapLong(var1, var2, var6, var6 + var4));

    return var6;
}

/**
 * int类型值原子操作方法，将var2地址对应的值置为var4
 *
 * @param var1 操作的对象
 * @param var2 var2字段内存地址偏移量
 * @param var4 新值
 * @return 返回旧值
 */
public final int getAndSetInt(Object var1, long var2, int var4) {
    int var5;
    do {
        var5 = this.getIntVolatile(var1, var2);
    } while (!this.compareAndSwapInt(var1, var2, var5, var4));

    return var5;
}

/**
 * long类型值原子操作方法，将var2地址对应的值置为var4
 *
 * @param var1 操作的对象
 * @param var2 var2字段内存地址偏移量
 * @param var4 新值
 * @return 返回旧值
 */
public final long getAndSetLong(Object var1, long var2, long var4) {
    long var6;
    do {
        var6 = this.getLongVolatile(var1, var2);
    } while (!this.compareAndSwapLong(var1, var2, var6, var4));

    return var6;
}

/**
 * Object类型值原子操作方法，将var2地址对应的值置为var4
 *
 * @param var1 操作的对象
 * @param var2 var2字段内存地址偏移量
 * @param var4 新值
 * @return 返回旧值
 */
public final Object getAndSetObject(Object var1, long var2, Object var4) {
    Object var5;
    do {
        var5 = this.getObjectVolatile(var1, var2);
    } while (!this.compareAndSwapObject(var1, var2, var5, var4));

    return var5;
}


```

看一下上面的方法，内部通过自旋的 CAS 操作实现的，这些方法都可以保证操作的数据在多线程环境中的原子性，正确性。

来个示例，我们还是来实现一个网站计数功能，同时有 100 个人发起对网站的请求，每个人发起 10 次请求，每次请求算一次，最终结果是 1000 次，代码如下：

```
package com.itsoku.chat21;

import sun.misc.Unsafe;

import java.lang.reflect.Field;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo2 {
    static Unsafe unsafe;
    //用来记录网站访问量，每次访问+1
    static int count;
    //count在Demo.class对象中的地址偏移量
    static long countOffset;

    static {
        try {
            //获取Unsafe对象
            Field field = Unsafe.class.getDeclaredField("theUnsafe");
            field.setAccessible(true);
            unsafe = (Unsafe) field.get(null);

            Field countField = Demo2.class.getDeclaredField("count");
            //获取count字段在Demo2中的内存地址的偏移量
            countOffset = unsafe.staticFieldOffset(countField);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //模拟访问一次
    public static void request() throws InterruptedException {
        //模拟耗时5毫秒
        TimeUnit.MILLISECONDS.sleep(5);
        //对count原子加1
        unsafe.getAndAddInt(Demo2.class, countOffset, 1);
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
main，耗时：114,count=1000


```

代码中我们在静态块中通过反射获取到了 Unsafe 类的实例，然后获取 Demo2 中 count 字段内存地址偏移量`countOffset`，main 方法中模拟了 100 个人，每人发起 10 次请求，等到所有请求完毕之后，输出 count 的结果。

代码中用到了`CountDownLatch`，通过`countDownLatch.await()`让主线程等待，等待 100 个子线程都执行完毕之后，主线程在进行运行。`CountDownLatch`的使用可以参考：[JUC 中等待多线程完成的工具类 CountDownLatch](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933134&idx=1&sn=65c2b9982bb6935c54ff33082f9c111f&chksm=88621b30bf159226d41607292a1dc83186f8928744dbc44acfda381266fa2cdc006177b44095&token=773938509&lang=zh_CN&scene=21#wechat_redirect)

Unsafe 中线程调度相关方法
----------------

这部分，包括线程挂起、恢复、锁机制等方法。

```
//取消阻塞线程
public native void unpark(Object thread);
//阻塞线程,isAbsolute：是否是绝对时间，如果为true，time是一个绝对时间，如果为false，time是一个相对时间，time表示纳秒
public native void park(boolean isAbsolute, long time);
//获得对象锁（可重入锁）
@Deprecated
public native void monitorEnter(Object o);
//释放对象锁
@Deprecated
public native void monitorExit(Object o);
//尝试获取对象锁
@Deprecated
public native boolean tryMonitorEnter(Object o);


```

调用`park`后，线程将被阻塞，直到`unpark`调用或者超时，如果之前调用过`unpark`, 不会进行阻塞，即`park`和`unpark`不区分先后顺序。**monitorEnter、monitorExit、tryMonitorEnter** 3 个方法**已过期**，不建议使用了。

park 和 unpark 示例
----------------

代码如下：

```
package com.itsoku.chat21;

import sun.misc.Unsafe;

import java.lang.reflect.Field;
import java.util.concurrent.TimeUnit;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo3 {
    static Unsafe unsafe;

    static {
        try {
            Field field = Unsafe.class.getDeclaredField("theUnsafe");
            field.setAccessible(true);
            unsafe = (Unsafe) field.get(null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 调用park和unpark，模拟线程的挂起和唤醒
     *
     * @throws InterruptedException
     */
    public static void m1() throws InterruptedException {
        Thread thread = new Thread(() -> {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + ",start");
            unsafe.park(false, 0);
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + ",end");
        });
        thread.setName("thread1");
        thread.start();

        TimeUnit.SECONDS.sleep(5);
        unsafe.unpark(thread);
    }

    /**
     * 阻塞指定的时间
     */
    public static void m2() {
        Thread thread = new Thread(() -> {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + ",start");
            //线程挂起3秒
            unsafe.park(false, TimeUnit.SECONDS.toNanos(3));
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + ",end");
        });
        thread.setName("thread2");
        thread.start();
    }

    public static void main(String[] args) throws InterruptedException {
        m1();
        m2();
    }
}


```

输出：

```
1565000238474,thread1,start
1565000243475,thread1,end
1565000243475,thread2,start
1565000246476,thread2,end


```

m1() 中 thread1 调用 park 方法，park 方法会将**当前线程阻塞**，被阻塞了 5 秒之后，被主线程调用 unpark 方法给唤醒了，unpark 方法参数表示需要唤醒的线程。

线程中相当于有个许可，许可默认是 0，调用 park 的时候，发现是 0 会阻塞当前线程，调用 unpark 之后，许可会被置为 1，并会唤醒当前线程。如果在 park 之前先调用了 unpark 方法，执行 park 方法的时候，不会阻塞。park 方法被唤醒之后，许可又会被置为 0。多次调用 unpark 的效果是一样的，许可还是 1。

juc 中的`LockSupport`类是通过 unpark 和 park 方法实现的，需要了解 LockSupport 可以移步：[JUC 中的 LockSupport 工具类](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933125&idx=1&sn=382528aeb341727bafb02bb784ff3d4f&chksm=88621b3bbf15922d93bfba11d700724f1e59ef8a74f44adb7e131a4c3d1465f0dc539297f7f3&scene=21#wechat_redirect)

Unsafe 锁示例
----------

代码如下：

```
package com.itsoku.chat21;

import sun.misc.Unsafe;

import java.lang.reflect.Field;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo4 {

    static Unsafe unsafe;
    //用来记录网站访问量，每次访问+1
    static int count;

    static {
        try {
            Field field = Unsafe.class.getDeclaredField("theUnsafe");
            field.setAccessible(true);
            unsafe = (Unsafe) field.get(null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //模拟访问一次
    public static void request() {
        unsafe.monitorEnter(Demo4.class);
        try {
            count++;
        } finally {
            unsafe.monitorExit(Demo4.class);
        }
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
main，耗时：64,count=1000


```

注意：

1.  **monitorEnter、monitorExit、tryMonitorEnter 3 个方法已过期，不建议使用了**
    
2.  **monitorEnter、monitorExit 必须成对出现，出现的次数必须一致，也就是说锁了 n 次，也必须释放 n 次，否则会造成死锁**
    

Unsafe 中保证变量的可见性
----------------

关于变量可见性需要先了解 java 内存模型 JMM，可以移步到：

[JMM 相关的一些概念](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933050&idx=1&sn=497c4de99086f95bed11a4317a51e6a6&chksm=88621a84bf159392c9e3e243355313c397e0658df6b88769cdd182cb5d39b6f25686c86beffc&scene=21#wechat_redirect)

[volatile 与 Java 内存模型](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933088&idx=1&sn=f1d666dd799664b1989c77441b9d12c5&chksm=88621adebf1593c83501ac33d6a0e0de075f2b2e30caf986cf276cbb1c8dff0eac2a0a648b1d&scene=21#wechat_redirect)

java 中操作内存分为主内存和工作内存，共享数据在主内存中，线程如果需要操作主内存的数据，需要先将主内存的数据复制到线程独有的工作内存中，操作完成之后再将其刷新到主内存中。如线程 A 要想看到线程 B 修改后的数据，需要满足：线程 B 修改数据之后，需要将数据从自己的工作内存中刷新到主内存中，并且 A 需要去主内存中读取数据。

被关键字 volatile 修饰的数据，有 2 点语义：

1.  如果一个变量被 volatile 修饰，读取这个变量时候，会强制从主内存中读取，然后将其复制到当前线程的工作内存中使用
    
2.  给 volatile 修饰的变量赋值的时候，会强制将赋值的结果从工作内存刷新到主内存
    

上面 2 点语义保证了被 volatile 修饰的数据在多线程中的可见性。

Unsafe 中提供了和 volatile 语义一样的功能的方法，如下：

```
//设置给定对象的int值，使用volatile语义，即设置后立马更新到内存对其他线程可见
public native void  putIntVolatile(Object o, long offset, int x);
//获得给定对象的指定偏移量offset的int值，使用volatile语义，总能获取到最新的int值。
public native int getIntVolatile(Object o, long offset);


```

putIntVolatile 方法，2 个参数：

> o：表示需要操作的对象
> 
> offset：表示操作对象中的某个字段地址偏移量
> 
> x：将 offset 对应的字段的值修改为 x，并且立即刷新到主存中
> 
> 调用这个方法，会强制将工作内存中修改的数据刷新到主内存中。

getIntVolatile 方法，2 个参数

> o：表示需要操作的对象
> 
> offset：表示操作对象中的某个字段地址偏移量
> 
> 每次调用这个方法都会强制从主内存读取值，将其复制到工作内存中使用。

其他的还有几个 putXXXVolatile、getXXXVolatile 方法和上面 2 个类似。

本文主要讲解这些内容，希望您能有所收获，谢谢。

java 高并发系列目录
------------

1.  [第 1 天: 必须知道的几个概念](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933019&idx=1&sn=3455877c451de9c61f8391ffdc1eb01d&chksm=88621aa5bf1593b377e2f090bf37c87ba60081fb782b2371b5f875e4a6cadc3f92ff6d747e32&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [第 2 天: 并发级别](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933024&idx=1&sn=969bfa5e2c3708e04adaf6401503c187&chksm=88621a9ebf1593886dd3f0f5923b6f929eade0b43204b98a8d0622a5f542deff4f6a633a13c8&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [第 3 天: 有关并行的两个重要定律](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933041&idx=1&sn=82af7c702f737782118a9141858117d1&chksm=88621a8fbf159399be1d4834f6f845fa530b94a4ca7c0eaa61de508f725ad0fab74b074d73be&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
4.  [第 4 天: JMM 相关的一些概念](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933050&idx=1&sn=497c4de99086f95bed11a4317a51e6a6&chksm=88621a84bf159392c9e3e243355313c397e0658df6b88769cdd182cb5d39b6f25686c86beffc&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [第 5 天: 深入理解进程和线程](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933069&idx=1&sn=82105bb5b759ec8b1f3a69062a22dada&chksm=88621af3bf1593e5ece7c1da3df3b4be575271a2eaca31c784591ed0497252caa1f6a6ec0545&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [第 6 天: 线程的基本操作](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933082&idx=1&sn=e940c4f94a8c1527b6107930eefdcd00&chksm=88621ae4bf1593f270991e6f6bac5769ea850fa02f11552d1aa91725f4512d4f1ff8f18fcdf3&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [第 7 天: volatile 与 Java 内存模型](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933088&idx=1&sn=f1d666dd799664b1989c77441b9d12c5&chksm=88621adebf1593c83501ac33d6a0e0de075f2b2e30caf986cf276cbb1c8dff0eac2a0a648b1d&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
8.  [第 8 天: 线程组](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933095&idx=1&sn=d32242a5ec579f45d1e9becf44bff069&chksm=88621ad9bf1593cf00b574a8e0feeffbb2c241c30b01ebf5749ccd6b7b64dcd2febbd3000581&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
9.  [第 9 天：用户线程和守护线程](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933102&idx=1&sn=5255e94dc2649003e01bf3d61762c593&chksm=88621ad0bf1593c6905e75a82aaf6e39a0af338362366ce2860ee88c1b800e52f5c6529c089c&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
10.  [第 10 天: 线程安全和 synchronized 关键字](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933107&idx=1&sn=6b9fbdfa180c2ca79703e0ca1b524b77&chksm=88621acdbf1593dba5fa5a0092d810004362e9f38484ffc85112a8c23ef48190c51d17e06223&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
11.  [第 11 天: 线程中断的几种方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933111&idx=1&sn=0a3592e41e59d0ded4a60f8c1b59e82e&chksm=88621ac9bf1593df5f8342514d6750cc8a833ba438aa208cf128493981ba666a06c4037d84fb&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
12.  [第 12 天 JUC:ReentrantLock 重入锁](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933116&idx=1&sn=83ae2d1381e3b8a425e65a9fa7888d38&chksm=88621ac2bf1593d4de1c5f6905c31c7d88ac4b53c0c5c071022ba2e25803fc734078c1de589c&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)
    
13.  [第 13 天: JUC 中的 Condition 对象](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933120&idx=1&sn=63ffe3ff64dcaf0418816febfd1e129a&chksm=88621b3ebf159228df5f5a501160fafa5d87412a4f03298867ec9325c0be57cd8e329f3b5ad1&token=476165288&lang=zh_CN&scene=21#wechat_redirect)
    
14.  [第 14 天: JUC 中的 LockSupport 工具类，必备技能](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933125&idx=1&sn=382528aeb341727bafb02bb784ff3d4f&chksm=88621b3bbf15922d93bfba11d700724f1e59ef8a74f44adb7e131a4c3d1465f0dc539297f7f3&token=1338873010&lang=zh_CN&scene=21#wechat_redirect)
    
15.  [第 15 天：JUC 中的 Semaphore（信号量）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933130&idx=1&sn=cecc6bd906e79a86510c1fbb0e66cd21&chksm=88621b34bf159222042da8ed4b633e94ca04a614d290d54a952a668459a339ebec0c754d562d&token=702505185&lang=zh_CN&scene=21#wechat_redirect)
    
16.  [第 16 天：JUC 中等待多线程完成的工具类 CountDownLatch](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933134&idx=1&sn=65c2b9982bb6935c54ff33082f9c111f&chksm=88621b30bf159226d41607292a1dc83186f8928744dbc44acfda381266fa2cdc006177b44095&token=773938509&lang=zh_CN&scene=21#wechat_redirect)
    
17.  [第 17 天：JUC 中的循环栅栏 CyclicBarrier 的 6 种使用场景](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933144&idx=1&sn=7f0cddc92ff39835ea6652ebb3186dbf&chksm=88621b26bf15923039933b127c19f39a76214fb1d5daa7ad0eee77f961e2e3ab5f5ca3f48740&token=773938509&lang=zh_CN&scene=21#wechat_redirect)
    
18.  [18 天：JAVA 线程池，这一篇就够了](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933151&idx=1&sn=2020066b974b5f4c0823abd419e8adae&chksm=88621b21bf159237bdacfb47bd1a344f7123aabc25e3607e78d936dd554412edce5dd825003d&token=995072421&lang=zh_CN&scene=21#wechat_redirect)
    
19.  [第 19 天：JUC 中的 Executor 框架详解 1](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933156&idx=1&sn=30f7d67b44a952eae98e688bc6035fbd&chksm=88621b1abf15920c7a0705fbe34c4ce92b94b88e08f8ecbcad3827a0950cfe4d95814b61f538&token=995072421&lang=zh_CN&scene=21#wechat_redirect)
    
20.  [第 20 天：JUC 中的 Executor 框架详解 2](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933160&idx=1&sn=62649485b065f68c0fc59bb502ed42df&chksm=88621b16bf159200d5e25d11ab7036c60e3f923da3212ae4dd148753d02593a45ce0e9b886c4&token=42900009&lang=zh_CN&scene=21#wechat_redirect)
    
21.  [第 21 天：java 中的 CAS](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933166&idx=1&sn=15e614500676170b76a329efd3255c12&chksm=88621b10bf1592064befc5c9f0d78c56cda25c6d003e1711b85e5bfeb56c9fd30d892178db87&scene=21#wechat_redirect)  
    

**java 高并发系列连载中，总计估计会有四五十篇文章。**

**跟着阿里 p7 学并发，微信公众号：****javacode2018**

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06AcmgEdFkkWEgWeMkg0tpVAH0UK9CMukCQEk0KdnicBdPCgg2sEXr6nG0NKGDGZcrcj7ZaHF8Dnudw/640?wx_fmt=jpeg)