> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933190&idx=1&sn=916f539cb1e695948169a358549227d3&chksm=88621b78bf15926e0a94e50a43651dab0ceb14a1fb6b1d8b9b75e38c6d8ac908e31dd2131ded&token=1963100670&lang=zh_CN&scene=21#wechat_redirect)

这是 java 高并发系列第 25 篇文章。

环境：jdk1.8。

本文内容
----

1.  掌握 Queue、BlockingQueue 接口中常用的方法
    
2.  介绍 6 中阻塞队列，及相关场景示例
    
3.  重点掌握 4 种常用的阻塞队列
    

Queue 接口
--------

队列是一种先进先出（FIFO）的数据结构，java 中用`Queue`接口来表示队列。

`Queue`接口中定义了 6 个方法：

```
public interface Queue<E> extends Collection<E> {
    boolean add(e);
    boolean offer(E e);
    E remove();
    E poll();
    E element();
    E peek();
}


```

每个`Queue`方法都有两种形式：

（1）如果操作失败则抛出异常，

（2）如果操作失败，则返回特殊值（`null`或`false`，具体取决于操作），接口的常规结构如下表所示。

<table data-darkmode-bgcolor-16079192512725="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192512725="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)"><thead data-darkmode-bgcolor-16079192512725="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192512725="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)"><tr data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th width="84.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192512725="rgb(240, 240, 240)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; background-color: rgb(240, 240, 240); text-align: left;">操作类型</th><th width="178.66666666666666" data-darkmode-bgcolor-16079192512725="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192512725="rgb(240, 240, 240)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; background-color: rgb(240, 240, 240); text-align: left;">抛出异常</th><th width="238.66666666666669" data-darkmode-bgcolor-16079192512725="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192512725="rgb(240, 240, 240)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; background-color: rgb(240, 240, 240); text-align: left;">返回特殊值</th></tr></thead><tbody data-darkmode-bgcolor-16079192512725="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192512725="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)"><tr data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="57" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">插入</td><td width="171.66666666666663" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">add(e)</code></td><td width="238.66666666666669" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">offer(e)</code></td></tr><tr data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td width="57" data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">移除</td><td width="172.66666666666663" data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)">remove()</code></td><td width="238.66666666666669" data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)">poll()</code></td></tr><tr data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="57" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">检查</td><td width="174.66666666666663" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">element()</code></td><td width="238.66666666666669" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">peek()</code></td></tr></tbody></table>

`Queue`从`Collection`继承的`add`方法插入一个元素，除非它违反了队列的容量限制，在这种情况下它会抛出`IllegalStateException`；`offer`方法与`add`不同之处仅在于它通过返回`false`来表示插入元素失败。

`remove`和`poll`方法都移除并返回队列的头部，确切地移除哪个元素是由具体的实现来决定的，仅当队列为空时，`remove`和`poll`方法的行为才有所不同，在这些情况下，`remove`抛出`NoSuchElementException`，而`poll`返回`null`。

`element`和`peek`方法返回队列头部的元素，但不移除，它们之间的差异与`remove`和`poll`的方式完全相同，如果队列为空，则`element`抛出`NoSuchElementException`，而`peek`返回`null`。

队列一般不要插入空元素。

BlockingQueue 接口
----------------

`BlockingQueue`位于 juc 中，熟称阻塞队列， 阻塞队列首先它是一个队列，继承`Queue`接口，是队列就会遵循先进先出（FIFO）的原则，又因为它是阻塞的，故与普通的队列有两点区别：

1.  当一个线程向队列里面添加数据时，如果队列是满的，那么将阻塞该线程，暂停添加数据
    
2.  当一个线程从队列里面取出数据时，如果队列是空的，那么将阻塞该线程，暂停取出数据
    

`BlockingQueue`相关方法：

