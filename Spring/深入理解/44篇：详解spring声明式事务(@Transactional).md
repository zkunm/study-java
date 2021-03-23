> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936892&idx=2&sn=473a156dc141a2efc0580f93567f0630&scene=21#wechat_redirect)

spring 事务有 2 种用法：**编程式事务和声明式事务**。

编程式事务[上一篇](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936779&idx=2&sn=a6255c7d436a62af380dfa6b326fd4e7&scene=21#wechat_redirect)文章中已经介绍了，不熟悉的建议先看一下编程式事务的用法。

这篇主要介绍声明式事务的用法，我们在工作中基本上用的都是声明式事务，所以这篇文章是比较重要的，建议各位打起精神，正式开始。

什么是声明式事务？
---------

所谓声明式事务，就是通过配置的方式，比如通过配置文件（xml）或者注解的方式，告诉 spring，哪些方法需要 spring 帮忙管理事务，然后开发者只用关注业务代码，而事务的事情 spring 自动帮我们控制。

比如注解的方式，只需在方法上面加一个`@Transaction`注解，那么方法执行之前 spring 会自动开启一个事务，方法执行完毕之后，会自动提交或者回滚事务，而方法内部没有任何事务相关代码，用起来特别的方法。

```
@Transaction
public void insert(String userName){
    this.jdbcTemplate.update("insert into t_user (name) values (?)", userName);
}


```

声明式事务的 2 种实现方式
--------------

1.  **配置文件的方式**，即在 spring xml 文件中进行统一配置，开发者基本上就不用关注事务的事情了，代码中无需关心任何和事务相关的代码，一切交给 spring 处理。
    
2.  **注解的方式**，只需在需要 spring 来帮忙管理事务的方法上加上 @Transaction 注解就可以了，注解的方式相对来说更简洁一些，都需要开发者自己去进行配置，可能有些同学对 spring 不是太熟悉，所以配置这个有一定的风险，做好代码 review 就可以了。
    

配置文件的方式这里就不讲了，用的相对比较少，我们主要掌握注解的方式如何使用，就可以了。

声明式事务注解方式 5 个步骤
---------------

#### 1、启用 Spring 的注释驱动事务管理功能

在 spring 配置类上加上`@EnableTransactionManagement`注解

```
@EnableTransactionManagement
public class MainConfig4 {
}


```

简要介绍一下原理：**当 spring 容器启动的时候，发现有 @EnableTransactionManagement 注解，此时会拦截所有 bean 的创建，扫描看一下 bean 上是否有 @Transaction 注解（类、或者父类、或者接口、或者方法中有这个注解都可以），如果有这个注解，spring 会通过 aop 的方式给 bean 生成代理对象，代理对象中会增加一个拦截器，拦截器会拦截 bean 中 public 方法执行，会在方法执行之前启动事务，方法执行完毕之后提交或者回滚事务。稍后会专门有一篇文章带大家看这块的源码。**

如果有兴趣的可以自己先去读一下源码，主要是下面这个这方法会

```
org.springframework.transaction.interceptor.TransactionInterceptor#invoke


```

再来看看 EnableTransactionManagement 的源码

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import(TransactionManagementConfigurationSelector.class)
public @interface EnableTransactionManagement {

 /**
  * spring是通过aop的方式对bean创建代理对象来实现事务管理的
  * 创建代理对象有2种方式，jdk动态代理和cglib代理
  * proxyTargetClass：为true的时候，就是强制使用cglib来创建代理
  */
 boolean proxyTargetClass() default false;

 /**
  * 用来指定事务拦截器的顺序
  * 我们知道一个方法上可以添加很多拦截器，拦截器是可以指定顺序的
  * 比如你可以自定义一些拦截器，放在事务拦截器之前或者之后执行，就可以通过order来控制
  */
 int order() default Ordered.LOWEST_PRECEDENCE;
}


```

#### 2、定义事务管理器

事务交给 spring 管理，那么你肯定要创建一个或者多个事务管理者，有这些管理者来管理具体的事务，比如启动事务、提交事务、回滚事务，这些都是管理者来负责的。

spring 中使用 PlatformTransactionManager 这个接口来表示事务管理者。

PlatformTransactionManager 多个实现类，用来应对不同的环境

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06DycA80FqTHT8qgh8qibK8FcMSj5TG1WricHV7JcunbkPj9mTtNiaKOhKkddoKZmeEicXAPClCMWxqzaQ/640?wx_fmt=png)

**JpaTransactionManager**：如果你用 jpa 来操作 db，那么需要用这个管理器来帮你控制事务。

**DataSourceTransactionManager**：如果你用是指定数据源的方式，比如操作数据库用的是：JdbcTemplate、mybatis、ibatis，那么需要用这个管理器来帮你控制事务。

**HibernateTransactionManager**：如果你用 hibernate 来操作 db，那么需要用这个管理器来帮你控制事务。

**JtaTransactionManager**：如果你用的是 java 中的 jta 来操作 db，这种通常是分布式事务，此时需要用这种管理器来控制事务。

比如：我们用的是 mybatis 或者 jdbctemplate，那么通过下面方式定义一个事务管理器。

```
@Bean
public PlatformTransactionManager transactionManager(DataSource dataSource) {
    return new DataSourceTransactionManager(dataSource);
}


```

#### 3、需使用事务的目标上加 @Transaction 注解

*   @Transaction 放在接口上，那么接口的实现类中所有 public 都被 spring 自动加上事务
    
*   @Transaction 放在类上，那么当前类以及其下无限级子类中所有 pubilc 方法将被 spring 自动加上事务
    
*   @Transaction 放在 public 方法上，那么该方法将被 spring 自动加上事务
    
*   注意：**@Transaction 只对 public 方法有效**
    

下面我们看一下 @Transactional 源码：

```
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
@Documented
public @interface Transactional {

    /**
     * 指定事务管理器的bean名称，如果容器中有多事务管理器PlatformTransactionManager，
     * 那么你得告诉spring，当前配置需要使用哪个事务管理器
     */
    @AliasFor("transactionManager")
    String value() default "";

    /**
     * 同value，value和transactionManager选配一个就行，也可以为空，如果为空，默认会从容器中按照类型查找一个事务管理器bean
     */
    @AliasFor("value")
    String transactionManager() default "";

    /**
     * 事务的传播属性
     */
    Propagation propagation() default Propagation.REQUIRED;

    /**
     * 事务的隔离级别，就是制定数据库的隔离级别，数据库隔离级别大家知道么？不知道的可以去补一下
     */
    Isolation isolation() default Isolation.DEFAULT;

    /**
     * 事务执行的超时时间（秒），执行一个方法，比如有问题，那我不可能等你一天吧，可能最多我只能等你10秒
     * 10秒后，还没有执行完毕，就弹出一个超时异常吧
     */
    int timeout() default TransactionDefinition.TIMEOUT_DEFAULT;

    /**
     * 是否是只读事务，比如某个方法中只有查询操作，我们可以指定事务是只读的
     * 设置了这个参数，可能数据库会做一些性能优化，提升查询速度
     */
    boolean readOnly() default false;

    /**
     * 定义零(0)个或更多异常类，这些异常类必须是Throwable的子类，当方法抛出这些异常及其子类异常的时候，spring会让事务回滚
     * 如果不配做，那么默认会在 RuntimeException 或者 Error 情况下，事务才会回滚 
     */
    Class<? extends Throwable>[] rollbackFor() default {};

    /**
     * 和 rollbackFor 作用一样，只是这个地方使用的是类名
     */
    String[] rollbackForClassName() default {};

    /**
     * 定义零(0)个或更多异常类，这些异常类必须是Throwable的子类，当方法抛出这些异常的时候，事务不会回滚
     */
    Class<? extends Throwable>[] noRollbackFor() default {};

    /**
     * 和 noRollbackFor 作用一样，只是这个地方使用的是类名
     */
    String[] noRollbackForClassName() default {};

}


```

参数介绍

<table data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)"><thead data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)"><tr data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184184077="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">参数</th><th data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184184077="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">描述</th></tr></thead><tbody data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)"><tr data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">value</td><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">指定事务管理器的 bean 名称，如果容器中有多事务管理器 PlatformTransactionManager，那么你得告诉 spring，当前配置需要使用哪个事务管理器</td></tr><tr data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">transactionManager</td><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">同 value，value 和 transactionManager 选配一个就行，也可以为空，如果为空，默认会从容器中按照类型查找一个事务管理器 bean</td></tr><tr data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">propagation</td><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">事务的传播属性，下篇文章详细介绍</td></tr><tr data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">isolation</td><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">事务的隔离级别，就是制定数据库的隔离级别，数据库隔离级别大家知道么？不知道的可以去补一下</td></tr><tr data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">timeout</td><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">事务执行的超时时间（秒），执行一个方法，比如有问题，那我不可能等你一天吧，可能最多我只能等你 10 秒 10 秒后，还没有执行完毕，就弹出一个超时异常吧</td></tr><tr data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">readOnly</td><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是否是只读事务，比如某个方法中只有查询操作，我们可以指定事务是只读的 设置了这个参数，可能数据库会做一些性能优化，提升查询速度</td></tr><tr data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">rollbackFor</td><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">定义零 (0) 个或更多异常类，这些异常类必须是 Throwable 的子类，当方法抛出这些异常及其子类异常的时候，spring 会让事务回滚 如果不配做，那么默认会在 RuntimeException 或者 Error 情况下，事务才会回滚</td></tr><tr data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">rollbackForClassName</td><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">同 rollbackFor，只是这个地方使用的是类名</td></tr><tr data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">noRollbackFor</td><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184184077="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">定义零 (0) 个或更多异常类，这些异常类必须是 Throwable 的子类，当方法抛出这些异常的时候，事务不会回滚</td></tr><tr data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">noRollbackForClassName</td><td data-darkmode-color-16079184184077="rgb(163, 163, 163)" data-darkmode-original-color-16079184184077="rgb(0,0,0)" data-darkmode-bgcolor-16079184184077="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184184077="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">同 noRollbackFor，只是这个地方使用的是类名</td></tr></tbody></table>

#### 4、执行 db 业务操作

在 @Transaction 标注类或者目标方法上执行业务操作，此时这些方法会自动被 spring 进行事务管理。

如，下面的 insertBatch 操作，先删除数据，然后批量插入数据，方法上加上了 @Transactional 注解，此时这个方法会自动受 spring 事务控制，要么都成功，要么都失败。

```
@Component
public class UserService {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    //先清空表中数据，然后批量插入数据，要么都成功要么都失败
    @Transactional
    public void insertBatch(String... names) {
        jdbcTemplate.update("truncate table t_user");
        for (String name : names) {
            jdbcTemplate.update("INSERT INTO t_user(name) VALUES (?)", name);
        }
    }
}


```

#### 5、启动 spring 容器，使用 bean 执行业务操作

```
@Test
public void test1() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig4.class);
    context.refresh();

    UserService userService = context.getBean(UserService.class);
    userService.insertBatch("java高并发系列", "mysql系列", "maven系列", "mybatis系列");
}


