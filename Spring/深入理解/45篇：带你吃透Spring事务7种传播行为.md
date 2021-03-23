> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937136&idx=2&sn=73d60cc0e6d9734d675aec369704992e&scene=21#wechat_redirect)

本文详解 Spring 事务中的 7 种传播行为，还是比较重要的。

环境
--

2.  jdk1.8
    
3.  Spring 5.2.3.RELEASE
    
4.  mysql5.7
    

什么是事务传播行为？
----------

事务的传播行为用来描述：系统中的一些方法交由 spring 来管理事务，当这些方法之间出现嵌套调用的时候，事务所表现出来的行为是什么样的？

比如下面 2 个类，Service1 中的 m1 方法和 Service2 中的 m2 方法上面都有 @Transactional 注解，说明这 2 个方法由 spring 来控制事务。

但是注意 m1 中 2 行代码，先执行了一个 insert，然后调用 service2 中的 m2 方法，service2 中的 m2 方法也执行了一个 insert。

那么大家觉得这 2 个 insert 会在一个事务中运行么？也就是说此时事务的表现行为是什么样的呢？这个就是 spring 事务的传播行为来控制的事情，不同的传播行为，表现会不一样，可能他们会在一个事务中执行，也可能不会在一个事务中执行，这就需要看传播行为的配置了。

```
@Component
public class Service1 {
    @Autowired
    private Service2 service2;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Transactional
    public void m1() {
        this.jdbcTemplate.update("INSERT into t1 values ('m1')");
        this.service2.m2();
    }
}

@Component
public class Service2 {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Transactional
    public void m2() {
        this.jdbcTemplate.update("INSERT into t1 values ('m2')");
    }
}



```

如何配置事务传播行为？
-----------

通过 @Transactional 注解中的 propagation 属性来指定事务的传播行为：

```
Propagation propagation() default Propagation.REQUIRED;


```

Propagation 是个枚举，有 7 种值，如下：