<table data-darkmode-bgcolor-16079192512725="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192512725="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)"><thead data-darkmode-bgcolor-16079192512725="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192512725="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)"><tr data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th width="43.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192512725="rgb(240, 240, 240)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; background-color: rgb(240, 240, 240); text-align: left; word-break: break-all;">操作类型</th><th width="98.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192512725="rgb(240, 240, 240)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; background-color: rgb(240, 240, 240); text-align: left;">抛出异常</th><th width="96.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192512725="rgb(240, 240, 240)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; background-color: rgb(240, 240, 240); text-align: left;">返回特殊值</th><th width="76.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192512725="rgb(240, 240, 240)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; text-align: left; background-color: rgb(240, 240, 240);">一直阻塞</th><th width="157.66666666666666" data-darkmode-bgcolor-16079192512725="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079192512725="rgb(240, 240, 240)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-top-width: 1px; border-color: rgb(204, 204, 204); padding: 0.5em 1em; text-align: left; background-color: rgb(240, 240, 240);">超时退出</th></tr></thead><tbody data-darkmode-bgcolor-16079192512725="rgba(112, 0, 0, 0.018750000000000003)" data-darkmode-original-bgcolor-16079192512725="rgba(20, 0, 0, 0.018750000000000003)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)"><tr data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="47.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">插入</td><td width="101.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">add(e)</code></td><td width="95.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">offer(e)</code></td><td width="76.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">put(e)</td><td width="157.66666666666666" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">offer(e,timeuout,unit)</td></tr><tr data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td width="49.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">移除</td><td width="101.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)">remove()</code></td><td width="96.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)">poll()</code></td><td width="76.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">take()</td><td width="157.66666666666666" data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">poll(timeout,unit)</td></tr><tr data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="font-size: inherit; color: inherit; line-height: inherit; border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="50.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">检查</td><td width="101.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">element()</code></td><td width="97.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;"><code data-darkmode-bgcolor-16079192512725="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079192512725="rgb(248, 248, 248)" data-darkmode-color-16079192512725="rgb(248, 35, 117)" data-darkmode-original-color-16079192512725="rgb(248, 35, 117)" data-style="font-size: inherit; line-height: inherit; overflow-wrap: break-word; padding: 2px 4px; border-radius: 4px; margin-right: 2px; margin-left: 2px; color: rgb(248, 35, 117); background: rgb(248, 248, 248);">peek()</code></td><td width="76.66666666666667" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">不支持</td><td width="157.66666666666666" data-darkmode-bgcolor-16079192512725="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079192512725="rgb(255,255,255)" data-darkmode-color-16079192512725="rgb(163, 163, 163)" data-darkmode-original-color-16079192512725="rgb(62, 62, 62)" data-style="color: inherit; line-height: inherit; font-size: 1em; border-color: rgb(204, 204, 204); padding: 0.5em 1em;">不支持</td></tr></tbody></table>

**重点，再来解释一下，加深印象：**

1.  3 个可能会有异常的方法，add、remove、element；这 3 个方法不会阻塞（是说队列满或者空的情况下是否会阻塞）；队列满的情况下，add 抛出异常；队列为空情况下，remove、element 抛出异常
    
2.  offer、poll、peek 也不会阻塞（是说队列满或者空的情况下是否会阻塞）；队列满的情况下，offer 返回 false；队列为空的情况下，pool、peek 返回 null
    
3.  队列满的情况下，调用 put 方法会导致当前线程阻塞
    
4.  队列为空的情况下，调用 take 方法会导致当前线程阻塞
    
5.  `offer(e,timeuout,unit)`，超时之前，插入成功返回 true，否者返回 false
    
6.  `poll(timeout,unit)`，超时之前，获取到头部元素并将其移除，返回 true，否者返回 false
    
7.  **以上一些方法希望大家都记住，方便以后使用**
    

BlockingQueue 常见的实现类
--------------------

看一下相关类图

**ArrayBlockingQueue**

