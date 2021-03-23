> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936449&idx=2&sn=da1e98e5914821f040d5530e8ca9d9bc&scene=21#wechat_redirect)

本来这篇文章要写 spring 事务的，但是事务中大部分案例会用到 JdbcTemplate 相关的功能，所以先把 JdbcTemplate 拿出来说一下。

什么是 JdbcTemplate？
-----------------

大家来回顾一下，java 中操作 db 最原始的方式就是纯 jdbc 了，是不是每次操作 db 都需要加载数据库驱动、获取连接、获取 PreparedStatement、执行 sql、关闭 PreparedStatement、关闭连接等等，操作还是比较繁琐的，spring 中提供了一个模块，对 jdbc 操作进行了封装，使其更简单，就是本文要讲的 JdbcTemplate，JdbcTemplate 是 Spring 对 JDBC 的封装，目的是使 JDBC 更加易于使用。

下面我们来看一下 JdbcTemplate 到底怎么玩的？

JdbcTemplate 使用步骤
-----------------

1.  创建数据源 DataSource
    
2.  创建 JdbcTemplate，new JdbcTemplate(dataSource)
    
3.  调用 JdbcTemplate 的方法操作 db，如增删改查
    

```
public class DataSourceUtils {
    public static DataSource getDataSource() {
        org.apache.tomcat.jdbc.pool.DataSource dataSource = new org.apache.tomcat.jdbc.pool.DataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:3306/javacode2018?characterEncoding=UTF-8");
        dataSource.setUsername("root");
        dataSource.setPassword("root123");
        dataSource.setInitialSize(5);
        return dataSource;
    }
}

@Test
public void test0() {
    //1.创建数据源DataSource
    DataSource dataSource = DataSourceUtils.getDataSource();
    //2.创建JdbcTemplate，new JdbcTemplate(dataSource)
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    //3.调用JdbcTemplate的方法操作db，如增删改查
    List<Map<String, Object>> maps = jdbcTemplate.queryForList("select * from t_user");
    System.out.println(maps);
}


```

输出

```
[{id=114, name=路人}, {id=115, name=java高并发}, {id=116, name=spring系列}]


```

t_user 表数据

```
mysql> select id,name from t_user;
+-----+---------------+
| id  | name          |
+-----+---------------+
| 114 | 路人          |
| 115 | java高并发    |
| 116 | spring系列    |
+-----+---------------+
3 rows in set (0.00 sec)


```

上面查询返回了`t_user`表所有的记录，返回了一个集合，集合中是一个 Map，Map 表示一行记录，key 为列名，value 为列对应的值。

有没有感觉到特别的方便，只需要`jdbcTemplate.queryForList("select * from t_user")`这么简单的一行代码，数据就被获取到了。

下面我们继续探索更强大更好用的功能。

增加、删除、修改操作
----------

**JdbcTemplate 中以 update 开头的方法，用来执行增、删、改操作**，下面来看几个常用的。

### 无参情况

#### Api

```
int update(final String sql)


```

#### 案例

```
@Test
public void test1() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    int updateRows = jdbcTemplate.update("INSERT INTO t_user (name) VALUE ('maven系列')");
    System.out.println("影响行数：" + updateRows);
}


```

### 有参情况 1

#### Api

```
int update(String sql, Object... args)


```

#### 案例

**sql 中使用? 作为占位符。**

```
@Test
public void test2() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    int updateRows = jdbcTemplate.update("INSERT INTO t_user (name) VALUE (?)", "mybatis系列");
    System.out.println("影响行数：" + updateRows);
}


```

### 有参情况 2

#### Api

```
int update(String sql, PreparedStatementSetter pss)


```

通过 PreparedStatementSetter 来设置参数，是个函数式接口，内部有个 setValues 方法会传递一个 PreparedStatement 参数，我们可以通这个参数手动的设置参数的值。

#### 案例

```
@Test
public void test3() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    int updateRows = jdbcTemplate.update("INSERT INTO t_user (name) VALUE (?)", new PreparedStatementSetter() {
        @Override
        public void setValues(PreparedStatement ps) throws SQLException {
            ps.setString(1, "mysql系列");
        }
    });
    System.out.println("影响行数：" + updateRows);
}


```

获取自增列的值
-------

### Api

```
public int update(final PreparedStatementCreator psc, final KeyHolder generatedKeyHolder)


```

### 案例

