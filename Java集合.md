一、学习指南

## 一、Java集合学习指南

> 本文会提出很多可能新手会想到的问题，但不会一一解答，只会往大方向去说明白。本文的内容偏向于**指南**，而非技术教程讲解。
>
> 如果想要得到具体的答案，可以翻阅我曾经写过的资料：https://github.com/ZhongFuCheng3y/3y，或者加入**人才交流群**跟众多开发者讨论，前面的**Github**链接有我的联系方式。

### 1.1学习一项技术之前，必须知道为什么要学它！

**Q:** 我们得知道为什么要学习Java集合，学到Java集合的时候已经学过了数组了，为什么我不用数组反而用Java集合。数组和Java集合有什么区别？

![学习Java集合先需要知道](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151024.png)

 

**A:**Java是一门面向对象的语言，就免不了处理对象，为了方便操作多个对象，那么我们就得把这多个对象存储起来，想要存储多个对象(变量),很容易就能想到一个**容器**(集合)来装载

 

总的来说：就是Java给我们**提供了工具方便我们去操作多个Java对象**。

![方便操作多个对象](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151028.png)

### 1.2如何入门学习Java集合

**Q:** 从上面我们已经知道了为什么要学Java集合，下面我们就该知道Java集合的基本用法，以及从它整体的知识点去了解它是什么

![入门Java集合](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151034.png)

**A：** 我们学习Java集合实际上就是为了方便操作多个对象，而Java给我们提供一系列的API(方法)供我们去操作。所以在初学Java集合的时候我们更多的是学习这些API(方法)分别是什么意思。

![API的用法以及效果](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151036.png)

**Q：** 对Java集合的API使用有一定的了解之后，我们就应该从**面向对象**的角度去理解它。为什么会抽象出多个接口，以及每个接口的有什么特性。

![从面向对象的角度去理解接口以及每个接口下的常用类](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151038.png)

**A:** 我们可以总结出几个**常用的实现类**，这几个常用的实现类我们必须要知道它的**数据结构**是什么，什么时候使用这个类。

![需要知道每个常用子类的数据结构](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151040.png)

 

需要学习和了解的数据结构：

![数据结构](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151043.png)

 

到这里，我们简单了解各个实现类的数据结构以后，我们可能会简单记住下面的**结论**：

- 如果是集合类型，有List和Set供我们选择。List的特点是插入有序的，元素是可重复的。Set的特点是插入无序的，元素不可重复的。至于选择哪个实现类来作为我们的存储容器，我们就得看具体的应用场景。是希望可重复的就得用List，选择List下常见的子类。是希望不可重复，选择Set下常见的子类。
- 如果是`Key-Value`型，那我们会选择Map。如果要保持插入顺序的，我们可以选择LinkedHashMap，如果不需要则选择HashMap，如果要排序则选择TreeMap。
- 总之：学完**常见**实现类的数据结构之后，你对它的使用场景就有一个清楚的认知了。

![选择什么样的容器来存储我们的对象，关键在于了解每个常用集合类的数据结构](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151046.png)

### 1.3 集合进阶与面试

如果我们在写代码的时候**懂得**选择什么样的集合作为我们的容器，那已经是入门了。但要知道的是，如果去面试之前，你懂的不应该只有这么少。

（如果还在**初学或者零基础**的同学我建议可以跳过这一部分，在网上有可能很多言论，比如：**“如果你Java基础扎实的话，那你以后找工作就不愁了。在学Java基础的时候一定要把基础学好，看源码！”**。但我认为，这一块是建立在有一定的编码/项目或者是去找工作的时候才成立的，**一个刚入门学Java的，就不应该看源码，这很容易把自己劝退了**）

 

我的观点是：如果刚入门学Java，首先你要十分清楚知道为什么要学这个，这个到底有什么用，用在哪些地方，以及熟悉常用的方法，就足够了。即便你花了两周左右时间去看源码实现了，可能看懂了。但是，你相信我，你**大概率会忘掉**。

 

Java集合是面试的**重点**，我在面试的时候几乎每家公司都会问集合的问题，从基础到源码，一步一步深入。Java集合面试的知识点就不限于基本的用法了。可能面试官会问你：

- HashMap的数据结构是什么？他是怎么扩容的？底层有没有用红黑树？取Key Hash值是JDK源码是怎么实现的？为什么要这样做？
- HashMap是线程安全的吗？什么是线程安全？有什么更好的解决方案？那线程安全的HashMap是怎么实现的？
- HashSet是如何判断Key是重复的？
- .....很多很多

![总结](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151048.png)

总的来说，入门Java集合并不难，归根到底我认为就是三件事：

- 了解为什么要学习Java集合
- 学习Java集合的各个接口以及常用的实现类用法
- 学习常用实现类的数据结构是什么，能在写代码的时候选择一个合适的实现类装载自己的对象。

 

零基础入门不需要阅读源码，面试前一定要回顾和阅读源码（这是面试必考的知识点）！

![总结本文](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151051.png)

# 二、Collection

## 一、集合(Collection)介绍

### 1.1为什么需要Collection

1. Java是一门面向对象的语言，就免不了处理对象
2. 为了方便操作多个对象，那么我们就得把这多个对象存储起来
3. 想要存储多个对象(变量),很容易就能想到一个**容器**
4. 常用的容器我们知道有-->StringBuffered,数组(虽然有对象数组，但是数组的长度是不可变的！)
5. 所以，Java就为我们提供了集合(Collection)～

### 1.2数组和集合的区别

接下来，我们可以对数组和集合的区别来分析一下：

数组和集合的区别:

- 1:长度的区别
  - **数组的长度固定**
  - **集合的长度可变**
- 2:元素的数据类型
  - 数组可以存储基本数据类型,也可以存储引用类型
  - **集合只能存储引用类型(你存储的是简单的int，它会自动装箱成Integer)**

### 1.3Collection的由来与功能

**Collection的由来：**

- 集合可以存储多个元素,但我们**对多个元素也有不同的需求**
  - 多个元素,不能有相同的
  - 多个元素,能够按照某个规则排序
- 针对不同的需求：java就提供了很多集合类，多个集合类的数据结构不同。但是，结构不重要，重要的是**能够存储东西,能够判断,获取**
- 把集合**共性的内容不断往上提取**,最终形成集合的继承体系---->Collection

Collection的大致结构体系是这样的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151102.jpeg)

但是，一般我们要掌握的并不需要那么多，只需要掌握一些常用的集合类就行了。下面我**圈出来的那些**：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151104.png)

**再次精减：**

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151107.bmp)

Collection的基础功能：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151110.png)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151112.png)

 

## 二、迭代器(Iterator)介绍

我们可以发现Collection的源码中继承了Iterable，有iterator()这个方法...

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151114.png)

点进去看了一下，Iterable是一个接口：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151119.png)

它有iterator()这个方法，返回的是**Iterator**

再来看一下，Iterator也是一个接口，它只有三个方法：

- hasNext()
- next()
- remove()

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151122.png)

可是，我们没能找到对应的实现方法，只能往Collection的子类下找找了，于是我们找到了--->ArrayList(该类后面会说)

于是，我们在ArrayList下找到了iterator实现的身影：它是在ArrayList以**内部类的方式实现**的！并且，从源码可知：**Iterator实际上就是在遍历集合**

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151124.png)

所以说：我们**遍历集合(Collection)的元素都可以使用Iterator**，至于它的具体实现是以内部类的方式实现的！

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151128.bmp)

## 三、List集合介绍

从上面已经可以看到了，Collection主要学习集合的类型两种：**Set和List**，这里主要讲解List！

我们来看一下List接口的方法，比Collection多了一点点：

- List集合的**特点**就是：**有序(存储顺序和取出顺序一致),可重复**

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151138.png)

Collection返回的是Iterator迭代器接口，而List中又有它自己对应的实现-->**ListIterator接口**

该接口比普通的Iterator接口多了几个方法： ![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151140.png)

从方法名就可以知道：**ListIterator可以往前遍历，添加元素，设置元素**

 

 

### 3.1List集合常用子类

List集合常用的子类有三个：

- ArrayList
  - 底层数据结构是数组。线程不安全
- LinkedList
  - 底层数据结构是链表。线程不安全
- Vector
  - 底层数据结构是数组。线程安全

**现在知道有三个常用的集合类即可，后面会开新的文章来讲解的**～

## 四、Set集合介绍

从Set集合的方法我们可以看到：方法没有比Collection要多

- Set集合的特点是：**元素不可重复**

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151143.png)

### 4.1Set集合常用子类

- HashSet集合
  - A:底层数据结构是哈希表(是一个元素为链表的数组) 
- TreeSet集合
  - A:底层数据结构是红黑树(是一个自平衡的二叉树)
  - B:保证元素的排序方式
- LinkedHashSet集合     
  - A:：底层数据结构由哈希表和链表组成。

# 三、List集合

现在这篇主要讲List集合的三个子类：

- ArrayList
  - 底层数据结构是数组。线程不安全
- LinkedList
  - 底层数据结构是链表。线程不安全
- Vector
  - 底层数据结构是数组。线程安全

这篇主要来看看它们比较重要的方法是如何实现的，需要注意些什么，最后比较一下哪个时候用哪个～

 

 

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151152.bmp)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151155.bmp)

