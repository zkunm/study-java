> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937266&idx=2&sn=dec5380383ed768b734ffe02e0322724&scene=21#wechat_redirect)

本篇内容：**通过原理和大量案例带大家吃透 Spring 多数据源事务****。**

Spring 中通过事务管理器来控制事务，每个数据源都需要指定一个事务管理器，如果我们的项目中需要操作多个数据库，那么需要我们配置多个数据源，也就需要配置多个数据管理器。

多数据源事务使用 2 个步骤
--------------

### 1、为每个数据源定义一个事务管理器

如下面代码，有 2 个数据源分别连接数据库 ds1 和 ds2，然后为每个数据源定义了 1 个事务管理器，此时 spring 容器中有 2 个数据源和 2 个事务管理器。

```
//数据源1
@Bean
public DataSource dataSource1() {
     org.apache.tomcat.jdbc.pool.DataSource dataSource = new org.apache.tomcat.jdbc.pool.DataSource();
    dataSource.setDriverClassName("com.mysql.jdbc.Driver");
    dataSource.setUrl("jdbc:mysql://localhost:3306/ds1?characterEncoding=UTF-8");
    dataSource.setUsername("root");
    dataSource.setPassword("root123");
    dataSource.setInitialSize(5);
    return dataSource;
}

//事务管理器1，对应数据源1
@Bean
public PlatformTransactionManager transactionManager1(@Qualifier("dataSource1")DataSource dataSource) {
    return new DataSourceTransactionManager(dataSource);
}

//数据源2
@Bean
public DataSource dataSource2() {
    org.apache.tomcat.jdbc.pool.DataSource dataSource = new org.apache.tomcat.jdbc.pool.DataSource();
    dataSource.setDriverClassName("com.mysql.jdbc.Driver");
    dataSource.setUrl("jdbc:mysql://localhost:3306/ds2?characterEncoding=UTF-8");
    dataSource.setUsername("root");
    dataSource.setPassword("root123");
    dataSource.setInitialSize(5);
    return dataSource;
}

//事务管理器2，对应数据源2
@Bean
public PlatformTransactionManager transactionManager2(@Qualifier("dataSource2")DataSource dataSource) {
    return new DataSourceTransactionManager(dataSource);
}


```

### 2、指定事务的管理器 bean 名称

使用 @Transaction 中时，需通过 @Transaction 注解的 value 或 transactionManager 属性指定事务管理器 bean 名称，如：

```
@Transactional(transactionManager = "transactionManager1", propagation = Propagation.REQUIRED)
public void required(String name) {
    this.jdbcTemplate1.update("insert into user1(name) VALUES (?)", name);
}


```

这里补充一下，之前我们使用 @Transactional 的时候，并没有通过 value 或者 transactionManager 设置事务管理器，这是为什么？

这是因为我们在 spring 容器中只定义了一个事务管理器，spring 启动事务的时候，默认会按类型在容器中查找事务管理器，刚好容器中只有一个，就拿过来用了，如果有多个的时候，如果你不指定，spring 是不知道具体要用哪个事务管理器的。

多数据源事务的使用就这么简单，下面我们来看案例，案例才是精华。

事务管理器运行过程
---------

这里先给大家解释一下 REQUIRED 传播行为下，事务管理器的大致的运行过程，方便理解后面的案例代码。

```
Service1中：
@Transactional(transactionManager = "transactionManager1", propagation = Propagation.REQUIRED)
public void m1(){
    this.jdbcTemplate1.update("insert into user1(name) VALUES ('张三')");
 service2.m2();
}

Service2中：
@Transactional(transactionManager = "transactionManager1", propagation = Propagation.REQUIRED)
public void m2(){
    this.jdbcTemplate1.update("insert into user1(name) VALUES ('李四')");
}


```

spring 事务中有个 resources 的 ThreadLocal，static 修饰的，用来存放共享的资源，稍后过程中会用到。

```
private static final ThreadLocal<Map<Object, Object>> resources = new NamedThreadLocal<>("Transactional resources");


```

下面看 m1 方法简化版的事务过程：