<table data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><thead data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th width="150" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">事务传播行为类型</th><th width="365" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">说明</th></tr></thead><tbody data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="65" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;"><strong data-darkmode-color-16079184193008="rgb(255, 23, 0)" data-darkmode-original-color-16079184193008="rgb(255, 0, 0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="color: rgb(255, 0, 0);">REQUIRED</strong></td><td width="365" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">如果当前事务管理器中没有事务，就新建一个事务，如果已经存在一个事务中，加入到这个事务中。这是最常见的选择，是默认的传播行为。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td width="65" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;"><strong data-darkmode-color-16079184193008="rgb(255, 35, 0)" data-darkmode-original-color-16079184193008="rgb(255, 0, 0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="color: rgb(255, 0, 0);">SUPPORTS</strong></td><td width="365" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">支持当前事务，如果当前事务管理器中没有事务，就以非事务方式执行。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="65" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;"><strong data-darkmode-color-16079184193008="rgb(255, 23, 0)" data-darkmode-original-color-16079184193008="rgb(255, 0, 0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="color: rgb(255, 0, 0);">MANDATORY</strong></td><td width="365" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">使用当前的事务，如果当前事务管理器中没有事务，就抛出异常。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td width="65" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;"><strong data-darkmode-color-16079184193008="rgb(255, 35, 0)" data-darkmode-original-color-16079184193008="rgb(255, 0, 0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="color: rgb(255, 0, 0);">REQUIRES_NEW</strong></td><td width="365" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">新建事务，如果当前事务管理器中存在事务，把当前事务挂起，然后会新建一个事务。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="65" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;"><strong data-darkmode-color-16079184193008="rgb(255, 23, 0)" data-darkmode-original-color-16079184193008="rgb(255, 0, 0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="color: rgb(255, 0, 0);">NOT_SUPPORTED</strong></td><td width="365" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">以非事务方式执行操作，如果当前事务管理器中存在事务，就把当前事务挂起。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td width="65" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;"><strong data-darkmode-color-16079184193008="rgb(255, 35, 0)" data-darkmode-original-color-16079184193008="rgb(255, 0, 0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="color: rgb(255, 0, 0);">NEVER</strong></td><td width="365" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">以非事务方式执行，如果当前事务管理器中存在事务，则抛出异常。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td width="65" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;"><strong data-darkmode-color-16079184193008="rgb(255, 23, 0)" data-darkmode-original-color-16079184193008="rgb(255, 0, 0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="color: rgb(255, 0, 0);">NESTED</strong></td><td width="365" data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">如果当前事务管理器中存在事务，则在嵌套事务内执行；如果当前事务管理器中没有事务，则执行与 PROPAGATION_REQUIRED 类似的操作。</td></tr></tbody></table>

**注意：这 7 种传播行为有个前提，他们的事务管理器是同一个的时候，才会有上面描述中的表现行为。**

下面通过案例对 7 中表现行为来做说明，在看案例之前，先来回顾几个知识点

**1、Spring 声明式事务处理事务的过程**

spring 声明式事务是通过事务拦截器 TransactionInterceptor 拦截目标方法，来实现事务管理的功能的，事务管理器处理过程大致如下：

```
1、获取事务管理器
2、通过事务管理器开启事务
try{
 3、调用业务方法执行db操作
 4、提交事务
}catch(RuntimeException | Error){
 5、回滚事务
}


```

**2、何时事务会回滚？**

默认情况下，目标方法抛出 RuntimeException 或者 Error 的时候，事务会被回滚。

**3、Spring 事务管理器中的 Connection 和业务中操作 db 的 Connection 如何使用同一个的？**

以 DataSourceTransactionManager 为事务管理器，操作 db 使用 JdbcTemplate 来说明一下。

创建 DataSourceTransactionManager 和 JdbcTemplate 的时候都需要指定 dataSource，需要将他俩的 dataSource 指定为同一个对象。

当事务管理器开启事务的时候，会通过 dataSource.getConnection() 方法获取一个 db 连接 connection，然后会将 dataSource->connection 丢到一个 Map 中，然后将 map 放到 ThreadLocal 中。

当 JdbcTemplate 执行 sql 的时候，以 JdbcTemplate.dataSource 去上面的 ThreadLocal 中查找，是否有可用的连接，如果有，就直接拿来用了，否则调用 JdbcTemplate.dataSource.getConnection() 方法获取一个连接来用。

所以 spring 中可以确保事务管理器中的 Connection 和 JdbcTemplate 中操作 db 的 Connection 是同一个，这样才能确保 spring 可以控制事务。

代码验证
----

### 准备 db

```
DROP DATABASE IF EXISTS javacode2018;
CREATE DATABASE if NOT EXISTS javacode2018;

USE javacode2018;
DROP TABLE IF EXISTS user1;
CREATE TABLE user1(
  id int PRIMARY KEY AUTO_INCREMENT,
  name varchar(64) NOT NULL DEFAULT '' COMMENT '姓名'
);

DROP TABLE IF EXISTS user2;
CREATE TABLE user2(
  id int PRIMARY KEY AUTO_INCREMENT,
  name varchar(64) NOT NULL DEFAULT '' COMMENT '姓名'
);


```

### spring 配置类 MainConfig6

准备 JdbcTemplate 和事务管理器。

```
package com.javacode2018.tx.demo6;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;

@EnableTransactionManagement //开启spring事务管理功能
@Configuration //指定当前类是一个spring配置类
@ComponentScan //开启bean扫描注册
public class MainConfig6 {
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

    //定义我一个事务管理器
    @Bean
    public PlatformTransactionManager transactionManager(DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }
}


```

### 来 3 个 service

后面的案例中会在这 3 个 service 中使用 spring 的事务来演示效果。

#### User1Service

```
package com.javacode2018.tx.demo6;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class User1Service {
    @Autowired
    private JdbcTemplate jdbcTemplate;
}


```

#### User2Service

```
package com.javacode2018.tx.demo6;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class User2Service {
    @Autowired
    private JdbcTemplate jdbcTemplate;
}


```

#### TxService

```
package com.javacode2018.tx.demo6;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class TxService {
    @Autowired
    private User1Service user1Service;
    @Autowired
    private User2Service user2Service;
}


```

### 测试用例 Demo6Test

before 方法会在每个 @Test 标注的方法之前执行一次，这个方法主要用来做一些准备工作：启动 spring 容器、清理 2 个表中的数据；after 方法会在每个 @Test 标注的方法执行完毕之后执行一次，我们在这个里面输出 2 个表的数据；方便查看的测试用例效果。

```
package com.javacode2018.tx.demo6;

import org.junit.Before;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class Demo6Test {

    private TxService txService;
    private JdbcTemplate jdbcTemplate;

    //每个@Test用例执行之前先启动一下spring容器，并清理一下user1、user2中的数据
    @Before
    public void before() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig6.class);
        txService = context.getBean(TxService.class);
        jdbcTemplate = context.getBean(JdbcTemplate.class);
        jdbcTemplate.update("truncate table user1");
        jdbcTemplate.update("truncate table user2");
    }

    @After
    public void after() {
        System.out.println("user1表数据：" + jdbcTemplate.queryForList("SELECT * from user1"));
        System.out.println("user2表数据：" + jdbcTemplate.queryForList("SELECT * from user2"));
    }

}


```

1、REQUIRED
----------

### User1Service

添加 1 个方法，事务传播行为：REQUIRED

```
@Transactional(propagation = Propagation.REQUIRED)
public void required(String name) {
    this.jdbcTemplate.update("insert into user1(name) VALUES (?)", name);
}


```

### User2Service

添加 2 个方法，事务传播行为：REQUIRED，注意第 2 个方法内部最后一行会抛出一个异常。

```
@Transactional(propagation = Propagation.REQUIRED)
public void required(String name) {
    this.jdbcTemplate.update("insert into user1(name) VALUES (?)", name);
}

@Transactional(propagation = Propagation.REQUIRED)
public void required_exception(String name) {
    this.jdbcTemplate.update("insert into user1(name) VALUES (?)", name);
    throw new RuntimeException();
}


```

### 场景 1（1-1）

外围方法没有事务，外围方法内部调用 2 个 REQUIRED 级别的事务方法。

案例中都是在 TxService 的方法中去调用另外 2 个 service，所以 TxService 中的方法统称外围方法，另外 2 个 service 中的方法称内部方法。

#### 验证方法 1

##### TxService 添加

```
public void notransaction_exception_required_required() {
    this.user1Service.required("张三");
    this.user2Service.required("李四");
    throw new RuntimeException();
}


```

##### 测试用例，Demo6Test 中添加

```
@Test
public void notransaction_exception_required_required() {
    txService.notransaction_exception_required_required();
}


```

##### 运行输出

```
user1表数据：[{id=1, name=张三}]
user2表数据：[{id=1, name=李四}]


```

#### 验证方法 2

##### TxService 添加

```
public void notransaction_required_required_exception() {
    this.user1Service.required("张三");
    this.user2Service.required_exception("李四");
}


```

##### 测试用例，Demo6Test 中添加

```
@Test
public void notransaction_required_required_exception() {
    txService.notransaction_required_required_exception();
}


```

##### 运行输出

```
user1表数据：[{id=1, name=张三}]
user2表数据：[]


```

#### 结果分析

<table data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><thead data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">验证方法序号</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">数据库结果</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">结果分析</th></tr></thead><tbody data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">1</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三”、“李四” 均插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法未开启事务，插入 “张三”、“李四” 方法在自己的事务中独立运行，外围方法异常不影响内部插入 “张三”、“李四” 方法独立的事务。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">2</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三” 插入，“李四” 未插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法没有事务，插入 “张三”、“李四” 方法都在自己的事务中独立运行，所以插入 “李四” 方法抛出异常只会回滚插入 “李四” 方法，插入 “张三” 方法不受影响。</td></tr></tbody></table>

#### 结论

**通过这两个方法我们证明了在外围方法未开启事务的情况下`Propagation.REQUIRED`修饰的内部方法会新开启自己的事务，且开启的事务相互独立，互不干扰。**

### 场景 2（1-2）

外围方法开启事务（Propagation.REQUIRED），这个使用频率特别高。

#### 验证方法 1

##### TxService 添加

```
@Transactional(propagation = Propagation.REQUIRED)
public void transaction_exception_required_required() {
    user1Service.required("张三");
    user2Service.required("李四");
    throw new RuntimeException();
}


```

##### 测试用例，Demo6Test 中添加

```
@Test
public void transaction_exception_required_required() {
    txService.transaction_exception_required_required();
}


```

##### 运行输出

```
user1表数据：[]
user2表数据：[]


```

#### 验证方法 2

##### TxService 添加

```
@Transactional(propagation = Propagation.REQUIRED)
public void transaction_required_required_exception() {
    user1Service.required("张三");
    user2Service.required_exception("李四");
}


```

##### 测试用例，Demo6Test 中添加

```
@Test
public void transaction_required_required_exception() {
    txService.transaction_required_required_exception();
}


```

##### 运行输出

```
user1表数据：[]
user2表数据：[]


```

#### 验证方法 3

##### TxService 添加

```
@Transactional(propagation = Propagation.REQUIRED)
public void transaction_required_required_exception_try() {
    user1Service.required("张三");
    try {
        user2Service.required_exception("李四");
    } catch (Exception e) {
        System.out.println("方法回滚");
    }
}


```

##### 测试用例，Demo6Test 中添加

```
@Test
public void transaction_required_required_exception_try() {
    txService.transaction_required_required_exception_try();
}


```

##### 运行输出

```
方法回滚
user1表数据：[]
user2表数据：[]


```

#### 结果分析

<table data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><thead data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">验证方法序号</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">数据库结果</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">结果分析</th></tr></thead><tbody data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">1</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三”、“李四” 均未插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法开启事务，内部方法加入外围方法事务，外围方法回滚，内部方法也要回滚。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">2</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三”、“李四” 均未插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法开启事务，内部方法加入外围方法事务，内部方法抛出异常回滚，外围方法感知异常致使整体事务回滚。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">3</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三”、“李四” 均未插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法开启事务，内部方法加入外围方法事务，内部方法抛出异常回滚，即使方法被 catch 不被外围方法感知，整个事务依然回滚。</td></tr></tbody></table>

#### 结论

**以上试验结果我们证明在外围方法开启事务的情况下`Propagation.REQUIRED`修饰的内部方法会加入到外围方法的事务中，所有`Propagation.REQUIRED`修饰的内部方法和外围方法均属于同一事务，只要一个方法回滚，整个事务均回滚。**

2、PROPAGATION_REQUIRES_NEW
--------------------------

### User1Service

添加 1 个方法，事务传播行为：REQUIRES_NEW

```
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void requires_new(String name) {
    this.jdbcTemplate.update("insert into user1(name) VALUES (?)", name);
}


```

### User2Service

添加 2 个方法，事务传播行为：REQUIRES_NEW，注意第 2 个方法内部最后一行会抛出一个异常。

```
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void requires_new(String name) {
    this.jdbcTemplate.update("insert into user2(name) VALUES (?)", name);
}

@Transactional(propagation = Propagation.REQUIRES_NEW)
public void requires_new_exception(String name) {
    this.jdbcTemplate.update("insert into user2(name) VALUES (?)", name);
    throw new RuntimeException();
}


```

### 场景 1（2-1）

外围方法没有事务。

#### 验证方法 1

##### TxService 添加

```
public void notransaction_exception_requiresNew_requiresNew(){
    user1Service.requires_new("张三");
    user2Service.requires_new("李四");
    throw new RuntimeException();
}


```

##### Demo6Test 中添加

```
@Test
public void notransaction_exception_requiresNew_requiresNew() {
    txService.notransaction_exception_requiresNew_requiresNew();
}


```

##### 运行输出

```
user1表数据：[{id=1, name=张三}]
user2表数据：[{id=1, name=李四}]


```

#### 验证方法 2

##### TxService 添加

```
public void notransaction_requiresNew_requiresNew_exception(){
    user1Service.requires_new("张三");
    user2Service.requires_new_exception("李四");
}


```

##### 测试用例，Demo6Test 中添加

```
@Test
public void notransaction_requiresNew_requiresNew_exception() {
    txService.notransaction_requiresNew_requiresNew_exception();
}


```

##### 运行输出

```
user1表数据：[{id=1, name=张三}]
user2表数据：[]


```

#### 结果分析

<table data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><thead data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">验证方法序号</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">数据库结果</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">结果分析</th></tr></thead><tbody data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">1</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三” 插入，“李四” 插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法没有事务，插入 “张三”、“李四” 方法都在自己的事务中独立运行, 外围方法抛出异常回滚不会影响内部方法。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">2</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三” 插入，“李四” 未插入</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法没有开启事务，插入 “张三” 方法和插入 “李四” 方法分别开启自己的事务，插入 “李四” 方法抛出异常回滚，其他事务不受影响。</td></tr></tbody></table>

#### 结论

**通过这两个方法我们证明了在外围方法未开启事务的情况下`Propagation.REQUIRES_NEW`修饰的内部方法会新开启自己的事务，且开启的事务相互独立，互不干扰。**

### 场景 2（2-2）

外围方法开启事务。

#### 验证方法 1

##### TxService 添加

```
@Transactional(propagation = Propagation.REQUIRED)
public void transaction_exception_required_requiresNew_requiresNew() {
    user1Service.required("张三");

    user2Service.requires_new("李四");

    user2Service.requires_new("王五");
    throw new RuntimeException();
}


```

##### 测试用例，Demo6Test 中添加

```
@Test
public void transaction_exception_required_requiresNew_requiresNew() {
    txService.transaction_exception_required_requiresNew_requiresNew();
}


```

##### 运行输出

```
user1表数据：[]
user2表数据：[{id=1, name=李四}, {id=2, name=王五}]


```

#### 验证方法 2

##### TxService 添加

```
@Transactional(propagation = Propagation.REQUIRED)
public void transaction_required_requiresNew_requiresNew_exception() {
    user1Service.required("张三");

    user2Service.requires_new("李四");

    user2Service.requires_new_exception("王五");
}


```

##### Demo6Test 中添加

```
@Test
public void transaction_required_requiresNew_requiresNew_exception() {
    txService.transaction_required_requiresNew_requiresNew_exception();
}


```

##### 运行输出

```
user1表数据：[]
user2表数据：[{id=1, name=李四}]


```

#### 验证方法 3

##### TxService 添加

```
@Transactional(propagation = Propagation.REQUIRED)
public void transaction_required_requiresNew_requiresNew_exception_try(){
    user1Service.required("张三");

    user2Service.requires_new("李四");

    try {
        user2Service.requires_new_exception("王五");
    } catch (Exception e) {
        System.out.println("回滚");
    }
}


```

##### Demo6Test 中添加

```
@Test
public void transaction_required_requiresNew_requiresNew_exception_try() {
    txService.transaction_required_requiresNew_requiresNew_exception_try();
}


```

##### 运行输出

```
回滚
user1表数据：[{id=1, name=张三}]
user2表数据：[{id=1, name=李四}]


```

#### 结果分析

<table data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><thead data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">验证方法序号</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">数据库结果</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">结果分析</th></tr></thead><tbody data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">1</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三” 未插入，“李四” 插入，“王五” 插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法开启事务，插入 “张三” 方法和外围方法一个事务，插入 “李四” 方法、插入 “王五” 方法分别在独立的新建事务中，外围方法抛出异常只回滚和外围方法同一事务的方法，故插入 “张三” 的方法回滚。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">2</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三” 未插入，“李四” 插入，“王五” 未插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法开启事务，插入 “张三” 方法和外围方法一个事务，插入 “李四” 方法、插入 “王五” 方法分别在独立的新建事务中。插入 “王五” 方法抛出异常，首先插入 “王五”方法的事务被回滚，异常继续抛出被外围方法感知，外围方法事务亦被回滚，故插入 “张三” 方法也被回滚。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">3</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三” 插入，“李四” 插入，“王五” 未插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法开启事务，插入 “张三” 方法和外围方法一个事务，插入 “李四” 方法、插入 “王五” 方法分别在独立的新建事务中。插入 “王五” 方法抛出异常，首先插入 “王五” 方法的事务被回滚，异常被 catch 不会被外围方法感知，外围方法事务不回滚，故插入 “张三” 方法插入成功。</td></tr></tbody></table>

#### 结论

**在外围方法开启事务的情况下`Propagation.REQUIRES_NEW`修饰的内部方法依然会单独开启独立事务，且与外部方法事务也独立，内部方法之间、内部方法和外部方法事务均相互独立，互不干扰。**

3、PROPAGATION_NESTED
--------------------

### User1Service

添加 1 个方法，事务传播行为：NESTED

```
@Transactional(propagation = Propagation.NESTED)
public void nested(String name) {
    this.jdbcTemplate.update("insert into user1(name) VALUES (?)", name);
}


```

### User2Service

添加 2 个方法，事务传播行为：NESTED，注意第 2 个方法内部最后一行会抛出一个异常。

```
@Transactional(propagation = Propagation.NESTED)
public void nested(String name) {
    this.jdbcTemplate.update("insert into user2(name) VALUES (?)", name);
}

@Transactional(propagation = Propagation.NESTED)
public void nested_exception(String name) {
    this.jdbcTemplate.update("insert into user2(name) VALUES (?)", name);
    throw new RuntimeException();
}


```

### 场景 1（3-1）

外围方法没有事务。

#### 验证方法 1

##### TxService 添加

```
public void notransaction_exception_nested_nested(){
    user1Service.nested("张三");
    user2Service.nested("李四");
    throw new RuntimeException();
}


```

##### Demo6Test 中添加

```
@Test
public void notransaction_exception_nested_nested() {
    txService.notransaction_exception_nested_nested();
}


```

##### 运行输出

```
user1表数据：[{id=1, name=张三}]
user2表数据：[{id=1, name=李四}]


```

#### 验证方法 2

##### TxService 添加

```
public void notransaction_nested_nested_exception(){
    user1Service.nested("张三");
    user2Service.nested_exception("李四");
}


```

##### 测试用例，Demo6Test 中添加

```
@Test
public void notransaction_nested_nested_exception() {
    txService.notransaction_nested_nested_exception();
}


```

##### 运行输出

```
user1表数据：[{id=1, name=张三}]
user2表数据：[]


```

#### 结果分析

<table data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><thead data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">验证方法序号</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">数据库结果</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">结果分析</th></tr></thead><tbody data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">1</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三”、“李四” 均插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法未开启事务，插入 “张三”、“李四” 方法在自己的事务中独立运行，外围方法异常不影响内部插入 “张三”、“李四” 方法独立的事务。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">2</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三” 插入，“李四” 未插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法没有事务，插入 “张三”、“李四” 方法都在自己的事务中独立运行, 所以插入 “李四” 方法抛出异常只会回滚插入 “李四” 方法，插入 “张三” 方法不受影响。</td></tr></tbody></table>

#### 结论

**通过这两个方法我们证明了在外围方法未开启事务的情况下`Propagation.NESTED`和`Propagation.REQUIRED`作用相同，修饰的内部方法都会新开启自己的事务，且开启的事务相互独立，互不干扰。**

### 场景 2（3-1）

外围方法开启事务。

#### 验证方法 1

##### TxService 添加

```
@Transactional
public void transaction_exception_nested_nested(){
    user1Service.nested("张三");
    user2Service.nested("李四");
    throw new RuntimeException();
}


```

##### 测试用例，Demo6Test 中添加

```
@Test
public void transaction_exception_nested_nested() {
    txService.transaction_exception_nested_nested();
}


```

##### 运行输出

```
user1表数据：[]
user2表数据：[]


```

#### 验证方法 2

##### TxService 添加

```
@Transactional
public void transaction_nested_nested_exception(){
    user1Service.nested("张三");
    user2Service.nested_exception("李四");
}


```

##### Demo6Test 中添加

```
@Test
public void transaction_nested_nested_exception() {
    txService.transaction_nested_nested_exception();
}


```

##### 运行输出

```
user1表数据：[]
user2表数据：[]


```

#### 验证方法 3

##### TxService 添加

```
@Transactional
public void transaction_nested_nested_exception_try(){
    user1Service.nested("张三");
    try {
        user2Service.nested_exception("李四");
    } catch (Exception e) {
        System.out.println("方法回滚");
    }
}


```

##### Demo6Test 中添加

```
@Test
public void transaction_nested_nested_exception_try() {
    txService.transaction_nested_nested_exception_try();
}


```

##### 运行输出

```
方法回滚
user1表数据：[{id=1, name=张三}]
user2表数据：[]


```

#### 结果分析

<table data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><thead data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">验证方法序号</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">数据库结果</th><th data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079184193008="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">结果分析</th></tr></thead><tbody data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)"><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">1</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三”、“李四” 均未插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法开启事务，内部事务为外围事务的子事务，外围方法回滚，内部方法也要回滚。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">2</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三”、“李四” 均未插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079184193008="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法开启事务，内部事务为外围事务的子事务，内部方法抛出异常回滚，且外围方法感知异常致使整体事务回滚。</td></tr><tr data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">3</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">“张三” 插入、“李四” 未插入。</td><td data-darkmode-color-16079184193008="rgb(163, 163, 163)" data-darkmode-original-color-16079184193008="rgb(0,0,0)" data-darkmode-bgcolor-16079184193008="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079184193008="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">外围方法开启事务，内部事务为外围事务的子事务，插入 “李四” 内部方法抛出异常，可以单独对子事务回滚。</td></tr></tbody></table>

#### 结论

**以上试验结果我们证明在外围方法开启事务的情况下`Propagation.NESTED`修饰的内部方法属于外部事务的子事务，外围主事务回滚，子事务一定回滚，而内部子事务可以单独回滚而不影响外围主事务和其他子事务。**

#### 内部事务原理

以 mysql 为例，mysql 中有个 [savepoint 的功能](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933355&idx=1&sn=b426ad28dfc2a64bba813df5b7c341a4&scene=21#wechat_redirect)，NESTED 内部事务就是通过这个实现的。

REQUIRED,REQUIRES_NEW,NESTED 比较
-------------------------------

由 “场景 2（1-2）” 和“场景 2（3-2）”对比，我们可知：

**REQUIRED 和 NESTED 修饰的内部方法都属于外围方法事务，如果外围方法抛出异常，这两种方法的事务都会被回滚。但是 REQUIRED 是加入外围方法事务，所以和外围事务同属于一个事务，一旦 REQUIRED 事务抛出异常被回滚，外围方法事务也将被回滚。而 NESTED 是外围方法的子事务，有单独的保存点，所以 NESTED 方法抛出异常被回滚，不会影响到外围方法的事务。**

由 “场景 2（2-2）” 和“场景 2（3-2）”对比，我们可知：