## 一、ArrayList解析

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151158.png)

首先，我们来讲解的是ArrayList集合，它是我们用得非常非常多的一个集合~

首先，我们来看一下ArrayList的属性：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151200.png)

根据上面我们可以清晰的发现：**ArrayList底层其实就是一个数组**，ArrayList中有**扩容**这么一个概念，正因为它扩容，所以它能够**实现“动态”增长**

### 1.1构造方法

我们来看看构造方法来印证我们上面说得对不对：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151202.png)

### 1.2Add方法

add方法可以说是ArrayList比较重要的方法了，我们来总览一下：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151212.png)

#### 1.2.1add(E e)

步骤：

- **检查是否需要扩容**
- **插入元素**

首先，我们来看看这个方法：

```
    public boolean add(E e) {
        ensureCapacityInternal(size + 1);  // Increments modCount!!
        elementData[size++] = e;
        return true;
    }
```

该方法很短，我们可以根据方法名就猜到他是干了什么：

- **确认list容量，尝试容量加1，看看有无必要**
- **添加元素**

接下来我们来看看这个小容量(+1)是否满足我们的需求：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151215.png)

随后调用`ensureExplicitCapacity()`来确定明确的容量，我们也来看看这个方法是怎么实现的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151217.png)

所以，接下来看看`grow()`是怎么实现的~

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151220.png)

进去看`copyOf()`方法：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151224.png)

到目前为止，我们就可以知道`add(E e)`的基本实现了：

- 首先去检查一下数组的容量是否足够
  - 足够：直接添加
  - 不足够：扩容
    - **扩容到原来的1.5倍**
    - 第一次扩容后，如果容量还是小于minCapacity，就将容量扩充为minCapacity。

#### 1.2.2add(int index, E element)

步骤：

- **检查角标**
- **空间检查，如果有需要进行扩容**
- **插入元素**

我们来看看插入的实现： ![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151226.png)

我们发现，与扩容相关ArrayList的add方法底层其实都是`arraycopy()`来实现的

看到`arraycopy()`，我们可以发现：**该方法是由C/C++来编写的**，并不是由Java实现：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151228.png)

总的来说：`arraycopy()`还是比较可靠高效的一个方法。

 

### 1.3 get方法

- **检查角标**
- **返回元素**

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151229.png)

```
// 检查角标
private void rangeCheck(int index) {
  if (index >= size)
    throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
}

// 返回元素
E elementData(int index) {
  return (E) elementData[index];
}
```

### 1.4 set方法

步骤：

- **检查角标**
- **替代元素**
- **返回旧值**

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151232.png)

### 1.5remove方法

步骤：

- **检查角标**
- **删除元素**
- **计算出需要移动的个数，并移动**
- 设置为null，让Gc回收

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151234.png)

 

### 1.6细节再说明

- ArrayList是**基于动态数组实现的**，在**增删时候，需要数组的拷贝复制**。
- **ArrayList的默认初始化容量是10，每次扩容时候增加原先容量的一半，也就是变为原来的1.5倍**
- 删除元素时不会减少容量，**若希望减少容量则调用trimToSize()**
- 它不是线程安全的。它能存放null值。

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151237.png)

## 二、Vector与ArrayList区别

Vector是jdk1.2的类了，比较老旧的一个集合类。

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151246.png)

Vector底层也是数组，与ArrayList最大的区别就是：**同步(线程安全)**

Vector是同步的，我们可以从方法上就可以看得出来~

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151249.png)

在要求非同步的情况下，我们一般都是使用ArrayList来替代Vector的了~

如果想要ArrayList实现同步，可以使用Collections的方法：`List list = Collections.synchronizedList(new ArrayList(...));`，就可以实现同步了~

还有另一个区别：

- **ArrayList在底层数组不够用时在原来的基础上扩展0.5倍，Vector是扩展1倍。**、

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151251.png)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151253.png)

 

## 三、LinkedList解析

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151255.png)

LinkedList底层是**双向链表**~如果对于链表不熟悉的同学可先看看我的**单向链表**(双向链表的练习我还没做)【[Java实现单向链表](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484086&idx=1&sn=24127ceb5e0fed7f832f82579c4fbc19&chksm=ebd743b7dca0caa1dce912d47251548225aa59b4b48742a963ac52b05e13ec923a738ebcb836#rd)】

理解了单向链表，双向链表也就不难了。

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151257.png)

从结构上，我们还看到了**LinkedList实现了Deque接口**，因此，我们可以**操作LinkedList像操作队列和栈一样**~

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151259.png)

LinkedList变量就这么几个，因为我们操作单向链表的时候也发现了：有了头结点，其他的数据我们都可以获取得到了。(双向链表也同理)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151302.png)

### 3.1构造方法

LinkedList的构造方法有两个：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151304.png)

### 3.2add方法

如果做过链表的练习，对于下面的代码并不陌生的~

- **add方法实际上就是往链表最后添加元素**

```
    public boolean add(E e) {
        linkLast(e);
        return true;
    }

    void linkLast(E e) {
        final Node<E> l = last;
        final Node<E> newNode = new Node<>(l, e, null);
        last = newNode;
        if (l == null)
            first = newNode;
        else
            l.next = newNode;
        size++;
        modCount++;
    }
```

### 3.3remove方法

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151306.png)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151308.png)

实际上就是下面那个图的操作：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151311.jpeg)

### 3.4get方法

可以看到get方法实现就两段代码：

```
    public E get(int index) {
        checkElementIndex(index);
        return node(index).item;
    }
```

我们进去看一下具体的实现是怎么样的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151312.png)

### 3.5set方法

 

set方法和get方法其实差不多，**根据下标来判断是从头遍历还是从尾遍历**

```
    public E set(int index, E element) {
        checkElementIndex(index);
        Node<E> x = node(index);
        E oldVal = x.item;
        x.item = element;
        return oldVal;
    }

```

 

## 四、List集合总结

其实集合的源码看起来并不是很困难，遇到问题可以翻一翻，应该是能够看懂的~

ArrayList、LinkedList、Vector算是在面试题中比较常见的的知识点了。下面我就来做一个简单的总结：

**ArrayList：**

- 底层实现是数组
- ArrayList的默认初始化容量是10，每次扩容时候增加原先容量的一半，也就是变为原来的1.5倍
- 在**增删时候，需要数组的拷贝复制(navite 方法由C/C++实现)**

**LinkedList：**

- 底层实现是**双向链表**[双向链表方便实现往前遍历]

**Vector：**

- 底层是数组，现在已少用，被ArrayList替代，原因有两个：
  - Vector所有方法都是同步，**有性能损失**。
  - Vector初始length是10 超过length时 以100%比率增长，**相比于ArrayList更多消耗内存**。

**总的来说：查询多用ArrayList，增删多用LinkedList。**

**ArrayList增删慢不是绝对**的(**在数量大的情况下，已测试**)：

- 如果增加元素一直是使用`add()`(增加到末尾)的话，那是ArrayList要快
- 一直**删除末尾的元素也是ArrayList要快**【不用复制移动位置】
- 至于如果**删除的是中间的位置的话，还是ArrayList要快**！

但一般来说：**增删多还是用LinkedList，因为上面的情况是极端的~**

# 四、Map集合

 

## 一、Map介绍

### 1.1为什么需要Map

前面我们学习的Collection叫做集合，它可以快速查找现有的元素。

而Map在《Core Java》中称之为-->映射..

映射的模型图是这样的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151323.png)

那为什么我们需要这种数据存储结构呢？？？举个例子

- 作为学生来说，我们是根据学号来区分不同的学生。**只要我们知道学号，就可以获取对应的学生信息**。这就是Map映射的作用！

生活中还有很多这样的例子：**只要你掏出身份证(key)，那就可以证明是你自己(value)**

### 1.2Map与Collection的区别

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151327.png)

### 1.3Map的功能

下面我们来看看Map的源码：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151329.png)

简单常用的Map功能有这么一些：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151331.png)

下面用红色框框圈住的就是**Map值得关注的子类：**

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151334.png)

## 二、散列表介绍

无论是Set还是Map，我们会发现都会有对应的-->**Hash**Set,**Hash**Map

首先我们也先得**回顾一下数据和链表**：

- 链表和数组都可以按照人们的意愿来排列元素的次序，他们可以说是**有序**的(存储的顺序和取出的顺序是一致的)
- 但同时，这会带来缺点：**想要获取某个元素，就要访问所有的元素，直到找到为止。**
- 这会让我们消耗很多的时间在里边，遍历访问元素~

 

而还有另外的一些存储结构：**不在意元素的顺序，能够快速的查找元素的数据**

- 其中就有一种非常常见的：**散列表**

### 2.1散列表工作原理

散列表**为每个对象计算出一个整数，称为散列码**。**根据**这些计算出来的**整数(散列码)保存在对应的位置上**！

在Java中，散列表用的是链表数组实现的，**每个列表称之为桶。**【之前也写过[桶排序就这么简单](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484071&idx=2&sn=5195363e7a5c5e3e7cac2a733c2695e9&chksm=ebd743a6dca0cab0b79aec38ff835116af9079114c9266ef673c6c1009b32b2abf262bf35e0c#rd)，可以回顾回顾】

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151336.jpeg)

