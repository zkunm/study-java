> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933050&idx=1&sn=497c4de99086f95bed11a4317a51e6a6&chksm=88621a84bf159392c9e3e243355313c397e0658df6b88769cdd182cb5d39b6f25686c86beffc&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)

java 高并发系列第 4 篇文章

JMM(java 内存模型)，由于并发程序要比串行程序复杂很多，其中一个重要原因是并发程序中数据访问**一致性**和**安全性**将会受到严重挑战。**如何保证一个线程可以看到正确的数据呢？**这个问题看起来很白痴。对于串行程序来说，根本就是小菜一碟，如果你读取一个变量，这个变量的值是 1，那么你读取到的一定是 1，就是这么简单的问题在并行程序中居然变得复杂起来。事实上，如果不加控制地任由线程胡乱并行，即使原本是 1 的数值，你也可能读到 2。因此我们需要在深入了解并行机制的前提下，再定义一种规则，保证多个线程间可以有小弟，正确地协同工作。而 JMM 也就是为此而生的。

JMM 关键技术点都是围绕着多线程的**原子性、可见性、有序性**来建立的。我们需要先了解这些概念。

**原子性**
-------

原子性是指**操作是不可分的**，要么全部一起执行，要么不执行。在 java 中，其表现在对于共享变量的某些操作，是不可分的，必须连续的完成。比如 a++，对于共享变量 a 的操作，实际上会执行 3 个步骤：

1. 读取变量 a 的值，假如 a=1

2.a 的值 + 1，为 2 

3. 将 2 值赋值给变量 a，此时 a 的值应该为 2

这三个操作中任意一个操作，a 的值如果被其他线程篡改了，那么都会出现我们不希望出现的结果。所以必须保证这 3 个操作是原子性的，在操作 a++ 的过程中，其他线程不会改变 a 的值，如果在上面的过程中出现其他线程修改了 a 的值，在满足原子性的原则下，上面的操作应该失败。

java 中实现原子操作的方法大致有 2 种：**锁机制**、**无锁 CAS 机制**，后面的章节中会有介绍。

**可见性**
-------

**可见性是值一个线程对共享变量的修改，对于另一个线程来说是否是可以看到的。**有些同学会说修改同一个变量，那肯定是可以看到的，难道线程眼盲了？

为什么会出现这种问题呢？

看一下 java 线程内存模型：

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06AfoFlYGibABFUia3HUlyHyYlZN9FpaJmILun5pF3oGYicPgGVY7nAM13hZU1icjAfzkVj3TBIjbAPVicg/640?wx_fmt=png)

*   我们定义的所有变量都储存在 `主内存`中
    
*   每个线程都有自己 `独立的工作内存`，里面保存该线程使用到的变量的副本（主内存中该变量的一份拷贝）
    
*   线程对共享变量所有的操作都必须在自己的工作内存中进行，不能直接从主内存中读写（不能越级）
    
*   不同线程之间也无法直接访问其他线程的工作内存中的变量，线程间变量值的传递需要通过主内存来进行。（同级不能相互访问）
    

线程需要修改一个共享变量 X，需要先把 X 从主内存复制一份到线程的工作内存，在自己的工作内存中修改完毕之后，再从工作内存中回写到主内存。如果线程对变量的操作没有刷写回主内存的话，仅仅改变了自己的工作内存的变量的副本，那么对于其他线程来说是不可见的。而如果另一个变量没有读取主内存中的新的值，而是使用旧的值的话，同样的也可以列为不可见。

**共享变量可见性的实现原理：**

线程 A 对共享变量的修改要被线程 B 及时看到的话，需要进过以下步骤：

1. 线程 A 在自己的工作内存中修改变量之后，需要将变量的值刷新到主内存中 2. 线程 B 要把主内存中变量的值更新到工作内存中

关于线程可见性的控制，可以使用 **volatile**、**synchronized**、**锁**来实现，后面章节会有详细介绍。

**有序性**
-------

有序性指的是程序按照代码的先后顺序执行。

为了性能优化，编译器和处理器会进行指令冲排序，有时候会改变程序语句的先后顺序，比如程序。

```
int a = 1;  //1
int b = 20; //2
int c = a + b; //3

```

编译器优化后可能变成

```
int b = 20;  //1
int a = 1; //2
int c = a + b; //3

```

上面这个例子中，编译器调整了语句的顺序，但是不影响程序的最终结果。

在单例模式的实现上有一种双重检验锁定的方式，代码如下：

```
public class Singleton {
  static Singleton instance;
  static Singleton getInstance(){
    if (instance == null) {
      synchronized(Singleton.class) {
        if (instance == null)
          instance = new Singleton();
        }
    }
    return instance;
  }
}

```

我们先看 `instance=newSingleton();`

**未被编译器优化的操作：**

1.  指令 1：分配一款内存 M
    
2.  指令 2：在内存 M 上初始化 Singleton 对象
    
3.  指令 3：将 M 的地址赋值给 instance 变量
    

**编译器优化后的操作指令：**

1.  指令 1：分配一块内存 S
    
2.  指令 2：将 M 的地址赋值给 instance 变量
    
3.  指令 3：在内存 M 上初始化 Singleton 对象
    

现在有 2 个线程，刚好执行的代码被编译器优化过，过程如下：

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06AfoFlYGibABFUia3HUlyHyYlfqX0NuI6W6vaXJadQtkpnYHAmKVXrjOmw6RlABYXBC0GP27xCGxsEw/640?wx_fmt=png)

最终线程 B 获取的 instance 是没有初始化的，此时去使用 instance 可能会产生一些意想不到的错误。

现在比较好的做法就是采用静态内部内的方式实现：

```
public class SingletonDemo {
    private SingletonDemo() {
    }
    private static class SingletonDemoHandler{
        private static SingletonDemo instance = new SingletonDemo();
    }
    public static SingletonDemo getInstance() {
        return SingletonDemoHandler.instance;
    }
}

```

**java 高并发系列目录：**
-----------------

[1.java 高并发系列 - 第 1 天: 必须知道的几个概念](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933019&idx=1&sn=3455877c451de9c61f8391ffdc1eb01d&chksm=88621aa5bf1593b377e2f090bf37c87ba60081fb782b2371b5f875e4a6cadc3f92ff6d747e32&scene=21#wechat_redirect)

[2.java 高并发系列 - 第 2 天: 并发级别](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933024&idx=1&sn=969bfa5e2c3708e04adaf6401503c187&chksm=88621a9ebf1593886dd3f0f5923b6f929eade0b43204b98a8d0622a5f542deff4f6a633a13c8&scene=21#wechat_redirect)

[3.java 高并发系列 - 第 3 天: 有关并行的两个重要定律](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933041&idx=1&sn=82af7c702f737782118a9141858117d1&chksm=88621a8fbf159399be1d4834f6f845fa530b94a4ca7c0eaa61de508f725ad0fab74b074d73be&scene=21#wechat_redirect)

希望您能把这篇文章分享给更多的朋友，让它帮助更多的人。帮助他人，快乐自己，最后，感谢您的阅读。微信扫码入群一起交流。

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06AfoFlYGibABFUia3HUlyHyYlia0BS6gjaBHRhhFkUxTRjicTaRqzA7cVhtw2IXv0C4iaQXicK0KohuWpvg/640?wx_fmt=jpeg)