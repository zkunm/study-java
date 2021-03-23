Spring入门和IOC介绍

## 1. Spring介绍

Spring诞生：

- 创建Spring的目的就是用来**替代更加重量级的的企业级Java技术**
- **简化Java的开发**
  - 基于POJO轻量级和**最小侵入式开发**
  - 通过依赖注入和面向接口实现**松耦合** 		
  - **基于切面**和惯例进行声明式编程
  - 通过切面和模板**减少样板式代码** 

### 1.1侵入式概念

**侵入式**：对于EJB、Struts2等一些传统的框架，**通常是要实现特定的接口，继承特定的类才能增强功能**

- **改变了java类的结构**	 

**非侵入式**：对于Hibernate、Spring等框架，**对现有的类结构没有影响，就能够增强JavaBean的功能**

### 1.2 松耦合概念

前面我们在写程序的时候，都是**面向接口编程，通过DaoFactroy等方法来实现松耦合**

```
private CategoryDao categoryDao = DaoFactory.getInstance().createDao("dao.impl.CategoryDAOImpl", CategoryDao.class)
private BookDao bookDao = DaoFactory.getInstance().createDao("dao.impl.BookDaoImpl", BookDao.class);
private UserDao userDao = DaoFactory.getInstance().createDao("dao.impl.UserDaoImpl", UserDao.class);
private OrderDao orderDao = DaoFactory.getInstance().createDao("dao.impl.OrderDaoImpl", OrderDao.class);
```

DAO层和Service层通过DaoFactory来实现松耦合，如果Serivce层直接`new DaoBook()`，那么DAO和Service就紧耦合了【Service层依赖紧紧依赖于Dao】。

而Spring给我们更加合适的方法来实现松耦合，并且更加灵活、功能更加强大！---->**IOC控制反转**

### 1.3 切面编程

切面编程也就是AOP编程，动态代理就是一种切面编程

AOP编程可以简单理解成：**在执行某些代码前，执行另外的代码**（Struts2的拦截器也是面向切面编程【在执行Action业务方法之前执行拦截器】）

Spring也为我们**提供更好地方式来实现面向切面编程**！

## 2. 引出Spring

我们试着回顾一下没学Spring的时候，是怎么开发Web项目的

- **1. 实体类--->class User{ }**
- **2. daoclass-->  UserDao{  .. 访问db}**
- **3. service--->class  UserService{  UserDao userDao = new UserDao();}**
- **4. actionclass  UserAction{UserService userService = new UserService();}** 

**用户访问：Tomcat->servlet->service->dao**

我们来思考几个问题：

- ①：**对象创建创建能否写死？**
- ②：对象创建细节
  - **对象数量**
    - action  多个   【维护成员变量】
    - service 一个   【不需要维护公共变量】
    - dao     一个   【不需要维护公共变量】
  - **创建时间**
    - action    访问时候创建
    - service   启动时候创建
    - dao       启动时候创建
- ③：对象的依赖关系
  - **action 依赖 service**
  - **service依赖 dao**

对于第一个问题和第三个问题，**我们可以通过DaoFactory解决掉(虽然不是比较好的解决方法)**

对于第二个问题，我们要**控制对象的数量和创建时间就有点麻烦了**....

而**Spring框架通过IOC就很好地可以解决上面的问题**....

### 2.1 IOC控制反转

Spring的核心思想之一：**Inversion of Control , 控制反转 IOC**

那么控制反转是什么意思呢？？？**对象的创建交给外部容器完成，这个就做控制反转。**

- **Spring使用控制反转来实现对象不用在程序中写死**
- **控制反转解决对象处理问题【把对象交给别人创建】**

那么对象的对象之间的依赖关系Spring是怎么做的呢？？**依赖注入：dependency injection.**

- **Spring使用依赖注入来实现对象之间的依赖关系**
- **在创建完对象之后，对象的关系处理就是依赖注入**

上面已经说了，控制反转是通过外部容器完成的，**而Spring又为我们提供了这么一个容器，我们一般将这个容器叫做：IOC容器.**

**无论是创建对象、处理对象之间的依赖关系、对象创建的时间还是对象的数量，我们都是在Spring为我们提供的IOC容器上配置对象的信息就好了。**

那么使用IOC控制反转这一思想有什么作用呢？？？我们来看看一些优秀的回答...

来自知乎：https://www.zhihu.com/question/23277575/answer/24259844

我摘取一下核心的部分：

> ioc的思想最核心的地方在于，资源不由使用资源的双方管理，而由不使用资源的第三方管理，这可以带来很多好处。**第一，资源集中管理，实现资源的可配置和易管理**。**第二，降低了使用资源双方的依赖程度，也就是我们说的耦合度**。
>
> 也就是说，甲方要达成某种目的不需要直接依赖乙方，它只需要达到的目的告诉第三方机构就可以了，比如甲方需要一双袜子，而乙方它卖一双袜子，它要把袜子卖出去，并不需要自己去直接找到一个卖家来完成袜子的卖出。它也只需要找第三方，告诉别人我要卖一双袜子。这下好了，甲乙双方进行交易活动，都不需要自己直接去找卖家，相当于程序内部开放接口，卖家由第三方作为参数传入。甲乙互相不依赖，而且只有在进行交易活动的时候，甲才和乙产生联系。反之亦然。这样做什么好处么呢，甲乙可以在对方不真实存在的情况下独立存在，而且保证不交易时候无联系，想交易的时候可以很容易的产生联系。甲乙交易活动不需要双方见面，避免了双方的互不信任造成交易失败的问题。**因为交易由第三方来负责联系，而且甲乙都认为第三方可靠。那么交易就能很可靠很灵活的产生和进行了**。这就是ioc的核心思想。生活中这种例子比比皆是，支付宝在整个淘宝体系里就是庞大的ioc容器，交易双方之外的第三方，提供可靠性可依赖可灵活变更交易方的资源管理中心。另外人事代理也是，雇佣机构和个人之外的第三方。 ==========================update===========================
>
> 在以上的描述中，诞生了两个专业词汇，依赖注入和控制反转所谓的依赖注入，则是，甲方开放接口，在它需要的时候，能够讲乙方传递进来(注入)所谓的控制反转，甲乙双方不相互依赖，交易活动的进行不依赖于甲乙任何一方，整个活动的进行由第三方负责管理。

参考优秀的博文②：[这里写链接内容](http://mp.weixin.qq.com/s?__biz=MzAxOTc0NzExNg==&mid=2665513179&idx=1&sn=772226a5be436a0d08197c335ddb52b8#rd)

**知乎@Intopass的回答：**

1. 不用自己组装，拿来就用。
2. 享受单例的好处，效率高，不浪费空间。
3. 便于单元测试，方便切换mock组件。
4. 便于进行AOP操作，对于使用者是透明的。
5. 统一配置，便于修改。

## 3.Spring模块

**Spring可以分为6大模块：**

- Spring Core  spring的核心功能： IOC容器, 解决对象创建及依赖关系
- Spring Web  Spring对web模块的支持。
  - 可以与struts整合,让struts的action创建交给spring
  - spring mvc模式
- Spring DAO  Spring 对jdbc操作的支持  【JdbcTemplate模板工具类】
- Spring ORM  spring对orm的支持： 
  - 既可以与hibernate整合【session】
  - 也可以使用spring的对hibernate操作的封装
- Spring AOP  切面编程
- SpringEE   spring 对javaEE其他模块的支持

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212162333.png)

## 4. Core模块快速入门

### 4.1搭建配置环境

1. 引入依赖

```xml
<!--spring-context依赖aop,beans,core,expression-->
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context</artifactId>
    <version>5.2.0.RELEASE</version>
</dependency>
```

2. 编写配置文件:Spring核心的配置文件`applicationContext.xml`或者叫`bean.xml`

```
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:p="http://www.springframework.org/schema/p"
    xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd">
  
</beans>   
```

前面在介绍Spring模块的时候已经说了，**Core模块是：IOC容器，解决对象创建和之间的依赖关系**。

因此**Core模块主要是学习如何得到IOC容器，通过IOC容器来创建对象、解决对象之间的依赖关系、IOC细节。**

### 4.2 得到Spring容器对象【IOC容器】

Spring容器不单单只有一个，可以归为两种类型

- **Bean工厂，BeanFactory【功能简单】** 
- **应用上下文，ApplicationContext【功能强大，一般我们使用这个】**

#### 4.2.1通过Resource获取BeanFactory

- **加载Spring配置文件**
- **通过XmlBeanFactory+配置文件来创建IOC容器**

```
//加载Spring的资源文件
Resource resource = new ClassPathResource("applicationContext.xml");
//创建IOC容器对象【IOC容器=工厂类+applicationContext.xml】
BeanFactory beanFactory = new XmlBeanFactory(resource);     
```

------

#### 4.2.2类路径下XML获取ApplicationContext

**直接通过ClassPathXmlApplicationContext对象来获取**

```
// 得到IOC容器对象
ApplicationContext ac = new ClassPathXmlApplicationContext("applicationContext.xml");
System.out.println(ac);
```

在Spring中总体来看可以通过四种方式来配置对象:

- **使用XML文件配置**
- **使用注解来配置**
- **使用JavaConfig来配置**
- groovy脚本 DSL

### 4.3XML配置方式

在上面我们已经可以得到IOC容器对象了。**接下来就是在applicationContext.xml文件中配置信息【让IOC容器根据applicationContext.xml文件来创建对象】**

首先我们先有个JavaBean的类

```
@NoArgsConstructor
@AllArgsConstructor
@Data
public class User {
    private String id;
    private String username;
}
```

以前我们是通过new User的方法创建对象的

```
User user = new User();
```

现在我们有了IOC容器，可以让IOC容器帮我们创建对象了。在applicationContext.xml文件中配置对应的信息就行了

```
<!--
使用bean节点来创建对象
id属性标识着对象
name属性代表着要创建对象的类全名
-->
<bean id="user" class="com.zkunm.domain.User"/>
```

**通过IOC容器对象获取对象:在外界通过IOC容器对象得到User对象**

```
// 得到IOC容器对象
ApplicationContext ac = new ClassPathXmlApplicationContext("applicationContext.xml");
User user = (User) ac.getBean("user");
System.out.println(user);
```

上面我们使用的是IOC通过无参构造函数来创建对象，我们来回顾一下一般有几种创建对象的方式：