一个桶上可能会**遇到被占用的情况(hashCode散列码相同，就存储在同一个位置上)**，这种情况是无法避免的，这种现象称之为：**散列冲突**

- 此时需要**用该对象与桶上的对象进行比较，看看该对象是否存在桶子上了**~如果存在，就不添加了，如果不存在则添加到桶子上
- 当然了，如果hashcode函数设计得足够好，桶的数目也足够，这种比较是很少的~
- 在**JDK1.8**中，**桶满时**会从**链表变成平衡二叉树**

如果散列表太满，**是需要对散列表再散列，创建一个桶数更多的散列表，并将原有的元素插入到新表中，丢弃原来的表**~

- 装填因子(load factor)**决定了何时**对散列表再散列~
- 装填因子默认为0.75，如果表中**超过了75%的位置**已经填入了元素，那么这个表就会用**双倍的桶数**自动进行再散列

当然了， 在后面阅读源码的时候会继续说明的，现在简单了解一下即可~

## 三、红黑树介绍

上面散列表中已经提过了：如果桶数满的时候，JDK8是将**链表转成红黑树**的~。并且，我们的TreeSet、TreeMap底层都是红黑树来实现的。

所以，在这里学习一波红黑树到底是啥玩意。

在未学习之前，我们可能是听过红黑树这么一个数据结构类型的，还有其他什么B/B+树等等，反正是**比较复杂的数据结构了**~~~

各种常见的树的用途：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151348.png)

 

### 3.1回顾二叉查找树

首先我们来回顾一下：利用二叉查找树的特性，我们一般来说可以很快地查找出对应的元素。

可是二叉查找树也有**个例(最坏)**的情况(线性)：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151351.png)

上面符合二叉树的特性，但是它是线性的，完全没树的用处~

树是要**“均衡”**才能将它的优点展示出来的~，比如下面这种：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151354.png)

因此，就有了**平衡树**这么一个概念~红黑树就是一种平衡树，它可以**保证二叉树基本符合矮矮胖胖(均衡)的结构**

### 3.2知新2-3树

讲到了平衡树就不得不说**最基础**的2-3树，2-3树**长的是这个样子：**

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151357.png)

在二叉查找树上，我们插入节点的过程是这样的：小于节点值往右继续与左子节点比，大于则继续与右子节点比，直到某节点左或右子节点为空，把值插入进去。**这样无法避免偏向问题**

而2-3树不一样：**它插入的时候可以保持树的平衡**！

在2-3树插入的时可以简单总结为两个操作：

- **合并2-节点为3-节点，扩充将3-节点扩充为一个4-节点**
- **分解4-节点为3-节点，节点3-节点为2-节点**
- ........**至使得树平衡**~

合并分解的操作还是**比较复杂的，要分好几种情况**，代码量很大~这里我就不介绍了，因为要学起来是一大堆的，很麻烦~

### 3.3从2-3树到红黑树

由于2-3树为了保持平衡性，在维护的时候是需要大量的节点交换的！这些变换在实际代码中是很复杂的，大佬们**在2-3树的理论基础上发明了红黑树**(2-3-4树也是同样的道理，只是2-3树是最简单的一种情况，所以我就不说2-3-4树了)。

- 红黑树是对2-3查找树的改进，它能用一种**统一的方式完成所有变换**。

红黑树是一种**平衡二叉树**,因此它没有3-节点。那红黑树是怎么将3-节点来改进成全都是二叉树呢？

红黑树就字面上的意思，**有红色的节点，有黑色的节点**：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151401.png)

我们可以将红色节点的**左链接**画平看看：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151403.png)

一颗典型的二叉树：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151406.png)

**将红色节点的左链接画平之后：得到2-3平衡树:**

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151409.png)

### 3.4红黑树基础知识

前面已经说了，红黑树是在2-3的基础上实现的一种树，它能够用统一的方式完成所有变换。很好理解：红黑树也是平衡树的一种，在插入元素的时候它也得保持树的平衡，那红黑树是以什么的方式来保持树的平衡的呢？

红黑树用的是也是两种方式来替代2-3树不断的节点交换操作：

- **旋转**：顺时针旋转和逆时针旋转
- **反色**：交换红黑的颜色
- 这个两个实现比2-3树交换的节点(合并，分解)要方便一些

 

红黑树为了保持平衡，还有制定一些约束，遵守这些约束的才能叫做红黑树：

1. 红黑树是二叉搜索树。
2. **根节点是黑色**。
3. **每个叶子节点都是黑色的空节点（NIL节点）**。
4. **每个红色节点的两个子节点都是黑色。(从每个叶子到根的所有路径上不能有两个连续的红色节点)**
5. **从任一节点到其每个叶子的所有路径都包含相同数目的黑色节点(每一条树链上的黑色节点数量（称之为“黑高”）必须相等)**。

# 五、HashMap

## 一、HashMap剖析

首先看看HashMap的顶部注释说了些什么：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151419.png)

再来看看HashMap的类继承图：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151422.png)

下面我们来看一下HashMap的属性：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151424.jpeg)

成员属性有这么几个：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151427.png)

再来看一下hashMap的一个内部类Node：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151429.png)

我们知道Hash的底层是散列表，而在Java中散列表的实现是通过数组+链表的~

再来简单看看put方法就可以印证我们的说法了：**数组+链表-->散列表**

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151431.png)

我们可以简单总结出HashMap：

- **无序，允许为null，非同步**
- **底层由散列表(哈希表)实现**
- **初始容量和装载因子对HashMap影响挺大的**，设置小了不好，设置大了也不好

### 1.1HashMap构造方法

HashMap的构造方法有4个：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151433.png)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151435.png)

在上面的构造方法最后一行，我们会发现调用了`tableSizeFor()`，我们进去看看：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151437.png)

看完上面可能会感到奇怪的是：**为啥是将2的整数幂的数赋给threshold**？

- threshold这个成员变量是阈值，决定了是否要将散列表再散列。它的值应该是：`capacity * load factor`才对的。

其实这里仅仅是一个初始化，当创建哈希表的时候，它会重新赋值的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151439.png)

 

至于别的构造方法都差不多，这里我就不细讲了：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151441.png)

### 1.2put方法

put方法可以说是HashMap的核心，我们来看看：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151444.png)

我们来看看它是怎么计算哈希值的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151447.png)

为什么要这样干呢？？我们一般来说直接将key作为哈希值不就好了吗，做异或运算是干嘛用的？？

我们看下来：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151448.png)

我们是根据key的哈希值来保存在散列表中的，我们表默认的初始容量是16，要放到散列表中，就是0-15的位置上。也就是`tab[i = (n - 1) & hash]`。可以发现的是：在做`&`运算的时候，仅仅是**后4位有效**~那如果我们key的哈希值高位变化很大，低位变化很小。直接拿过去做`&`运算，这就会导致计算出来的Hash值相同的很多。

而设计者**将key的哈希值的高位也做了运算(与高16位做异或运算，使得在做&运算时，此时的低位实际上是高位与低位的结合)，这就增加了随机性**，减少了碰撞冲突的可能性！

下面我们再来看看流程是怎么样的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151451.png)

新值覆盖旧值，返回旧值测试：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151453.png)

接下来我们看看`resize()`方法，在初始化的时候要调用这个方法，当散列表元素大于`capacity * load factor`的时候也是调用`resize()`

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151456.png)

 

### 1.3get方法

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151501.png)

接下来我们看看`getNode()`是怎么实现的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151503.png)

### 1.4remove方法

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151505.png)

再来看看`removeNode()`的实现：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151507.png)

## 二、HashMap与Hashtable对比

> 从存储结构和实现来讲基本上都是相同的。它和HashMap的最大的不同是它是线程安全的，另外它不允许key和value为null。Hashtable是个过时的集合类，不建议在新代码中使用，不需要线程安全的场合可以用HashMap替换，需要线程安全的场合可以用ConcurrentHashMap替换

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151512.png)

## 三、HashMap总结

在JDK8中HashMap的底层是：**数组+链表(散列表)+红黑树**

在散列表中有装载因子这么一个属性，当装载因子*初始容量小于散列表元素时，该散列表会再散列，扩容2倍！

装载因子的**默认值是0.75**，无论是初始大了还是初始小了对我们HashMap的性能都不好

- 装载因子初始值大了，可以减少散列表再散列(扩容的次数)，但同时会导致散列冲突的可能性变大(**散列冲突也是耗性能的一个操作，要得操作链表(红黑树)**！
- 装载因子初始值小了，可以减小散列冲突的可能性，但同时扩容的次数可能就会变多！

初始容量的**默认值是16**，它也一样，无论初始大了还是小了，对我们的HashMap都是有影响的：

- 初始容量过大，那么遍历时我们的速度就会受影响~
- 初始容量过小，散列表再散列(扩容的次数)可能就变得多，扩容也是一件非常耗费性能的一件事~

从源码上我们可以发现：HashMap并不是直接拿key的哈希值来用的，它会将key的哈希值的高16位进行异或操作，使得我们将元素放入哈希表的时候**增加了一定的随机性**。

还要值得注意的是：**并不是桶子上有8位元素的时候它就能变成红黑树，它得同时满足我们的散列表容量大于64才行的**~

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151515.png)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151517.png)

