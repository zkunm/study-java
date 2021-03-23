> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933197&idx=1&sn=1ef33a6403680ee49b3acf22d4a4aa34&chksm=88621b73bf159265c8775bc7d80e44f68bc162b7301f5ac8dce9669d17643934404440b6560f&token=2027319240&lang=zh_CN&scene=21#wechat_redirect)

这是 java 高并发系列第 26 篇文章。

环境：jdk1.8。

本文内容
----

1.  了解 JUC 常见集合，学会使用
    
2.  ConcurrentHashMap
    
3.  ConcurrentSkipListMap
    
4.  ConcurrentSkipListSet
    
5.  CopyOnWriteArraySet
    
6.  介绍 Queue 接口
    
7.  ConcurrentLinkedQueue
    
8.  CopyOnWriteArrayList
    
9.  介绍 Deque 接口
    
10.  ConcurrentLinkedDeque
    

JUC 集合框架图
---------

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06DcB27fboiaibInWuiaAPa8gEW3iaN486O4bC6tlWvJJLw9EstgB0Eh1rTmicw2xuD3JlC2a8yaxDFr6Sw/640?wx_fmt=png)

> 图可以看到，JUC 的集合框架也是从 Map、List、Set、Queue、Collection 等超级接口中继承而来的。所以，大概可以知道 JUC 下的集合包含了一一些基本操作，并且变得线程安全。

Map
---

### ConcurrentHashMap

功能和 HashMap 基本一致，内部使用红黑树实现的。

**特性：**

1.  迭代结果和存入顺序不一致
    
2.  key 和 value 都不能为空
    
3.  线程安全的
    

### ConcurrentSkipListMap

内部使用跳表实现的，放入的元素会进行排序，排序算法支持 2 种方式来指定：

1.  通过构造方法传入一个`Comparator`
    
2.  放入的元素实现`Comparable`接口
    

上面 2 种方式必选一个，如果 2 种都有，走规则 1。

**特性：**

1.  迭代结果和存入顺序不一致
    
2.  放入的元素会排序
    
3.  key 和 value 都不能为空
    
4.  线程安全的
    

List
----

### CopyOnWriteArrayList

实现 List 的接口的，一般我们使用`ArrayList、LinkedList、Vector`，其中只有 Vector 是线程安全的，可以使用 Collections 静态类的 synchronizedList 方法对 ArrayList、LinkedList 包装为线程安全的 List，不过这些方式在保证线程安全的情况下性能都不高。

CopyOnWriteArrayList 是线程安全的 List，内部使用数组存储数据，`集合中多线程并行操作一般存在4种情况：读读、读写、写写、写读，这个只有在写写操作过程中会导致其他线程阻塞，其他3种情况均不会阻塞`，所以读取的效率非常高。

可以看一下这个类的名称：CopyOnWrite，意思是在写入操作的时候，进行一次自我复制，换句话说，当这个 List 需要修改时，并不修改原有内容（这对于保证当前在读线程的数据一致性非常重要），而是在原有存放数据的数组上产生一个副本，在副本上修改数据，修改完毕之后，用副本替换原来的数组，这样也保证了写操作不会影响读。

**特性：**

1.  迭代结果和存入顺序一致
    
2.  元素不重复
    
3.  元素可以为空
    
4.  线程安全的
    
5.  读读、读写、写读 3 种情况不会阻塞；写写会阻塞
    
6.  无界的
    

Set
---

### ConcurrentSkipListSet

有序的 Set，内部基于 ConcurrentSkipListMap 实现的，放入的元素会进行排序，排序算法支持 2 种方式来指定：

1.  通过构造方法传入一个`Comparator`
    
2.  放入的元素实现`Comparable`接口
    

上面 2 种方式需要实现一个，如果 2 种都有，走规则 1

**特性：**

1.  迭代结果和存入顺序不一致
    
2.  放入的元素会排序
    
3.  元素不重复
    
4.  元素不能为空
    
5.  线程安全的
    
6.  无界的
    

### CopyOnWriteArraySet

