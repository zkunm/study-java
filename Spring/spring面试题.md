# IOC再回顾和面试题

## 一、Spring IOC全面认知

### 1.1IOC和DI概述

在《精通Spring4.x 企业应用开发实战》中对IOC的定义是这样的：

> IoC(Inversion of Control)控制反转，包含了两个方面：一、控制。二、反转

我们可以简单认为：

- 控制指的是：**当前对象对内部成员的控制权**。
- 反转指的是：这种控制权**不由当前对象管理**了，由其他(类,第三方容器)来管理。

> IOC不够开门见山，于是Martin Fowler提出了DI(dependency injection)来替代IoC，即让调用类对某一接口实现类的依赖关系由第三方(容器或协作类)注入，以移除调用类对某一接口实现类的依赖。

在《Spring 实战 (第4版)》中并没有提及到IOC，而是直接来说DI的：

> 通过DI，对象的依赖关系将由系统中负责协调各对象的第三方组件在创建对象的时候进行设定，对象无需自行创建或管理它们的依赖关系，依赖关系将被自动注入到需要它们的对象当中去

从书上我们也可以发现：IoC和DI的定义(区别)并不是如此容易就可以说得清楚的了。这里我就**简单摘抄**一下：

- IoC(思想，设计模式)主要的实现方式有两种：依赖查找，**依赖注入**。
- 依赖注入是一种更可取的方式(实现的方式)

对我们而言，其实也没必要分得那么清，混合一谈也不影响我们的理解...

其实所谓的IOC容器就是一个大工厂第三方容器

使用IOC的好处(知乎@Intopass的回答)：

1. 不用自己组装，拿来就用。
2. 享受单例的好处，效率高，不浪费空间。
3. 便于单元测试，方便切换mock组件。
4. 便于进行AOP操作，对于使用者是透明的。
5. 统一配置，便于修改。

参考资料：

- https://www.zhihu.com/question/23277575--Spring IoC有什么好处呢？

### 1.2IOC容器的原理

从上面就已经说了：IOC容器其实就是一个大工厂，它用来管理我们所有的对象以及依赖关系。

- 原理就是通过Java的**反射技术**来实现的！通过反射我们可以获取类的所有信息(成员变量、类名等等等)！
- 再通过配置文件(xml)或者注解来**描述**类与类之间的关系
- 我们就可以通过这些配置信息和反射技术来**构建**出对应的对象和依赖关系了！

上面描述的技术只要学过点Java的都能说出来，这一下子可能就会被面试官问倒了，我们**简单**来看看实际Spring IOC容器是怎么实现对象的创建和依赖的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212160840.jpeg)

1. 根据Bean配置信息在容器内部创建Bean定义注册表
2. 根据注册表加载、实例化bean、建立Bean与Bean之间的依赖关系
3. 将这些准备就绪的Bean放到Map缓存池中，等待应用程序调用

Spring容器(Bean工厂)可简单分成两种：

- BeanFactory
  - 这是最基础、面向Spring的
- ApplicationContext
  - 这是在BeanFactory基础之上，面向使用Spring框架的开发者。提供了一系列的功能！

几乎所有的应用场合**都是**使用ApplicationContext！

BeanFactory的继承体系：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161047.png)

ApplicationContext的继承体系：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161232.png)

其中在ApplicationContext子类中又有一个比较重要的：WebApplicationContext

 

专门为Web应用准备的

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161236.png)

Web应用与Spring融合：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161242.png)

我们看看BeanFactory的生命周期：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161246.png)

接下来我们再看看ApplicationContext的生命周期：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161250.png)

初始化的过程都是比较长，我们可以**分类**来对其进行解析：

- **Bean自身的方法**：如调用 Bean 构造函数实例化 Bean，调用 Setter 设置 Bean 的属性值以及通过的 init-method 和 destroy-method 所指定的方法； 
- **Bean级生命周期接口方法**：如 BeanNameAware、 BeanFactoryAware、 InitializingBean 和 DisposableBean，这些接口方法由 Bean 类直接实现； 
- **容器级生命周期接口方法**：在上图中带“★” 的步骤是由 InstantiationAwareBean PostProcessor 和 BeanPostProcessor 这两个接口实现，一般称它们的实现类为“ **后处理器**” 。 后处理器接口一般不由 Bean 本身实现，它们独立于 Bean，实现类以容器附加装置的形式注册到Spring容器中并通过接口反射为Spring容器预先识别。当Spring 容器创建任何 Bean 的时候，这些后处理器都会发生作用，所以这些后处理器的影响是全局性的。当然，用户可以通过合理地编写后处理器，让其仅对感兴趣Bean 进行加工处理