# 六、LinkedHashMap

## 一、LinkedHashMap

首先我们来看看类继承图：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151528.png)

我简单翻译了一下顶部的注释(我英文水平渣，如果有错的地方请多多包涵~欢迎在评论区下指正)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151530.png)

从顶部翻译我们就可以归纳总结出LinkedHashMap几点：

- 底层是散列表和双向链表
- 允许为null，不同步
- 插入的顺序是有序的(底层链表致使有序)
- 装载因子和初始容量对LinkedHashMap影响是很大的~

同时也给我带了几个疑问：

- access-ordered和insertion-ordered具体的使用和意思
- 为什么说初始容量对遍历没有影响？

希望可以在看源码的过程中可以解决掉我这两个疑问~~~那接下来就开始吧

### 1.1LinkedHashMap的域

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151535.png)

### 1.2LinkedHashMap重写的方法

下面我列举就这两个比较重要的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151537.png)

这就印证了我们的LinkedHashMap**底层确确实实是散列表和双向链表**~

- 在构建新节点时，构建的是`LinkedHashMap.Entry` 不再是`Node`.

### 1.3构造方法

可以发现，LinkedHashMap有**5个构造方法**：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151539.png)

下面我们来看看构造方法的定义是怎么样的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151541.png)

从构造方法上我们可以知道的是：**LinkedHashMap默认使用的是插入顺序**

### 1.4put方法

原本我是想要找put方法，看看是怎么实现的，**后来没找着，就奇了个怪**~

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151544.png)

再顿了一下，原来LinkedHashMap和HashMap的put方法是一样的！LinkedHashMap继承着HashMap，LinkedHashMap没有重写HashMap的put方法

所以，LinkedHashMap的put方法和HashMap是一样的。

当然了，**在创建节点的时候，调用的是LinkedHashMap重写的方法**~

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151546.png)

### 1.5get方法

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151550.png)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151553.png)

get方法也是多了：**判断是否为访问顺序**~~~

讲到了这里，感觉我们可以简单测试一波了：

首先我们来看看已**插入顺序**来进行插入和遍历：

```
    public static void insertOrder() {

        // 默认是插入顺序
        LinkedHashMap<Integer,String>  insertOrder = new LinkedHashMap();

        String value = "关注公众号Java3y";
        int i = 0;

        insertOrder.put(i++, value);
        insertOrder.put(i++, value);
        insertOrder.put(i++, value);
        insertOrder.put(i++, value);
        insertOrder.put(i++, value);

        //遍历
        Set<Integer> set = insertOrder.keySet();
        for (Integer s : set) {
            String mapValue = insertOrder.get(s);
            System.out.println(s + "---" + mapValue);
        }
    }
```

测试一波：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151556.png)

接着，我们来测试一下以**访问顺序**来进行插入和遍历：

```
    public static void accessOrder() {
        // 设置为访问顺序的方式
        LinkedHashMap<Integer,String> accessOrder = new LinkedHashMap(16, 0.75f, true);

        String value = "关注公众号Java3y";
        int i = 0;
        accessOrder.put(i++, value);
        accessOrder.put(i++, value);
        accessOrder.put(i++, value);
        accessOrder.put(i++, value);
        accessOrder.put(i++, value);


        // 遍历
        Set<Integer> sets = accessOrder.keySet();
        for (Integer key : sets) {
            String mapValue = accessOrder.get(key);
            System.out.println(key + "---" + mapValue);
        }

    }

```

代码**看似**是没有问题，但是运行会出错的！

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151559.png)

前面在看源码注释的时候我们就发现了：**在AccessOrder的情况下，使用get方法也是结构性的修改**！

为了简单看出他俩的区别，下面我就**直接用key来进行看了**~

以下是**访问顺序的测试**：

```

    public static void accessOrder() {
        // 设置为访问顺序的方式
        LinkedHashMap<Integer,String> accessOrder = new LinkedHashMap(16, 0.75f, true);

        String value = "关注公众号Java3y";
        int i = 0;
        accessOrder.put(i++, value);
        accessOrder.put(i++, value);
        accessOrder.put(i++, value);
        accessOrder.put(i++, value);
        accessOrder.put(i++, value);


        // 访问一下key为3的元素再进行遍历
        accessOrder.get(3);

        // 遍历
        Set<Integer> sets = accessOrder.keySet();
        for (Integer key : sets) {

            System.out.println(key );
        }

    }

```

测试结果：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151601.png)

以下是**插入顺序的测试**(代码就不贴了，和上面几乎一样)：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151603.png)

我们可以这样理解：**最常用的将其放在链表的最后，不常用的放在链表的最前**~

这个知识点以我的理解而言，它这个**访问顺序在LinkedHashMap如果不重写用处并不大**~它是用来给别的实现进行**扩展**的

- **因为最常被使用的元素再遍历的时候却放在了最后边，在LinkedHashMap中我也没找到对应的方法来进行调用**~
- 一个`removeEldestEntry(Map.Entry<K,V> eldest)`方法，**重写它可以删除最久未被使用的元素**！！
- 还有一个是`afterNodeInsertion(boolean evict)`方法，**新增时判断是否需要删除最久未被使用的元素**！！

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151605.png)

 

### 1.6remove方法

对于remove方法，在LinkedHashMap中也没有重写，它调用的还是父类的HashMap的`remove()`方法，在LinkedHashMap中重写的是：`afterNodeRemoval(Node<K,V> e)`这个方法

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151607.png)

当然了，在remove的时候会涉及到上面重写的方法：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151609.png)

### 1.7遍历的方法

`Set<Map.Entry<K,V>> entrySet()`是被重写的了

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151612.png)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151617.png)

看到了这里，我们就知道为啥注释说：**初始容量对遍历没有影响**

因为它遍历的是**LinkedHashMap内部维护的一个双向链表**，而不是散列表(当然了，链表双向链表的元素都来源于散列表)

 

## 二、LinkedHashMap总结

LinkedHashMap比HashMap多了一个双向链表的维护，在数据结构而言它要复杂一些，阅读源码起来比较轻松一些，因为大多都由HashMap实现了..

阅读源码的时候我们会发现多态是无处不在的~子类用父类的方法，子类重写了父类的**部分**方法即可达到不一样的效果！

- 比如：LinkedHashMap并没有重写put方法，而put方法内部的`newNode()`方法重写了。LinkedHashMap调用父类的put方法，里面回调的是重写后的`newNode()`，从而达到目的！

LinkedHashMap可以设置两种遍历顺序：

- 访问顺序（access-ordered）
- 插入顺序（insertion-ordered）
- **默认是插入顺序的**

对于访问顺序，它是LRU(最近最少使用)算法的实现，要使用它要么**重写LinkedListMap的几个方法**(`removeEldestEntry(Map.Entry<K,V> eldest)`和`afterNodeInsertion(boolean evict)`)，要么是**扩展**成LRUMap来使用，不然设置为访问顺序（access-ordered）的用处不大~

**LinkedHashMap遍历的是内部维护的双向链表**，所以说初始容量对LinkedHashMap遍历是不受影响的

# 七、TreeMap

 

## 一、TreeMap剖析

按照惯例，我简单翻译了一下顶部的注释(我英文水平渣，如果有错的地方请多多包涵~欢迎在评论区下指正)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151626.png)

接着我们来看看类继承图：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151630.png)

在注释中提到的要点，我来总结一下：

- TreeMap实现了NavigableMap接口，而NavigableMap接口继承着SortedMap接口，致使我们的**TreeMap是有序的**！
- TreeMap底层是红黑树，它方法的时间复杂度都不会太高:log(n)~
- 非同步
- 使用Comparator或者Comparable来比较key是否相等与排序的问题~

 

对我而言，Comparator和Comparable我都忘得差不多了~~~下面就开始看TreeMap的源码来看看它是怎么实现的，并且回顾一下Comparator和Comparable的用法吧！

### 1.1TreeMap的域

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151632.png)

### 1.2TreeMap构造方法

TreeMap的构造方法有4个：

![img](https://user-gold-cdn.xitu.io/2018/4/12/162b9081b3545c52?w=477&h=126&f=png&s=7267)

可以发现，TreeMap的构造方法大多数与comparator有关：

![img](https://user-gold-cdn.xitu.io/2018/4/12/162b908ce819c105?w=1918&h=2487&f=png&s=232085)

也就是顶部注释说的：TreeMap有序是通过Comparator来进行比较的，**如果comparator为null，那么就使用自然顺序**~

打个比方：如果value是整数，自然顺序指的就是我们平常排序的顺序(1,2,3,4,5..)~

```
    TreeMap<Integer, Integer> treeMap = new TreeMap<>();

    treeMap.put(1, 5);
    treeMap.put(2, 4);
    treeMap.put(3, 3);
    treeMap.put(4, 2);
    treeMap.put(5, 1);

    for (Entry<Integer, Integer> entry : treeMap.entrySet()) {

        String s = entry.getKey() +"关注公众号：Java3y---->" + entry.getValue();

        System.out.println(s);
    }
```

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151638.png)

### 1.3put方法

我们来看看TreeMap的核心put方法，阅读它就可以获取不少关于TreeMap特性的东西了~

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151640.png)

