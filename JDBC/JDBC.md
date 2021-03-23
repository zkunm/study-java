## 1、JDBC入门

​	JDBC 是 Java 访问数据库的标准规范，真正怎么操作数据库还需要具体的实现类，也就是数据库驱动。每个 数据库厂商根据自家数据库的通信格式编写好自己数据库的驱动。所以我们只需要会调用 JDBC 接口中的方法即 可，数据库驱动由数据库厂商提供。

**为什么我们要用JDBC**

- 市面上有非常多的数据库，本来我们是需要根据不同的数据库学习不同的API，sun公司为了简化这个操作，定义了JDBC API【接口】
- sun公司只是提供了JDBC API【接口】，数据库厂商负责实现。
- 对于我们来说，**操作数据库都是在JDBC API【接口】上**，使用不同的数据库，只要用数据库厂商提供的数据库驱动程序即可
- 这大大简化了我们的学习成本

### JDBC核心API

| 接口或类              | 作用                                                     |
| --------------------- | -------------------------------------------------------- |
| DriverManager类       | 1. 管理和注册数据库驱动<br/>2. 得到数据库连接对象        |
| Connection接口        | 一个连接对象，可用于创建Statement和PreparedStatement对象 |
| Statement接口         | 一个SQL语句对象，用于将SQL发送给数据库服务器             |
| RreparedStatement接口 | 一个SQL语句对象，是Statement的子接口                     |
| ResultSet接口         | 用英语封装数据库查询的结果集，返回给客户端Java程序       |

### 快速使用JDBC

```java
{
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    try {
        // 1.加载驱动
        Class.forName("com.mysql.jdbc.Driver");
        // 2. 获取与数据库连接的对象-Connetcion
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/zkunm", "root", "123456");
        // 3. 获取执行sql语句的statement对象
        statement = connection.createStatement();
        // 4. 执行sql语句,拿到结果集
        resultSet = statement.executeQuery("SELECT * FROM users");
        // 5. 遍历结果集，得到数据
        while (resultSet.next()) {
            System.out.println(resultSet.getString(1));
            System.out.println(resultSet.getString(2));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
    } finally {
        // 6. 关闭连接
        if (resultSet != null) {
            try {
                resultSet.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (statement != null) {
            try {
                statement.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
```

### DriverManager：驱动管理对象

* 管理和注册驱动
* 创建数据库连接

| Driver Manager类中的静态方法                                 | 描述                                             |
| ------------------------------------------------------------ | ------------------------------------------------ |
| Connection getConnection(String url, String user, String password) | 通过连接字符串，用户名，密码来得到数据库连接对象 |
| Connection getConnection(String url, Properties info)        | 通过连接字符串，属性对象来得到连接对象           |

> 乱码的处理，指定参数characterEncoding=utf8

### Connection 对象

客户端与数据库所有的交互都是通过 Connection 来完成的。

```java
//创建向数据库发送sql的statement对象。
createcreateStatement()

//创建向数据库发送预编译sql的PrepareSatement对象。
prepareStatement(sql) 

//创建执行存储过程的callableStatement对象
prepareCall(sql)

//设置事务自动提交
setAutoCommit(boolean autoCommit)

//提交事务
commit()

//回滚事务
rollback()
```

### Statement 对象

Statement 对象用于向数据库发送 Sql 语句，对数据库的增删改查都可以通过此对象发送 sql 语句完成。

```java
//查询
executeQuery(String sql)

//增删改
executeUpdate(String sql)

//任意sql语句都可以，但是目标不明确，很少用
execute(String sql)

//把多条的sql语句放进同一个批处理中
addBatch(String sql)

//向数据库发送一批sql语句执行
executeBatch()
```

### PreparedStatement对象

PreparedStatement对象继承Statement对象，它比Statement对象更强大，使用起来更简单

1. Statement对象编译SQL语句时，如果SQL语句有变量，就需要使用分隔符来隔开，如果变量非常多，就会使SQL变得非常复杂。PreparedStatement可以使用占位符，简化sql的编写
2. Statement会频繁编译SQL。PreparedStatement可对SQL进行预编译，提高效率，预编译的SQL存储在PreparedStatement对象中
3. PreparedStatement防止SQL注入。

```java
//模拟查询id为2的信息
String id = "2";
Connection connection = UtilsDemo.getConnection();
String sql = "SELECT * FROM users WHERE id = ?";
PreparedStatement preparedStatement = connection.preparedStatement(sql);
//第一个参数表示第几个占位符【也就是?号】，第二个参数表示值是多少
preparedStatement.setString(1,id);
ResultSet resultSet = preparedStatement.executeQuery();
if (resultSet.next()) System.out.println(resultSet.getString("name"));
//释放资源
UtilsDemo.release(connection, preparedStatement, resultSet);
```