ApplicationContext和BeanFactory**不同之处**在于：

- ApplicationContext会利用Java反射机制自动识别出配置文件中定义的BeanPostProcessor、 InstantiationAwareBeanPostProcesso 和BeanFactoryPostProcessor**后置器**，并**自动将它们注册到应用上**下文中。而BeanFactory需要在代码中通过**手工调用**`addBeanPostProcessor()`方法进行注册
- ApplicationContext在**初始化**应用上下文的时候**就实例化所有单实例的Bean**。而BeanFactory在初始化容器的时候并未实例化Bean，**直到**第一次访问某个Bean时**才**实例化目标Bean。

有了上面的知识点了，我们再来**详细**地看看Bean的初始化过程：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161253.jpeg)

简要总结：

- BeanDefinitionReader**读取Resource所指向的配置文件资源**，然后解析配置文件。配置文件中每一个`<bean>`解析成一个**BeanDefinition对象**，并**保存**到BeanDefinitionRegistry中；
- 容器扫描BeanDefinitionRegistry中的BeanDefinition；调用InstantiationStrategy**进行Bean实例化的工作**；使用**BeanWrapper完成Bean属性的设置**工作；
- 单例Bean缓存池：Spring 在DefaultSingletonBeanRegistry类中提供了一个用于缓存单实例 Bean 的**缓存器**，它是一个用HashMap实现的缓存器，单实例的Bean**以beanName为键保存在这个HashMap**中。

### 1.3IOC容器装配Bean

#### 1.3.1装配Bean方式

Spring4.x开始IOC容器装配Bean有**4种**方式：

- XML配置
- 注解
- JavaConfig
- 基于Groovy DSL配置(这种很少见)

总的来说：我们以XML配置+注解来装配Bean得多，其中**注解这种方式占大部分**！

#### 1.3.2依赖注入方式

依赖注入的方式有3种方式：

- **属性注入**-->通过`setter()`方法注入
- 构造函数注入
- 工厂方法注入

总的来说使用**属性注入**是比较灵活和方便的，这是大多数人的选择！

#### 1.3.3对象之间关系

`<bean>`对象之间有三种关系：

- 依赖-->挺少用的(使用depends-on就是依赖关系了-->前置依赖【依赖的Bean需要初始化之后，当前Bean才会初始化】)
- 继承-->可能会用到(指定abstract和parent来实现继承关系)
- 引用-->最常见(使用ref就是引用关系了)

#### 1.3.4Bean的作用域

Bean的作用域：

- 单例Singleton
- 多例prototype
- 与Web应用环境相关的Bean作用域
  - reqeust
  - session

使用到了Web应用环境相关的Bean作用域的话，是需要我们**手动配置代理**的~

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161258.png)

原因也很简单：因为我们默认的Bean是单例的，为了适配Web应用环境相关的Bean作用域--->每个request都需要一个对象，此时我们**返回一个代理对象**出去就可以完成我们的需求了！

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161300.png)

------

将Bean配置单例的时候还有一个问题：

- 如果我们的Bean配置的是单例，而Bean对象里边的**成员对象我们希望是多例的话**。那怎么办呢？？
- 默认的情况下我们的Bean单例，返回的成员对象也默认是单例的(因为对象就只有那么一个)！

此时我们需要用到了`lookup`方法注入，使用也很简单，看看例子就明白了：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161303.png)

#### 1.3.6处理自动装配的歧义性

昨天在刷书的时候刚好看到了有人在知乎邀请我回答这个问题：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161306.png)

结合两本书的知识点，可以归纳成两种解决方案：

- 使用`@Primary`注解设置为**首选**的注入Bean
- 使用`@Qualifier`注解设置**特定名称的Bean**来限定注入！
  - 也可以使用自定义的注解来标识	

#### 1.3.7引用属性文件以及Bean属性

之前在写配置文件的时候都是直接将我们的数据库配置信息在里面写死的了：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161308.png)

其实我们有**更优雅的做法**：将这些配置信息写到配置文件上(因为这些配置信息很可能是会变的，而且有可能被多个配置文件引用).