- 无参构造函数创建对象
- 带参数的构造函数创建对象
- 工厂创建对象
  - 静态方法创建对象
  - 非静态方法创建对象

使用无参的构造函数创建对象我们已经会了，接下来我们看看使用剩下的IOC容器是怎么创建对象的。

#### 4.3.1带参数的构造函数创建对象

首先，**JavaBean就要提供带参数的构造函数：**

```
public User(String id, String username) {
    this.id = id;
    this.username = username;
}
```

接下来，关键是怎么配置applicationContext.xml文件了。

```
<bean id="user" class="com.zkunm.domain.User">
    <!--通过constructor这个节点来指定构造函数的参数类型、名称、第几个-->
    <constructor-arg index="0" name="id" type="java.lang.String" value="1"/>
    <constructor-arg index="1" name="username" type="java.lang.String" value="zkunm"/>
</bean>
```

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212165518.png)

在constructor上如果构造函数的值是一个对象，而不是一个普通类型的值，我们就需要用到ref属性了，而不是value属性

#### 4.3.2工厂静态方法创建对象

首先，**使用一个工厂的静态方法返回一个对象**

```
public class Factory {
    public static User getBean() {
        return new User();
    }
}
```

**配置文件中使用工厂的静态方法返回对象**

```
<!--工厂静态方法创建对象，直接使用class指向静态类，指定静态方法就行了-->
<bean id="user" class="com.zkunm.Factory" factory-method="getBean"/>
```

#### 4.3.3工厂非静态方法创建对象

首先，也是通过工厂的非非静态方法来得到一个对象

```
public class Factory {
    public User getBean() {
        return new User();
    }
}
```

**配置文件中使用工厂的非静态方法返回对象**

```
<!--首先创建工厂对象-->
<bean id="factory" class="com.zkunm.Factory"/>
<!--指定工厂对象和工厂方法-->
<bean id="user" class="com.zkunm.domain.User" factory-bean="factory" factory-method="getBean"/>
```

#### 4.3.4 c名称空间

我们在使用XML配置创建Bean的时候，如果该Bean有构造器，那么我们使用`<constructor-arg>`这个节点来对构造器的参数进行赋值...

`<constructor-arg>`未免有点太长了，为了简化配置，Spring来提供了c名称空间...

**要想c名称空间是需要导入`xmlns:c="http://www.springframework.org/schema/c"`的**

```
<bean id="userService" class="com.zkunm.service.UserService" c:userDao-ref=""/>
```

c名称空间有个**缺点：不能装配集合，**当我们要装配集合的时候还是需要`<constructor-arg>`这个节点

#### 4.3.5装载集合

如果对象上的属性或者构造函数拥有集合的时候，而我们又需要为集合赋值，那么怎么办？

**在构造函数上，普通类型**

```
<bean id="userService" class="com.zkunm.service.UserService" >
    <constructor-arg >
        <list>
            <value></value>
        </list>
    </constructor-arg>
</bean>
```

**在属性上,引用类型**

```
<property name="userDao">
    <list>
        <ref></ref>
    </list>
</property>
```

### 4.4注解方式

自从jdk5有了注解这个新特性，我们可以看到Struts2框架、Hibernate框架都支持使用注解来配置信息...

**通过注解来配置信息就是为了简化IOC容器的配置，注解可以把对象添加到IOC容器中、处理对象依赖关系**，我们来看看怎么用吧：

使用注解步骤：

- **1）先引入context名称空间**
  - xmlns:context="http://www.springframework.org/schema/context"
- **2）开启注解扫描器**
  - `<context:component-scan base-package=""/>`
  - 第二种方法:也可以通过自定义扫描类以@CompoentScan修饰来扫描IOC容器的bean对象。如下代码:

```
//表明该类是配置类
@Configuration
//启动扫描器，扫描bb包下的
//也可以指定多个基础包
//也可以指定类型
@ComponentScan("com.zkunm")
public class AnnotationScan {
}
```

在使用@ComponentScan()这个注解的时候，在测试类上需要@ContextConfiguration这个注解来加载配置类...

- @ContextConfiguration这个注解又在Spring的test包下..

创建对象以及处理对象依赖关系，相关的注解：

- @ComponentScan扫描器
- @Configuration表明该类是配置类
- @Component   指定把一个对象加入IOC容器--->@Name也可以实现相同的效果【一般少用】
- @Repository   作用同@Component； 在持久层使用
- @Service      作用同@Component； 在业务逻辑层使用
- @Controller    作用同@Component； 在控制层使用 
- @Resource  依赖关系
  - 如果@Resource不指定值，那么就根据类型来找，相同的类型在IOC容器中不能有两个
  - 如果@Resource指定了值，那么就根据名字来找

测试代码:UserDao

```
@Repository
public class UserDao {
    public void save() {
        System.out.println("DB:保存用户");
    }
}
```

UserService

```
//把UserService对象添加到IOC容器中,首字母会小写
@Service
public class UserService {
    //如果@Resource不指定值，那么就根据类型来找--->UserDao....当然了，IOC容器不能有两个UserDao类型的对象
    //@Resource
    //如果指定了值，那么Spring就在IOC容器找有没有id为userDao的对象。
    @Resource(name = "userDao")
    private UserDao userDao;

    public void save() {
        userDao.save();
    }
}
```

UserController

```
@Controller
public class UserController {
    @Resource(name = "userService")
    private UserService userService;
    public String execute() {
        userService.save();
        return null;
    }
}
```

测试

```
@Test
public void test1() {
    ApplicationContext ac = new ClassPathXmlApplicationContext("applicationContext.xml");
    UserController controller = (UserController) ac.getBean("userController");
    System.out.println(controller);
    controller.execute();
}
```

------

### 4.5通过JavaConfig方式

怎么通过java代码来配置Bean呢？？

- 编写一个java类，使用@Configuration修饰该类
- 被@Configuration修饰的类就是配置类

**编写配置类:**

```
@Configuration
public class MyConfiguration {
}
```

**使用配置类创建bean:**

- 使用@Bean来修饰方法，该方法返回一个对象。
- 不管方法体内的对象是怎么创建的，Spring可以获取得到对象就行了。
- Spring内部会将该对象加入到Spring容器中
- 容器中bean的ID默认为方法名

```
@Configuration
public class MyConfiguration {
    @Bean
    public UserDao userDao() {
        UserDao userDao = new UserDao();
        System.out.println("我是在MyConfiguration中的" + userDao);
        return userDao;
    }
}
```

- 测试代码：要使用@ContextConfiguration加载配置类的信息【引入test包】

```
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = MyConfiguration.class)
public class SpringContextTest {
    @Test
    public void test1() {
        ApplicationContext ac = new ClassPathXmlApplicationContext("applicationContext.xml");
        UserDao dao = (UserDao) ac.getBean("userDao");
        dao.save();
    }
}
```

### 4.6三种方式混合使用？

**注解和XML配置是可以混合使用的，JavaConfig和XML也是可以混合使用的...**

如果JavaConfig的配置类是分散的，我们一般再创建一个更高级的配置类（root），然后使用**@Import来将配置类进行组合** 如果XML的配置文件是分散的，我们也是创建一个更高级的配置文件（root），然后**使用`<import>`来将配置文件组合**

在JavaConfig引用XML

- 使用@ImportResource()

在XML引用JavaConfig

- 使用`<bean>`节点就行了

在公司的项目中，一般我们是`XML+注解`

## 5. bean对象创建细节

既然我们现在已经初步了解IOC容器了，那么这些问题我们都是可以解决的。并且是十分简单【对象写死问题已经解决了，IOC容器就是控制反转创建对象】

### 5.1 scope属性

指定scope属性，IOC容器就知道创建对象的时候是单例还是多例的了。

属性的值就只有两个：单例/多例

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212172020.png)

> 当我们使用singleton【单例】的时候，从IOC容器获取的对象都是同一个：
>
> 当我们使用prototype【多例】的时候，从IOC容器获取的对象都是不同的：

scope属性除了控制对象是单例还是多例的，**还控制着对象创建的时间**！

> 当使用singleton的时候，对象在IOC容器之前就已经创建了
>
> 当使用prototype的时候，对象在使用的时候才创建

### 5.2lazy-init属性

lazy-init属性**只对singleton【单例】的对象有效**.....lazy-init默认为false....

有的时候，可能我们**想要对象在使用的时候才创建，那么将lazy-init设置为ture就行了**

------

### 5.3 init-method和destroy-method

如果我们想要**对象在创建后，执行某个方法**，我们指定为init-method属性就行了。。

如果我们想要**IOC容器销毁后，执行某个方法**，我们指定destroy-method属性就行了。

```
<bean id="user" class="User" scope="singleton" lazy-init="true" init-method="" destroy-method=""/>
```

### 5.4 Bean创建细节总结

```
  /**
   * 1) 对象创建： 单例/多例
   *  scope="singleton", 默认是单例 【service/dao/工具类】
   *  scope="prototype", 多例；【Controller对象】
   * 
   * 2) 什么时候创建?
   *    scope="prototype"  在用到对象的时候，才创建对象。
   *    scope="singleton"  在启动(容器初始化之前)， 就已经创建了bean，且整个应用只有一个。
   * 3)是否延迟创建
   *    lazy-init="false"  默认为false,  不延迟创建，即在启动时候就创建对象
   *    lazy-init="true"   延迟初始化， 在用到对象的时候才创建对象
   *    （只对单例有效）
   * 4) 创建对象之后，初始化/销毁
   *    init-method="init_user"       【对应对象的init_user方法，在对象创建之后执行 】
   *    destroy-method="destroy_user"  【在调用容器对象的destroy方法时候执行，(容器用实现类)】
   */
```

# 对象依赖

## 1. 回顾以前对象依赖

### 1.1 直接new对象

在最开始，我们是直接new对象给serice的userDao属性赋值...

```
class UserService{
  UserDao userDao = new UserDao();
}
```

### 1.2 写DaoFactory，用字符串来维护依赖关系

后来，我们发现service层紧紧耦合了dao层。**我们就写了DaoFactory，在service层只要通过字符串就能够创建对应的dao层的对象了。**

DaoFactory

```
public class DaoFactory {
    private static final DaoFactory factory = new DaoFactory();
    private DaoFactory(){}
    public static DaoFactory getInstance(){
        return factory;
    }
    public <T> T createDao(String className,Class<T> clazz){
        try{
            T t = (T) Class.forName(className).newInstance();
            return t;
        }catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
```