### ResultSet 对象

ResultSet 对象代表 Sql 语句的执行结果，当 Statement 对象执行 executeQuery() 时，会返回一个 ResultSet 对象

ResultSet 对象维护了一个数据行的游标【简单理解成指针】，调用 ResultSet.next() 方法，可以让游标指向具体的数据行，进行获取该行的数据

```java
//获取任意类型的数据
getObject(String columnName)

//获取指定类型的数据【各种类型，查看API】
getString(String columnName)

//对结果集进行滚动查看的方法
next()
Previous()
absolute(int row)
beforeFirst()
afterLast()
```
### JDBC工具类

```java
public class JDBCUtils {
    private static String driver = null;
    private static String url = null;
    private static String username = null;
    private static String password = null;
    static {
        try {
            //获取配置文件的读入流
            InputStream inputStream = JDBCUtils.class.getClassLoader().getResourceAsStream("db.properties");
            Properties properties = new Properties();
            properties.load(inputStream);
            //获取配置文件的信息
            driver = properties.getProperty("driver");
            url = properties.getProperty("url");
            username = properties.getProperty("username");
            password = properties.getProperty("password");
            //加载驱动类
            Class.forName(driver);
        } 处理异常
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }
    public static void release(Connection connection, Statement statement, ResultSet resultSet) {
		关闭连接
}
```

## 2、JDBC使用的一些细节

### 批处理

当需要向数据库发送一批SQL语句执行时，应避免向数据库一条条发送执行，采用批处理以提升执行效率

批处理有两种方式：

1. Statement
2. PreparedStatement

通过executeBath()方法批量处理执行SQL语句，返回一个int[]数组，该数组代表各句SQL的返回值
addBatch(String sql)
executeBatch()

```java
/*
* Statement执行批处理
*
* 优点：
*       可以向数据库发送不同的SQL语句
* 缺点：
*       SQL没有预编译
*       仅参数不同的SQL，需要重复写多条SQL
* */
Connection connection = UtilsDemo.getConnection();
Statement statement = connection.createStatement();
String sql1 = "UPDATE users SET name='zhongfucheng' WHERE id='3'";
String sql2 = "INSERT INTO users (id, name, password, email, birthday)" + " VALUES('5','nihao','123','ss@qq.com','1995-12-1')";
//将sql添加到批处理
statement.addBatch(sql1);
statement.addBatch(sql2);
//执行批处理
statement.executeBatch();
//清空批处理的sql
statement.clearBatch();
UtilsDemo.release(connection, statement, null);
```

```java
/*
* PreparedStatement批处理
*   优点：
*       SQL语句预编译了
*       对于同一种类型的SQL语句，不用编写很多条
*   缺点：
*       不能发送不同类型的SQL语句
*
* */
Connection connection = UtilsDemo.getConnection();
String sql = "INSERT INTO test(id,name) VALUES (?,?)";
PreparedStatement preparedStatement = connection.prepareStatement(sql);
for (int i = 1; i <= 205; i++) {
    preparedStatement.setInt(1, i);
    preparedStatement.setString(2, (i + "zhongfucheng"));
    //添加到批处理中
    preparedStatement.addBatch();
    if (i %2 ==100) {
        //执行批处理
        preparedStatement.executeBatch();
        //清空批处理【如果数据量太大，所有数据存入批处理，内存肯定溢出】
        preparedStatement.clearBatch();
    }
}
//不是所有的%2==100，剩下的再执行一次批处理
preparedStatement.executeBatch();
//再清空
preparedStatement.clearBatch();
UtilsDemo.release(connection, preparedStatement, null);
```



### 处理大文本和二进制数据

clob和blob

- clob用于存储大文本
- blob用于存储二进制数据

MySQL存储大文本是用Test【代替clob】，Test又分为4类

- TINYTEXT
- TEXT
- MEDIUMTEXT
- LONGTEXT