> 基于数组的阻塞队列实现，其内部维护一个定长的数组，用于存储队列元素。线程阻塞的实现是通过 ReentrantLock 来完成的，数据的插入与取出共用同一个锁，因此 ArrayBlockingQueue 并不能实现生产、消费同时进行。而且在创建 ArrayBlockingQueue 时，我们还可以控制对象的内部锁是否采用公平锁，默认采用非公平锁。

**LinkedBlockingQueue**

> 基于单向链表的阻塞队列实现，在初始化 LinkedBlockingQueue 的时候可以指定大小，也可以不指定，默认类似一个无限大小的容量（Integer.MAX_VALUE），不指队列容量大小也是会有风险的，一旦数据生产速度大于消费速度，系统内存将有可能被消耗殆尽，因此要谨慎操作。另外 LinkedBlockingQueue 中用于阻塞生产者、消费者的锁是两个（锁分离），因此生产与消费是可以同时进行的。

**PriorityBlockingQueue**

> 一个支持优先级排序的无界阻塞队列，进入队列的元素会按照优先级进行排序

**SynchronousQueue**

> 同步阻塞队列，SynchronousQueue 没有容量，与其他 BlockingQueue 不同，SynchronousQueue 是一个不存储元素的 BlockingQueue，每一个 put 操作必须要等待一个 take 操作，否则不能继续添加元素，反之亦然

**DelayQueue**

> DelayQueue 是一个支持延时获取元素的无界阻塞队列，里面的元素全部都是 “可延期” 的元素，列头的元素是最先 “到期” 的元素，如果队列里面没有元素到期，是不能从列头获取元素的，哪怕有元素也不行，也就是说只有在延迟期到时才能够从队列中取元素

**LinkedTransferQueue**

> LinkedTransferQueue 是基于链表的 FIFO 无界阻塞队列，它出现在 JDK7 中，Doug Lea 大神说 LinkedTransferQueue 是一个聪明的队列，它是 ConcurrentLinkedQueue、SynchronousQueue(公平模式下)、无界的 LinkedBlockingQueues 等的超集，`LinkedTransferQueue`包含了`ConcurrentLinkedQueue、SynchronousQueue、LinkedBlockingQueues`三种队列的功能

下面我们来介绍每种阻塞队列的使用。

ArrayBlockingQueue
------------------

有界阻塞队列，内部使用数组存储元素，有 2 个常用构造方法：

```
//capacity表示容量大小，默认内部采用非公平锁
public ArrayBlockingQueue(int capacity)
//capacity：容量大小，fair：内部是否是使用公平锁
public ArrayBlockingQueue(int capacity, boolean fair)


```

**需求：**业务系统中有很多地方需要推送通知，由于需要推送的数据太多，我们将需要推送的信息先丢到阻塞队列中，然后开一个线程进行处理真实发送，代码如下：

```
package com.itsoku.chat25;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import sun.text.normalizer.NormalizerBase;

import java.util.Calendar;
import java.util.concurrent.*;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo1 {
    //推送队列
    static ArrayBlockingQueue<String> pushQueue = new ArrayBlockingQueue<String>(10000);

    static {
        //启动一个线程做真实推送
        new Thread(() -> {
            while (true) {
                String msg;
                try {
                    long starTime = System.currentTimeMillis();
                    //获取一条推送消息，此方法会进行阻塞，直到返回结果
                    msg = pushQueue.take();
                    long endTime = System.currentTimeMillis();
                    //模拟推送耗时
                    TimeUnit.MILLISECONDS.sleep(500);

                    System.out.println(String.format("[%s,%s,take耗时:%s],%s,发送消息:%s", starTime, endTime, (endTime - starTime), Thread.currentThread().getName(), msg));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    //推送消息，需要发送推送消息的调用该方法，会将推送信息先加入推送队列
    public static void pushMsg(String msg) throws InterruptedException {
        pushQueue.put(msg);
    }

    public static void main(String[] args) throws InterruptedException {
        for (int i = 1; i <= 5; i++) {
            String msg = "一起来学java高并发,第" + i + "天";
            //模拟耗时
            TimeUnit.SECONDS.sleep(i);
            Demo1.pushMsg(msg);
        }
    }
}


```