```

案例 1
----

#### 准备数据库

```
DROP DATABASE IF EXISTS javacode2018;
CREATE DATABASE if NOT EXISTS javacode2018;

USE javacode2018;
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user(
  id int PRIMARY KEY AUTO_INCREMENT,
  name varchar(256) NOT NULL DEFAULT '' COMMENT '姓名'
);


```

#### spring 配置类

```
package com.javacode2018.tx.demo4;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.transaction.support.TransactionTemplate;

import javax.sql.DataSource;

@EnableTransactionManagement //@1
@Configuration
@ComponentScan
public class MainConfig4 {
    //定义一个数据源
    @Bean
    public DataSource dataSource() {
        org.apache.tomcat.jdbc.pool.DataSource dataSource = new org.apache.tomcat.jdbc.pool.DataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:3306/javacode2018?characterEncoding=UTF-8");
        dataSource.setUsername("root");
        dataSource.setPassword("root123");
        dataSource.setInitialSize(5);
        return dataSource;
    }

    //定义一个JdbcTemplate,用来执行db操作
    @Bean
    public JdbcTemplate jdbcTemplate(DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }

    //定义我一个事物管理器
    @Bean
    public PlatformTransactionManager transactionManager(DataSource dataSource) { //@2
        return new DataSourceTransactionManager(dataSource);
    }
}


