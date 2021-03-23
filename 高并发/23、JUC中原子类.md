> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933181&idx=1&sn=a1e254365d405cdc2e3b8372ecda65ee&chksm=88621b03bf159215ca696c9f81e228d0544a7598b03fe30436babc95c6a95e848161f61b868c&token=743622661&lang=zh_CN&scene=21#wechat_redirect)

这是 java 高并发系列第 23 篇文章，环境：jdk1.8。

本文主要内容
------

1.  JUC 中的原子类介绍
    
2.  介绍基本类型原子类
    
3.  介绍数组类型原子类
    
4.  介绍引用类型原子类
    
5.  介绍对象属性修改相关原子类
    

预备知识
----

JUC 中的原子类都是都是依靠 **volatile**、**CAS**、**Unsafe** 类配合来实现的，需要了解的请移步：  
[volatile 与 Java 内存模型](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933088&idx=1&sn=f1d666dd799664b1989c77441b9d12c5&chksm=88621adebf1593c83501ac33d6a0e0de075f2b2e30caf986cf276cbb1c8dff0eac2a0a648b1d&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)  
[java 中的 CAS](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933166&idx=1&sn=15e614500676170b76a329efd3255c12&chksm=88621b10bf1592064befc5c9f0d78c56cda25c6d003e1711b85e5bfeb56c9fd30d892178db87&scene=21#wechat_redirect)  
[JUC 底层工具类 Unsafe](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933173&idx=1&sn=80eb550294677b0042fc030f90cce109&chksm=88621b0bbf15921d2274a7bf6afde912fec02a4c3ade9cfb50d03cdce73e07e33d08d35a3b27&token=1771071046&lang=zh_CN&scene=21#wechat_redirect)

JUC 中原子类介绍
----------

**什么是原子操作？**

**atomic** 翻译成中文是原子的意思。在化学上，我们知道原子是构成一般物质的最小单位，在化学反应中是不可分割的。**在我们这里 atomic 是指一个操作是不可中断的。即使是在多个线程一起执行的时候，一个操作一旦开始，就不会被其他线程干扰，所以，所谓原子类说简单点就是具有原子操作特征的类，原子操作类提供了一些修改数据的方法，这些方法都是原子操作的，在多线程情况下可以确保被修改数据的正确性**。

JUC 中对原子操作提供了强大的支持，这些类位于 **java.util.concurrent.atomic** 包中，如下图：

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06CZz5iboLmALMU3lokCMnS3B1sSs74DRqCTUbqEwToobJab3xmEuepGYTaJHjpCQISfZbSbDdCcDrA/640?wx_fmt=png)

JUC 中原子类思维导图
------------

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06CZz5iboLmALMU3lokCMnS3BhiapFsDEABpv0iazZY0K7da61xuTibnQG16DbRHIjfqngrNA4icogsVSHg/640?wx_fmt=png)

基本类型原子类
-------

使用原子的方式更新基本类型

*   AtomicInteger：int 类型原子类
    
*   AtomicLong：long 类型原子类
    
*   AtomicBoolean ：boolean 类型原子类
    

上面三个类提供的方法几乎相同，这里以 AtomicInteger 为例子来介绍。

**AtomicInteger 类常用方法**

```
public final int get() //获取当前的值
public final int getAndSet(int newValue)//获取当前的值，并设置新的值
public final int getAndIncrement()//获取当前的值，并自增
public final int getAndDecrement() //获取当前的值，并自减
public final int getAndAdd(int delta) //获取当前的值，并加上预期的值
boolean compareAndSet(int expect, int update) //如果输入的数值等于预期值，则以原子方式将该值设置为输入值（update）
public final void lazySet(int newValue)//最终设置为newValue,使用 lazySet 设置之后可能导致其他线程在之后的一小段时间内还是可以读到旧的值。


```

**部分源码**

```
private static final Unsafe unsafe = Unsafe.getUnsafe();
private static final long valueOffset;

static {
    try {
        valueOffset = unsafe.objectFieldOffset
            (AtomicInteger.class.getDeclaredField("value"));
    } catch (Exception ex) { throw new Error(ex); }
}

private volatile int value;


```

> 2 个关键字段说明：  
> **value**：使用 volatile 修饰，可以确保 value 在多线程中的可见性。  
> **valueOffset**：value 属性在 AtomicInteger 中的偏移量，通过这个偏移量可以快速定位到 value 字段，这个是实现 AtomicInteger 的关键。