```
@Test
public void test4() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    String sql = "INSERT INTO t_user (name) VALUE (?)";
    KeyHolder keyHolder = new GeneratedKeyHolder();
    int rowCount = jdbcTemplate.update(new PreparedStatementCreator() {
        @Override
        public PreparedStatement createPreparedStatement(Connection con) throws SQLException {
            //手动创建PreparedStatement，注意第二个参数：Statement.RETURN_GENERATED_KEYS
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, "获取自增列的值");
            return ps;
        }
    }, keyHolder);
    System.out.println("新记录id：" + keyHolder.getKey().intValue());
}


```

输出

```
新记录id：122


```

```
mysql> select id,name from t_user;
+-----+-----------------------+
| id  | name                  |
+-----+-----------------------+
| 114 | 路人                  |
| 115 | java高并发            |
| 116 | spring系列            |
| 117 | maven系列             |
| 118 | mysql系列             |
| 122 | 获取自增列的值        |
+-----+-----------------------+
6 rows in set (0.00 sec)


```

批量增删改操作
-------

### Api

```
int[] batchUpdate(final String[] sql);
int[] batchUpdate(String sql, List<Object[]> batchArgs);
int[] batchUpdate(String sql, List<Object[]> batchArgs, int[] argTypes);


```

### 案例

```
@Test
public void test5() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    List<Object[]> list = Arrays.asList(
            new Object[]{"刘德华"}, 
            new Object[]{"郭富城"}, 
            new Object[]{"张学友"}, 
            new Object[]{"黎明"});
    int[] updateRows = jdbcTemplate.batchUpdate("INSERT INTO t_user (name) VALUE (?)", list);
    for (int updateRow : updateRows) {
        System.out.println(updateRow);
    }
}


```

查询操作
----

### 查询一列单行

#### Api

```
/**
 * sql：执行的sql，如果有参数，参数占位符?
 * requiredType：返回的一列数据对应的java类型，如String
 * args：?占位符对应的参数列表
 **/
<T> T queryForObject(String sql, Class<T> requiredType, @Nullable Object... args)


```

#### 案例

```
@Test
public void test6() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    String name = jdbcTemplate.queryForObject("select name from t_user where id = ?", String.class, 114);
    System.out.println(name);
}


```

输出

```
路人


```

db 中对应数据

```
mysql> select name from t_user where id = 114;
+--------+
| name   |
+--------+
| 路人   |
+--------+
1 row in set (0.00 sec)


```

#### 使用注意

**若 queryForObject 中 sql 查询无结果时，会报错**

如 id 为 0 的记录不存在

```
mysql> select name from t_user where id = 0;
Empty set (0.00 sec)


```

```
@Test
public void test7() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    String name = jdbcTemplate.queryForObject("select name from t_user where id = ?", String.class, 0);
    System.out.println(name);
}


```

运行，会弹出一个异常`EmptyResultDataAccessException`，期望返回一条记录，但实际上却没有找到记录，和期望结果不符，所以报错了

```
org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0

 at org.springframework.dao.support.DataAccessUtils.nullableSingleResult(DataAccessUtils.java:97)
 at org.springframework.jdbc.core.JdbcTemplate.queryForObject(JdbcTemplate.java:784)


```

这种如何解决呢，需要用到查询多行的方式来解决了，即下面要说到的`queryForList`相关的方法，无结果的时候会返回一个空的 List，我们可以在这个空的 List 上面做文章。

### 查询一列多行

#### Api

以 queryForList 开头的方法。

```
<T> List<T> queryForList(String sql, Class<T> elementType);
<T> List<T> queryForList(String sql, Class<T> elementType, @Nullable Object... args);
<T> List<T> queryForList(String sql, Object[] args, Class<T> elementType);
<T> List<T> queryForList(String sql, Object[] args, int[] argTypes, Class<T> elementType);


```

**注意：**

上面这个 T 虽然是泛型，但是只支持 Integer.class String.class 这种单数据类型的，自己定义的 Bean 不支持。（所以用来查询单列数据）

elementType：查询结果需要转换为哪种类型？如 String、Integer、Double。

#### 案例