serivce

```
private OrderDao orderDao = DaoFactory.getInstance().createDao("dao.impl.OrderDaoImpl", OrderDao.class);
```

### 1.3 DaoFactory读取配置文件

再后来，我们发现要修**改Dao的实现类，还是得修改service层的源代码**呀..**于是我们就在DaoFactory中读取关于daoImpl的配置文件，根据配置文件来创建对象，这样一来，创建的是哪个daoImpl对service层就是透明的**

DaoFactory

```
public class DaoFactory {
  private  UserDao userdao = null;
  private DaoFactory(){
    try{
      InputStream in = DaoFactory.class.getClassLoader().getResourceAsStream("dao.properties");
      Properties prop = new Properties();
      prop.load(in);
      String daoClassName = prop.getProperty("userdao");
      userdao = (UserDao)Class.forName(daoClassName).newInstance();
    }catch (Exception e) {
      throw new RuntimeException(e);
    }
  }
  private static final DaoFactory instance = new DaoFactory();
  public static DaoFactory getInstance(){
    return instance;
  }
  public UserDao createUserDao(){
    return userdao;
  }
}
```

service

```
  UserDao dao = DaoFactory.getInstance().createUserDao();
```

## 2. Spring依赖注入

通过上面的历程，我们可以清晰地发现：**对象之间的依赖关系，其实就是给对象上的属性赋值！因为对象上有其他对象的变量，因此存在了依赖**...

Spring提供了好几种的方式来给属性赋值

- **1) 通过构造函数**
- **2) 通过set方法给属性注入值**
- 3) p名称空间
- 4)自动装配(了解)
- **5) 注解**

### 2.1 搭建测试环境

 UserService中使用userDao变量来维护与Dao层之间的依赖关系，UserController中使用userService变量来维护与Service层之间的依赖关系。

UserDao

```
public class UserDao {
  public void save() {
    System.out.println("DB:保存用户");
  }
}
```

UserService

```
public class UserService {
  private UserDao userDao; 
  public void save() {
    userDao.save();
  }
}
```

UserController

```
public class UserController {
    private UserService userService;
    public String execute() {
        userService.save();
        return null;
    }
}
```

### 2.2构造函数给属性赋值

其实我们在讲解**创建带参数的构造函数的时候已经讲过了**...我们还是来回顾一下呗..

我们**测试service和dao的依赖关系就好了**....在**serice中加入一个构造函数，参数就是userDao**

```
public UserService(UserDao userDao) {
    this.userDao = userDao;
    System.out.println(userDao);
}
```

**applicationContext.xml配置文件**

```
<!--创建userDao对象-->
<bean id="userDao" class="com.zkunm.dao.UserDao"/>
<!--创建userService对象-->
<bean id="userService" class="com.zkunm.service.UserService">
    <!--要想在userService层中能够引用到userDao，就必须先创建userDao对象-->
    <constructor-arg index="0" name="userDao" type="com.zkunm.dao.UserDao" ref="userDao"/>
</bean>
```

### 2.3通过set方法给属性注入值

我们这里也是测试service和dao层的依赖关系就好了...**在service层通过set方法来把userDao注入到UserService中**

为UserService添加set方法

```
public class UserService {
    private UserDao userDao;
    public void setUserDao(UserDao userDao) {
        this.userDao = userDao;
        System.out.println(userDao);
    }
    public void save() {
        userDao.save();
    }
}
```

applicationContext.xml配置文件：通过property节点来给属性赋值

- **引用类型使用ref属性**
- **基本类型使用value属性**

```
<!--创建userDao对象-->
<bean id="userDao" class="com.zkunm.dao.UserDao"/>
<!--创建userService对象-->
<bean id="userService" class="com.zkunm.service.UserService">
    <property name="userDao" ref="userDao"/>
</bean>
```

### 2.4 内部Bean

我们刚才是**先创建userDao对象，再由userService对userDao对象进行引用**...我们还有另一种思维：**先创建userService，发现userService需要userDao的属性，再创建userDao**...我们来看看这种思维方式是怎么配置的：

applicationContext.xml配置文件：property节点内置bean节点

```
<!--
1.创建userService，看到有userDao这个属性
2.而userDao这个属性又是一个对象
3.在property属性下又内置了一个bean
4.创建userDao
-->
<bean id="userService" class="com.zkunm.service.UserService">
    <property name="userDao">
        <bean id="userDao" class="com.zkunm.dao.UserDao"/>
    </property>
</bean>
```

### 2.5 p 名称空间注入属性值

p名称控件这种方式**其实就是set方法的一种优化，优化了配置而已**...p名称空间这个内容**需要在Spring3版本以上才能使用**...我们来看看：

applicationContext.xml配置文件：使用p名称空间

```
<bean id="userDao" class="com.zkunm.dao.UserDao"/>
<!--不用写property节点了，直接使用p名称空间-->
<bean id="userService" class="com.zkunm.service.UserService" p:userDao-ref="userDao"/>
```

------

### 2.6 自动装配

**Spring还提供了自动装配的功能，能够非常简化我们的配置**

自动装载默认是不打开的，自动装配常用的可分为两种：

- **根据名字来装配**
- **根据类型类装配**

#### 2.6.1XML配置根据名字

applicationContext.xml配置文件：使用自动装配，根据名字

```
<bean id="userDao" class="com.zkunm.dao.UserDao"/>
<!--
    1.通过名字来自动装配
    2.发现userService中有个叫userDao的属性
    3.看看IOC容器中没有叫userDao的对象
    4.如果有，就装配进去
-->
<bean id="userService" class="com.zkunm.service.UserService" autowire="byName"/>
```

------

#### 2.6.2 XML配置根据类型

applicationContext.xml配置文件：使用自动装配，根据类型

值得注意的是：**如果使用了根据类型来自动装配，那么在IOC容器中只能有一个这样的类型，否则就会报错！**

```
<bean id="userDao" class="com.zkunm.dao.UserDao"/>
<!--
    1.通过名字来自动装配
    2.发现userService中有个叫userDao的属性
    3.看看IOC容器UserDao类型的对象
    4.如果有，就装配进去
-->
<bean id="userService" class="com.zkunm.service.UserService" autowire="byType"/>
```

 也可以**使用默认自动分配**

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212175305.png)

### 2.7 使用注解来实现自动装配

@Autowired注解来实现自动装配：

- **可以在构造器上修饰**
- **也可以在setter方法上修饰**
- **来自java的@Inject的和@AutoWired有相同的功能**

如果没有匹配到bean，又为了避免异常的出现，我们可以使用required属性上设置为false。【谨慎对待】

测试代码

```
@Component
public class UserService {
    private UserDao userDao ;
    @Autowired
    public void setUserDao(UserDao userDao) {
        this.userDao = userDao;
    }
}
```

顺利拿到userDao的引用

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212175349.png)

# AOP入门

## 1. cglib代理

在讲解cglib之前，首先我们来回顾一下静态代理和动态代理

**由于静态代理需要实现目标对象的相同接口，那么可能会导致代理类会非常非常多....不好维护**---->因此出现了动态代理

动态代理也有个约束：**目标对象一定是要有接口的，没有接口就不能实现动态代理**.....----->因此出现了cglib代理

cglib代理也叫子类代理，**从内存中构建出一个子类来扩展目标对象的功能！**

- CGLIB是一个强大的高性能的代码生成包，它可以在运行期扩展Java类与实现Java接口。它广泛的被许多AOP的框架使用，例如Spring AOP和dynaop，为他们提供方法的interception（拦截）。 

### 1.1 编写cglib代理

接下来我们就讲讲怎么写cglib代理：

- 需要引入cglib – jar文件，但是spring的核心包中已经包括了cglib功能，所以直接引入spring-core即可
- 引入功能包后，就可以在内存中动态构建子类
- **代理的类不能为final**，否则报错【在内存中构建子类来做扩展，当然不能为final，有final就不能继承了】
- **目标对象的方法如果为final/static, 那么就不会被拦截**，即不会执行目标对象额外的业务方法。

```
//需要实现MethodInterceptor接口
public class ProxyFactory implements MethodInterceptor {
    // 维护目标对象
    private Object target;

    public ProxyFactory(Object target) {
        this.target = target;
    }

    // 给目标对象创建代理对象
    public Object getProxyInstance() {
        //1. 工具类
        Enhancer en = new Enhancer();
        //2. 设置父类
        en.setSuperclass(target.getClass());
        //3. 设置回调函数
        en.setCallback(this);
        //4. 创建子类(代理对象)
        return en.create();
    }

    @Override
    public Object intercept(Object obj, Method method, Object[] args, MethodProxy proxy) throws Throwable {
        System.out.println("开始事务.....");
        // 执行目标对象的方法
        Object returnValue = method.invoke(target, args);
//        proxy.invokeSuper(obj, args);
        System.out.println("提交事务.....");
        return returnValue;
    }
}

```

测试：

```
@Test
public void test1() {
    UserDao userDao = new UserDao();
    UserDao factory = (UserDao) new ProxyFactory(userDao).getProxyInstance();
    factory.save();
}
```

结果如下：

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212180727.png)

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212180708.png)

使用cglib就是为了弥补动态代理的不足【动态代理的目标对象一定要实现接口】

## 2. 手动实现AOP编程

AOP 面向切面的编程：**AOP可以实现“业务代码”与“关注点代码”分离**

下面我们来看一段代码：

```
// 保存一个用户
public void add(User user) {
    Session session = null;
    Transaction trans = null;
    try {
        session = HibernateSessionFactoryUtils.getSession();   // 【关注点代码】
        trans = session.beginTransaction();    // 【关注点代码】
        session.save(user);     // 核心业务代码
        trans.commit();     //…【关注点代码】
    } catch (Exception e) {
        e.printStackTrace();
        if(trans != null){
            trans.rollback();   //..【关注点代码】
        }
    } finally{
        HibernateSessionFactoryUtils.closeSession(session);   ////..【关注点代码】
    }
}
```

关注点代码，就是指重复执行的代码。

业务代码与关注点代码分离，好处？

- **关注点代码写一次即可**；
- **开发者只需要关注核心业务**；
- **运行时期，执行核心业务代码时候动态植入关注点代码； 【代理】**

### 2.1案例分析：

IUser接口

```
public interface IUser {
    void save();
}
```

我们一步一步来分析，**首先我们的UserDao有一个save()方法，每次都要开启事务和关闭事务**