- 如此一来，我们**改的时候就十分方便**了。

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161310.png)

引用配置文件的数据使用的是`${}`

除了引用配置文件上的数据，我们还可以**引用Bean的属性**：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161312.png)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161314.png)

引用Bean的属性使用的是`#{}`

在这种技术在《Spring 实战 第四版》称之为Spring EL，跟我们之前学过的EL表达式是类似的。主要的功能就是上面的那种，想要更深入了解可参考下面的链接：

- http://www.cnblogs.com/leiOOlei/p/3543222.html

#### 1.3.8组合配置文件

xml文件之间组合：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161317.png)

xml和javaconfig互相组合的方式：

```
  public static void main(String[] args) {
    
        //1.通过构造函数加载配置类
         ApplicationContext ctx = new AnnotationConfigApplicationContext(AppConf.class);

        //2.通过编码方式注册配置类
     AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext();
     ctx.register(DaoConfig.class);
     ctx.register(ServiceConfig.class);
     ctx.refresh();

        //3.通过XML组装@Configuration配置类所提供的配置信息
     ApplicationContext ctx = new ClassPathXmlApplicationContext("com/smart/conf/beans2.xml");

        //4.通过@Configuration组装XML配置所提供的配置信息
     ApplicationContext ctx = new AnnotationConfigApplicationContext(LogonAppConfig.class);

     //5.@Configuration的配置类相互引用
     ApplicationContext ctx = new AnnotationConfigApplicationContext(DaoConfig.class,ServiceConfig.class);
         LogonService logonService = ctx.getBean(LogonService.class);
         System.out.println((logonService.getLogDao() !=null));
         logonService.printHelllo();   
  }
```

第一种的例子：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161320.png)

第二种的例子：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161322.png)

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161324.png)

第三种的例子：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161326.png)

第四种的例子：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161328.png)

 

#### 1.3.9装配Bean总结

总的来说，Spring IOC容器就是在创建Bean的时候有很多的方式给了我们实现，其中也包括了很多关于Bean的配置~

对于Bean相关的注入教程代码和简化配置(p和c名称空间)我就不一一说明啦，你们去看[Spring入门这一篇就够了](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247483942&idx=1&sn=f71e1adeeaea3430dd989ef47cf9a0b3&chksm=ebd74327dca0ca3141c8636e95d41629843d2623d82be799cf72701fb02a665763140b480aec#rd)和[Spring【依赖注入】就是这么简单](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247483946&idx=1&sn=bb21dfd83cf51214b2789c9ae214410f&chksm=ebd7432bdca0ca3ded6ad9b50128d29267f1204bf5722e5a0501a1d38af995c1ee8e37ae27e7#rd)就行了。

总的对比图：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161330.png) ![img](https://user-gold-cdn.xitu.io/2018/5/22/16387d35177cc21a?w=715&h=693&f=png&s=178450)

分别的应用场景：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161332.png)

至于一些小的知识点：

- 方法替换
  - 使用某个Bean的方法替换成另一个Bean的方法
- 属性编辑器
  - Spring可以对基本类型做转换就归结于属性编辑器的功劳！
- 国际化
  - 使用不同语言(英语、中文)的操作系统去显式不同的语言
- profile与条件化的Bean
  - 满足了某个条件才初始化Bean，这可以方便切换生产环境和开发环境~
- 容器事件
  - 类似于我们的Servlet的监听器，只不过它是在Spring中实现了~

上面这些小知识点比较少情况会用到，这也不去讲解啦。知道有这么一回事，到时候查查就会用啦~~~

## 二、Spring IOC相关面试题

将SpringIOC相关知识点整理了一遍，要想知道哪些知识点是比较重要的。很简单，我们去找找相关的面试题就知道了，如果该面试题是常见的，那么说明这个知识点还是相对比较重要的啦！

以下的面试题从各种博客上摘抄下来，摘抄量较大的会注明出处的~

### 2.1什么是spring?

> 什么是spring?

Spring 是个java企业级应用的开源开发框架。Spring主要用来开发Java应用，但是有些扩展是针对构建J2EE平台的web应用。Spring框架**目标是简化Java企业级应用开发**，并通过POJO为基础的编程模型促进良好的编程习惯。

### 2.2使用Spring框架的好处是什么？

> 使用Spring框架的好处是什么？