```java
/*
*用JDBC操作MySQL数据库去操作大文本数据
*
*setCharacterStream(int parameterIndex,java.io.Reader reader,long length)
*第二个参数接收的是一个流对象，因为大文本不应该用String来接收，String太大会导致内存溢出
*第三个参数接收的是文件的大小
*
* */
public class Demo5 {
    @Test
    public void add() {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            connection = JdbcUtils.getConnection();
            String sql = "INSERT INTO test2 (bigTest) VALUES(?) ";
            preparedStatement = connection.prepareStatement(sql);
            //获取到文件的路径
            String path = Demo5.class.getClassLoader().getResource("BigTest").getPath();
            File file = new File(path);
            FileReader fileReader = new FileReader(file);
            //第三个参数，由于测试的Mysql版本过低，所以只能用int类型的。高版本的不需要进行强转
            preparedStatement.setCharacterStream(1, fileReader, (int) file.length());
            if (preparedStatement.executeUpdate() > 0) System.out.println("插入成功");
        } catch 处理异常，关闭连接
    }

    /*
    * 读取大文本数据，通过ResultSet中的getCharacterStream()获取流对象数据
    * 
    * */
    @Test
    public void read() {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            connection = JdbcUtils.getConnection();
            String sql = "SELECT * FROM test2";
            preparedStatement = connection.prepareStatement(sql);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                Reader reader = resultSet.getCharacterStream("bigTest");
                FileWriter fileWriter = new FileWriter("d:\\abc.txt");
                char[] chars = new char[1024];
                int len = 0;
                while ((len = reader.read(chars)) != -1) {
                    fileWriter.write(chars, 0, len);
                    fileWriter.flush();
                }
                fileWriter.close();
                reader.close();
            }
        } catch 处理异常，关闭连接
    }
```

```java
/*
* 使用JDBC连接MYsql数据库操作二进制数据
* 如果我们要用数据库存储一个大视频的时候，数据库是存储不到的。
* 需要设置max_allowed_packet，一般我们不使用数据库去存储一个视频
* */
public class Demo6 {
    @Test
    public void add() {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            connection = JdbcUtils.getConnection();
            String sql = "INSERT INTO test3 (blobtest) VALUES(?)";
            preparedStatement = connection.prepareStatement(sql);
            //获取文件的路径和文件对象
            String path = Demo6.class.getClassLoader().getResource("1.wmv").getPath();
            File file = new File(path);
            //调用方法
            preparedStatement.setBinaryStream(1, new FileInputStream(path), (int)file.length());
            if (preparedStatement.executeUpdate() > 0) {
                System.out.println("添加成功");
            }
        } 处理异常，关闭连接
    }
    @Test
    public void read() {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            connection = JdbcUtils.getConnection();
            String sql = "SELECT * FROM test3";
            preparedStatement = connection.prepareStatement(sql);
            resultSet = preparedStatement.executeQuery();
            //如果读取到数据，就把数据写到磁盘下
            if (resultSet.next()) {
                InputStream inputStream = resultSet.getBinaryStream("blobtest");
                FileOutputStream fileOutputStream = new FileOutputStream("d:\\aa.jpg");
                int len = 0;
                byte[] bytes = new byte[1024];
                while ((len = inputStream.read(bytes)) > 0) {
                    fileOutputStream.write(bytes, 0, len);
                }
                fileOutputStream.close();
                inputStream.close();
            }
        } 处理异常，关闭连接
    }
```

### 获取数据库的自动主键列

```java
@Test
public void test() {
    Connection connection = null;
    PreparedStatement preparedStatement = null;
    ResultSet resultSet = null;
    try {
        connection = JdbcUtils.getConnection();
        String sql = "INSERT INTO test(name) VALUES(?)";
        preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setString(1, "ouzicheng");
        if (preparedStatement.executeUpdate() > 0) {
            //获取到自动主键列的值
            resultSet = preparedStatement.getGeneratedKeys();
            if (resultSet.next()) {
                int id = resultSet.getInt(1);
                System.out.println(id);
            }
        }
    } catch 处理异常，关闭连接
}    
```

### 调用数据库的存储过程

**调用存储过程的语法：**

```
{call <procedure-name>[(<arg1>,<arg2>, ...)]}
```

**调用函数的语法：**

```
{?= call <procedure-name>[(<arg1>,<arg2>, ...)]}
```

```java
/*
jdbc调用存储过程

delimiter $$
    CREATE PROCEDURE demoSp(IN inputParam VARCHAR(255), INOUT inOutParam varchar(255))
    BEGIN
        SELECT CONCAT('zyxw---', inputParam) into inOutParam;
    END $$
delimiter ;
*/
//我们在JDBC调用存储过程,就像在调用方法一样
public class Demo9 {
    public static void main(String[] args) {
        Connection connection = null;
        CallableStatement callableStatement = null;
        try {
            connection = JdbcUtils.getConnection();
            callableStatement = connection.prepareCall("{call demoSp(?,?)}");
            callableStatement.setString(1, "nihaoa");
            //注册第2个参数,类型是VARCHAR
            callableStatement.registerOutParameter(2, Types.VARCHAR);
            callableStatement.execute();
            //获取传出参数[获取存储过程里的值]
            String result = callableStatement.getString(2);
            System.out.println(result);
        } catch 处理异常，关闭连接
    }
}    
```