```
@Component
public class UserDao implements IUser{
    public void save() {
        System.out.println("开始事务");
        System.out.println("DB:保存用户");
        System.out.println("关闭事务");
    }
}
```

在刚学习java基础的时候，我们知道：**如果某些功能经常需要用到就封装成方法：**

```
@Component
public class UserDao implements IUser{
    public void save() {
        begin();
        System.out.println("DB:保存用户");
        close();
    }
    public void begin() {
        System.out.println("开始事务");
    }
    public void close() {
        System.out.println("关闭事务");
    }
}
```

现在呢，**我们可能有多个Dao，都需要有开启事务和关闭事务的功能，现在只有UserDao中有这两个方法，重用性还是不够高。因此我们抽取出一个类出来**

```
public class AOP {
    public void begin() {
        System.out.println("开始事务");
    }
    public void close() {
        System.out.println("关闭事务");
    }
}
```

在UserDao维护这个变量，要用的时候，调用方法就行了。

```
@Component
public class UserDao implements IUser{
    AOP aop;
    public void save() {
        aop.begin();
        System.out.println("DB:保存用户");
        aop.close();
    }
}
```

现在的开启事务、关闭事务还是需要我在userDao中手动调用。还是不够优雅。。我想要的效果：当我在调用userDao的save()方法时，**动态地开启事务、关闭事务。**因此，我们就**用到了代理**。当然了，**真正执行方法的都是userDao、要干事的是AOP，因此在代理中需要维护他们的引用**。

```
public class ProxyFactory {
    //维护目标对象
    private static Object target;
    //维护关键点代码的类
    private static AOP aop;
    public static Object getProxyInstance(Object target_, AOP aop_) {
        //目标对象和关键点代码的类都是通过外界传递进来
        target = target_;
        aop = aop_;
        return Proxy.newProxyInstance(
                target.getClass().getClassLoader(),
                target.getClass().getInterfaces(),
                (proxy, method, args) -> {
                    aop.begin();
                    Object returnValue = method.invoke(target, args);
                    aop.close();
                    return returnValue;
                }
        );
    }
}
```

### 2.2工厂静态方法：

把AOP加入IOC容器中

```
@Component
public class AOP {
    public void begin() {
        System.out.println("开始事务");
    }
    public void close() {
        System.out.println("关闭事务");
    }
}
```

把UserDao放入容器中

```
@Component
public class UserDao implements IUser{
    public void save() {
        System.out.println("DB:保存用户");
    }
}
```

在配置文件中开启注解扫描,使用工厂静态方法创建代理对象

```
<bean id="proxy" class="com.ProxyFactory" factory-method="getProxyInstance">
    <constructor-arg index="0" ref="userDao"/>
    <constructor-arg index="1" ref="AOP"/>
</bean>
<context:component-scan base-package="com"/>
```

测试，得到UserDao对象，调用方法

```
ApplicationContext ac = new ClassPathXmlApplicationContext("applicationContext.xml");
IUser iUser = (IUser) ac.getBean("proxy");
iUser.save();
```

### 2.3 工厂非静态方法

上面使用的是工厂静态方法来创建代理类对象。我们也**使用一下非静态的工厂方法创建对象**。

```
public class ProxyFactory {
    public Object getProxyInstance(final Object target_, final AOP aop_) {
        return Proxy.newProxyInstance(
                target_.getClass().getClassLoader(),
                target_.getClass().getInterfaces(),
                (proxy, method, args) -> {
                    aop_.begin();
                    Object returnValue = method.invoke(target_, args);
                    aop_.close();
                    return returnValue;
                }
        );
    }
}
```

配置文件:**先创建工厂，再创建代理类对象**

```
<!--创建工厂-->
<bean id="factory" class="com.ProxyFactory"/>
<!--通过工厂创建代理-->
<bean id="IUser" class="com.IUser" factory-bean="factory" factory-method="getProxyInstance">
    <constructor-arg index="0" ref="userDao"/>
    <constructor-arg index="1" ref="AOP"/>
</bean>
<context:component-scan base-package="com"/>
```

## 3. AOP的概述

**Aop： aspect object programming  面向切面编程**

- **功能： 让关注点代码与业务代码分离！**
- 面向切面编程就是指： **对很多功能都有的重复的代码抽取，再在运行的时候往业务方法上动态植入“切面类代码”。**

关注点：**重复代码就叫做关注点。**

```
// 保存一个用户
public void add(User user) { 
    Session session = null; 
    Transaction trans = null; 
    try { 
      session = HibernateSessionFactoryUtils.getSession();   // 【关注点代码】
      trans = session.beginTransaction();    // 【关注点代码】
      session.save(user);     // 核心业务代码
      trans.commit();     //…【关注点代码】
    } catch (Exception e) {     
      e.printStackTrace(); 
      if(trans != null){ 
        trans.rollback();   //..【关注点代码】
      } 
    } finally{ 
      HibernateSessionFactoryUtils.closeSession(session);   ////..【关注点代码】
    } 
   } 
```

切面：**关注点形成的类，就叫切面(类)！**

```
public class AOP {
    public void begin() {
        System.out.println("开始事务");
    }
    public void close() {
        System.out.println("关闭事务");
    }
}
```

切入点：

- 执行目标对象方法，动态植入切面代码。
- 可以通过**切入点表达式**，**指定拦截哪些类的哪些方法； 给指定的类在运行的时候植入切面类代码**。

切入点表达式：

- **指定哪些类的哪些方法被拦截**

## 4. 使用Spring AOP开发步骤

1） **先引入aop相关jar文件**    	（aspectj  aop优秀组件）	

```xml
<dependency>
    <groupId>aopalliance</groupId>
    <artifactId>aopalliance</artifactId>
    <version>1.0</version>
</dependency>
<dependency>
    <groupId>org.aspectj</groupId>
    <artifactId>aspectjweaver</artifactId>
    <version>1.9.4</version>
</dependency>
<dependency>
    <groupId>org.aspectj</groupId>
    <artifactId>aspectjrt</artifactId>
    <version>1.8.13</version>
</dependency>
```

2） **bean.xml中引入aop名称空间**

- **`xmlns:context="http://www.springframework.org/schema/context"`**
- **`http://www.springframework.org/schema/context`**
- **`http://www.springframework.org/schema/context/spring-context.xsd`**

### 4.1 引入名称空间

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd">
    
</beans>
```

------

### 4.2注解方式实现AOP编程

我们之前手动的实现AOP编程是需要自己来编写代理工厂的**，现在有了Spring，就不需要我们自己写代理工厂了。Spring内部会帮我们创建代理工厂**。也就是说，不用我们自己写代理对象了。

因此，我们**只要关心切面类、切入点、编写切入表达式指定拦截什么方法就可以了！**

还是以上一个例子为案例，使用Spring的注解方式来实现AOP编程

#### 4.2.1在配置文件中开启AOP注解方式

```
<!-- 开启aop注解方式 -->
<aop:aspectj-autoproxy></aop:aspectj-autoproxy>
<context:component-scan base-package="com"/>
```

#### 4.2.2代码：

切面类

```
@Component
@Aspect//指定为切面类
public class AOP {
    //里面的值为切入点表达式
    @Before("execution(* com.*.*(..))")
    public void begin() {
        System.out.println("开始事务");
    }
    @After("execution(* com.*.*(..))")
    public void close() {
        System.out.println("关闭事务");
    }
}
```

UserDao实现了IUser接口

```
@Component
public class UserDao implements IUser{
    public void save() {
        System.out.println("DB:保存用户");
    }
}
```

IUser接口

```
public interface IUser {
    void save();
}
```

测试代码：

```
public class App {
    public static void main(String[] args) {
        ApplicationContext ac = new ClassPathXmlApplicationContext("applicationContext.xml");
        IUser iUser = (IUser) ac.getBean("userDao");
        System.out.println(iUser.getClass());
        iUser.save();
    }
}
```

------

### 4.3目标对象没有接口

上面我们测试的是UserDao有IUser接口，内部使用的是动态代理...那么我们这次测试的是目标对象没有接口

OrderDao没有实现接口

```
@Component
public class OrderDao {
    public void save() {
        System.out.println("我已经进货了！！！");
    }
}
```

测试代码：

```
public class App {
    public static void main(String[] args) {
        ApplicationContext ac =new ClassPathXmlApplicationContext("applicationContext.xml");
        OrderDao orderDao = (OrderDao) ac.getBean("orderDao");
        System.out.println(orderDao.getClass());
        orderDao.save();
    }
}
```

效果：

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212184640.png)

------

### 4.4 AOP注解API

api:

- **@Aspect**							指定一个类为切面类		
- **@Pointcut("execution(\* cn.itcast.e_aop_anno.\*.\*(..))")  指定切入点表达式**
- **@Before("pointCut_()")**			  前置通知: 目标方法之前执行
- **@After("pointCut_()")**				 后置通知：目标方法之后执行（始终执行）
- @AfterReturning("pointCut_()")   返回后通知： **执行方法结束前执行(异常不执行)**
- @AfterThrowing("pointCut_()")	异常通知:  出现异常时候执行
- @Around("pointCut_()")				环绕通知： 环绕目标方法执行

```
// 前置通知 : 在执行目标方法之前执行
@Before("pointCut_()")
public void begin(){
    System.out.println("开始事务/异常");
}
// 后置/最终通知：在执行目标方法之后执行  【无论是否出现异常最终都会执行】
@After("pointCut_()")
public void after(){
    System.out.println("提交事务/关闭");
}
// 返回后通知： 在调用目标方法结束后执行 【出现异常不执行】
@AfterReturning("pointCut_()")
public void afterReturning() {
    System.out.println("afterReturning()");
}
// 异常通知： 当目标方法执行异常时候执行此关注点代码
@AfterThrowing("pointCut_()")
public void afterThrowing(){
    System.out.println("afterThrowing()");
}
// 环绕通知：环绕目标方式执行
@Around("pointCut_()")
public void around(ProceedingJoinPoint pjp) throws Throwable{
    System.out.println("环绕前....");
    pjp.proceed();  // 执行目标方法
    System.out.println("环绕后....");
}
```

### 4.5表达式优化

我们的代码是这样的：**每次写Before、After等，都要重写一次切入点表达式，这样就不优雅了。**

```
@Before("execution(* com.*.*(..))")
public void begin() {
	System.out.println("开始事务");
}
@After("execution(* com.*.*(..))")
public void close() {
	System.out.println("关闭事务");
}
```

于是乎，我们要**使用@Pointcut这个注解，来指定切入点表达式，在用到的地方中，直接引用就行了！**

那么我们的代码就可以改造成这样了：

```
@Component
@Aspect//指定为切面类
public class AOP {
    // 指定切入点表达式，拦截哪个类的哪些方法
    @Pointcut("execution(* aa.*.*(..))")
    public void pt() {
    }
    @Before("pt()")
    public void begin() {
        System.out.println("开始事务");
    }
    @After("pt()")
    public void close() {
        System.out.println("关闭事务");
    }
}
```

------

### 4.6 XML方式实现AOP编程

XML文件配置

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:aop="http://www.springframework.org/schema/aop"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd">

    <!--对象实例-->
    <bean id="userDao" class="com.UserDao"/>
    <bean id="orderDao" class="com.OrderDao"/>
    <!--切面类-->
    <bean id="aop" class="com.AOP"/>
    <!--AOP配置-->
    <aop:config >
        <!--定义切入表达式，拦截哪些方法-->
        <aop:pointcut id="pointCut" expression="execution(* com.*.*(..))"/>
        <!--指定切面类是哪个-->
        <aop:aspect ref="aop">
            <!--指定来拦截的时候执行切面类的哪些方法-->
            <aop:before method="begin" pointcut-ref="pointCut"/>
            <aop:after method="close" pointcut-ref="pointCut"/>
        </aop:aspect>
    </aop:config>
</beans>
```