**getAndIncrement 源码：**

```
public final int getAndIncrement() {
    return unsafe.getAndAddInt(this, valueOffset, 1);
}


```

内部调用的是 **Unsafe** 类中的 **getAndAddInt** 方法，我们看一下 **getAndAddInt** 源码：

```
public final int getAndAddInt(Object var1, long var2, int var4) {
    int var5;
    do {
        var5 = this.getIntVolatile(var1, var2);
    } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));

    return var5;
}


```

> 说明：  
> this.getIntVolatile：可以确保从主内存中获取变量最新的值。
> 
> compareAndSwapInt：CAS 操作，CAS 的原理是拿期望的值和原本的值作比较，如果相同则更新成新的值，可以确保在多线程情况下只有一个线程会操作成功，不成功的返回 false。
> 
> 上面有个 do-while 循环，compareAndSwapInt 返回 false 之后，会再次从主内存中获取变量的值，继续做 CAS 操作，直到成功为止。
> 
> getAndAddInt 操作相当于线程安全的 count++ 操作，如同：  
> synchronize(lock){  
>    count++;  
> }  
> count++ 操作实际上是被拆分为 3 步骤执行：
> 
> 1.  获取 count 的值，记做 A：A=count
>     
> 2.  将 A 的值 + 1，得到 B：B = A+1
>     
> 3.  让 B 赋值给 count：count = B  
>     多线程情况下会出现线程安全的问题，导致数据不准确。
>     
> 
> synchronize 的方式会导致占时无法获取锁的线程处于阻塞状态，性能比较低。CAS 的性能比 synchronize 要快很多。

**示例**

> 使用 AtomicInteger 实现网站访问量计数器功能，模拟 100 人同时访问网站，每个人访问 10 次，代码如下：

```
package com.itsoku.chat23;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo1 {
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
main，耗时：158,count=1000


```

通过输出中可以看出`incrementAndGet`在多线程情况下能确保数据的正确性。

数组类型原子类介绍
---------

使用原子的方式更新数组里的某个元素，可以确保修改数组中数据的线程安全性。

*   AtomicIntegerArray：整形数组原子操作类
    
*   AtomicLongArray：长整形数组原子操作类
    
*   AtomicReferenceArray ：引用类型数组原子操作类
    

上面三个类提供的方法几乎相同，所以我们这里以 AtomicIntegerArray 为例子来介绍。

**AtomicIntegerArray 类常用方法**

```
public final int get(int i) //获取 index=i 位置元素的值
public final int getAndSet(int i, int newValue)//返回 index=i 位置的当前的值，并将其设置为新值：newValue
public final int getAndIncrement(int i)//获取 index=i 位置元素的值，并让该位置的元素自增
public final int getAndDecrement(int i) //获取 index=i 位置元素的值，并让该位置的元素自减
public final int getAndAdd(int delta) //获取 index=i 位置元素的值，并加上预期的值
boolean compareAndSet(int expect, int update) //如果输入的数值等于预期值，则以原子方式将 index=i 位置的元素值设置为输入值（update）
public final void lazySet(int i, int newValue)//最终 将index=i 位置的元素设置为newValue,使用 lazySet 设置之后可能导致其他线程在之后的一小段时间内还是可以读到旧的值。


```

**示例**

> 统计网站页面访问量，假设网站有 10 个页面，现在模拟 100 个人并行访问每个页面 10 次，然后将每个页面访问量输出，应该每个页面都是 1000 次，代码如下：

```
package com.itsoku.chat23;

import java.util.Arrays;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicIntegerArray;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo2 {

    static AtomicIntegerArray pageRequest = new AtomicIntegerArray(new int[10]);

    /**
     * 模拟访问一次
     *
     * @param page 访问第几个页面
     * @throws InterruptedException
     */
    public static void request(int page) throws InterruptedException {
        //模拟耗时5毫秒
        TimeUnit.MILLISECONDS.sleep(5);
        //pageCountIndex为pageCount数组的下标，表示页面对应数组中的位置
        int pageCountIndex = page - 1;
        pageRequest.incrementAndGet(pageCountIndex);
    }

    public static void main(String[] args) throws InterruptedException {
        long starTime = System.currentTimeMillis();
        int threadSize = 100;
        CountDownLatch countDownLatch = new CountDownLatch(threadSize);
        for (int i = 0; i < threadSize; i++) {
            Thread thread = new Thread(() -> {
                try {

                    for (int page = 1; page <= 10; page++) {
                        for (int j = 0; j < 10; j++) {
                            request(page);
                        }
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
        System.out.println(Thread.currentThread().getName() + "，耗时：" + (endTime - starTime));

        for (int pageIndex = 0; pageIndex < 10; pageIndex++) {
            System.out.println("第" + (pageIndex + 1) + "个页面访问次数为" + pageRequest.get(pageIndex));
        }
    }
}


```