- **轻量**：Spring 是轻量的，基本的版本大约2MB。
- **控制反转**：Spring通过控制反转实现了松散耦合，对象们给出它们的依赖，而不是创建或查找依赖的对象们。
- **面向切面的编程**(AOP)：Spring支持面向切面的编程，并且把应用业务逻辑和系统服务分开。
- **容器**：Spring 包含并管理应用中对象的生命周期和配置。
- **MVC框架**：Spring的WEB框架是个精心设计的框架，是Web框架的一个很好的替代品。
- **事务管理**：Spring 提供一个持续的事务管理接口，可以扩展到上至本地事务下至全局事务（JTA）。
- **异常处理**：Spring 提供方便的API把具体技术相关的异常（比如由JDBC，Hibernate or JDO抛出的）转化为一致的unchecked 异常。

### 2.3Spring由哪些模块组成?

> Spring由哪些模块组成?

简单可以分成6大模块：

- Core
- AOP
- ORM
- DAO
- Web
- Spring EE

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161337.png)

### 2.4BeanFactory 实现举例

> BeanFactory 实现举例

Bean工厂是工厂模式的一个实现，提供了控制反转功能，**用来把应用的配置和依赖从正真的应用代码中分离**。

在spring3.2之前最常用的是XmlBeanFactory的，但现在被废弃了，取而代之的是：XmlBeanDefinitionReader和DefaultListableBeanFactory

### 2.5什么是Spring的依赖注入？

> 什么是Spring的依赖注入？

依赖注入，是IOC的一个方面，是个通常的概念，它有多种解释。这概念是说你不用创建对象，而只需要描述它如何被创建。你**不在代码里直接组装你的组件和服务，但是要在配置文件里描述哪些组件需要哪些服务**，之后一个容器（IOC容器）负责把他们组装起来。

### 2.6有哪些不同类型的IOC（依赖注入）方式？

> 有哪些不同类型的IOC（依赖注入）方式？

- **构造器依赖注入**：构造器依赖注入通过容器触发一个类的构造器来实现的，该类有一系列参数，每个参数代表一个对其他类的依赖。
- **Setter方法注入**：Setter方法注入是容器通过调用无参构造器或无参static工厂 方法实例化bean之后，调用该bean的setter方法，即实现了基于setter的依赖注入。
- 工厂注入：这个是遗留下来的，很少用的了！

### 2.7哪种依赖注入方式你建议使用，构造器注入，还是 Setter方法注入？

> 哪种依赖注入方式你建议使用，构造器注入，还是 Setter方法注入？

你两种依赖方式都可以使用，构造器注入和Setter方法注入。最好的解决方案是**用构造器参数实现强制依赖，setter方法实现可选依赖**。

### 2.8什么是Spring beans?

> 什么是Spring beans?

Spring beans 是那些**形成Spring应用的主干的java对象**。它们被Spring IOC容器初始化，装配，和管理。这些beans通过容器中配置的元数据创建。比如，以XML文件中`<bean/>`的形式定义。

这里有四种重要的方法给Spring容器**提供配置元数据**。

- XML配置文件。
- 基于注解的配置。
- 基于java的配置。
- Groovy DSL配置

### 2.9解释Spring框架中bean的生命周期

> 解释Spring框架中bean的生命周期

- Spring容器 从XML 文件中读取bean的定义，并实例化bean。
- Spring根据bean的定义填充所有的属性。
- 如果bean实现了BeanNameAware 接口，Spring 传递bean 的ID 到 setBeanName方法。
- 如果Bean 实现了 BeanFactoryAware 接口， Spring传递beanfactory 给setBeanFactory 方法。
- 如果有任何与bean相关联的BeanPostProcessors，Spring会在postProcesserBeforeInitialization()方法内调用它们。
- 如果bean实现IntializingBean了，调用它的afterPropertySet方法，如果bean声明了初始化方法，调用此初始化方法。
- 如果有BeanPostProcessors 和bean 关联，这些bean的postProcessAfterInitialization() 方法将被调用。
- 如果bean实现了 DisposableBean，它将调用destroy()方法。

### 2.10解释不同方式的自动装配

> 解释不同方式的自动装配