## 3、事务+元数据+改造工具类

### 事务

一个SESSION所进行的所有更新操作要么一起成功，要么一起失败

举个例子:A向B转账，转账这个流程中如果出现问题，事务可以让数据恢复成原来一样【A账户的钱没变，B账户的钱也没变】。

事例说明：

```java
/*
* 我们来模拟A向B账号转账的场景
*   A和B账户都有1000块，现在我让A账户向B账号转500块钱
* */
//JDBC默认的情况下是关闭事务的，下面我们看看关闭事务去操作转账操作有什么问题
//A账户减去500块
String sql = "UPDATE a SET money=money-500 ";
preparedStatement = connection.prepareStatement(sql);
preparedStatement.executeUpdate();
//B账户多了500块
String sql2 = "UPDATE b SET money=money+500";
preparedStatement = connection.prepareStatement(sql2);
preparedStatement.executeUpdate();
```

从上面看，我们的确可以发现A向B转账，成功了。可是**如果A向B转账的过程中出现了问题呢？**下面模拟一下

```java
//A账户减去500块
String sql = "UPDATE a SET money=money-500 ";
preparedStatement = connection.prepareStatement(sql);
preparedStatement.executeUpdate();
//这里模拟出现问题
int a = 3 / 0;
String sql2 = "UPDATE b SET money=money+500";
preparedStatement = connection.prepareStatement(sql2);
preparedStatement.executeUpdate();
```

显然，上面**代码是会抛出异常的**，我们再来查询一下数据。**A账户少了500块钱，B账户的钱没有增加**。**这明显是不合理的**。

------

我们可以通过事务来解决上面出现的问题

```java
try{
    //开启事务,对数据的操作就不会立即生效。
    connection.setAutoCommit(false);
    //A账户减去500块
    String sql = "UPDATE a SET money=money-500 ";
    preparedStatement = connection.prepareStatement(sql);
    preparedStatement.executeUpdate();
    //在转账过程中出现问题
    int a = 3 / 0;
    //B账户多500块
    String sql2 = "UPDATE b SET money=money+500";
    preparedStatement = connection.prepareStatement(sql2);
    preparedStatement.executeUpdate();
    //如果程序能执行到这里，没有抛出异常，我们就提交数据
    connection.commit();
    //关闭事务【自动提交】
    connection.setAutoCommit(true);
} catch (SQLException e) {
    try {
        //如果出现了异常，就会进到这里来，我们就把事务回滚【将数据变成原来那样】
        connection.rollback();
        //关闭事务【自动提交】
        connection.setAutoCommit(true);
    } catch (SQLException e1) {
        e1.printStackTrace();
    }
```

上面的程序也一样抛出了异常，A账户钱没有减少，B账户的钱也没有增加。

注意：当Connection遇到一个未处理的SQLException时，系统会非正常退出，事务也会自动回滚，但**如果程序捕获到了异常，是需要在catch中显式回滚事务的。**

### savapoint

我们还可以使用savepoint设置中间点。如果在某地方出错了，我们设置中间点，回滚到出错之前即可。

应用场景：现在我们要算一道数学题，算到后面发现算错数了。前面的运算都是正确的，我们不可能重头再算【直接rollback】，最好的做法就是在**保证前面算对的情况下，设置一个保存点。从保存点开始重新算。**

注意：**savepoint不会结束当前事务，普通提交和回滚都会结束当前事务的**

------

### 事务的隔离级别

数据库定义了4个隔离级别：

1. Serializable【可避免脏读，不可重复读，虚读】
2. Repeatable read【可避免脏读，不可重复读】
3. Read committed【可避免脏读】
4. Read uncommitted【级别最低，什么都避免不了】

分别对应Connection类中的4个常量

1. TRANSACTION_READ_UNCOMMITTED
2. TRANSACTION_READ_COMMITTED
3. TRANSACTION_REPEATABLE_READ
4. TRANSACTION_SERIALIZABLE

**脏读**：一个事务读取到另外一个事务未提交的数据

​	例子：A向B转账，A执行了转账语句，但A还没有提交事务，B读取数据，发现自己账户钱变多了！B跟A说，我已经收到钱了。A回滚事务【rollback】，等B再查看账户的钱时，发现钱并没有多。