输出：

```
main，耗时：635
第1个页面访问次数为1000
第2个页面访问次数为1000
第3个页面访问次数为1000
第4个页面访问次数为1000
第5个页面访问次数为1000
第6个页面访问次数为1000
第7个页面访问次数为1000
第8个页面访问次数为1000
第9个页面访问次数为1000
第10个页面访问次数为1000


```

说明：

> 代码中将 10 个面的访问量放在了一个 int 类型的数组中，数组大小为 10，然后通过`AtomicIntegerArray`来操作数组中的每个元素，可以确保操作数据的原子性，每次访问会调用`incrementAndGet`，此方法需要传入数组的下标，然后对指定的元素做原子 + 1 操作。输出结果都是 1000，可以看出对于数组中元素的并发修改是线程安全的。如果线程不安全，则部分数据可能会小于 1000。

其他的一些方法可以自行操作一下，都非常简单。

引用类型原子类介绍
---------

基本类型原子类只能更新一个变量，如果需要原子更新多个变量，需要使用 引用类型原子类。

*   **AtomicReference**：引用类型原子类
    
*   **AtomicStampedRerence**：原子更新引用类型里的字段原子类
    
*   **AtomicMarkableReference** ：原子更新带有标记位的引用类型
    

**AtomicReference** 和 **AtomicInteger** 非常类似，不同之处在于 **AtomicInteger** 是对整数的封装，而 **AtomicReference** 则是对应普通的对象引用，它可以确保你在修改对象引用时的线程安全性。在介绍 **AtomicReference** 的同时，我们先来了解一个有关原子操作逻辑上的不足。

### ABA 问题

之前我们说过，线程判断被修改对象是否可以正确写入的条件是对象的当前值和期望值是否一致。这个逻辑从一般意义上来说是正确的，但是可能出现一个小小的例外，就是当你获得当前数据后，在准备修改为新值钱，对象的值被其他线程连续修改了两次，而经过这 2 次修改后，对象的值又恢复为旧值，这样，当前线程就无法正确判断这个对象究竟是否被修改过，这就是所谓的 ABA 问题，可能会引发一些问题。

**举个例子**

有一家蛋糕店，为了挽留客户，决定为贵宾卡客户一次性赠送 20 元，刺激客户充值和消费，但条件是，每一位客户只能被赠送一次，现在我们用`AtomicReference`来实现这个功能，代码如下：

```
package com.itsoku.chat22;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo3 {
    //账户原始余额
    static int accountMoney = 19;
    //用于对账户余额做原子操作
    static AtomicReference<Integer> money = new AtomicReference<>(accountMoney);

    /**
     * 模拟2个线程同时更新后台数据库，为用户充值
     */
    static void recharge() {
        for (int i = 0; i < 2; i++) {
            new Thread(() -> {
                for (int j = 0; j < 5; j++) {
                    Integer m = money.get();
                    if (m == accountMoney) {
                        if (money.compareAndSet(m, m + 20)) {
                            System.out.println("当前余额：" + m + "，小于20，充值20元成功，余额：" + money.get() + "元");
                        }
                    }
                    //休眠100ms
                    try {
                        TimeUnit.MILLISECONDS.sleep(100);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }).start();
        }
    }

    /**
     * 模拟用户消费
     */
    static void consume() throws InterruptedException {
        for (int i = 0; i < 5; i++) {
            Integer m = money.get();
            if (m > 20) {
                if (money.compareAndSet(m, m - 20)) {
                    System.out.println("当前余额：" + m + "，大于10，成功消费10元，余额：" + money.get() + "元");
                }
            }
            //休眠50ms
            TimeUnit.MILLISECONDS.sleep(50);
        }
    }

    public static void main(String[] args) throws InterruptedException {
        recharge();
        consume();
    }

}


```

输出：