内部使用 CopyOnWriteArrayList 实现的，将所有的操作都会转发给 CopyOnWriteArrayList。

**特性：**

1.  迭代结果和存入顺序不一致
    
2.  元素不重复
    
3.  元素可以为空
    
4.  线程安全的
    
5.  读读、读写、写读 不会阻塞；写写会阻塞
    
6.  无界的
    

Queue
-----

Queue 接口中的方法，我们再回顾一下：

<table data-darkmode-bgcolor-16079192551281="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192551281="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)"><thead data-darkmode-bgcolor-16079192551281="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192551281="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)"><tr data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th width="129" data-darkmode-bgcolor-16079192551281="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192551281="rgb(240, 240, 240)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; background-color: rgb(240, 240, 240); text-align: left;">操作类型</th><th width="193" data-darkmode-bgcolor-16079192551281="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192551281="rgb(240, 240, 240)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; background-color: rgb(240, 240, 240); text-align: left;">抛出异常</th><th width="185" data-darkmode-bgcolor-16079192551281="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192551281="rgb(240, 240, 240)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; background-color: rgb(240, 240, 240); text-align: left;">返回特殊值</th></tr></thead><tbody data-darkmode-bgcolor-16079192551281="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192551281="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)"><tr data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="130" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">插入</td><td width="193" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">add(e)</code></td><td width="185" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">offer(e)</code></td></tr><tr data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td width="130" data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">移除</td><td width="193" data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)">remove()</code></td><td width="185" data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)">poll()</code></td></tr><tr data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="130" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">检查</td><td width="193" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">element()</code></td><td width="185" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">peek()</code></td></tr></tbody></table>

3 种操作，每种操作有 2 个方法，不同点是队列为空或者满载时，调用方法是抛出异常还是返回特殊值，大家按照表格中的多看几遍，加深记忆。

### ConcurrentLinkedQueue

高效并发队列，内部使用链表实现的。

**特性：**

1.  线程安全的
    
2.  迭代结果和存入顺序一致
    
3.  元素可以重复
    
4.  元素不能为空
    
5.  线程安全的
    
6.  无界队列
    

Deque
-----

先介绍一下 Deque 接口，双向队列 (Deque) 是 Queue 的一个子接口，双向队列是指该队列两端的元素既能入队 (offer) 也能出队 (poll)，如果将 Deque 限制为只能从一端入队和出队，则可实现栈的数据结构。对于栈而言，有入栈(push) 和出栈(pop)，遵循先进后出原则。

一个线性 collection，支持在两端插入和移除元素。名称 _deque_ 是 “double ended queue（双端队列）” 的缩写，通常读为“deck”。大多数 `Deque` 实现对于它们能够包含的元素数没有固定限制，但此接口既支持有容量限制的双端队列，也支持没有固定大小限制的双端队列。

此接口定义在双端队列两端访问元素的方法。提供插入、移除和检查元素的方法。每种方法都存在两种形式：一种形式在操作失败时抛出异常，另一种形式返回一个特殊值（`null` 或 `false`，具体取决于操作）。插入操作的后一种形式是专为使用有容量限制的 `Deque` 实现设计的；在大多数实现中，插入操作不能失败。

下表总结了上述 12 种方法：