**不可重复读**：一个事务读取到另外一个事务已经提交的数据，也就是说一个事务可以看到其他事务所做的修改

​	注：A查询数据库得到数据，B去修改数据库的数据，导致A多次查询数据库的结果都不一样【危害：A每次查询的结果都是受B的影响的，那么A查询出来的信息就没有意思了】

**虚读(幻读)**：是指在一个事务内读取到了别的事务插入的数据，导致前后读取不一致。

​	注：和不可重复读类似，但虚读(幻读)会读到其他事务的插入的数据，导致前后读取不一致


简单总结：脏读是不可容忍的，不可重复读和虚读在一定的情况下是可以的【做统计的肯定就不行】。

### 元数据

什么是元数据

元数据其实就是数据库，表，列的定义信息

为什么我们要用元数据

即使我们写了一个简单工具类，我们的代码还是非常冗余。对于增删改而言，只有SQL和参数是不同的，我们为何不把这些相同的代码抽取成一个方法？对于查询而言，不同的实体查询出来的结果集是不一样的。我们要使用元数据获取结果集的信息，才能对结果集进行操作。

- ParameterMetaData  --参数的元数据
- ResultSetMetaData    --结果集的元数据
- DataBaseMetaData    --数据库的元数据

```java
interface ResultSetHandler {
    Object handler(ResultSet resultSet);
}

/**
 * @Description
 * @author: zkunm
 * @create: 2020-12-05 13:55
 */
public class JDBCUtils {
    private static String driver = null;
    private static String url = null;
    private static String username = null;
    private static String password = null;

    static {
        try {
            InputStream inputStream = JDBCUtils.class.getClassLoader().getResourceAsStream("db.properties");
            Properties properties = new Properties();
            properties.load(inputStream);
            driver = properties.getProperty("driver");
            url = properties.getProperty("url");
            username = properties.getProperty("username");
            password = properties.getProperty("password");
            Class.forName(driver);
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }

    public static void update(String sql, Object[] objects) {
        Connection conn = null;
        PreparedStatement prep = null;
        ResultSet result = null;
        try {
            conn = getConnection();
            prep = conn.prepareStatement(sql);
            for (int i = 0; i < objects.length; i++) {
                prep.setObject(i + 1, objects[i]);
            }
            prep.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            release(conn,prep,result);
        }
    }

    public static Object query(String sql, Object[] objects, ResultSetHandler rsh) {
        Connection conn = null;
        PreparedStatement prep = null;
        ResultSet result = null;
        try {
            conn = getConnection();
            prep = conn.prepareStatement(sql);
            if (objects != null)
                for (int i = 0; i < objects.length; i++) prep.setObject(i + 1, objects[i]);
            result = prep.executeQuery();
            return rsh.handler(result);
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            release(conn,prep,result);
        }
    }

    public static void release(Connection connection, Statement statement, ResultSet resultSet) {
        if (resultSet != null) {
            try {
                resultSet.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (statement != null) {
            try {
                statement.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}

class BeanHandler implements ResultSetHandler {
    private final Class clazz;

    public BeanHandler(Class clazz) {
        this.clazz = clazz;
    }

    @Override
    public Object handler(ResultSet resultSet) {
        try {
            Object bean = clazz.newInstance();
            if (resultSet.next()) {
                ResultSetMetaData resultSetMetaData = resultSet.getMetaData();
                for (int i = 0; i < resultSetMetaData.getColumnCount(); i++) {
                    String columnName = resultSetMetaData.getColumnName(i + 1);
                    String columnData = resultSet.getString(i + 1);
                    Field field = clazz.getDeclaredField(columnName);
                    field.setAccessible(true);
                    field.set(bean, columnData);
                }
                return bean;
            }
        } catch (IllegalAccessException | InstantiationException | SQLException | NoSuchFieldException e) {
            e.printStackTrace();
        }
        return null;
    }
}
```

## 4、数据库连接池+DBUtils+分页

### 为什么要使用数据库连接池

- 数据库的连接的建立和关闭是非常消耗资源的
- 频繁地打开、关闭连接造成系统性能低下

### 自己编写一个连接池

1. 编写连接池需实现java.sql.DataSource接口
2. 创建批量的Connection用LinkedList保存【既然是个池，当然用集合保存、、LinkedList底层是链表，对增删性能较好】
3. 实现getConnetion()，让getConnection()每次调用，都是在LinkedList中取一个Connection返回给用户
4. 调用Connection.close()方法，Connction返回给LinkedList