输出：

```
[1565595629206,1565595630207,take耗时:1001],Thread-0,发送消息:一起来学java高并发,第1天
[1565595630208,1565595632208,take耗时:2000],Thread-0,发送消息:一起来学java高并发,第2天
[1565595632208,1565595635208,take耗时:3000],Thread-0,发送消息:一起来学java高并发,第3天
[1565595635208,1565595639209,take耗时:4001],Thread-0,发送消息:一起来学java高并发,第4天
[1565595639209,1565595644209,take耗时:5000],Thread-0,发送消息:一起来学java高并发,第5天


```

代码中我们使用了有界队列`ArrayBlockingQueue`，创建`ArrayBlockingQueue`时候需要制定容量大小，调用`pushQueue.put`将推送信息放入队列中，如果队列已满，此方法会阻塞。代码中在静态块中启动了一个线程，调用`pushQueue.take();`从队列中获取待推送的信息进行推送处理。

**注意：**`ArrayBlockingQueue`如果队列容量设置的太小，消费者发送的太快，消费者消费的太慢的情况下，会导致队列空间满，调用 put 方法会导致发送者线程阻塞，所以注意设置合理的大小，协调好消费者的速度。

LinkedBlockingQueue
-------------------

内部使用单向链表实现的阻塞队列，3 个构造方法：

```
//默认构造方法，容量大小为Integer.MAX_VALUE
public LinkedBlockingQueue();
//创建指定容量大小的LinkedBlockingQueue
public LinkedBlockingQueue(int capacity);
//容量为Integer.MAX_VALUE,并将传入的集合丢入队列中
public LinkedBlockingQueue(Collection<? extends E> c);


```

`LinkedBlockingQueue`的用法和`ArrayBlockingQueue`类似，建议使用的时候指定容量，如果不指定容量，插入的太快，移除的太慢，可能会产生 OOM。

PriorityBlockingQueue
---------------------

**无界的优先级**阻塞队列，内部使用数组存储数据，达到容量时，会自动进行扩容，放入的元素会按照优先级进行排序，4 个构造方法：

```
//默认构造方法，默认初始化容量是11
public PriorityBlockingQueue();
//指定队列的初始化容量
public PriorityBlockingQueue(int initialCapacity);
//指定队列的初始化容量和放入元素的比较器
public PriorityBlockingQueue(int initialCapacity,Comparator<? super E> comparator);
//传入集合放入来初始化队列，传入的集合可以实现SortedSet接口或者PriorityQueue接口进行排序，如果没有实现这2个接口，按正常顺序放入队列
public PriorityBlockingQueue(Collection<? extends E> c);


```

优先级队列放入元素的时候，会进行排序，所以我们需要指定排序规则，有 2 种方式：

1.  创建`PriorityBlockingQueue`指定比较器`Comparator`
    
2.  放入的元素需要实现`Comparable`接口
    

上面 2 种方式必须选一个，如果 2 个都有，则走第一个规则排序。

**需求：**还是上面的推送业务，目前推送是按照放入的先后顺序进行发送的，比如有些公告比较紧急，优先级比较高，需要快点发送，怎么搞？此时`PriorityBlockingQueue`就派上用场了，代码如下：