```
@Test
public void test8() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    //<T> List<T> queryForList(String sql, Class<T> elementType);
    List<String> list1 = jdbcTemplate.queryForList("select name from t_user where id>131", String.class);
    System.out.println("list1:" + list1);

    //<T> List<T> queryForList(String sql, Class<T> elementType, @Nullable Object... args);
    List<String> list2 = jdbcTemplate.queryForList("select name from t_user where id>?", String.class, 131);
    System.out.println("list2:" + list2);

    //<T> List<T> queryForList(String sql, Object[] args, Class<T> elementType);
    List<String> list3 = jdbcTemplate.queryForList("select name from t_user where id>?", new Object[]{131}, String.class);
    System.out.println("list3:" + list3);

    //<T> List<T> queryForList(String sql, Object[] args, int[] argTypes, Class<T> elementType);
    List<String> list4 = jdbcTemplate.queryForList("select name from t_user where id>?", new Object[]{131}, new int[]{java.sql.Types.INTEGER}, String.class);
    System.out.println("list4:" + list4);
}


```

输出

```
list1:[郭富城, 张学友, 黎明]
list2:[郭富城, 张学友, 黎明]
list3:[郭富城, 张学友, 黎明]
list4:[郭富城, 张学友, 黎明]


```

sql 结果：

```
mysql> select name from t_user where id>131;
+-----------+
| name      |
+-----------+
| 郭富城    |
| 张学友    |
| 黎明      |
+-----------+
3 rows in set (0.00 sec)


```

### 查询单行记录，将记录转换成一个对象

#### Api

```
<T> T queryForObject(String sql, RowMapper<T> rowMapper);
<T> T queryForObject(String sql, Object[] args, RowMapper<T> rowMapper);
<T> T queryForObject(String sql, Object[] args, int[] argTypes, RowMapper<T> rowMapper);
<T> T queryForObject(String sql, RowMapper<T> rowMapper, Object... args);


```

上面这些方法的参数中都有一个 rowMapper 参数，行映射器，可以将当前行的结果映射为一个自定义的对象。

```
@FunctionalInterface
public interface RowMapper<T> {

 /**
  * @param ResultSet 结果集
  * @param 当前结果集的第几行
  * @return 当前行的结果对象，将当前行的结果映射为一个自定义的对象返回
  */
 @Nullable
 T mapRow(ResultSet rs, int rowNum) throws SQLException;

}


```

JdbcTemplate 内部会遍历 ResultSet，然后循环调用 RowMapper#mapRow，得到当前行的结果，将其丢到 List 中返回，如下：

```
List<T> results = new ArrayList<>();
int rowNum = 0;
while (rs.next()) {
    results.add(this.rowMapper.mapRow(rs, rowNum++));
}
return results;


```

#### 案例

```
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class User {
    private Integer id;
    private String name;
}


```

```
@Test
public void test9() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    String sql = "select id,name from t_user where id = ?";
    //查询id为34的用户信息
    User user = jdbcTemplate.queryForObject(sql, new RowMapper<User>() {
        @Nullable
        @Override
        public User mapRow(ResultSet rs, int rowNum) throws SQLException {
            User user = new User();
            user.setId(rs.getInt(1));
            user.setName(rs.getString(1));
            return user;
        }
    }, 134);
    System.out.println(user);
}


```

输出

```
User(id=134, name=134)


```

#### 使用注意

**当 queryForObject 中 sql 查询无结果的时候，会报错，必须要返回一行记录**

### 查询单行记录，返回指定的 javabean

RowMapper 有个实现了类 BeanPropertyRowMapper，可以将结果映射为 javabean。

```
@Test
public void test10() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    String sql = "select id,name from t_user where id = ?";
    //查询id为34的用户信息
    RowMapper<User> rowMapper = new BeanPropertyRowMapper<>(User.class);
    User user = jdbcTemplate.queryForObject(sql, rowMapper, 134);
    System.out.println(user);
}


```

### 查询多列多行，每行结果为一个 Map

#### Api

```
List<Map<String, Object>> queryForList(String sql);
List<Map<String, Object>> queryForList(String sql, Object... args);


```

每行结果为一个 Map，key 为列名小写，value 为列对应的值。

#### 案例

```
@Test
public void test11() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    String sql = "select id,name from t_user where id>?";
    List<Map<String, Object>> maps = jdbcTemplate.queryForList(sql, 130);
    System.out.println(maps);
}


```

输出

```
[{id=131, name=刘德华}, {id=132, name=郭富城}, {id=133, name=张学友}, {id=134, name=黎明}]


```

### 查询多列多行，将结果映射为 javabean

#### Api

```
<T> List<T> query(String sql, RowMapper<T> rowMapper, @Nullable Object... args)


```

#### 案例