```
public class MyJDBCPool {
    private static LinkedList<Connection> list = new LinkedList<>();
    //获取连接只需要一次就够了，所以用static代码块
    static {
        //读取文件配置
        InputStream inputStream = MyJDBCPool.class.getClassLoader().getResourceAsStream("db.properties");
        Properties properties = new Properties();
        try {
            properties.load(inputStream);
            String url = properties.getProperty("url");
            String username = properties.getProperty("username");
            String driver = properties.getProperty("driver");
            String password = properties.getProperty("password");
            //加载驱动
            Class.forName(driver);
            //获取多个连接，保存在LinkedList集合中
            for (int i = 0; i < 10; i++) {
                Connection connection = DriverManager.getConnection(url, username, password);
                list.add(connection);
            }
        } catch (IOException | ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }
    // 重写Connection方法，用户获取连接应该从LinkedList中给他
    public Connection getConnection() throws SQLException {
        System.out.println(list.size());
        System.out.println(list);
        //先判断LinkedList是否存在连接
        return list.size() > 0 ? list.removeFirst() : null;
    }
}
```

我们已经完成前三步了，现在问题来了。我们调用Conncetion.close()方法，是把数据库的物理连接关掉，而不是返回给LinkedList的

解决思路：

1. 写一个Connection子类，覆盖close()方法
2. 写一个Connection包装类，增强close()方法
3. 用动态代理，返回一个代理对象出去，拦截close()方法的调用，对close()增强

分析第一个思路：

- Connection是通过数据库驱动加载的，保存了数据的信息。写一个子类Connection，new出对象，子类的Connction无法直接继承父类的数据信息，也就是说子类的Connection是无法连接数据库的，更别谈覆盖close()方法了。

分析第二个思路：

- 写一个Connection包装类。
  1. 写一个类，实现与被增强对象的相同接口【Connection接口】
  2. 定义一个变量，指向被增强的对象
  3. 定义构造方法，接收被增强对象
  4. 覆盖想增强的方法
  5. 对于不想增强的方法，直接调用被增强对象的方法
- 这个思路本身是没什么毛病的，就是**实现接口时，方法太多了！**，所以我们也不使用此方法

分析第三个思路代码实现：

```java
public Connection getConnection() throws SQLException {
    if (list.size() > 0) {
        final Connection connection = list.removeFirst();
        //看看池的大小
        System.out.println(list.size());
        //返回一个动态代理对象
        return (Connection) Proxy.newProxyInstance(MyJDBCPool.class.getClassLoader(), connection.getClass().getInterfaces(), (proxy, method, args) -> {
            //如果不是调用close方法，就按照正常的来调用
            if (!method.getName().equals("close")) method.invoke(connection, args);
            else {
                // 进到这里来，说明调用的是close方法
                list.add(connection);
                //再看看池的大小
                System.out.println(list.size());
            }
            return null;
        });
    }
    return null;
}
```

### Druid

Druid一般的用处有两个：

- 替代C3P0、DBCP数据库连接池(因为它的性能更好)
- 自带监控页面，实时监控应用的连接池情况

配置数据源的信息(Druid),和JPA相关配置

```yaml
# 数据库访问配置
# 主数据源，默认的
spring.datasource.type=com.alibaba.druid.pool.DruidDataSource
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost:3306/druid
spring.datasource.username=root
spring.datasource.password=root

# 下面为连接池的补充设置，应用到上面所有数据源中
# 初始化大小，最小，最大
spring.datasource.initialSize=5
spring.datasource.minIdle=5
spring.datasource.maxActive=20
# 配置获取连接等待超时的时间
spring.datasource.maxWait=60000
# 配置间隔多久才进行一次检测，检测需要关闭的空闲连接，单位是毫秒
spring.datasource.timeBetweenEvictionRunsMillis=60000
# 配置一个连接在池中最小生存的时间，单位是毫秒
spring.datasource.minEvictableIdleTimeMillis=300000
spring.datasource.validationQuery=SELECT 1 FROM DUAL
spring.datasource.testWhileIdle=true
spring.datasource.testOnBorrow=false
spring.datasource.testOnReturn=false
# 打开PSCache，并且指定每个连接上PSCache的大小
spring.datasource.poolPreparedStatements=true
spring.datasource.maxPoolPreparedStatementPerConnectionSize=20
# 配置监控统计拦截的filters，去掉后监控界面sql无法统计，'wall'用于防火墙
spring.datasource.filters=stat,wall,log4j
# 通过connectProperties属性来打开mergeSql功能；慢SQL记录
spring.datasource.connectionProperties=druid.stat.mergeSql=true;druid.stat.slowSqlMillis=5000
# 合并多个DruidDataSource的监控数据
#spring.datasource.useGlobalDataSourceStat=true
#JPA配置
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jackson.serialization.indent_output=true。
```