测试：

```
@Test
public void test1() {
    ApplicationContext ac = new ClassPathXmlApplicationContext("applicationContext.xml");
    OrderDao orderDao = (OrderDao) ac.getBean("orderDao");
    System.out.println(orderDao.getClass());
    orderDao.save();
}
@Test
public void test2() {
    ApplicationContext ac = new ClassPathXmlApplicationContext("applicationContext.xml");
    IUser userDao = (IUser) ac.getBean("userDao");
    System.out.println(userDao.getClass());
    userDao.save();
}
```

测试OrderDao

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212185248.png)

测试UserDao

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212185245.png)

------

## 5. 切入点表达式

切入点表达式主要就是来**配置拦截哪些类的哪些方法**

### 5.1 查官方文档

我们去文档中找找它的语法..

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212185302.png)

在文档中搜索:execution(

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212185304.png)

### 5.2语法解析

那么它的语法是这样子的：

```
execution(modifiers-pattern? ret-type-pattern declaring-type-pattern? name-pattern(param-pattern) throws-pattern?)

```

**符号讲解：**

- ?号代表0或1，可以不写
- “*”号代表任意类型，0或多
- 方法参数为..表示为可变参数

**参数讲解：**

- modifiers-pattern?【修饰的类型，可以不写】
- ret-type-pattern【方法返回值类型，必写】
- declaring-type-pattern?【方法声明的类型，可以不写】
- name-pattern(param-pattern)【要匹配的名称，括号里面是方法的参数】
- throws-pattern?【方法抛出的异常类型，可以不写】

官方也有给出一些例子给我们理解：

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212185335.png)

### 5.3 测试代码

```
    <!-- 【拦截所有public方法】 -->
    <!--<aop:pointcut expression="execution(public * *(..))" id="pt"/>-->
    
    <!-- 【拦截所有save开头的方法 】 -->
    <!--<aop:pointcut expression="execution(* save*(..))" id="pt"/>-->
    
    <!-- 【拦截指定类的指定方法, 拦截时候一定要定位到方法】 -->
    <!--<aop:pointcut expression="execution(public * cn.itcast.g_pointcut.OrderDao.save(..))" id="pt"/>-->
    
    <!-- 【拦截指定类的所有方法】 -->
    <!--<aop:pointcut expression="execution(* cn.itcast.g_pointcut.UserDao.*(..))" id="pt"/>-->
    
    <!-- 【拦截指定包，以及其自包下所有类的所有方法】 -->
    <!--<aop:pointcut expression="execution(* cn..*.*(..))" id="pt"/>-->
    
    <!-- 【多个表达式】 -->
    <!--<aop:pointcut expression="execution(* cn.itcast.g_pointcut.UserDao.save()) || execution(* cn.itcast.g_pointcut.OrderDao.save())" id="pt"/>-->
    <!--<aop:pointcut expression="execution(* cn.itcast.g_pointcut.UserDao.save()) or execution(* cn.itcast.g_pointcut.OrderDao.save())" id="pt"/>-->
    <!-- 下面2个且关系的，没有意义 -->
    <!--<aop:pointcut expression="execution(* cn.itcast.g_pointcut.UserDao.save()) &amp;&amp; execution(* cn.itcast.g_pointcut.OrderDao.save())" id="pt"/>-->
    <!--<aop:pointcut expression="execution(* cn.itcast.g_pointcut.UserDao.save()) and execution(* cn.itcast.g_pointcut.OrderDao.save())" id="pt"/>-->
    
    <!-- 【取非值】 -->
    <!--<aop:pointcut expression="!execution(* cn.itcast.g_pointcut.OrderDao.save())" id="pt"/>-->
```

# JDBCTemplate和Spring事务

## 1. 回顾对模版代码优化过程

我们来回忆一下我们怎么对模板代码进行优化的！

首先来看一下我们**原生的JDBC：需要手动去数据库的驱动从而拿到对应的连接**..

```
    try {
      String sql = "insert into t_dept(deptName) values('test');";
      Connection con = null;
      Statement stmt = null;
      Class.forName("com.mysql.jdbc.Driver");
      // 连接对象
      con = DriverManager.getConnection("jdbc:mysql:///hib_demo", "root", "root");
      // 执行命令对象
      stmt =  con.createStatement();
      // 执行
      stmt.execute(sql);
      // 关闭
      stmt.close();
      con.close();
    } catch (Exception e) {
      e.printStackTrace();
    }
```

因为JDBC是面向接口编程的，因此数据库的驱动都是由数据库的厂商给做到好了，我们**只要加载对应的数据库驱动，便可以获取对应的数据库连接**....因此，我们**写了一个工具类，专门来获取与数据库的连接(Connection)**,当然啦，为了更加灵活，我们的**工具类是读取配置文件的方式来做的**。

```
    private static String  driver = null;
    private static String  url = null;
    private static String  username = null;
    private static String password = null;
    static {
        try {
            //获取配置文件的读入流
            InputStream inputStream = UtilsDemo.class.getClassLoader().getResourceAsStream("db.properties");
            Properties properties = new Properties();
            properties.load(inputStream);
            //获取配置文件的信息
            driver = properties.getProperty("driver");
            url = properties.getProperty("url");
            username = properties.getProperty("username");
            password = properties.getProperty("password");
            //加载驱动类
            Class.forName(driver);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url,username,password);
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
```

经过上面一层的封装，我们可以**在使用的地方直接使用工具类来得到与数据库的连接...那么比原来就方便很多了！**但是呢，**每次还是需要使用Connection去创建一个Statement对象。并且无论是什么方法，其实就是SQL语句和传递进来的参数不同！**

于是我们可以使用**DBUtils**这样的组件来解决上面的问题

## 2. 使用Spring的JDBC

上面已经回顾了一下以前我们的JDBC开发了，那么看看Spring对JDBC又是怎么优化的

首先，想要使用Spring的JDBC模块，就必须引入两个jar文件：

- 引入jar文件(spring-jdbc依赖spring-tx)

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-jdbc</artifactId>
    <version>5.2.0.RELEASE</version>
</dependency>
```

首先还是看一下我们原生的JDBC代码：**获取Connection是可以抽取出来的，直接使用dataSource来得到Connection就行了**。

```
  public void save() {
    try {
      String sql = "insert into t_dept(deptName) values('test');";
      Connection con = null;
      Statement stmt = null;
      Class.forName("com.mysql.jdbc.Driver");
      // 连接对象
      con = DriverManager.getConnection("jdbc:mysql:///hib_demo", "root", "root");
      // 执行命令对象
      stmt =  con.createStatement();
      // 执行
      stmt.execute(sql);
      // 关闭
      stmt.close();
      con.close();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
```

值得注意的是，**JDBC对C3P0数据库连接池是有很好的支持的。因此我们直接可以使用Spring的依赖注入，在配置文件中配置dataSource就行了**！

```
  <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
    <property name="driverClass" value="com.mysql.jdbc.Driver"></property>
    <property name="jdbcUrl" value="jdbc:mysql:///hib_demo"></property>
    <property name="user" value="root"></property>
    <property name="password" value="root"></property>
    <property name="initialPoolSize" value="3"></property>
    <property name="maxPoolSize" value="10"></property>
    <property name="maxStatements" value="100"></property>
    <property name="acquireIncrement" value="2"></property>
  </bean>
  
  // IOC容器注入
  private DataSource dataSource;
  public void setDataSource(DataSource dataSource) {
    this.dataSource = dataSource;
  }
  public void save() {
    try {
      String sql = "insert into t_dept(deptName) values('test');";
      Connection con = null;
      Statement stmt = null;
      // 连接对象
      con = dataSource.getConnection();
      // 执行命令对象
      stmt =  con.createStatement();
      // 执行
      stmt.execute(sql);
      // 关闭
      stmt.close();
      con.close();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
```

**Spring来提供了JdbcTemplate这么一个类给我们使用！它封装了DataSource，也就是说我们可以在Dao中使用JdbcTemplate就行了。**

创建dataSource，创建jdbcTemplate对象

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:c="http://www.springframework.org/schema/c"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <property name="driverClass" value="com.mysql.jdbc.Driver"></property>
        <property name="jdbcUrl" value="jdbc:mysql:///zhongfucheng"></property>
        <property name="user" value="root"></property>
        <property name="password" value="root"></property>
        <property name="initialPoolSize" value="3"></property>
        <property name="maxPoolSize" value="10"></property>
        <property name="maxStatements" value="100"></property>
        <property name="acquireIncrement" value="2"></property>
    </bean>

    <!--扫描注解-->
    <context:component-scan base-package="bb"/>

    <!-- 2. 创建JdbcTemplate对象 -->
    <bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
        <property name="dataSource" ref="dataSource"></property>
    </bean>
</beans>
```

userDao

```
@Component
public class UserDao implements IUser {
    //使用Spring的自动装配
    @Autowired
    private JdbcTemplate template;
    @Override
    public void save() {
        String sql = "insert into user(name,password) values('zz','123')";
        template.update(sql);
    }
}
```

------

### 2.1 JdbcTemplate查询

我们要是使用JdbcTemplate查询会发现**有很多重载了query()方法**

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212185819.png)

一般地，**如果我们使用queryForMap()，那么只能封装一行的数据，如果封装多行的数据、那么就会报错**！并且，Spring是不知道我们想把一行数据封装成是什么样的，因此返回值是Map集合...我们得到Map集合的话还需要我们自己去转换成自己需要的类型。

 我们一般使用下面这个方法：

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212185826.png)

我们可以**实现RowMapper，告诉Spriing我们将每行记录封装成怎么样的**。

```
    public void query(String id) {
        String sql = "select * from USER where password=?";
        List<User> query = template.query(sql, new RowMapper<User>() {
            //将每行记录封装成User对象
            @Override
            public User mapRow(ResultSet resultSet, int i) throws SQLException {
                User user = new User();
                user.setName(resultSet.getString("name"));
                user.setPassword(resultSet.getString("password"));
                return user;
            }
        },id);
        System.out.println(query);
    }
```

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212185844.png)

------

当然了，一般我们都是**将每行记录封装成一个JavaBean对象的，因此直接实现RowMapper，在使用的时候创建就好了**。

```
  class MyResult implements RowMapper<Dept>{
    // 如何封装一行记录
    @Override
    public Dept mapRow(ResultSet rs, int index) throws SQLException {
      Dept dept = new Dept();
      dept.setDeptId(rs.getInt("deptId"));
      dept.setDeptName(rs.getString("deptName"));
      return dept;
    }
    
  }
```

## 3. 事务控制概述

下面主要讲解Spring的事务控制，如何使用Spring来对程序进行事务控制....

- **Spring的事务控制是属于Spring Dao模块的**。

一般地，我们**事务控制都是在service层做的**

**service层是业务逻辑层，service的方法一旦执行成功，那么说明该功能没有出错**。

事务控制分为两种：

- **编程式事务控制**
- **声明式事务控制**

### 3.1 编程式事务控制

**自己手动控制事务，就叫做编程式事务控制。**

- Jdbc代码：Conn.setAutoCommite(false);  // 设置手动控制事务
- Hibernate代码：Session.beginTransaction();    // 开启一个事务
- 特点：**细粒度的事务控制： 可以对指定的方法、指定的方法的某几行添加事务控制（比较灵活，但开发起来比较繁琐： 每次都要开启、提交、回滚.)**

