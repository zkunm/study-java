> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933088&idx=1&sn=f1d666dd799664b1989c77441b9d12c5&chksm=88621adebf1593c83501ac33d6a0e0de075f2b2e30caf986cf276cbb1c8dff0eac2a0a648b1d&token=2041017112&lang=zh_CN&scene=21#wechat_redirect)

**java 高并发系列第 7 篇文章**
---------------------

```
public class Demo09 {
    public static boolean flag = true;
    public static class T1 extends Thread {
        public T1(String name) {
            super(name);
        }
        @Override
        public void run() {
            System.out.println("线程" + this.getName() + " in");
            while (flag) {
                ;
            }
            System.out.println("线程" + this.getName() + "停止了");
        }
    }
    public static void main(String[] args) throws InterruptedException {
        new T1("t1").start();
        //休眠1秒
        Thread.sleep(1000);
        //将flag置为false
        flag = false;
    }
}

```

运行上面代码，会发现程序无法终止。

线程 t1 的 run() 方法中有个循环，通过 flag 来控制循环是否结束，主线程中休眠了 1 秒，将 flag 置为 false，按说此时线程 t1 会检测到 flag 为 false，打印 “线程 t1 停止了”，为何和我们期望的结果不一样呢？运行上面的代码我们可以判断，t1 中看到的 flag 一直为 true，主线程将 flag 置为 false 之后，t1 线程中并没有看到，所以一直死循环。

那么 t1 中为什么看不到被主线程修改之后的 flag？

要解释这个，我们需要先了解一下 java 内存模型（JMM），Java 线程之间的通信由 Java 内存模型（本文简称为 JMM）控制，JMM 决定一个线程对共享变量的写入何时对另一个线程可见。从抽象的角度来看，JMM 定义了线程和主内存之间的抽象关系：线程之间的共享变量存储在主内存（main memory）中，每个线程都有一个私有的本地内存（local memory），本地内存中存储了该线程以读 / 写共享变量的副本。本地内存是 JMM 的一个抽象概念，并不真实存在。它涵盖了缓存，写缓冲区，寄存器以及其他的硬件和编译器优化。Java 内存模型的抽象示意图如下：

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06CFf0kLqBQuTib3vopD6e9dByoovA64uE9fGmtqbtfBGP8cgedz8E4A1hia4GWpOCpJrJwK7NsJPq7w/640?wx_fmt=png)

从上图中可以看出，线程 A 需要和线程 B 通信，必须要经历下面 2 个步骤：

1.  首先，线程 A 把本地内存 A 中更新过的共享变量刷新到主内存中去
    
2.  然后，线程 B 到主内存中去读取线程 A 之前已更新过的共享变量
    

下面通过示意图来说明这两个步骤：

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06CFf0kLqBQuTib3vopD6e9dBo2qc8CmicVvZkQEAnv2hz6qgJsIdjFDbmhmVNTw36IHAUBk8I41l77g/640?wx_fmt=png)

如上图所示，本地内存 A 和 B 有主内存中共享变量 x 的副本。假设初始时，这三个内存中的 x 值都为 0。线程 A 在执行时，把更新后的 x 值（假设值为 1）临时存放在自己的本地内存 A 中。当线程 A 和线程 B 需要通信时，线程 A 首先会把自己本地内存中修改后的 x 值刷新到主内存中，此时主内存中的 x 值变为了 1。随后，线程 B 到主内存中去读取线程 A 更新后的 x 值，此时线程 B 的本地内存的 x 值也变为了 1。从整体来看，这两个步骤实质上是线程 A 在向线程 B 发送消息，而且这个通信过程必须要经过主内存。JMM 通过控制主内存与每个线程的本地内存之间的交互，来为 java 程序员提供内存可见性保证。

对 JMM 了解之后，我们再看看文章开头的问题，线程 t1 中为何看不到被主线程修改为 false 的 flag 的值，有两种可能:

1.  **主线程修改了 flag 之后，未将其刷新到主内存，所以 t1 看不到**
    
2.  **主线程将 flag 刷新到了主内存，但是 t1 一直读取的是自己工作内存中 flag 的值，没有去主内存中获取 flag 最新的值**
    

**对于上面 2 种情况，有没有什么办法可以解决？**

**是否有这样的方法：线程中修改了工作内存中的副本之后，立即将其刷新到主内存；工作内存中每次读取共享变量时，都去主内存中重新读取，然后拷贝到工作内存。**

java 帮我们提供了这样的方法，使用 **volatile 修饰共享变量**，就可以达到上面的效果，被 volatile 修改的变量有以下特点：

1.  **线程中读取的时候，每次读取都会去主内存中读取共享变量最新的值，然后将其复制到工作内存**
    
2.  **线程中修改了工作内存中变量的副本，修改之后会立即刷新到主内存**
    

我们修改一下开头的示例代码：

```
public
 
volatile
 
static
 
boolean
 flag 
=
 
true
;
```

使用 volatile 修饰 flag 变量，然后运行一下程序，输出：

```
线程t1 in
线程t1停止了

```

这下程序可以正常停止了。

volatile 解决了共享变量在多线程中可见性的问题，可见性是指一个线程对共享变量的修改，对于另一个线程来说是否是可以看到的。

**码子不易，感觉还可以的，帮忙分享一下，谢谢！**

**java 高并发系列目录：**
-----------------

[1.java 高并发系列 - 第 1 天: 必须知道的几个概念](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933019&idx=1&sn=3455877c451de9c61f8391ffdc1eb01d&chksm=88621aa5bf1593b377e2f090bf37c87ba60081fb782b2371b5f875e4a6cadc3f92ff6d747e32&scene=21#wechat_redirect)

[2.java 高并发系列 - 第 2 天: 并发级别](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933024&idx=1&sn=969bfa5e2c3708e04adaf6401503c187&chksm=88621a9ebf1593886dd3f0f5923b6f929eade0b43204b98a8d0622a5f542deff4f6a633a13c8&scene=21#wechat_redirect)

[3.java 高并发系列 - 第 3 天: 有关并行的两个重要定律](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933041&idx=1&sn=82af7c702f737782118a9141858117d1&chksm=88621a8fbf159399be1d4834f6f845fa530b94a4ca7c0eaa61de508f725ad0fab74b074d73be&scene=21#wechat_redirect)

[4.java 高并发系列 - 第 4 天: JMM 相关的一些概念](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933050&idx=1&sn=497c4de99086f95bed11a4317a51e6a6&chksm=88621a84bf159392c9e3e243355313c397e0658df6b88769cdd182cb5d39b6f25686c86beffc&scene=21#wechat_redirect)

[5.java 并发系列第 5 天 - 深入理解进程和线程](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933069&idx=1&sn=82105bb5b759ec8b1f3a69062a22dada&chksm=88621af3bf1593e5ece7c1da3df3b4be575271a2eaca31c784591ed0497252caa1f6a6ec0545&scene=21#wechat_redirect)

[6.java 高并发系列 - 第 6 天: 线程的基本操作](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933082&idx=1&sn=e940c4f94a8c1527b6107930eefdcd00&chksm=88621ae4bf1593f270991e6f6bac5769ea850fa02f11552d1aa91725f4512d4f1ff8f18fcdf3&scene=21#wechat_redirect)[](http://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933069&idx=1&sn=82105bb5b759ec8b1f3a69062a22dada&chksm=88621af3bf1593e5ece7c1da3df3b4be575271a2eaca31c784591ed0497252caa1f6a6ec0545&scene=21#wechat_redirect)

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06B0V4c4HlyWomib6HajyYNozC1P22h3Z478Y16Qx0h3Lu2sibfiawU2wR2pQianBYXmj0kInB31Rjoia3Q/640?wx_fmt=jpeg)