配置监控页面

> Druid的监控统计功能是通过filter-chain扩展实现，如果你要打开监控统计功能，配置StatFilter

配置druid数据源状态监控，配置一个拦截器和一个Servlet即可～

```java
package com.example.demo;

import com.alibaba.druid.support.http.StatViewServlet;
import com.alibaba.druid.support.http.WebStatFilter;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DruidConfiguration {
    @Bean
    public ServletRegistrationBean DruidStatViewServle2() {
        //org.springframework.boot.context.embedded.ServletRegistrationBean提供类的进行注册.
        ServletRegistrationBean servletRegistrationBean = new ServletRegistrationBean(new StatViewServlet(), "/druid/*");

        //添加初始化参数：initParams

        //白名单：
        servletRegistrationBean.addInitParameter("allow", "127.0.0.1");
        //IP黑名单 (存在共同时，deny优先于allow) : 如果满足deny的话提示:Sorry, you are not permitted to view this page.
        servletRegistrationBean.addInitParameter("deny", "192.168.1.73");
        //登录查看信息的账号密码.
        servletRegistrationBean.addInitParameter("loginUsername", "admin2");
        servletRegistrationBean.addInitParameter("loginPassword", "123456");
        //是否能够重置数据.
        servletRegistrationBean.addInitParameter("resetEnable", "false");
        return servletRegistrationBean;
    }

    @Bean
    public FilterRegistrationBean druidStatFilter2() {
        FilterRegistrationBean filterRegistrationBean = new FilterRegistrationBean(new WebStatFilter());
        //添加过滤规则.
        filterRegistrationBean.addUrlPatterns("/*");
        //添加不需要忽略的格式信息.
        filterRegistrationBean.addInitParameter("exclusions", "*.js,*.gif,*.jpg,*.png,*.css,*.ico,/druid/*");
        return filterRegistrationBean;
    }
}
```

### 使用dbutils框架

dbutils它是对JDBC的简单封装，极大简化jdbc编码的工作量

DbUtils类

提供了关闭连接，装载JDBC驱动，回滚提交事务等方法的工具类【比较少使用，因为我们学了连接池，就应该使用连接池连接数据库】

QueryRunner类

该类简化了SQL查询，配合ResultSetHandler使用，可以完成大部分的数据库操作，重载了许多的查询，更新，批处理方法。大大减少了代码量

ResultSetHandler接口

该接口规范了对ResultSet的操作，要对结果集进行什么操作，传入ResultSetHandler接口的实现类即可。

- ArrayHandler：把结果集中的第一行数据转成对象数组。
- ArrayListHandler：把结果集中的每一行数据都转成一个数组，再存放到List中。
- BeanHandler：将结果集中的第一行数据封装到一个对应的JavaBean实例中。
- BeanListHandler：将结果集中的每一行数据都封装到一个对应的JavaBean实例中，存放到List里。
- ColumnListHandler：将结果集中某一列的数据存放到List中。
- KeyedHandler(name)：将结果集中的每一行数据都封装到一个Map里，再把这些map再存到一个map里，其key为指定的key。
- MapHandler：将结果集中的第一行数据封装到一个Map里，key是列名，value就是对应的值。
- MapListHandler：将结果集中的每一行数据都封装到一个Map里，然后再存放到List
- ScalarHandler 将ResultSet的一个列到一个对象中。

使用DbUils框架对数据库的CRUD