```

**@1**：使用 @EnableTransactionManagement 注解开启 spring 事务管理

**@2**：定义事务管理器

#### 来个业务类

```
package com.javacode2018.tx.demo4;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Component
public class UserService {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    //先清空表中数据，然后批量插入数据，要么都成功要么都失败
    @Transactional //@1
    public int insertBatch(String... names) {
        int result = 0;
        jdbcTemplate.update("truncate table t_user");
        for (String name : names) {
            result += jdbcTemplate.update("INSERT INTO t_user(name) VALUES (?)", name);
        }
        return result;
    }

    //获取所有用户信息
    public List<Map<String, Object>> userList() {
        return jdbcTemplate.queryForList("SELECT * FROM t_user");
    }
}


```

**@1**：insertBatch 方法上加上了 @Transactional 注解，让 spring 来自动为这个方法加上事务

#### 测试类

```
package com.javacode2018.tx.demo4;

import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class Demo4Test {
    @Test
    public void test1() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(MainConfig4.class);
        context.refresh();

        UserService userService = context.getBean(UserService.class);
        //先执行插入操作
        int count = userService.insertBatch(
                "java高并发系列",
                "mysql系列",
                "maven系列",
                "mybatis系列");
        System.out.println("插入成功（条）：" + count);
        //然后查询一下
        System.out.println(userService.userList());
    }
}


```

#### 运行输出

```
插入成功（条）：4
[{id=1, name=java高并发系列}, {id=2, name=mysql系列}, {id=3, name=maven系列}, {id=4, name=mybatis系列}]


```

**有些朋友可能会问，如何知道这个被调用的方法有没有使用事务？** 下面我们就来看一下。

如何确定方法有没有用到 spring 事务
---------------------

### 方式 1：断点调试

spring 事务是由 TransactionInterceptor 拦截器处理的，最后会调用下面这个方法，设置个断点就可以看到详细过程了。

```
org.springframework.transaction.interceptor.TransactionAspectSupport#invokeWithinTransaction