```
当前余额：19，小于20，充值20元成功，余额：39元
当前余额：39，大于10，成功消费10元，余额：19元
当前余额：19，小于20，充值20元成功，余额：39元
当前余额：39，大于10，成功消费10元，余额：19元
当前余额：19，小于20，充值20元成功，余额：39元
当前余额：39，大于10，成功消费10元，余额：19元
当前余额：19，小于20，充值20元成功，余额：39元


```

> 从输出中可以看到，这个账户被先后反复多次充值。其原因是账户余额被反复修改，修改后的值和原有的数值 19 一样，使得 CAS 操作无法正确判断当前数据是否被修改过（是否被加过 20）。虽然这种情况出现的概率不大，但是依然是有可能出现的，因此，当业务上确实可能出现这种情况时，我们必须多加防范。JDK 也为我们考虑到了这种情况，使用`AtomicStampedReference`可以很好地解决这个问题。

### 使用 AtomicStampedRerence 解决 ABA 的问题

`AtomicReference`无法解决上述问题的根本原因是，对象在被修改过程中丢失了状态信息，比如充值 20 元的时候，需要同时标记一个状态，用来标注用户被充值过。因此我们只要能够记录对象在修改过程中的状态值，就可以很好地解决对象被反复修改导致线程无法正确判断对象状态的问题。

`AtomicStampedRerence`正是这么做的，他内部不仅维护了对象的值，还维护了一个时间戳（我们这里把他称为时间戳，实际上它可以使用任何一个整形来表示状态值），当 AtomicStampedRerence 对应的数值被修改时，除了更新数据本身外，还必须要更新时间戳。当 AtomicStampedRerence 设置对象值时，对象值及时间戳都必须满足期望值，写入才会成功。因此，即使对象值被反复读写，写回原值，只要时间戳发生变量，就能防止不恰当的写入。

`AtomicStampedRerence`的几个 Api 在`AtomicReference`的基础上新增了有关时间戳的信息。

```
//比较设置，参数依次为：期望值、写入新值、期望时间戳、新时间戳
public boolean compareAndSet(V expectedReference, V newReference, int expectedStamp, int newStamp);
//获得当前对象引用
public V getReference();
//获得当前时间戳
public int getStamp();
//设置当前对象引用和时间戳
public void set(V newReference, int newStamp);


```

现在我们使用`AtomicStampedRerence`来修改一下上面充值的问题，代码如下：

```
package com.itsoku.chat22;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.atomic.AtomicStampedReference;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo4 {
    //账户原始余额
    static int accountMoney = 19;
    //用于对账户余额做原子操作
    static AtomicStampedReference<Integer> money = new AtomicStampedReference<>(accountMoney, 0);

    /**
     * 模拟2个线程同时更新后台数据库，为用户充值
     */
    static void recharge() {
        for (int i = 0; i < 2; i++) {
            int stamp = money.getStamp();
            new Thread(() -> {
                for (int j = 0; j < 50; j++) {
                    Integer m = money.getReference();
                    if (m == accountMoney) {
                        if (money.compareAndSet(m, m + 20, stamp, stamp + 1)) {
                            System.out.println("当前时间戳：" + money.getStamp() + ",当前余额：" + m + "，小于20，充值20元成功，余额：" + money.getReference() + "元");
                        }
                    }
                    //休眠100ms
                    try {
                        TimeUnit.MILLISECONDS.sleep(100);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }).start();
        }
    }

    /**
     * 模拟用户消费
     */
    static void consume() throws InterruptedException {
        for (int i = 0; i < 50; i++) {
            Integer m = money.getReference();
            int stamp = money.getStamp();
            if (m > 20) {
                if (money.compareAndSet(m, m - 20, stamp, stamp + 1)) {
                    System.out.println("当前时间戳：" + money.getStamp() + ",当前余额：" + m + "，大于10，成功消费10元，余额：" + money.getReference() + "元");
                }
            }
            //休眠50ms
            TimeUnit.MILLISECONDS.sleep(50);
        }
    }

    public static void main(String[] args) throws InterruptedException {
        recharge();
        consume();
    }

}


```

输出：

```
当前时间戳：1,当前余额：19，小于20，充值20元成功，余额：39元
当前时间戳：2,当前余额：39，大于10，成功消费10元，余额：19元


```

结果正常了。

**关于这个时间戳的，在数据库修改数据中也有类似的用法，比如 2 个编辑同时编辑一篇文章，同时提交，只允许一个用户提交成功，提示另外一个用户：博客已被其他人修改，如何实现呢？**