### 3.2声明式事务控制

**Spring提供对事务的控制管理就叫做声明式事务控制**

Spring提供了对事务控制的实现。

- 如果用户想要使用Spring的事务控制，**只需要配置就行了**。
- 当不用Spring事务的时候，直接移除就行了。
- 特点：Spring的事务控制是**基于Spring AOP实现的**。因此它的**耦合度是非常低**的。【粗粒度的事务控制： **只能给整个方法应用事务，不可以对方法的某几行应用事务。**】(因为aop拦截的是方法。)

**Spring给我们提供了事务的管理器类**，事务管理器类又分为两种，因为**JDBC的事务和Hibernate的事务是不一样的**。

- Spring声明式事务管理器类：
  - Jdbc技术：DataSourceTransactionManager
  - Hibernate技术：HibernateTransactionManager

------

### 3.3 声明式事务控制教程

我们基于Spring的JDBC来做例子吧

引入相关jar包(如果用maven，那引入pom依赖就好了)

- **AOP相关的jar包【因为Spring的声明式事务控制是基于AOP的，那么就需要引入AOP的jar包。】**
- **引入tx名称空间**
- **引入AOP名称空间**
- **引入jdbcjar包【jdbc.jar包和tx.jar包】**

------

#### 3.3.1搭建配置环境

编写一个接口

```
public interface IUser {
    void save();
}
```

UserDao实现类，使用JdbcTemplate对数据库进行操作！

```
@Repository
public class UserDao implements IUser {
    //使用Spring的自动装配
    @Autowired
    private JdbcTemplate template;
    @Override
    public void save() {
        String sql = "insert into user(name,password) values('zhong','222')";
        template.update(sql);
    }
}
```

userService

```
@Service
public class UserService {
    @Autowired
    private UserDao userDao;
    public void save() {
        userDao.save();
    }
}
```

bean.xml配置：配置数据库连接池、jdbcTemplate对象、扫描注解

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:c="http://www.springframework.org/schema/c"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

    <!--数据连接池配置-->
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <property name="driverClass" value="com.mysql.jdbc.Driver"></property>
        <property name="jdbcUrl" value="jdbc:mysql:///zhongfucheng"></property>
        <property name="user" value="root"></property>
        <property name="password" value="root"></property>
        <property name="initialPoolSize" value="3"></property>
        <property name="maxPoolSize" value="10"></property>
        <property name="maxStatements" value="100"></property>
        <property name="acquireIncrement" value="2"></property>
    </bean>

    <!--扫描注解-->
    <context:component-scan base-package="bb"/>

    <!-- 2. 创建JdbcTemplate对象 -->
    <bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
        <property name="dataSource" ref="dataSource"></property>
    </bean>

</beans>
```

------

前面搭建环境的的时候，是没有任何的事务控制的。也就是说，**当我在service中调用两次userDao.save()，即时在中途中有异常抛出，还是可以在数据库插入一条记录的**。

Service代码：

```
@Service
public class UserService {
    @Autowired
    private UserDao userDao;
    public void save() {
        userDao.save();
        int i = 1 / 0;
        userDao.save();
    }
}

```

测试代码：

```
public class Test2 {
    @Test
    public void test33() {
        ApplicationContext ac = new ClassPathXmlApplicationContext("bb/bean.xml");
        UserService userService = (UserService) ac.getBean("userService");
        userService.save();
    }
}

```

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212190131.png)

------

#### 3.3.2XML方式实现声明式事务控制

首先，我们要配置事务的管理器类：因为JDBC和Hibernate的事务控制是不同的。

```
    <!--1.配置事务的管理器类:JDBC-->
    <bean id="txManage" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <!--引用数据库连接池-->
        <property name="dataSource" ref="dataSource"/>
    </bean>
```

再而，**配置事务管理器类如何管理事务**

```
    <!--2.配置如何管理事务-->
    <tx:advice id="txAdvice" transaction-manager="txManage">
        <!--配置事务的属性-->
        <tx:attributes>
            <!--所有的方法，并不是只读-->
            <tx:method name="*" read-only="false"/>
        </tx:attributes>
    </tx:advice>
```

最后，**配置拦截哪些方法，**

```
    <!--3.配置拦截哪些方法+事务的属性-->
    <aop:config>
        <aop:pointcut id="pt" expression="execution(* bb.UserService.*(..) )"/>
        <aop:advisor advice-ref="txAdvice" pointcut-ref="pt"></aop:advisor>
    </aop:config>
```

配置完成之后，service中的方法都应该被Spring的声明式事务控制了。因此我们再次测试一下：

```
@Test
public void test33() {
  ApplicationContext ac = new ClassPathXmlApplicationContext("bb/bean.xml");

  UserService userService = (UserService) ac.getBean("userService");
  userService.save();
}
```

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212190212.png)

------

#### 3.3.3 使用注解的方法实现事务控制

当然了，有的人可能觉得到XML文件上配置太多东西了。**Spring也提供了使用注解的方式来实现对事务控制**

第一步和XML的是一样的，**必须配置事务管理器类：**

```
    <!--1.配置事务的管理器类:JDBC-->
    <bean id="txManage" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <!--引用数据库连接池-->
        <property name="dataSource" ref="dataSource"/>
    </bean>
```

第二步：开启以注解的方式来实现事务控制

```
    <!--开启以注解的方式实现事务控制-->
    <tx:annotation-driven transaction-manager="txManage"/>
```

最后，**想要控制哪个方法事务，在其前面添加@Transactional这个注解就行了！**如果想要控制整个类的事务，那么在类上面添加就行了。

```
    @Transactional
    public void save() {
        userDao.save();
        int i = 1 / 0;
        userDao.save();
    }
```

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212190232.png)

## 4.事务属性

其实我们**在XML配置管理器类如何管理事务，就是在指定事务的属性！**我们来看一下事务的属性有什么：

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212190235.png)

### 4.1事务传播行为:

看了上面的事务属性，没有接触过的属性其实就这么一个：`propagation = Propagation.REQUIRED`事务的传播行为。

事务传播行为的属性有以下这么多个，常用的就只有两个：

- Propagation.REQUIRED【如果当前方法已经有事务了，**加入当前方法事务**】
- Propagation.REQUIRED_NEW【如果当前方法有事务了，当前方法事务会挂起。**始终开启一个新的事务**，直到新的事务执行完、当前方法的事务才开始】

![这里写图片描述](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212190300.png)

### 4.2 当事务传播行为是Propagation.REQUIRED

现在有一个日志类，它的事务传播行为是Propagation.REQUIRED

```
  Class Log{
      Propagation.REQUIRED  
      insertLog();  
  }
```

**现在，我要在保存之前记录日志**

```
  Propagation.REQUIRED
  Void  saveDept(){
    insertLog();   
    saveDept();
  }
```

**saveDept()本身就存在着一个事务，当调用insertLog()的时候，insertLog()的事务会加入到saveDept()事务中**

也就是说，**saveDept()方法内始终是一个事务，如果在途中出现了异常，那么insertLog()的数据是会被回滚的【因为在同一事务内】**

```
  Void  saveDept(){
    insertLog();    // 加入当前事务
    .. 异常, 会回滚
    saveDept();
  }
```

### 4.3当事务传播行为是Propagation.REQUIRED_NEW

现在有一个日志类，它的事务传播行为是Propagation.REQUIRED_NEW

```
  Class Log{
      Propagation.REQUIRED  
      insertLog();  
  }
```

**现在，我要在保存之前记录日志**

```
  Propagation.REQUIRED
  Void  saveDept(){
    insertLog();   
    saveDept();
  }
```

当执行到saveDept()中的insertLog()方法时，**insertLog()方法发现 saveDept()已经存在事务了，insertLog()会独自新开一个事务，直到事务关闭之后，再执行下面的方法**

**如果在中途中抛出了异常，insertLog()是不会回滚的，因为它的事务是自己的，已经提交了**

```
  Void  saveDept(){
    insertLog();    // 始终开启事务
    .. 异常, 日志不会回滚
    saveDept();
  }