```

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06DycA80FqTHT8qgh8qibK8FcUHIuVuXS60QgFdhA0QA2gs6LX3n1CgIeGtkRWKbqBAGnn927o1OqEA/640?wx_fmt=png)

### 方式 2：看日志

spring 处理事务的过程，有详细的日志输出，开启日志，控制台就可以看到事务的详细过程了。

#### 添加 maven 配置

```
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>1.2.3</version>
</dependency>


```

#### src\main\resources 新建 logback.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <appender >
        <encoder>
            <pattern>[%d{MM-dd HH:mm:ss.SSS}][%thread{20}:${PID:- }][%X{trace_id}][%level][%logger{56}:%line:%method\(\)]:%msg%n##########**********##########%n</pattern>
        </encoder>
    </appender>

    <logger >
        <appender-ref ref="STDOUT" />
    </logger>

</configuration>


```

再来运行一下案例 1

```
[09-10 11:20:38.830][main: ][][DEBUG][o.s.jdbc.datasource.DataSourceTransactionManager:370:getTransaction()]:Creating new transaction with name [com.javacode2018.tx.demo4.UserService.insertBatch]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT
##########**********##########
[09-10 11:20:39.120][main: ][][DEBUG][o.s.jdbc.datasource.DataSourceTransactionManager:265:doBegin()]:Acquired Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@65fe9e33]]] for JDBC transaction
##########**********##########
[09-10 11:20:39.125][main: ][][DEBUG][o.s.jdbc.datasource.DataSourceTransactionManager:283:doBegin()]:Switching JDBC Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@65fe9e33]]] to manual commit
##########**********##########
[09-10 11:20:39.139][main: ][][DEBUG][org.springframework.jdbc.core.JdbcTemplate:502:update()]:Executing SQL update [truncate table t_user]
##########**********##########
[09-10 11:20:39.169][main: ][][DEBUG][org.springframework.jdbc.core.JdbcTemplate:860:update()]:Executing prepared SQL update
##########**********##########
[09-10 11:20:39.169][main: ][][DEBUG][org.springframework.jdbc.core.JdbcTemplate:609:execute()]:Executing prepared SQL statement [INSERT INTO t_user(name) VALUES (?)]
##########**********##########
[09-10 11:20:39.234][main: ][][DEBUG][org.springframework.jdbc.core.JdbcTemplate:860:update()]:Executing prepared SQL update
##########**********##########
[09-10 11:20:39.235][main: ][][DEBUG][org.springframework.jdbc.core.JdbcTemplate:609:execute()]:Executing prepared SQL statement [INSERT INTO t_user(name) VALUES (?)]
##########**********##########
[09-10 11:20:39.236][main: ][][DEBUG][org.springframework.jdbc.core.JdbcTemplate:860:update()]:Executing prepared SQL update
##########**********##########
[09-10 11:20:39.237][main: ][][DEBUG][org.springframework.jdbc.core.JdbcTemplate:609:execute()]:Executing prepared SQL statement [INSERT INTO t_user(name) VALUES (?)]
##########**********##########
[09-10 11:20:39.238][main: ][][DEBUG][org.springframework.jdbc.core.JdbcTemplate:860:update()]:Executing prepared SQL update
##########**********##########
[09-10 11:20:39.239][main: ][][DEBUG][org.springframework.jdbc.core.JdbcTemplate:609:execute()]:Executing prepared SQL statement [INSERT INTO t_user(name) VALUES (?)]
##########**********##########
[09-10 11:20:39.241][main: ][][DEBUG][o.s.jdbc.datasource.DataSourceTransactionManager:741:processCommit()]:Initiating transaction commit
##########**********##########
[09-10 11:20:39.241][main: ][][DEBUG][o.s.jdbc.datasource.DataSourceTransactionManager:328:doCommit()]:Committing JDBC transaction on Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@65fe9e33]]]
##########**********##########
[09-10 11:20:39.244][main: ][][DEBUG][o.s.jdbc.datasource.DataSourceTransactionManager:387:doCleanupAfterCompletion()]:Releasing JDBC Connection [ProxyConnection[PooledConnection[com.mysql.jdbc.JDBC4Connection@65fe9e33]]] after transaction
##########**********##########
插入成功（条）：4
[09-10 11:20:39.246][main: ][][DEBUG][org.springframework.jdbc.core.JdbcTemplate:427:query()]:Executing SQL query [SELECT * FROM t_user]
##########**********##########
[09-10 11:20:39.247][main: ][][DEBUG][org.springframework.jdbc.datasource.DataSourceUtils:115:doGetConnection()]:Fetching JDBC Connection from DataSource
##########**********##########
[{id=1, name=java高并发系列}, {id=2, name=mysql系列}, {id=3, name=maven系列}, {id=4, name=mybatis系列}]


```

#### 来理解一下日志