![](https://mmbiz.qpic.cn/mmbiz_png/xicEJhWlK06DcB27fboiaibInWuiaAPa8gEWhcjKHUPBmW4ps8MS0m5vCKAcicFrrwnPEf05pzpicX2P3ricHB5yOLpzw/640?wx_fmt=png)

此接口扩展了 `Queue`接口。在将双端队列用作队列时，将得到 FIFO（先进先出）行为。将元素添加到双端队列的末尾，从双端队列的开头移除元素。从 `Queue` 接口继承的方法完全等效于 `Deque` 方法，如下表所示：  

<table data-darkmode-bgcolor-16079192551281="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192551281="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)"><thead data-darkmode-bgcolor-16079192551281="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192551281="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)"><tr data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th width="237" data-darkmode-bgcolor-16079192551281="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192551281="rgb(240, 240, 240)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; text-align: left; background-color: rgb(240, 240, 240);"><strong data-darkmode-bgcolor-16079192551281="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192551281="rgb(240, 240, 240)" data-darkmode-color-16079192551281="rgb(233, 105, 0)" data-darkmode-original-color-16079192551281="rgb(233, 105, 0)">Queue 方法</strong></th><th width="291" data-darkmode-bgcolor-16079192551281="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192551281="rgb(240, 240, 240)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; text-align: left; background-color: rgb(240, 240, 240);"><strong data-darkmode-bgcolor-16079192551281="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192551281="rgb(240, 240, 240)" data-darkmode-color-16079192551281="rgb(233, 105, 0)" data-darkmode-original-color-16079192551281="rgb(233, 105, 0)">等效 Deque 方法</strong></th></tr></thead><tbody data-darkmode-bgcolor-16079192551281="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192551281="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)"><tr data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="238" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">add(e)</code></td><td width="291" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">addLast(e)</code></td></tr><tr data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td width="238" data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)">offer(e)</code></td><td width="291" data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)">offerLast(e)</code></td></tr><tr data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="238" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">remove()</code></td><td width="291" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">removeFirst()</code></td></tr><tr data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td width="238" data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)">poll()</code></td><td width="291" data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)">pollFirst()</code></td></tr><tr data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="238" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">element()</code></td><td width="291" data-darkmode-bgcolor-16079192551281="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192551281="rgb(255,255,255)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">getFirst()</code></td></tr><tr data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td width="238" data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)">peek()</code></td><td width="291" data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(163, 163, 163)" data-darkmode-original-color-16079192551281="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192551281="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192551281="rgb(248, 248, 248)" data-darkmode-color-16079192551281="rgb(248, 35, 117)" data-darkmode-original-color-16079192551281="rgb(248, 35, 117)">peekFirst()</code></td></tr></tbody></table>

ConcurrentLinkedDeque
---------------------

实现了 Deque 接口，内部使用链表实现的高效的并发双端队列。

**特性：**

1.  线程安全的
    
2.  迭代结果和存入顺序一致
    
3.  元素可以重复
    
4.  元素不能为空
    
5.  线程安全的
    
6.  无界队列
    

BlockingQueue
-------------

关于阻塞队列，上一篇有详细介绍，可以看看：**[掌握 JUC 中的阻塞队列](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933190&idx=1&sn=916f539cb1e695948169a358549227d3&chksm=88621b78bf15926e0a94e50a43651dab0ceb14a1fb6b1d8b9b75e38c6d8ac908e31dd2131ded&token=1963100670&lang=zh_CN&scene=21#wechat_redirect)**

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
    
23.  **[第 23 天：JUC 中原子类，一篇就够了](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933181&idx=1&sn=a1e254365d405cdc2e3b8372ecda65ee&chksm=88621b03bf159215ca696c9f81e228d0544a7598b03fe30436babc95c6a95e848161f61b868c&token=743622661&lang=zh_CN&scene=21#wechat_redirect)**
    
24.  **[第 24 天：ThreadLocal、InheritableThreadLocal（通俗易懂）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933186&idx=1&sn=079567e8799e43cb734b833c44055c01&chksm=88621b7cbf15926aace88777445822314d6eed2c1f5559b36cb6a6e181f0e543ee14d832ebc2&token=1963100670&lang=zh_CN&scene=21#wechat_redirect)**
    
25.  **[第 25 天：掌握 JUC 中的阻塞队列](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933190&idx=1&sn=916f539cb1e695948169a358549227d3&chksm=88621b78bf15926e0a94e50a43651dab0ceb14a1fb6b1d8b9b75e38c6d8ac908e31dd2131ded&token=1963100670&lang=zh_CN&scene=21#wechat_redirect)**
    

**阿里 p7 一起学并发，公众号：路人甲 java，每天获取最新文章！**

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06AcmgEdFkkWEgWeMkg0tpVAH0UK9CMukCQEk0KdnicBdPCgg2sEXr6nG0NKGDGZcrcj7ZaHF8Dnudw/640?wx_fmt=jpeg)