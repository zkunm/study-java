> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937564&idx=2&sn=549f841b7935c6f5f98957e4d443f893&scene=21#wechat_redirect)

本文主要内容：**Spring 编程式事务源码深度解析，理解 spring 事务的本质**

开始本文之前，有些必备的知识需要大家先了解一下

1.  [玩转 JdbcTemplate](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936449&idx=2&sn=da1e98e5914821f040d5530e8ca9d9bc&scene=21#wechat_redirect)
    
2.  [详解 Spring 编程式事务](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936779&idx=2&sn=a6255c7d436a62af380dfa6b326fd4e7&scene=21#wechat_redirect)
    
3.  [详解 Spring 声明式事务 (@EnableTransactionManagement、@Transactional)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936892&idx=2&sn=473a156dc141a2efc0580f93567f0630&scene=21#wechat_redirect)
    
4.  [详解 Spring 事务 7 种传播行为](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937136&idx=2&sn=73d60cc0e6d9734d675aec369704992e&scene=21#wechat_redirect)
    
5.  [详解 Spring 多数据源事务](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937266&idx=2&sn=dec5380383ed768b734ffe02e0322724&scene=21#wechat_redirect)
    

### 目录

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06A103A9g7z4ZsGjVKTKteReMliaoLYh0MW9l7MAaKSgLqibYia01328PwgVe2enYmVWpB7ZFNJfAzibQQ/640?wx_fmt=png)

### 环境

1.  jdk1.8
    
2.  Spring 版本：5.2.3.RELEASE
    
3.  mysql5.7
    

### 回顾一下编程式事务用法

```
@Test
public void test1() throws Exception {
    //定义一个数据源
    org.apache.tomcat.jdbc.pool.DataSource dataSource = new org.apache.tomcat.jdbc.pool.DataSource();
    dataSource.setDriverClassName("com.mysql.jdbc.Driver");
    dataSource.setUrl("jdbc:mysql://localhost:3306/javacode2018?characterEncoding=UTF-8");
    dataSource.setUsername("root");
    dataSource.setPassword("root123");
    dataSource.setInitialSize(5);
    //定义一个JdbcTemplate，用来方便执行数据库增删改查
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    //1.定义事务管理器，给其指定一个数据源（可以把事务管理器想象为一个人，这个人来负责事务的控制操作）
    PlatformTransactionManager platformTransactionManager = new DataSourceTransactionManager(dataSource);
    //2.定义事务属性：TransactionDefinition，TransactionDefinition可以用来配置事务的属性信息，比如事务隔离级别、事务超时时间、事务传播方式、是否是只读事务等等。
    TransactionDefinition transactionDefinition = new DefaultTransactionDefinition();
    //3.获取事务：调用platformTransactionManager.getTransaction开启事务操作，得到事务状态(TransactionStatus)对象
    TransactionStatus transactionStatus = platformTransactionManager.getTransaction(transactionDefinition);
    //4.执行业务操作，下面就执行2个插入操作
    try {
        System.out.println("before:" + jdbcTemplate.queryForList("SELECT * from t_user"));
        jdbcTemplate.update("insert into t_user (name) values (?)", "test1-1");
        jdbcTemplate.update("insert into t_user (name) values (?)", "test1-2");
        //5.提交事务：platformTransactionManager.commit
        platformTransactionManager.commit(transactionStatus);
    } catch (Exception e) {
        //6.回滚事务：platformTransactionManager.rollback
        platformTransactionManager.rollback(transactionStatus);
    }
    System.out.println("after:" + jdbcTemplate.queryForList("SELECT * from t_user"));
}


```

### 编程式事务过程

编程式事务过程，我们简化了一下，如下：

```
1、定义事务属性信息：TransactionDefinition transactionDefinition = new DefaultTransactionDefinition();
2、定义事务管理器：PlatformTransactionManager platformTransactionManager = new DataSourceTransactionManager(dataSource);
3、获取事务：TransactionStatus transactionStatus = platformTransactionManager.getTransaction(transactionDefinition);
4、执行sql操作：比如上面通过JdbcTemplate的各种方法执行各种sql操作
5、提交事务(platformTransactionManager.commit)或者回滚事务(platformTransactionManager.rollback)


```

下面通过源码来解析上面 4 步操作，带大家理解原理。

### 1、定义事务属性信息 (TransactionDefinition)

事务启动的过程中需要定义事务的一些配置信息，如：事务传播行为、隔离级别、超时时间、是否是只读事务、事务名称，spring 中使用 **TransactionDefinition 接口**表示事务定义信息，下面看一下 TransactionDefinition 接口源码，主要有 5 个信息

*   事务传播行为
    
*   事务隔离级别
    
*   事务超时时间
    
*   是否是只读事务
    
*   事务名称
    

```
public interface TransactionDefinition {

    //传播行为:REQUIRED
    int PROPAGATION_REQUIRED = 0;

    //传播行为:REQUIRED
    int PROPAGATION_SUPPORTS = 1;

    //传播行为:REQUIRED
    int PROPAGATION_MANDATORY = 2;

    //传播行为:REQUIRED
    int PROPAGATION_REQUIRES_NEW = 3;

    //传播行为:REQUIRED
    int PROPAGATION_NOT_SUPPORTED = 4;

    //传播行为:REQUIRED
    int PROPAGATION_NEVER = 5;

    //传播行为:REQUIRED
    int PROPAGATION_NESTED = 6;

    //默认隔离级别
    int ISOLATION_DEFAULT = -1;

    //隔离级别：读未提交
    int ISOLATION_READ_UNCOMMITTED = 1;

    //隔离级别：读已提交
    int ISOLATION_READ_COMMITTED = 2;

    //隔离级别：可重复读
    int ISOLATION_REPEATABLE_READ = 4;

    //隔离级别：序列化的方式
    int ISOLATION_SERIALIZABLE = 8;

    //默认超时时间
    int TIMEOUT_DEFAULT = -1;

    //返回事务传播行为，默认是REQUIRED
    default int getPropagationBehavior() {
        return PROPAGATION_REQUIRED;
    }

    //返回事务的隔离级别
    default int getIsolationLevel() {
        return ISOLATION_DEFAULT;
    }

    //返回事务超时时间(秒)
    default int getTimeout() {
        return -1;
    }

    //是否是只读事务
    default boolean isReadOnly() {
        return false;
    }

    //获取事务名称
    @Nullable
    default String getName() {
        return null;
    }

    //获取默认的事务定义信息
    static TransactionDefinition withDefaults() {
        return StaticTransactionDefinition.INSTANCE;
    }

}


```

TransactionDefinition 接口的实现类，比较多，我们重点关注用的比较多的 2 个

*   **DefaultTransactionDefinition**：TransactionDefinition 接口的默认的一个实现，编程式事务中通常可以使用这个
    
*   **RuleBasedTransactionAttribute**：声明式事务中用到的是这个，这个里面对于事务回滚有一些动态匹配的规则，稍后在声明式事务中去讲。
    

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06A103A9g7z4ZsGjVKTKteReeH9Rj5AIoz7TpVFYV5H4Ern8QQ0lfaxWwicRWKATrKX7gEsvSc0kubg/640?wx_fmt=png)

编程式事务中通常使用 DefaultTransactionDefinition，如下：

```
DefaultTransactionDefinition transactionDefinition = new DefaultTransactionDefinition();
//设置事务传播行为
transactionDefinition.setPropagationBehavior(TransactionDefinition.PROPAGATION_SUPPORTS);
//设置事务隔离级别
transactionDefinition.setIsolationLevel(TransactionDefinition.ISOLATION_READ_COMMITTED);
//设置是否是只读事务
transactionDefinition.setReadOnly(true);
//设置事务超时时间(s)，事务超过了指定的时间还未结束，会抛异常
transactionDefinition.setTimeout(5);
//设置事务名称，这个名称可以随便设置，不过最好起个有意义的名字，在debug的过程中会输出
transactionDefinition.setName("class完整类名.方法名称");


```

下面进入第 2 步，定义事务管理器。

### 2、定义事务管理器 (PlatformTransactionManager)

事务管理器，这是个非常重要的角色，可以把这货想象为一个人，spring 就是靠这个人来管理事务的，负责：**获取事务、提交事务、回滚事务**，Spring 中用 **PlatformTransactionManager 接口**表示事务管理器，接口中有三个方法

```
public interface PlatformTransactionManager {

    //通过事务管理器获取一个事务，返回TransactionStatus：内部包含事务的状态信息
    TransactionStatus getTransaction(@Nullable TransactionDefinition definition) throws TransactionException;

    //根据事务的状态信息提交事务
    void commit(TransactionStatus status) throws TransactionException;

    //根据事务的状态信息回滚事务
    void rollback(TransactionStatus status) throws TransactionException;

}


```

PlatformTransactionManager 有多个实现类，用来应对不同的环境，比如你操作 db 用的是 hibernate 或者 mybatis，那么用到的事务管理器是不一样的，常见的事务管理器实现有下面几个

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06A103A9g7z4ZsGjVKTKteRerkmlTjmB8ZTs3TibZfKyzVqREp5xV9olUXLkrJkToR3YamjMLfW9Rkg/640?wx_fmt=png)

**JpaTransactionManager**：如果你用 jpa 来操作 db，那么需要用这个管理器来帮你控制事务。

**DataSourceTransactionManager**：如果你用是指定数据源的方式，比如操作数据库用的是：JdbcTemplate、mybatis、ibatis，那么需要用这个管理器来帮你控制事务。

**HibernateTransactionManager**：如果你用 hibernate 来操作 db，那么需要用这个管理器来帮你控制事务。

**JtaTransactionManager**：如果你用的是 java 中的 jta 来操作 db，这种通常是分布式事务，此时需要用这种管理器来控制事务。

我们的案例中使用的是 JdbcTemplate 来操作 db，所以用的是`DataSourceTransactionManager`这个管理器。

```
PlatformTransactionManager platformTransactionManager = new DataSourceTransactionManager(dataSource);


```

下面进入第 3 步，通过事务管理器来开启事务。

### 3、获取事务

下面源码我们以 REQUIRED 中嵌套一个 REQUIRED_NEW 来进行说明，也就是事务中嵌套一个新的事务。

#### 3.1、getTransaction：获取事务

通过事务管理器的 getTransactiongetTransaction(transactionDefinition) 方法开启事务，传递一个 TransactionDefinition 参数

```
TransactionStatus transactionStatus = platformTransactionManager.getTransaction(transactionDefinition);


```

事务管理器我们用的是 DataSourceTransactionManager，下面我们看一下 DataSourceTransactionManager.getTransaction 源码

```
org.springframework.jdbc.datasource.DataSourceTransactionManager

public final TransactionStatus getTransaction(@Nullable TransactionDefinition definition) throws TransactionException {

    //事务定义信息，若传入的definition如果为空，取默认的
    TransactionDefinition def = (definition != null ? definition : TransactionDefinition.withDefaults());

    //@3.1-1：获取事务对象
    Object transaction = doGetTransaction();
    boolean debugEnabled = logger.isDebugEnabled();

    //@3.1-2：当前是否存在事务
    if (isExistingTransaction(transaction)) {
        //@1-3：如果当前存在事务，走这里
        return handleExistingTransaction(def, transaction, debugEnabled);
    }
    // 当前没有事务，走下面的代码
    // 若事务传播级别是PROPAGATION_MANDATORY：要求必须存在事务，若当前没有事务，弹出异常
    if (def.getPropagationBehavior() == TransactionDefinition.PROPAGATION_MANDATORY) {
        throw new IllegalTransactionStateException(
                "No existing transaction found for transaction marked with propagation 'mandatory'");
    } else if (def.getPropagationBehavior() == TransactionDefinition.PROPAGATION_REQUIRED ||
            def.getPropagationBehavior() == TransactionDefinition.PROPAGATION_REQUIRES_NEW ||
            def.getPropagationBehavior() == TransactionDefinition.PROPAGATION_NESTED) {
        //事务传播行为(PROPAGATION_REQUIRED|PROPAGATION_REQUIRES_NEW|PROPAGATION_NESTED)走这里
        //@3.1-4：挂起事务
        SuspendedResourcesHolder suspendedResources = suspend(null);
        try {
            //@3.1-5：是否开启新的事务同步
            boolean newSynchronization = (getTransactionSynchronization() != SYNCHRONIZATION_NEVER);
            //@3.1-6：创建事务状态对象DefaultTransactionStatus,DefaultTransactionStatus是TransactionStatus的默认实现
            DefaultTransactionStatus status = newTransactionStatus(def, transaction, true, newSynchronization, debugEnabled, suspendedResources);
            //@3.1-7：doBegin用于开始事务
            doBegin(transaction, def);
            //@3.1-8：准备事务同步
            prepareSynchronization(status, def);
            //@3.1-9：返回事务状态对象
            return status;
        } catch (RuntimeException | Error ex) {
            //@3.1-10：出现（RuntimeException|Error）恢复被挂起的事务
            resume(null, suspendedResources);
            throw ex;
        }
    } else {
        //@3.1-11：其他事务传播行为的走这里(PROPAGATION_SUPPORTS、PROPAGATION_NOT_SUPPORTED、PROPAGATION_NEVER)
        boolean newSynchronization = (getTransactionSynchronization() == SYNCHRONIZATION_ALWAYS);
        return prepareTransactionStatus(def, null, true, newSynchronization, debugEnabled, null);
    }
}


```

下面来看一下 @3.1-1：doGetTransaction 方法，用来获取事务对象

#### 3.2、doGetTransaction：获取事务对象

```
org.springframework.jdbc.datasource.DataSourceTransactionManager

protected Object doGetTransaction() {
    //@3.2-1：创建数据源事务对象
    DataSourceTransactionObject txObject = new DataSourceTransactionObject();
    //@3.2-2：是否支持内部事务
    txObject.setSavepointAllowed(isNestedTransactionAllowed());
    //@3.2-4：ConnectionHolder表示jdbc连接持有者，简单理解：数据的连接被丢到ConnectionHolder中了，ConnectionHolder中提供了一些方法来返回里面的连接，此处调用TransactionSynchronizationManager.getResource方法来获取ConnectionHolder对象
    ConnectionHolder conHolder = (ConnectionHolder) TransactionSynchronizationManager.getResource(obtainDataSource());
    //@3.2-5：将conHolder丢到DataSourceTransactionObject中，第二个参数表示是否是一个新的连接，明显不是的吗，新的连接需要通过datasource来获取，通过datasource获取的连接才是新的连接
    txObject.setConnectionHolder(conHolder, false);
    return txObject;
}


```

下面来看一下`@3.2-4`的代码，这个是重点了，这个用到了一个新的类`TransactionSynchronizationManager:事务同步管理器`，什么叫同步？一个事务过程中，被调用的方法都在一个线程中串行执行，就是同步；这个类中用到了很多 ThreadLocal，用来在线程中存储事务相关的一些信息,，来瞅一眼

```
public abstract class TransactionSynchronizationManager {

    //存储事务资源信息
    private static final ThreadLocal<Map<Object, Object>> resources =
            new NamedThreadLocal<>("Transactional resources");

    //存储事务过程中的一些回调接口(TransactionSynchronization接口，这个可以在事务的过程中给开发者提供一些回调用的)
    private static final ThreadLocal<Set<TransactionSynchronization>> synchronizations =
            new NamedThreadLocal<>("Transaction synchronizations");

    //存储当前正在运行的事务的名称
    private static final ThreadLocal<String> currentTransactionName =
            new NamedThreadLocal<>("Current transaction name");

    //存储当前正在运行的事务是否是只读的
    private static final ThreadLocal<Boolean> currentTransactionReadOnly =
            new NamedThreadLocal<>("Current transaction read-only status");

    //存储当前正在运行的事务的隔离级别
    private static final ThreadLocal<Integer> currentTransactionIsolationLevel =
            new NamedThreadLocal<>("Current transaction isolation level");

    //存储当前正在运行的事务是否是活动状态，事务启动的时候会被激活
    private static final ThreadLocal<Boolean> actualTransactionActive =
            new NamedThreadLocal<>("Actual transaction active");

    //还有很多静态方法，主要是用来操作上面这些ThreadLocal的，这里就不列出的，大家可以去看看
}


```

下面来看 TransactionSynchronizationManager.getResource 代码

```
ConnectionHolder conHolder = (ConnectionHolder) TransactionSynchronizationManager.getResource(obtainDataSource());


```

obtainDataSource() 会返回事务管理器中的 datasource 对象

```
protected DataSource obtainDataSource() {
    DataSource dataSource = getDataSource();
    Assert.state(dataSource != null, "No DataSource set");
    return dataSource;
}


```

下面看 TransactionSynchronizationManager.getResource 的源码

```
public static Object getResource(Object key) {
    //通过TransactionSynchronizationUtils.unwrapResourceIfNecessary(key)获取一个actualKey，我们传入的是datasouce，实际上最后actualKey和传入的datasource是一个对象
    Object actualKey = TransactionSynchronizationUtils.unwrapResourceIfNecessary(key);
    //调用doGetResource方法获取对应的value
    Object value = doGetResource(actualKey);
    return value;
}


```

doGetResource(actualKey) 方法如下，内部会从 resources 这个 ThreadLocal 中获取获取数据 ConnectionHolder 对象，到目前为止，根本没有看到向 resource 中放入过数据，获取获取到的 conHolder 肯定是 null 了

```
static final ThreadLocal<Map<Object, Object>> resources = new NamedThreadLocal<>("Transactional resources");

private static Object doGetResource(Object actualKey) {
    Map<Object, Object> map = resources.get();
    if (map == null) {
        return null;
    }
    Object value = map.get(actualKey);
    return value;
}


```

TransactionSynchronizationManager.getResource：可以理解为从 resource ThreadLocal 中查找 transactionManager.datasource 绑定的 ConnectionHolder 对象

到此，Object transaction = doGetTransaction() 方法执行完毕，下面我们再回到 getTransaction 方法，第一次进来，上下文中是没有事务的，所以会走下面的 @3.1-4 的代码，当前没有事务，导致没有事务需要挂起，所以 suspend 方法内部可以先忽略

```
org.springframework.transaction.support.AbstractPlatformTransactionManager#getTransaction

public final TransactionStatus getTransaction(@Nullable TransactionDefinition definition)
        throws TransactionException {

    //事务定义信息，若传入的definition如果为空，取默认的
    TransactionDefinition def = (definition != null ? definition : TransactionDefinition.withDefaults());

    //@3.1-1：获取事务对象
    Object transaction = doGetTransaction();

    if (def.getPropagationBehavior() == TransactionDefinition.PROPAGATION_REQUIRED ||
            def.getPropagationBehavior() == TransactionDefinition.PROPAGATION_REQUIRES_NEW ||
            def.getPropagationBehavior() == TransactionDefinition.PROPAGATION_NESTED) {
        //事务传播行为(PROPAGATION_REQUIRED|PROPAGATION_REQUIRES_NEW|PROPAGATION_NESTED)走这里
        //@3.1-4：挂起事务
        SuspendedResourcesHolder suspendedResources = suspend(null);
        try {
            //@3.1-5：是否开启新的事务同步
            boolean newSynchronization = (getTransactionSynchronization() != SYNCHRONIZATION_NEVER);
            //@3.1-6：创建事务状态对象DefaultTransactionStatus,DefaultTransactionStatus是TransactionStatus的默认实现
            DefaultTransactionStatus status = newTransactionStatus(
                    def, transaction, true, newSynchronization, debugEnabled, suspendedResources);
            //@3.1-7：doBegin用于开始事务
            doBegin(transaction, def);
            //@3.1-8：准备事务同步
            prepareSynchronization(status, def);
            //@3.1-9：返回事务状态对象
            return status;
        } catch (RuntimeException | Error ex) {
            //@3.1-10：出现（RuntimeException|Error）恢复被挂起的事务
            resume(null, suspendedResources);
            throw ex;
        }
    }
}


```

然后会执行下面代码

```
//@3.1-5：是否开启新的事务同步，事务同步是干嘛的，是spring在事务过程中给开发者预留的一些扩展点，稍后细说；大家先这么理解，每个新的事务newSynchronization都是true，开一个一个新的事务就会启动一个新的同步
boolean newSynchronization = (getTransactionSynchronization() != SYNCHRONIZATION_NEVER);
//@3.1-6：创建事务状态对象DefaultTransactionStatus,DefaultTransactionStatus是TransactionStatus的默认实现
DefaultTransactionStatus status = newTransactionStatus(def, transaction, true, newSynchronization, debugEnabled, suspendedResources);
//@3.1-7：doBegin用于开始事务
doBegin(transaction, def);
//@3.1-8：准备事务同步
prepareSynchronization(status, def);
//@3.1-9：返回事务状态对象
return status;


```

上面过程我们重点来说一下 @3.1-7 和 @3.1-8

#### 3.3、@3.1-7：doBegin 开启事务

```
org.springframework.jdbc.datasource.DataSourceTransactionManager#doBegin

protected void doBegin(Object transaction, TransactionDefinition definition) {
    //数据源事务对象
    DataSourceTransactionObject txObject = (DataSourceTransactionObject) transaction;
    //数据库连接
    Connection con = null;
    try {
        //txObject.hasConnectionHolder()用来判断txObject.connectionHolder!=null，现在肯定是null，所以txObject.hasConnectionHolder()返回false
        if (!txObject.hasConnectionHolder() ||
                txObject.getConnectionHolder().isSynchronizedWithTransaction()) {
            //调用transactionManager.datasource.getConnection()获取一个数据库连接
            Connection newCon = obtainDataSource().getConnection();
            //将数据库连接丢到一个ConnectionHolder中，放到txObject中，注意第2个参数是true，表示第一个参数的ConnectionHolder是新创建的
            txObject.setConnectionHolder(new ConnectionHolder(newCon), true);
        }
        //连接中启动事务同步
        txObject.getConnectionHolder().setSynchronizedWithTransaction(true);
        //获取连接
        con = txObject.getConnectionHolder().getConnection();
        //获取隔离级别
        Integer previousIsolationLevel = DataSourceUtils.prepareConnectionForTransaction(con, definition);
        //设置隔离级别
        txObject.setPreviousIsolationLevel(previousIsolationLevel);
        //设置是否是只读
        txObject.setReadOnly(definition.isReadOnly());

        //判断连接是否是自动提交的，如果是自动提交的将其置为手动提交
        if (con.getAutoCommit()) {
            //在txObject中存储一下连接自动提交老的值，用于在事务执行完毕之后，还原一下Connection的autoCommit的值
            txObject.setMustRestoreAutoCommit(true);
            //设置手动提交
            con.setAutoCommit(false);
        }
        //准备事务连接
        prepareTransactionalConnection(con, definition);
        //设置事务活动开启
        txObject.getConnectionHolder().setTransactionActive(true);

        //根据事务定义信息获取事务超时时间
        int timeout = determineTimeout(definition);
        if (timeout != TransactionDefinition.TIMEOUT_DEFAULT) {
            //设置连接的超时时间
            txObject.getConnectionHolder().setTimeoutInSeconds(timeout);
        }
        //txObject中的ConnectionHolder是否是一个新的，确实是新的，所以这个地方返回true
        if (txObject.isNewConnectionHolder()) {
            //将datasource->ConnectionHolder丢到resource ThreadLocal的map中
            TransactionSynchronizationManager.bindResource(obtainDataSource(), txObject.getConnectionHolder());
        }
    }
}


```

重点来看一下下面这段代码

```
TransactionSynchronizationManager.bindResource(obtainDataSource(), txObject.getConnectionHolder());


```

源码

```
org.springframework.transaction.support.TransactionSynchronizationManager#bindResource

public static void bindResource(Object key, Object value) throws IllegalStateException {
    Object actualKey = TransactionSynchronizationUtils.unwrapResourceIfNecessary(key);
    Map<Object, Object> map = resources.get();
    if (map == null) {
        map = new HashMap<>();
        resources.set(map);
    }
    map.put(actualKey, value);
}


```

上面这段代码执行完毕之后，datasource->ConnectionHoloder(conn) 被放到 resources Threadloca 的 map 中了。

#### 3.4、@3.1-8：prepareSynchronization 准备事务同步

```
//@3.1-8：准备事务同步
prepareSynchronization(status, def);


```

源码如下，大家看一下，这个方法主要的作用是，开启一个新事务的时候，会将事务的状态、隔离级别、是否是只读事务、事务名称丢到 TransactionSynchronizationManager 中的各种对应的 ThreadLocal 中，方便在当前线程中共享这些数据。

```
org.springframework.transaction.support.AbstractPlatformTransactionManager#prepareSynchronization
    
protected void prepareSynchronization(DefaultTransactionStatus status, TransactionDefinition definition) {
    //如果是一个新的事务，status.isNewSynchronization()将返回true
    if (status.isNewSynchronization()) {
        TransactionSynchronizationManager.setActualTransactionActive(status.hasTransaction());
        TransactionSynchronizationManager.setCurrentTransactionIsolationLevel(
                definition.getIsolationLevel() != TransactionDefinition.ISOLATION_DEFAULT ?
                        definition.getIsolationLevel() : null);
        TransactionSynchronizationManager.setCurrentTransactionReadOnly(definition.isReadOnly());
        TransactionSynchronizationManager.setCurrentTransactionName(definition.getName());
        //@3.4-1：初始化事务同步
        TransactionSynchronizationManager.initSynchronization();
    }
}


```

@3.4-1：初始化事务同步

```
org.springframework.transaction.support.TransactionSynchronizationManager

private static final ThreadLocal<Set<TransactionSynchronization>> synchronizations =
   new NamedThreadLocal<>("Transaction synchronizations");

//获取同步是否启动，新事务第一次进来synchronizations.get()是null，所以这个方法返回的是false
public static boolean isSynchronizationActive() {
    return (synchronizations.get() != null);
}

//初始化事务同步，主要就是在synchronizations ThreadLocal中放一个LinkedHashSet
public static void initSynchronization() throws IllegalStateException {
    if (isSynchronizationActive()) {
        throw new IllegalStateException("Cannot activate transaction synchronization - already active");
    }
    synchronizations.set(new LinkedHashSet<>());
}


```

#### 3.5、小结

获取事务的过程已经结束了，我们来看一下这个过程中做的一些关键的事情

```
1、获取db连接：从事务管理器的datasource中调用getConnection获取一个新的数据库连接，将连接置为手动提交
2、将datasource关联连接丢到ThreadLocal中：将第一步中获取到的连丢到ConnectionHolder中，然后将事务管理器的datasource->ConnectionHolder丢到了resource ThreadLocal中，这样我们可以通过datasource在ThreadLocal中获取到关联的数据库连接
3、准备事务同步：将事务的一些信息放到ThreadLocal中


```

### 4、事务方法中执行增删改查

以下面这个插入操作来看一下这个插入是如何参与到 spring 事务中的。

```
jdbcTemplate.update("insert into t_user (name) values (?)", "test1-1");


```

最终会进入到 jdbctemplate#execute 方法里，无用代码我们给剔除，重点内部关注下面获取连接的方法

```
org.springframework.jdbc.core.JdbcTemplate#execute(org.springframework.jdbc.core.PreparedStatementCreator, org.springframework.jdbc.core.PreparedStatementCallback<T>){
    //获取数据库连接
    Connection con = DataSourceUtils.getConnection(obtainDataSource());
    //通过conn执行db操作
}


```

obtainDataSource() 会返回 jdbctemplate.datasource 对象，下面重点来看 DataSourceUtils.getConnection 源码，最终会进入下面这个方法

```
org.springframework.jdbc.datasource.DataSourceUtils#doGetConnection
    
public static Connection doGetConnection(DataSource dataSource) throws SQLException {
    //用jdbctemplate.datSource从TransactionSynchronizationManager的resouce ThreadLocal中获取对应的ConnectionHolder对象，在前面获取事务环节中，transactionManager.datasource->ConnectionHolder被丢到resouce ThreadLocal，而jdbctemplate.datSource和transactionManager.datasource是同一个对象，所以是可以获取到ConnectionHolder的，此时就会使用事务开启是的数据库连接
    ConnectionHolder conHolder = (ConnectionHolder) TransactionSynchronizationManager.getResource(dataSource);
    //conHolder不为空 && conHolder中有数据库连接对象
    if (conHolder != null && (conHolder.hasConnection() || conHolder.isSynchronizedWithTransaction())) {
        //返回conHolder中的数据库连接对象
        return conHolder.getConnection();
    }

    //如果上面获取不到连接，会走这里，这里将会调用jdbctemplate.datasource.getConnection()从数据源中获取一个新的db连接
    Connection con = fetchConnection(dataSource);
    //将连接返回
    return con;
}


```

**可以得出一个结论：如果要让最终执行的 sql 受 spring 事务控制，那么事务管理器中 datasource 对象必须和 jdbctemplate.datasource 是同一个，这个结论在其他文章中说过很多次了，这里大家算是搞明白了吧。**

### 5、提交事务

调用事务管理器的 commit 方法，提交事务

```
platformTransactionManager.commit(transactionStatus);


```

commit 源码

```
org.springframework.transaction.support.AbstractPlatformTransactionManager#commit

public final void commit(TransactionStatus status) throws TransactionException {
    //事务是否已经完成，此时还未完成，如果事务完成了，再来调用commit方法会报错
    if (status.isCompleted()) {
        throw new IllegalTransactionStateException(
                "Transaction is already completed - do not call commit or rollback more than once per transaction");
    }
    //事务状态
    DefaultTransactionStatus defStatus = (DefaultTransactionStatus) status;
    //defStatus.rollbackOnly是否是true，如果是true，说明事务状态被标注了需要回滚，此时走回滚逻辑
    if (defStatus.isLocalRollbackOnly()) {
        //走回滚逻辑
        processRollback(defStatus, false);
        return;
    }
    //提交事务过程
    processCommit(defStatus);
}


```

processCommit 源码

```
org.springframework.transaction.support.AbstractPlatformTransactionManager#processCommit

private void processCommit(DefaultTransactionStatus status) throws TransactionException {
    try {
        try {
            //提交之前的回调（给开发提供的扩展点）
            triggerBeforeCommit(status);
            //事务完成之前的回调（给开发提供的扩展点）
            triggerBeforeCompletion(status);
            //是否是新事务，如果是新事务，将执行提交操作，比如传播行为是REQUIRED中嵌套了一个REQUIRED，那么内部的事务就不是新的事务，外部的事务是新事务
            if (status.isNewTransaction()) {
                //@5-1：执行提交操作
                doCommit(status);
            }
        } catch (UnexpectedRollbackException ex) {
            //事务完成之后执行的回调（给开发提供的扩展点）
            triggerAfterCompletion(status, TransactionSynchronization.STATUS_ROLLED_BACK);
            throw ex;
        } catch (RuntimeException | Error ex) {
            //提交过程中有异常,执行回滚操作
            doRollbackOnCommitException(status, ex);
            throw ex;
        }
        try {
            //事务commit之后，执行一些回调（给开发提供的扩展点）
            triggerAfterCommit(status);
        } finally {
            //事务完成之后，执行一些回调（给开发提供的扩展点）
            triggerAfterCompletion(status, TransactionSynchronization.STATUS_COMMITTED);
        }
    } finally {
        //事务执行完毕之后，执行一些清理操作
        cleanupAfterCompletion(status);
    }
}


```

上面这个方法看起来挺长的，重点会做 **3 件**事情：

**1、给开发提供的扩展点**：以 trigger 开头的方法，是留给开发的扩展点，可以在事务执行的过程中执行一些回调，主要是在事务提交之前，提交之后，回滚之前，回滚之后，可以执行一些回调，也就是事务同步要干的事情，这个扩展点稍后说。

**2、通过 connection 执行 commit 操作**，对应上面的 @5-1 代码：doCommit(status);

**3、完成之后执行清理操作**：finally 中执行 cleanupAfterCompletion(status);

来看看 **doCommit(status) 方法**，内部主要就是调用 connection 的 commit() 提交事务，如下：

```
org.springframework.jdbc.datasource.DataSourceTransactionManager#doCommit

protected void doCommit(DefaultTransactionStatus status) {
    DataSourceTransactionObject txObject = (DataSourceTransactionObject) status.getTransaction();
    //从ConnectionHolder中获取Connection
    Connection con = txObject.getConnectionHolder().getConnection();
    //执行commit，提交数据库事务
    con.commit();
}


```

cleanupAfterCompletion(status)：清理操作

```
org.springframework.transaction.support.AbstractPlatformTransactionManager#cleanupAfterCompletion

private void cleanupAfterCompletion(DefaultTransactionStatus status) {
    //将事务状态置为已完成
    status.setCompleted();
    //是否是新的事务同步
    if (status.isNewSynchronization()) {
        //将TransactionSynchronizationManager中的那些ThreadLoca中的数据都清除，会调用ThreadLocal的remove()方法清除数据
        TransactionSynchronizationManager.clear();
    }
    //是否是新事务
    if (status.isNewTransaction()) {
        //执行清理操作
        doCleanupAfterCompletion(status.getTransaction());
    }
    //是否有被挂起的事务
    if (status.getSuspendedResources() != null) {
        Object transaction = (status.hasTransaction() ? status.getTransaction() : null);
        //恢复被挂起的事务
        resume(transaction, (SuspendedResourcesHolder) status.getSuspendedResources());
    }
}


```

doCleanupAfterCompletion 源码

```
org.springframework.jdbc.datasource.DataSourceTransactionManager#doCleanupAfterCompletion
    
protected void doCleanupAfterCompletion(Object transaction) {
    DataSourceTransactionObject txObject = (DataSourceTransactionObject) transaction;

    //是否是一个新的ConnectionHolder，如果是新的事务，那么ConnectionHolder是新的
    if (txObject.isNewConnectionHolder()) {
        //将transactionManager.datasource->ConnectionHolder从resource Threadlocal中干掉
        TransactionSynchronizationManager.unbindResource(obtainDataSource());
    }
    //下面重置Connection，将Connection恢复到最原始的状态
    Connection con = txObject.getConnectionHolder().getConnection();
    try {
        if (txObject.isMustRestoreAutoCommit()) {
            //自动提交
            con.setAutoCommit(true);
        }
        //恢复connction的隔离级别、是否是只读事务
        DataSourceUtils.resetConnectionAfterTransaction(
                con, txObject.getPreviousIsolationLevel(), txObject.isReadOnly());
    } catch (Throwable ex) {
        logger.debug("Could not reset JDBC Connection after transaction", ex);
    }
    //是否是新的连接
    if (txObject.isNewConnectionHolder()) {
        //释放连接，内部会调用conn.close()方法
        DataSourceUtils.releaseConnection(con, this.dataSource);
    }
    //还原ConnectionHoloder到最初的状态
    txObject.getConnectionHolder().clear();
}


```

终结一下，**清理工作主要做的事情就是释放当前线程占有的一切资源，然后将被挂起的事务恢复**。

### 6、回滚事务

回滚的操作和提交的操作差不多的，源码我就不讲了，大家自己去看一下。

### 7、存在事务的情况如何走？

下面来看另外一个流程，REQUIRED 中嵌套一个 REQUIRED_NEW，然后走到 REQUIRED_NEW 的时候，代码是如何运行的？大致的过程如下

**1、判断上线文中是否有事务**

**2、挂起当前事务**

**3、开启新事务，并执行新事务**

**4、恢复被挂起的事务**

#### 7.1、判断是否有事务：isExistingTransaction

判断上线文中是否有事务，比较简单，如下：

```
org.springframework.jdbc.datasource.DataSourceTransactionManager#isExistingTransaction

protected boolean isExistingTransaction(Object transaction) {
    DataSourceTransactionObject txObject = (DataSourceTransactionObject) transaction;
    //txObject.connectionHolder!=null && connectionHolder事务处于开启状态(上面我们介绍过在doBegin开启事务的时候connectionHolder.transactionActive会被置为true)
    return (txObject.hasConnectionHolder() && txObject.getConnectionHolder().isTransactionActive());
}


```

#### 7.2、若当前存在事务

我们再来看一下获取事务中，有事务如何走

```
org.springframework.transaction.support.AbstractPlatformTransactionManager#getTransaction

public final TransactionStatus getTransaction(@Nullable TransactionDefinition definition) throws TransactionException {
    //获取事务
    Object transaction = doGetTransaction();

    //是否存在事务
    if (isExistingTransaction(transaction)) {
        //存在事务会走这里
        return handleExistingTransaction(def, transaction, debugEnabled);
    }
}


```

当前存在事务，然后会进入 handleExistingTransaction 方法

```
org.springframework.transaction.support.AbstractPlatformTransactionManager#handleExistingTransaction

private TransactionStatus handleExistingTransaction(TransactionDefinition definition, Object transaction, boolean debugEnabled) throws TransactionException {
    //当前有事务，被嵌套的事务传播行为是PROPAGATION_NEVER，抛出异常
    if (definition.getPropagationBehavior() == TransactionDefinition.PROPAGATION_NEVER) {
        throw new IllegalTransactionStateException(
                "Existing transaction found for transaction marked with propagation 'never'");
    }

    if (definition.getPropagationBehavior() == TransactionDefinition.PROPAGATION_NOT_SUPPORTED) {
        //当前有事务，被嵌套的事务传播行为是PROPAGATION_NOT_SUPPORTED，那么将先调用suspend将当前事务挂起，然后以无事务的方式运行被嵌套的事务
        //挂起当前事务
        Object suspendedResources = suspend(transaction);
        boolean newSynchronization = (getTransactionSynchronization() == SYNCHRONIZATION_ALWAYS);
        //以无事务的方式运行
        return prepareTransactionStatus(
                definition, null, false, newSynchronization, debugEnabled, suspendedResources);
    }

    if (definition.getPropagationBehavior() == TransactionDefinition.PROPAGATION_REQUIRES_NEW) {
        //被嵌套的事务传播行为是PROPAGATION_REQUIRES_NEW，那么会先挂起当前事务，然后会重新开启一个新的事务
        //挂起当前事务
        SuspendedResourcesHolder suspendedResources = suspend(transaction);
        try {
            //下面的过程我们就不在再介绍了，之前有介绍过
            boolean newSynchronization = (getTransactionSynchronization() != SYNCHRONIZATION_NEVER);
            DefaultTransactionStatus status = newTransactionStatus(
                    definition, transaction, true, newSynchronization, debugEnabled, suspendedResources);
            doBegin(transaction, definition);
            prepareSynchronization(status, definition);
            return status;
        } catch (RuntimeException | Error beginEx) {
            resumeAfterBeginException(transaction, suspendedResources, beginEx);
            throw beginEx;
        }
    }
    //其他的传播行为走下面。。。，暂时省略了
}


```

下面重点看事务挂起和事务的恢复操作。

#### 7.3、事务挂起：suspend

事务挂起调用事务管理器的 suspend 方法，源码如下，主要做的事情：将当前事务中的一切信息保存到 SuspendedResourcesHolder 对象中，相当于事务的快照，后面恢复的时候用；然后将事务现场清理干净，主要是将一堆存储在 ThreadLocal 中的事务数据干掉。

```
org.springframework.transaction.support.AbstractPlatformTransactionManager#suspend

protected final SuspendedResourcesHolder suspend(@Nullable Object transaction) throws TransactionException {
    //当前事务同步是否被激活，如果是新事务，这个返回的是true
    if (TransactionSynchronizationManager.isSynchronizationActive()) {
        //挂起事务同步，这个地方会可以通过TransactionSynchronization接口给开发者提供了扩展点，稍后我们会单独介绍TransactionSynchronization接口，这个接口专门用来在事务执行过程中做回调的
        List<TransactionSynchronization> suspendedSynchronizations = doSuspendSynchronization();
        try {
            Object suspendedResources = null;
            if (transaction != null) {
                //@1：获取挂起的资源
                suspendedResources = doSuspend(transaction);
            }
            //下面就是获取当前事务的各种信息(name,readyOnly,事务隔离级别,是否被激活)
            String name = TransactionSynchronizationManager.getCurrentTransactionName();
            TransactionSynchronizationManager.setCurrentTransactionName(null);
            boolean readOnly = TransactionSynchronizationManager.isCurrentTransactionReadOnly();
            TransactionSynchronizationManager.setCurrentTransactionReadOnly(false);
            Integer isolationLevel = TransactionSynchronizationManager.getCurrentTransactionIsolationLevel();
            TransactionSynchronizationManager.setCurrentTransactionIsolationLevel(null);
            boolean wasActive = TransactionSynchronizationManager.isActualTransactionActive();
            TransactionSynchronizationManager.setActualTransactionActive(false);
            return new SuspendedResourcesHolder(
                    suspendedResources, suspendedSynchronizations, name, readOnly, isolationLevel, wasActive);
        }
    }
}


```

下面来看看`@1：doSuspend(transaction)`源码，主要就是将 datasource->connectionHolder 从 resource ThreadLocal 中解绑，然后将 connectionHolder 返回，下面这个方法实际上返回的就是 connectionHolder 对象

```
org.springframework.jdbc.datasource.DataSourceTransactionManager#doSuspend

protected Object doSuspend(Object transaction) {
    DataSourceTransactionObject txObject = (DataSourceTransactionObject) transaction;
    //将connectionHolder置为null
    txObject.setConnectionHolder(null);
    //将datasource->connectionHolder从resource ThreadLocal中解绑，并返回被解绑的connectionHolder对象
    return TransactionSynchronizationManager.unbindResource(obtainDataSource());
}


```

此时，当前的事务被挂起了，然后开启一个新的事务，新的事务的过程上面已经介绍过了，下面我们来看事务的恢复过程。

#### 7.4、事务恢复：resume

事务挂起调用事务管理器的 resume 方法，源码如下，主要做的事情：通过 SuspendedResourcesHolder 对象中，将被挂起的事务恢复，SuspendedResourcesHolder 对象中保存了被挂起的事务所有信息，所以可以通过这个对象来恢复事务。

```
org.springframework.transaction.support.AbstractPlatformTransactionManager#resume

protected final void resume(@Nullable Object transaction, @Nullable SuspendedResourcesHolder resourcesHolder)
        throws TransactionException {
    if (resourcesHolder != null) {
        Object suspendedResources = resourcesHolder.suspendedResources;
        if (suspendedResources != null) {
            //恢复被挂起的资源，也就是将datasource->connectionHolder绑定到resource ThreadLocal中
            doResume(transaction, suspendedResources);
        }
        List<TransactionSynchronization> suspendedSynchronizations = resourcesHolder.suspendedSynchronizations;
        //下面就是将数据恢复到各种ThreadLocal中
        if (suspendedSynchronizations != null) {
            TransactionSynchronizationManager.setActualTransactionActive(resourcesHolder.wasActive);
            TransactionSynchronizationManager.setCurrentTransactionIsolationLevel(resourcesHolder.isolationLevel);
            TransactionSynchronizationManager.setCurrentTransactionReadOnly(resourcesHolder.readOnly);
            TransactionSynchronizationManager.setCurrentTransactionName(resourcesHolder.name);
            //恢复事务同步（将事务扩展点恢复）
            doResumeSynchronization(suspendedSynchronizations);
        }
    }
}


```

### 8、事务执行过程中的回调接口： TransactionSynchronization

#### 8.1、作用

spring 事务运行的过程中，给开发者预留了一些扩展点，在事务执行的不同阶段，将回调扩展点中的一些方法。

比如我们想在事务提交之前、提交之后、回滚之前、回滚之后做一些事务，那么可以通过扩展点来实现。

#### 8.2、扩展点的用法

##### 1、定义事务 TransactionSynchronization 对象

TransactionSynchronization 接口中的方法在 spring 事务执行的过程中会自动被回调

```
public interface TransactionSynchronization extends Flushable {

    //提交状态
    int STATUS_COMMITTED = 0;

    //回滚状态
    int STATUS_ROLLED_BACK = 1;

    //状态未知，比如事务提交或者回滚的过程中发生了异常，那么事务的状态是未知的
    int STATUS_UNKNOWN = 2;

    //事务被挂起的时候会调用被挂起事务中所有TransactionSynchronization的resume方法
    default void suspend() {
    }

    //事务恢复的过程中会调用被恢复的事务中所有TransactionSynchronization的resume方法
    default void resume() {
    }

    //清理操作
    @Override
    default void flush() {
    }

    //事务提交之前调用
    default void beforeCommit(boolean readOnly) {
    }

    //事务提交或者回滚之前调用
    default void beforeCompletion() {
    }

    //事务commit之后调用
    default void afterCommit() {
    }

    //事务完成之后调用
    default void afterCompletion(int status) {
    }

}


```

##### 2、将 TransactionSynchronization 注册到当前事务中

通过下面静态方法将事务扩展点 TransactionSynchronization 注册到当前事务中

```
TransactionSynchronizationManager.registerSynchronization(transactionSynchronization)


```

看一下源码，很简单，丢到 ThreadLocal 中了

```
private static final ThreadLocal<Set<TransactionSynchronization>> synchronizations =
   new NamedThreadLocal<>("Transaction synchronizations");

public static void registerSynchronization(TransactionSynchronization synchronization)
   throws IllegalStateException {
    Set<TransactionSynchronization> synchs = synchronizations.get();
    if (synchs == null) {
        throw new IllegalStateException("Transaction synchronization is not active");
    }
    synchs.add(synchronization);
}


```

当有多个 TransactionSynchronization 的时候，可以指定其顺序，可以实现 org.springframework.core.Ordered 接口，来指定顺序，从小大的排序被调用，TransactionSynchronization 有个默认适配器 TransactionSynchronizationAdapter，这个类实现了 Ordered 接口，所以，如果我们要使用的时候，直接使用 TransactionSynchronizationAdapter 这个类。

##### 3、回调扩展点 TransactionSynchronization 中的方法

TransactionSynchronization 中的方法是 spring 事务管理器自动调用的，本文上面有提交到，事务管理器在事务提交或者事务回滚的过程中，有很多地方会调用 trigger 开头的方法，这个 trigger 方法内部就会遍历当前事务中的 transactionSynchronization 列表，然后调用 transactionSynchronization 内部的一些指定的方法。

以事务提交的源码为例，来看一下

```
private void processCommit(DefaultTransactionStatus status) throws TransactionException {
    triggerBeforeCommit(status);
    triggerBeforeCompletion(status);
    //....其他代码省略
}


```

triggerBeforeCommit(status) 源码

```
protected final void triggerBeforeCommit(DefaultTransactionStatus status) {
    if (status.isNewSynchronization()) {
        TransactionSynchronizationUtils.triggerBeforeCommit(status.isReadOnly());
    }
}


```

TransactionSynchronizationUtils.triggerBeforeCommit 源码

```
public static void triggerBeforeCommit(boolean readOnly) {
    for (TransactionSynchronization synchronization : TransactionSynchronizationManager.getSynchronizations()) {
        synchronization.beforeCommit(readOnly);
    }
}


```

#### 8.3、来个案例

##### 1、执行 sql

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

##### 2、案例代码

代码比较简单，不多解释了，运行测试方法 m0

```
package com.javacode2018.tx.demo9;

import org.junit.Before;
import org.junit.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.transaction.support.TransactionSynchronizationAdapter;
import org.springframework.transaction.support.TransactionSynchronizationManager;

/**
 * 公众号：路人甲java，工作10年的前阿里P7,所有文章以系列的方式呈现，带领大家成为java高手，
 * 目前已出：java高并发系列、mysq|高手系列、Maven高手系列、mybatis系列、spring系列，
 * 正在连载springcloud系列，欢迎关注！
 */
public class Demo9Test {
    JdbcTemplate jdbcTemplate;
    PlatformTransactionManager platformTransactionManager;

    @Before
    public void before() {
        //定义一个数据源
        org.apache.tomcat.jdbc.pool.DataSource dataSource = new org.apache.tomcat.jdbc.pool.DataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:3306/javacode2018?characterEncoding=UTF-8");
        dataSource.setUsername("root");
        dataSource.setPassword("root123");
        dataSource.setInitialSize(5);
        //定义一个JdbcTemplate，用来方便执行数据库增删改查
        this.jdbcTemplate = new JdbcTemplate(dataSource);
        this.platformTransactionManager = new DataSourceTransactionManager(dataSource);
        this.jdbcTemplate.update("truncate table t_user");
    }

    @Test
    public void m0() throws Exception {
        System.out.println("PROPAGATION_REQUIRED start");
        //2.定义事务属性：TransactionDefinition，TransactionDefinition可以用来配置事务的属性信息，比如事务隔离级别、事务超时时间、事务传播方式、是否是只读事务等等。
        TransactionDefinition transactionDefinition = new DefaultTransactionDefinition(TransactionDefinition.PROPAGATION_REQUIRED);
        //3.开启事务：调用platformTransactionManager.getTransaction开启事务操作，得到事务状态(TransactionStatus)对象
        TransactionStatus transactionStatus = platformTransactionManager.getTransaction(transactionDefinition);
        this.addSynchronization("ts-1", 2);
        this.addSynchronization("ts-2", 1);
        //4.执行业务操作，下面就执行2个插入操作
        jdbcTemplate.update("insert into t_user (name) values (?)", "test1-1");
        jdbcTemplate.update("insert into t_user (name) values (?)", "test1-2");
        this.m1();
        //5.提交事务：platformTransactionManager.commit
        System.out.println("PROPAGATION_REQUIRED 准备commit");
        platformTransactionManager.commit(transactionStatus);
        System.out.println("PROPAGATION_REQUIRED commit完毕");

        System.out.println("after:" + jdbcTemplate.queryForList("SELECT * from t_user"));
    }

    public void m1() {
        System.out.println("PROPAGATION_REQUIRES_NEW start");
        TransactionDefinition transactionDefinition = new DefaultTransactionDefinition(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
        TransactionStatus transactionStatus = platformTransactionManager.getTransaction(transactionDefinition);
        jdbcTemplate.update("insert into t_user (name) values (?)", "test2-1");
        jdbcTemplate.update("insert into t_user (name) values (?)", "test2-2");
        this.addSynchronization("ts-3", 2);
        this.addSynchronization("ts-4", 1);
        System.out.println("PROPAGATION_REQUIRES_NEW 准备commit");
        platformTransactionManager.commit(transactionStatus);
        System.out.println("PROPAGATION_REQUIRES_NEW commit完毕");
    }

    public void addSynchronization(final String name, final int order) {
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronizationAdapter() {
                @Override
                public int getOrder() {
                    return order;
                }

                @Override
                public void suspend() {
                    System.out.println(name + ":suspend");
                }

                @Override
                public void resume() {
                    System.out.println(name + ":resume");
                }

                @Override
                public void flush() {
                    System.out.println(name + ":flush");
                }

                @Override
                public void beforeCommit(boolean readOnly) {
                    System.out.println(name + ":beforeCommit:" + readOnly);
                }

                @Override
                public void beforeCompletion() {
                    System.out.println(name + ":beforeCompletion");
                }

                @Override
                public void afterCommit() {
                    System.out.println(name + ":afterCommit");
                }

                @Override
                public void afterCompletion(int status) {
                    System.out.println(name + ":afterCompletion:" + status);
                }
            });
        }
    }

}


```

##### 3、输出

```
PROPAGATION_REQUIRED start
PROPAGATION_REQUIRES_NEW start
ts-2:suspend
ts-1:suspend
PROPAGATION_REQUIRES_NEW 准备commit
ts-4:beforeCommit:false
ts-3:beforeCommit:false
ts-4:beforeCompletion
ts-3:beforeCompletion
ts-4:afterCommit
ts-3:afterCommit
ts-4:afterCompletion:0
ts-3:afterCompletion:0
ts-2:resume
ts-1:resume
PROPAGATION_REQUIRES_NEW commit完毕
PROPAGATION_REQUIRED 准备commit
ts-2:beforeCommit:false
ts-1:beforeCommit:false
ts-2:beforeCompletion
ts-1:beforeCompletion
ts-2:afterCommit
ts-1:afterCommit
ts-2:afterCompletion:0
ts-1:afterCompletion:0
PROPAGATION_REQUIRED commit完毕
after:[{id=1, name=test1-1}, {id=2, name=test1-2}, {id=3, name=test2-1}, {id=4, name=test2-2}]


```

输出配合案例源码，大家理解一下。

### 总结一下

**今天的内容挺长的，辛苦大家了，不过我相信 spring 事务这块吃透了，会让你收获很多，加油！**

**事务方面有任何问题的欢迎给我留言，下篇文章将解析声明式事务的源码，敬请期待！！****

### 案例源码

```
git地址：
https://gitee.com/javacode2018/spring-series

本文案例对应源码：
    spring-series\lesson-002-tx\src\main\java\com\javacode2018\tx\demo9


```

**路人甲 java 所有案例代码以后都会放到这个上面，大家 watch 一下，可以持续关注动态。**

### Spring 系列

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
    
22.  [Spring 系列第 22 篇：@Scope、@DependsOn、@ImportResource、@Lazy 详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934284&idx=1&sn=00126ad4b435cb31726a5ef10c31af25&chksm=88621fb2bf1596a41563db5c474873c62d552ec9a440037d913704f018742ffca9be9b598680&token=887127000&lang=zh_CN&scene=21#wechat_redirect)
    
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
    
44.  [Spring 系列第 44 篇：详解 spring 声明式事务 (@Transactional)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936892&idx=2&sn=473a156dc141a2efc0580f93567f0630&scene=21#wechat_redirect)
    
45.  [Spring 系列第 45 篇：带你吃透 Spring 事务 7 种传播行为](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937136&idx=2&sn=73d60cc0e6d9734d675aec369704992e&scene=21#wechat_redirect)
    
46.  [Spring 系列第 46 篇：Spring 如何管理多数据源事务？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937266&idx=2&sn=dec5380383ed768b734ffe02e0322724&scene=21#wechat_redirect)
    

### 更多好文章

1.  [Java 高并发系列（共 34 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933285&idx=1&sn=f5507c251b84c3405f2fe0f7fb1da97d&chksm=88621b9bbf15928dd4c26f52b2abb0e130cde02100c432f33f0e90123b5e4b20d43017c1030e&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [MySql 高手系列（共 27 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933461&idx=1&sn=67cd31469273b68a258d963e53b56325&chksm=88621c6bbf15957d7308d81cd8ba1761b356222f4c6df75723aee99c265bd94cc869faba291c&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Maven 高手系列（共 10 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933753&idx=1&sn=0b41083939980be87a61c4f573792459&chksm=88621d47bf1594516092b662c545abfac299d296e232bf25e9f50be97e002e2698ea78218828&scene=21#wechat_redirect)
    
4.  [Mybatis 系列（共 12 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933868&idx=1&sn=ed16ef4afcbfcb3423a261422ff6934e&chksm=88621dd2bf1594c4baa21b7adc47456e5f535c3358cd11ddafb1c80742864bb19d7ccc62756c&token=1400407286&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [聊聊 db 和缓存一致性常见的实现方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933452&idx=1&sn=48b3b1cbd27c50186122fef8943eca5f&chksm=88621c72bf159564e629ee77d180424274ae9effd8a7c2997f853135b28f3401970793d8098d&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [接口幂等性这么重要，它是什么？怎么实现？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933334&idx=1&sn=3a68da36e4e21b7339418e40ab9b6064&chksm=88621be8bf1592fe5301aab732fbed8d1747475f4221da341350e0cc9935225d41bf79375d43&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [泛型，有点难度，会让很多人懵逼，那是因为你没有看这篇文章！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933878&idx=1&sn=bebd543c39d02455456680ff12e3934b&chksm=88621dc8bf1594de6b50a760e4141b80da76442ba38fb93a91a3d18ecf85e7eee368f2c159d3&token=799820369&lang=zh_CN&scene=21#wechat_redirect)
    

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06AibRrjQicuaJj6Mq4hmnCUlIibUvzyXLROGOKSGfz9FrjG1Cjy4bicNmFdO4yWE2ibiaQJ1F6eic95FWc9Q/640?wx_fmt=png)