```
1、TransactionInterceptor拦截m1方法
2、获取m1方法的事务配置信息：事务管理器bean名称：transactionManager1，事务传播行为：REQUIRED
3、从spring容器中找到事务管理器transactionManager1，然后问一下transactionManager1，当前上下文中有没有事务，显然现在是没有的
4、创建一个新的事务
    //获取事务管理器对应的数据源，即dataSource1
    DataSource dataSource1 = transactionManager1.getDataSource();
    //即从dataSource1中获取一个连接
    Connection conn = transactionManager1.dataSource1.getConnection();
    //开启事务手动提交
    conn.setAutoCommit(false);
    //将dataSource1->conn放入map中
    map.put(dataSource1,conn);
 //将map丢到上面的resources ThreadLocal中
    resources.set(map);
5、下面来带m1放的第一行代码：this.jdbcTemplate1.update("insert into user1(name) VALUES ('张三')");
6、jdbctemplate内部需要获取数据连接，获取连接的过程
    //从resources这个ThreadLocal中获取到map
    Map map = resources.get();
    //通过jdbcTemplate1.datasource从map看一下没有可用的连接
    Connection conn = map.get(jdbcTemplate1.datasource);
    //如果从map没有找到连接，那么重新从jdbcTemplate1.datasource中获取一个
    //大家应该可以看出来，jdbcTemplate1和transactionManager1指定的是同一个dataSource，索引这个地方conn是不为null的
    if(conn==null){
     conn = jdbcTemplate1.datasource.getConnection();
    }
7、通过上面第6步获取的conn执行db操作，插入张三
8、下面来到m1方法的第2行代码：service2.m2();
9、m2方法上面也有@Transactional,TransactionInterceptor拦截m2方法
10、获取m2方法的事务配置信息：事务管理器bean名称：transactionManager1，事务传播行为：REQUIRED
11、从spring容器中找到事务管理器transactionManager1，然后问一下transactionManager1，当前上下文中有没有事务，显然是是有的，m1开启的事务正在执行中，所以m2方法就直接加入这个事务了
12、下面来带m2放的第一行代码：this.jdbcTemplate1.update("insert into user1(name) VALUES ('李四')");
13、jdbctemplate内部需要获取数据连接，获取连接的过程
    //从resources这个ThreadLocal中获取到map
    Map map = resources.get();
    //通过jdbcTemplate1.datasource从map看一下没有可用的连接
    Connection conn = map.get(jdbcTemplate1.datasource);
    //如果从map没有找到连接，那么重新从jdbcTemplate1.datasource中获取一个
    //大家应该可以看出来，jdbcTemplate1和transactionManager1指定的是同一个dataSource，索引这个地方conn是不为null的
    if(conn==null){
        conn = jdbcTemplate1.datasource.getConnection();
    }
14、通过第13步获取的conn执行db操作，插入李四
15、最终TransactionInterceptor发现2个方法都执行完毕了，没有异常，执行事务提交操作，如下
    //获取事务管理器对应的数据源，即dataSource1
    DataSource dataSource1 = transactionManager1.getDataSource();
    //从resources这个ThreadLocal中获取到map
    Map map = resources.get();
    //通过map拿到事务管理器开启的连接
    Connection conn = map.get(dataSource1);
    //通过conn提交事务
    conn.commit();
    //管理连接
    conn.close();
16、清理ThreadLocal中的连接：通过map.remove(dataSource1)将连接从resource ThreadLocal中移除
17、清理事务


```

**从上面代码中可以看出：整个过程中有 2 个地方需要用到数据库连接 Connection 对象，第 1 个地方是：spring 事务拦截器启动事务的时候会从 datasource 中获取一个连接，通过这个连接开启事务手动提交，第 2 个地方是：最终执行 sql 操作的时候，也需要用到一个连接。那么必须确保这两个连接必须是同一个连接的时候，执行 sql 的操作才会受 spring 事务控制，那么如何确保这 2 个是同一个连接呢？从代码中可以看出必须让事务管理器中的 datasource 和 JdbcTemplate 中的 datasource 必须是同一个，那么最终 2 个连接就是同一个对象。**

这里顺便回答一下群友问的一个问题：**什么是事务挂起操作？**

这里以事务传播行为 REQUIRED_NEW 为例说明一下，REQUIRED_NEW 表示不管当前事务管理器中是否有事务，都会重新开启一个事务，如果当前事务管理器中有事务，会把当前事务挂起。

所谓挂起，你可以这么理解：**对当前存在事务的现场生成一个快照，然后将事务现场清理干净，然后重新开启一个新事务，新事务执行完毕之后，将事务现场清理干净，然后再根据前面的快照恢复旧事务**。

下面我们再回到本文的内容，多数据源事务管理。

事务管理器如何判断当前是否有事务？
-----------------

简化版的过程如下：

```
Map map=resource的ThreadLocal.get();
DataSource datasource = transactionManager.getDataSource();
Connection conn = map.get(datasource);
//如果conn不为空，就表示当前有事务
if(conn!=null){
}


```

**从这段代码可以看出：判断是否存在事务，主要和 datasource 有关，和事务管理器无关，即使是不同的事务管理器，只要事务管理器的 datasource 是一样的，那么就可以发现当前存在的事务。**

事务管理器的运行过程和如何判断是否有事务，这 2 点大家一定要理解，这个理解了，后面的案例理解起来会容易很多。

**下面上案例。**