```

# Spring事务原理

Spring事务管理我相信大家都用得很多，但可能仅仅局限于一个`@Transactional`注解或者在`XML`中配置事务相关的东西。不管怎么说，日常**可能**足够我们去用了。但作为程序员，无论是为了面试还是说更好把控自己写的代码，还是应该得多多了解一下Spring事务的一些细节。

这里我抛出几个问题，看大家能不能瞬间答得上：

- 如果**嵌套调用**含有事务的方法，在Spring事务管理中，这属于哪个知识点？
- 我们使用的框架可能是`Hibernate/JPA`或者是`Mybatis`，都知道的底层是需要一个`session/connection`对象来帮我们执行操作的。要保证事务的完整性，我们需要多组数据库操作要使用**同一个**`session/connection`对象，而我们又知道Spring IOC所管理的对象默认都是**单例**的，这为啥我们在使用的时候不会引发线程安全问题呢？内部Spring到底干了什么？
- 人家所说的BPP又是啥东西？
- Spring事务管理重要接口有哪几个？

## 一、阅读本文需要的基础知识

阅读这篇文章的同学我**默认**大家都对Spring事务相关知识有一定的了解了。(ps:如果不了解点解具体的文章去阅读再回到这里来哦)

我们都知道，Spring事务是Spring AOP的最佳实践之一，所以说[AOP入门基础知识(简单配置，使用)](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247483954&idx=1&sn=b34e385ed716edf6f58998ec329f9867&chksm=ebd74333dca0ca257a77c02ab458300ef982adff3cf37eb6d8d2f985f11df5cc07ef17f659d4&scene=21##wechat_redirect)是需要先知道的。如果想更加全面了解AOP可以看这篇文章：[AOP重要知识点(术语介绍、全面使用)](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484251&idx=1&sn=f792c5a1835af2c17f260be2055b5776&chksm=ebd7425adca0cb4cc3a4e2ee61bdfa99508ea564e4ba4fd4ed54054b12fed76694b2b3afc26e&scene=21##wechat_redirect)。说到AOP就不能不说[AOP底层原理：动态代理设计模式](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484222&idx=1&sn=5191aca33f7b331adaef11c5e07df468&chksm=ebd7423fdca0cb29cdc59b4c79afcda9a44b9206806d2212a1b807c9f5879674934c37c250a1&scene=21##wechat_redirect)。到这里，对AOP已经有一个基础的认识了。于是我们就可以[使用XML/注解方式来配置Spring事务管理](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247483965&idx=1&sn=2cd6c1530e3f81ca5ad35335755ed287&chksm=ebd7433cdca0ca2a70cb8419306eb9b3ccaa45b524ddc5ea549bf88cf017d6e5c63c45f62c6e&scene=21##wechat_redirect)。

在IOC学习中，可以知道的是[Spring中Bean的生命周期(引出BPP对象)](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484247&idx=1&sn=e228e29e344559e469ac3ecfa9715217&chksm=ebd74256dca0cb40059f3f627fc9450f916c1e1b39ba741842d91774f5bb7f518063e5acf5a0&scene=21##wechat_redirect)并且[IOC所管理的对象默认都是单例的：单例设计模式](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484239&idx=1&sn=6560be96e456b513cb1e4f78a740a258&chksm=ebd7424edca0cb584906fb97679cf2ca557f430fbc87d2c86ce0652d2e3c36c2528466942df5&scene=21##wechat_redirect)，单例对象如果有"**状态**"(有成员变量)，那么多线程访问这个单例对象，可能就造成线程不安全。那么[何为线程安全？](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484194&idx=1&sn=ed1241fcba5d3e85b6d900d8667f04f6&chksm=ebd74223dca0cb35fe16a267c88ac9e5159825b27c278fb165a8c50d681e1340b73cfd69ae0d&scene=21##wechat_redirect)，解决线程安全有很多方式，但其中有一种：[让每一个线程都拥有自己的一个变量：ThreadLocal](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484118&idx=1&sn=da3e4c4cfd0642687c5d7bcef543fe5b&chksm=ebd743d7dca0cac19a82c7b29b5b22c4b902e9e53bd785d066b625b4272af2a6598a0cc0f38e&scene=21##wechat_redirect)

> 如果对我以上说的知识点不太了解的话，建议点击蓝字进去学习一番。

## 二、两个不靠谱直觉的例子

### 2.1第一个例子

在Service层抛出Exception，在Controller层捕获，那如果在Service中有异常，那会事务回滚吗？

```
// Service方法
@Transactional
public Employee addEmployee() throws Exception {
    Employee employee = new Employee("3y", 23);
    employeeRepository.save(employee);
  // 假设这里出了Exception
    int i = 1 / 0;
    return employee;
}

// Controller调用
@RequestMapping("/add")
public Employee addEmployee() {
    Employee employee = null;
    try {
        employee = employeeService.addEmployee();
    } catch (Exception e) {
        e.printStackTrace();
    }
    return employee;
}
```

可以回滚

![发生了运行时Exception，Spring事务管理自动回滚](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212190459.png)

看了一下文档，原来文档有说明：

> By default checked exceptions do not result in the transactional interceptor marking the transaction for rollback and instances of RuntimeException and its  subclasses do

结论：如果是编译时异常不会自动回滚，**如果是运行时异常，那会自动回滚**！

### 2.2第二个例子

> 第二个例子来源于知乎@柳树文章，文末会给出相应的URL

我们都知道，带有`@Transactional`注解所包围的方法就能被Spring事务管理起来，那如果我在**当前类下使用一个没有事务的方法去调用一个有事务的方法**，那我们这次调用会怎么样？是否会有事务呢？

用代码来描述一下：

```
// 没有事务的方法去调用有事务的方法
public Employee addEmployee2Controller() throws Exception {
    return this.addEmployee();
}

@Transactional
public Employee addEmployee() throws Exception {
    employeeRepository.deleteAll();
    Employee employee = new Employee("3y", 23);
    // 模拟异常
    int i = 1 / 0;
    return employee;
}
```

我第一直觉是：这跟Spring事务的传播机制有关吧。

其实这跟Spring事务的传播机制**没有关系**，下面我讲述一下：

- Spring事务管理用的是AOP，AOP底层用的是动态代理。所以如果我们在类或者方法上标注注解`@Transactional`，那么会生成一个**代理对象**。

接下来我用图来说明一下：

![Spring会自动生成代理对象](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212190538.png)

显然地，我们拿到的是代理(Proxy)对象，调用`addEmployee2Controller()`方法，而`addEmployee2Controller()`方法的逻辑是`target.addEmployee()`，调用回原始对象(target)的`addEmployee()`。所以这次的调用**压根就没有事务存在**，更谈不上说Spring事务传播机制了。

原有的数据：

![原有的数据](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212190603.png)

测试结果：压根就没有事务的存在

![没有事务的存在](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212190605.png)

#### 2.2.1再延伸一下

从上面的测试我们可以发现：如果是在本类中没有事务的方法来调用标注注解`@Transactional`方法，最后的结论是没有事务的。那如果我将这个标注注解的方法**移到**别的Service对象上，有没有事务？

```
@Service
public class TestService {
    @Autowired
    private EmployeeRepository employeeRepository;
    @Transactional
    public Employee addEmployee() throws Exception {
        employeeRepository.deleteAll();
        Employee employee = new Employee("3y", 23);
        // 模拟异常
        int i = 1 / 0;
        return employee;
    }
}