```java

/*
* 使用DbUtils框架对数据库的CRUD
* 批处理
* */
public class Test {
    @Test
    public void add() throws SQLException {
        //创建出QueryRunner对象
        QueryRunner queryRunner = new QueryRunner(JdbcUtils.getDataSource());
        String sql = "INSERT INTO student (id,name) VALUES(?,?)";
        //我们发现query()方法有的需要传入Connection对象，有的不需要传入
        //区别：你传入Connection对象是需要你来销毁该Connection，你不传入，由程序帮你把Connection放回到连接池中
        queryRunner.update(sql, new Object[]{"100", "zhongfucheng"});

    }
    @Test
    public void query()throws SQLException {
        //创建出QueryRunner对象
        QueryRunner queryRunner = new QueryRunner(JdbcUtils.getDataSource());
        String sql = "SELECT * FROM student";
        List list = (List) queryRunner.query(sql, new BeanListHandler(Student.class));
        System.out.println(list.size());
    }
    @Test
    public void delete() throws SQLException {
        //创建出QueryRunner对象
        QueryRunner queryRunner = new QueryRunner(JdbcUtils.getDataSource());
        String sql = "DELETE FROM student WHERE id='100'";
        queryRunner.update(sql);
    }
    @Test
    public void update() throws SQLException {
        //创建出QueryRunner对象
        QueryRunner queryRunner = new QueryRunner(JdbcUtils.getDataSource());
        String sql = "UPDATE student SET name=? WHERE id=?";
        queryRunner.update(sql, new Object[]{"zhongfuchengaaa", 1});
    }
    @Test
    public void batch() throws SQLException {
        //创建出QueryRunner对象
        QueryRunner queryRunner = new QueryRunner(JdbcUtils.getDataSource());
        String sql = "INSERT INTO student (name,id) VALUES(?,?)";
        Object[][] objects = new Object[10][];
        for (int i = 0; i < 10; i++) {
            objects[i] = new Object[]{"aaa", i + 300};
        }
        queryRunner.batch(sql, objects);
    }
}
```

### 分页

分页技术是非常常见的，在搜索引擎下搜索页面，不可能把全部数据都显示在一个页面里边。所以我们用到了分页技术。

- Mysql从(currentPage-1)*lineSize开始取数据，取lineSize条数据
- Oracle先获取currentPage*lineSize条数据，从(currentPage-1)*lineSize开始取数据

分析：

1. 算出有多少页数据这是非常简单的【在数据库中查询有多少条记录，你每页显示多少条记录，就可以算出有多少页数据了】
2. 使用Mysql或Oracle的分页语法即可

通过上面分析，我们会发现需要用到4个变量

- currentPage--当前页【由用户决定的】
- totalRecord--总数据数【查询表可知】
- lineSize--每页显示数据的数量【由我们开发人员决定】
- pageCount--页数【totalRecord和lineSize决定】

```java
        //每页显示3条数据
        int lineSize = 3;

        //总记录数
        int totalRecord = getTotalRecord();

        //假设用户指定的是第2页
        int currentPage = 2;

        //一共有多少页
        int pageCount = getPageCount(totalRecord, lineSize);

        //使用什么数据库进行分页，记得要在JdbcUtils中改配置
        List<Person> list = getPageData2(currentPage, lineSize);
        for (Person person : list) {
            System.out.println(person);
        }

    }

    //使用JDBC连接Mysql数据库实现分页
    public static List<Person> getPageData(int currentPage, int lineSize) throws SQLException {
        //从哪个位置开始取数据
        int start = (currentPage - 1) * lineSize;
        QueryRunner queryRunner = new QueryRunner(JdbcUtils.getDataSource());
        String sql = "SELECT name,address  FROM person LIMIT ?,?";
        List<Person> persons = (List<Person>) queryRunner.query(sql, new BeanListHandler(Person.class), new Object[]{start, lineSize});
        return persons;
    }

    //使用JDBC连接Oracle数据库实现分页
    public static List<Person> getPageData2(int currentPage, int lineSize) throws SQLException {
        //从哪个位置开始取数据
        int start = (currentPage - 1) * lineSize;
        //读取前N条数据
        int end = currentPage * lineSize;
        QueryRunner queryRunner = new QueryRunner(JdbcUtils.getDataSource());
        String sql = "SELECT " +
                "  name, " +
                "  address " +
                "FROM ( " +
                "  SELECT " +
                "    name, " +
                "    address , " +
                "    ROWNUM rn " +
                "  FROM person " +
                "  WHERE ROWNUM <= ? " +
                ")temp WHERE temp.rn>?";
        List<Person> persons = (List<Person>) queryRunner.query(sql, new BeanListHandler(Person.class), new Object[]{end, start});
        return persons;
    }
    public static int getPageCount(int totalRecord, int lineSize) {
        //简单算法
        //return (totalRecord - 1) / lineSize + 1;
        //此算法比较好理解，把数据代代进去就知道了。
        return totalRecord % lineSize == 0 ? (totalRecord / lineSize) : (totalRecord / lineSize) + 1;
    }
    public static int  getTotalRecord() throws SQLException {
        //使用DbUtils框架查询数据库表中有多少条数据
        QueryRunner queryRunner = new QueryRunner(JdbcUtils.getDataSource());
        String sql = "SELECT COUNT(*) FROM person";
        Object o = queryRunner.query(sql, new ScalarHandler());
        String ss = o.toString();
        int  s = Integer.parseInt(ss);
        return s;
    }
```