下面是`compare(Object k1, Object k2)`方法

```
    /**
     * Compares two keys using the correct comparison method for this TreeMap.
     */
    @SuppressWarnings("unchecked")
    final int compare(Object k1, Object k2) {
        return comparator==null ? ((Comparable<? super K>)k1).compareTo((K)k2)
            : comparator.compare((K)k1, (K)k2);
    }
```

如果我们设置key为null，会抛出异常的，就不执行下面的代码了。

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151643.png)

### 1.4get方法

接下来我们来看看get方法的实现：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151645.png)

点进去`getEntry()`看看实现：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151647.png)

如果Comparator不为null，接下来我们进去看看`getEntryUsingComparator(Object key)`，是怎么实现的

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151649.png)

### 1.5remove方法

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151651.png)

删除节点的时候调用的是`deleteEntry(Entry<K,V> p)`方法，这个方法主要是**删除节点并且平衡红黑树**

平衡红黑树的代码是比较复杂的，我就不说了，你们去看吧(反正我看不懂)....

### 1.6遍历方法

在看源码的时候可能不知道哪个是核心的遍历方法，因为Iterator有非常非常多~

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151653.png)

此时，我们只需要debug一下看看，跟下去就好！

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151655.png)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151658.png)

于是乎，我们可以找到：**TreeMap遍历是使用EntryIterator这个内部类的**

首先来看看EntryIterator的类结构图吧：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151701.png)

可以发现，EntryIterator大多的实现都是在父类中：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151702.png)

那接下来我们去看看PrivateEntryIterator比较重要的方法：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151704.png)

我们进去`successor(e)`方法看看实现：

> successor 其实就是一个结点的 下一个结点，所谓 下一个，是按次序排序后的下一个结点。从代码中可以看出，如果右子树不为空，就返回右子树中最小结点。如果右子树为空，就要向上回溯了。在这种情况下，t 是以其为根的树的最后一个结点。如果它是其父结点的左孩子，那么父结点就是它的下一个结点，否则，t 就是以其父结点为根的树的最后一个结点，需要再次向上回溯。一直到 ch 是 p 的左孩子为止。

来源：https://blog.csdn.net/on_1y/article/details/27231855

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151710.png)

## 二、TreeMap总结

TreeMap底层是红黑树，能够实现该Map集合有序~

如果在构造方法中传递了Comparator对象，那么就会以Comparator对象的方法进行比较。否则，则使用Comparable的`compareTo(T o)`方法来比较。

- 值得说明的是：如果使用的是`compareTo(T o)`方法来比较，**key一定是不能为null**，并且得实现了Comparable接口的。
- 即使是传入了Comparator对象，不用`compareTo(T o)`方法来比较，key**也是**不能为null的

```
    public static void main(String[] args) {
        TreeMap<Student, String> map = new TreeMap<Student, String>((o1, o2) -> {
            //主要条件
            int num = o1.getAge() - o2.getAge();

            //次要条件
            int num2 = num == 0 ? o1.getName().compareTo(o2.getName()) : num;

            return num2;
        });

        //创建学生对象
        Student s1 = new Student("潘安", 30);
        Student s2 = new Student("柳下惠", 35);

        //添加元素进集合
        map.put(s1, "宋朝");
        map.put(s2, "元朝");
        map.put(null, "汉朝");

        //获取key集合
        Set<Student> set = map.keySet();

        //遍历key集合
        for (Student student : set) {
            String value = map.get(student);
            System.out.println(student + "---------" + value);
        }
    }
```

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151712.png)

 

我们从源码中的很多地方中发现：Comparator和Comparable出现的频率是很高的，因为TreeMap实现有序要么就是外界传递进来Comparator对象，要么就使用默认key的Comparable接口(实现自然排序)

最后我就来总结一下TreeMap要点吧：

1. 由于底层是红黑树，那么时间复杂度可以保证为log(n)
2. key不能为null，为null为抛出NullPointException的
3. 想要自定义比较，在构造方法中传入Co smparator对象，否则使用key的自然排序来进行比较
4. TreeMap非同步的，想要同步可以使用Collections来进行封装

# 八、ConcurrentHashMap

 

## 一、ConCurrentHashMap剖析

ConCurrentHashMap在初学的时候反正我是没有接触过的，不知道你们接触过了没有~

这个类听得也挺少的，在集合中是比较复杂的一个类了，它涉及到了一些多线程的知识点。

不了解或忘记多线程知识点的同学也不要怕，哪儿用到了多线程的知识点，我都会简单介绍一下，并给出对应的资料去阅读的~

好了，我们就来开始吧~

### 1.1初识ConCurrentHashMap

ConCurrentHashMap的**底层是：散列表+红黑树**，与HashMap是一样的。

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151731.png)

从前面的章节我们也可以发现：最快了解一下类是干嘛的，我们**看源码的顶部注释**就可以了！

我简单翻译了一下顶部的注释(我英文水平渣，如果有错的地方请多多包涵~欢迎在评论区下指正)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151734.png)

根据上面注释我们可以简单总结：

- JDK1.8底层是**散列表+红黑树**
- ConCurrentHashMap支持**高并发**的访问和更新，它是**线程安全**的
- 检索操作不用加锁，get方法是非阻塞的
- key和value都不允许为null

### 1.2JDK1.7底层实现

上面指明的是JDK1.8底层是：散列表+红黑树，也就意味着，JDK1.7的底层跟JDK1.8是不同的~

JDK1.7的底层是：segments+HashEntry数组：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151738.png)

图来源：https://blog.csdn.net/panweiwei1994/article/details/78897275

- Segment**继承了ReentrantLock**,每个片段都有了一个锁，叫做“**锁分段**”

### 1.3有了Hashtable为啥需要ConCurrentHashMap

- Hashtable是在**每个方法上都加上了Synchronized**完成同步，效率低下。
- ConcurrentHashMap通过在**部分加锁**和**利用CAS算法**来实现同步。

### 1.4CAS算法和volatile简单介绍

在看ConCurrentHashMap源码之前，我们来简单讲讲CAS算法和volatile关键字

CAS（比较与交换，Compare and swap） 是一种有名的**无锁算法**

CAS有**3个**操作数

- **内存值V**
- **旧的预期值A**
- **要修改的新值B**

**当且仅当预期值A和内存值V相同时，将内存值V修改为B，否则什么都不做**

- 当多个线程尝试使用CAS同时更新同一个变量时，只有其中一个线程能更新变量的值(**A和内存值V相同时，将内存值V修改为B)**，而其它线程都失败，失败的线程**并不会被挂起**，而是被告知这次竞争中失败，并可以再次尝试**(否则什么都不做)**

看了上面的描述应该就很容易理解了，先**比较**是否相等，如果相等则**替换**(CAS算法)

------

接下来我们看看**volatile关键字**，在初学的时候也很少使用到volatile这个关键字。反正我没用到，而又经常在看Java相关面试题的时候看到它，觉得是一个挺神秘又很难的一个关键字。其实不然，还是挺容易理解的~

volatile经典总结：**volatile仅仅用来保证该变量对所有线程的可见性，但不保证原子性**

我们将其拆开来解释一下：

- 保证**该变量对所有线程的可见性**
  - 在多线程的环境下：当这个变量修改时，**所有的线程都会知道该变量被修改了**，也就是所谓的“可见性”
- 不保证原子性
  - 修改变量(赋值)**实质上**是在JVM中**分了好几步**，而**在这几步内(从装载变量到修改)，它是不安全的**。

 

### 1.5ConCurrentHashMap域

域对象有这么几个：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151741.png)

我们来简单看一下他们是什么东东：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151743.png)

初次阅读完之后，有的属性我也不太清楚它是干什么的，在**继续阅读之后可能就明朗了**~

### 1.6ConCurrentHashMap构造方法

ConcurrentHashMap的构造方法有5个：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151746.png)

具体的实现是这样子的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151747.png)

可以发现，在构造方法中有几处都调用了`tableSizeFor()`，我们来看一下他是干什么的：

点进去之后发现，啊，原来我看过这个方法，在HashMap的时候.....

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151751.png)

它就是用来获取**大于参数且最接近2的整次幂的数**...

**赋值给sizeCtl属性也就说明了：这是下次扩容的大小**~

 

### 1.7put方法

终于来到了最核心的方法之一：put方法啦~~~~

我们先来**整体看一下**put方法干了什么事：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151753.png)

接下来，我们来看看初始化散列表的时候干了什么事：`initTable()`

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151756.png)

**只让一个线程对散列表进行初始化**！

### 1.8get方法

从顶部注释我们可以读到，get方法是**不用加锁**的，是非阻塞的。

我们可以发现，Node节点是重写的，设置了volatile关键字修饰，致使它每次获取的都是**最新**设置的值

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151758.png)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151801.png)

## 二、ConcurrentHashMap总结

上面简单介绍了ConcurrentHashMap的核心知识，还有很多知识点都没有提及到，作者的水平也不能将其弄懂~~有兴趣进入的同学可到下面的链接继续学习。

下面我来简单总结一下ConcurrentHashMap的核心要点：