- no：默认的方式是不进行自动装配，通过显式设置ref 属性来进行装配。
- byName：通过参数名 自动装配，Spring容器在配置文件中发现bean的autowire属性被设置成byname，之后容器试图匹配、装配和该bean的属性具有相同名字的bean。
- byType:：通过参数类型自动装配，Spring容器在配置文件中发现bean的autowire属性被设置成byType，之后容器试图匹配、装配和该bean的属性具有相同类型的bean。如果有多个bean符合条件，则抛出错误。
- constructor：这个方式类似于byType， 但是要提供给构造器参数，如果没有确定的带参数的构造器参数类型，将会抛出异常。
- autodetect：首先尝试使用constructor来自动装配，如果无法工作，则使用byType方式。

只用注解的方式时，**注解默认是使用byType的**！

### 2.11IOC的优点是什么？

> IOC的优点是什么？

IOC 或 依赖注入把应用的代码量降到最低。它使应用容易测试，单元测试不再需要单例和JNDI查找机制。**最小的代价和最小的侵入性使松散耦合得以实现**。IOC容器支持加载服务时的**饿汉式初始化和懒加载**。

### 2.12哪些是重要的bean生命周期方法？ 你能重载它们吗？

> 哪些是重要的bean生命周期方法？ 你能重载它们吗？

有两个重要的bean 生命周期方法，第一个是`setup`， 它是在容器加载bean的时候被调用。第二个方法是 `teardown` 它是在容器卸载类的时候被调用。

The bean 标签有两个重要的属性（`init-method`和`destroy-method`）。用它们你可以自己定制初始化和注销方法。它们也有相应的注解（`@PostConstruct`和`@PreDestroy`）。

### 2.13怎么回答面试官：你对Spring的理解？

> 怎么回答面试官：你对Spring的理解？

来源：

- https://www.zhihu.com/question/48427693?sort=created

下面我就截几个答案：

一、

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161342.png)

二、

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161345.png)

### 2.14Spring框架中的单例Beans是线程安全的么？

> Spring框架中的单例Beans是线程安全的么？

Spring框架并没有对单例bean进行任何多线程的封装处理。关于单例bean的线程安全和并发问题需要开发者自行去搞定。但实际上，大部分的Spring bean并没有可变的状态(比如Serview类和DAO类)，所以在某种程度上说Spring的单例bean是线程安全的。**如果你的bean有多种状态的话**（比如 View Model 对象），就**需要自行保证线程安全**。

最浅显的解决办法就是将多态bean的作用域由“singleton”变更为“prototype”

### 2.15FileSystemResource和ClassPathResource有何区别？

> FileSystemResource和ClassPathResource有何区别？

在FileSystemResource 中需要给出spring-config.xml文件在你项目中的相对路径或者绝对路径。在ClassPathResource中spring会在ClassPath中自动搜寻配置文件，所以要把ClassPathResource文件放在ClassPath下。

如果将spring-config.xml保存在了src文件夹下的话，只需给出配置文件的名称即可，因为src文件夹是默认。

简而言之，**ClassPathResource在环境变量中读取配置文件，FileSystemResource在配置文件中读取配置文件**。

# AOP再回顾

## 一、Spring AOP全面认知

### 1.1AOP概述

AOP称为面向切面编程，那我们怎么理解面向切面编程？？

我们可以先看看下面这段代码：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161349.png)

我们学Java面向对象的时候，如果代码重复了怎么办啊？？可以分成下面几个步骤：

- 1：抽取成方法
- 2：抽取类

抽取成类的方式我们称之为：**纵向抽取**

- 通过继承的方式实现纵向抽取

但是，我们现在的办法不行：即使抽取成类还是会出现重复的代码，因为这些逻辑(开始、结束、提交事务)**依附在我们业务类的方法逻辑中**！

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161352.png)

现在纵向抽取的方式不行了，AOP的理念：就是将**分散在各个业务逻辑代码中相同的代码通过横向切割的方式**抽取到一个独立的模块中！

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161354.png)

上面的图也很清晰了，将重复性的逻辑代码横切出来其实很容易(我们简单可认为就是封装成一个类就好了)，但我们要将这些**被我们横切出来的逻辑代码融合到业务逻辑中**，来完成和之前(没抽取前)一样的功能！这就是AOP首要解决的问题了！

### 1.2Spring AOP原理

> 被我们横切出来的逻辑代码融合到业务逻辑中，来完成和之前(没抽取前)一样的功能

没有学Spring AOP之前，我们就可以使用代理来完成。