```
package com.itsoku.chat25;

import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.TimeUnit;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo2 {

    //推送信息封装
    static class Msg implements Comparable<Msg> {
        //优先级，越小优先级越高
        private int priority;
        //推送的信息
        private String msg;

        public Msg(int priority, String msg) {
            this.priority = priority;
            this.msg = msg;
        }

        @Override
        public int compareTo(Msg o) {
            return Integer.compare(this.priority, o.priority);
        }

        @Override
        public String toString() {
            return "Msg{" +
                    "priority=" + priority +
                    ", msg='" + msg + '\'' +
                    '}';
        }
    }

    //推送队列
    static PriorityBlockingQueue<Msg> pushQueue = new PriorityBlockingQueue<Msg>();

    static {
        //启动一个线程做真实推送
        new Thread(() -> {
            while (true) {
                Msg msg;
                try {
                    long starTime = System.currentTimeMillis();
                    //获取一条推送消息，此方法会进行阻塞，直到返回结果
                    msg = pushQueue.take();
                    //模拟推送耗时
                    TimeUnit.MILLISECONDS.sleep(100);
                    long endTime = System.currentTimeMillis();
                    System.out.println(String.format("[%s,%s,take耗时:%s],%s,发送消息:%s", starTime, endTime, (endTime - starTime), Thread.currentThread().getName(), msg));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    //推送消息，需要发送推送消息的调用该方法，会将推送信息先加入推送队列
    public static void pushMsg(int priority, String msg) throws InterruptedException {
        pushQueue.put(new Msg(priority, msg));
    }

    public static void main(String[] args) throws InterruptedException {
        for (int i = 5; i >= 1; i--) {
            String msg = "一起来学java高并发,第" + i + "天";
            Demo2.pushMsg(i, msg);
        }
    }
}


```

输出：

```
[1565598857028,1565598857129,take耗时:101],Thread-0,发送消息:Msg{priority=1, msg='一起来学java高并发,第1天'}
[1565598857162,1565598857263,take耗时:101],Thread-0,发送消息:Msg{priority=2, msg='一起来学java高并发,第2天'}
[1565598857263,1565598857363,take耗时:100],Thread-0,发送消息:Msg{priority=3, msg='一起来学java高并发,第3天'}
[1565598857363,1565598857463,take耗时:100],Thread-0,发送消息:Msg{priority=4, msg='一起来学java高并发,第4天'}
[1565598857463,1565598857563,take耗时:100],Thread-0,发送消息:Msg{priority=5, msg='一起来学java高并发,第5天'}


```

main 中放入了 5 条推送信息，i 作为消息的优先级按倒叙放入的，最终输出结果中按照优先级由小到大输出。注意 Msg 实现了`Comparable`接口，具有了比较功能。

SynchronousQueue
----------------

> 同步阻塞队列，SynchronousQueue 没有容量，与其他 BlockingQueue 不同，SynchronousQueue 是一个不存储元素的 BlockingQueue，每一个 put 操作必须要等待一个 take 操作，否则不能继续添加元素，反之亦然。SynchronousQueue 在现实中用的不多，线程池中有用到过，`Executors.newCachedThreadPool()`实现中用到了这个队列，当有任务丢入线程池的时候，如果已创建的工作线程都在忙于处理任务，则会新建一个线程来处理丢入队列的任务。

来个示例代码：

```
package com.itsoku.chat25;

import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.SynchronousQueue;
import java.util.concurrent.TimeUnit;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo3 {

    static SynchronousQueue<String> queue = new SynchronousQueue<>();

    public static void main(String[] args) throws InterruptedException {
        new Thread(() -> {
            try {
                long starTime = System.currentTimeMillis();
                queue.put("java高并发系列，路人甲Java!");
                long endTime = System.currentTimeMillis();
                System.out.println(String.format("[%s,%s,take耗时:%s],%s", starTime, endTime, (endTime - starTime), Thread.currentThread().getName()));
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }).start();
        //休眠5秒之后，从队列中take一个元素
        TimeUnit.SECONDS.sleep(5);
        System.out.println(System.currentTimeMillis() + "调用take获取并移除元素," + queue.take());
    }
}


```

输出：

```
1565600421645调用take获取并移除元素,java高并发系列，路人甲Java!
[1565600416645,1565600421645,take耗时:5000],Thread-0


```

main 方法中启动了一个线程，调用`queue.put`方法向队列中丢入一条数据，调用的时候产生了阻塞，从输出结果中可以看出，直到 take 方法被调用时，put 方法才从阻塞状态恢复正常。