- **底层结构是散列表(数组+链表)+红黑树**，这一点和HashMap是一样的。
- Hashtable是将所有的方法进行同步，效率低下。而ConcurrentHashMap作为一个高并发的容器，它是通过**部分锁定+CAS算法来进行实现线程安全的**。CAS算法也可以认为是**乐观锁**的一种~
- 在高并发环境下，统计数据(计算size...等等)其实是无意义的，因为在下一时刻size值就变化了。
- get方法是非阻塞，无锁的。重写Node类，通过volatile修饰next来实现每次获取都是**最新**设置的值
- **ConcurrentHashMap的key和Value都不能为null**

# 九、Set

## 一、HashSet剖析

首先，我们来看一下HashSet的继承结构图：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151809.png)

按照惯例，我们来看看HashSet顶部注释：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151811.png)

从顶部注释来看，我们就可以归纳HashSet的要点了：

- 实现Set接口
- 不保证迭代顺序
- 允许元素为null
- **底层实际上是一个HashMap实例**
- 非同步
- 初始容量非常影响迭代性能

 

 

顶部注释说底层实际上是一个HashMap实例，那证据呢？

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151815.png)

我们再来看一下HashSet整个类的方法和属性：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151816.png)

对于学习过HashMap的人来说，简直简单得让人开心，哈哈哈~

我们知道Map是一个映射，有key有value，**既然HashSet底层用的是HashMap，那么value在哪里呢**？？？

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151819.png)

value是一个Object，**所有的value都是它**

所以可以直接总结出：HashSet实际上就是封装了HashMap，**操作HashSet元素实际上就是操作HashMap**。这也是面向对象的一种体现，**重用性贼高**！

 

## 二、TreeSet剖析

首先，我们也来看看TreeSet的类继承结构图：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151820.png)

按照惯例，我们来看看TreeSet顶部注释：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151822.png)

从顶部注释来看，我们就可以归纳TreeSet的要点了：

- 实现NavigableSet接口
- 可以实现排序功能
- **底层实际上是一个TreeMap实例**
- 非同步

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151831.png)

## 三、LinkedHashSet剖析

首先，我们也来看看TreeSet的类继承结构图：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151825.png)

按照惯例，我们来看看LinkedHashSet顶部注释：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151835.png)

从顶部注释来看，我们就可以归纳LinkedHashSet的要点了：

- 迭代是有序的
- 允许为null
- **底层实际上是一个HashMap+双向链表实例(其实就是LinkedHashMap)...**
- 非同步
- 性能比HashSet差一丢丢，因为要维护一个双向链表
- 初始容量与迭代无关，LinkedHashSet迭代的是双向链表

## 四、Set集合总结

可以很明显地看到，**Set集合的底层就是Map**，所以我都没有做太多的分析在上面，也没什么好分析的了。

下面总结一下Set集合常用的三个子类吧：

**HashSet：**

- 无序，允许为null，底层是HashMap(散列表+红黑树)，非线程同步

**TreeSet：**

- 有序，不允许为null，底层是TreeMap(红黑树),非线程同步

**LinkedHashSet：**

- 迭代有序，允许为null，底层是HashMap+双向链表，非线程同步

从结论而言我们就可以根据自己的实际情况来使用了。

# 十、CopyOnWriteArrayList

 

CopyWriteOn 可能大家对这个技术**比较陌生**吧，但这项技术是**挺多应用场景**的。除了上文所说的Linux、文件系统外，其实在**Java**也有其身影。

大家对线程安全容器可能最熟悉的就是ConcurrentHashMap了，因为这个容器经常会在面试的时候考查。

比如说，一个常见的面试场景：

- 面试官问：“HashMap是线程安全的吗？如果HashMap线程不安全的话，那有没有安全的Map容器”
- 3y：“线程安全的Map有两个，一个是Hashtable，一个是ConcurrentHashMap”
- 面试官继续问：“那Hashtable和ConcurrentHashMap有什么区别啊？”
- 3y：“balabalabalabalabalabala"
- 面试官：”ok,ok,ok,看你Java基础挺不错的呀“

那如果有这样的面试呢？

- 面试官问：“ArrayList是线程安全的吗？如果ArrayList线程不安全的话，那有没有安全的类似ArrayList的容器”
- 3y：“线程安全的ArrayList我们可以使用Vector，或者说我们可以使用Collections下的方法来包装一下”
- 面试官继续问：“嗯，我相信你也知道Vector是一个比较老的容器了，还有没有其他的呢？”
- 3y：“Emmmm,这个...“
- 面试官**提示**：“就比如JUC中有ConcurrentHashMap，那JUC中有类似"ArrayList"的线程安全容器类吗？“
- 3y：“Emmmm,这个...“
- 面试官：”ok,ok,ok,**今天的面试时间也差不多了，你回去等通知吧**。“

今天主要讲解的是CopyOnWriteArrayList~

本文**力求简单讲清每个知识点**，希望大家看完能有所收获

## 一、Vector和SynchronizedList

### 1.1回顾线程安全的Vector和SynchronizedList

我们知道ArrayList是用于替代Vector的，Vector是线程安全的容器。因为它几乎在每个方法声明处都加了**synchronized关键字**来使容器安全。

![Vector实现](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151846.png)

如果使用`Collections.synchronizedList(new ArrayList())`来使ArrayList变成是线程安全的话，也是几乎都是每个方法都加上synchronized关键字的，只不过**它不是加在方法的声明处，而是方法的内部**。

![Collections.synchronizedList()的实现](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151848.png)

### 1.2Vector和SynchronizedList可能会出现的问题

在讲解CopyOnWrite容器之前，我们还是先来看一下线程安全容器的一些**可能没有注意到**的地方~

下面我们直接来看一下这段代码：

```
    // 得到Vector最后一个元素
    public static Object getLast(Vector list) {
        int lastIndex = list.size() - 1;
        return list.get(lastIndex);
    }

    // 删除Vector最后一个元素
    public static void deleteLast(Vector list) {
        int lastIndex = list.size() - 1;
        list.remove(lastIndex);
    }

```

以我们第一反应来分析一下上面两个方法：**在多线程环境下，是否有问题**？

- 我们可以知道的是Vector的`size()和get()以及remove()`都被synchronized修饰的。

答案：从调用者的角度是**有问题**的

我们可以写段代码测试一下：

```
import java.util.Vector;

public class UnsafeVectorHelpers {


    public static void main(String[] args) {

        // 初始化Vector
        Vector<String> vector = new Vector();
        vector.add("关注公众号");
        vector.add("Java3y");
        vector.add("买Linux可到我下面的链接，享受最低价");
        vector.add("给3y加鸡腿");

        new Thread(() -> getLast(vector)).start();
        new Thread(() -> deleteLast(vector)).start();
        new Thread(() -> getLast(vector)).start();
        new Thread(() -> deleteLast(vector)).start();
    }

    // 得到Vector最后一个元素
    public static Object getLast(Vector list) {
        int lastIndex = list.size() - 1;
        return list.get(lastIndex);
    }

    // 删除Vector最后一个元素
    public static void deleteLast(Vector list) {
        int lastIndex = list.size() - 1;
        list.remove(lastIndex);
    }
}

```

可以发现的是，有可能会抛出异常的：

![代码抛出异常](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151859.png)

原因也很简单，我们照着流程走一下就好了：

- 线程A执行`getLast()`方法，线程B执行`deleteLast()`方法
- 线程A执行`int lastIndex = list.size() - 1;`得到lastIndex的值是3。**同时**，线程B执行`int lastIndex = list.size() - 1;`得到的lastIndex的值**也**是3
- 此时线程B先得到CPU执行权，执行`list.remove(lastIndex)`将下标为3的元素删除了
- 接着线程A得到CPU执行权，执行`list.get(lastIndex);`，发现已经没有下标为3的元素，抛出异常了.

![交替执行导致异常发生](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151901.png)

出现这个问题的原因也很简单：

- `getLast()`和`deleteLast()`这两个方法并不是原子性的，即使他们**内部的每一步操作是原子性**的(被Synchronize修饰就可以实现原子性)，但是内部之间还是可以**交替**执行。
  - 这里的意思就是：`size()和get()以及remove()`都是原子性的，但是如果并发执行`getLast()`和`deleteLast()`，方法里面的`size()和get()以及remove()`是可以交替执行的。

要解决上面这种情况也很简单，因为我们都是对Vector进行操作的，**只要操作Vector前把它锁住就没毛病了**！

所以我们可以改成这样子：

```
    // 得到Vector最后一个元素
    public static Object getLast(Vector list) {
        synchronized (list) {
            int lastIndex = list.size() - 1;
            return list.get(lastIndex);
        }
    }
    // 删除Vector最后一个元素
    public static void deleteLast(Vector list) {
        synchronized (list) {
            int lastIndex = list.size() - 1;
            list.remove(lastIndex);
        }
    }

```

> ps:如果有人去测试一下，发现会抛出异常java.lang.ArrayIndexOutOfBoundsException: -1，这是**没有检查角标的异常**，不是并发导致的问题。

经过上面的例子我们可以看看下面的代码：