@Service
public class EmployeeService {
    @Autowired
    private TestService testService;
    // 没有事务的方法去调用别的类有事务的方法
    public Employee addEmployee2Controller() throws Exception {
        return testService.addEmployee();
    }
}
```

测试结果：

![抛出了运行时异常，但我们的数据还是存在的！](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212190946.png)

因为我们用的是代理对象(Proxy)去调用`addEmployee()`方法，那就当然有事务了。

## 三、Spring事务传播机制

> 如果**嵌套调用**含有事务的方法，在Spring事务管理中，这属于哪个知识点？

在当前**含有事务方法内部调用其他的方法**(无论该方法是否含有事务)，这就属于Spring事务传播机制的知识点范畴了。

Spring事务基于Spring AOP，Spring AOP底层用的动态代理，动态代理有两种方式：

- 基于接口代理(JDK代理)
  - 基于接口代理，凡是类的方法**非public修饰**，或者**用了static关键字**修饰，那这些方法都不能被Spring AOP增强
- 基于CGLib代理(子类代理)
  - 基于子类代理，凡是类的方法**使用了private、static、final修饰**，那这些方法都不能被Spring AOP增强

> 至于为啥以上的情况不能增强，用你们的脑瓜子想一下就知道了。

值得说明的是：那些不能被Spring AOP增强的方法**并不是不能**在事务环境下工作了。只要它们**被外层的事务方法调用了**，由于Spring事务管理的传播级别，内部方法也可以**工作**在外部方法所启动的**事务上下文中**。

> 至于Spring事务传播机制的几个级别，我在这里就不贴出来了。这里只是再次解释“啥情况才是属于Spring事务传播机制的范畴”。

## 四、多线程问题

> 我们使用的框架可能是`Hibernate/JPA`或者是`Mybatis`，都知道的底层是需要一个`session/connection`对象来帮我们执行操作的。要保证事务的完整性，我们需要**多组数据库操作要使用同一个**`session/connection`对象，而我们又知道Spring IOC所管理的对象默认都是**单例**的，这为啥我们在使用的时候不会引发线程安全问题呢？内部Spring到底干了什么？

回想一下当年我们学Mybaits的时候，是怎么编写[Session工具类](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247483937&idx=2&sn=28c7827639bb6ac0296746c4c4343c59&chksm=ebd74320dca0ca36b763b3975665fc38a7e921f9ecaef1aaea3a7c757063a29222cd00b3d3b6&scene=21##wechat_redirect)？

![Mybatis工具类部分代码截图](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191317.png)

没错，用的就是ThreadLocal，同样地，Spring也是用的ThreadLocal。

以下内容来源《精通 Spring4.x》

> 我们知道在一般情况下，只有无状态的Bean才可以在多线程环境下共享，在Spring中，绝大部分Bean都可以声明为singleton作用域。就是因为Spring对一些Bean（如RequestContextHolder、**TransactionSynchronizationManager**、LocaleContextHolder等）中非线程安全状态的“状态性对象”采用ThreadLocal封装，让它们也成为线程安全的“状态性对象”，因此，有状态的Bean就能够以singleton的方式在多线程中工作。

我们可以试着点一下进去TransactionSynchronizationManager中看一下：

![全都是ThreadLocal](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191338.png)

## 五、啥是BPP？

BBP的全称叫做：BeanPostProcessor，一般我们俗称**对象后处理器**

- 简单来说，通过BeanPostProcessor可以对我们的对象进行“**加工处理**”。

Spring管理Bean(或者说Bean的生命周期)也是一个**常考**的知识点，我在秋招也**重新**整理了一下步骤，因为比较重要，所以还是在这里贴一下吧：

1. ResouceLoader加载配置信息
2. BeanDefintionReader解析配置信息，生成一个一个的BeanDefintion
3. BeanDefintion由BeanDefintionRegistry管理起来
4. BeanFactoryPostProcessor对配置信息进行加工(也就是处理配置的信息，一般通过PropertyPlaceholderConfigurer来实现)
5. 实例化Bean
6. 如果该Bean`配置/实现`了InstantiationAwareBean，则调用对应的方法
7. 使用BeanWarpper来完成对象之间的属性配置(依赖)
8. 如果该Bean`配置/实现了`Aware接口，则调用对应的方法
9. 如果该Bean配置了BeanPostProcessor的before方法，则调用
10. 如果该Bean配置了`init-method`或者实现InstantiationBean，则调用对应的方法
11. 如果该Bean配置了BeanPostProcessor的after方法，则调用
12. 将对象放入到HashMap中
13. 最后如果配置了destroy或者DisposableBean的方法，则执行销毁操作

![Application中Bean的声明周期](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191349.png)

其中也有关于BPP图片：

![BBP所在的位置](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191352.jpeg)

### 5.1为什么特意讲BPP？

Spring AOP编程底层通过的是动态代理技术，在调用的时候肯定用的是**代理对象**。那么Spring是怎么做的呢？

> 我只需要写一个BPP，在postProcessBeforeInitialization或者postProcessAfterInitialization方法中，对对象进行判断，看他需不需要织入切面逻辑，如果需要，那我就根据这个对象，生成一个代理对象，然后返回这个代理对象，那么最终注入容器的，自然就是代理对象了。

Spring提供了BeanPostProcessor，就是让我们可以对有需要的对象进行“**加工处理**”啊！

## 六、认识Spring事务几个重要的接口

Spring事务可以分为两种：

- 编程式事务(通过代码的方式来实现事务)
- 声明式事务(通过配置的方式来实现事务)

编程式事务在Spring实现相对简单一些，而声明式事务因为封装了大量的东西(一般我们使用简单，里头都非常复杂)，所以声明式事务实现要难得多。

在编程式事务中有以下几个重要的了接口：

- TransactionDefinition：定义了Spring兼容的**事务属性**(比如事务隔离级别、事务传播、事务超时、是否只读状态)
- TransactionStatus：代表了事务的具体**运行状态**(获取事务运行状态的信息，也可以通过该接口**间接**回滚事务等操作)
- PlatformTransactionManager：事务管理器接口(定义了一组行为，具体实现交由不同的持久化框架来完成---**类比**JDBC)

![PlatformTransactionManager解析](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191359.png)

在声明式事务中，除了TransactionStatus和PlatformTransactionManager接口，还有几个重要的接口：

- TransactionProxyFactoryBean：生成代理对象
- TransactionInterceptor：实现对象的拦截
- TransactionAttrubute：事务配置的数据

# Spring事务的一个线程安全问题

该问题来源知乎(synchronized锁问题)：

- https://www.zhihu.com/question/277812143

> 开启10000个线程，每个线程给员工表的money字段【初始值是0】加1，没有使用悲观锁和乐观锁，但是在业务层方法上加了synchronized关键字，问题是代码执行完毕后数据库中的money 字段不是10000，而是小于10000 问题出在哪里？

Service层代码：

![代码](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191459.jpeg)

SQL代码(没有加悲观/乐观锁)：

![SQL代码(没有加悲观/乐观锁)](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191502.jpeg)

用1000个线程跑代码：

![用1000个线程跑代码：](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191506.jpeg)

简单来说：多线程跑一个使用**synchronized**关键字修饰的方法，方法内操作的是数据库，按正常逻辑应该最终的值是1000，但经过多次测试，结果是**低于**1000。这是为什么呢？

## 一、我的思考

既然测试出来的结果是低于1000，那说明这段代码**不是线程安全**的。不是线程安全的，那问题出现在哪呢？众所周知，synchronized方法能够保证所修饰的`代码块、方法`保证`有序性、原子性、可见性`。

讲道理，以上的代码跑起来，问题中`Service`层的`increaseMoney()`是`有序的、原子的、可见的`，所以**断定**跟synchronized应该没关系。

(参考我之前写过的synchronize锁笔记：[Java锁机制了解一下](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484198&idx=1&sn=4d8e372165bb49987a6243f17153a9b4&chksm=ebd74227dca0cb31311886f835092c9360d08a9f0a249ece34d4b1e49a31c9ec773fa66c8acc&scene=21#wechat_redirect))

既然Java层面上找不到原因，那分析一下数据库层面的吧(因为方法内操作的是数据库)。在`increaseMoney()`方法前加了`@Transcational`注解，说明这个方法是带有**事务**的。事务能保证同组的SQL要么同时成功，要么同时失败。讲道理，如果没有报错的话，应该每个线程都对money值进行`+1`。从理论上来说，结果应该是1000的才对。

(参考我之前写过的Spring事务：[一文带你看懂Spring事务！](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484721&idx=5&sn=67467f35a9e9314aa3d1c07ff250af6b&chksm=ebd74430dca0cd26c94daf2d3e34806c29d05583de2255b98d20d34cd86e12ae94624d33be1b&token=1885756144&lang=zh_CN#rd))

根据上面的分析，我怀疑是**提问者没测试好**(hhhh，逃)，于是我也跑去测试了一下，发现是以提问者的方式来使用**是真的有问题**。

首先贴一下我的测试代码：

```
@RestController
public class EmployeeController {
    @Autowired
    private EmployeeService employeeService;
    @RequestMapping("/add")
    public void addEmployee() {
        for (int i = 0; i < 1000; i++) {
            new Thread(() -> employeeService.addEmployee()).start();
        }
    }
}

@Service
public class EmployeeService {
    @Autowired
    private EmployeeRepository employeeRepository;
    @Transactional
    public synchronized void addEmployee() {
        // 查出ID为8的记录，然后每次将年龄增加一
        Employee employee = employeeRepository.getOne(8);
        System.out.println(employee);
        Integer age = employee.getAge();
        employee.setAge(age + 1);
        employeeRepository.save(employee);
    }
}
```

简单地打印了每次拿到的employee值，并且拿到了SQL执行的顺序，如下(贴出小部分)：

![SQL执行的顺序](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191616.png)

从打印的情况我们可以得出：多线程情况下并**没有串行**执行`addEmployee()`方法。这就导致对同一个值做**重复**的修改，所以最终的数值比1000要少。

## 二、图解出现的原因

发现并不是**同步**执行的，于是我就怀疑`synchronized`关键字和Spring肯定有点冲突。于是根据这两个关键字搜了一下，找到了问题所在。

我们知道Spring事务的底层是Spring AOP，而Spring AOP的底层是动态代理技术。跟大家一起回顾一下动态代理：

```
    public static void main(String[] args) {
        // 目标对象
        Object target ;
        Proxy.newProxyInstance(ClassLoader.getSystemClassLoader(), Main.class, new InvocationHandler() {
            @Override
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                // 但凡带有@Transcational注解的方法都会被拦截
                // 1... 开启事务
                method.invoke(target);
                // 2... 提交事务
                return null;
            }
        });
    }
```

(详细请参考我之前写过的动态代理：[给女朋友讲解什么是代理模式](https://mp.weixin.qq.com/s?__biz=MzI4Njg5MDA5NA==&mid=2247484222&idx=1&sn=5191aca33f7b331adaef11c5e07df468&chksm=ebd7423fdca0cb29cdc59b4c79afcda9a44b9206806d2212a1b807c9f5879674934c37c250a1&scene=21#wechat_redirect))

实际上Spring做的处理跟以上的思路是一样的，我们可以看一下TransactionAspectSupport类中`invokeWithinTransaction()`：

![Spring事务管理是如何实现的](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191651.png)

调用方法**前**开启事务，调用方法**后**提交事务

![Spring事务和synchronized锁互斥问题](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191655.png)

在多线程环境下，就可能会出现：**方法执行完了(synchronized代码块执行完了)，事务还没提交，别的线程可以进入被synchronized修饰的方法，再读取的时候，读到的是还没提交事务的数据，这个数据不是最新的**，所以就出现了这个问题。

![事务未提交，别的线程读取到旧数据](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191700.png)

## 三、解决问题

从上面我们可以发现，问题所在是因为`@Transcational`注解和`synchronized`一起使用了，**加锁的范围没有包括到整个事务**。所以我们可以这样做：

新建一个名叫SynchronizedService类，让其去调用`addEmployee()`方法，整个代码如下：

```
@RestController
public class EmployeeController {
    @Autowired
    private SynchronizedService synchronizedService ;
    @RequestMapping("/add")
    public void addEmployee() {
        for (int i = 0; i < 1000; i++) {
            new Thread(() -> synchronizedService.synchronizedAddEmployee()).start();
        }
    }
}

// 新建的Service类
@Service
public class SynchronizedService {
    @Autowired
    private EmployeeService employeeService ;
    // 同步
    public synchronized void synchronizedAddEmployee() {
        employeeService.addEmployee();
    }
}

@Service
public class EmployeeService {
    @Autowired
    private EmployeeRepository employeeRepository;
    @Transactional
    public void addEmployee() {
        // 查出ID为8的记录，然后每次将年龄增加一
        Employee employee = employeeRepository.getOne(8);
        System.out.println(Thread.currentThread().getName() + employee);
        Integer age = employee.getAge();
        employee.setAge(age + 1);
        employeeRepository.save(employee);
    }
}
```

我们将synchronized锁的范围**包含到整个Spring事务上**，这就不会出现线程安全的问题了。在测试的时候，我们可以发现1000个线程跑起来**比之前要慢得多**，当然我们的数据是正确的：

![正确的数据](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201212191715.png)