- 如果看过我写的[给女朋友讲解什么是代理模式](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484222&idx=1&sn=5191aca33f7b331adaef11c5e07df468&chksm=ebd7423fdca0cb29cdc59b4c79afcda9a44b9206806d2212a1b807c9f5879674934c37c250a1#rd)这篇文章的话，一定就不难理解上面我说的那句话了
- 代理能干嘛？代理可以帮我们**增强对象的行为**！使用动态代理实质上就是**调用时拦截对象方法，对方法进行改造、增强**！

其实Spring AOP的底层原理就是**动态代理**！

来源《精通Spring4.x 企业应用开发实战》一段话：

> Spring AOP使用纯Java实现，它不需要专门的编译过程，也不需要特殊的类装载器，它在**运行期通过代理方式向目标类织入增强代码**。在Spring中可以无缝地将Spring AOP、IoC和AspectJ整合在一起。

来源《Spring 实战 (第4版)》一句话：

> Spring AOP构建在动态代理基础之上，因此，**Spring对AOP的支持局限于方法拦截**。

在Java中动态代理有**两种**方式：

- JDK动态代理
- CGLib动态代理

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161357.png)

JDK动态代理是需要实现某个接口了，而我们类未必全部会有接口，于是CGLib代理就有了~~

- CGLib代理其生成的动态代理对象是目标类的子类
- Spring AOP**默认是使用JDK动态代理**，如果代理的类**没有接口则会使用CGLib代理**。

那么JDK代理和CGLib代理我们该用哪个呢？？在《精通Spring4.x 企业应用开发实战》给出了建议：

- 如果是**单例的我们最好使用CGLib代理**，如果是多例的我们最好使用JDK代理

原因：

- JDK在创建代理对象时的性能要高于CGLib代理，而生成代理对象的运行性能却比CGLib的低。
- 如果是单例的代理，推荐使用CGLib

看到这里我们就应该知道什么是Spring AOP(面向切面编程)了：**将相同逻辑的重复代码横向抽取出来，使用动态代理技术将这些重复代码织入到目标对象方法中，实现和原来一样的功能**。

- 这样一来，我们就在**写业务时只关心业务代码**，而不用关心与业务无关的代码

### 1.3AOP的实现者

AOP除了有Spring AOP实现外，还有著名的AOP实现者：AspectJ，也有可能大家没听说过的实现者：JBoss AOP~~

我们下面来说说AspectJ扩展一下知识面：

> AspectJ是**语言级别**的AOP实现，扩展了Java语言，定义了AOP语法，能够在**编译期**提供横切代码的织入，所以它有**专门的编译器**用来生成遵守Java字节码规范的Class文件。

而Spring借鉴了AspectJ很多非常有用的做法，**融合了AspectJ实现AOP的功能**。但Spring AOP本质上**底层还是动态代理**，所以Spring AOP是不需要有专门的编辑器的~

### 1.4AOP的术语

嗯，AOP搞了好几个术语出来~~两本书都有讲解这些术语，我会尽量让大家看得明白的：

**连接点**(Join point)：

- **能够被拦截的地方**：Spring AOP是基于动态代理的，所以是方法拦截的。每个成员方法都可以称之为连接点~

**切点**(Poincut)：

- **具体定位的连接点**：上面也说了，每个方法都可以称之为连接点，我们**具体定位到某一个方法就成为切点**。

**增强/通知**(Advice)：

- 表示添加到切点的一段**逻辑代码**，并定位连接点的**方位信息**。
  - 简单来说就定义了是干什么的，具体是在哪干
  - Spring AOP提供了5种Advice类型给我们：前置、后置、返回、异常、环绕给我们使用！

**织入**(Weaving)：

- 将`增强/通知`添加到目标类的具体连接点上的过程。

**引入/引介**(Introduction)：

- `引入/引介`允许我们**向现有的类添加新方法或属性**。是一种**特殊**的增强！

**切面**(Aspect)：

- 切面由切点和`增强/通知`组成，它既包括了横切逻辑的定义、也包括了连接点的定义。

在《Spring 实战 (第4版)》给出的总结是这样子的：

> 通知/增强包含了需要用于多个应用对象的横切行为；连接点是程序执行过程中能够应用通知的所有点；切点定义了通知/增强被应用的具体位置。其中关键的是切点定义了哪些连接点会得到通知/增强。

总的来说：

- 这些术语可能翻译过来不太好理解，但对我们正常使用AOP的话**影响并没有那么大**~~看多了就知道它是什么意思了。

### 1.5Spring对AOP的支持