```
    public static void main(String[] args) {

        // 初始化Vector
        Vector<String> vector = new Vector();
        vector.add("关注公众号");
        vector.add("Java3y");
        vector.add("买Linux可到我下面的链接，享受最低价");
        vector.add("给3y加鸡腿");

        // 遍历Vector
        for (int i = 0; i < vector.size(); i++) {

            // 比如在这执行vector.clear();
            //new Thread(() -> vector.clear()).start();

            System.out.println(vector.get(i));
        }
    }
```

同样地：如果在遍历Vector的时候，有别的线程修改了Vector的长度，那还是会**有问题**！

- 线程A遍历Vector，执行`vector.size()`时，发现Vector的长度为5
- 此时**很有可能存在**线程B对Vector进行`clear()`操作
- 随后线程A执行`vector.get(i)`时，抛出异常

![Vector遍历抛出异常](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151908.png)

在JDK5以后，Java推荐使用`for-each`(迭代器)来遍历我们的集合，好处就是**简洁、数组索引的边界值只计算一次**。

如果使用`for-each`(迭代器)来做上面的操作，会抛出ConcurrentModificationException异常

![迭代器遍历会抛出ConcurrentModificationException](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151911.png)

SynchronizedList在使用**迭代器遍历**的时候同样会有问题的，源码已经提醒我们要手动加锁了。

![SynchronizedList在遍历的时候同样会有问题的](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151913.png)

如果想要完美解决上面所讲的问题，我们可以在**遍历前加锁**：

```
    // 遍历Vector
    synchronized (vector) {
            for (int i = 0; i < vector.size(); i++) {
                vector.get(i);
            }
        }
```

有经验的同学就可以知道：**哇，遍历一下容器都要我加上锁，这这这不是要慢死了吗**.的确是挺慢的..

所以我们的CopyOnWriteArrayList就登场了！

## 二、CopyOnWriteArrayList(Set)介绍

一般来说，我们会认为：CopyOnWriteArrayList是同步List的替代品，CopyOnWriteArraySet是同步Set的替代品。

无论是Hashtable-->ConcurrentHashMap，还是说Vector-->CopyOnWriteArrayList。JUC下支持并发的容器与老一代的线程安全类相比，总结起来就是加锁**粒度**的问题

- Hashtable、Vector加锁的粒度大(直接在方法声明处使用synchronized)
- ConcurrentHashMap、CopyOnWriteArrayList加锁粒度小(用各种的方式来实现线程安全，比如我们知道的ConcurrentHashMap用了cas锁、volatile等方式来实现线程安全..)
- JUC下的线程安全容器在遍历的时候**不会**抛出ConcurrentModificationException异常

所以一般来说，我们都会**使用JUC包下给我们提供的线程安全容器**，而不是使用老一代的线程安全容器。

下面我们来看看CopyOnWriteArrayList是怎么实现的，为什么使用**迭代器遍历**的时候就**不用额外加锁**，也不会抛出ConcurrentModificationException异常。

### 2.1CopyOnWriteArrayList实现原理

我们还是先来回顾一下COW：

> 如果有多个调用者（callers）同时请求相同资源（如内存或磁盘上的数据存储），他们会共同获取**相同的指针指向相同的资源**，直到某个调用者**试图修改**资源的内容时，系统才会**真正复制一份专用副本**（private copy）给该调用者，而其他调用者所见到的最初的资源仍然保持不变。**优点**是如果调用者**没有修改该资源，就不会有副本**（private copy）被建立，因此多个调用者只是读取操作时可以**共享同一份资源**。