> 博客表：t_blog（id,content,stamp)，stamp 默认值为 0，每次更新 + 1
> 
> A、B 二个编辑同时对一篇文章进行编辑，stamp 都为 0，当点击提交的时候，将 stamp 和 id 作为条件更新博客内容，执行的 sql 如下：
> 
> **update t_blog set content = 更新的内容, stamp = stamp+1 where id = 博客 id and stamp = 0;**
> 
> 这条 update 会返回影响的行数，只有一个会返回 1，表示更新成功，另外一个提交者返回 0，表示需要修改的数据已经不满足条件了，被其他用户给修改了。这种修改数据的方式也叫乐观锁。

对象的属性修改原子类介绍
------------

如果需要原子更新某个类里的某个字段时，需要用到对象的属性修改原子类。

*   AtomicIntegerFieldUpdater：原子更新整形字段的值
    
*   AtomicLongFieldUpdater：原子更新长整形字段的值
    
*   AtomicReferenceFieldUpdater ：原子更新应用类型字段的值
    

要想原子地更新对象的属性需要两步：

1.  第一步，因为对象的属性修改类型原子类都是抽象类，所以每次使用都必须使用静态方法 newUpdater() 创建一个更新器，并且需要设置想要更新的类和属性。
    
2.  第二步，更新的对象属性必须使用 public volatile 修饰符。
    

上面三个类提供的方法几乎相同，所以我们这里以`AtomicReferenceFieldUpdater`为例子来介绍。

调用`AtomicReferenceFieldUpdater`静态方法`newUpdater`创建`AtomicReferenceFieldUpdater`对象

```
public static <U, W> AtomicReferenceFieldUpdater<U, W> newUpdater(Class<U> tclass, Class<W> vclass, String fieldName)


```

说明:

> 三个参数
> 
> tclass：需要操作的字段所在的类  
> vclass：操作字段的类型  
> fieldName：字段名称

**示例**

> 多线程并发调用一个类的初始化方法，如果未被初始化过，将执行初始化工作，要求只能初始化一次

代码如下：

```
package com.itsoku.chat22;

import com.sun.org.apache.xpath.internal.operations.Bool;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo5 {

    static Demo5 demo5 = new Demo5();
    //isInit用来标注是否被初始化过
    volatile Boolean isInit = Boolean.FALSE;
    AtomicReferenceFieldUpdater<Demo5, Boolean> updater = AtomicReferenceFieldUpdater.newUpdater(Demo5.class, Boolean.class, "isInit");

    /**
     * 模拟初始化工作
     *
     * @throws InterruptedException
     */
    public void init() throws InterruptedException {
        //isInit为false的时候，才进行初始化，并将isInit采用原子操作置为true
        if (updater.compareAndSet(demo5, Boolean.FALSE, Boolean.TRUE)) {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + "，开始初始化!");
            //模拟休眠3秒
            TimeUnit.SECONDS.sleep(3);
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + "，初始化完毕!");
        } else {
            System.out.println(System.currentTimeMillis() + "," + Thread.currentThread().getName() + "，有其他线程已经执行了初始化!");
        }
    }

    public static void main(String[] args) {
        for (int i = 0; i < 5; i++) {
            new Thread(() -> {
                try {
                    demo5.init();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }).start();
        }
    }
}


```

输出：

```
1565159962098,Thread-0，开始初始化!
1565159962098,Thread-3，有其他线程已经执行了初始化!
1565159962098,Thread-4，有其他线程已经执行了初始化!
1565159962098,Thread-2，有其他线程已经执行了初始化!
1565159962098,Thread-1，有其他线程已经执行了初始化!
1565159965100,Thread-0，初始化完毕!


```

说明：

> 1.  isInit 属性必须要 volatille 修饰，可以确保变量的可见性
>     
> 2.  可以看出多线程同时执行`init()`方法，只有一个线程执行了初始化的操作，其他线程跳过了。多个线程同时到达`updater.compareAndSet`，只有一个会成功。
>     

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
    

**java 高并发系列连载中，总计估计会有四五十篇文章。**

**阿里 p7 一起学并发，公众号：路人甲 java，每天获取最新文章！**

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06AcmgEdFkkWEgWeMkg0tpVAH0UK9CMukCQEk0KdnicBdPCgg2sEXr6nG0NKGDGZcrcj7ZaHF8Dnudw/640?wx_fmt=jpeg)