Spring提供了3种类型的AOP支持：

- 基于代理的经典SpringAOP
  - 需要实现接口，手动创建代理
- 纯POJO切面
  - 使用XML配置，aop命名空间
- `@AspectJ`注解驱动的切面
  - 使用注解的方式，这是最简洁和最方便的！

## 二、基于代理的经典SpringAOP

这部分配置比较麻烦，用起来也很麻烦，这里我就主要整理一下书上的内容，大家看看了解一下吧，我们实际上使用Spring AOP基本不用这种方式了！

 

首先，我们来看一下增强接口的继承关系图：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161401.png)

可以分成**五类**增强的方式：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161404.png)

Spring提供了**六种的切点类型**：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161406.png)

**切面类型主要分成了三种**：

- **一般切面**
- **切点切面**
- **引介/引入切面**

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161408.png)

一般切面，切点切面，引介/引入切面介绍：

![img](https://user-gold-cdn.xitu.io/2018/5/24/1639259f27c9deaf?w=755&h=190&f=png&s=62774) ![img](https://user-gold-cdn.xitu.io/2018/5/24/1639259f334512f0?w=741&h=89&f=png&s=25335)

对于切点切面我们一般都是直接用就好了，我们来看看引介/引入切面是怎么一回事：

- 引介/引入切面是引介/引入增强的封装器，通过引介/引入切面，**可以更容易地为现有对象添加任何接口的实现**！

继承关系图：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161411.png)

引介/引入切面有两个实现类：

- DefaultIntroductionAdvisor：常用的实现类
- DeclareParentsAdvisor：用于实现AspectJ语言的DeclareParent注解表示的引介/引入切面

 

实际上，我们使用AOP往往是**Spring内部使用BeanPostProcessor帮我们创建代理**。

这些代理的创建器可以分成三类：

- 基于Bean配置名规则的自动代理创建器：BeanNameAutoProxyCreator
- 基于Advisor匹配机制的自动代理创建器：它会对容器所有的Advisor进行扫描，实现类为DefaultAdvisorAutoProxyCreator
- 基于Bean中的AspectJ注解标签的自动代理创建器：AnnotationAwareAspectJAutoProxyCreator

对应的类继承图：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161414.png)

嗯，基于代理的经典SpringAOP就讲到这里吧，其实我是不太愿意去写这个的，因为已经几乎不用了，在《Spring 实战 第4版》也没有这部分的知识点了。

- 但是通过这部分的知识点可以**更加全面地认识Spring AOP的各种接口**吧~

## 三、拥抱基于注解和命名空的AOP编程

Spring在新版本中对AOP功能进行了增强，体现在这么几个方面：

- 在XML配置文件中为AOP提供了aop命名空间
- 增加了AspectJ切点表达式语言的支持
- 可以无缝地集成AspectJ

那我们使用`@AspectJ`来玩AOP的话，学什么？？其实也就是上面的内容，学如何设置切点、创建切面、增强的内容是什么...

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161416.png)

具体的切点表达式使用还是前往：[Spring【AOP模块】就这么简单](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247483954&idx=1&sn=b34e385ed716edf6f58998ec329f9867&chksm=ebd74333dca0ca257a77c02ab458300ef982adff3cf37eb6d8d2f985f11df5cc07ef17f659d4#rd)看吧~~

对应的增强注解：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161419.png)

![img](https://user-gold-cdn.xitu.io/2018/5/24/1639259f85f3f536?w=721&h=378&f=png&s=78849)

### 3.1使用引介/引入功能实现为Bean引入新方法

其实前置啊、后置啊这些很容易就理解了，整篇文章看下来就只有这个引介/引入切面有点搞头。于是我们就来玩玩吧~

我们来看一下具体的用法吧，现在我有个服务员的接口：

```
public interface Waiter {

    // 向客人打招呼
    void greetTo(String clientName);

    // 服务
    void serveTo(String clientName);
}

```

一位年轻服务员实现类：

```
public class NaiveWaiter implements Waiter {
    public void greetTo(String clientName) {
        System.out.println("NaiveWaiter:greet to " + clientName + "...");
    }

    @NeedTest
    public void serveTo(String clientName) {
        System.out.println("NaiveWaiter:serving " + clientName + "...");
    }

}

```

现在我想做的就是：**想这个服务员可以充当售货员的角色，可以卖东西**！当然了，我肯定不会加一个卖东西的方法到Waiter接口上啦，因为这个是暂时的~

所以，我搞了一个售货员接口：

```
public interface Seller {

  // 卖东西
  int sell(String goods, String clientName);
}
```

一个售货员实现类：

```
public class SmartSeller implements Seller {

  // 卖东西
  public int sell(String goods,String clientName) {
    System.out.println("SmartSeller: sell "+goods +" to "+clientName+"...");
    return 100;
  }
  
}
```

此时，我们的类图是这样子的：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161423.png)