DelayQueue
----------

> DelayQueue 是一个支持延时获取元素的无界阻塞队列，里面的元素全部都是 “可延期” 的元素，列头的元素是最先 “到期” 的元素，如果队列里面没有元素到期，是不能从列头获取元素的，哪怕有元素也不行，也就是说只有在延迟期到时才能够从队列中取元素。

**需求：**还是推送的业务，有时候我们希望早上 9 点或者其他指定的时间进行推送，如何实现呢？此时`DelayQueue`就派上用场了。

我们先看一下`DelayQueue`类的声明：

```
public class DelayQueue<E extends Delayed> extends AbstractQueue<E>
    implements BlockingQueue<E>


```

元素 E 需要实现接口`Delayed`，我们看一下这个接口的代码：

```
public interface Delayed extends Comparable<Delayed> {
    long getDelay(TimeUnit unit);
}


```

`Delayed`继承了`Comparable`接口，这个接口是用来做比较用的，`DelayQueue`内部使用`PriorityQueue`来存储数据的，`PriorityQueue`是一个优先级队列，丢入的数据会进行排序，排序方法调用的是`Comparable`接口中的方法。下面主要说一下`Delayed`接口中的`getDelay`方法：此方法在给定的时间单位内返回与此对象关联的剩余延迟时间。

**对推送我们再做一下处理，让其支持定时发送（定时在将来某个时间也可以说是延迟发送），代码如下：**

```
package com.itsoku.chat25;

import java.util.Calendar;
import java.util.concurrent.DelayQueue;
import java.util.concurrent.Delayed;
import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.TimeUnit;

/**
 * 跟着阿里p7学并发，微信公众号：javacode2018
 */
public class Demo4 {

    //推送信息封装
    static class Msg implements Delayed {
        //优先级，越小优先级越高
        private int priority;
        //推送的信息
        private String msg;
        //定时发送时间，毫秒格式
        private long sendTimeMs;

        public Msg(int priority, String msg, long sendTimeMs) {
            this.priority = priority;
            this.msg = msg;
            this.sendTimeMs = sendTimeMs;
        }

        @Override
        public String toString() {
            return "Msg{" +
                    "priority=" + priority +
                    ", msg='" + msg + '\'' +
                    ", sendTimeMs=" + sendTimeMs +
                    '}';
        }

        @Override
        public long getDelay(TimeUnit unit) {
            return unit.convert(this.sendTimeMs - Calendar.getInstance().getTimeInMillis(), TimeUnit.MILLISECONDS);
        }

        @Override
        public int compareTo(Delayed o) {
            if (o instanceof Msg) {
                Msg c2 = (Msg) o;
                return Integer.compare(this.priority, c2.priority);
            }
            return 0;
        }
    }

    //推送队列
    static DelayQueue<Msg> pushQueue = new DelayQueue<Msg>();

    static {
        //启动一个线程做真实推送
        new Thread(() -> {
            while (true) {
                Msg msg;
                try {
                    //获取一条推送消息，此方法会进行阻塞，直到返回结果
                    msg = pushQueue.take();
                    //此处可以做真实推送
                    long endTime = System.currentTimeMillis();
                    System.out.println(String.format("定时发送时间：%s,实际发送时间：%s,发送消息:%s", msg.sendTimeMs, endTime, msg));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    //推送消息，需要发送推送消息的调用该方法，会将推送信息先加入推送队列
    public static void pushMsg(int priority, String msg, long sendTimeMs) throws InterruptedException {
        pushQueue.put(new Msg(priority, msg, sendTimeMs));
    }

    public static void main(String[] args) throws InterruptedException {
        for (int i = 5; i >= 1; i--) {
            String msg = "一起来学java高并发,第" + i + "天";
            Demo4.pushMsg(i, msg, Calendar.getInstance().getTimeInMillis() + i * 2000);
        }
    }
}


```