参考自维基百科：[https://zh.wikipedia.org/wiki/%E5%AF%AB%E5%85%A5%E6%99%82%E8%A4%87%E8%A3%BD](https://zh.wikipedia.org/wiki/寫入時複製)

> 之前写博客的时候，如果是要看源码，一般会翻译一下源码的注释并用图贴在文章上的。Emmm，发现阅读体验并不是很好，所以我这里就**直接概括一下源码注释**说了什么吧。另外，如果使用IDEA的话，可以下一个插件**Translation**(免费好用).

![Translation插件](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151916.png)

![Translation插件](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151923.png)

------

概括一下CopyOnWriteArrayList源码注释介绍了什么：

- CopyOnWriteArrayList是线程安全容器(相对于ArrayList)，底层通过**复制数组**的方式来实现。
- CopyOnWriteArrayList在遍历的使用不会抛出ConcurrentModificationException异常，并且遍历的时候就不用额外加锁
- 元素可以为null

#### 2.1.1看一下CopyOnWriteArrayList基本的结构

```
    /** 可重入锁对象 */
    final transient ReentrantLock lock = new ReentrantLock();

    /** CopyOnWriteArrayList底层由数组实现，volatile修饰 */
    private transient volatile Object[] array;

    /**
     * 得到数组
     */
    final Object[] getArray() {
        return array;
    }

    /**
     * 设置数组
     */
    final void setArray(Object[] a) {
        array = a;
    }

    /**
     * 初始化CopyOnWriteArrayList相当于初始化数组
     */
    public CopyOnWriteArrayList() {
        setArray(new Object[0]);
    }
```

看起来挺简单的，CopyOnWriteArrayList底层就是数组，加锁就交由ReentrantLock来完成。

#### 2.1.2常见方法的实现

 

根据上面的分析我们知道如果遍历`Vector/SynchronizedList`是需要自己手动加锁的。

CopyOnWriteArrayList使用迭代器遍历时不需要显示加锁，看看`add()、clear()、remove()`与`get()`方法的实现可能就有点眉目了。

首先我们可以看看`add()`方法

```
    public boolean add(E e) {
    
    // 加锁
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
      
      // 得到原数组的长度和元素
            Object[] elements = getArray();
            int len = elements.length;
      
      // 复制出一个新数组
            Object[] newElements = Arrays.copyOf(elements, len + 1);
      
      // 添加时，将新元素添加到新数组中
            newElements[len] = e;
      
      // 将volatile Object[] array 的指向替换成新数组
            setArray(newElements);
            return true;
        } finally {
            lock.unlock();
        }
    }

```

通过代码我们可以知道：在添加的时候就上锁，并**复制一个新数组，增加操作在新数组上完成，将array指向到新数组中**，最后解锁。

再来看看`size()`方法：

```
  public int size() {

    // 直接得到array数组的长度
        return getArray().length;
    }
```

再来看看`get()`方法：

```

    public E get(int index) {
        return get(getArray(), index);
    }

  final Object[] getArray() {
        return array;
    }
```

那再来看看`set()`方法

```
public E set(int index, E element) {
  final ReentrantLock lock = this.lock;
  lock.lock();
  try {
    
    // 得到原数组的旧值
    Object[] elements = getArray();
    E oldValue = get(elements, index);

    // 判断新值和旧值是否相等
    if (oldValue != element) {
      
      // 复制新数组，新值在新数组中完成
      int len = elements.length;
      Object[] newElements = Arrays.copyOf(elements, len);
      newElements[index] = element;
      
      // 将array引用指向新数组
      setArray(newElements);
    } else {
      // Not quite a no-op; enssures volatile write semantics
      setArray(elements);
    }
    return oldValue;
  } finally {
    lock.unlock();
  }
}

```

对于`remove()、clear()`跟`set()和add()`是类似的，这里我就不再贴出代码了。

总结：

- **在修改时，复制出一个新数组，修改的操作在新数组中完成，最后将新数组交由array变量指向**。
- **写加锁，读不加锁**

#### 2.1.3剖析为什么遍历时不用调用者显式加锁

常用的方法实现我们已经基本了解了，但还是不知道为啥能够在容器遍历的时候对其进行修改而不抛出异常。所以，来看一下他的迭代器吧：

```

  // 1. 返回的迭代器是COWIterator
  public Iterator<E> iterator() {
        return new COWIterator<E>(getArray(), 0);
    }


  // 2. 迭代器的成员属性
    private final Object[] snapshot;
    private int cursor;

  // 3. 迭代器的构造方法
  private COWIterator(Object[] elements, int initialCursor) {
        cursor = initialCursor;
        snapshot = elements;
    }

  // 4. 迭代器的方法...
  public E next() {
        if (! hasNext())
            throw new NoSuchElementException();
        return (E) snapshot[cursor++];
    }

  //.... 可以发现的是，迭代器所有的操作都基于snapshot数组，而snapshot是传递进来的array数组

```

到这里，我们应该就可以想明白了！CopyOnWriteArrayList在使用迭代器遍历的时候，操作的都是**原数组**！

![一张图来解析COW容器](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151929.png)

#### 2.1.4CopyOnWriteArrayList缺点

看了上面的实现源码，我们应该也大概能分析出CopyOnWriteArrayList的缺点了。

- **内存占用**：如果CopyOnWriteArrayList经常要增删改里面的数据，经常要执行`add()、set()、remove()`的话，那是比较耗费内存的。
  - 因为我们知道每次`add()、set()、remove()`这些增删改操作都要**复制一个数组**出来。
- **数据一致性**：CopyOnWrite容器**只能保证数据的最终一致性，不能保证数据的实时一致性**。
  - 从上面的例子也可以看出来，比如线程A在迭代CopyOnWriteArrayList容器的数据。线程B在线程A迭代的间隙中将CopyOnWriteArrayList部分的数据修改了(已经调用`setArray()`了)。但是线程A迭代出来的是原有的数据。

#### 2.1.5CopyOnWriteSet

CopyOnWriteArraySet的原理就是CopyOnWriteArrayList。

```
    private final CopyOnWriteArrayList<E> al;

    public CopyOnWriteArraySet() {
        al = new CopyOnWriteArrayList<E>();
    }
```

# 十一、Java集合面试题

 

Java容器可分为两大类：

- Collection
  - List
    - **ArrayList**
    - LinkedList
    - Vector(了解，已过时)
  - Set
    - **HashSet**
      - LinkedHashSet
    - TreeSet
- Map
  - **HashMap**
    - LinkedHashMap
  - TreeMap
  - ConcurrentHashMap
  - Hashtable(了解，，已过时)

着重标出的那些就是我们**用得最多**的容器。

 

## 一、ArrayList和Vector的区别

**共同点：**

- 这两个类都实现了List接口，它们都是**有序**的集合(存储有序)，**底层是数组**。我们可以按位置索引号取出某个元素，**允许元素重复和为null**。

**区别：**

- **同步性：**
  - ArrayList是非同步的
  - Vector是同步的
  - 即便需要同步的时候，我们可以使用Collections工具类来构建出同步的ArrayList而不用Vector
- **扩容大小：**
  - Vector增长原来的一倍，ArrayList增长原来的0.5倍

## 二、HashMap和Hashtable的区别

**共同点：**

- 从存储结构和实现来讲基本上都是相同的，都是实现Map接口~

**区别：**

- **同步性：**
  - HashMap是非同步的
  - Hashtable是同步的
  - 需要同步的时候，我们往往不使用，而使用ConcurrentHashMap[ConcurrentHashMap基于JDK1.8源码剖析](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484161&idx=1&sn=6f52fb1f714f3ffd2f96a5ee4ebab146&chksm=ebd74200dca0cb16288db11f566cb53cafc580e08fe1c570e0200058e78676f527c014ffef41#rd)
- **是否允许为null：**
  - HashMap允许为null
  - Hashtable不允许为null
- **contains方法**
  - 这知识点是在牛客网刷到的，没想到这种题还会有(我不太喜欢)....
  - Hashtable有contains方法
  - HashMap把Hashtable的contains方法去掉了，改成了containsValue和containsKey
- **继承不同：**
  - HashMap<K,V> extends AbstractMap<K,V>
  - public class Hashtable<K,V> extends Dictionary<K,V>

## 三、List和Map的区别

**共同点：**

- 都是Java常用的容器，都是接口(ps：写出来感觉好像和没写一样.....)

**不同点：**

- **存储结构不同**：
  - List是存储单列的集合
  - Map存储的是key-value键值对的集合
- **元素是否可重复**：
  - List允许元素重复
  - Map不允许key重复
- **是否有序**：
  - List集合是有序的(存储有序)
  - Map集合是无序的(存储无序)

## 四、Set里的元素是不能重复的，那么用什么方法来区分重复与否呢? 是用==还是equals()?

我们知道Set集合实际**大都使用的是Map集合的put方法来添加元素**。

以HashSet为例，HashSet里的元素不能重复，在源码(HashMap)是这样体现的：

```
  
  // 1. 如果key 相等  
    if (p.hash == hash &&
        ((k = p.key) == key || (key != null && key.equals(k))))
        e = p;
  // 2. 修改对应的value
     if (e != null) { // existing mapping for key
            V oldValue = e.value;
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            afterNodeAccess(e);
            return oldValue;
       }
```

添加元素的时候，如果key(也对应的Set集合的元素)相等，那么则修改value值。而在Set集合中，value值仅仅是一个Object对象罢了(**该对象对Set本身而言是无用的**)。

也就是说：Set集合如果添加的元素相同时，**是根本没有插入的(仅修改了一个无用的value值)**！从源码(HashMap)中也看出来，**==和equals()方法都有使用**！

## 五、Collection和Collections的区别

1. Collection是集合的上级**接口**，继承它的有Set和List接口
2. Collections是集合的**工具类**，提供了一系列的静态方法对集合的搜索、查找、同步等操作

## 六、说出ArrayList,LinkedList的存储性能和特性

ArrayList的底层是数组，LinkedList的底层是双向链表。

- ArrayList它支持以角标位置进行索引出对应的元素(随机访问)，而LinkedList则需要遍历整个链表来获取对应的元素。因此**一般来说ArrayList的访问速度是要比LinkedList要快的**
- ArrayList由于是数组，对于删除和修改而言消耗是比较大(复制和移动数组实现)，LinkedList是双向链表删除和修改只需要修改对应的指针即可，消耗是很小的。因此**一般来说LinkedList的增删速度是要比ArrayList要快的**

### 6.1扩展：

ArrayList的增删**未必**就是比LinkedList要慢。

- 如果增删都是在**末尾**来操作【每次调用的都是remove()和add()】，此时ArrayList就不需要移动和复制数组来进行操作了。如果数据量有百万级的时，**速度是会比LinkedList要快的**。(我测试过)
- 如果**删除操作**的位置是在**中间**。由于LinkedList的消耗主要是在遍历上，ArrayList的消耗主要是在移动和复制上(底层调用的是arraycopy()方法，是native方法)。
  - LinkedList的遍历速度是要慢于ArrayList的复制移动速度的
  - 如果数据量有百万级的时，**还是ArrayList要快**。(我测试过)

## 七、Enumeration和Iterator接口的区别

这个我在前面的文章中也没有详细去讲它们，只是大概知道的是：Iterator替代了Enumeration，Enumeration是一个旧的迭代器了。

与Enumeration相比，Iterator更加安全，**因为当一个集合正在被遍历的时候，它会阻止其它线程去修改集合**。

- 我们在做练习的时候，迭代时会不会经常出错，抛出ConcurrentModificationException异常，说我们在遍历的时候还在修改元素。
- 这其实就是fail-fast机制~具体可参考博文：https://blog.csdn.net/panweiwei1994/article/details/77051261

**区别有三点：**

- Iterator的方法名比Enumeration更科学
- Iterator有fail-fast机制，比Enumeration更安全
- Iterator能够删除元素，Enumeration并不能删除元素

## 八、ListIterator有什么特点

- ListIterator**继承了**Iterator接口，它用于**遍历List集合的元素**。
- ListIterator可以实现**双向遍历,添加元素，设置元素**

看一下源码的方法就知道了：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201209151942.png)

## 九、并发集合类是什么？

Java1.5并发包（java.util.concurrent）**包含线程安全集合类，允许在迭代时修改集合**。

- Utils包下的集合迭代器被设计为fail-fast的，会抛出ConcurrentModificationException。但java.util.concurrent的并不会，感谢评论区提醒~
- 一部分类为：
  - CopyOnWriteArrayList
  - ConcurrentHashMap
  - CopyOnWriteArraySet

## 十、Java中HashMap的key值要是为类对象则该类需要满足什么条件？

**需要同时重写该类的hashCode()方法和它的equals()方法**。

- 从源码可以得知，在插入元素的时候是**先算出该对象的hashCode**。如果hashcode相等话的。那么表明该对象是存储在同一个位置上的。
- 如果调用equals()方法，**两个key相同**，则**替换元素**
- 如果调用equals()方法，**两个key不相同**，则说明该**hashCode仅仅是碰巧相同**，此时是散列冲突，将新增的元素放在桶子上

一般来说，我们会认为：**只要两个对象的成员变量的值是相等的，那么我们就认为这两个对象是相等的**！因为，Object底层比较的是两个对象的地址，而对我们开发来说这样的意义并不大~这也就为什么我们要重写`equals()`方法

重写了equals()方法，就要重写hashCode()的方法。因为**equals()认定了这两个对象相同**，而**同一个对象调用hashCode()方法时**，是应该返回相同的值的！

 

## 十一、与Java集合框架相关的有哪些最好的实践

1. **根据需要**确定集合的类型。如果是单列的集合，我们考虑用Collection下的子接口ArrayList和Set。如果是映射，我们就考虑使用Map~
2. 确定完我们的集合类型，我们接下来**确定使用该集合类型下的哪个子类**~我认为可以简单分成几个步骤：
   - 是否需要同步
     - 去找线程安全的集合类使用
   - 迭代时是否需要有序(插入顺序有序)
     - 去找Linked双向列表结构的
   - 是否需要排序(自然顺序或者手动排序)
     - 去找Tree红黑树类型的(JDK1.8) 
3. 估算存放集合的数据量有多大，无论是List还是Map，它们实现动态增长，都是有性能消耗的。在初始集合的时候给出一个**合理的容量**会减少动态增长时的消耗~
4. **使用泛型**，避免在运行时出现ClassCastException
5. 尽可能使用Collections工具类，或者获取只读、同步或空的集合，**而非编写自己的实现**。它将会提供代码重用性，它有着更好的稳定性和可维护性

## 十二、ArrayList集合加入1万条数据，应该怎么提高效率

ArrayList的默认初始容量为10，要插入大量数据的时候需要不断扩容，而扩容是非常影响性能的。因此，现在明确了10万条数据了，我们可以**直接在初始化的时候就设置ArrayList的容量**！

这样就可以提高效率了~