insertBatch 方法上有 @Transaction 注解，所以会被拦截器拦截，下面是在 insertBatch 方法调用之前，创建了一个事务。

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06DycA80FqTHT8qgh8qibK8Fc9zId79ibd0bLYubrBDSWp1K2kKTdibic9gGSduYnfbIHcz6kArzLyOdoQ/640?wx_fmt=png)

insertBatch 方法上 @Transaction 注解参数都是默认值，@Transaction 注解中可以通过`value或者transactionManager`来指定事务管理器，但是没有指定，此时 spring 会在容器中按照事务管理器类型找一个默认的，刚好我们在 spring 容器中定义了一个，所以直接拿来用了。事务管理器我们用的是`new DataSourceTransactionManager(dataSource)`，从事务管理器的 datasource 中获取一个数据库连接，然后通过连接设置事务为手动提交，然后将（datasource-> 这个连接) 丢到 ThreadLocal 中了，具体为什么，可以看[上一篇](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936779&idx=2&sn=a6255c7d436a62af380dfa6b326fd4e7&scene=21#wechat_redirect)文章。

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06DycA80FqTHT8qgh8qibK8FceIH9ibJJLwO4xg7Mcvbq1DG6X3hKWAL4v2zibfhtRf4smh9OxuiaVgfrg/640?wx_fmt=png)

下面就正是进入 insertBatch 方法内部了，通过 jdbctemplate 执行一些 db 操作，jdbctemplate 内部会通过 datasource 到上面的 threadlocal 中拿到 spring 事务那个连接，然后执行 db 操作。

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06DycA80FqTHT8qgh8qibK8FcBTk74RvbqNIicaPhdLS1Lriba57pqLrLN33LGm8V3xUCfUQWcTxY4Vcw/640?wx_fmt=png)

最后 insertBatch 方法执行完毕之后，没有任何异常，那么 spring 就开始通过数据库连接提交事务了。

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06DycA80FqTHT8qgh8qibK8FcLC8lNXicTPX0QCwvyLVZKWjNCpQliawJGP36Jj8reTNbc6IcmyxYDbwQ/640?wx_fmt=png)

总结
--

本文讲解了一下 spring 中编程式事务的使用步骤。

主要涉及到了 2 个注解：

@EnableTransactionManagement：开启 spring 事务管理功能

@Transaction：将其加在需要 spring 管理事务的类、方法、接口上，只会对 public 方法有效。

大家再消化一下，有问题，欢迎留言交流。

**下篇文章将详细介绍事务的传播属性，敬请期待。**

案例源码
----

```
git地址：
https://gitee.com/javacode2018/spring-series

本文案例对应源码：spring-series\lesson-002-tx\src\main\java\com\javacode2018\tx\demo4


```

**路人甲 java 所有案例代码以后都会放到这个上面，大家 watch 一下，可以持续关注动态。**

Spring 系列
---------