现在我想干的就是：**借助AOP的引入/引介切面，来让我们的服务员也可以卖东西**！

我们的引入/引介切面具体是这样干的：

```
@Aspect
public class EnableSellerAspect {
    
    @DeclareParents(value = "com.smart.NaiveWaiter",  // 指定服务员具体的实现
            defaultImpl = SmartSeller.class) // 售货员具体的实现
    public Seller seller; // 要实现的目标接口
    
}
```

写了这个切面类会发生什么？？

- 切面技术将SmartSeller融合到NaiveWaiter中，这样**NaiveWaiter就实现了Seller接口**！！！！

是不是很神奇？？我也觉得很神奇啊，我们来测试一下：

我们的`bean.xml`文件很简单：

```
<?xml version="1.0" encoding="UTF-8" ?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:aop="http://www.springframework.org/schema/aop"
  xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.0.xsd
           http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-4.0.xsd">
    <aop:aspectj-autoproxy/>
  <bean id="waiter" class="com.smart.NaiveWaiter"/>
  <bean class="com.smart.aspectj.basic.EnableSellerAspect"/>
</beans>
```

测试一下：

```
public class Test {
    public static void main(String[] args) {


        ClassPathXmlApplicationContext ctx = new ClassPathXmlApplicationContext("com/smart/aspectj/basic/beans.xml");
        Waiter waiter = (Waiter) ctx.getBean("waiter");

        // 调用服务员原有的方法
        waiter.greetTo("Java3y");
        waiter.serveTo("Java3y");

        // 通过引介/引入切面已经将waiter服务员实现了Seller接口，所以可以强制转换
        Seller seller = (Seller) waiter;
        seller.sell("水军", "Java3y");

    }
}


```

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161427.png)

具体的调用过程是这样子的：

> 当引入接口方法被调用时，代理对象会把此调用委托给实现了新接口的某个其他对象。实际上，一个Bean的实现被拆分到多个类中

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161429.png)

### 3.2在XML中声明切面

我们知道注解很方便，**但是**，要想使用**注解的方式**使用Spring AOP就**必须要有源码**(因为我们要在切面类上添加注解)。如果没有源码的话，我们就得使用XML来声明切面了~

 

其实就跟注解差不多的功能：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161432.png)

我们就直接来个例子终结掉它吧：

首先我们来测试一下与传统的SpringAOP结合的advisor是怎么用的：

实现类：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161435.png)

xml配置文件：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161439.png)

.......

一个一个来讲解还是太花时间了，我就一次性用图的方式来讲啦：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161443.png)

最后还有一个切面类型总结图，看完就几乎懂啦：

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212161445.png)

## 四、总结

看起来AOP有很多很多的知识点，其实我们只要记住AOP的核心概念就行啦。

下面是我的简要总结AOP：

- AOP的底层实际上是动态代理，动态代理分成了JDK动态代理和CGLib动态代理。如果被代理对象没有接口，那么就使用的是CGLIB代理(也可以直接配置使用CBLib代理)
- 如果是单例的话，那我们最好使用CGLib代理，因为CGLib代理对象运行速度要比JDK的代理对象要快
- AOP既然是基于动态代理的，那么它只能对方法进行拦截，它的层面上是方法级别的
- 无论经典的方式、注解方式还是XML配置方式使用Spring AOP的原理都是一样的，只不过形式变了而已。一般我们使用注解的方式使用AOP就好了。
- 注解的方式使用Spring AOP就了解几个切点表达式，几个增强/通知的注解就完事了，是不是贼简单...使用XML的方式和注解其实没有很大的区别，很快就可以上手啦。
- 引介/引入切面也算是一个比较亮的地方，可以用代理的方式为某个对象实现接口，从而能够使用借口下的方法。这种方式是非侵入式的~
- 要增强的方法还可以接收与被代理方法一样的参数、绑定被代理方法的返回值这些功能...

 