输出：

```
定时发送时间：1565603357198,实际发送时间：1565603357198,发送消息:Msg{priority=1, msg='一起来学java高并发,第1天', sendTimeMs=1565603357198}
定时发送时间：1565603359198,实际发送时间：1565603359198,发送消息:Msg{priority=2, msg='一起来学java高并发,第2天', sendTimeMs=1565603359198}
定时发送时间：1565603361198,实际发送时间：1565603361199,发送消息:Msg{priority=3, msg='一起来学java高并发,第3天', sendTimeMs=1565603361198}
定时发送时间：1565603363198,实际发送时间：1565603363199,发送消息:Msg{priority=4, msg='一起来学java高并发,第4天', sendTimeMs=1565603363198}
定时发送时间：1565603365182,实际发送时间：1565603365183,发送消息:Msg{priority=5, msg='一起来学java高并发,第5天', sendTimeMs=1565603365182}


```

可以看出时间发送时间，和定时发送时间基本一致，代码中`Msg`需要实现`Delayed接口`，重点在于`getDelay`方法，这个方法返回剩余的延迟时间，代码中使用`this.sendTimeMs`减去当前时间的毫秒格式时间，得到剩余延迟时间。

LinkedTransferQueue
-------------------

> LinkedTransferQueue 是一个由链表结构组成的无界阻塞 TransferQueue 队列。相对于其他阻塞队列，LinkedTransferQueue 多了 tryTransfer 和 transfer 方法。

LinkedTransferQueue 类继承自 AbstractQueue 抽象类，并且实现了 TransferQueue 接口：

```
public interface TransferQueue<E> extends BlockingQueue<E> {
    // 如果存在一个消费者已经等待接收它，则立即传送指定的元素，否则返回false，并且不进入队列。
    boolean tryTransfer(E e);
    // 如果存在一个消费者已经等待接收它，则立即传送指定的元素，否则等待直到元素被消费者接收。
    void transfer(E e) throws InterruptedException;
    // 在上述方法的基础上设置超时时间
    boolean tryTransfer(E e, long timeout, TimeUnit unit)
        throws InterruptedException;
    // 如果至少有一位消费者在等待，则返回true
    boolean hasWaitingConsumer();
    // 获取所有等待获取元素的消费线程数量
    int getWaitingConsumerCount();
}


```

再看一下上面的这些方法，`transfer(E e)`方法和`SynchronousQueue的put方法`类似，都需要等待消费者取走元素，否者一直等待。其他方法和`ArrayBlockingQueue、LinkedBlockingQueue`中的方法类似。

总结
--

1.  重点需要了解`BlockingQueue`中的所有方法，以及他们的区别
    
2.  重点掌握`ArrayBlockingQueue`、`LinkedBlockingQueue`、`PriorityBlockingQueue`、`DelayQueue`的使用场景
    
3.  需要处理的任务有优先级的，使用`PriorityBlockingQueue`
    
4.  处理的任务需要延时处理的，使用`DelayQueue`
    

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
    
24.  **[第 24 天：ThreadLocal、InheritableThreadLocal（通俗易懂）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933186&idx=1&sn=079567e8799e43cb734b833c44055c01&chksm=88621b7cbf15926aace88777445822314d6eed2c1f5559b36cb6a6e181f0e543ee14d832ebc2&token=408917828&lang=zh_CN&scene=21#wechat_redirect)**
    

**java 高并发系列连载中，总计估计会有四五十篇文章。**

**阿里 p7 一起学并发，公众号：路人甲 java，每天获取最新文章！**

![](https://mmbiz.qpic.cn/mmbiz_jpg/xicEJhWlK06AcmgEdFkkWEgWeMkg0tpVAH0UK9CMukCQEk0KdnicBdPCgg2sEXr6nG0NKGDGZcrcj7ZaHF8Dnudw/640?wx_fmt=jpeg)