1.  [Spring 系列第 1 篇：为何要学 spring？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933921&idx=1&sn=db7ff07c5d60283b456fb9cd2a60f960&chksm=88621e1fbf15970919e82f059815714545806dc7ca1c48ed7a609bc4d90c1f4bb52dfa0706d5&token=157089977&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [Spring 系列第 2 篇：控制反转（IoC）与依赖注入（DI）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933936&idx=1&sn=bd7fbbb66035ce95bc4fd11b8cb3bdf2&chksm=88621e0ebf15971872448086b445f56aef714d8597c4b61f1fbae2f7c04061754d4f5873c954&token=339287021&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Spring 系列第 3 篇：Spring 容器基本使用及原理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933940&idx=1&sn=6c8c6dc1d8f955663a9874c9f94de88e&chksm=88621e0abf15971c796248e35100c043dac0f5173a870c1d952d4d88a336fa4b76db6885a70c&token=339287021&lang=zh_CN&scene=21#wechat_redirect)
    
4.  [Spring 系列第 4 篇：xml 中 bean 定义详解 (-)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933945&idx=1&sn=f9a3355a60f33a0bbf56d013adbf94ca&chksm=88621e07bf1597119d8df91702f7bece9fa64659b5cbb8fed311b314fa64b0465eaa080712fc&token=298797737&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [Spring 系列第 5 篇：创建 bean 实例这些方式你们都知道？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933955&idx=2&sn=bbf4c1c9c996df9454b71a9f68d59779&chksm=88621e7dbf15976ba26c8919394b9049c3906223c4e97b88ccfed62e75ec4688668555dd200f&token=1045303334&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [Spring 系列第 6 篇：玩转 bean scope，避免跳坑里！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933960&idx=1&sn=f4308f8955f87d75963c379c2a0241f4&chksm=88621e76bf159760d404c253fa6716d3ffce4de8df0fc1d0d5dd0cf00a81bc170a30829ee58f&token=1314297026&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [Spring 系列第 7 篇：依赖注入之手动注入](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933967&idx=1&sn=3444809283b21222dd291a14dad0571b&chksm=88621e71bf159767f8e32e33488383d5841de7e13ca596d7c6572c8d97ba3ae143d3a3888463&token=1687118085&lang=zh_CN&scene=21#wechat_redirect)
    
8.  [Spring 系列第 8 篇：自动注入（autowire）详解，高手在于坚持](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933974&idx=2&sn=7c9cc4e1f2c0f4cb83e985b593f2b6fb&chksm=88621e68bf15977e9451262d440c21e0abf622e54162beef838ba8a9512c7eac0bb8b8852527&token=2030963208&lang=zh_CN&scene=21#wechat_redirect)
    
9.  [Spring 系列第 9 篇：depend-on 到底是干什么的？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933982&idx=1&sn=69a2906f5db1953030ff40225b3ac788&chksm=88621e60bf159776093398f89652fecc99fb78ddf6f7434afbe65f8511d3e41c65d729303507&token=880944996&lang=zh_CN&scene=21#wechat_redirect)
    
10.  [Spring 系列第 10 篇：primary 可以解决什么问题？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933997&idx=1&sn=755c93c5e1bef571ac108e9045444fdd&chksm=88621e53bf15974584bbc4c6bf706f1714cb86cd65ac3e467ccf81bb9853fc9854b9ceed1981&token=1156408467&lang=zh_CN&scene=21#wechat_redirect)
    
11.  [Spring 系列第 11 篇：bean 中的 autowire-candidate 又是干什么的？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934008&idx=1&sn=ac156fe2788c49e0014bb5056139206e&chksm=88621e46bf1597505eba3e716148efcd9acec72ee6c0d95cf3936be70241fd41b180f0de02b5&token=1248115129&lang=zh_CN&scene=21#wechat_redirect)
    
12.  [Spring 系列第 12 篇：lazy-init：bean 延迟初始化](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934052&idx=2&sn=96f821743a61d4645f32faa44b2b3087&chksm=88621e9abf15978cb11ad368523b7c98181744862c26020a5213db521040cd880347eb452af6&token=1656183666&lang=zh_CN&scene=21#wechat_redirect)
    
13.  [Spring 系列第 13 篇：使用继承简化 bean 配置 (abstract & parent)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934063&idx=1&sn=d529258a955ed5b53c9081219c8391e7&chksm=88621e91bf159787351880d2217b9f3fb7b06d251caa32995657cd2ca9613765bf87ff7e04a0&token=1656183666&lang=zh_CN&scene=21#wechat_redirect)
    
14.  [Spring 系列第 14 篇：lookup-method 和 replaced-method 比较陌生，怎么玩的？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934074&idx=1&sn=5b7ccbef079053d9af4027f0dc642c56&chksm=88621e84bf1597923127e459e11da5c27741f080a0bfd033019ccc52cf67915ec4999d76b6dd&token=1283885571&lang=zh_CN&scene=21#wechat_redirect)
    
15.  [Spring 系列第 15 篇：代理详解（Java 动态代理 & cglib 代理）？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934082&idx=1&sn=c919886400135a0152da23eaa1f276c7&chksm=88621efcbf1597eab943b064147b8fb8fd3dfbac0dc03f41d15d477ef94b60d4e8f78c66b262&token=1042984313&lang=zh_CN&scene=21#wechat_redirect)
    
16.  [Spring 系列第 16 篇：深入理解 java 注解及 spring 对注解的增强（预备知识）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934095&idx=1&sn=26d539ef61389bae5d293f1b2f5210b2&chksm=88621ef1bf1597e756ccaeb6c6c6f4b74c6e3ba22ca6adba496b05e81558cd3801c62b21b8d9&token=1042984313&lang=zh_CN&scene=21#wechat_redirect)
    
17.  [Spring 系列第 17 篇：@Configration 和 @Bean 注解详解 (bean 批量注册)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934137&idx=1&sn=3775d5d7a23c43616d1274b0b52a9f99&chksm=88621ec7bf1597d1b16d91cfb28e63bef485f10883c7ca30d09838667f65e3d214b9e1cebd47&token=1372043037&lang=zh_CN&scene=21#wechat_redirect)
    
18.  [Spring 系列第 18 篇：@ComponentScan、@ComponentScans 详解 (bean 批量注册)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934150&idx=1&sn=6e466720d78f212cbd7d003bc5c2eec2&chksm=88621f38bf15962e324888161d0b91f34c26e4b8a53da87f1364e5af7010dbdcabc9fb555476&token=1346356013&lang=zh_CN&scene=21#wechat_redirect)
    
19.  [Spring 系列第 18 篇：@import 详解 (bean 批量注册)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934173&idx=1&sn=60bb7d58fd408db985a785bfed6e1eb2&chksm=88621f23bf15963589f06b7ce4e521a7c8d615b1675788f383cbb0bcbb05b117365327e1941a&token=704646761&lang=zh_CN&scene=21#wechat_redirect)
    
20.  [Spring 系列第 20 篇：@Conditional 通过条件来控制 bean 的注册](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934205&idx=1&sn=5407aa7c49eb34f7fb661084b8873cfe&chksm=88621f03bf1596159eeb40d75620db03457f4aa831066052ebc6e1efc2d7b18802a49a7afe8a&token=332995799&lang=zh_CN&scene=21#wechat_redirect)
    
21.  [Spring 系列第 21 篇：注解实现依赖注入（@Autowired、@Resource、@Primary、@Qulifier）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934232&idx=1&sn=fd2f34d8d1342fe819c5a71059e440a7&chksm=88621f66bf159670a8268f8db74db075634a24a58b75589e4e7db2f06e6166c971074feae764&token=979575345&lang=zh_CN&scene=21#wechat_redirect)
    
22.  [Spring 系列第 22 篇：@Scope、@DependsOn、@ImportResource、@Lazy 详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934284&idx=1&sn=00126ad4b435cb31726a5ef10c31af25&chksm=88621fb2bf1596a41563db5c474873c62d552ec9a440037d913704f018742ffca9be9b598680&token=887127000&lang=zh_CN&scene=21#wechat_redirect)
    
23.  [Spring 系列第 23 篇：Bean 生命周期详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934322&idx=1&sn=647edffeedeb8978c18ad403b1f3d8d7&chksm=88621f8cbf15969af1c5396903dcce312c1f316add1af325327d287e90be49bbeda52bc1e736&token=718443976&lang=zh_CN&scene=21#wechat_redirect)
    
24.  [Spring 系列第 24 篇：父子容器详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934382&idx=1&sn=7d37aef61cd18ec295f268c902dfb84f&chksm=88621fd0bf1596c6c9f60c966eb325c6dfe0e200666ee0bcdd1ff418597691795ad209e444f2&token=749715143&lang=zh_CN&scene=21#wechat_redirect)
    
25.  [Spring 系列第 25 篇：@Value【用法、数据来源、动态刷新】](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934401&idx=1&sn=98e726ec9adda6d40663f624705ba2e4&chksm=8862103fbf15992981183abef03b4774ab1dfd990a203a183efb8d118455ee4b477dc6cba50d&token=636643900&lang=zh_CN&scene=21#wechat_redirect)
    
26.  [Spring 系列第 26 篇：国际化详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934484&idx=1&sn=ef0a704c891f318a7c23fe000d9003d5&chksm=8862106abf15997c39a3387ce7b2e044cfb3abd92b908eb0971d084c8238ff5f99af412d6054&token=1299257585&lang=zh_CN&scene=21#wechat_redirect)
    
27.  [Spring 系列第 27 篇：spring 事件机制详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934522&idx=1&sn=7653141d01b260875797bbf1305dd196&chksm=88621044bf15995257129e33068f66fc5e39291e159e5e0de367a14e0195595c866b3aaa1972&token=1081910573&lang=zh_CN&scene=21#wechat_redirect)
    
28.  [Spring 系列第 28 篇：Bean 循环依赖详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934550&idx=1&sn=2cf05f53a63d12f74e853a10a11dcc98&scene=21#wechat_redirect)
    
29.  [Spring 系列第 29 篇：BeanFactory 扩展（BeanFactoryPostProcessor、BeanDefinitionRegistryPostProcessor）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934655&idx=1&sn=5b6c360de7eda0ca83d38e9db3616761&chksm=886210c1bf1599d7c42919a8b883a7cd2dd8e42212627a32e6d91dfb1f6da1b9536079ec4f6d&token=1804011114&lang=zh_CN&scene=21#wechat_redirect)
    
30.  [Spring 系列第 30 篇：jdk 动态代理和 cglib 代理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934783&idx=1&sn=5531f14475a4addc6d4d47f0948b3208&chksm=88621141bf159857bc19d7bb545ed3ddc4152dcda9e126f27b83afc2e975dee1682de2d98ad6&token=690771459&lang=zh_CN&scene=21#wechat_redirect)
    
31.  [Spring 系列第 31 篇：aop 概念详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934876&idx=1&sn=7794b50e658e0ec3e0aff6cf5ed4aa2e&chksm=886211e2bf1598f4e0e636170a4b36a5a5edd8811c8b7c30d61135cb114b0ce506a6fa84df0b&token=690771459&lang=zh_CN&scene=21#wechat_redirect)
    
32.  [Spring 系列第 32 篇：AOP 核心源码、原理详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934930&idx=1&sn=4030960657cc72006122ef8b6f0de889&chksm=8862122cbf159b3a4823a7f6b93add5ae1ad0e60cdedf8ed2d558c0f67bd6b0158a900d270eb&scene=21#wechat_redirect)
    
33.  [Spring 系列第 33 篇：ProxyFactoryBean 创建 AOP 代理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934977&idx=1&sn=8e4caf6a17bf5e123884df81a6382214&chksm=8862127fbf159b699c4456afe35a17f0d7bed119a635b11c154751dd95f59917487c895ccb84&scene=21#wechat_redirect)
    
34.  [Spring 系列第 34 篇：@Aspect 中 @Pointcut 12 种用法](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935037&idx=2&sn=cf813ac4cdfa3a0a0d6b5ed770255779&chksm=88621243bf159b554be2fe75eda7f5631ca29eed54edbfb97b08244625e03957429f2414d1e3&token=883563940&lang=zh_CN&scene=21#wechat_redirect)
    
35.  [Spring 系列第 35 篇：@Aspect 中 5 中通知详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935466&idx=2&sn=f536d7a2834e6e590bc7af0527e4de1f&scene=21#wechat_redirect)
    
36.  [Spring 系列第 36 篇：@EnableAspectJAutoProxy、@Aspect 中通知顺序详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935500&idx=2&sn=5fb794139e476a275963432948e29362&scene=21#wechat_redirect)
    
37.  [Spring 系列第 37 篇：@EnableAsync & @Async 实现方法异步调用](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935642&idx=2&sn=6b9ac2b42f5c5da424a424ec909392fe&scene=21#wechat_redirect)
    
38.  [Spring 系列第 38 篇：@Scheduled & @EnableScheduling 定时器详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935890&idx=2&sn=f8a8e01e7399161621152b2e4caa8128&scene=21#wechat_redirect)
    
39.  [Spring 系列第 39 篇：强大的 Spel 表达式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936152&idx=2&sn=5d5dcaa28fe5aec867ce05bf5119829e&scene=21#wechat_redirect)
    
40.  [Spring 系列第 40 篇：缓存使用（@EnableCaching、@Cacheable、@CachePut、@CacheEvict、@Caching、@CacheConfig）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936253&idx=2&sn=fe74d8130a85dd70405a80092b2ba48c&scene=21#wechat_redirect)
    
41.  [Spring 系列第 41 篇：@EnableCaching 集成 redis 缓存](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936334&idx=2&sn=7565a7528bb24d090ce170e456e991ce&scene=21#wechat_redirect)
    
42.  [Spring 系列第 42 篇：玩转 JdbcTemplate](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936449&idx=2&sn=da1e98e5914821f040d5530e8ca9d9bc&scene=21#wechat_redirect)
    
43.  [Spring 系列第 43 篇：spring 中编程式事务怎么用的？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936779&idx=2&sn=a6255c7d436a62af380dfa6b326fd4e7&scene=21#wechat_redirect)
    

更多好文章
-----

1.  [Java 高并发系列（共 34 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933285&idx=1&sn=f5507c251b84c3405f2fe0f7fb1da97d&chksm=88621b9bbf15928dd4c26f52b2abb0e130cde02100c432f33f0e90123b5e4b20d43017c1030e&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [MySql 高手系列（共 27 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933461&idx=1&sn=67cd31469273b68a258d963e53b56325&chksm=88621c6bbf15957d7308d81cd8ba1761b356222f4c6df75723aee99c265bd94cc869faba291c&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Maven 高手系列（共 10 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933753&idx=1&sn=0b41083939980be87a61c4f573792459&chksm=88621d47bf1594516092b662c545abfac299d296e232bf25e9f50be97e002e2698ea78218828&scene=21#wechat_redirect)
    
4.  [Mybatis 系列（共 12 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933868&idx=1&sn=ed16ef4afcbfcb3423a261422ff6934e&chksm=88621dd2bf1594c4baa21b7adc47456e5f535c3358cd11ddafb1c80742864bb19d7ccc62756c&token=1400407286&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [聊聊 db 和缓存一致性常见的实现方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933452&idx=1&sn=48b3b1cbd27c50186122fef8943eca5f&chksm=88621c72bf159564e629ee77d180424274ae9effd8a7c2997f853135b28f3401970793d8098d&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [接口幂等性这么重要，它是什么？怎么实现？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933334&idx=1&sn=3a68da36e4e21b7339418e40ab9b6064&chksm=88621be8bf1592fe5301aab732fbed8d1747475f4221da341350e0cc9935225d41bf79375d43&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [泛型，有点难度，会让很多人懵逼，那是因为你没有看这篇文章！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933878&idx=1&sn=bebd543c39d02455456680ff12e3934b&chksm=88621dc8bf1594de6b50a760e4141b80da76442ba38fb93a91a3d18ecf85e7eee368f2c159d3&token=799820369&lang=zh_CN&scene=21#wechat_redirect)
    

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06AibRrjQicuaJj6Mq4hmnCUlIibUvzyXLROGOKSGfz9FrjG1Cjy4bicNmFdO4yWE2ibiaQJ1F6eic95FWc9Q/640?wx_fmt=png)