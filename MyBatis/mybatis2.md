1、入门mybatis

1. 项目中引入mybatis配置

```xml
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.5.3</version>
</dependency>
```

2. 创建mybatis-config.xml配置文件

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <environments default="development">
        <environment id="development">
            <transactionManager type="JDBC"/>
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.jdbc.Driver"/>
                <property name="url" value="jdbc:mysql://devos/mybatis?characterEncoding=UTF-8"/>
                <property name="username" value="root"/>
                <property name="password" value="123456"/>
            </dataSource>
        </environment>
    </environments>
</configuration>
```

3. 创建UserMapper.xml文件，在配置文件中引入mapper 文件

```xml
<mappers>
    <mapper resource="mapper/UserMapper.xml"/>
</mappers>
```

4. 创建UserMapper接口

```java
public interface UserMapper {
    void inser(User user);
}
```

```xml
<mapper namespace="com.zkunm.mapper.UserMapper">
```

UserMapper.xml文件中的namespace的值，对应的是UserMapper这个接口完整的引用，通过这个namespace，UserMapper接口就可以UserMapper.xml建立了映射关系。

UserMapper.xml中又有很多 db 操作，这些操作会和UserMapper接口中的方法建立映射关系，当调用UserMapper中的方法的时候，间接的会调用到UserMapper.xml中对应的操作。

如UserMapper.xml中有下面一段配置：

```xml
<insert id="insert" parameterType="map">
    insert into t_user(id, name, age, salary) values
    <foreach collection="list" separator="," item="item">
        (#{item.id}, #{item.name}, #{item.age}, #{item.salary})
    </foreach>
</insert>
```

而UserMapper中有个insert方法和上面这个insert插入对应，如下：

```
void insertBatch(List<UserModel> userModelList);
```

所以当我们调用UserMapper中的insert方法的时候，会间接调用到UserMapper.xml中的 id="insert"这个操作。

5. 通过 mybatis 获取 Mapper 接口执行对 db 的操作

```
SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(Resources.getResourceAsStream("mybatis-config.xml"));
SqlSession session = factory.openSession(true);
UserMapper mapper = session.getMapper(UserMapper.class);
```

## SqlSessionFactoryBuilder

这个是一个构建器，通过名字可以感觉到SqlSessionFactoryBuilder构建器，是用来构建SqlSessionFactory对象的，SqlSessionFactoryBuilder 可以通过读取 mybatis 的配置文件，然后构建一个SqlSessionFactory对象，一个项目中有很多mapper xml文件，如果每次操作都去重新解析是非常慢的，那么怎么办？

能不能第一次解析好然后放在内存中，以后直接使用，SqlSessionFactoryBuilder 就是搞这个事情的，将 mybatis 配置文件、mapper xml文件、mapper xml文件和Mapper 接口的映射关系，这些都先给解析好，然后放在 java 对象中，java 对象存在于内存中，内存中访问会非常快的，那么我们每次去用的时候就不需要重新去解析 xml 了，SqlSessionFactoryBuilder 解析配置之后，生成的对象就是SqlSessionFactory，这个是一个重量级的对象，创建他是比较耗时的，所以一般一个 db 我们会创建一个SqlSessionFactory对象，然后在系统运行过程中会一直存在，而 SqlSessionFactoryBuilder 用完了就可以释放了。

## SqlSessionFactory

通过名字可以知道，这个是一个工厂，是用来创建SqlSession的工厂，SqlSessionFactory是一个重量级的对象，一般一个 db 对应一个SqlSessionFactory对象，系统运行过程中会一直存在。

SqlSessionFactory 是一个接口，这个接口有 2 个实现DefaultSqlSessionFactory和SqlSessionManager，一般都是通过SqlSessionFactoryBuilder来创建SqlSessionFactory对象。

通过SqlSessionFactoryBuilder来创建SqlSessionFactory对象主要有 2 种方式，一种通过读取 mybatis 配置文件的方式，另外一种是硬编码的方式

## SqlSession

我们通过 jdbc 操作数据库需要先获取一个Connection连接，然后拿着这个连接去对db进行操作，在mybatis中SqlSession就类似于jdbc中Connection连接对象，在mybatis中叫做Sql会话对象，一般我们一个db操作使用一个SqlSession对象，所以这个对象一般是方法级别的，方法结束之后，这个对象就销毁了，这个对象可以调用sqlSessionFactory.openSession的方法来进行获取。

我们可以直接通过 SqlSession 对象来调用mapper xml中各种 db 操作，需要指定具体的操作的 id，id的格式为namespace.操作的id。

## Mapper 接口

我们可以通过 SqlSession 直接调用mapper xml中的 db 操作，不过更简单的以及推荐的方式是使用 Mapper 接口，Mapper接口中的方法和mapper xml文件中的各种db操作建立了映射关系，是通过Mapper接口完整名称+方法名称和mapper xml中的namespace+具体操作的id来进行关联的，然后我们直接调用Mapper接口中的方法就可以间接的操作 db 了，使用想当方便，Mapper接口需要通过SqlSession获取，传入Mapper接口对应的Class对象，然后会返回这个接口的实例，如：

```
UserMapper mapper = sqlSession.getMapper(UserMapper.class);
```

# 2 、Mybatis 使用详解（1）

1. 准备数据库

```
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE t_user
(
    id       BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键，用户id，自动增长',
    `name`   VARCHAR(32)    NOT NULL DEFAULT '' COMMENT '姓名',
    `age`    SMALLINT       NOT NULL DEFAULT 1 COMMENT '年龄',
    `salary` DECIMAL(12, 2) NOT NULL DEFAULT 0 COMMENT '薪水',
    `sex`    TINYINT        NOT NULL DEFAULT 0 COMMENT '性别,0:未知,1:男,2:女'
) COMMENT '用户表';

SELECT * FROM t_user;
```

2. 引入mybatis依赖

```
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.5.3</version>
</dependency>
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>5.1.36</version>
</dependency>
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.10</version>
</dependency>
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>4.12</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>1.2.3</version>
</dependency>
```

上面我们引入了依赖mybatis、mysql驱动、lombok支持、junit、logback支持，其实运行mybatis只需要引入下面这一个构件就行了：

```
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.5.3</version>
</dependency>
```

3. 创建mybatis-config.xml文件，内容如下：

```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <environments default="mysql">
        <environment id="mysql">
            <transactionManager type="org.apache.ibatis.transaction.jdbc.JdbcTransactionFactory"/>
            <dataSource type="org.apache.ibatis.datasource.pooled.PooledDataSourceFactory">
                <property name="driver" value="com.mysql.jdbc.Driver"/>
                <property name="url" value="jdbc:mysql://devos/myabtis?characterEncoding=UTF-8"/>
                <property name="username" value="root"/>
                <property name="password" value="123456"/>
            </dataSource>
        </environment>
    </environments>
</configuration>
```

**configuration 元素**

​	这个是 mybatis 全局配置文件的根元素，每个配置文件只有一个

**environments 元素**

​	environments 元素中用来配置多个环境的，具体的一个环境使用`environment`元素进行配置，environment 元素有个 id 用来标识某个具体的环境。

​	environments元素有个default属性，用来指定默认使用哪个环境

**environment 元素**

​	用来配置具体的环境信息，这个元素下面有两个子元素：transactionManager 和 dataSource

**transactionManager 元素**

用来配置事务工厂的，有个 type 属性，type 的值必须是org.apache.ibatis.transaction.TransactionFactory接口的实现类，TransactionFactory看名字就知道是一个工厂，用来创建事务管理器org.apache.ibatis.transaction.Transaction对象的，TransactionFactory接口默认有 2 个实现：

```
org.apache.ibatis.transaction.managed.ManagedTransactionFactory
org.apache.ibatis.transaction.jdbc.JdbcTransactionFactory
```

一般情况下使用org.apache.ibatis.transaction.jdbc.JdbcTransactionFactory，mybatis 和其他框架集成，比如和 spring 集成，事务交由 spring 去控制，spring 中有TransactionFactory接口的一个实现org.mybatis.spring.transaction.SpringManagedTransactionFactory

**dataSource 元素**

这个用来配置数据源的，type 属性的值必须为接口org.apache.ibatis.datasource.DataSourceFactory的实现类，DataSourceFactory也是一个工厂，用来创建数据源javax.sql.DataSource对象的，mybatis 中这个接口默认有 3 个实现类：

```
org.apache.ibatis.datasource.jndi.JndiDataSourceFactory
org.apache.ibatis.datasource.pooled.PooledDataSourceFactory
org.apache.ibatis.datasource.unpooled.UnpooledDataSourceFactory
```

我们使用第 2 个org.apache.ibatis.datasource.pooled.PooledDataSourceFactory，这个用来创建一个数据库连接池类型的数据源，可以实现数据库连接共用，减少连接重复创建销毁的时间。

配置数据源需要指定数据库连接的属性信息，比如：驱动、连接 db 的 url、用户名、密码，这个在dataSource元素下面的property中配置，property元素的格式：

```
<property name="属性名称" value="值"/>
```

4. 创建 Mapper xml 文件

在mybatis中一般我们将一个表的所有sql操作写在一个mapper xml中，一般命名为XXXMapper.xml格式。

创建文件resource/mapper/UserMapper.xml，内容如下：

```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.zkunm.mapper.UserMapper">
</mapper>
```

5. mybatis全局配置文件中引入Mapper xml文件

UserMapper.xml我们写好了，如何让mybatis知道这个文件呢，此时我们需要在mybatis-config.xml全局配置文件中引入UserMapper.xml，在mybatis-config.xml加入下面配置：

```
<mappers>
    <mapper resource="mapper/UserMapper.xml" />
</mappers>
```

mappers元素下面有多个mapper元素，通过mapper元素的resource属性可以引入Mapper xml文件，resource是相对于classes的路径

6. 构建 SqlSessionFactory 对象

```
String resource = "mybatis-config.xml";
InputStream inputStream = Resources.getResourceAsStream(resource);
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
```

SqlSessionFactory 是一个接口，是一个重量级的对象，SqlSessionFactoryBuilder 通过读取全局配置文件来创建一个SqlSessionFactory，创建这个对象是比较耗时的，主要耗时在对 mybatis 全局配置文件的解析上面，全局配置文件中包含很多内容，SqlSessionFactoryBuilder 通过解析这些内容，创建了一个复杂的SqlSessionFactory对象，这个对象的生命周期一般和应用的生命周期是一样的，随着应用的启动而创建，随着应用的停止而结束，所以一般是一个全局对象，一般情况下一个 db 对应一个 SqlSessionFactory 对象。

7. 构建 SqlSession 对象

SqlSession相当于jdbc中的Connection对象，相当于数据库的一个连接，可以用SqlSession来对 db 进行操作：如执行 sql、提交事务、关闭连接等等，需要通过SqlSessionFactory来创建SqlSession对象，SqlSessionFactory中常用的有 2 个方法来创建SqlSession对象，如下：

```
//创建一个SqlSession，默认不会自动提交事务
SqlSession openSession();
//创建一个SqlSession,autoCommit：指定是否自动提交事务
SqlSession openSession(boolean autoCommit);
```

SqlSession接口中很多方法，直接用来操作 db，方法清单如下，大家眼熟一下：

```
<T> T selectOne(String statement);
<T> T selectOne(String statement, Object parameter);
<E> List<E> selectList(String statement);
<E> List<E> selectList(String statement, Object parameter);
<E> List<E> selectList(String statement, Object parameter, RowBounds rowBounds);
<K, V> Map<K, V> selectMap(String statement, String mapKey);
<K, V> Map<K, V> selectMap(String statement, Object parameter, String mapKey);
<K, V> Map<K, V> selectMap(String statement, Object parameter, String mapKey, RowBounds rowBounds);
<T> Cursor<T> selectCursor(String statement);
<T> Cursor<T> selectCursor(String statement, Object parameter);
<T> Cursor<T> selectCursor(String statement, Object parameter, RowBounds rowBounds);
void select(String statement, Object parameter, ResultHandler handler);
void select(String statement, ResultHandler handler);
void select(String statement, Object parameter, RowBounds rowBounds, ResultHandler handler);
int insert(String statement);
int insert(String statement, Object parameter);
int update(String statement);
int update(String statement, Object parameter);
int delete(String statement);
int delete(String statement, Object parameter);
void commit();
void commit(boolean force);
void rollback();
void rollback(boolean force);
List<BatchResult> flushStatements();
void close();
void clearCache();
Configuration getConfiguration();
<T> T getMapper(Class<T> type);
Connection getConnection();
```

上面以select开头的可以对 db 进行查询操作，insert相关的可以对 db 进行插入操作，update 相关的可以对 db 进行更新操作。

8. 引入 logback（非必须）

```
<dependency>
   <groupId>ch.qos.logback</groupId>
   <artifactId>logback-classic</artifactId>
   <version>1.2.3</version>
</dependency>
```

创建`logback.xml`文件：

```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <logger name="com.zkunm" level="debug" additivity="false">
        <appender-ref ref="STDOUT" />
    </logger>
</configuration>
```

## 使用SqlSesion执行操作

SqlSession 相当于一个连接，可以使用这个对象对 db 执行增删改查操作，操作完毕之后需要关闭，使用步骤：

```
1.获取SqlSession对象：通过该sqlSessionFactory.openSession方法获取SqlSession对象
2.对db进行操作：使用SqlSession对象进行db操作
3.关闭SqlSession对象：sqlSession.close();
```

常见的使用方式如下：

```
//获取SqlSession
SqlSession sqlSession = this.sqlSessionFactory.openSession();
try {
    //执行业务操作，如：增删改查
} finally {
    //关闭SqlSession
    sqlSession.close();
}
```

上面我们将 SqlSession 的关闭放在finally块中，确保 close() 一定会执行。更简单的方式是使用 java 中的try()的方式，如下：

```
try (SqlSession sqlSession = this.sqlSessionFactory.openSession();) {
    //执行业务操作，如：增删改查
}
```

### 新增操作

1. 创建一个 UserModel

新建一个com.zkunm.model.UserModel.java类，代码如下：

```
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserModel {
    private Long id;
    private String name;
    private Integer age;
    private Double salary;
    private Integer sex;
}
```

2. UserMapper.xml 中定义插入操作

```
<insert id="insertUser" parameterType="com.zkunm.model.UserModel">
    insert into t_user (id, name, age, salary, sex) values (#{id}, #{name}, #{age}, #{salary}, #{sex})
</insert>
```

id：是这个操作的一个标识，一会通过 mybatis 执行操作的时候会通过这个namespace和id引用到这个insert操作，

parameterType：用来指定这个 insert 操作接受的参数的类型，可以是：各种 javabean、map、list、collection 类型的 java 对象

insert元素内部定义了具体的 sql

需要插入的值从 UserModel 对象中获取，取UserModel对象的的字段，使用#{字段} 这种格式可以获取到 UserModel 中字段的值。

3. 调用 SqlSession.insert 方法执行插入操作

```
int insert(String statement, Object parameter)
```

statement：表示那个操作，值为 Mapper xml 的namespace.具体操作的id，如需要调用UserMapper.xml中的insertUser操作，这个值就UserMapper.insertUser

parameter：insert 操作的参数，和 Mapper xml 中的 insert 中的parameterType指定的类型一致。

返回值为插入的行数。

### 更新操作

1. UserMapper.xml 中定义 Update 操作

```
<update id="updateUser" parameterType="com.zkunm.model.UserModel">
    update t_user set name = #{name}, age = #{age}, salary = #{salary}, sex = #{sex} where id = #{id};
</update>
```

2. 调用 SqlSession.update 方法执行更新操作

```
int update(String statement, Object parameter)
```

statement：表示哪个操作，值为 Mapper xml 的namespace.具体操作的id，如需要调用UserMapper.xml中的updateUser操作，这个值就是com.zkunm.mapper.UserMapper.updateUser

parameter：update 操作的参数，和 Mapper xml 中的 update 中的parameterType指定的类型一致。

返回值为 update 影响行数。

### 删除操作

1. UserMapper.xml 中定义delete操作

```
<update id="deleteUser" parameterType="java.lang.Long">
    delete from t_user where id = #{id}
</update>
```

2. 调用 SqlSession.update 方法执行更新操作

```
int delete(String statement, Object parameter)
```

这个方法有 2 个参数:

statement：表示哪个操作，值为 Mapper xml 的namespace.具体操作的id，如需要调用UserMapper.xml中的deleteUser操作，这个值就是：

com.zkunm.mapper.UserMapper.deleteUser

parameter：delete 操作的参数，和 Mapper xml 中的 delete 中的parameterType指定的类型一致。

返回值为 delete 影响行数。

### 执行查询

1. UserMapper.xml 中定义 Select 操作

```
<select id="getUserList" resultType="com.zkunm.model.UserModel">
    select * from t_user;
</select>
```

2. 调用 SqlSession.select 方法执行更新操作

## Mapper 接口的使用

### 为什么需要 Mapper 接口

上面我们讲解了对一个表的增删改查操作，都是通过调用 SqlSession 中的方法来完成的，大家再来看一下 SqlSession 接口中刚才用到的几个方法的定义：

```
int insert(String statement, Object parameter);
int update(String statement, Object parameter);
int delete(String statement, Object parameter);
<E> List<E> selectList(String statement);
```

这些方法的特点我们来看一下：

1. 调用这些方法，需要明确知道`statement`的值，statement 的值为`namespace.具体操作的id`，这些需要打开`Mapper xml`中去查看了才知道，写起来不方便
2. parameter 参数都是 Object 类型的，我们根本不知道这个操作具体类型是什么，需要查看`Mapper xml`才知道，随便传递个值，可能类型不匹配，但是只有在运行的时候才知道有问题
3. selectList 方法返回的是一个泛型类型的，通过这个方法我们根本不知道返回的结果的具体类型，也需要去查看`Mapper xml`才知道

以上这几点使用都不是太方便，有什么方法能解决上面这些问题么？

有，这就是 mybatis 中的 Mapper 接口，我们可以定义一个 interface，然后和 Mapper xml 关联起来，Mapper xml 中的操作和 Mapper 接口中的方法会进行绑定，当我们调用 Mapper 接口的方法的时候，会间接调用到 Mapper xml 中的操作，接口的完整类名需要和 Mapper xml 中的 namespace 一致。

### Mapper 接口的用法（三步）

1. 定义 Mapper 接口

去看一下，UserMapper.xml 中的 namespace，是：

```
<mapper namespace="com.zkunm.mapper.UserMapper">
```

我们创建的接口完整的名称需要和上面的namespace的值一样，下面我们创建一个接口`com.zkunm.mapper.UserMapper`，如下：

UserMapper.xml 中有 4 个操作，我们需要在 UserMapper 接口中也定义 4 个操作，和 UserMapper.xml 的 4 个操作对应，如下：

```
public interface UserMapper {
    int insertUser(UserModel model);
    int updateUser(UserModel model);
    int deleteUser(Long userId);
    List<UserModel> getUserList();
}
```

UserMapper 接口中定义了 4 个方法，方法的名称需要和 UserMapper.xml 具体操作的 id 值一样，这样调用 UserMapper 接口中的方法的时候，才会对应的找到 UserMapper.xml 中具体的操作。

比如调用UserMapper接口中的insertUser方法，mybatis 查找的规则是：通过接口完整名称.方法名称去 Mapper xml 中找到对应的操作。

2. 通过 SqlSession 获取 Mapper 接口对象

SqlSession 中有个`getMapper`方法，可以传入接口的类型，获取具体的 Mapper 接口对象，如下：

```
<T> T getMapper(Class<T> type);
```

如获取 UserMapper 接口对象：

```
UserMapper mapper = sqlSession.getMapper(UserMapper.class);
```

3. 调用 Mapper 接口的方法对 db 进行操作

```
@Test
public void insertUser() {
    try (SqlSession sqlSession = this.sqlSessionFactory.openSession(true);) {
        UserMapper mapper = sqlSession.getMapper(UserMapper.class);
        UserModel userModel = UserModel.builder().id(System.currentTimeMillis()).name("zkunm").age(30).salary(50000D).sex(1).build();
        //执行插入操作
        int insert = mapper.insertUser(userModel);
        log.info("影响行数：{}", insert);
    }
}
```

### Mapper 接口使用时注意的几点

1. Mapper 接口的完整类名必须和对应的 Mapper xml 中的 namespace 的值一致
2. Mapper 接口中方法的名称需要和 Mapper xml 中具体操作的 id 值一致
3. Mapper 接口中方法的参数、返回值可以不和 Mapper xml 中的一致

### Mapper 接口的原理

这个使用 java 中的动态代理实现的，mybatis 启动的时候会加载全局配置文件mybatis-config.xml，然后解析这个文件中的mapper元素指定的UserMapper.xml，会根据UserMapper.xml的namespace的值创建这个接口的一个动态代理，具体可以去看一下 mybatis 的源码，主要使用 java 中的 Proxy 实现的，使用java.lang.reflect.Proxy类中的newProxyInstance方法，我们可以创建任意一个接口的一个代理对象：

```
public static Object newProxyInstance(ClassLoader loader, Class<?>[] interfaces, InvocationHandler h)
```

我们使用 Proxy 来模仿 Mapper 接口的实现：

```
@Slf4j
public class ProxyTest {
    private SqlSessionFactory sqlSessionFactory;
    @Before
    public void before() throws IOException {
        String resource = "mybatis-config.xml";
        InputStream inputStream = Resources.getResourceAsStream(resource);
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
        this.sqlSessionFactory = sqlSessionFactory;
    }

    @Test
    public void test1() {
        try (SqlSession sqlSession = this.sqlSessionFactory.openSession(true);) {
            UserMapper userMapper = (UserMapper) Proxy.newProxyInstance(ProxyTest.class.getClassLoader(), new Class[]{UserMapper.class}, new UserMapperProxy(sqlSession, UserMapper.class));
            log.info("{}", userMapper.getUserList());
        }
    }

    public static class UserMapperProxy implements InvocationHandler {
        private SqlSession sqlSession;
        private Class<?> mapperClass;
        public UserMapperProxy(SqlSession sqlSession, Class<?> mapperClass) {
            this.sqlSession = sqlSession;
            this.mapperClass = mapperClass;
        }

        @Override
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            log.debug("invoke start");
            String statement = mapperClass.getName() + "." + method.getName();
            List<Object> result = sqlSession.selectList(statement);
            log.debug("invoke end");
            return result;
        }
    }
}
```

上面代码中：UserMapper 是没有实现类的，可以通过 Proxy.newProxyInstance 给`UserMapper`接口创建一个代理对象，当调用`UserMapper`接口的方法的时候，会调用到`UserMapperProxy`对象的`invoke`方法。

运行一下`test1`用例，输出如下：

![image-20201211182432858](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201211182432.png)

注意上面输出的`invoke start`和`invoke end`，可以看到我们调用`userMapper.getUserList`时候，被`UserMapperProxy#invoke`方法处理了。

Mybatis 中创建 Mapper 接口代理对象使用的是下面这个类，大家可以去研究一下：

![image-20201211182510198](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201211182510.png)

# 3 、Mybatis 使用详解 (2)

## 别名

parameterType 是指定参数的类型，resultType 是指定查询结果返回值的类型，他们的值都是UserModel类完整的类名，比较长，mybatis 支持我们给某个类型起一个别名，然后通过别名可以访问到指定的类型。

> 使用别名之前需要先在 mybatis 中注册别名，我们先说通过 mybatis 全局配置文件中注册别名，通过 mybatis 配置文件注册别名有 3 种方式

### 方式1 使用 typeAlias 元素进行注册

```
<typeAliases>
    <typeAlias type="玩转的类型名称" alias="别名" />
</typeAliases>
```

typeAliases 元素中可以包含多个 typeAlias 子元素，每个 typeAlias 可以给一个类型注册别名，有 2 个属性需要指定：

type：完整的类型名称

alias：别名

### 方式2 通过 packege 元素批量注册

```
<typeAliases>
    <package name="需要扫描的包"/>
</typeAliases>
```

这个也是在 typeAliases 元素下面，不过这次使用的是`package`元素，package 有个 name 属性，可以指定一个包名，mybatis 会加载这个包以及子包中所有的类型，给这些类型都注册别名，别名名称默认会采用类名小写的方式，如`UserModel`的别名为`usermodel`

### 方式3 package 结合 @Alias 批量注册并指定别名

package 方式批量注册别名的时候，我们可以给类中添加一个`@Alias`注解来给这个类指定别名：

```
@Alias("user")
public class UserModel {
}
```

当 mybatis 扫描类的时候，发现类上有`Alias`注解，会取这个注解的`value`作为别名，如果没有这个注解，会将类名小写作为别名，如同方式 2。

### 别名不区分大小写

### mybatis 内置的别名

| 别名       | 对应的实际类型 |
| ---------- | -------------- |
| _byte      | byte           |
| _long      | long           |
| _short     | short          |
| _int       | int            |
| _integer   | int            |
| _double    | double         |
| _float     | float          |
| _boolean   | boolean        |
| string     | String         |
| byte       | Byte           |
| long       | Long           |
| short      | Short          |
| int        | Integer        |
| integer    | Integer        |
| double     | Double         |
| float      | Float          |
| boolean    | Boolean        |
| date       | Date           |
| decimal    | BigDecimal     |
| bigdecimal | BigDecimal     |
| object     | Object         |
| map        | Map            |
| hashmap    | HashMap        |
| list       | List           |
| arraylist  | ArrayList      |
| collection | Collection     |
| iterator   | Iterator       |

上面这些默认都是在`org.apache.ibatis.type.TypeAliasRegistry`类中进行注册的，这个类就是 mybatis 注册别名使用的，别名和具体的类型关联是放在这个类的一个 map 属性（typeAliases）中，贴一部分代码大家感受一下：

![image-20201211185727043](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201211185727.png)

mybatis 启动的时候会加载全局配置文件，会将其转换为一个`org.apache.ibatis.session.Configuration`对象，存储在内存中，`Configuration`类中也注册了一些别名，代码如下：

![image-20201211185829397](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201211185829.png)

### 别名的原理

mybatis 允许我们给某种类型注册一个别名，别名和类型之间会建立映射关系，这个映射关系存储在一个 map 对象中，key 为别名的名称，value 为具体的类型，当我们通过一个名称访问某种类型的时候，mybatis 根据类型的名称，先在别名和类型映射的 map 中按照 key 进行查找，如果找到了直接返回对应的类型，如果没找到，会将这个名称当做完整的类名去解析成 Class 对象，如果这 2 步解析都无法识别这种类型，就会报错。

mybatis 和别名相关的操作都位于org.apache.ibatis.type.TypeAliasRegistry类中，包含别名的注册、解析等各种操作。

我们来看一下别名解析的方法，如下：

![image-20201211190003679](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201211190003.png)

有一个`typeAliases`对象，我们看一下其定义：

```
private final Map<String, Class<?>> typeAliases = new HashMap<>();
```

这个对象就是存放别名和具体类型映射关系的，从上面代码中可以看出，通过传入的参数解析对应的类型的时候，会先从`typeAliases`中查找，如果找不到会调用下面代码：

```
value = Resources.classForName(string);
```

上面这个方法里面具体是使用下面代码去通过名称解析成类型的：

```
Class.forName(类名完整名称)
```

## 属性配置文件详解

看一下中下面这一部分的配置：

```
<dataSource type="org.apache.ibatis.datasource.pooled.PooledDataSourceFactory">
    <property name="driver" value="com.mysql.jdbc.Driver"/>
    <property name="url" value="jdbc:mysql://devos/mybatis?characterEncoding=UTF-8"/>
    <property name="username" value="root"/>
    <property name="password" value="123456"/>
</dataSource>
```

这个连接数据库的配置，我们是直接写在 mybatis 全局配置文件中的

mybatis 也支持我们通过外部 properties 文件来配置一些属性信息，有 3 种方式

### 方式 1：property 元素中定义属性

mybatis 全局配置文件中通过 properties 元素来定义属性信息，如下：

```
<configuration>
    <properties>
        <property name="属性名称" value="属性对应的值"/>
    </properties>
</configuration>
```

```
<property name="jdbc.driver" value="com.mysql.jdbc.Driver"/>
```

使用 ${属性名称} 引用属性的值

属性已经定义好了，我们可以通过`${属性名称}`引用定义好的属性的值，如：

```
<property name="driver" value="${jdbc.driver}"/>
```

### 方式 2：resource 引入配置文件

引入 classes 路径中的配置文件

```
<configuration>
    <properties resource="配置文件路径"/>
</configuration>
```

properties 元素有个resource属性，值为配置文件相对于classes的路径，配置文件我们一般放在src/main/resource目录，这个目录的文件编译之后会放在classes路径中。

### 方式 3：url 的方式引入远程配置文件

```
<properties url="远程配置文件的路径" />
```

### 问题

如果 3 种方式如果我们都写了，mybatis 会怎么走？

方式 1 和方式 2 都存在的时候，方式 2 的配置会覆盖方式 1 的配置。

方式 2 和方式 3 都存在的时候，方式 3 会失效，mybatis 会先读取方式 1 的配置，然后读取方式 2 或者方式 3 的配置，会将 1 中相同的配置给覆盖。

## mybatis 中引入 mapper 的 3 种方式

### 方式 1：使用 mapper resouce 属性注册 mapper xml 文件

```
<mappers>
    <mapper resource="Mapper xml的路径（相对于classes的路径）"/>
</mappers>
```

1. 一般情况下面我们会创建一个和 Mapper xml 中 namespace 同名的 Mapper 接口，Mapper 接口会和 Mapper xml 文件进行绑定
2. mybatis 加载 mapper xml 的时候，会去查找 namespace 对应的 Mapper 接口，然后进行注册，我们可以通过 Mapper 接口的方式去访问 Mapper xml 中的具体操作
3. Mapper xml 和 Mapper 接口配合的方式是比较常见的做法，也是强烈建议大家使用的

### 方式 2：使用 mapper class 属性注册 Mapper 接口

```
<mappers>
      <mapper class="接口的完整类名" />
</mappers>
```

这种情况下，mybais 会去加载class对应的接口，然后还会去加载和这个接口同一个目录的同名的 xml 文件。

maven 编译 src/java 代码的时候，默认只会对 java 文件进行编译然后放在 target/classes 目录，需要pom.xml中加入下面配置：

```
<build>
    <resources>
        <resource>
            <directory>${project.basedir}/src/main/java</directory>
            <includes>
                <include>**/*.xml</include>
            </includes>
        </resource>
        <resource>
            <directory>${project.basedir}/src/main/resources</directory>
            <includes>
                <include>**/*</include>
            </includes>
        </resource>
    </resources>
</build>
```

### 方式 3：使用 package 元素批量注册 Mapper 接口

```
<mappers>
    <package name="需要扫描的包" />
</mappers>
```

mybatis 会扫描package元素中name属性指定的包及子包中的所有接口，将其当做Mapper 接口进行注册，所以一般我们会创建一个mapper包，里面放Mapper接口和同名的Mapper xml文件

## 关于配置和源码

本次讲解到的一些配置都是在 mybatis 全局配置文件中进行配置的，这些元素配置是有先后顺序的，具体元素是在下面的 dtd 文件中定义的：

```
http://mybatis.org/dtd/mybatis-3-config.dtd
```

Mybatis 解析这个配置文件的入口是在下面的方法中：

```
org.apache.ibatis.builder.xml.XMLConfigBuilder#parseConfiguration
```

代码的部分实现如下：

![image-20201211191601186](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201211191601.png)

# 4、Mapper 接口多种方式传参详解、原理、源码解析

## 传递一个参数

Mapper 接口方法中只有一个参数，如：

```
UserModel getByName(String name);
```

Mapper xml 引用这个 name 参数：

```
#{任意合法名称}
```

如：`#{name}、#{val}、${x}等等写法都可以引用上面name参数的值`。

## 传递一个 Map 参数

如果我们需要传递的参数比较多，参数个数是动态的，那么我们可以将这些参数放在一个 map 中，key 为参数名称，value 为参数的值。

Mapper 接口中可以这么定义，如：

```
List<UserModel> getByMap(Map<String,Object> map);
```

如我们传递：

```
Map<String, Object> map = new HashMap<>();
map.put("id", 1L);
map.put("name", "张学友");
```

对应的 mapper xml 中可以通过`#{map中的key}`可以获取 key 在 map 中对应的 value 的值作为参数，如：

```
SELECT * FROM t_user WHERE id=#{id} OR name = #{name}
```

## 传递一个 java 对象参数

```
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserFindDto {
    private Long userId;
    private String userName;
}
```

UserMapper 中新增一个方法，将`UserFindDto`作为参数：

```
List<UserModel> getListByUserFindDto(UserFindDto userFindDto);
```

对应的 UserMapper.xml 中这么写，如下：

```
<select id="getListByUserFindDto" parameterType="userFindDto" resultType="usermodel">
    SELECT * FROM t_user WHERE id=#{userId} OR name = #{userName}
</select>
```

## 传递多个参数

`UserMapper`中新增一个方法，和上面 UserMapper.xml 中的对应，如下：

```
UserModel getByIdOrName(Long id, String name);
```

注意上面的方法由 2 个参数，参数名称分别为`id、name`，在对应的 mapper xml 中写对应的操作

```
<select id="getByIdOrName" resultType="userModel">
    SELECT * FROM t_user WHERE id=#{id} OR name = #{name} LIMIT 1
</select>

SELECT * FROM t_user WHERE id=#{param1} OR name = #{param2} LIMIT 1
```

### 使用注意

1. 使用参数名称的方式对编译环境有很强的依赖性，如果编译中加上了 -parameters 参数，参数实际名称可以直接使用，如果没有加，参数名称就变成 arg 下标 的格式了，这种很容易出错
2. sql 中使用 param1、param2、paramN 这种方式来引用多参数，对参数的顺序依赖性特别强，如果有人把参数的顺序调整了或者调整了参数的个数，后果就是灾难性的，所以这种方式不建议大家使用。

## 多参数中用 @param 指定参数名称

刚才上面讲了多参数传递的使用上面，对参数名称和顺序有很强的依赖性，容易导致一些严重的错误。

mybatis 也为我们考虑到了这种情况，可以让我们自己去指定参数的名称，通过@param(“参数名称”)来给参数指定名称

UserMapper#getByIdOrName做一下修改：

```
UserModel getByIdOrName(@Param("userId") Long id, @Param("userName") String name);
```

上面我们通过 @Param 注解给两个参数明确指定了名称，分别是userId、userName，对应的 UserMapper.xml 中也做一下调整，如下：

```
<select id="getByIdOrName" resultType="userModel">
    SELECT * FROM t_user WHERE id=#{userId} OR name = #{userName} LIMIT 1
</select>
```

### mybatis 参数处理相关源码

上面参数的解析过程代码在`org.apache.ibatis.reflection.ParamNameResolver`类中，主要看下面的 2 个方法：

```
public ParamNameResolver(Configuration config, Method method)
public Object getNamedParams(Object[] args)
```

## 传递 1 个 Collection 参数

当传递的参数类型是`java.util.Collection`的时候，会被放在 map 中，key 为`collection`，value 为参数的值，如下面的查询方法：

```
List<UserModel> getListByIdCollection(Collection<Long> idCollection);
```

上面的查询方法，mybatis 内部会将`idList`做一下处理：

```
Map<String,Object> map = new HashMap<>();
map.put("collection",idCollection)
```

所以我们在 mapper xml 中使用的使用，需要通过`collection`名称来引用`idCollection`参数，如下：

```
<select id="getListByIdCollection" resultType="userModel">
    SELECT * FROM t_user WHERE id IN (#{collection[0]},#{collection[1]})
</select>
```

### Mybatis 中集合参数处理了源码解析

集合参数，mybatis 会进行一些特殊处理，代码在下面的方法中：org.apache.ibatis.session.defaults.DefaultSqlSession#wrapCollection

这个方法的源码如下：

```
private Object wrapCollection(final Object object) {
    if (object instanceof Collection) {
      StrictMap<Object> map = new StrictMap<>();
      map.put("collection", object);
      if (object instanceof List) {
        map.put("list", object);
      }
      return map;
    } else if (object != null && object.getClass().isArray()) {
      StrictMap<Object> map = new StrictMap<>();
      map.put("array", object);
      return map;
    }
    return object;
  }
```

源码解释：

判断参数是否是`java.util.Collection`类型，如果是，会放在 map 中，key 为`collection`。

如果参数是`java.util.List`类型的，会在 map 中继续放一个`list`作为 key 来引用这个对象。

如果参数是数组类型的，会通过`array`来引用这个对象。

## 传递 1 个 List 参数

从上面源码中可知，List 类型的参数会被放在 map 中，可以通过 2 个 key（`collection`和`list`）都可以引用到这个 List 对象。

UserMapper中新增一个方法：

```
List<UserModel> getListByIdList(List<Long> idList);
```

对应的`UserMaper.xml`中增加一个操作，如下：

```
<select id="getListByIdList" resultType="userModel">
    SELECT * FROM t_user WHERE id IN (#{list[0]},#{collection[1]})
</select>
```

注意上面我们使用了 2 中方式获取参数，通过`list、collection`都可以引用 List 类型的参数。

## 传递 1 个数组参数

数组类型的参数从上面源码中可知，sql 中需要通过`array`来进行引用

## ResultHandler 作为参数

查询的数量比较大的时候，返回一个 List 集合占用的内存还是比较多的，比如我们想导出很多数据，实际上如果我们通过 jdbc 的方式，遍历`ResultSet`的`next`方法，一条条处理，而不用将其存到 List 集合中再取处理。

mybatis 中也支持我们这么做，可以使用`ResultHandler`对象，犹如其名，这个接口是用来处理结果的，先看一下其定义：

```
public interface ResultHandler<T> {
  void handleResult(ResultContext<? extends T> resultContext);
}
```

里面有 1 个方法，方法的参数是`ResultContext`类型的，这个也是一个接口，看一下源码：

```
public interface ResultContext<T> {
  T getResultObject();
  int getResultCount();
  boolean isStopped();
  void stop();
}
```

4 个方法：

- getResultObject：获取当前行的结果
- getResultCount：获取当前结果到第几行了
- isStopped：判断是否需要停止遍历结果集
- stop：停止遍历结果集

`ResultContext`接口有一个实现类`org.apache.ibatis.executor.result.DefaultResultContext`，mybatis 中默认会使用这个类。

# 5、玩转mybatis增删改

```
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE t_user (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键，用户id，自动增长',
  `name` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '姓名',
  `age` SMALLINT NOT NULL DEFAULT 1 COMMENT '年龄',
  `salary` DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '薪水',
  `sex` TINYINT NOT NULL DEFAULT 0 COMMENT '性别,0:未知,1:男,2:女'
) COMMENT '用户表';

SELECT * FROM t_user;
```

## 增删改返回值

mybatis 中对 db 执行增删改操作，不管是新增、删除、还是修改，最后都会去调用 jdbc 中对应的方法，要么是调用`java.sql.Statement`的`executeUpdate`的方法，要么是调用`java.sql.PreparedStatement`的`executeUpdate`方法，这 2 个类的方法名称都是`executeUpdate`，他们的参数可能不一样，但是他们的返回值都是 int，说明增删改的返回值都是 int 类型的，表示影响的行数

那么我们通过 Mybatis 中的 Mapper 接口来对 db 增删改的时候，mybatis 的返回值支持哪些类型呢？

mybatis 的返回值比 jdbc 更强大，对于增删改还支持下面几种类型：

```
int
Integer
long 
Long
boolean
Boolean
void
```

mapper 的增删改方法返回值必须为上面的类型，mybatis 内部将 jdbc 返回的 int 类型转换为上面列表中指定的类型，我们来看一下 mybatis 这块的源码，源码在下面的方法中：

```
org.apache.ibatis.binding.MapperMethod#rowCountResult
```

我们来看一下这个方法的源码：

![image-20201211194742330](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201211194742.png)

mybatis 中会使用上面这个方法最后会对 jdbc 增删改返回的 int 结果进行处理，处理为 mapper 接口中增删改方法返回值的类型。

int、Integer、long、Long 我们就不说了，主要说一下返回值是 boolean、Boolean 类型，如果影响的行数大于 0 了，将返回 true。

## jdbc 获取主键的几种方式

**方式 1：jdbc 内置的方式**

jdbc 的 api 中为我们提供了获取自动生成主键的值，具体看这个方法：

```
java.sql.Statement#getGeneratedKeys
```

这个方法会返回一个结果集，从这个结果集中可以获取自增主键的值。

不过使用这个方法有个前提，执行 sql 的时候需要做一个设置。

如果是通过`java.sql.Statement`执行 sql，需要调用下面这个方法：

```
int executeUpdate(String sql, int autoGeneratedKeys) throws SQLException
```

注意上面这个方法的第二个参数需要设置为`java.sql.Statement.RETURN_GENERATED_KEYS`，表示需要返回自增列的值。

不过多数情况下，我们会使用`java.sql.PreparedStatement`对象来执行 sql，如果想获取自增值，创建这个对象需要设置第 2 个参数的值，如下：

```
PreparedStatement preparedStatement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
```

然后我们就可以通过`getGeneratedKeys`返回的`ResultSet`对象获取自动增长的值了，如下：

```
ResultSet generatedKeys = preparedStatement.getGeneratedKeys();
if (generatedKeys!=null && generatedKeys.next()) {
    log.info("自增值为：{}", generatedKeys.getInt(1));
}
```

**方式 2：插入之后查询获取**

mysql 中插入一条数据之后，可以通过下面的 sql 获取最新插入记录的 id 的值：

```
SELECT LAST_INSERT_ID()
```

那么我们可以在插入之后，立即使用当前连接发送上面这条 sql 去获取自增列的值就可以。

## mybatis 获取主键的2种方式

**方式 1：内部使用 jdbc 内置的方式**

```
<insert id="insertUser" parameterType="userModel" useGeneratedKeys="true" keyProperty="id">
    INSERT INTO t_user (name,age,salary,sex) VALUES (#{name},#{age},#{salary},#{sex})
</insert>
```

有 2 个关键参数必须要设置：

- useGeneratedKeys：设置为 true
- keyProperty：参数对象中的属性名称，最后插入成功之后，mybatis 会通过反射将自增值设置给 keyProperty 指定的这个属性

**方式 2：插入后查询获取主键**

```
<insert id="insertUser" parameterType="userModel">
    <selectKey keyProperty="id" order="AFTER" resultType="long">
    SELECT LAST_INSERT_ID()
    </selectKey>
    INSERT INTO t_user (name,age,salary,sex) VALUES (#{name},#{age},#{salary},#{sex})
</insert>
```

关键代码是selectKey元素包含的部分，这个元素内部可以包含一个 sql，这个 sql 可以在插入之前或者插入之后运行（之前还是之后通过 order 属性配置），然后会将 sql 运行的结果设置给 keyProperty 指定的属性，selectKey元素有 3 个属性需要指定：

- keyProperty：参数对象中的属性名称，最后插入成功之后，mybatis 会通过反射将自增值设置给 keyProperty 指定的这个属性
- order：指定 selectKey 元素中的 sql 是在插入之前运行还是插入之后运行，可选值（BEFORE|AFTER），这种方式中我们选择AFTER
- resultType：keyProperty 指定的属性对应的类型，如上面的 id 对应的类型是java.lang.Long，我们直接写的是别名long

## 源码

mybatis 处理自动生产主键值的代码，主要看下面这个接口：

```
org.apache.ibatis.executor.keygen.KeyGenerator
```

看一下这个接口的定义：

```
public interface KeyGenerator {
  void processBefore(Executor executor, MappedStatement ms, Statement stmt, Object parameter);
  void processAfter(Executor executor, MappedStatement ms, Statement stmt, Object parameter);
}
```

有 2 个方法，根据方法名称就可以知道，一个是插入 sql 执行之前调用的，一个是之后调用的，通过这 2 个方法 mybatis 完成了获取主键的功能。

这个接口默认有 3 个实现类：

```
org.apache.ibatis.executor.keygen.Jdbc3KeyGenerator
org.apache.ibatis.executor.keygen.SelectKeyGenerator
org.apache.ibatis.executor.keygen.NoKeyGenerator
```

mybatis 中获取主键的第一种方式就是在`Jdbc3KeyGenerator`类中实现的，其他 2 种方式是在第 2 个类中实现的，第 3 个类 2 个方法是空实现

# 6、各种查询详解

**建库建表**

4 张表:

t_user(用户表)

t_goods(商品表)

t_order(订单表)

t_order_detail(订单明细表)

表之间的关系：

t_order 和 t_user 是一对一的关系，一条订单关联一个用户记录

t_order 和 t_order_detail 是一对多关系，每个订单中可能包含多个子订单，每个子订单对应一个商品

```
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user
(
    id   int AUTO_INCREMENT PRIMARY KEY COMMENT '用户id',
    name VARCHAR(32) NOT NULL DEFAULT '' COMMENT '用户名'
) COMMENT '用户表';
INSERT INTO t_user
VALUES (1, '张学友'),
       (2, '林俊杰');

DROP TABLE IF EXISTS t_goods;
CREATE TABLE t_goods
(
    id    int AUTO_INCREMENT PRIMARY KEY COMMENT '商品id',
    name  VARCHAR(32)    NOT NULL DEFAULT '' COMMENT '商品名称',
    price DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT '商品价格'
) COMMENT '商品信息表';
INSERT INTO t_goods
VALUES (1, 'Mybatis系列', 8.88),
       (2, 'maven高手系列', 16.66);

DROP TABLE IF EXISTS t_order;
CREATE TABLE t_order
(
    id          int AUTO_INCREMENT PRIMARY KEY COMMENT '订单id',
    user_id     INT    NOT NULL DEFAULT 0 COMMENT '用户id，来源于t_user.id',
    create_time BIGINT NOT NULL DEFAULT 0 COMMENT '订单创建时间(时间戳，秒)',
    up_time     BIGINT NOT NULL DEFAULT 0 COMMENT '订单最后修改时间(时间戳，秒)'
) COMMENT '订单表';
INSERT INTO t_order
VALUES (1, 2, unix_timestamp(now()), unix_timestamp(now())),
       (2, 1, unix_timestamp(now()), unix_timestamp(now()));

DROP TABLE IF EXISTS t_order_detail;
CREATE TABLE t_order_detail
(
    id          int AUTO_INCREMENT PRIMARY KEY COMMENT '订单明细id',
    order_id    INT            NOT NULL DEFAULT 0 COMMENT '订单id，来源于t_order.id',
    goods_id    INT            NOT NULL DEFAULT 0 COMMENT '商品id，来源于t_goods.id',
    num         INT            NOT NULL DEFAULT 0 COMMENT '商品数量',
    total_price DECIMAL(12, 2) NOT NULL DEFAULT 0 COMMENT '商品总金额'
) COMMENT '订单表';
INSERT INTO t_order_detail
VALUES (1, 1, 1, 2, 17.76),
       (2, 1, 1, 1, 16.66),
       (3, 2, 1, 1, 8.88);

select *
from t_user;
select *
from t_goods;
select *
from t_order;
select *
from t_order_detail;
```

## 单表查询 (3 种方式)

需要按照订单 id 查询订单信息。

**方式 1**

1. 创建每个表对应的 Model

db 中表的字段是采用下划线分割的，model 中我们是采用骆驼命名法来命名的，如`OrderModel`:

```
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderModel {
    private Integer id;
    private Integer userId;
    private Long createTime;
    private Long upTime;
}
```

其他几个 Model 也类似。

2. Mapper xml

```
<select id="getById" resultType="com.zkunm.model.OrderModel">
    SELECT a.id,a.user_id as userId,a.create_time createTime,a.up_time upTime FROM t_order a WHERE a.id = #{value}
</select>
```

注意上面的`resultType`，标识结果的类型。

3. Mapper 接口方法

```
OrderModel getById(int id);
```

> sql 中我们使用了别名，将`t_order`中的字段转换成了和`OrderModel`中字段一样的名称，最后 mybatis 内部会通过反射，将查询结果按照名称到`OrderModel`中查找同名的字段，然后进行赋值。

**方式 2**

若我们项目中表对应的 Model 中的字段都是采用骆驼命名法，mybatis 中可以进行一些配置，可以使表中的字段和对应 Model 中骆驼命名法的字段进行自动映射。

1. 需要在 mybatis 全局配置文件中加入下面配置：

```
<settings>
    <!-- 是否开启自动驼峰命名规则映射，及从xx_yy映射到xxYy -->
    <setting name="mapUnderscoreToCamelCase" value="true"/>
</settings>
```

2. Mapper xml

```
<select id="getById1" resultType="com.zkunm.model.OrderModel">
    SELECT a.id,a.user_id,a.create_time,a.up_time FROM t_order a WHERE a.id = #{value}
</select>
```

注意上面的 sql，我们没有写别名了，由于我们开启了自动骆驼命名映射，所以查询结果会按照下面的关系进行自动映射：

| sql 对应的字段 | OrderModel 中的字段 |
| -------------- | ------------------- |
| id             | id                  |
| user_id        | userId              |
| create_time    | createTime          |
| up_time        | upTime              |

3. Mapper 接口

```
OrderModel getById1(int id);
```

OrderModel 中的字段是骆驼命名法，结果也自动装配成功，这个就是开启`mapUnderscoreToCamelCase`产生的效果。

**方式 3**

mapper xml 中有个更强大的元素`resultMap`，通过这个元素可以定义查询结果的映射关系。

1. Mapper xml

```
<resultMap id="orderModelMap2" type="com.zkunm.model.OrderModel">
    <id column="id" property="id" />
    <result column="user_id" property="userId" />
    <result column="create_time" property="createTime" />
    <result column="up_time" property="upTime" />
</resultMap>

<select id="getById2" resultMap="orderModelMap2">
    SELECT a.id,a.user_id,a.create_time,a.up_time FROM t_order a WHERE a.id = #{value}
</select>
```

上面`resultMap`有 2 个元素需要指定：

- id：resultMap 标识
- type：将结果封装成什么类型，此处我们需要将结果分装为`OrderModel`

注意上面的 select 元素，有个`resultMap`，标识查询结果使用哪个`resultMap`进行映射，此处我们使用的是`orderModelMap2`，所以查询结果会按照`orderModelMap2`关联的`resultMap`进行映射。

2. Mapper 接口

```
OrderModel getById2(int id);
```

## 一对一关联查询 (4 种方式)

通过订单 id 查询订单的时候，将订单关联的用户信息也返回。

我们修改一下`OrderModel`代码，内部添加一个`UserModel`，如下：

```
@Getter
@Setter
@Builder
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class OrderModel {
    private Integer id;
    private Integer userId;
    private Long createTime;
    private Long upTime;

    //下单用户信息
    private UserModel userModel;
}
```

UserModel 内容：

```
@Getter
@Setter
@Builder
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class UserModel {
    private Integer id;
    private String name;
}
```

**方式 1**

```
<resultMap id="orderModelMap1" type="com.zkunm.model.OrderModel">
    <id column="id" property="id" />
    <result column="user_id" property="userId"/>
    <result column="create_time" property="createTime"/>
    <result column="up_time" property="upTime"/>
    <result column="user_id" property="userModel.id"/>
    <result column="name" property="userModel.name"/>
</resultMap>

<select id="getById1" resultMap="orderModelMap1">
    SELECT a.id, a.user_id, a.create_time, a.up_time, b.name FROM t_order a, t_user b WHERE a.user_id = b.id AND a.id = #{value}
</select>
```

注意重点在于上面的这两行：

```
<result column="user_id" property="userModel.id"/>
<result column="name" property="userModel.name"/>
```

这个地方使用到了级联赋值，多级之间用`.`进行引用，此处我们只有一级，可以有很多级。

**方式 2**

这次我们需要使用 mapper xml 中另外一个元素`association`，这个元素可以配置关联对象的映射关系

```
<resultMap id="orderModelMap2" type="com.zkunm.model.OrderModel">
    <id column="id" property="id" />
    <result column="user_id" property="userId"/>
    <result column="create_time" property="createTime"/>
    <result column="up_time" property="upTime"/>
    <association property="userModel">
        <id column="user_id" property="id"/>
        <result column="name" property="name" />
    </association>
</resultMap>

<select id="getById2" resultMap="orderModelMap2">
    SELECT a.id, a.user_id, a.create_time, a.up_time, b.name
    FROM t_order a, t_user b
    WHERE a.user_id = b.id
    AND a.id = #{value}
</select>
```

注意上面下面这部分代码：

```
<association property="userModel">
    <id column="user_id" property="id"/>
    <result column="name" property="name" />
</association>
```

注意上面的property属性，这个就是配置 sql 查询结果和OrderModel.userModel对象的映射关系，将user_id和userModel中的id进行映射,name和userModel中的name进行映射。

**方式 3**

先按照订单 id 查询订单数据，然后在通过订单中`user_id`去用户表查询用户数据，通过两次查询，组合成目标结果，mybatis 已经内置了这种操作，如下。

UserMapper.xml

我们先定义一个通过用户 id 查询用户信息的 select 元素，如下

```
<select id="getById" resultType="com.zkunm.model.UserModel">
    SELECT id,name FROM t_user where id = #{value}
</select>
```

OrderModel.xml

```
<resultMap id="orderModelMap3" type="com.zkunm.model.OrderModel">
    <id column="id" property="id" />
    <result column="user_id" property="userId"/>
    <result column="create_time" property="createTime"/>
    <result column="up_time" property="upTime"/>
    <association property="userModel" select="com.zkunm.mapper.UserMapper.getById" column="user_id" />
</resultMap>

<select id="getById3" resultMap="orderModelMap3">
    SELECT a.id, a.user_id, a.create_time, a.up_time
    FROM t_order a
    WHERE a.id = #{value}
</select>
```

`OrderModel.userModel`属性的值来在于另外一个查询，这个查询是通过`association`元素的`select`属性指定的，此处使用的是

```
com.zkunm.mapper.UserMapper.getById
```

这个查询是有条件的，条件通过`association`的`column`进行传递的，此处传递的是`getById3`查询结果中的`user_id`字段。

**方式 4**

方式 3 中给第二个查询传递了一个参数，如果需要给第二个查询传递多个参数怎么办呢？可以这么写

```
<association property="属性" select="查询对应的select的id" column="{key1=父查询字段1,key2=父查询字段2,key3=父查询字段3}" />
```

这种相当于给子查询传递了一个 map，子查询中 需要用过 map 的 key 获取对应的条件，看案例：

OrderMapper.xml

```
<resultMap id="orderModelMap4" type="com.zkunm.model.OrderModel">
    <id column="id" property="id" />
    <result column="user_id" property="userId"/>
    <result column="create_time" property="createTime"/>
    <result column="up_time" property="upTime"/>
    <association property="userModel" select="com.zkunm.mapper.UserMapper.getById1" column="{uid1=user_id,uid2=create_time}" />
</resultMap>

<select id="getById4" resultMap="orderModelMap4">
    SELECT a.id, a.user_id, a.create_time, a.up_time
    FROM t_order a
    WHERE a.id = #{value}
</select>
```

UserMapper.xml

```
<select id="getById1" resultType="com.zkunm.model.UserModel">
    SELECT id,name FROM t_user where id = #{uid1} and id = #{uid2}
</select>
```

## 一对多查询 (2 种方式)

根据订单 id 查询出订单信息，并且查询出订单明细列表。

先修改一下 OrderModel 代码，如下：

```
@Getter
@Setter
@Builder
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class OrderModel {
    private Integer id;
    private Integer userId;
    private Long createTime;
    private Long upTime;
    //订单详情列表
    private List<OrderDetailModel> orderDetailModelList;
}
```

OrderModel 中添加了一个集合`orderDetailModelList`用来存放订单详情列表。

**方式 1**

OrderMapper.xml

```
<resultMap id="orderModelMap1" type="com.zkunm.model.OrderModel">
    <id column="id" property="id"/>
    <result column="user_id" property="userId"/>
    <result column="create_time" property="createTime"/>
    <result column="up_time" property="upTime"/>
    <collection property="orderDetailModelList" ofType="com.zkunm.model.OrderDetailModel">
        <id column="orderDetailId" property="id"/>
        <result column="order_id" property="orderId"/>
        <result column="goods_id" property="goodsId"/>
        <result column="num" property="num"/>
        <result column="total_price" property="totalPrice"/>
    </collection>
</resultMap>

<select id="getById1" resultMap="orderModelMap1">
    SELECT a.id , a.user_id, a.create_time, a.up_time, b.id orderDetailId, b.order_id, b.goods_id, b.num, b.total_price
    FROM t_order a, t_order_detail b
    WHERE a.id = b.order_id AND a.id = #{value}
</select>
```

注意上面的`getById1`中的 sql，这个 sql 中使用到了`t_order和t_order_detail`连接查询，这个查询会返回多条结果，但是最后结果按照`orderModelMap1`进行映射，最后只会返回一个`OrderModel`对象，关键在于`collection`元素，这个元素用来定义集合中元素的映射关系，有 2 个属性需要注意：

- property：对应的属性名称
- ofType：集合中元素的类型，此处是`OrderDetailModel`

原理是这样的，注意`orderModelMap1`中有个

```
<id column="id" property="id"/>
```

查询出来的结果会按照这个配置中指定的`column`进行分组，即按照订单`id`进行分组，每个订单对应多个订单明细，订单明细会按照`collection`的配置映射为 ofType 元素指定的对象。

实际 resultMap 元素中的 id 元素可以使用`result`元素代替，只是用`id`可以提升性能，mybatis 可以通过 id 元素配置的列的值判断唯一一条记录，如果我们使用`result`元素，那么判断是否是同一条记录的时候，需要通过所有列去判断了，所以通过`id`可以提升性能，使用 id 元素在一对多中可以提升性能，在单表查询中使用 id 元素还是 result 元素，性能都是一样的

**方式 2**

通过 2 次查询，然后对结果进行分装，先通过订单 id 查询订单信息，然后通过订单 id 查询订单明细列表，然后封装结果。mybatis 中默认支持这么玩，还是通过`collection`元素来实现的。

OrderDetailMapper.xml

```
<select id="getListByOrderId1" resultType="com.zkunm.model.OrderDetailModel" parameterType="int">
    SELECT a.id, a.order_id AS orderId, a.goods_id AS goodsId, a.num, a.total_price AS totalPrice
    FROM t_order_detail a
    WHERE a.order_id = #{value}
</select>
```

OrderMapper.xml

```
<resultMap id="orderModelMap2" type="com.zkunm.model.OrderModel">
    <id column="id" property="id"/>
    <result column="user_id" property="userId"/>
    <result column="create_time" property="createTime"/>
    <result column="up_time" property="upTime"/>
    <collection property="orderDetailModelList" select="com.zkunm.mapper.OrderDetailMapper.getListByOrderId1" column="id"/>
</resultMap>

<select id="getById2" resultMap="orderModelMap2">
    SELECT a.id, a.user_id, a.create_time, a.up_time
    FROM t_order a
    WHERE a.id = #{value}
</select>
```

重点在于下面这句配置：

```
<collection property="orderDetailModelList" select="com.zkunm.mapper.OrderDetailMapper.getListByOrderId1" column="id"/>
```

表示`orderDetailModelList`属性的值通过`select`属性指定的查询获取，即：

```
com.zkunm.mapper.OrderDetailMapper.getListByOrderId1
```

查询参数是通过`column`属性指定的，此处使用`getById2` sql 中的`id`作为条件，即订单 id。

## 总结

1. mybatis 全局配置文件中通过`mapUnderscoreToCamelCase`可以开启 sql 中的字段和 javabean 中的骆驼命名法的字段进行自动映射
2. 掌握 resultMap 元素常见的用法
3. 一对一关联查询使用`resultMap->association`元素（2 种方式）
4. 一对多查询使用`resultMap->collection`元素（2 种方式）
5. resultMap 中使用`id`元素主要在复杂的关联查询中可以提升效率，可以通过这个来判断记录的唯一性，如果没有这个，需要通过所有的 result 相关的列才能判断记录的唯一性

# 7、自动映射

## 什么是自动映射？

介绍自动映射之前先看一下手动映射，如下：

```
<resultMap id="orderModelMap1" type="com.zkunm.model.OrderModel">
    <id column="id" property="id"/>
    <result column="userId" property="userId" />
    <result column="createTime" property="createTime" />
    <result column="upTime" property="upTime" />
</resultMap>

<select id="getById1" resultMap="orderModelMap1">
    SELECT a.id, a.user_id userId, a.create_time createTime, a.up_time upTime
    FROM t_order a
    WHERE a.id = #{value}
</select>
```

注意上面的 resultMap 元素中有 4 行配置，如下：

```
<id column="id" property="id"/>
<result column="userId" property="userId" />
<result column="createTime" property="createTime" />
<result column="upTime" property="upTime" />
```

这 4 行代码用于配置 sql 结果的列和 OrderModel 对象中字段的映射关系。

大家有没有注意到，映射规则中 column 和 property 元素的值都是一样，mybatis 中支持自动映射配置，当开启自动映射之后，当 sql 的列名和 Model 中的字段名称是一样的时候（不区分大小写），mybatis 内部会进行自动映射，不需要我们手动去写上面的 4 行映射规则。

下面我们将上面的示例改成自动映射的方式，如下：

```
<resultMap id="orderModelMap2" type="com.zkunm.model.OrderModel" autoMapping="true">
</resultMap>

<select id="getById2" resultMap="orderModelMap2">
    SELECT a.id, a.user_id userId, a.create_time createTime, a.up_time upTime
    FROM t_order a
    WHERE a.id = #{value}
</select>
```

注意上面的 resultMap 中的 autoMapping 属性，是否开启自动映射，我们设置为 true，这样 mybatis 会自动按照列名和 Model 中同名的字段进行映射赋值。

上面两个配置最后查询结果是一样的，都会将查询结果对应的 4 个字段的值自动赋值给 OrderModel 中同名的属性。

## 自动映射开关

mybatis 中自动映射主要有 2 种配置，一种是全局的配置，对应用中所有的 resultMap 起效，这个是在 mybatis 配置文件中进行设置的；另外一种是通过`resultMap`的`autoMapping`属性进行配置。

mybatis 判断某个 resultMap 是否开启自动映射配置的时候，会先查找自身的`autoMapping`属性，如果这个属性设置值了，就直接用这个属性的值，如果 resultMap 元素的`autoMapping`属性没有配置，则走全局配置的自动映射规则。

## mybatis 自动映射全局配置

在 mybatis 全局配置文件中加入下面配置：

```
<settings>
    <setting name="autoMappingBehavior" value="自动映射规则"/>
</settings>
```

autoMappingBehavior 值来源于枚举：`org.apache.ibatis.session.AutoMappingBehavior`，源码：

```
public enum AutoMappingBehavior {
  NONE,
  PARTIAL,
  FULL
}
```

- NONE：关闭全局映射开关
- PARTIAL：对除在内部定义了嵌套结果映射（也就是连接的属性）以外的属性进行映射，这个也是默认值。
- FULL：自动映射所有属性。

> settings 元素中有很多配置，这些配置最后都会被解析成org.apache.ibatis.session.Configuration的属性，源码位于org.apache.ibatis.builder.xml.XMLConfigBuilder#settingsElement方法中。

### NONE

mybatis-config.xml 加入配置

```
<settings>
    <!-- 关闭自动映射开关 -->
    <setting name="autoMappingBehavior" value="NONE"/>
</settings>
```

### PARTIAL

对除在内部定义了嵌套结果映射（也就是连接的属性）以外的属性进行映射，这个也是 autoMappingBehavior 的默认值。

mybatis-config.xml 加入配置

```
<settings>
    <!-- 对除在内部定义了嵌套结果映射（也就是连接的属性）以外的属性进行映射，这个也是autoMappingBehavior的默认值。 -->
    <setting name="autoMappingBehavior" value="PARTIAL"/>
</settings>
```

`PARTIAL`的解释：对除在内部定义了嵌套结果映射（也就是连接的属性）以外的属性进行映射。这句话是什么意思？

有些复杂的查询映射会在 resultMap 中嵌套一些映射（如：association，collection），当使用`PARTIAL`的时候，如果有嵌套映射，则这个嵌套映射不会进行自动映射了。

### FULL

自动映射所有属性。

```
<settings>
    <!-- 自动映射所有属性 -->
    <setting name="autoMappingBehavior" value="FULL"/>
</settings>
```

## autoMapping 使用

当在 resultMap 中指定了 autoMapping 属性之后，这个 resultMap 的自动映射就受 autoMapping 属性的控制，和 mybatis 中全局映射配置（autoMappingBehavior）行为无关了。

```
<resultMap id="orderModelMap7" type="com.zkunm.model.OrderModel" autoMapping="true">
    <association property="userModel" autoMapping="true">
        <id column="user_id" property="id"/>
    </association>
</resultMap>

<select id="getById7" resultMap="orderModelMap7">
    SELECT a.id, a.user_id userId, a.create_time createTime, a.up_time upTime, b.id as user_id, b.name
    FROM t_order a,t_user b
    WHERE a.user_id = b.id AND a.id = #{value}
</select>
```

> 如果配置中有个 column 属性，指定的是 id，此时 mybatis 认为你对 id 字段手动指定了映射关系，就跳过了对 id 字段到 OrderModel.id 属性的自动映射，此时需要我们在`orderModelMap8`手动指定 id 的映射规则



# 8、延迟加载、鉴别器、继承

4 张表:

t_user(用户表)

t_goods(商品表)

t_order(订单表)

t_order_detail(订单明细表)

表之间的关系：

t_order 和 t_user 是一对一的关系，一条订单关联一个用户记录

t_order 和 t_order_detail 是一对多关系，每个订单中可能包含多个子订单，每个子订单对应一个商品

```mysql
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user(
  id int AUTO_INCREMENT PRIMARY KEY COMMENT '用户id',
  name VARCHAR(32) NOT NULL DEFAULT '' COMMENT '用户名'
) COMMENT '用户表';
INSERT INTO t_user VALUES (1,'张学友'),(2,'路人甲Java');

DROP TABLE IF EXISTS t_goods;
CREATE TABLE t_goods(
  id int AUTO_INCREMENT PRIMARY KEY COMMENT '商品id',
  name VARCHAR(32) NOT NULL DEFAULT '' COMMENT '商品名称',
  price DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '商品价格'
) COMMENT '商品信息表';
INSERT INTO t_goods VALUES (1,'Mybatis系列',8.88),(2,'maven高手系列',16.66);

DROP TABLE IF EXISTS t_order;
CREATE TABLE t_order(
  id int AUTO_INCREMENT PRIMARY KEY COMMENT '订单id',
  user_id INT NOT NULL DEFAULT 0 COMMENT '用户id，来源于t_user.id',
  create_time BIGINT NOT NULL DEFAULT 0 COMMENT '订单创建时间(时间戳，秒)',
  up_time BIGINT NOT NULL DEFAULT 0 COMMENT '订单最后修改时间(时间戳，秒)'
) COMMENT '订单表';
INSERT INTO t_order VALUES (1,2,unix_timestamp(now()),unix_timestamp(now())),(2,1,unix_timestamp(now()),unix_timestamp(now())),(3,1,unix_timestamp(now()),unix_timestamp(now()));

DROP TABLE IF EXISTS t_order_detail;
CREATE TABLE t_order_detail(
  id int AUTO_INCREMENT PRIMARY KEY COMMENT '订单明细id',
  order_id INT NOT NULL DEFAULT 0 COMMENT '订单id，来源于t_order.id',
  goods_id INT NOT NULL DEFAULT 0 COMMENT '商品id，来源于t_goods.id',
  num INT NOT NULL DEFAULT 0 COMMENT '商品数量',
  total_price DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '商品总金额'
) COMMENT '订单表';
INSERT INTO t_order_detail VALUES (1,1,1,2,17.76),(2,1,1,1,16.66),(3,2,1,1,8.88),(4,3,1,1,8.88);

select * from t_user;
select * from t_goods;
select * from t_order;
select * from t_order_detail;
```

## 延迟加载

延迟加载其实就是将数据加载时机推迟，比如推迟嵌套查询的执行时机，在 mybatis 中经常用到关联查询，但是并不是任何时候都需要立即返回关联查询结果。比如查询订单信息，并不一定需要及时返回订单对应的用户信息或者订单详情信息等，这种情况需要一种机制，当需要查看关联的数据时，再去执行对应的查询，返回需要的结果，这种需求在 mybatis 中可以使用延迟加载机制来实现。

### 延迟加载 2 种设置方式

1. 全局配置的方式
2. sqlmap 中配置的方式

方式 1 中会对所有关联查询起效，而方式 2 只会对相关设置的查询起效。

#### 全局配置延迟加载

mybatis 配置文件中通过下面两个属性来控制延迟加载：

```
<settings>
    <!--打开延迟加载的开关  -->
    <setting name="lazyLoadingEnabled" value="true"/>
    <!-- 当为true的时候，调用任意延迟属性，会去加载所有延迟属性，如果为false，则调用某个属性的时候，只会加载指定的属性 -->
    <setting name="aggressiveLazyLoading" value="false"/>
</settings>
```

lazyLoadingEnabled：这个属性比较好理解，是否开启延迟加载，默认为 false，如果需要开启延迟加载，将其设置为 true

aggressiveLazyLoading：当为 true 的时候，调用任意延迟属性，会去加载所有延迟属性，如果为 false，则调用某个属性的时候，只会加载指定的属性

#### mapper中设置延迟加载

全局的方式会对所有的关联查询起效，影响范围比较大，mybatis 也提供了在关联查询中进行设置的方式，只会对当前设置的关联查询起效。

关联查询，一般我们使用`association、collection`，这两个元素都有个属性`fetchType`，通过这个属性可以指定关联查询的加载方式。

```
fetchType值有2种，eager：立即加载；lazy：延迟加载。
```

## 鉴别器 (discriminator)

有时候，一个数据库查询可能会返回多个不同的结果集（但总体上还是有一定的联系的）， 鉴别器（discriminator）元素就是被设计来应对这种情况的，鉴别器的概念很好理解——它很像 Java 语言中的 switch 语句。

discriminator 标签常用的两个属性如下：

- column：该属性用于设置要进行鉴别比较值的列。
- javaType：该属性用于指定列的类型，保证使用相同的 java 类型来比较值。

discriminator 标签可以有 1 个或多个 case 标签，case 标签有一个比较重要的属性：

- value：该值为 discriminator 指定 column 用来匹配的值，当匹配的时候，结果会走这个 case 关联的映射。

我们使用鉴别器实现一个功能：通过订单 id 查询订单信息，当传入的订单 id 为 1 的时候，获取订单信息及下单人信息；当传入的订单 id 为 2 的时候，获取订单信息、下单人信息、订单明细信息；其他情况默认只查询订单信息。

OrderMapper.xml

```
<resultMap id="orderModelMap1" type="com.zkunm.model.OrderModel">
    <id column="id" property="id"/>
    <result column="user_id" property="userId"/>
    <result column="create_time" property="createTime"/>
    <result column="up_time" property="upTime"/>
    <!-- 鉴别器 -->
    <discriminator javaType="int" column="id">
        <case value="1">
            <!--通过用户id查询用户信息-->
            <association property="userModel" select="com.zkunm.mapper.UserMapper.getById1" column="user_Id"/>
        </case>
        <case value="2">
            <!--通过用户id查询用户信息-->
            <association property="userModel" select="com.zkunm.mapper.UserMapper.getById1" column="user_Id"/>
            <!--通过订单id查询订单列表-->
            <collection property="orderDetailModelList" select="com.zkunm.mapper.OrderDetailMapper.getListByOrderId1" column="id"/>
        </case>
    </discriminator>
</resultMap>

<select id="getById1" resultMap="orderModelMap1">
    SELECT a.id , a.user_id, a.create_time, a.up_time
    FROM t_order a
    WHERE a.id = #{value}
</select>
```

注意上面的 discriminator，这部分是关键，discriminator 内部的 case 会和每行查询结果中的 id 字段进行匹配，匹配成功了 case 内部的关联查询会被执行，未匹配上的，只会走 discriminator 外部默认配置的映射映射规则

## 继承 (extends)

继承在 java 是三大特性之一，可以起到重用代码的作用，而 mybatis 也有继承的功能，和 java 中的继承的作用类似，主要在 resultMap 中使用，可以重用其他 resultMap 中配置的映射关系。

```
<resultMap extends="被继承的resultMap的id"></resultMap>
```

```xml
<resultMap id="orderModelMap2" type="com.zkunm.model.OrderModel">
    <id column="id" property="id"/>
    <result column="user_id" property="userId"/>
    <result column="create_time" property="createTime"/>
    <result column="up_time" property="upTime"/>
    <!-- 鉴别器 -->
    <discriminator javaType="int" column="id">
        <case value="1" resultMap="orderModelMap3" />
        <case value="2" resultMap="orderModelMap4" />
    </discriminator>
</resultMap>

<resultMap id="orderModelMap3" type="com.zkunm.model.OrderModel" extends="orderModelMap2">
    <!--通过用户id查询用户信息-->
    <association property="userModel" select="com.zkunm.mapper.UserMapper.getById1" column="user_Id"/>
</resultMap>

<resultMap id="orderModelMap4" type="com.zkunm.model.OrderModel" extends="orderModelMap3">
    <!--通过订单id查询订单列表-->
    <collection property="orderDetailModelList" select="com.zkunm.mapper.OrderDetailMapper.getListByOrderId1" column="id"/>
</resultMap>

<select id="getById2" resultMap="orderModelMap2">
    SELECT a.id, a.user_id, a.create_time, a.up_time
    FROM t_order a
    WHERE a.id = #{value}
</select>
```

重点在于上面两个 extends 属性，上面 orderModelMap3 继承了 orderModelMap2 中配置的映射关系（除鉴别器之外），自己又加入了一个 association 去查询用户信息；orderModelMap4 继承了 orderModelMap3，自己又加入了一个查询订单列表的 collection 元素

# 9、动态 SQL

```
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user(
  id int AUTO_INCREMENT PRIMARY KEY COMMENT '用户id',
  name VARCHAR(32) NOT NULL DEFAULT '' COMMENT '用户名',
  age SMALLINT NOT NULL DEFAULT 1 COMMENT '年龄'
) COMMENT '用户表';
INSERT INTO t_user VALUES (1,'路人甲Java',30),(2,'张学友',50),(3,'刘德华',50);
```

## if 元素

相当于 java 中的 if 判断，语法：

```
<if test="判断条件">需要追加的sql</if>
```

test 的值为一个判断表达式，写法上采用 OGNL 表达式的方式

当 test 成立的时候，if 体内部的 sql 会被拼接上。

如：

```
<select id="getList1" resultType="com.zkunm.model.UserModel" parameterType="map">
    SELECT id,name,age FROM t_user
    WHERE 1 = 1
    <if test="id!=null">
        AND id = #{id}
    </if>
    <if test="name!=null and name.toString()!=''">
        AND name = #{name}
    </if>
    <if test="age!=null">
        AND age = #{age}
    </if>
</select>
```

上面查询用户列表，参数为一个 map，当 map 中 id 不为空的时候，将其作为条件查询，如果 name 不为空，将 name 也作为条件，如果 age 不为空，将 age 也作为条件进行查询

当只传入 id 的时候，sql 如下：

```
SELECT id,name,age FROM t_user WHERE 1 = 1 AND id = ?
```

当 3 个参数都传了，sql 如下：

```
SELECT id,name,age FROM t_user WHERE 1 = 1 AND id = ? AND name = ? AND age = ?
```

上面这种写法相对于 java 代码看起来是不是清爽了很多，也更方便维护，大家注意一下 sql 中有个`WHERE 1=1`，如果没有这个，上面单通过 if 元素就不好实现了，mybatis 也有解决方案，稍后会说明。

## choose/when/otherwise 元素

这个相当于 java 中的`if..else if..else`，语法：

```
<choose>
    <when test="条件1">
        满足条件1追加的sql
    </when>
    <when test="条件2">
        满足条件2追加的sql
    </when>
    <when test="条件n">
        满足条件n追加的sql
    </when>
    <otherwise>
        都不满足追加的sql
    </otherwise>
</choose>
```

choose 内部的条件满足一个，choose 内部的 sql 拼接就会结束。

otherwise 属于可选的，当所有条件都不满足的时候，otherwise 将起效。

如：

传入 id、name、age 作为条件，按顺序进行判断，如果 id 不为空，将 id 作为条件，忽略其他条件，如果 id 为空，会判断 name 是否为空，name 不为空将 name 作为条件，如果 name 为空，再看看 age 是否为空，如果 age 不为空，将 age 作为条件。

```
<select id="getList2" resultType="com.zkunm.model.UserModel" parameterType="map">
    SELECT id,name,age FROM t_user
    WHERE 1 = 1
    <choose>
        <when test="id!=null">
            AND id = #{id}
        </when>
        <when test="name!=null and name.toString()!=''">
            AND name = #{name}
        </when>
        <when test="age!=null">
            AND age = #{age}
        </when>
    </choose>
</select>
```

如果 id、name、age 都传了，sql 如下：

```
SELECT id,name,age FROM t_user WHERE 1 = 1 AND id = ?
```

如果值传递了 name、age，sql 如下：

```
SELECT id,name,age FROM t_user WHERE 1 = 1 AND name = ?
```

name 判断在 age 前面，所以 name 条件先匹配上了。

## where 元素

上面 2 个案例的 sql 中都有`where 1=1`这部分代码，虽然可以解决问题，但是看起来不美观，如果将`where 1=1`中`1=1`这部分干掉，上面的两个案例都会出问题，where 后面会多一个`AND`符号，mybatis 中已经考虑到这种问题了，属于通用性的问题，mybatis 中通过`where 元素`来解决，当使用 where 元素的时候，mybatis 会将 where 内部拼接的 sql 进行处理，会将这部分 sql 前面的`AND 或者 OR`给去掉，并在前面追加一个 where，我们使用 where 元素来对上面的案例 1 进行改造，如下：

```
<select id="getList1" resultType="com.zkunm.model.UserModel" parameterType="map">
    SELECT id,name,age FROM t_user
    <where>
        <if test="id!=null">
            AND id = #{id}
        </if>
        <if test="name!=null and name.toString()!=''">
            AND name = #{name}
        </if>
        <if test="age!=null">
            AND age = #{age}
        </if>
    </where>
</select>
```

`where 1=1`被替换成了`where 元素`

## set 元素

现在我们想通过用户 id 更新用户信息，参数为 UserModel 对象，对象中的属性如果不为空，就进行更新，我们可以这么写：

```
<update id="update1" parameterType="com.zkunm.model.UserModel">
    UPDATE t_user SET
    <if test="name!=null">
        name = #{name},
    </if>
    <if test="age!=null">
        age = #{age},
    </if>
    <where>
        <if test="id!=null">
            AND id = #{id}
        </if>
    </where>
</update>
```

我们来看一下，当所有属性都传值了，sql 变成了下面这样：

```
UPDATE t_user SET name = ?, age = ?, where id = ?
```

上面这个 sql 是有问题的，where 前面多了一个逗号，得想办法将这个逗号去掉，这个逗号属于最后一个需要更新的字段后面的逗号，属于多余的，mybatis 中提供了 set 元素来解决这个问题，将上面的代码改成下面这样：

```
<update id="update1" parameterType="com.zkunm.model.UserModel">
    UPDATE t_user
    <set>
        <if test="name!=null">
            name = #{name},
        </if>
        <if test="age!=null">
            age = #{age},
        </if>
    </set>
    <where>
        <if test="id!=null">
            AND id = #{id}
        </if>
    </where>
</update>
```

我们将 sql 中的 set 去掉了，加了个 set 元素，set 元素会对其内部拼接的 sql 进行处理，会将这部分 sql 前后的逗号给去掉并在前面加上set。

当传入 id 和 age 的时候，生成的 sql：

```
UPDATE t_user SET age = ? where id = ?
```

## trim 元素

```
<trim prefix="" prefixOverrides="" suffix="" suffixOverrides=""></trim>
```

trim 元素内部可以包含各种动态 sql，如 where、chose、sql 等各种元素，使用 trim 包含的元素，mybatis 处理过程：

1. 先对 trim 内部的 sql 进行拼接，比如这部分 sql 叫做 sql1
2. 将 sql1 字符串前面的部分中包含 trim 的 prefixOverrides 指定的部分给去掉，得到 sql2
3. 将 sql2 字符串后面的部分中包含 trim 的 suffixOverrides 指定的部分给去掉，得到 sql3
4. 在 sql3 前面追加 trim 中 prefix 指定的值，得到 sql4
5. 在 sql4 后面追加 trim 中 suffix 指定的值，得到最终需要拼接的 sql5

了解了这个过程之后，说明可以通过 trim 来代替 where 和 set，我们使用 trim 来改造一下案例 1，如下：

```
<select id="getList1" resultType="com.zkunm.model.UserModel" parameterType="map">
    SELECT id,name,age FROM t_user
    <trim prefix="where" prefixOverrides="and|or">
        <if test="id!=null">
            AND id = #{id}
        </if>
        <if test="name!=null and name.toString()!=''">
            AND name = #{name}
        </if>
        <if test="age!=null">
            AND age = #{age}
        </if>
    </trim>
</select>
```

注意上面的 prefixOverrides 的值的写法，如果有多个需要覆盖的之间用 | 进行分割，suffixOverrides 写法和 prefixOverrides 的写法类似。

我们在用 trim 来改造一下上面的 update 中的，如下：

```
<update id="update1" parameterType="com.zkunm.model.UserModel">
    UPDATE t_user
    <trim prefix="SET" prefixOverrides="," suffixOverrides=",">
        <if test="name!=null">
            name = #{name},
        </if>
        <if test="age!=null">
            age = #{age},
        </if>
    </trim>
    <where>
        <if test="id!=null">
            AND id = #{id}
        </if>
    </where>
</update>
```

上面的 prefixOverrides 和 suffixOverrides 都设置的是逗号，表示 trim 内部的 sql 前后的逗号会被去掉，最后会在前面拼接一个 prefix 指定的 set。

大家有兴趣的可以去看一下 trim 的 java 实现，代码下面这个类中：

```
org.apache.ibatis.scripting.xmltags.TrimSqlNode
```

实际上 where 和 set 的实现是继承了`TrimSqlNode`，where 对应的 java 代码：

```
public class WhereSqlNode extends TrimSqlNode {
  private static List<String> prefixList = Arrays.asList("AND ","OR ","AND\n", "OR\n", "AND\r", "OR\r", "AND\t", "OR\t");
  public WhereSqlNode(Configuration configuration, SqlNode contents) {
    super(configuration, contents, "WHERE", prefixList, null, null);
  }
}
```

set 对应的 java 代码：

```
public class SetSqlNode extends TrimSqlNode {
  private static final List<String> COMMA = Collections.singletonList(",");
  public SetSqlNode(Configuration configuration,SqlNode contents) {
    super(configuration, contents, "SET", COMMA, null, COMMA);
  }
}
```

最后都是依靠 TrimSqlNode 来实现的。

## foreach 元素

相当于 java 中的循环，可以用来遍历数组、集合、map 等。

```
<foreach collection="需要遍历的集合" item="集合中当前元素" index="" open="" separator="每次遍历的分隔符" close="">
动态sql部分
</foreach>
```

- collection：可以是一个 List、Set、Map 或者数组
- item：集合中的当前元素的引用
- index：用来访问当前元素在集合中的位置
- separator：各个元素之间的分隔符
- open 和 close 用来配置最后用什么前缀和后缀将 foreach 内部所有拼接的 sql 给包装起来。

### 案例：in 多值查询

我们对案例 1 做个改造，map 中支持放入用户的 id 列表（ArrayList），对应的 key 为 idList，然后支持多个用户 id 查询，此时我们需要用 in 来查询，实现如下：

```
<select id="getList1" resultType="com.zkunm.model.UserModel" parameterType="map">
    SELECT id,name,age FROM t_user
    <where>
        <if test="id!=null">
            AND id = #{id}
        </if>
        <if test="name!=null and name.toString()!=''">
            AND name = #{name}
        </if>
        <if test="age!=null">
            AND age = #{age}
        </if>
        <if test="idList!=null and idList.size()>=1">
            <foreach collection="idList" item="id" open="AND id in (" separator="," close=")">
                #{id}
            </foreach>
        </if>
    </where>
</select>
```

大家看一下上面 idList 那部分判断，判断这个参数不为空，并且 size() 大于 1，表示这个集合不为空，然后会走 if 元素内部的 foreach 元素。

比如我们传递的 idList 对应的是 [1,2]，最后产生的 sql 如下：

```
SELECT id,name,age FROM t_user WHERE id in ( ? , ? )
```

### 案例：批量插入

传入 UserModel List 集合，使用 foreach 实现批量插入，如下：

```
<insert id="insertBatch" parameterType="list">
    INSERT INTO t_user (id,name,age) VALUES
    <foreach collection="collection" separator="," item="item">
        (#{item.id}, #{item.name}, #{item.age})
    </foreach>
</insert>
```

## sql/include 元素

这两 2 个元素一般进行配合使用，可以实现代码重用的效果。

sql 元素可以用来定义一段动态 sql，语法如下：

```
<sql id="sql片段id">
各种动态sql
</sql>
```

其他地方需要使用的时候需要通过 include 关键字进行引入：

```
<include refid="需要引入的sql片段的id"/>
```

注意：refid 值的写法，refid 的值为 mapper xml 的namespace的值.sql的id，如果在同一个 mapper 中，namespace 可以省略，直接写对应的 sql 的 id 就可以了，如：

```xml
<sql id="findSql">
    <where>
        <if test="id!=null">
            AND id = #{id}
        </if>
        <if test="name!=null and name.toString()!=''">
            AND name = #{name}
        </if>
        <if test="age!=null">
            AND age = #{age}
        </if>
        <if test="idList!=null and idList.size()>=1">
            <foreach collection="idList" item="id" open="AND id in (" separator="," close=")">
                #{id}
            </foreach>
        </if>
    </where>
</sql>

<select id="getList1" resultType="com.zkunm.model.UserModel" parameterType="map">
    SELECT id,name,age FROM t_user
    <include refid="com.zkunm.mapper.UserMapper.findSql" />
</select>

<select id="getList1Count" resultType="com.zkunm.model.UserModel" parameterType="map">
    SELECT count(*) FROM t_user
    <include refid="findSql" />
</select>
```

## bind 元素

bind 元素允许我们通过 ognl 表达式在上下文中自定义一个变量，最后在动态 sql 中可以使用这个变量

```
<bind name="变量名称" value="ognl表达式">
```

对 sql、include 中的案例进行扩展，添加一个按照用户名模糊查询，用户名在 map 中对应的 key 为`likeName`，主要修改上面 sql 片段部分，在 sql 中加入下面部分：

```
<if test="likeName!=null and likeName.trim()!=''">
  <bind name="nameLike" value="'%'+likeName.trim()+'%'" />
  AND name like #{nameLike}
</if>
```

先判断传入的参数 likeName 是否不为空字符串，然后使用 bind 元素创建了一个变量`nameLike`，值为`'%'+likeName.trim()+'%'`。

## #和 $

#和 $ 一般都是结合变量来使用，如：#{}、${} 这种来进行使用。

#{}: 为参数占位符？，即 sql 预编译，相当于使用 jdbc 中的 PreparedStatement 中的 sql 占位符，可以防止 sql 注入

${}: 为字符串替换， 即字符串拼接，不能访sql 注入。

\#{} 的用法上面已经有很多案例了，此处我们来一个 ${} 的案例。

下面通过 orderSql 变量传入任意的排序 sql，如下：

```
<select id="getList1" resultType="com.zkunm.model.UserModel" parameterType="map">
    SELECT id,name,age FROM t_user
    <if test="orderSql">
        ${orderSql}
    </if>
</select>
```

传入值：

```
orderSql = "order by id asc,age desc"
```

# 10、类型处理器

## mybatis 内部参数设置和结果的处理

先来看一个案例：

jdbc 的方式插入用户信息，参数为 UserModel：

```
public class UserModel {
    private Integer id;
    private String name;
    private Integer age;
}

public static int insert(UserModel userModel) throws SQLException {
    Connection connection = null;
    String sql = "insert into t_user (id,name,age) values (?,?,?)";
    PreparedStatement preparedStatement = connection.prepareStatement(sql);
    preparedStatement.setInt(1,userModel.getId());
    preparedStatement.setString(2,userModel.getName());
    preparedStatement.setInt(3,userModel.getAge());
    return preparedStatement.executeUpdate();
}
```

上面我们调用了`preparedStatement`的几个方法来设置参数，如下：

```
preparedStatement.setInt(1,userModel.getId());
preparedStatement.setString(2,userModel.getName());
preparedStatement.setInt(3,userModel.getAge());
```

当我们使用 mybatis 插入用户信息的时候，mybatis 底层也会调用`PreparedStatement`的这些设置参数的方法，mybatis 底层是如何判断调用哪个方法的呢？

是调用`setInt`方法还是`setString`方法的呢？

再来看一个 jdbc 查询的案例，查询出 t_user 表所有数据，将其转换为 UserModel 对象，核心代码如下：

```
public static List<UserModel> getList() throws Exception {
    List<UserModel> result = new ArrayList<>();
    Connection connection = null;
    String sql = "select id,name,age from t_user";
    PreparedStatement preparedStatement = connection.prepareStatement(sql);
    ResultSet rs = preparedStatement.executeQuery();
    while (rs.next()) {
        UserModel userModel = new UserModel();
        userModel.setId(rs.getInt(1));
        userModel.setName(rs.getString(2));
        userModel.setAge(rs.getInt(3));
        result.add(userModel);
    }
    return result;
}
```

上面有几行从`ResultSet`获取数据的方法，如下：

```
userModel.setId(rs.getInt(1));
userModel.setName(rs.getString(2));
userModel.setAge(rs.getInt(3));
```

如果使用 mybatis 实现，mybatis 可以将 sql 结果自动映射到 UserModel 中的属性中，mybatis 内部给 UserModel 的 id 设置值的时候，mybatis 内部是如何知道是调用`rs.getInt`还是调用`rs.getString`来获取`id`列的值的呢？

这些就是 mybatis 中类型转换器做的事情，类型转换器主要有 2 个功能：

1. 参数设置，即设置参数的时候需要调用 PreparedStatement 中哪个 set 方法去设置参数，比如：插入用户信息 id 字段，id 字段是 java 中的 Integer 类型的，mybatis 内部知道需要调用 setInt 方法去给 id 字段设置参数。
2. 将 sql 查询结果转换为对应的 java 类型，即调用 ResultSet 中的哪个 get 方法去获取参数，比如：id 在数据中是 int 类型的，读取的时候会调用 ResultSet 的 getInt 方法去读取，而 name 字段在 db 中是 varchar 类型的，读取的时候会调用 getString 方法去读取，而不是调用 getInt 方法去读取。

mybatis 中定义了一个类型转换器的接口：

```
public interface TypeHandler<T> {

  void setParameter(PreparedStatement ps, int i, T parameter, JdbcType jdbcType) throws SQLException;

  /**
   * @param columnName Colunm name, when configuration <code>useColumnLabel</code> is <code>false</code>
   */
  T getResult(ResultSet rs, String columnName) throws SQLException;

  T getResult(ResultSet rs, int columnIndex) throws SQLException;

  T getResult(CallableStatement cs, int columnIndex) throws SQLException;

}
```

第一个方法用于通过 PreparedStatement 设置参数的，即内部会根据参数的类型，去调用`PreparedStatement`中对应的方法去设置参数的值，比如是调用 setInt 方法呢还是 setString 方法，每个类型转换器中实现的是不同的。其他 3 个方法是从结果集中读取数据的，内部具体是调用结果集的 getInt 方法还是 getString 方法或者是 getObject 方法，每个转换器内部实现也是不一样的。

mybatis 内部默认实现了很多类型转换器，基本上够我们用了，比如 IntegerTypeHandler 转换器，IntegerTypeHandler 主要用来处理 java 中的 Integer、int 类型参数的，所以会调用 setInt 方法设置参数；读取的时候，对应的 jdbc 中的类型是 JdbcType.INTEGER，所以会调用 getInt 方法读取数据库返回的值，读取的结果是 Integer 类型的。我们看一下其源码：

```
public class IntegerTypeHandler extends BaseTypeHandler<Integer> {

  @Override
  public void setNonNullParameter(PreparedStatement ps, int i, Integer parameter, JdbcType jdbcType)
      throws SQLException {
    ps.setInt(i, parameter);
  }

  @Override
  public Integer getNullableResult(ResultSet rs, String columnName)
      throws SQLException {
    int result = rs.getInt(columnName);
    return result == 0 && rs.wasNull() ? null : result;
  }

  @Override
  public Integer getNullableResult(ResultSet rs, int columnIndex)
      throws SQLException {
    int result = rs.getInt(columnIndex);
    return result == 0 && rs.wasNull() ? null : result;
  }

  @Override
  public Integer getNullableResult(CallableStatement cs, int columnIndex)
      throws SQLException {
    int result = cs.getInt(columnIndex);
    return result == 0 && cs.wasNull() ? null : result;
  }
}
```

mybatis 内部默认实现了很多类型转换器，每种类型转换器能够处理哪些 java 类型以及能够处理的 JdbcType 的类型，这些都在`TypeHandlerRegistry`进行注册的，大家可以去看一下这个类源码，IntegerTypeHandler 也是在这个类中进行注册的，代码如下：

```
register(Integer.class, new IntegerTypeHandler());
register(int.class, new IntegerTypeHandler());
register(JdbcType.INTEGER, new IntegerTypeHandler());
```

所以当我们参数是 Integer 或者 int 类型的时候，mybatis 会调用 IntegerTypeHandler 转换器中的 setInt 方法去设置参数，上面我们的 UserModel 的 id 字段是 Integer 类型的，所以插入数据的时候会调用 IntegerTypeHandler 处理器中的 setInt 方法去设置参数，当 mybatis 将 t_user 表的数据自动映射为 UserModel 类型的时候，mybatis 会发现 id 类型是 Integer 类型，然后会找到 IntegerTypeHandler 中对应的读取结果集的方法去读取数据，即调用 ResultSet 的 getInt 方法读取 id 字段的数据，然后赋值给 UserModel 中的 id 属性

## 自定义类型转换器

我们在用户表新增一个性别字段 sex，java 中我们通过一个枚举来表示这个类型，db 脚本如下：

```
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user(
  id int AUTO_INCREMENT PRIMARY KEY COMMENT '用户id',
  name VARCHAR(32) NOT NULL DEFAULT '' COMMENT '用户名',
  age SMALLINT NOT NULL DEFAULT 1 COMMENT '年龄',
  sex SMALLINT DEFAULT 0 COMMENT '性别，0：未知，1：男，2：女'
) COMMENT '用户表';
INSERT INTO t_user VALUES (1,'Java',30,1),(2,'林志玲',45,2);
```

t_user 对应的 Model 如下：

```
@Getter
@Setter
@Builder
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class UserModel implements Serializable {
    private Integer id;
    private String name;
    private Integer age;
    private SexEnum sex;
}
```

sex 是一个枚举类型，枚举定义如下：

```
public enum SexEnum {
    UNKNOW(0, "未知"),
    MAN(1, "男"),
    WOMAN(2, "女");

    private Integer value;
    private String name;

    SexEnum(Integer value, String name) {
        this.value = value;
        this.name = name;
    }

    public Integer getValue() {
        return value;
    }

    public String getName() {
        return name;
    }

    public static SexEnum getByValue(Integer value) {
        for (SexEnum item : values()) {
            if (item.getValue().equals(value)) {
                return item;
            }
        }
        return null;
    }
}
```

我们来写一个查询如下：

```
<select id="getList1" resultType="com.zkunm.model.UserModel">
SELECT id,name,age,sex FROM t_user
</select>
```

sex 字段在 t_user 中是数字类型的，最后通过 mybatis 查询，需要赋值给 UserModel 中的 sex 字段，这个字段是一个枚举类型的，mybatis 不知道这两者之间如何进行转换

此时需要我们指定一个转换规则，来告知 mybatis 如何进行转换，需要我们用到自定义类型转换器了。

自定义一个类型转换器 SexEnumTypeHandle，用来处理 sex 字段和 SexEnum 枚举之间的相互转换，代码如下：

```java
@Slf4j
public class SexEnumTypeHandle extends BaseTypeHandler<SexEnum> {
    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, SexEnum parameter, JdbcType jdbcType) throws SQLException {
        ps.setInt(i, parameter.getValue());
        log.info("{}", parameter);
    }

    @Override
    public SexEnum getNullableResult(ResultSet rs, String columnName) throws SQLException {
        log.info("{}", columnName);
        Object object = rs.getObject(columnName);
        Integer sex = object != null && object instanceof Integer ? (Integer) object : null;
        return SexEnum.getByValue(sex);
    }

    @Override
    public SexEnum getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        log.info("{}", columnIndex);
        Object object = rs.getObject(columnIndex);
        Integer sex = object != null && object instanceof Integer ? (Integer) object : null;
        return SexEnum.getByValue(sex);
    }

    @Override
    public SexEnum getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        log.info("{}", columnIndex);
        Object object = cs.getObject(columnIndex);
        Integer sex = object != null && object instanceof Integer ? (Integer) object : null;
        return SexEnum.getByValue(sex);
    }
}
```

自定义类型转换器可以直接继承 BaseTypeHandler，后面有个泛型，泛型类型为需要处理的 java 类型，即 SexEnum。

类型转换器定义好了，需要将其注册到 mybatis 中，需要在 mybatis 配置文件中加入：

```
<typeHandlers>
    <typeHandler handler="com.zkunm.typehandle.SexEnumTypeHandle"/>
</typeHandlers>
```

再来一个案例，向用户表插入用户信息，参数为一个 map，每个字段的值丢在 map 中，key 为字段的名称，sex 我们传递 SexEnum 枚举类型。

对应的 java 测试用例代码如下：

```
@Test
public void insert1() throws IOException {
    try (SqlSession sqlSession = this.sqlSessionFactory.openSession(true);) {
        UserMapper mapper = sqlSession.getMapper(UserMapper.class);
        Map<String, Object> map = new HashMap<>();
        Integer id = Integer.valueOf(Calendar.getInstance().getTime().getTime() / 1000 + "");
        map.put("id", id);
        map.put("name", id.toString());
        map.put("age", 30);
        map.put("sex", SexEnum.WOMAN);
        int result = mapper.insert1(map);
        log.info("{}", result);
    }
}
```

对应 mapper xml 我们按照下面这种写法，如：

```
<insert id="insert1" parameterType="map">
    insert into t_user (id,name,age,sex)
    VALUE (#{id},#{name},#{age},#{sex})
</insert>
```

map 中 sex 对应的是`SexEnum.WOMAN`，mybatis 中判断 map 中 sex 对应的是 SexEnum 类型的，所以会找到其对应的类型转换器`SexEnumTypeHandle`

但是当我们不传递 sex 的值的时候，或者说 sex 传递为 null 的时候，此时 mybatis 是无法判断 map 中 sex 对应的具体类型的，mybatis 内部将无法判断 sex 参数的设置的时候，无法找到具体用哪个类型转换器给 sex 设置参数，这个在 mysql 中不会报错，但是在 oracle 中会报错

```
@Test
public void insert1() throws IOException {
    try (SqlSession sqlSession = this.sqlSessionFactory.openSession(true);) {
        UserMapper mapper = sqlSession.getMapper(UserMapper.class);
        Map<String, Object> map = new HashMap<>();
        Integer id = Integer.valueOf(Calendar.getInstance().getTime().getTime() / 1000 + "");
        map.put("id", id);
        map.put("name", id.toString());
        map.put("age", 30);
        map.put("sex", null);
        int result = mapper.insert1(map);
        log.info("{}", result);
    }
}
```

上面代码 oracle 中执行会报错，需要修改对应的 mapper xml 中的代码，需要让 mybatis 明确知道 sex 字段需要用哪个类型转换器进行处理，有 2 种写法。

第一种，通过 typeHandler 属性明确指定参数的类型转换器，如下

```
<insert id="insert1" parameterType="map">
    insert into t_user (id,name,age,sex)
    VALUE (#{id},#{name},#{age},#{sex,typeHandler=com.zkunm.typehandle.SexEnumTypeHandle})
</insert>
```

第二种，可以指定 sex 字段的类型，需要通过 javaType 属性来指定参数的具体类型，如下：

```
<insert id="insert1" parameterType="map">
    insert into t_user (id,name,age,sex)
    VALUE (#{id},#{name},#{age},#{sex,javaType=com.zkunm.enums.SexEnum})
</insert>
```

mybatis 通过 java 的类型就可以找到对应的类型转换器，所以方式 2 也是正常的。

**再来总结一下自定义类型转换器的使用步骤：**

1. **自定义类型转换器，继承 BaseTypeHandler**
2. **将自定义类型转换器注册到 mybatis 中，需要在 mybatis 配置文件中通过 typeHandler 元素进行引入**
3. **mapper xml 中就可以使用了。**

# 11、缓存

## 什么是缓存？

缓存就是存储数据的一个地方（称作：Cache），当程序要读取数据时，会首先从缓存中获取，有则直接返回，否则从其他存储设备中获取，缓存最重要的一点就是从其内部获取数据的速度是非常快的，通过缓存可以加快数据的访问速度。比如我们从 db 中获取数据，中间需要经过网络传输耗时，db server 从磁盘读取数据耗时等，如果这些数据直接放在 jvm 对应的内存中，访问是不是会快很多。

## mybatis 中的缓存

通常情况下 mybatis 会访问数据库获取数据，中间涉及到网络通信，数据库从磁盘中读取数据，然后将数据返回给 mybatis，总的来说耗时还是挺长的，mybatis 为了加快数据查询的速度，在其内部引入了缓存来加快数据的查询速度。

mybatis 中分为一级缓存和二级缓存。

一级缓存是 SqlSession 级别的缓存，在操作数据库时需要构造 sqlSession 对象，在对象中有一个数据结构（HashMap）用于存储缓存数据，不同的 sqlSession 之间的缓存数据区域（HashMap）是互相不影响的。

二级缓存是 mapper 级别的缓存，多个 SqlSession 去操作同一个 Mapper 的 sql 语句，多个 SqlSession 可以共用二级缓存，二级缓存是跨 SqlSession 的。

## 一级缓存

一级缓存是 SqlSession 级别的缓存，每个 SqlSession 都有自己单独的一级缓存，多个 SqlSession 之间的一级缓存是相互隔离的，互不影响，mybatis 中一级缓存是默认自动开启的。

一级缓存工作原理：在同一个 SqlSession 中去多次去执行同样的查询，每次执行的时候会先到一级缓存中查找，如果缓存中有就直接返回，如果一级缓存中没有相关数据，mybatis 就会去 db 中进行查找，然后将查找到的数据放入一级缓存中，第二次执行同样的查询的时候，会发现缓存中已经存在了，会直接返回。一级缓存的存储介质是内存，是用一个 HashMap 来存储数据的，所以访问速度是非常快的。

### 清空一级缓存的 3 种方式

同一个 SqlSession 中查询同样的数据，mybatis 默认会从一级缓存中获取，如果缓存中没有，才会访问 db，那么我们如何去情况一级缓存呢，强制让查询去访问 db 呢？

让一级缓存失效有 3 种方式：

1. SqlSession 中执行增、删、改操作，此时 sqlsession 会自动清理其内部的一级缓存
2. 调用 SqlSession 中的 clearCache 方法清理其内部的一级缓存
3. 设置 Mapper xml 中 select 元素的 flushCache 属性值为 true，那么执行查询的时候会先清空一级缓存中的所有数据，然后去 db 中获取数据

### 一级缓存使用总结

1. 一级缓存是 SqlSession 级别的，每个人 SqlSession 有自己的一级缓存，不同的 SqlSession 之间一级缓存是相互隔离的
2. mybatis 中一级缓存默认是自动开启的
3. 当在同一个 SqlSession 中执行同样的查询的时候，会先从一级缓存中查找，如果找到了直接返回，如果没有找到会去访问 db，然后将 db 返回的数据丢到一级缓存中，下次查询的时候直接从缓存中获取
4. 一级缓存清空的 3 种方式（1：SqlSession 中执行增删改会使一级缓存失效；2：调用 SqlSession.clearCache 方法会使一级缓存失效；3：Mapper xml 中的 select 元素的 flushCache 属性置为 true，那么执行这个查询会使一级缓存失效）

## 二级缓存

### 二级缓存的使用

一级缓存使用上存在局限性，必须要在同一个 SqlSession 中执行同样的查询，一级缓存才能提升查询速度，如果想在不同的 SqlSession 之间使用缓存来加快查询速度，此时我们需要用到二级缓存了。

二级缓存是 mapper 级别的缓存，每个 mapper xml 有个 namespace，二级缓存和 namespace 绑定的，每个 namespace 关联一个二级缓存，多个 SqlSession 可以共用二级缓存，二级缓存是跨 SqlSession 的。

二级缓存默认是没有开启的，需要我们在 mybatis 全局配置文件中进行开启：

```
<settings>
    <!-- 开启二级缓存 -->
    <setting name="cacheEnabled" value="true"/>
</settings>
```

上面配置好了以后，还需要在对应的 mapper xml 加上下面配置，表示这个 mapper 中的查询开启二级缓存：

```
<cache/>
```

配置就这么简单。

### 一二级缓存共存时查询原理

一二级缓存如果都开启的情况下，数据查询过程如下：

1. 当发起一个查询的时候，mybatis 会先访问这个 namespace 对应的二级缓存，如果二级缓存中有数据则直接返回，否则继续向下
2. 查询一级缓存中是否有对应的数据，如果有则直接返回，否则继续向下
3. 访问 db 获取需要的数据，然后放在当前 SqlSession 对应的二级缓存中，并且在本地内存中的另外一个地方存储一份（这个地方我们就叫 TransactionalCache）
4. 当 SqlSession 关闭的时候，也就是调用 SqlSession 的 close 方法的时候，此时会将 TransactionalCache 中的数据放到二级缓存中，并且会清空当前 SqlSession 一级缓存中的数据。

### 清空或者跳过二级缓存的 3 种方式

当二级缓存开启的时候，在某个 mapper xml 中添加 cache 元素之后，这个 mapper xml 中所有的查询都默认开启了二级缓存，那么我们如何清空或者跳过二级缓存呢？3 种方式如下：

1. 对应的 mapper 中执行增删改查会清空二级缓存中数据
2. select 元素的 flushCache 属性置为 true，会先清空二级缓存中的数据，然后再去 db 中查询数据，然后将数据再放到二级缓存中
3. select 元素的 useCache 属性置为 true，可以使这个查询跳过二级缓存，然后去查询数据

### 总结

1. 一二级缓存访问顺序：一二级缓存都存在的情况下，会先访问二级缓存，然后再访问一级缓存，最后才会访问 db，这个顺序大家理解一下
2. 将 mapper xml 中 select 元素的 flushCache 属性置为 false，最终会清除一级缓存所有数据，同时会清除这个 select 所在的 namespace 对应的二级缓存中所有的数据
3. 将 mapper xml 中 select 元素的 useCache 置为 false，会使这个查询跳过二级缓存
4. 总体上来说使用缓存可以提升查询效率，这块知识掌握了，大家可以根据业务自行选择