```
@Test
public void test12() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    String sql = "select id,name from t_user where id>?";
    List<User> maps = jdbcTemplate.query(sql, new RowMapper<User>() {
        @Nullable
        @Override
        public User mapRow(ResultSet rs, int rowNum) throws SQLException {
            User user = new User();
            user.setId(rs.getInt(1));
            user.setName(rs.getString(1));
            return user;
        }
    }, 130);
    System.out.println(maps);
}


```

运行输出

```
[User(id=131, name=刘德华), User(id=132, name=郭富城), User(id=133, name=张学友), User(id=134, name=黎明)]


```

更简单的方式，使用`BeanPropertyRowMapper`

```
@Test
public void test13() {
    DataSource dataSource = DataSourceUtils.getDataSource();
    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
    String sql = "select id,name from t_user where id>?";
    List<User> maps = jdbcTemplate.query(sql, new BeanPropertyRowMapper<User>(User.class), 130);
    System.out.println(maps);
}


```

输出

```
[User(id=131, name=刘德华), User(id=132, name=郭富城), User(id=133, name=张学友), User(id=134, name=黎明)]


```

总结
--

1.  使用注意：JdbcTemplate 中的 getObject 开头的方法，要求 sql 必须返回一条记录，否则会报错
    
2.  BeanPropertyRowMapper 可以将行记录映射为 javabean
    
3.  JdbcTemplate 采用模板的方式操作 jdbc 变的特别的容易，代码特别的简洁，不过其内部没有动态 sql 的功能，即通过参数，动态生成指定的 sql，mybatis 在动态 sql 方面做的比较好，大家用的时候可以根据需求进行选择。
    

案例源码
----

```
git地址：
https://gitee.com/javacode2018/spring-series

本文案例对应源码：
spring-series\lesson-003-jdbctemplate\src\main\java\com\javacode2018\jdbctemplate\demo1\Demo1Test.java


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
    

更多好文章
-----

1.  [Java 高并发系列（共 34 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933285&idx=1&sn=f5507c251b84c3405f2fe0f7fb1da97d&chksm=88621b9bbf15928dd4c26f52b2abb0e130cde02100c432f33f0e90123b5e4b20d43017c1030e&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [MySql 高手系列（共 27 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933461&idx=1&sn=67cd31469273b68a258d963e53b56325&chksm=88621c6bbf15957d7308d81cd8ba1761b356222f4c6df75723aee99c265bd94cc869faba291c&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Maven 高手系列（共 10 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933753&idx=1&sn=0b41083939980be87a61c4f573792459&chksm=88621d47bf1594516092b662c545abfac299d296e232bf25e9f50be97e002e2698ea78218828&scene=21#wechat_redirect)
    
4.  [Mybatis 系列（共 12 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933868&idx=1&sn=ed16ef4afcbfcb3423a261422ff6934e&chksm=88621dd2bf1594c4baa21b7adc47456e5f535c3358cd11ddafb1c80742864bb19d7ccc62756c&token=1400407286&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [聊聊 db 和缓存一致性常见的实现方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933452&idx=1&sn=48b3b1cbd27c50186122fef8943eca5f&chksm=88621c72bf159564e629ee77d180424274ae9effd8a7c2997f853135b28f3401970793d8098d&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [接口幂等性这么重要，它是什么？怎么实现？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933334&idx=1&sn=3a68da36e4e21b7339418e40ab9b6064&chksm=88621be8bf1592fe5301aab732fbed8d1747475f4221da341350e0cc9935225d41bf79375d43&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [泛型，有点难度，会让很多人懵逼，那是因为你没有看这篇文章！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933878&idx=1&sn=bebd543c39d02455456680ff12e3934b&chksm=88621dc8bf1594de6b50a760e4141b80da76442ba38fb93a91a3d18ecf85e7eee368f2c159d3&token=799820369&lang=zh_CN&scene=21#wechat_redirect)
    

```
世界上最好的关系是相互成就，点赞转发 感恩开心😃

```

路人甲 java  

![](https://mmbiz.qpic.cn/mmbiz_png/9Xne6pfLaexiaK8h8pVuFJibShbdbS0QEE9V2UuWiakgeMWbXLgrrT114RwXKZfEJicvtz3jsUslfVhpOGZS62mQvg/640?wx_fmt=png)

▲长按图片识别二维码关注

路人甲 Java：工作 10 年的前阿里 P7，所有文章以系列的方式呈现，带领大家成为 java 高手，目前已出：java 高并发系列、mysql 高手系列、Maven 高手系列、mybatis 系列、spring 系列，正在连载 springcloud 系列，欢迎关注！