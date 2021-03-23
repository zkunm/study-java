# 1、Spring概念

Spring 是一个简化 java 企业级开发的一个框架，内部包含了很多技术，比如：控制反转 & 依赖注入、面向切面编程、spring 事务管理、通过 spring 集成其他框架、springmvc、springboot、springcloud 等等，这些都是围绕简化开发展开的技术

springboot 让我们更关注业务代码的实现，从而最大限度的帮我们提升开发效率，简化项目的开发过程。

# 2、控制反转（IOC）与依赖注入（DI）

Spring 中有 3 个核心的概念：**控制反转 (IOC)、依赖注入 (DI)、面向切面编程 (AOP)**，spring 中其他的技术都是依靠 3 个核心的技术建立起来的

### spring 容器

spring 容器的概念，容器这个名字起的相当好，容器可以放很多东西，我们的程序启动的时候会创建 spring 容器，会给 spring 容器一个清单，清单中列出了需要创建的对象以及对象依赖关系，spring 容器会创建和组装好清单中的对象，然后将这些对象存放在 spring 容器中，当程序中需要使用的时候，可以到容器中查找获取，然后直接使用。

### IOC：控制反转

使用者之前使用一个对象的时候都需要自己去创建和组装，而现在这些创建和组装都交给 spring 容器去给完成了，使用者只需要去 spring 容器中查找需要使用的对象就可以了；这个过程中这个对象的创建和组装过程被反转了，之前是使用者自己主动去控制的，现在交给 spring 容器去创建和组装了，对象的构建过程被反转了，所以叫做控制反转；IOC 是是面相对象编程中的一种设计原则，主要是为了降低系统代码的耦合度，让系统利于维护和扩展。

### DI：依赖注入

依赖注入是 spring 容器中创建对象时给其设置依赖对象的方式，比如给 spring 一个清单，清单中列出了需要创建 B 对象以及其他的一些对象（可能包含了 B 类型中需要依赖对象），此时 spring 在创建 B 对象的时候，会看 B 对象需要依赖于哪些对象，然后去查找一下清单中有没有包含这些被依赖的对象，如果有就去将其创建好，然后将其传递给 B 对象；可能 B 需要依赖于很多对象，B 创建之前完全不需要知道其他对象是否存在或者其他对象在哪里以及被他们是如何创建，而 spring 容器会将 B 依赖对象主动创建好并将其注入到 B 中去，比如 spring 容器创建 B 的时候，发现 B 需要依赖于 A，那么 spring 容器在清单中找到 A 的定义并将其创建好之后，注入到 B 对象中。

### 总结

1. IOC 控制反转，是一种设计理念，将对象创建和组装的主动控制权利交给了 spring 容器去做，控制的动作被反转了，降低了系统的耦合度，利于系统维护和扩展，**主要就是指需要使用的对象的组装控制权被反转了，之前是自己要做的，现在交给 spring 容器做了**。
2. DI 依赖注入，表示 spring 容器中创建对象时给其设置依赖对象的方式，通过某些注入方式可以让系统更灵活，比如自动注入等可以让系统变的很灵活，这个后面的文章会细说。
3. spring 容器：主要负责容器中对象的创建、组装、对象查找、对象生命周期的管理等等操作。

# 3 、Spring 容器基本使用及原理

### IOC 容器

IOC 容器是具有依赖注入功能的容器，负责**对象的实例化、对象的初始化，对象和对象之间依赖关系配置、对象的销毁、对外提供对象的查找**等操作，对象的整个生命周期都是由容器来控制。我们需要使用的对象都由 ioc 容器进行管理，不需要我们再去手动通过 new 的方式去创建对象，由 ioc 容器直接帮我们组装好，当我们需要使用的时候直接从 ioc 容器中直接获取就可以了。

**那么 spring ioc 容器是如何知道需要管理哪些对象呢？**

需要我们给 ioc 容器提供一个配置清单，这个配置**支持 xml 格式**和 **java 注解的方式**，在配置文件中列出需要让 ioc 容器管理的对象，以及可以指定让 ioc 容器如何构建这些对象，当 spring 容器启动的时候，就会去加载这个配置文件，然后将这些对象给组装好以供外部访问者使用。

这里所说的 IOC 容器也叫 spring 容器。

### Bean 概念

由 spring 容器管理的对象统称为 Bean 对象。Bean 就是普通的 java 对象，和我们自己 new 的对象其实是一样的，只是这些对象是由 spring 去创建和管理的，我们需要在配置文件中告诉 spring 容器需要创建哪些 bean 对象，所以需要先在配置文件中定义好需要创建的 bean 对象，这些配置统称为 bean 定义配置元数据信息，spring 容器通过读取这些 bean 配置元数据信息来构建和组装我们需要的对象。

### Spring 容器使用步骤

1. 引入 spring 相关的 maven 配置
2. 创建 bean 配置文件，比如 bean xml 配置文件
3. 在 bean xml 文件中定义好需要 spring 容器管理的 bean 对象
4. 创建 spring 容器，并给容器指定需要装载的 bean 配置文件，当 spring 容器启动之后，会加载这些配置文件，然后创建好配置文件中定义好的 bean 对象，将这些对象放在容器中以供使用
5. 通过容器提供的方法获取容器中的对象，然后使用

### Spring 容器对象

spring 内部提供了很多表示 spring 容器的接口和对象，我们来看看比较常见的几个容器接口和具体的实现类。

#### BeanFactory 接口

```
org.springframework.beans.factory.BeanFactory
```

spring 容器中具有代表性的容器就是 BeanFactory 接口，这个是 spring 容器的顶层接口，提供了容器最基本的功能。

##### 常用的几个方法

```
//按bean的id或者别名查找容器中的bean
Object getBean(String name) throws BeansException

//这个是一个泛型方法，按照bean的id或者别名查找指定类型的bean，返回指定类型的bean对象
<T> T getBean(String name, Class<T> requiredType) throws BeansException;

//返回容器中指定类型的bean对象
<T> T getBean(Class<T> requiredType) throws BeansException;

//获取指定类型bean对象的获取器，这个方法比较特别
<T> ObjectProvider<T> getBeanProvider(Class<T> requiredType);
```

#### ApplicationContext 接口

```
org.springframework.context.ApplicationContext
```

这个接口继承了 BeanFactory 接口，所以内部包含了 BeanFactory 所有的功能，并且在其上进行了扩展，增加了很多企业级功能，比如 AOP、国际化、事件支持等等

#### ClassPathXmlApplicationContext 类

```
org.springframework.context.support.ClassPathXmlApplicationContext
```

这个类实现了 ApplicationContext 接口，注意一下这个类名称包含了 ClassPathXml，说明这个容器类可以从 classpath 中加载 bean xml 配置文件，然后创建 xml 中配置的 bean 对象

#### AnnotationConfigApplicationContext 类

```
org.springframework.context.annotation.AnnotationConfigApplicationContext
```

这个类也实现了 ApplicationContext 接口，注意其类名包含了 Annotation 和 config 两个单词，上面我们有说过，bean 的定义支持 xml 的方式和注解的方式，当我们使用注解的方式定义 bean 的时候，就需要用到这个容器来装载了，这个容器内部会解析注解来构建构建和管理需要的 bean。

### 案例

创建项目 spring-parent

使用 idea 创建 maven 项目 spring-parent，项目坐标：

```
<groupId>com.zkunm</groupId>
<artifactId>spring-parent</artifactId>
<version>1.0-SNAPSHOT</version>
<packaging>pom</packaging>
```

spring-parent 项目中创建一个子模块`spring-001`

spring-parent/pom.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.zkunm</groupId>
    <artifactId>spring-parent</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
        <spring.version>5.2.0.RELEASE</spring.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework</groupId>
                <artifactId>spring-core</artifactId>
                <version>${spring.version}</version>
            </dependency>
            <dependency>
                <groupId>org.springframework</groupId>
                <artifactId>spring-context</artifactId>
                <version>${spring.version}</version>
            </dependency>
            <dependency>
                <groupId>org.springframework</groupId>
                <artifactId>spring-beans</artifactId>
                <version>${spring.version}</version>
            </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```

使用 spring 的版本`5.2.0.RELEASE`，需要引入 spring 提供的 3 个构件

```
spring-core、spring-context、spring-beans
```

spring-001\pom.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-parent</artifactId>
        <groupId>com.zkunm</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>spring-001</artifactId>

    <properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-beans</artifactId>
        </dependency>
    </dependencies>
</project>
```

spring-001 中创建 HelloWord 类

```
public class HelloWorld {
    public void say() {
        System.out.println("Hello world");
    }
}
```

使用 spring 容器

下面我们通过 spring 容器来创建 HelloWord 对象，并从容器中获取这个对象，然后调用其 say 方法输出文字。

创建 bean xml 配置文件

bean.xml 内容如下：

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
    <!--
    定义一个bean
    id：bean的唯一标识，可以通过这个标识从容器中获取这个bean对象
    class：这个bean的类型，完整类名称
    -->
    <bean id="helloWorld" class="com.zkunm.spring001.demo1.HelloWorld"/>
</beans>
```

上面就是 bean 的定义文件，每个 xml 中可以定义多个 bean 元素，通过 bean 元素定义需要 spring 容器管理的对象，bean 元素需指定 id 和 class 属性

- id 表示这个 bean 的标识，在容器中需要唯一，可以通过这个 id 从容器中获取这个对象；
- class 用来指定这个 bean 的完整类名

上面的配置文件中我们定义了一个`helloWorld`标识的`HellWorld类型`的 bean 对象。

创建测试类

创建一个 Client 类，如下：

```
public class Client {
    public static void main(String[] args) {
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("bean.xml");
        HelloWorld helloWorld = context.getBean("helloWorld", HelloWorld.class);
        helloWorld.say();
    }
}
```

上面 main 方法中有容器的详细使用步骤，需要先创建容器对象，创建容器的对象的时候需要指定 bean xml 文件的位置，容器启动之后会加载这些配文件，然后将这些对象构建好。

代码中通过容器提供的 getBean 方法从容器中获取了 HellWorld 对象，第一个参数就是 xml 中 bean 的 id，第二个参数为 bean 对应的 Class 对象。

运行输出

![image-20201213105751330](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213105751.png)

# 4 、xml 中 bean 定义详解 

### bean xml 配置文件格式

bean xml 文件用于定义 spring 容器需要管理的 bean，常见的格式如下：

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd">

    <import resource="引入其他bean xml配置文件" />
    <bean id="bean标识" class="玩转类型名称"/>
    <alias name="bean标识" alias="别名" />
</beans>
```

beans 是根元素，下面可以包含任意数量的 import、bean、alias 元素，下面我们对每个元素进行详解。

### bean 元素

用来定义一个 bean 对象

```
<bean id="bean唯一标识" name="bean名称" class="完整类型名称" factory-bean="工厂bean名称" factory-method="工厂方法"/>
```

#### bean 名称

每个 bean 都有一个名称，叫做 bean 名称，bean 名称在一个 spring 容器中必须唯一，否则会报错，通过 bean 名称可以从 spring 容器获取对应的 bean 对象。

#### bean 别名

先来说一下什么是别名？

相当于人的外号一样，一个人可能有很多外号，当别人喊这个人的名称或者外号的时候，都可以找到这个人。那么 bean 也一样，也可以给 bean 起几个外号，这个外号在 spring 中叫做 bean 的别名，spring 容器允许使用者通过名称或者别名获取对应的 bean 对象。

#### bean 名称别名定义规则

名称和别名可以通过 bean 元素中的 id 和 name 来定义，具体定义规则如下：：

1. 当 id 存在的时候，不管 name 有没有，取 id 为 bean 的名称
2. 当 id 不存在，此时需要看 name，name 的值可以通过`,;或者空格`分割，最后会按照分隔符得到一个 String 数组，数组的第一个元素作为 bean 的名称，其他的作为 bean 的别名
3. 当 id 和 name 都存在的时候，id 为 bean 名称，name 用来定义多个别名
4. 当 id 和 name 都不指定的时候，bean 名称自动生成，生成规则下面详细说明

getAliases：通过 bean 名称获取这个 bean 的所有别名

getBeanDefinitionNames：返回 spring 容器中定义的所有 bean 的名称

#### id 和 name 都未指定

当 id 和 name 都未指定的时候，bean 的名称和别名又是什么呢？此时由 spring 自动生成，bean 名称为：

```
bean的class的完整类名#编号
```

上面的编号是从 0 开始的，同种类型的没有指定名称的依次递增。

### alias 元素

alias 元素也可以用来给某个 bean 定义别名，语法：

```
<alias name="需要定义别名的bean" alias="别名" />
```

### import 元素

当我们的系统比较大的时候，会分成很多模块，每个模块会对应一个 bean xml 文件，我们可以在一个总的 bean xml 中对其他 bean xml 进行汇总，相当于把多个 bean xml 的内容合并到一个里面了，可以通过 import 元素引入其他 bean 配置文件。

语法：

```
<import resource="其他配置文件的位置" />
```

# 5 、创建 bean 实例的方式

1. 通过反射调用构造方法创建 bean 对象
2. 通过静态工厂方法创建 bean 对象
3. 通过实例工厂方法创建 bean 对象
4. 通过 FactoryBean 创建 bean 对象

Spring 容器内部创建 bean 实例对象常见的有 4 种方式。

### 通过反射调用构造方法创建 bean 对象

调用类的构造方法获取对应的 bean 实例，是使用最多的方式，这种方式只需要在 xml bean 元素中指定 class 属性，spring 容器内部会自动调用该类型的构造方法来创建 bean 对象，将其放在容器中以供使用。

```
<bean id="bean名称" name="bean名称或者别名" class="bean的完整类型名称">
    <constructor-arg index="0" value="bean的值" ref="引用的bean名称" />
    <constructor-arg index="1" value="bean的值" ref="引用的bean名称" />
    <constructor-arg index="2" value="bean的值" ref="引用的bean名称" />
    ....
    <constructor-arg index="n" value="bean的值" ref="引用的bean名称" />
</bean>
```

constructor-arg 用于指定构造方法参数的值

index：构造方法中参数的位置，从 0 开始，依次递增

value：指定参数的值

ref：当插入的值为容器内其他 bean 的时候，这个值为容器中对应 bean 的名称

#### 案例

**UserModel 类**

```
@Getter
@Setter
@ToString
public class UserModel {
    private String name;
    private int age;
    public UserModel() {
        this.name = "我是通过UserModel的无参构造方法创建的!";
    }
    public UserModel(String name, int age) {
        this.name = name;
        this.age = age;
    }
}
```

**beans.xml 配置**

```
<!-- 通过UserModel的默认构造方法创建UserModel对象 -->
<bean id="createBeanByConstructor1" class="com.zkunm.spring001.UserModel"/>
<!-- 通过UserModel有参构造方法创建UserModel对象 -->
<bean id="createBeanByConstructor2" class="com.zkunm.spring001.UserModel">
    <constructor-arg index="0" value="我是通过UserModel的有参方法构造的对象!"/>
    <constructor-arg index="1" value="30"/>
</bean>
```

上面这 2 种写法，spring 容器创建这两个 UserModel 的时候，都会通过反射的方式去调用 UserModel 类中对应的构造函数来创建 UserModel 对象。

**测试用例**

```
public class Client {
    public static void main(String[] args) {
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("bean.xml");
        System.out.println("spring容器中所有bean如下：");
        for (String beanName : context.getBeanDefinitionNames()) {
            System.out.println(beanName + ":" + context.getBean(beanName));
        }
    }
}
```

代码中会输出 spring 容器中所有 bean 的名称和其对应的 bean 对象。

**运行输出**

![image-20201213112225809](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213112225.png)

### 通过静态工厂方法创建 bean 对象

我们可以创建静态工厂，内部提供一些静态方法来生成所需要的对象，将这些静态方法创建的对象交给 spring 以供使用。

```
<bean id="bean名称" name="" class="静态工厂完整类名" factory-method="静态工厂的方法">
    <constructor-arg index="0" value="bean的值" ref="引用的bean名称" />
    <constructor-arg index="1" value="bean的值" ref="引用的bean名称" />
    <constructor-arg index="2" value="bean的值" ref="引用的bean名称" />
    ....
    <constructor-arg index="n" value="bean的值" ref="引用的bean名称" />
</bean>
```

class：指定静态工厂完整的类名

factory-method：静态工厂中的静态方法，返回需要的对象。

constructor-arg 用于指定静态方法参数的值，用法和上面介绍的构造方法一样。

spring 容器会自动调用静态工厂的静态方法获取指定的对象，将其放在容器中以供使用。

#### 案例

**定义静态工厂**

创建一个静态工厂类，用于生成 UserModel 对象。

```
public class UserStaticFactory {
    public static UserModel buildUser1() {
        System.out.println(UserStaticFactory.class + ".buildUser1()");
        UserModel userModel = new UserModel();
        userModel.setName("我是无参静态构造方法创建的!");
        return userModel;
    }
    
    public static UserModel buildUser2(String name, int age) {
        System.out.println(UserStaticFactory.class + ".buildUser2()");
        UserModel userModel = new UserModel();
        userModel.setName(name);
        userModel.setAge(age);
        return userModel;
    }
}
```

**beans.xml 配置**

```
<!-- 通过工厂静态无参方法创建bean对象 -->
<bean id="createBeanByStaticFactoryMethod1" class="com.zkunm.spring001.UserStaticFactory" factory-method="buildUser1"/>
<!-- 通过工厂静态有参方法创建bean对象 -->
<bean id="createBeanByStaticFactoryMethod2" class="com.zkunm.spring001.UserStaticFactory" factory-method="buildUser2">
    <constructor-arg index="0" value="通过工厂静态有参方法创建UerModel实例对象"/>
    <constructor-arg index="1" value="30"/>
</bean>
```

上面配置中，spring 容器启动的时候会自动调用 UserStaticFactory 中的 buildUser1 静态方法获取 UserModel 对象，将其作为 createBeanByStaticFactoryMethod1 名称对应的 bean 对象放在 spring 容器中。

会调用 UserStaticFactory 的 buildUser2 方法，并且会传入 2 个指定的参数，得到返回的 UserModel 对象，将其作为 createBeanByStaticFactoryMethod2 名称对应的 bean 对象放在 spring 容器中。

**运行 Client**

![image-20201213112632993](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213112633.png)

从输出中可以看出，两个静态方法都被调用了，createBeanByStaticFactoryMethod1 对应的 bean 对象是通过 buildUser1 方法创建的；createBeanByStaticFactoryMethod2 对应的 bean 对象是通过 buildUser2 方法创建的。

### 通过实例工厂方法创建 bean 对象

让 spring 容器去调用某些对象的某些实例方法来生成 bean 对象放在容器中以供使用。

```
<bean id="bean名称" factory-bean="需要调用的实例对象bean名称" factory-method="bean对象中的方法">
    <constructor-arg index="0" value="bean的值" ref="引用的bean名称" />
    <constructor-arg index="1" value="bean的值" ref="引用的bean名称" />
    <constructor-arg index="2" value="bean的值" ref="引用的bean名称" />
    ....
    <constructor-arg index="n" value="bean的值" ref="引用的bean名称" />
</bean>
```

spring 容器以 factory-bean 的值为 bean 名称查找对应的 bean 对象，然后调用该对象中 factory-method 属性值指定的方法，将这个方法返回的对象作为当前 bean 对象放在容器中供使用。

#### 案例

**定义一个实例工厂**

内部写 2 个方法用来创建 UserModel 对象。

```
public class UserFactory {
    public UserModel buildUser1() {
        System.out.println("----------------------1");
        UserModel userModel = new UserModel();
        userModel.setName("bean实例方法创建的对象!");
        return userModel;
    }

    public UserModel buildUser2(String name, int age) {
        System.out.println("----------------------2");
        UserModel userModel = new UserModel();
        userModel.setName(name);
        userModel.setAge(age);
        return userModel;
    }
}
```

**beans.xml**

```
<!-- 定义一个工厂实例 -->
<bean id="userFactory" class="com.zkunm.spring001.UserFactory"/>
<!-- 通过userFactory实例的无参user方法创建UserModel对象 -->
<bean id="createBeanByBeanMethod1" factory-bean="userFactory" factory-method="buildUser1"/>
<!-- 通过userFactory实例的有参user方法创建UserModel对象 -->
<bean id="createBeanByBeanMethod2" factory-bean="userFactory" factory-method="buildUser2">
    <constructor-arg index="0" value="通过bean实例有参方法创建UserModel实例对象"/>
    <constructor-arg index="1" value="30"/>
</bean>
```

createBeanByBeanMethod1 对应的 bean 是通过 userFactory 的 buildUser1 方法生成的。

createBeanByBeanMethod2 对应的 bean 是通过 userFactory 的 buildUser2 方法生成的。

**运行 Client**

![image-20201213113010961](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213113011.png)

### 通过 FactoryBean 来创建 bean 对象

前面我们学过了 BeanFactory 接口，BeanFactory 是 spring 容器的顶层接口，而这里要说的是 FactoryBean，也是一个接口，这两个接口很容易搞混淆，FactoryBean 可以让 spring 容器通过这个接口的实现来创建我们需要的 bean 对象。

FactoryBean 接口源码：

```
public interface FactoryBean<T> {
    /**
     * 返回创建好的对象
     */
    @Nullable
    T getObject() throws Exception;
    /**
     * 返回需要创建的对象的类型
     */
    @Nullable
    Class<?> getObjectType();
    /**
    * bean是否是单例的
    **/
    default boolean isSingleton() {
        return true;
    }
}
```

接口中有 3 个方法，前面 2 个方法需要我们去实现，getObject 方法内部由开发者自己去实现对象的创建，然后将创建好的对象返回给 Spring 容器，getObjectType 需要指定我们创建的 bean 的类型；最后一个方法 isSingleton 表示通过这个接口创建的对象是否是单例的，如果返回 false，那么每次从容器中获取对象的时候都会调用这个接口的 getObject() 去生成 bean 对象。

```
<bean id="bean名称" class="FactoryBean接口实现类" />
```

#### 案例

**创建一个 FactoryBean 实现类**

```
public class UserFactoryBean implements FactoryBean<UserModel> {
    int count = 1;

    @Nullable
    @Override
    public UserModel getObject() throws Exception { //@1
        UserModel userModel = new UserModel();
        userModel.setName("我是通过FactoryBean创建的第" + count++ + "对象");//@4
        return userModel;
    }

    @Nullable
    @Override
    public Class<?> getObjectType() {
        return UserModel.class; //@2
    }

    @Override
    public boolean isSingleton() {
        return true; //@3
    }
}
```

@1：返回了一个创建好的 UserModel 对象

@2：返回对象的 Class 对象

@3：返回 true，表示创建的对象是单例的，那么我们每次从容器中获取这个对象的时候都是同一个对象

@4：此处用到了一个 count，通过这个一会可以看出 isSingleton 不同返回值的时候从容器获取的 bean 是否是同一个

bean xml 配置

```
<!-- 通过FactoryBean 创建UserModel对象 -->
<bean id="createByFactoryBean" class="com.zkunm.spring001.UserFactoryBean"/>
```

Client 代码

```
public class Client {
    public static void main(String[] args) {
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("bean.xml");
        System.out.println("spring容器中所有bean如下：");
        //getBeanDefinitionNames用于获取容器中所有bean的名称
        for (String beanName : context.getBeanDefinitionNames()) {
            System.out.println(beanName + ":" + context.getBean(beanName));
        }
        System.out.println("--------------------------");
        //多次获取createByFactoryBean看看是否是同一个对象
        System.out.println("createByFactoryBean:" + context.getBean("createByFactoryBean"));
        System.out.println("createByFactoryBean:" + context.getBean("createByFactoryBean"));
    }
}
```

运行输出

![image-20201213113744214](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213113744.png)

有 3 行输出的都是同一个 createByFactoryBean，程序中通过 getBean 从 spring 容器中查找 createByFactoryBean 了 3 次，3 次结果都是一样的，说明返回的都是同一个 UserModel 对象。

下面我们将 UserFactoryBean 中的 isSingleton 调整一下，返回 false

```
@Override
public boolean isSingleton() {
    return false;
}
```

当这个方法返回 false 的时候，表示由这个 FactoryBean 创建的对象是多例的，那么我们每次从容器中 getBean 的时候都会去重新调用 FactoryBean 中的 getObject 方法获取一个新的对象。

再运行一下 Client，这 3 次获取的对象不一样了

![image-20201213113828146](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213113828.png)

# 6、bean scope

应用中，有时候我们需要一个对象在整个应用中只有一个，有些对象希望每次使用的时候都重新创建一个，spring 对我们这种需求也提供了支持，在 spring 中这个叫做 bean 的作用域，xml 中定义 bean 的时候，可以通过 scope 属性指定 bean 的作用域，如：

```
<bean id="" class="" scope="作用域" /> 
```

spring 容器中 scope 常见的有 5 种

### singleton

当 scope 的值设置为 singleton 的时候，整个 spring 容器中只会存在一个 bean 实例，通过容器多次查找 bean 的时候（调用 BeanFactory 的 getBean 方法或者 bean 之间注入依赖的 bean 对象的时候），返回的都是同一个 bean 对象，singleton 是 scope 的默认值，所以 spring 容器中默认创建的 bean 对象是单例的，通常 spring 容器在启动的时候，会将 scope 为 singleton 的 bean 创建好放在容器中（有个特殊的情况，当 bean 的 lazy 被设置为 true 的时候，表示懒加载，那么使用的时候才会创建），用的时候直接返回。

#### 案例

bean xml 配置

```
<!-- 单例bean，scope设置为singleton -->
<bean id="singletonBean" class="com.zkunm.spring001.BeanScopeModel" scope="singleton">
    <constructor-arg index="0" value="singleton"/>
</bean>
```

BeanScopeModel 代码

```
public class BeanScopeModel {
    public BeanScopeModel(String beanScope) {
        System.out.printf("create BeanScopeModel,{scope=%s},{this=%s}%n", beanScope, this);
    }
}
```

上面构造方法中输出了一段文字，一会我们可以根据输出来看一下这个 bean 什么时候创建的，是从容器中获取 bean 的时候创建的还是容器启动的时候创建的。

测试用例

```
public class ScopeTest {
    ClassPathXmlApplicationContext context;
    @Before
    public void before() {
        System.out.println("spring容器准备启动.....");
        this.context = new ClassPathXmlApplicationContext("bean.xml");
        System.out.println("spring容器启动完毕！");
    }

    @Test
    public void singletonBean() {
        System.out.println("---------单例bean，每次获取的bean实例都一样---------");
        System.out.println(context.getBean("singletonBean"));
        System.out.println(context.getBean("singletonBean"));
        System.out.println(context.getBean("singletonBean"));
    }
}
```

上面代码中 before 方法上面有 @Before 注解，这个是 junit 提供的功能，这个方法会在所有 @Test 标注的方法之前之前运行，before 方法中我们对容器进行初始化，并且在容器初始化前后输出了一段文字。

上面代码中，singletonBean 方法中，3 次获取 singletonBean 对应的 bean。

运行测试用例

![image-20201213121036906](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213121036.png)

结论

从输出中得到 2 个结论

- 前 3 行的输出可以看出，BeanScopeModel 的构造方法是在容器启动过程中调用的，说明这个 bean 实例在容器启动过程中就创建好了，放在容器中缓存着
- 最后 3 行输出的是一样的，说明返回的是同一个 bean 对象

#### 单例 bean 使用注意

**单例 bean 是整个应用共享的，所以需要考虑到线程安全问题，之前在玩 springmvc 的时候，springmvc 中 controller 默认是单例的，有些开发者在 controller 中创建了一些变量，那么这些变量实际上就变成共享的了，controller 可能会被很多线程同时访问，这些线程并发去修改 controller 中的共享变量，可能会出现数据错乱的问题；所以使用的时候需要特别注意。**

### prototype

如果 scope 被设置为 prototype 类型的了，表示这个 bean 是多例的，通过容器每次获取的 bean 都是不同的实例，每次获取都会重新创建一个 bean 实例对象。

#### 案例

bean xml 配置

```
<!-- 单例bean，scope设置为prototype -->
<bean id="prototypeBean" class="com.zkunm.spring001.BeanScopeModel" scope="prototype">
    <constructor-arg index="0" value="prototype"/>
</bean>
```

新增一个测试用例

ScopeTest 中新增一个方法

```
@Test
public void prototypeBean() {
    System.out.println("---------单例bean，每次获取的bean实例都一样---------");
    System.out.println(context.getBean("prototypeBean"));
    System.out.println(context.getBean("prototypeBean"));
    System.out.println(context.getBean("prototypeBean"));
}
```

运行测试用例

![image-20201213121217587](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213121217.png)

结论

输出中可以看出，容器启动过程中并没有去创建 BeanScopeModel 对象，3 次获取 prototypeBean 得到的都是不同的实例，每次获取的时候才会去调用构造方法创建 bean 实例。

#### 多例 bean 使用注意

**多例 bean 每次获取的时候都会重新创建，如果这个 bean 比较复杂，创建时间比较长，会影响系统的性能，这个地方需要注意。**

**下面要介绍的 3 个：request、session、application 都是在 spring web 容器环境中才会有的。**

### request

当一个 bean 的作用域为 request，表示在一次 http 请求中，一个 bean 对应一个实例；对每个 http 请求都会创建一个 bean 实例，request 结束的时候，这个 bean 也就结束了，request 作用域用在 spring 容器的 web 环境中，这个以后讲 springmvc 的时候会说，spring 中有个 web 容器接口 WebApplicationContext，这个里面对 request 作用域提供了支持，配置方式：

```
<bean id="" class="" scope="request" />
```

### session

这个和 request 类似，也是用在 web 环境中，session 级别共享的 bean，每个会话会对应一个 bean 实例，不同的 session 对应不同的 bean 实例，springmvc 中我们再细说。

```
<bean id="" class="" scope="session" />
```

### application

全局 web 应用级别的作用于，也是在 web 环境中使用的，一个 web 应用程序对应一个 bean 实例，通常情况下和 singleton 效果类似的，不过也有不一样的地方，singleton 是每个 spring 容器中只有一个 bean 实例，一般我们的程序只有一个 spring 容器，但是，一个应用程序中可以创建多个 spring 容器，不同的容器中可以存在同名的 bean，但是 sope=aplication 的时候，不管应用中有多少个 spring 容器，这个应用中同名的 bean 只有一个。

```
<bean id="" class="" scope="application" />
```

### 自定义 scope

有时候，spring 内置的几种 sope 都无法满足我们的需求的时候，我们可以自定义 bean 的作用域。

#### 自定义 Scope 3 步骤

第 1 步：实现 Scope 接口

我们来看一下这个接口定义

```
package org.springframework.beans.factory.config;

import org.springframework.beans.factory.ObjectFactory;
import org.springframework.lang.Nullable;

public interface Scope {

    /**
    * 返回当前作用域中name对应的bean对象
    * name：需要检索的bean的名称
    * objectFactory：如果name对应的bean在当前作用域中没有找到，那么可以调用这个ObjectFactory来创建这个对象
    **/
    Object get(String name, ObjectFactory<?> objectFactory);

    /**
     * 将name对应的bean从当前作用域中移除
     **/
    @Nullable
    Object remove(String name);

    /**
     * 用于注册销毁回调，如果想要销毁相应的对象,则由Spring容器注册相应的销毁回调，而由自定义作用域选择是不是要销毁相应的对象
     */
    void registerDestructionCallback(String name, Runnable callback);

    /**
     * 用于解析相应的上下文数据，比如request作用域将返回request中的属性。
     */
    @Nullable
    Object resolveContextualObject(String key);

    /**
     * 作用域的会话标识，比如session作用域将是sessionId
     */
    @Nullable
    String getConversationId();

}
```

第 2 步：将自定义的 scope 注册到容器

需要调用 org.springframework.beans.factory.config.ConfigurableBeanFactory#registerScope 的方法，看一下这个方法的声明

```
/**
* 向容器中注册自定义的Scope
*scopeName：作用域名称
* scope：作用域对象
**/
void registerScope(String scopeName, Scope scope);
```

第 3 步：使用自定义的作用域

定义 bean 的时候，指定 bean 的 scope 属性为自定义的作用域名称。

#### 案例

实现一个线程级别的 bean 作用域，同一个线程中同名的 bean 是同一个实例，不同的线程中的 bean 是不同的实例。

实现分析

需求中要求 bean 在线程中是贡献的，所以我们可以通过 ThreadLocal 来实现，ThreadLocal 可以实现线程中数据的共享。

下面我们来上代码。

ThreadScope

```
public class ThreadScope implements Scope {

    public static final String THREAD_SCOPE = "thread";//@1

    private ThreadLocal<Map<String, Object>> beanMap = new ThreadLocal() {
        @Override
        protected Object initialValue() {
            return new HashMap<>();
        }
    };

    @Override
    public Object get(String name, ObjectFactory<?> objectFactory) {
        Object bean = beanMap.get().get(name);
        if (Objects.isNull(bean)) {
            bean = objectFactory.getObject();
            beanMap.get().put(name, bean);
        }
        return bean;
    }

    @Nullable
    @Override
    public Object remove(String name) {
        return this.beanMap.get().remove(name);
    }

    @Override
    public void registerDestructionCallback(String name, Runnable callback) {
        //bean作用域范围结束的时候调用的方法，用于bean清理
        System.out.println(name);
    }

    @Nullable
    @Override
    public Object resolveContextualObject(String key) {
        return null;
    }

    @Nullable
    @Override
    public String getConversationId() {
        return Thread.currentThread().getName();
    }
}
```

@1：定义了作用域的名称为一个常量 thread，可以在定义 bean 的时候给 scope 使用

BeanScopeModel

```
public class BeanScopeModel {
    public BeanScopeModel(String beanScope) {
        System.out.printf("线程:%s,create BeanScopeModel,{sope=%s},{this=%s}%n", Thread.currentThread(), beanScope, this);
    }
}
```

上面的构造方法中会输出当前线程的信息，到时候可以看到创建 bean 的线程。

bean 配置文件

beans-thread.xml 内容

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-4.3.xsd">

    <!-- 自定义scope的bean -->
    <bean id="threadBean" class="com.javacode2018.lesson001.demo4.BeanScopeModel" scope="thread">
        <constructor-arg index="0" value="thread"/>
    </bean>
</beans>
```

注意上面的 scope 是我们自定义的，值为 thread

测试用例

```
public class ThreadScopeTest {
    public static void main(String[] args) throws InterruptedException {
        String beanXml = "classpath:beans-thread.xml";
        //手动创建容器
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext();
        //设置配置文件位置
        context.setConfigLocation(beanXml);
        //启动容器
        context.refresh();
        //向容器中注册自定义的scope
        context.getBeanFactory().registerScope(ThreadScope.THREAD_SCOPE, new ThreadScope());//@1

        //使用容器获取bean
        for (int i = 0; i < 2; i++) { //@2
            new Thread(() -> {
                System.out.println(Thread.currentThread() + "," + context.getBean("threadBean"));
                System.out.println(Thread.currentThread() + "," + context.getBean("threadBean"));
            }).start();
            TimeUnit.SECONDS.sleep(1);
        }
    }
}
```

注意上面代码，重点在 @1，这个地方向容器中注册了自定义的 ThreadScope。

@2：创建了 2 个线程，然后在每个线程中去获取同样的 bean 2 次，然后输出，我们来看一下效果。

运行输出

![image-20201213121812289](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213121812.png)

从输出中可以看到，bean 在同样的线程中获取到的是同一个 bean 的实例，不同的线程中 bean 的实例是不同的。

### 总结

1. spring 容器自带的有 2 种作用域，分别是 singleton 和 prototype；还有 3 种分别是 spring web 容器环境中才支持的 request、session、application
2. singleton 是 spring 容器默认的作用域，一个 spring 容器中同名的 bean 实例只有一个，多次获取得到的是同一个 bean；单例的 bean 需要考虑线程安全问题
3. prototype 是多例的，每次从容器中获取同名的 bean，都会重新创建一个；多例 bean 使用的时候需要考虑创建 bean 对性能的影响
4. 一个应用中可以有多个 spring 容器
5. 自定义 scope 3 个步骤，实现 Scope 接口，将实现类注册到 spring 容器，使用自定义的 sope

# 7、依赖注入之手动注入

### 依赖回顾

通常情况下，系统中类和类之间是有依赖关系的，如果一个类对外提供的功能需要通过调用其他类的方法来实现的时候，说明这两个类之间存在依赖关系，如：

```
public class UserService{
    public void insert(UserModel model){
        //插入用户信息
    }
}

public class UserController{
    private UserService userService;
    public void insert(UserModel model){
        this.userService.insert(model);
    }
}
```

UserController 中的 insert 方法中需要调用 userService 的 insert 方法，说明 UserController 依赖于 UserService，如果 userService 不存在，此时 UserControler 无法对外提供 insert 操作。

那么我们创建 UserController 对象的时候如何将给 userService 设置值呢？通常有 2 种方法。

#### 依赖对象的初始化方式

##### 通过构造器设置依赖对象

UserController 中添加一个有参构造方法，如下：

```
public class UserController{
    private UserService userService;
    public UserController(UserService userService){
        this.userService = userService;
    }
    public void insert(UserModel model){
        this.userService.insert(model);
    }
}

//UserController使用
UserSerivce userService = new UserService();
UserController userController = new UserController(userService);
//然后就可以使用userController对象了
```

##### 通过 set 方法设置依赖对象

可以在 UserController 中给 userService 添加一个 set 方法，如：

```
public class UserController{
    private UserService userService;
    public setUserService(UserService userService){
        this.userService = userService;
    }
    public void insert(UserModel model){
        this.userService.insert(model);
    }
}

//UserController使用
UserSerivce userService = new UserService();
UserController userController = new UserController();
userController.setService(userService);
//然后就可以使用userController对象了
```

上面这些操作，将被依赖的对象设置到依赖的对象中，spring 容器内部都提供了支持，这个在 spirng 中叫做依赖注入。

### spring 依赖注入

spring 中依赖注入主要分为手动注入和自动注入，手动注入需要我们明确配置需要注入的对象。

spring 中也是通过构造函数和 set 属性这两种方式实现注入的

### 通过构造器注入

构造器的参数就是被依赖的对象，构造器注入又分为 3 种注入方式：

- 根据构造器参数索引注入
- 根据构造器参数类型注入
- 根据构造器参数名称注入

### 根据构造器参数索引注入

```
<bean id="diByConstructorParamIndex" class="com.zkunm.spring001.UserModel">
    <constructor-arg index="0" value="Java"/>
    <constructor-arg index="1" value="上海市"/>
</bean>
```

constructor-arg 用户指定构造器的参数

index：构造器参数的位置，从 0 开始

value：构造器参数的值，value 只能用来给简单的类型设置值，value 对应的属性类型只能为 byte,int,long,float,double,boolean,Byte,Long,Float,Double, 枚举，spring 容器内部注入的时候会将 value 的值转换为对应的类型。

#### 案例

```
public class UserModel {
    private String name;
    private int age;
    //描述信息
    private String desc;

    public UserModel() {
    }

    public UserModel(String name, String desc) {
        this.name = name;
        this.desc = desc;
    }

    public UserModel(String name, int age, String desc) {
        this.name = name;
        this.age = age;
        this.desc = desc;
    }

    @Override
    public String toString() {
        return "UserModel{" +
                "name='" + name + '\'' +
                ", age=" + age +
                ", desc='" + desc + '\'' +
                '}';
    }
}
```

```
<!-- 通过构造器参数的索引注入 -->
<bean id="diByConstructorParamIndex" class="com.zkunm.spring001.UserModel">
    <constructor-arg index="0" value="Java"/>
    <constructor-arg index="1" value="我是通过构造器参数位置注入的"/>
</bean>
```

上面创建 UserModel 实例代码相当于下面代码：

```
UserModel userModel = new UserModel("Java","我是通过构造器参数类型注入的");
```

```
public class IocUtil {
    public static ClassPathXmlApplicationContext context(String beanXml) {
        return new ClassPathXmlApplicationContext(beanXml);
    }
}
```

```
public class DiTest {
    @Test
    public void diByConstructorParamIndex() {
        ClassPathXmlApplicationContext context = IocUtil.context("bean.xml");
        System.out.println(context.getBean("diByConstructorParamIndex"));
    }
}
```

![image-20201213123147144](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213123147.png)

#### 优缺点

**参数位置的注入对参数顺序有很强的依赖性，若构造函数参数位置被人调整过，会导致注入出错。**

**不过通常情况下，不建议去在代码中修改构造函数，如果需要新增参数的，可以新增一个构造函数来实现，这算是一种扩展，不会影响目前已有的功能。**

### 根据构造器参数类型注入

```
<bean id="diByConstructorParamType" class="com.zkunm.spring001.UserModel">
    <constructor-arg type="参数类型" value="参数值"/>
    <constructor-arg type="参数类型" value="参数值"/>
</bean>
```

constructor-arg 用户指定构造器的参数

type：构造函数参数的完整类型，如：java.lang.String,int,double

value：构造器参数的值，value 只能用来给简单的类型设置值

#### 案例

```
<!-- 通过构造器参数的类型注入 -->
<bean id="diByConstructorParamType" class="com.zkunm.spring001.UserModel">
    <constructor-arg type="int" value="30"/>
    <constructor-arg type="java.lang.String" value="Java"/>
    <constructor-arg type="java.lang.String" value="我是通过构造器参数类型注入的"/>
</bean>
```

上面创建 UserModel 实例代码相当于下面代码：

```
UserModel userModel = new UserModel("Java",30,"我是通过构造器参数类型注入的");
```

```
@Test
public void diByConstructorParamType() {
    ClassPathXmlApplicationContext context = IocUtil.context("bean.xml");
    System.out.println(context.getBean("diByConstructorParamType"));
}
```

![image-20201213123517937](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213123518.png)

#### 优缺点

**实际上按照参数位置或者按照参数的类型注入，都有一个问题，很难通过 bean 的配置文件，知道这个参数是对应 UserModel 中的那个属性的，代码的可读性不好，比如我想知道这每个参数对应 UserModel 中的那个属性，必须要去看 UserModel 的源码，下面要介绍按照参数名称注入的方式比上面这 2 种更优秀一些。**

### 根据构造器参数名称注入

```
<bean id="diByConstructorParamName" class="com.zkunm.spring001.UserModel">
    <constructor-arg name="参数名称" value="参数值"/>
    <constructor-arg name="参数名称" value="参数值"/>
</bean>
```

constructor-arg 用户指定构造器的参数

name：构造参数名称

value：构造器参数的值，value 只能用来给简单的类型设置值

#### 关于方法参数名称的问题

java 通过反射的方式可以获取到方法的参数名称，不过源码中的参数通过编译之后会变成 class 对象，通常情况下源码变成 class 文件之后，参数的真实名称会丢失，参数的名称会变成 arg0,arg1,arg2 这样的，和实际参数名称不一样了，**如果需要将源码中的参数名称保留在编译之后的 class 文件中，编译的时候需要用下面的命令**：

```
javac -parameters java源码
```

但是我们难以保证编译代码的时候，操作人员一定会带上 - parameters 参数，所以方法的参数可能在 class 文件中会丢失，导致反射获取到的参数名称和实际参数名称不符，这个我们需要先了解一下。

**参数名称可能不稳定的问题，spring 提供了解决方案，通过 ConstructorProperties 注解来定义参数的名称，将这个注解加在构造方法上面**，如下：

```
@ConstructorProperties({"第一个参数名称", "第二个参数的名称",..."第n个参数的名称"})
public 类名(String p1, String p2...,参数n) {
}
```

#### 案例

```
public class CarModel {
    private String name;
    //描述信息
    private String desc;

    public CarModel() {
    }

    @ConstructorProperties({"name", "desc"})
    public CarModel(String p1, String p2) {
        this.name = p1;
        this.desc = p2;
    }

    @Override
    public String toString() {
        return "CarModel{" +
                "name='" + name + '\'' +
                ", desc='" + desc + '\'' +
                '}';
    }
}
```

```
<!-- 通过构造器参数的名称注入 -->
<bean id="diByConstructorParamName" class="com.zkunm.spring001.CarModel">
    <constructor-arg name="desc" value="我是通过构造器参数类型注入的"/>
    <constructor-arg name="name" value="保时捷Macans"/>
</bean>
```

上面创建 CarModel 实例代码相当于下面代码：

```
CarModel carModel = new CarModel("保时捷Macans","我是通过构造器参数类型注入的");
```

```
@Test
public void diByConstructorParamName() {
    ClassPathXmlApplicationContext context = IocUtil.context("bean.xml");
    System.out.println(context.getBean("diByConstructorParamName"));
}
```

![image-20201213123852045](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213123852.png)

### setter 注入

**通常情况下，我们的类都是标准的 javabean，javabean 类的特点：**

- **属性都是 private 访问级别的**
- **属性通常情况下通过一组 setter（修改器）和 getter（访问器）方法来访问**
- **setter 方法，以 set 开头，后跟首字母大写的属性名，如：setUserName，简单属性一般只有一个方法参数，方法返回值通常为 void;**
- **getter 方法，一般属性以 get 开头，对于 boolean 类型一般以 is 开头，后跟首字母大写的属性名，如：getUserName，isOk；**

spring 对符合 javabean 特点类，提供了 setter 方式的注入，会调用对应属性的 setter 方法将被依赖的对象注入进去。

```
<bean id="" class="">
    <property name="属性名称" value="属性值" />
    ...
    <property name="属性名称" value="属性值" />
</bean>
```

property 用于对属性的值进行配置，可以有多个

name：属性的名称

value：属性的值

#### 案例

```
@Data
public class MenuModel {
    //菜单名称
    private String label;
    //同级别排序
    private Integer theSort;
}
```

```
<bean id="diBySetter" class="com.zkunm.spring001.MenuModel">
    <property name="label" value="spring"/>
</bean>
```

```
@Test
public void diBySetter() {
    String beanXml = "classpath:/com/javacode2018/lesson001/demo5/diBySetter.xml";
    ClassPathXmlApplicationContext context = IocUtils.context(beanXml);
    System.out.println(context.getBean("diBySetter"));
}
```

![image-20201213124136445](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213124136.png)

#### 优缺点

**setter 注入相对于构造函数注入要灵活一些，构造函数需要指定对应构造函数中所有参数的值，而 setter 注入的方式没有这种限制，不需要对所有属性都进行注入，可以按需进行注入。**

上面介绍的都是注入普通类型的对象，都是通过 value 属性来设置需要注入的对象的值的，value 属性的值是 String 类型的，spring 容器内部自动会将 value 的值转换为对象的实际类型。

**若我们依赖的对象是容器中的其他 bean 对象的时候，需要用下面的方式进行注入。**

### 注入容器中的 bean

**注入容器中的 bean 有两种写法：**

- **ref 属性方式**
- **内置 bean 的方式**

#### ref 属性方式

将上面介绍的 constructor-arg 或者 property 元素的 value 属性名称替换为 ref，ref 属性的值为容器中其他 bean 的名称，如：

构造器方式，将 value 替换为 ref：

```
<constructor-arg ref="需要注入的bean的名称"/>
```

setter 方式，将 value 替换为 ref：

```
<property name="属性名称" ref="需要注入的bean的名称" />
```

#### 内置 bean 的方式

构造器的方式：

```
<constructor-arg>
    <bean class=""/>
</constructor-arg>
```

setter 方式：

```
<property name="属性名称">
    <bean class=""/>
</property>
```

#### 案例

PersonModel.java

```
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PersonModel {
    private UserModel userModel;
    private CarModel carModel;
}
```

PersonModel 中有依赖于 2 个对象 UserModel、CarModel，下面我们通过 spring 将 UserModel 和 CarModel 创建好，然后注入到 PersonModel 中，下面创建 bean 配置文件

```
<bean id="user" class="com.zkunm.spring001.UserModel"></bean>
<!-- 通过构造器方式注入容器中的bean -->
<bean id="diBeanByConstructor" class="com.zkunm.spring001.PersonModel">
    <!-- 通过ref引用容器中定义的其他bean，user对应上面定义的id="user"的bean -->
    <constructor-arg index="0" ref="user"/>
    <constructor-arg index="1">
        <bean class="com.zkunm.spring001.CarModel">
            <constructor-arg index="0" value="宾利"/>
            <constructor-arg index="1" value=""/>
        </bean>
    </constructor-arg>
</bean>
<!-- 通过setter方式注入容器中的bean -->
<bean id="diBeanBySetter" class="com.zkunm.spring001.PersonModel">
    <!-- 通过ref引用容器中定义的其他bean，user对应上面定义的id="user"的bean -->
    <property name="userModel" ref="user"/>
    <property name="carModel">
        <bean class="com.zkunm.spring001.CarModel">
            <constructor-arg index="0" value="保时捷"/>
            <constructor-arg index="1" value=""/>
        </bean>
    </property>
</bean>
```

新增测试用例

```
@Test
public void diBean(){
    ClassPathXmlApplicationContext context = IocUtil.context("bean.xml");
    System.out.println(context.getBean("diBeanByConstructor"));
    System.out.println(context.getBean("diBeanBySetter"));
}
```

效果

![image-20201213124509522](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213124509.png)

### 其他类型注入

#### 注入 java.util.List（list 元素）

```
<list>
    <value>Spring</value>
    或
    <ref bean="bean名称"/>
    或
    <list></list>
    或
    <bean></bean>
    或
    <array></array>
    或
    <map></map>
</list>
```

#### 注入 java.util.Set（set 元素）

```
<set>
    <value>Spring</value>
    或
    <ref bean="bean名称"/>
    或
    <list></list>
    或
    <bean></bean>
    或
    <array></array>
    或
    <map></map>
</set>
```

#### 注入 java.util.Map（map 元素）

```
<map>
    <entry key="路人甲Java" value="30" key-ref="key引用的bean名称" value-ref="value引用的bean名称"/>
    或
    <entry>
        <key>
            value对应的值，可以为任意类型
        </key>
        <value>
            value对应的值，可以为任意类型
        </value>
    </entry>
</map>
```

#### 注入数组（array 元素）

```
<array>
    数组中的元素
</array>
```

#### 注入 java.util.Properties（props 元素）

Properties 类相当于键值都是 String 类型的 Map 对象，使用 props 进行注入，如下：

```
<props>
    <prop key="key1">java高并发系列</prop>
    <prop key="key2">mybatis系列</prop>
    <prop key="key3">mysql系列</prop>
</props>
```

#### 案例

DiOtherTypeModel.java

```
@Data
public class DiOtherTypeModel {
    private List<String> list1;
    private Set<UserModel> set1;
    private Map<String, Integer> map1;
    private int[] array1;
    private Properties properties1;
}
```

```
<bean id="user1" class="com.zkunm.spring001.UserModel"/>
<bean id="user2" class="com.zkunm.spring001.UserModel"/>
<bean id="diOtherType" class="com.zkunm.spring001.DiOtherTypeModel">
    <!-- 注入java.util.List对象 -->
    <property name="list1">
        <list>
            <value>Spring</value>
            <value>SpringBoot</value>
        </list>
    </property>
    <!-- 注入java.util.Set对象 -->
    <property name="set1">
        <set>
            <ref bean="user1"/>
            <ref bean="user2"/>
            <ref bean="user1"/>
        </set>
    </property>
    <!-- 注入java.util.Map对象 -->
    <property name="map1">
        <map>
            <entry key="1" value="30"/>
            <entry key="2" value="28"/>
        </map>
    </property>
    <!-- 注入数组对象 -->
    <property name="array1">
        <array>
            <value>10</value>
            <value>9</value>
            <value>8</value>
        </array>
    </property>
    <!-- 注入java.util.Properties对象 -->
    <property name="properties1">
        <props>
            <prop key="key1">java</prop>
            <prop key="key2">mybatis</prop>
            <prop key="key3">mysql</prop>
        </props>
    </property>
</bean>
```

新增测试用例

```
@Test
public void diOtherType() {
    ClassPathXmlApplicationContext context = IocUtil.context("bean.xml");
    System.out.println(context.getBean("diOtherType"));
}
```

##### 效果

![image-20201213124850716](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213124850.png)

# 8、自动注入（autowire）

### 手动注入的不足

```
public class A{
    private B b;
    private C c;
    private D d;
    private E e;
    ....
    private N n;

    //上面每个private属性的get和set方法
}
```

使用 spring 容器来管理，xml 配置如下：

```
<bean class="b" class="B"/>
<bean class="c" class="C"/>
<bean class="d" class="D"/>
<bean class="e" class="E"/>
<bean class="a" class="A">
    <property name="b" ref="b"/>
    <property name="c" ref="c"/>
    <property name="d" ref="d"/>
    <property name="e" ref="e"/>
    ...
</bean>
```

上面的注入存在的问题：

- **如果需要注入的对象比较多，比如 A 类中有几十个属性，那么上面的 property 属性是不是需要写几十个，此时配置文件代码量暴增**
- **如果 A 类中新增或者删除了一些依赖，还需要手动去调整 bean xml 中的依赖配置信息，否则会报错**
- **总的来说就是不利于维护和扩展**

**为了解决上面这些问题，spring 为我们提供了更强大的功能：自动注入**

### Class.isAssignableFrom 方法

isAssignableFrom 是 Class 类中的一个方法，看一下这个方法的定义：

```
public native boolean isAssignableFrom(Class<?> cls)
```

用法如下：

```
c1.isAssignableFrom(c2)
```

用来判断 c2 和 c1 是否相等，或者 c2 是否是 c1 的子类。

### 自动注入

自动注入是采用约定大约配置的方式来实现的，程序和 spring 容器之间约定好，遵守某一种都认同的规则，来实现自动注入。

xml 中可以在 bean 元素中通过 autowire 属性来设置自动注入的方式：

```
<bean id="" class="" autowire="byType|byName|constructor|default" />
```

- **byteName：按照名称进行注入**
- **byType：按类型进行注入**
- **constructor：按照构造方法进行注入**
- **default：默认注入方式**

### 按照名称进行注入

autowire 设置为 byName

```
<bean id="" class="X类" autowire="byName"/>
```

spring 容器会按照 set 属性的名称去容器中查找同名的 bean 对象，然后将查找到的对象通过 set 方法注入到对应的 bean 中，未找到对应名称的 bean 对象则 set 方法不进行注入

需要注入的 set 属性的名称和被注入的 bean 的名称必须一致。

#### 案例

```
public class DiAutowireByName {
    private Service1 service1;//@3
    private Service2 service2;//@4

    public Service1 getService1() {
        return service1;
    }

    public void setService1(Service1 service1) {
        System.out.println("setService1->" + service1);
        this.service1 = service1;
    }

    public Service2 getService2() {
        return service2;
    }

    public void setService2(Service2 service2) {
        System.out.println("setService2->" + service2);
        this.service2 = service2;
    }

    @Override
    public String toString() {
        return "DiAutowireByName{" +
                "service1=" + service1 +
                ", service2=" + service2 +
                '}';
    }
    @Data
    public static class Service1 { //@1
        private String desc;
    }
    @Data
    public static class Service2 { //@1
        private String desc;
    }
}
```

这个类中有 2 个属性，名称为：

- service1
- service2

这两个属性都有对应的 set 方法。

下面我们在 bean xml 中定义 2 个和这 2 个属性同名的 bean，然后使用按照名称进行自动注入。

```
<bean id="service1" class="com.zkunm.spring001.DiAutowireByName$Service1">
    <property name="desc" value="service1"/>
</bean>
<bean id="service2" class="com.zkunm.spring001.DiAutowireByName$Service2">
    <property name="desc" value="service2"/>
</bean>
<bean id="service2-1" class="com.zkunm.spring001.DiAutowireByName$Service2">
    <property name="desc" value="service2-1"/>
</bean>
<!-- autowire：byName 配置按照name进行自动注入 -->
<bean id="diAutowireByName1" class="com.zkunm.spring001.DiAutowireByName" autowire="byName"/>
<!-- 当配置了自动注入，还可以使用手动的方式自动注入进行覆盖，手动的优先级更高一些 -->
<bean id="diAutowireByName2" class="com.zkunm.spring001.DiAutowireByName" autowire="byName">
    <property name="service2" ref="service2-1"/>
</bean>
```

上面注释认真看一下。

@1：定义了一个名称为 service1 的 bean

@2：定义了一个名称为 service2 的 bean

@3：定义 diAutowireByName 需要将 autowire 的值置为 byName，表示按名称进行自动注入。

spring 容器创建 diAutowireByName 对应的 bean 时，会遍历 DiAutowireByName 类中的所有 set 方法，然后得到 set 对应的属性名称列表：{"service1","service2"}，然后遍历这属性列表，在容器中查找和属性同名的 bean 对象，然后调用属性对应的 set 方法，将 bean 对象注入进去

```
public class DiAutowireTest {
    ClassPathXmlApplicationContext context;

    @Before
    public void before() {
        context = IocUtil.context("bean.xml");
    }

    @Test
    public void diAutowireByName() {
        System.out.println(context.getBean("diAutowireByName"));
    }
}
```

![image-20201213130853386](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213130853.png)

#### 优缺点

按名称进行注入的时候，要求名称和 set 属性的名称必须同名，相对于硬编码的方式注入，确实节省了不少代码。

### 按照类型进行自动注入

autowire 设置为 byType

```
<bean id="" class="X类" autowire="byType"/>
```

spring 容器会遍历 x 类中所有的 set 方法，会在容器中查找和 set 参数类型相同的 bean 对象，将其通过 set 方法进行注入，未找到对应类型的 bean 对象则 set 方法不进行注入。

**需要注入的 set 属性的类型和被注入的 bean 的类型需要满足 isAssignableFrom 关系。**

按照类型自动装配的时候，如果按照类型找到了多个符合条件的 bean，系统会报错。

**set 方法的参数如果是下面的类型或者下面类型的数组的时候，这个 set 方法会被跳过注入：**

**Object,Boolean,boolean,Byte,byte,Character,char,Double,double,Float,float,Integer,int,Long,Short,shot,Enum,CharSequence,Number,Date,java.time.temporal.Temporal,java.net.URI,java.net.URI,java.util.Locale,java.lang.Class**

#### 案例

```
@Getter
@ToString
public class DiAutowireByType {
    private Service1 service1;
    private Service2 service2;

    public void setService1(Service1 service1) {
        System.out.println("setService1->" + service1); //@1
        this.service1 = service1;
    }
    
    public void setService2(Service2 service2) {
        System.out.println("setService2->" + service2); //@2
        this.service2 = service2;
    }

    @Data
    public static class Service1 {
        private String desc;
    }

    @Data
    public static class Service2 {
        private String desc;
    }
}
```

DiAutowireByType 类中有 2 个 set 方法分别来注入 Service1 和 Service2，两个 set 方法中都输出了一行文字，一会执行的时候可以通过这个输出可以看出 set 方法是否被调用了。

```
<bean id="service1" class="com.zkunm.spring001.DiAutowireByType$Service1">
    <property name="desc" value="service1"/>
</bean>
<bean id="service2" class="com.zkunm.spring001.DiAutowireByType$Service2">
    <property name="desc" value="service2"/>
</bean>
<bean id="diAutowireByType" class="com.zkunm.spring001.DiAutowireByType" autowire="byType"/>
```

上面注释认真看一下。

@1：定义了一个名称为 service1 的 bean

@2：定义了一个名称为 service2 的 bean

@3：定义 diAutowireByType 需要将 autowire 的值置为 byType，表示按名称进行自动注入。

spring 容器创建 diAutowireByType 对应的 bean 时，会遍历 DiAutowireByType 类中的所有 set 方法，然后得到 set 对应的属性名称列表：{"service1","service2"}，然后遍历这属性列表，在容器中查找和属性同名的 bean 对象，然后调用属性对应的 set 方法，将 bean 对象注入进去

```
@Test
public void diAutowireByType() {
    System.out.println(context.getBean("diAutowireByType"));
}
```

![image-20201213131529917](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213131530.png)

#### 优缺点

相对于手动注入，节省了不少代码，新增或者删除属性，只需要增减对应的 set 方法就可以了，更容易扩展了。

#### 注入类型匹配的所有 bean(重点)

**按照类型注入还有 2 中比较牛逼的用法：**

- **一个容器中满足某种类型的 bean 可以有很多个，将容器中某种类型中的所有 bean，通过 set 方法注入给一个 java.util.List <需要注入的 Bean 的类型或者其父类型或者其接口> 对象**
- **将容器中某种类型中的所有 bean，通过 set 方法注入给一个 java.util.Map<String, 需要注入的 Bean 的类型或者其父类型或者其接口> 对象**

```
public class DiAutowireByTypeExtend {

    private List<IService1> serviceList;//@1
    private List<BaseService> baseServiceList;//@2
    private Map<String, IService1> service1Map;//@3
    private Map<String, BaseService> baseServiceMap;//@4

    public List<IService1> getServiceList() {
        return serviceList;
    }

    public void setServiceList(List<IService1> serviceList) {//@5
        this.serviceList = serviceList;
    }

    public List<BaseService> getBaseServiceList() {
        return baseServiceList;
    }

    public void setBaseServiceList(List<BaseService> baseServiceList) {//@6
        this.baseServiceList = baseServiceList;
    }

    public Map<String, IService1> getService1Map() {
        return service1Map;
    }

    public void setService1Map(Map<String, IService1> service1Map) {//@7
        this.service1Map = service1Map;
    }

    public Map<String, BaseService> getBaseServiceMap() {
        return baseServiceMap;
    }

    public void setBaseServiceMap(Map<String, BaseService> baseServiceMap) {//@8
        this.baseServiceMap = baseServiceMap;
    }

    @Override
    public String toString() { //9
        return "DiAutowireByTypeExtend{" +
                "serviceList=" + serviceList +
                ", baseServiceList=" + baseServiceList +
                ", service1Map=" + service1Map +
                ", baseServiceMap=" + baseServiceMap +
                '}';
    }

    //定义了一个接口
    public interface IService1 {
    }

    public static class BaseService {
        private String desc;

        public String getDesc() {
            return desc;
        }

        public void setDesc(String desc) {
            this.desc = desc;
        }

        @Override
        public String toString() {
            return "BaseService{" +
                    "desc='" + desc + '\'' +
                    '}';
        }
    }

    //Service1实现了IService1接口
    public static class Service1 extends BaseService implements IService1 {

    }

    //Service1实现了IService1接口
    public static class Service2 extends BaseService implements IService1 {
    }
}
```

@1,@2,@3,@4：定义了 4 个属性，都是泛型类型的，都有对应的 set 方法。

@5：参数类型是 List<BaseService>，这个集合集合中元素的类型是 BaseService，spring 会找到容器中所有满足 BaseService.isAssignableFrom(bean 的类型) 的 bean 列表，将其通过 @5 的 set 方法进行注入。

@6：同 @5 的代码

@7：这个参数类型是一个 map 了，map 的 key 是 string 类型，value 是 IService1 类型，spring 容器会将所有满足 IService1 类型的 bean 找到，按照 name->bean 对象这种方式丢到一个 map 中，然后调用 @7 的 set 方法进行注入，最后注入的这个 map 就是 bean 的名称和 bean 对象进行映射的一个 map 对象。

@8：同 @7 的代码

@9：重写了 toString 方法，输出的时候好看一些

```
@Test
public void diAutowireByTypeExtend() {
    DiAutowireByTypeExtend diAutowireByTypeExtend = context.getBean(DiAutowireByTypeExtend.class);
    System.out.println("serviceList：" + diAutowireByTypeExtend.getServiceList());
    System.out.println("baseServiceList：" + diAutowireByTypeExtend.getBaseServiceList());
    System.out.println("service1Map：" + diAutowireByTypeExtend.getService1Map());
    System.out.println("baseServiceMap：" + diAutowireByTypeExtend.getBaseServiceMap());
}
```

### 按照构造函数进行自动注入

autowire 设置为 constructor

```
<bean id="" class="X类" autowire="constructor"/>
```

**spring 会找到 x 类中所有的构造方法（一个类可能有多个构造方法），然后将这些构造方法进行排序（先按修饰符进行排序，public 的在前面，其他的在后面，如果修饰符一样的，会按照构造函数参数数量倒叙，也就是采用贪婪的模式进行匹配，spring 容器会尽量多注入一些需要的对象）得到一个构造函数列表，会轮询这个构造器列表，判断当前构造器所有参数是否在容器中都可以找到匹配的 bean 对象，如果可以找到就使用这个构造器进行注入，如果不能找到，那么就会跳过这个构造器，继续采用同样的方式匹配下一个构造器，直到找到一个合适的为止。**

#### 案例

```
public class DiAutowireByConstructor {

    private Service1 service1;
    private Service2 service2;

    public DiAutowireByConstructor() { //@0
    }

    public DiAutowireByConstructor(Service1 service1) { //@1
        System.out.println("DiAutowireByConstructor(Service1 service1)");
        this.service1 = service1;
    }
    public DiAutowireByConstructor(Service1 service1, Service2 service2) { //@2
        System.out.println("DiAutowireByConstructor(Service1 service1, Service2 service2)");
        this.service1 = service1;
        this.service2 = service2;
    }

    public Service1 getService1() {
        return service1;
    }

    public void setService1(Service1 service1) {
        this.service1 = service1;
    }

    public Service2 getService2() {
        return service2;
    }

    public void setService2(Service2 service2) {
        this.service2 = service2;
    }

    @Override
    public String toString() {
        return "DiAutowireByConstructor{" +
                "service1=" + service1 +
                ", service2=" + service2 +
                '}';
    }

    public static class BaseService {
        private String desc;

        public String getDesc() {
            return desc;
        }

        public void setDesc(String desc) {
            this.desc = desc;
        }

        @Override
        public String toString() {
            return "BaseService{" +
                    "desc='" + desc + '\'' +
                    '}';
        }
    }

    //Service1实现了IService1接口
    public static class Service1 extends BaseService {
    }

    //Service1实现了IService1接口
    public static class Service2 extends BaseService {
    }
}
```

@1：1 个参数的构造函数

@2：2 个参数的构造函数

2 个有参构造函数第一行都打印了一段文字，一会在输出中可以看到代码是调用了那个构造函数创建对象。

```
<bean class="com.zkunm.spring001.DiAutowireByConstructor$Service1">
    <property name="desc" value="service1"/>
</bean>
<bean id="diAutowireByConstructor" class="com.zkunm.spring001.DiAutowireByConstructor" autowire="constructor"/>
```

```
@Test
public void diAutowireByConstructor() {
    System.out.println(context.getBean("diAutowireByConstructor"));
}
```

![image-20201213132652236](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213134425.png)

从输出中可以看到调用的是 DiAutowireByConstructor 类中的第一个构造函数注入了 service1 bean。

构造函数匹配采用贪婪匹配，多个构造函数结合容器找到一个合适的构造函数，最匹配的就是第一个有参构造函数，而第二个有参构造函数的第二个参数在 spring 容器中找不到匹配的 bean 对象，所以被跳过了。

我们在 diAutowireByConstructor.xml 加入 Service2 的配置：

```
<bean class="com.zkunm.spring001.DiAutowireByConstructor$Service2">
    <property name="desc" value="service2"/>
</bean>
```

再来运行一下 diAutowireByConstructor 输出：

![image-20201213132747760](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213132747.png)

此时可以看到第二个有参构造函数被调用了，满足了贪婪方式的注入原则，最大限度的注入所有依赖的对象。

### autowire=default

bean xml 的根元素为 beans，注意根元素有个`default-autowire`属性，这个属性可选值有 (no|byName|byType|constructor|default)，这个属性可以批量设置当前文件中所有 bean 的自动注入的方式，bean 元素中如果省略了 autowire 属性，那么会取`default-autowire`的值作为其`autowire`的值，而每个 bean 元素还可以单独设置自己的`autowire`覆盖`default-autowire`的配置，如下：

#### 案例

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-4.3.xsd"
       default-autowire="byName"> //@1

    <bean id="service1" class="com.zkunm.spring001.DiAutowireByName$Service1">
        <property name="desc" value="service1"/>
    </bean>
    <bean id="service2" class="com.zkunm.spring001.DiAutowireByName$Service2">
        <property name="desc" value="service2"/>
    </bean>
    <bean id="service2-1" class="com.zkunm.spring001.DiAutowireByName$Service2">
        <property name="desc" value="service2-1"/>
    </bean>

    <!-- autowire：default，会采用beans中的default-autowire指定的配置 -->
    <bean id="diAutowireByDefault1" class="com.zkunm.spring001.DiAutowireByName" autowire="default"/> //@2

    <!-- autowire：default，会采用beans中的default-autowire指定的配置，还可以使用手动的方式自动注入进行覆盖，手动的优先级更高一些 -->
    <bean id="diAutowireByDefault2" class="com.zkunm.spring001.DiAutowireByName" autowire="default"> //@3
        <property name="service2" ref="service2-1"/>
    </bean>

</beans>
```

注意上面的 @1 配置的 default-autowire="byName"，表示全局默认的自动注入方式是：按名称注入

@2 和 @3 的`autowire=default`，那么注入方式会取`default-autowire`的值。

```
@Test
public void diAutowireByDefault() {
    System.out.println(context.getBean("diAutowireByDefault1"));
    System.out.println(context.getBean("diAutowireByDefault2"));
}
```

# 9、bean中的depend-on

### 无依赖 bean 创建和销毁的顺序

```
<bean id="bean3" class="com.zkunm.spring001.NormalBean$Bean3"/>
<bean id="bean2" class="com.zkunm.spring001.NormalBean$Bean2"/>
<bean id="bean1" class="com.zkunm.spring001.NormalBean$Bean1"/>
```

注意 xml 中 bean 定义顺序是：bean3、bean2、bean1。

```
public class NormalBean {
    public static class Bean1 implements DisposableBean {
        public Bean1() {
            System.out.println(this.getClass() + " constructor!");
        }
        @Override
        public void destroy() throws Exception {
            System.out.println(this.getClass() + " destroy()");
        }
    }

    public static class Bean2 implements DisposableBean {
        public Bean2() {
            System.out.println(this.getClass() + " constructor!");
        }
        @Override
        public void destroy() throws Exception {
            System.out.println(this.getClass() + " destroy()");
        }
    }

    public static class Bean3 implements DisposableBean {
        public Bean3() {
            System.out.println(this.getClass() + " constructor!");
        }
        @Override
        public void destroy() throws Exception {
            System.out.println(this.getClass() + " destroy()");
        }
    }
}
```

上面代码中使用到了 DisposableBean 接口，这个是 spring 容器提供的一个接口，这个接口中有个 destroy 方法，我们的 bean 类可以实现这个接口，当我们调用容器的 close 方法关闭容器的时候，spring 会调用容器中所有 bean 的 destory 方法，用来做一些清理的工作。

上面几个类中构造方法和 destory 方法中都有输出。

```
public class DependOnTest {
    ClassPathXmlApplicationContext context;

    @Before
    public void before() {
        System.out.println("容器启动中!");
        context = IocUtil.context("bean.xml");
    }

    @Test
    public void normalBean() {
        System.out.println("容器启动完毕，准备关闭spring容器!");
        //关闭容器
        context.close();
        System.out.println("spring容器已关闭!");
    }
}
```

![image-20201213133634503](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213134433.png)

bean 的定义结合上面输出我们来对比一下：

| bean 定义顺序 | 创建顺序 | 销毁顺序 |
| ------------- | -------- | -------- |
| bean3         | bean3    | bean1    |
| bean2         | bean2    | bean2    |
| bean1         | bean1    | bean3    |

从输出中可以得到 2 点结论：

1. **bean 对象的创建顺序和 bean xml 中定义的顺序一致**
2. **bean 销毁的顺序和 bean xml 中定义的顺序相反**

### 通过构造器强依赖 bean 创建和销毁顺序

我们将上面案例改造一下，通过构造函数注入的方式使 bean 之间产生强依赖。

```
public class StrongDependenceBean {
    public static class Bean1 implements DisposableBean {
        public Bean1() {
            System.out.println(this.getClass() + " constructor!");
        }
        @Override
        public void destroy() throws Exception {
            System.out.println(this.getClass() + " destroy()");
        }
    }

    public static class Bean2 implements DisposableBean {
        private Bean1 bean1;
        public Bean2(Bean1 bean1) { //@1
            this.bean1 = bean1;
            System.out.println(this.getClass() + " constructor!");
        }
        @Override
        public void destroy() throws Exception {
            System.out.println(this.getClass() + " destroy()");
        }
    }

    public static class Bean3 implements DisposableBean {
        private Bean2 bean2;
        public Bean3(Bean2 bean2) { //@2
            this.bean2 = bean2;
            System.out.println(this.getClass() + " constructor!");
        }

        @Override
        public void destroy() throws Exception {
            System.out.println(this.getClass() + " destroy()");
        }
    }
}
```

代码解释：

@1：创建 Bean2 的时候需要传入一个 bean1 对象，对 bean1 产生了强依赖

@2：创建 Bean3 的时候需要传入一个 bean2 对象，对 bean2 产生了强依赖

依赖关系是：

```
bean3->bean2->bean1
```

```
<bean id="bean3" class="com.zkunm.spring001.NormalBean$Bean3">
    <constructor-arg index="0" ref="bean2"/> //@1
</bean>
<bean id="bean2" class="com.zkunm.spring001.NormalBean$Bean2">
    <constructor-arg index="0" ref="bean1"/> //@2
</bean>
<bean id="bean1" class="com.zkunm.spring001.NormalBean$Bean1"/>
```

注意上面 xml 中 bean 定义顺序是：bean3、bean2、bean1。

@1：bean3 中通过构造器注入 bean2

@2：bean2 中通过构造器注入 bean1

```
@Test
public void strongDependenceBean() {
    System.out.println("容器启动完毕，准备关闭spring容器!");
    context.close();
    System.out.println("spring容器已关闭!");
}
```

![image-20201213135235007](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213135235.png)

bean 的定义结合上面输出我们来对比一下：

| bean 定义顺序 | 依赖顺序（下面依赖上面的） | 创建顺序 | 销毁顺序 |
| ------------- | -------------------------- | -------- | -------- |
| bean3         | bean1                      | bean1    | bean3    |
| bean2         | bean2                      | bean2    | bean2    |
| bean1         | bean3                      | bean3    | bean1    |

从输出中可以得到 2 点结论：

1. **bean 对象的创建顺序和 bean 依赖的顺序一致**
2. **bean 销毁的顺序和 bean 创建的顺序相反**

### 通过 depend-on 干预 bean 创建和销毁顺序

上面看到了对于无依赖的 bean，通过定义的顺序确实可以干预 bean 的创建顺序，通过强依赖也可以干预 bean 的创建顺序。

那么如果 xml 中定义的 bean 特别多，而有些 bean 之间也没有强依赖关系，此时如果想去调整 bean 的创建和销毁的顺序，得去调整 xml 中 bean 的定义顺序，或者去加强依赖，这样是非常不好的，spring 中可以通过 depend-on 来解决这些问题，在不调整 bean 的定义顺序和强加依赖的情况下，可以通过通过 depend-on 属性来设置当前 bean 的依赖于哪些 bean，那么可以保证 depend-on 指定的 bean 在当前 bean 之前先创建好，销毁的时候在当前 bean 之后进行销毁。

**depend-on 使用方式：**

```
<bean id="bean1" class="" depend-on="bean2,bean3; bean4" />
```

**depend-on：设置当前 bean 依赖的 bean 名称，可以指定多个，多个之间可以用”,; 空格 “进行分割**

**上面不管 bean2,bean2,bean4 在任何地方定义，都可以确保在 bean1 创建之前，会先将 bean2,bean3,bean4 创建好，表示 bean1 依赖于这 3 个 bean，可能 bean1 需要用到 bean2、bean3、bean4 中生成的一些资源或者其他的功能等，但是又没有强制去在 bean1 类中通过属性定义强依赖的方式去依赖于 bean2、bean3、bean4；当然销毁的时候也会先销毁当前 bean，再去销毁被依赖的 bean，即先销毁 bean1，再去销毁 depend-on 指定的 bean。**

```
<bean id="bean3" class="com.zkunm.spring001.NormalBean$Bean3" depends-on="bean2,bean1"/>
<bean id="bean2" class="com.zkunm.spring001.NormalBean$Bean2"/>
<bean id="bean1" class="com.zkunm.spring001.NormalBean$Bean1"/>
```

上面 xml 中先定义的 bean3，然后定义了 bean2 和 bean1，并且指定了 bean3 的 depend-on=“bean2,bean1”，根据 depend-on 的规则，所以会先创建 bean2 和 bean1, 然后再创建 bean3，销毁的时候，会按照和创建相反的顺序来，即：bean1、bean2、bean3，下面我们来看看效果是不是这样：

```
public class DependOnBean {
    public static class Bean1 implements DisposableBean {
        public Bean1() {
            System.out.println(this.getClass() + " constructor!");
        }
        @Override
        public void destroy() throws Exception {
            System.out.println(this.getClass() + " destroy()");
        }
    }

    public static class Bean2 implements DisposableBean {
        public Bean2() {
            System.out.println(this.getClass() + " constructor!");
        }
        @Override
        public void destroy() throws Exception {
            System.out.println(this.getClass() + " destroy()");
        }
    }

    public static class Bean3 implements DisposableBean {
        public Bean3() {
            System.out.println(this.getClass() + " constructor!");
        }
        @Override
        public void destroy() throws Exception {
            System.out.println(this.getClass() + " destroy()");
        }
    }
}
```

```
@Test
public void dependOnBean() {
    System.out.println("容器启动完毕，准备关闭spring容器!");
    context.close();
    System.out.println("spring容器已关闭!");
}
```

![image-20201213135525158](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213135525.png)

### 总结

1. **无依赖的 bean 创建顺序和定义的顺序一致，销毁顺序刚好相反**
2. **通过构造器强依赖的 bean，会先创建构造器参数中对应的 bean，然后才会创建当前 bean，销毁顺序刚好相反**
3. **depend-on 可以指定档期 bean 依赖的 bean，通过这个可以确保 depend-on 指定的 bean 在当前 bean 创建之前先创建好，销毁顺序刚好相反**
4. **bean 的销毁顺序和 bean 创建的顺序相反**

# 10 、bean中的primary

### 存在的问题以及解决方案

```
public class NormalBean {
    public interface IService{} //@1
    public static class ServiceA implements IService{} //@2
    public static class ServiceB implements IService{} //@3
}
```

上面代码很简单，@1：定义了一个接口 IService，@2 和 @3 创建了两个类都实现了 IService 接口。

```
<bean id="serviceA" class="com.zkunm.spring001.NormalBean$ServiceA"/>
<bean id="serviceB" class="com.zkunm.spring001.NormalBean$ServiceB"/>
```

```
@Test
public void normalBean() {
    //下面我们通过spring容器的T getBean(Class<T> requiredType)方法获取容器中对应的bean
    NormalBean.IService service = context.getBean(NormalBean.IService.class); //@1
    System.out.println(service);
}
```

注意 @1 的代码，从 spring 容器中在容器中查找 NormalBean.IService.class 类型的 bean 对象，我们来运行一下看看效果，部分输出如下：

![image-20201213141727296](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213141727.png)

spring 容器中定义了 2 个 bean，分别是 serviceA 和 serviceB，这两个 bean 对象都实现了 IService 接口，而用例中我们想从容器中获取 IService 接口对应的 bean，此时容器中有 2 个候选者（serviceA 和 serviceB）满足我们的需求，此时 spring 容器不知道如何选择，到底是返回 serviceA 呢还是返回 serviceB 呢？spring 容器也懵逼了，所以报错了。

再来看一个通过 setter 方法注入的案例：

```
public class SetterBean {
    public interface IService{} //@1
    public static class ServiceA implements IService{} //@2
    public static class ServiceB implements IService{} //@3

    private IService service;

    public void setService(IService service) {
        this.service = service;
    }
}
```

下面我们通过 xml 来定义 SetterBean，并且使用 setter 方式将 IService 注入到 SetterBean 中，配置如下：

```
<bean id="serviceA" class="com.zkunm.spring001.SetterBean$ServiceA"/>
<bean id="serviceB" class="com.zkunm.spring001.SetterBean$ServiceA"/>
<bean id="setterBean" class="com.zkunm.spring001.SetterBean" autowire="byType" />
```

注意上面 setterBean 的定义，autowire="byType" 采用了按照类型自动注入的方式，容器启动的时候，会自动取调用 SetterBean 的 setService 方法，在容器中查找和这个方法参数类型匹配的 bean，将查找的 bean 通过 setService 方法注入进去。

容器中去找 IService 接口对应的 bean，期望有一个匹配的，实际上却找到了 2 个匹配的，不知道如何选择，报错了。

上面 2 个案例报的异常都是下面这个异常：

```
org.springframework.beans.factory.NoUniqueBeanDefinitionException
```

**当希望从容器中获取到一个 bean 对象的时候，容器中却找到了多个匹配的 bean，此时 spring 不知道如何选择了，处于懵逼状态，就会报这个异常。**

**spring 中可以通过 bean 元素的 primary 属性来解决这个问题，可以通过这个属性来指定当前 bean 为主要候选者，当容器查询一个 bean 的时候，如果容器中有多个候选者匹配的时候，此时 spring 会返回主要的候选者。**

下面我们使用 primary 来解决上面案例的问题：

```
@Setter
@ToString
public class PrimaryBean {
    public interface IService{} //@1
    public static class ServiceA implements IService{} //@2
    public static class ServiceB implements IService{} //@3

    private IService service;
}
```

spring 配置文件如下：

```
<bean id="serviceA" class="com.zkunm.spring001.PrimaryBean$ServiceA" primary="true"/>
<bean id="serviceB" class="com.zkunm.spring001.PrimaryBean$ServiceA"/>
<bean id="setterBean" class="com.zkunm.spring001.PrimaryBean" autowire="byType" />
```

上面配置中我们将 serviceA 的 primary 属性置为 true 了，将其置为主要候选者，容器中如果查找 bean 的时候，如果有多个匹配的，就以他为主。

```
 @Test
 public void primaryBean() {
     PrimaryBean.IService service = context.getBean(PrimaryBean.IService.class); //@1
     System.out.println(service);
     PrimaryBean primaryBean = context.getBean(PrimaryBean.class); //@2
     System.out.println(primaryBean);
 }
```

@1：从容器中查找 IService 类型匹配的 bean，这个接口有 2 个实现类（ServiceA 和 Service2），这类在容器中都定义了，但是 serviceA 为主要的 bean，所以这行代码会返回 serviceA

@2：从容器中查找 PrimaryBean 类型的 bean，容器中有一个，这个 bean 按照 byType 默认注入 IService 接口匹配的 bean，注入的时候如果候选者有多个，以 primary="true" 的 bean 为主来注入，所以此处会注入 service2

![image-20201213142424741](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213142424.png)

### 总结

**当从容器中查找一个 bean 的时候，如果容器中出现多个 Bean 候选者时，可以通过 primary="true" 将当前 bean 置为首选者，那么查找的时候就会返回主要的候选者，否则将抛出异常。**

# 11、bean中的autowire-candidate

### autowire-candidate 做什么事情的？

当容器中某种类型的 bean 存在多个的时候，此时如果我们从容器中查找这种类型的 bean 的时候，会报下面这个异常：

```
org.springframework.beans.factory.NoUniqueBeanDefinitionException
```

**原因：当从容器中按照类型查找一个 bean 对象的时候，容器中却找到了多个匹配的 bean，此时 spring 不知道如何选择了，处于懵逼状态，就会报这个异常。**

这种异常主要出现在 2 种场景中：

场景 1：

从容器容器中查找符合指定类型的 bean，对应 BeanFactory 下面的方法：

```
<T> T getBean(Class<T> requiredType) throws BeansException;
```

场景 2：

自动注入方式设置为 byType 的时候，如下：

```
@Setter
public class SetterBean {
    public interface IService{} //@1
    public static class ServiceA implements IService{} //@2
    public static class ServiceB implements IService{} //@3

    private IService service;
}


<bean id="serviceA" class="com.zkunm.spring001.SetterBean$ServiceA"/>
<bean id="serviceB" class="com.zkunm.spring001.SetterBean$ServiceA"/>
<bean id="setterBean" class="com.zkunm.spring001.SetterBean" autowire="byType" />
```

setterBean 的 autowire 设置的是 byType，即按 setter 方法的参数类型自动注入，SetterBean 的 setService 的类型是 IService，而 IService 类有 2 个实现类：ServiceA 和 ServiceB，而容器容器中刚好有这 2 个实现类的 bean：serviceA 和 serviceB，所以上面代码会报错，不知道注入的时候选择那个对象注入。

**我们可以通过 primary 属性来指定一个主要的 bean，当从容器中查找的时候，如果有多个候选的 bean 符合查找的类型，此时容器将返回 primary="true" 的 bean 对象。**

spring 还有一种方法也可以解决这个问题，可以设置某个 bean 是否在自动注入的时候是否为作为候选 bean，通过 bean 元素的 autowire-candidate 属性类配置，如下：

```
<bean id="serviceA" class="com.zkunm.spring001.SetterBean$ServiceA" autowire-candidate="false"/>
```

autowire-candidate：设置当前 bean 在被其他对象作为自动注入对象的时候，是否作为候选 bean，默认值是 true。

来举例说明一下，以上面的 setter 注入的案例先来说一下注入的过程：

**容器在创建 setterBean 的时候，发现其 autowire 为 byType，即按类型自动注入，此时会在 SetterBean 类中查找所有 setter 方法列表，其中就包含了 setService 方法，setService 方法参数类型是 IService，然后就会去容器中按照 IService 类型查找所有符合条件的 bean 列表，此时容器中会返回满足 IService 这种类型并且 autowire-candidate="true" 的 bean，刚才有说过 bean 元素的 autowire-candidate 的默认值是 true，所以容器中符合条件的候选 bean 有 2 个：serviceA 和 serviceB，setService 方法只需要一个满足条件的 bean，此时会再去看这个列表中是否只有一个主要的 bean（即 bean 元素的 primary=“ture” 的 bean），而 bean 元素的 primary 默认值都是 false，所以没有 primary 为 true 的 bean，此时 spring 容器懵了，不知道选哪个了，此时就报错了，抛出 NoUniqueBeanDefinitionException 异常**

从上面过程中可以看出将某个候选 bean 的 primary 置为 true 就可以解决问题了。

或者只保留一个 bean 的 autowire-candidate 为 true，将其余的满足条件的 bean 的 autowire-candidate 置为 false，此时也可以解决这个问题，下面我们使用 autowire-candidate 来解决上面问题看一下效果：

```
@Getter
@ToString
public class SetterBean {
    public interface IService {} //@1
    public static class ServiceA implements IService {} //@2
    public static class ServiceB implements IService {} //@3
    private IService service;
}
```

```
<bean id="serviceA" class="com.zkunm.spring001.SetterBean$ServiceA" autowire-candidate="false"/>
<bean id="serviceB" class="com.zkunm.spring001.SetterBean$ServiceB"/>
<bean id="setterBean" class="com.zkunm.spring001.SetterBean" autowire="byType" />
```

上面我们将 serviceA 的 autowire-candidate 置为 false 了，serviceA 在被其他 bean 自动按照类型注入的时候，将不再放入候选名单中

```
@Test
public void setterBean() {
    System.out.println(context.getBean(SetterBean.class)); //@1
    SetterBean.IService service = context.getBean(SetterBean.IService.class); //@2
    System.out.println(service);
}
```

@1：查找容器中 SetterBean 类型的 bean 对象

@2：查找容器中 SetterBean.IService 接口类型的 bean，实际上面容器中 serviceA 和 serviceB 都是这种类型的

![image-20201213143302053](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213143302.png)

注意一下输出，2 行输出中都是 ServiceB，因为 serviceB 的 autowire-candidate 是默认值 true，自动注入的时候作为候选 bean，而 serviceA 的 autowire-candidate 是 false，自动注入的时候不作为候选 bean，所以上面输出的都是 serviceB。

### autowire-candidates 属性解析源码

beans 元素是 xml 中定义 bean 的根元素，beans 元素有个 default-autowire-candidates 属性，用于定义哪些 bean 可以作为候选者，default-autowire-candidates 的值是个通配符如：

```
default-autowire-candidates="*Service"
```

再来说一下 bean 元素的 autowire-candidate 属性，这个属性有 3 个可选值：

- default：这个是默认值，autowire-candidate 如果不设置，其值就是 default
- true：作为候选者
- false：不作为候选者

spring 中由 beans 元素的 default-autowire-candidates 和 bean 元素的 autowire-candidate 来决定最终 bean 元素 autowire-candidate 的值，我们来看一下 bean 元素 autowire-candidates 的解析源码：

```
org.springframework.beans.factory.xml.BeanDefinitionParserDelegate#parseBeanDefinitionAttributes
```

主要代码如下：

```
//获取bean元素的autowire-candidate元素，autowire-candidate如果不设置，其值就是default
String autowireCandidate = ele.getAttribute(AUTOWIRE_CANDIDATE_ATTRIBUTE);
//判断bean元素的autowire-candidate元素是否等于"default"或者是否等于""
if (isDefaultValue(autowireCandidate)) { 
    //获取beans元素default-autowire-candidates属性值
    String candidatePattern = this.defaults.getAutowireCandidates();
    //判断获取beans元素default-autowire-candidates属性值是否为空，default-autowire-candidates默认值就是null
    if (candidatePattern != null) {
        //判断bean的名称是否和default-autowire-candidates的值匹配，如果匹配就将bean的autowireCandidate置为true，否则置为false
        String[] patterns = StringUtils.commaDelimitedListToStringArray(candidatePattern);
        bd.setAutowireCandidate(PatternMatchUtils.simpleMatch(patterns, beanName));
    }
}else {
    //判断bean的autowire-candidate的值是否等于"true"
    bd.setAutowireCandidate(TRUE_VALUE.equals(autowireCandidate));
}
```

如果上面判断都没有进去，autowireCandidate 属性默认值就是 true，这个在下面定义的：

```
org.springframework.beans.factory.support.AbstractBeanDefinition#autowireCandidate

private boolean autowireCandidate = true;
```

所有的 bean 元素最后都会被解析为 spring 中的 org.springframework.beans.factory.config.BeanDefinition 对象

# 12、lazy-init：bean 延迟初始化

### bean 初始化的方式 2 种方式

1. 实时初始化
2. 延迟初始化

### bean 实时初始化

在容器启动过程中被创建组装好的 bean，称为实时初始化的 bean，spring 中默认定义的 bean 都是实时初始化的 bean，这些 bean 默认都是单例的，在容器启动过程中会被创建好，然后放在 spring 容器中以供使用。

#### 实时初始化 bean 的有一些优点

1. 更早发下 bean 定义的错误：实时初始化的 bean 如果定义有问题，会在容器启动过程中会抛出异常，让开发者快速发现问题
2. 查找 bean 更快：容器启动完毕之后，实时初始化的 bean 已经完全创建好了，此时被缓存在 spring 容器中，当我们需要使用的时候，容器直接返回就可以了，速度是非常快的

#### 案例

```
public class ActualTimeBean {
    public ActualTimeBean() {
        System.out.println("我是实时初始化的bean!");
    }
}
```

一会我们在 spring 中创建上面这个对象，构造函数中会输出一段话，这段话会在 spring 容器创建过程中输出。

```
<bean id="actualTimeBean" class="com.zkunm.spring001.ActualTimeBean"/>
```

```
@Test
public void actualTimeBean() {
    System.out.println("spring容器启动中...");
    new ClassPathXmlApplicationContext("bean.xml"); //启动spring容器
    System.out.println("spring容器启动完毕...");
}
```

![image-20201213144227196](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213144227.png)

### 延迟初始化的 bean

从上面我们可以看出，实时初始化的 bean 都会在容器启动过程中创建好，如果程序中定义的 bean 非常多，并且有些 bean 创建的过程中比较耗时的时候，会导致系统消耗的资源比较多，并且会让整个启动时间比较长，这个我估计大家都是有感受的，使用 spring 开发的系统比较大的时候，整个系统启动耗时是比较长的，基本上多数时间都是在创建和组装 bean。

**spring 对这些问题也提供了解决方案：bean 延迟初始化。**

所谓延迟初始化，就是和实时初始化刚好相反，延迟初始化的 bean 在容器启动过程中不会创建，而是需要使用的时候才会去创建，先说一下 bean 什么时候会被使用：

1. 被其他 bean 作为依赖进行注入的时候，比如通过 property 元素的 ref 属性进行引用，通过构造器注入、通过 set 注入、通过自动注入，这些都会导致被依赖 bean 的创建
2. 开发者自己写代码向容器中查找 bean 的时候，如调用容器的 getBean 方法获取 bean。

上面这 2 种情况会导致延迟初始化的 bean 被创建。

#### 延迟 bean 的配置

在 bean 定义的时候通过`lazy-init`属性来配置 bean 是否是延迟加载，true：延迟初始化，false：实时初始化

```
<bean lazy-init="是否是延迟初始化" />
```

我们来 2 个案例看一下效果。

#### 案例 1

```
public class LazyInitBean {
    public LazyInitBean() {
        System.out.println("我是延迟初始化的bean!");
    }
}
```

```
<bean id="lazyInitBean" class="com.zkunm.spring001.LazyInitBean" lazy-init="true"/>
```

注意上面的`lazy-init="true"`表示定义的这个 bean 是延迟初始化的 bean。

#### 案例 2

上面这种方式是我们主动从容器中获取 bean 的时候，延迟初始化的 bean 才被容器创建的，下面我们再来看一下当延迟初始化的 bean 被其他实时初始化的 bean 依赖的时候，是什么时候创建的。

```
public class ActualTimeDependencyLazyBean {

    public ActualTimeDependencyLazyBean() {
        System.out.println("ActualTimeDependencyLazyBean实例化!");
    }

    private LazyInitBean lazyInitBean;

    public LazyInitBean getLazyInitBean() {
        return lazyInitBean;
    }

    public void setLazyInitBean(LazyInitBean lazyInitBean) {
        this.lazyInitBean = lazyInitBean;
        System.out.println("ActualTimeDependencyLazyBean.setLazyInitBean方法!");
    }
}
```

ActualTimeDependencyLazyBean 类中有个 lazyInitBean 属性，对应的有 get 和 set 方法，我们将通过 set 方法将 lazyInitBean 对象注入。

```
<bean id="lazyInitBean" class="com.zkunm.spring001.LazyInitBean" lazy-init="true"/>
<bean id="actualTimeDependencyLazyBean" class="com.zkunm.spring001.ActualTimeDependencyLazyBean">
    <property name="lazyInitBean" ref="lazyInitBean"/>
</bean>
```

注意上面定义了 2 个 bean：

lazyInitBean：lazy-init 为 true，说明这个 bean 是延迟创建的

actualTimeDependencyLazyBean：通过 property 元素来注入 lazyInitBean，actualTimeDependencyLazyBean 中没有指定 lazy-init，默认为 false，表示是实时创建的 bean，会在容器创建过程中被初始化

LazyBeanTest 中加个方法，如下：

```
@Test
public void actualTimeDependencyLazyBean() {
    System.out.println("spring容器启动中...");
    ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("bean.xml"); //启动spring容器
    System.out.println("spring容器启动完毕...");
}
```

![image-20201213145519700](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213145519.png)

从容器中可以看到，xml 中定义的 2 个 bean 都在容器启动过程中被创建好了。

有些朋友比较迷茫，lazyInitBean 的 lazy-init 为 true，怎么也在容器启动过程中被创建呢？

由于`actualTimeDependencyLazyBean`为实时初始化的 bean，而这个 bean 在创建过程中需要用到`lazyInitBean`，此时容器会去查找`lazyInitBean`这个 bean，然后会进行初始化，所以这 2 个 bean 都在容器启动过程中被创建的。

# 13、使用继承简化 bean 配置 (abstract & parent)

```
public class ServiceA {
}
```

```
@Data
public class ServiceB {
    private String name;
    private ServiceA serviceA;
}
```

```
@Data
public class ServiceC {
    private String name;
    private ServiceA serviceA;
}
```

```
<bean id="serviceA" class="com.ServiceA"/>
<bean id="serviceB" class="com.ServiceB">
    <property name="name" value="Java"/>
    <property name="serviceA" ref="serviceA"/>
</bean>
<bean id="serviceC" class="com.ServiceB">
    <property name="name" value="Java"/>
    <property name="serviceA" ref="serviceA"/>
</bean>
```

### 通过继承优化代码

我们再回头去看一下上面 xml 中，serviceB 和 serviceC 两个 bean 的定义如下：

```
<bean id="serviceB" class="com.ServiceB">
    <property name="name" value="Java"/>
    <property name="serviceA" ref="serviceA"/>
</bean>

<bean id="serviceC" class="com.ServiceC">
    <property name="name" value="Java"/>
    <property name="serviceA" ref="serviceA"/>
</bean>
```

这 2 个 bean 需要注入的属性的值是一样的，都需要注入 name 和 serviceA 两个属性，并且 2 个属性的值也是一样的，我们可以将上面的公共的代码抽取出来，通过 spring 中继承的方式来做到代码重用。

```
<bean id="serviceA" class="com.ServiceA"/>
<bean id="baseService" abstract="true">
    <property name="name" value="Java"/>
    <property name="serviceA" ref="serviceA"/>
</bean>
<bean id="serviceB" class="com.ServiceB" parent="baseService"/>
<bean id="serviceC" class="com.ServiceC" parent="baseService"/>
```

上面多了一个 baseService 的 bean，这个 bean 没有指定 class 对象，但是多了一个 abstract="true" 的属性，表示这个 bean 是抽象的，abstract 为 true 的 bean 在 spring 容器中不会被创建，只是会将其当做 bean 定义的模板，而 serviceB 和 serviceC 的定义中多了一个属性 parent，用来指定当前 bean 的父 bean 名称，此处是 baseService，此时 serviceB 和 serviceC 会继承 baseService 中定义的配置信息。

子 bean 中也可以重新定义父 bean 中已经定义好的配置，这样子配置会覆盖父 bean 中的配置信息

### 总结

1. **bean 元素的 abstract 属性为 true 的时候可以定义某个 bean 为一个抽象的 bean，相当于定义了一个 bean 模板，spring 容器并不会创建这个 bean，从容器中查找 abstract 为 true 的 bean 的时候，会报错 BeanIsAbstractException 异常**
2. **bean 元素的 parent 属性可以指定当前 bean 的父 bean，子 bean 可以继承父 bean 中配置信息，也可以自定义配置信息，这样可以覆盖父 bean 中的配置**

# 14、单例 bean 中使用多例 bean

### lookup-method：方法查找

通常情况下，我们使用的 bean 都是单例的，如果一个 bean 需要依赖于另一个 bean 的时候，可以在当前 bean 中声明另外一个 bean 引用，然后注入依赖的 bean，此时被依赖的 bean 在当前 bean 中自始至终都是同一个实例。

```
public class ServiceA {
}

public class ServiceB {
    private ServiceA serviceA;
    public ServiceA getServiceA() {
        return serviceA;
    }
    public void setServiceA(ServiceA serviceA) {
        this.serviceA = serviceA;
    }
}
```

上面 2 个类，ServiceA 和 ServiceB，而 ServiceB 中需要用到 ServiceA，可以通过 setServiceA 将 serviceA 注入到 ServiceB 中，spring 配置如下：

```
<bean id="serviceA" class="com.ServiceA" scope="prototype"/>
<bean id="serviceB" class="com.ServiceB">
	<property name="serviceA" ref="serviceA"/>
</bean>
```

上面 serviceA 的 scope 是 prototype，表示 serviceA 是多例的，每次从容器中获取 serviceA 都会返回一个新的对象。

而 serviceB 的 scope 没有配置，默认是单例的，通过 property 元素将 serviceA 注入。

来个测试案例，如下：

```
 @Test
 public void normalBean() {
     ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("bean.xml");
     System.out.println(context.getBean(ServiceA.class)); //@1
     System.out.println(context.getBean(ServiceA.class)); //@2
     System.out.println("serviceB中的serviceA");
     ServiceB serviceB = context.getBean(ServiceB.class); //@3
     System.out.println(serviceB.getServiceA()); //@4
     System.out.println(serviceB.getServiceA()); //@5
 }
```

@1 和 @2 从容器中按照类型查找 ServiceA 对应的 bean。

@3：从容器中获取 ServiceB

@4 和 @5：获取 serviceB 中的 serviceA 对象

![image-20201213150952947](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213150953.png)

从输出中可以看出，@1 和 @2 输出了不同的 ServiceA，而 @4 和 @5 输出的是同一个 serviceA，这是因为 serviceB 是单例的，serviceB 中的 serviceA 会在容器创建 serviceB 的时候，从容器中获取一个 serviceA 将其注入到 serviceB 中，所以自始至终 serviceB 中的 serviceA 都是同一个对象。

如果我们希望 beanB 中每次使用 beanA 的时候 beanA 都是一个新的实例，我们怎么实现呢？

我们可以在 serviceB 中加个方法去获取 serviceA，这个方法中我们主动去容器中获取 serviceA，那么每次获取到的都是不同的 serviceA 实例。

那么问题来了，我们如何在 serviceB 中获取到 spring 容器呢？

spring 中有个接口`ApplicationContextAware`：

```
org.springframework.context.ApplicationContextAware

public interface ApplicationContextAware extends Aware {
    void setApplicationContext(ApplicationContext applicationContext) throws BeansException;
}
```

上面这个接口有一个方法`setApplicationContext`，这个接口给了自定义的 bean 中获取 applicationContext 的能力，当我们的类实现这个接口之后，spring 容器创建 bean 对象的时候，如果 bean 实现了这个接口，那么容器会自动调用`setApplicationContext`方法，将容器对象`applicationContext`传入，此时在我们的 bean 对象中就可以使用容器的任何方法了。

下面我们就通过`ApplicationContextAware`接口来实现单例 bean 中使用多例 bean 的案例。

#### 单例 bean 中使用多例 bean：ApplicationContext 接口的方式

```
public class ServiceA {
}
```

```
public class ServiceB implements ApplicationContextAware { //@1
    private ApplicationContext context;

    public void say() {
        ServiceA serviceA = this.getServiceA();//@2
        System.out.println("this:" + this + ",serviceA:" + serviceA);
    }

    public ServiceA getServiceA() {
        return this.context.getBean(ServiceA.class);//@3
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.context = applicationContext;
    }
}
```

注意上面代码，ServiceB 实现了 ApplicationContextAware 接口，然后实现了这个接口中的 setApplicationContext 方法，spring 容器在创建 ServiceB 的时候会自动调用 setApplicationContext 方法。

@3：从容器中主动去获取 ServiceA，这样每次获取到的 ServiceA 都是一个新的实例。

@2：say 方法中调用 getServiceA 方法获取 ServiceA 对象，然后将其输出。

```
<bean id="serviceA" class="com.ServiceA" scope="prototype"/>
<bean id="serviceB" class="com.ServiceB"/>
```

```
@Test
    public void alicationcontextaware() {
        String beanXml = "bean.xml";
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(beanXml);

        System.out.println(context.getBean(ServiceA.class)); //@1
        System.out.println(context.getBean(ServiceA.class)); //@2

        System.out.println("serviceB中的serviceA");
        ServiceB serviceB = context.getBean( ServiceB.class); //@3
        serviceB.say();
        serviceB.say();
    }
```

![image-20201213151445301](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213151445.png)

最后 2 行是是 serviceB 中的 say 方法输出的，可以看出 serviceB 是一个对象，而 serviceA 是不同的对象。

#### 单例 bean 中使用多例 bean：lookup-method 方式实现

上面这种方式实现了单例 bean 中使用多例 bean 的需求，但是用到 spring 中的接口`ApplicationContextAware`，此时对 spring 的 api 有耦合的作用，我们一直推行高内聚低耦合，所以我们得寻求更好的办法。

能不能有这样的功能，当 serviceB 中调用 getServiceA 的时候，系统自动将这个方法拦截，然后去 spring 容器中查找对应的 serviceA 对象然后返回，spring 中的 lookup-method 就可以实现这样的功能。

```
public class ServiceA {
}
```

```
public class ServiceB {
    public void say() {
        ServiceA serviceA = this.getServiceA();
        System.out.println("this:" + this + ",serviceA:" + serviceA);
    }

    public ServiceA getServiceA() { //@1
        return null;
    }
}
```

**注意上面的 @1，这个方法中返回了一个 null 对象，下面我们通过 spring 来创建上面 2 个 bean 对象，然后让 spring 对上面的 getServiceA 方法进行拦截，返回指定的 bean，如下：**

```
<bean id="serviceA" class="com.ServiceA" scope="prototype"/>
<bean id="serviceB" class="com.ServiceB">
    <lookup-method name="getServiceA" bean="serviceA"/>
</bean>
```

注意上面的配置，重点在于这行配置：

```
<lookup-method name="getServiceA" bean="serviceA"/>
```

当我们调用`serviceB`中的`getServiceA`方法的时候，这个方法会拦截，然后会按照 lookup-method 元素中 bean 属性的值作为 bean 的名称去容器中查找对应 bean，然后作为 getServiceA 的返回值返回，即调用 getServiceA 方法的时候，会从 spring 容器中查找`id为serviceA`的 bean 然后返回。

```
@Test
public void lookupmethod() {
    ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("bean.xml");
    System.out.println(context.getBean(ServiceA.class)); //@1
    System.out.println(context.getBean(ServiceA.class)); //@2
    System.out.println("serviceB中的serviceA");
    ServiceB serviceB = context.getBean(ServiceB.class); //@3
    serviceB.say();
    serviceB.say();
}
```

运行看看效果：

![image-20201213151826921](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213151827.png)

注意最后 2 行的输出，serviceA 是调用 this.getServiceA() 方法获取 ，源码中这个方法返回的是 null，但是 spring 内部对这个方法进行了拦截，每次调用这个方法的时候，都会去容器中查找 serviceA，然后返回，所以上面最后 2 行的输出中 serviceA 是有值的，并且是不同的 serviceA 实例。

lookup-method：看其名字，就知道意思：方法查找，调用 name 属性指定的方法的时候，spring 会对这个方法进行拦截，然后去容器中查找 lookup-method 元素中 bean 属性指定的 bean，然后将找到的 bean 作为方法的返回值返回。

这个地方底层是使用 cglib 代理实现的

### replaced-method：方法替换

replaced-method：方法替换，比如我们要调用 serviceB 中的 getServiceA 的时候，我们可以对 serviceB 这个 bean 中的 getServiceA 方法进行拦截，把这个调用请求转发到一个替换者处理。这就是 replaced-method 可以实现的功能，比 lookup-method 更强大更灵活。

##### 步骤一：定义替换者

自定义一个替换者，替换者需要实现 spring 中的 MethodReplacer 接口，看一下这个接口的定义：

```
package org.springframework.beans.factory.support;

import java.lang.reflect.Method;

public interface MethodReplacer {

    /**
     * @param obj 被替换方法的目标对象
     * @param method 目标对象的方法
     * @param args 方法的参数
     * @return return value for the method
     */
    Object reimplement(Object obj, Method method, Object[] args) throws Throwable;

}
```

当调用目标对象需要被替换的方法的时候，这个调用请求会被转发到上面的替换者的 reimplement 方法进行处理。

```
public class ServiceBMethodReplacer implements MethodReplacer, ApplicationContextAware {

    @Override
    public Object reimplement(Object obj, Method method, Object[] args) throws Throwable {
        return this.context.getBean(ServiceA.class);
    }

    private ApplicationContext context;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.context = applicationContext;
    }
}
```

##### 步骤二：定义替换者 bean

```
<!-- 定义替换者bean -->
<bean id="serviceBMethodReplacer" class="com.ServiceBMethodReplacer" />
```

##### 步骤二：通过 replaced-method 元素配置目标 bean 需要被替换的方法

```
<bean id="serviceB" class="com.ServiceB">
    <replaced-method name="getServiceA" replacer="serviceAMethodReplacer"/>
</bean>
```

注意上面的`replaced-method`元素的 2 个属性：

name：用于指定当前 bean 需要被替换的方法

replacer：替换者，即实现了 MethodReplacer 接口的类对应的 bean

上面配置中当调用`serviceB`的 getServiceA 的时候，会自动调用`serviceAMethodReplacer`这个 bean 中的`reimplement`方法进行处理。

#### 案例

```
public class ServiceA {
}
```

```
public class ServiceB {
    public void say() {
        ServiceA serviceA = this.getServiceA();
        System.out.println("this:" + this + ",serviceA:" + serviceA);
    }

    public ServiceA getServiceA() { //@1
        return null;
    }
}
```

上面 getServiceA 需要返回一个 ServiceA 对象，此处返回的是 null，下面我们通过 spring 对这个方法进行替换，然后从容器中获取 ServiceA 然后返回，下面我们来看看替换者的代码。

这个替换者会替换 ServiceB 中的 getServiceA 方法

```
public class ServiceBMethodReplacer implements MethodReplacer, ApplicationContextAware {

    @Override
    public Object reimplement(Object obj, Method method, Object[] args) throws Throwable {
        return this.context.getBean(ServiceA.class);
    }

    private ApplicationContext context;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.context = applicationContext;
    }
}
```

```
<!-- 定义替换者bean -->
<bean id="serviceBMethodReplacer" class="com.ServiceBMethodReplacer" />
<bean id="serviceA" class="com.ServiceA" scope="prototype"/>
<bean id="serviceB" class="com.ServiceB">
    <replaced-method name="getServiceA" replacer="serviceBMethodReplacer"/>
</bean>
```

```
@Test
public void replacedmethod() {
    ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("bean.xml");
    System.out.println(context.getBean(ServiceA.class)); //@1
    System.out.println(context.getBean(ServiceA.class)); //@2
    System.out.println("serviceB中的serviceA");
    ServiceB serviceB = context.getBean(ServiceB.class); //@3
    serviceB.say();
    serviceB.say();
}
```

![image-20201213152406430](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213152406.png)

从输出中可以看出结果和 lookup-method 案例效果差不多，实现了单例 bean 中使用多例 bean 的案例。

输出中都有 CGLIB 这样的字样，说明这玩意也是通过 cglib 实现的。

### 总结

1. **lookup-method：方法查找，可以对指定的 bean 的方法进行拦截，然后从容器中查找指定的 bean 作为被拦截方法的返回值**
2. **replaced-method：方法替换，可以实现 bean 方法替换的效果，整体来说比 lookup-method 更灵活一些**



# 15、Java动态代理&cglib代理

### 为什么要用代理

```
public interface IService {
    void m1();
    void m2();
    void m3();
}
```

接口有 2 个实现类 ServiceA 和 ServiceB，如下：

```
public class ServiceA implements IService {
    @Override
    public void m1() {
        System.out.println("我是ServiceA中的m1方法!");
    }

    @Override
    public void m2() {
        System.out.println("我是ServiceA中的m2方法!");
    }

    @Override
    public void m3() {
        System.out.println("我是ServiceA中的m3方法!");
    }
}

public class ServiceB implements IService {
    @Override
    public void m1() {
        System.out.println("我是ServiceB中的m1方法!");
    }

    @Override
    public void m2() {
        System.out.println("我是ServiceB中的m2方法!");
    }

    @Override
    public void m3() {
        System.out.println("我是ServiceB中的m3方法!");
    }
}
```

```
public class ProxyTest {
    @Test
    public void m1() {
        IService serviceA = new ServiceA();
        IService serviceB = new ServiceB();
        serviceA.m1();
        serviceA.m2();
        serviceA.m3();

        serviceB.m1();
        serviceB.m2();
        serviceB.m3();
    }
}
```

上面是我们原本的程序，突然领导有个需求：调用 IService 接口中的任何方法的时候，需要记录方法的耗时。

此时你会怎么做呢？

IService 接口有 2 个实现类 ServiceA 和 ServiceB，我们可以在这两个类的所有方法中加上统计耗时的代码，如果 IService 接口有几十个实现，是不是要修改很多代码，所有被修改的方法需重新测试？是不是非常痛苦，不过上面这种修改代码的方式倒是可以解决问题，只是增加了很多工作量（编码 & 测试）。

突然有一天，领导又说，要将这些耗时统计发送到监控系统用来做监控报警使用。

此时是不是又要去一个修改上面的代码？又要去测试？此时的系统是难以维护。

还有假如上面这些类都是第三方以 jar 包的方式提供给我们的，此时这些类都是 class 文件，此时我们无法去修改源码。

**比较好的方式**：可以为 IService 接口创建一个代理类，通过这个代理类来间接访问 IService 接口的实现类，在这个代理类中去做耗时及发送至监控的代码，代码如下：

```
public class ServiceProxy implements IService {
    //目标对象，被代理的对象
    private IService target;

    public ServiceProxy(IService target) {
        this.target = target;
    }

    @Override
    public void m1() {
        long starTime = System.nanoTime();
        this.target.m1();
        long endTime = System.nanoTime();
        System.out.println(this.target.getClass() + ".m1()方法耗时(纳秒):" + (endTime - starTime));
    }

    @Override
    public void m2() {
        long starTime = System.nanoTime();
        this.target.m1();
        long endTime = System.nanoTime();
        System.out.println(this.target.getClass() + ".m1()方法耗时(纳秒):" + (endTime - starTime));
    }

    @Override
    public void m3() {
        long starTime = System.nanoTime();
        this.target.m1();
        long endTime = System.nanoTime();
        System.out.println(this.target.getClass() + ".m1()方法耗时(纳秒):" + (endTime - starTime));
    }
}
```

ServiceProxy 是 IService 接口的代理类，target 为被代理的对象，即实际需要访问的对象，也实现了 IService 接口，上面的 3 个方法中加了统计耗时的代码，当我们需要访问 IService 的其他实现类的时候，可以通过 ServiceProxy 来间接的进行访问，用法如下：

```
@Test
public void serviceProxy() {
    IService serviceA = new ServiceProxy(new ServiceA());//@1
    IService serviceB = new ServiceProxy(new ServiceB()); //@2
    serviceA.m1();
    serviceA.m2();
    serviceA.m3();

    serviceB.m1();
    serviceB.m2();
    serviceB.m3();
}
```

上面代码重点在于 @1 和 @2，创建的是代理对象 ServiceProxy，ServiceProxy 构造方法中传入了被代理访问的对象，现在我们访问 ServiceA 或者 ServiceB，都需要经过`ServiceProxy`

上面实现中我们没有去修改 ServiceA 和 ServiceB 中的方法，只是给 IService 接口创建了一个代理类，通过代理类去访问目标对象，需要添加的一些共有的功能都放在代理中，当领导有其他需求的时候，我们只需修改 ServiceProxy 的代码，方便系统的扩展和测试。

假如现在我们需要给系统中所有接口都加上统计耗时的功能，若按照上面的方式，我们需要给每个接口创建一个代理类，此时代码量和测试的工作量也是巨大的，那么我们能不能写一个通用的代理类，来满足上面的功能呢？

**通用代理的 2 种实现：**

1. **jdk 动态代理**
2. **cglib 代理**

### jdk 动态代理详解

jdk 中为实现代理提供了支持，主要用到 2 个类：

```
java.lang.reflect.Proxy
java.lang.reflect.InvocationHandler
```

jdk 自带的代理使用上面有个限制，只能为接口创建代理类，如果需要给具体的类创建代理类，需要用后面要说的 cglib

#### java.lang.reflect.Proxy

这是 jdk 动态代理中主要的一个类，里面有一些静态方法会经常用到，我们来熟悉一下：

##### getProxyClass 方法

为指定的接口创建代理类，返回代理类的 Class 对象

```
public static Class<?> getProxyClass(ClassLoader loader, Class<?>... interfaces)
```

参数说明：

loader：定义代理类的类加载器

interfaces：指定需要实现的接口列表，创建的代理默认会按顺序实现 interfaces 指定的接口

##### newProxyInstance 方法

创建代理类的实例对象

```
public static Object newProxyInstance(ClassLoader loader, Class<?>[] interfaces, InvocationHandler h)
```

这个方法先为指定的接口创建代理类，然后会生成代理类的一个实例，最后一个参数比较特殊，是 InvocationHandler 类型的，这个是个借口如下：

```
public Object invoke(Object proxy, Method method, Object[] args) throws Throwable;
```

上面方法会返回一个代理对象，当调用代理对象的任何方法的时候，会就被`InvocationHandler`接口的`invoke`方法处理，所以主要代码需要卸载`invoke`方法中，稍后会有案例细说。

##### isProxy 方法

判断指定的类是否是一个代理类

```
public static boolean isProxyClass(Class<?> cl)
```

##### getInvocationHandler 方法

获取代理对象的`InvocationHandler`对象

```
public static InvocationHandler getInvocationHandler(Object proxy) throws IllegalArgumentException
```

#### 创建代理：方式一

```
1.调用Proxy.getProxyClass方法获取代理类的Class对象
2.使用InvocationHandler接口创建代理类的处理器
3.通过代理类和InvocationHandler创建代理对象
4.上面已经创建好代理对象了，接着我们就可以使用代理对象了
```

```
public interface IService {
    void m1();
    void m2();
    void m3();
}
```

```
@Test
public void m1() throws NoSuchMethodException, IllegalAccessException, InvocationTargetException, InstantiationException {
    // 1. 获取接口对应的代理类
    Class<IService> proxyClass = (Class<IService>) Proxy.getProxyClass(IService.class.getClassLoader(), IService.class);
    // 2. 创建代理类的处理器
    InvocationHandler invocationHandler = (proxy, method, args) -> {
        System.out.println("我是InvocationHandler，被调用的方法是：" + method.getName());
        return null;
    };
    // 3. 创建代理实例
    IService proxyService = proxyClass.getConstructor(InvocationHandler.class).newInstance(invocationHandler);
    // 4. 调用代理的方法
    proxyService.m1();
    proxyService.m2();
    proxyService.m3();
}
```

#### 创建代理：方式二

创建代理对象有更简单的方式。

```
1.使用InvocationHandler接口创建代理类的处理器
2.使用Proxy类的静态方法newProxyInstance直接创建代理对象
3.使用代理对象
```

```
@Test
public void m2() {
    // 1. 创建代理类的处理器
    InvocationHandler invocationHandler = (proxy, method, args) -> {
        System.out.println("我是InvocationHandler，被调用的方法是：" + method.getName());
        return null;
    };
    // 2. 创建代理实例
    IService proxyService = (IService) Proxy.newProxyInstance(IService.class.getClassLoader(), new Class[]{IService.class}, invocationHandler);
    // 3. 调用代理的方法
    proxyService.m1();
    proxyService.m2();
    proxyService.m3();
}
```

#### 案例：任意接口中的方法耗时统计

```
public class CostTimeInvocationHandler implements InvocationHandler {
    private Object target;
    public CostTimeInvocationHandler(Object target) {
        this.target = target;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        long starTime = System.nanoTime();
        Object result = method.invoke(this.target, args);//@1
        long endTime = System.nanoTime();
        System.out.println(this.target.getClass() + ".m1()方法耗时(纳秒):" + (endTime - starTime));
        return result;
    }

    public static <T> T createProxy(Object target, Class<T> targetInterface) {
        if (!targetInterface.isInterface()) {
            throw new IllegalStateException("targetInterface必须是接口类型!");
        } else if (!targetInterface.isAssignableFrom(target.getClass())) {
            throw new IllegalStateException("target必须是targetInterface接口的实现类!");
        }
        return (T) Proxy.newProxyInstance(target.getClass().getClassLoader(), target.getClass().getInterfaces(), new CostTimeInvocationHandler(target));
    }
}
```

上面主要是`createProxy`方法用来创建代理对象，2 个参数：

target：目标对象，需要实现 targetInterface 接口

targetInterface：需要创建代理的接口

invoke 方法中通过`method.invoke(this.target, args)`调用目标方法，然后统计方法的耗时。

```
@Test
public void costTimeProxy() {
    IService serviceA = CostTimeInvocationHandler.createProxy(new ServiceA(), IService.class);
    IService serviceB = CostTimeInvocationHandler.createProxy(new ServiceB(), IService.class);
    serviceA.m1();
    serviceA.m2();
    serviceA.m3();

    serviceB.m1();
    serviceB.m2();
    serviceB.m3();
}
```

#### Proxy 使用注意

1. **jdk 中的 Proxy 只能为接口生成代理类，如果你想给某个类创建代理类，那么 Proxy 是无能为力的，此时需要我们用到下面要说的 cglib 了。**
2. **Proxy 类中提供的几个常用的静态方法大家需要掌握**
3. **通过 Proxy 创建代理对象，当调用代理对象任意方法时候，会被 InvocationHandler 接口中的 invoke 方法进行处理，这个接口内容是关键**

### cglib 代理详解

#### 什么是 cglib

jdk 动态代理只能为接口创建代理，使用上有局限性。实际的场景中我们的类不一定有接口，此时如果我们想为普通的类也实现代理功能，我们就需要用到 cglib 来实现了。

cglib 是一个强大、高性能的字节码生成库，它用于在运行时扩展 Java 类和实现接口；本质上它是通过动态的生成一个子类去覆盖所要代理的类（非 final 修饰的类和方法）。Enhancer 可能是 CGLIB 中最常用的一个类，和 jdk 中的 Proxy 不同的是，Enhancer 既能够代理普通的 class，也能够代理接口。Enhancer 创建一个被代理对象的子类并且拦截所有的方法调用（包括从 Object 中继承的 toString 和 hashCode 方法）。Enhancer 不能够拦截 final 方法，例如 Object.getClass() 方法，这是由于 Java final 方法语义决定的。基于同样的道理，Enhancer 也不能对 final 类进行代理操作。

CGLIB 作为一个开源项目，其代码托管在 github，地址为：

```
https://github.com/cglib/cglib
```

#### cglib 组成结构

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213154345.png)



CGLIB 底层使用了 ASM（一个短小精悍的字节码操作框架）来操作字节码生成新的类。除了 CGLIB 库外，脚本语言（如 Groovy 和 BeanShell）也使用 ASM 生成字节码。ASM 使用类似 SAX 的解析器来实现高性能。我们不鼓励直接使用 ASM，因为它需要对 Java 字节码的格式足够的了解。

spring 已将第三方 cglib jar 包中所有的类集成到 spring 自己的 jar 包中

#### 5 个案例来演示 cglib 常见的用法

##### 案例 1：拦截所有方法（MethodInterceptor）

创建一个具体的类，如下：

```
public class Service1 {
    public void m1() {
        System.out.println("我是m1方法");
    }

    public void m2() {
        System.out.println("我是m2方法");
    }
}
```

下面我们为这个类创建一个代理，代理中实现打印每个方法的调用日志

```
public class CglibTest {

    @Test
    public void test1() {
        //使用Enhancer来给某个类创建代理类，步骤
        //1.创建Enhancer对象
        Enhancer enhancer = new Enhancer();
        //2.通过setSuperclass来设置父类型，即需要给哪个类创建代理类
        enhancer.setSuperclass(Service1.class);
        /*3.设置回调，需实现org.springframework.cglib.proxy.Callback接口，
        此处我们使用的是org.springframework.cglib.proxy.MethodInterceptor，也是一个接口，实现了Callback接口，
        当调用代理对象的任何方法的时候，都会被MethodInterceptor接口的invoke方法处理*/
        enhancer.setCallback(new MethodInterceptor() {
            /**
             * 代理对象方法拦截器
             * @param o 代理对象
             * @param method 被代理的类的方法，即Service1中的方法
             * @param objects 调用方法传递的参数
             * @param methodProxy 方法代理对象
             * @return
             * @throws Throwable
             */
            @Override
            public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
                System.out.println("调用方法:" + method);
                //可以调用MethodProxy的invokeSuper调用被代理类的方法
                Object result = methodProxy.invokeSuper(o, objects);
                return result;
            }
        });
        //4.获取代理对象,调用enhancer.create方法获取代理对象，这个方法返回的是Object类型的，所以需要强转一下
        Service1 proxy = (Service1) enhancer.create();
        //5.调用代理对象的方法
        proxy.m1();
        proxy.m2();
    }
}
```

上面代码中的注释很详细，列出了给指定的类创建代理的具体步骤，整个过程中主要用到了 Enhancer 类和`MethodInterceptor`接口。

`enhancer.setSuperclass`用来设置代理类的父类，即需要给哪个类创建代理类，此处是 Service1

`enhancer.setCallback`传递的是`MethodInterceptor`接口类型的参数，`MethodInterceptor`接口有个`intercept`方法，这个方法会拦截代理对象所有的方法调用。

还有一个重点是`Object result = methodProxy.invokeSuper(o, objects);`可以调用被代理类，也就是 Service1 类中的具体的方法，从方法名称的意思可以看出是调用父类，实际对某个类创建代理，cglib 底层通过修改字节码的方式为 Service1 类创建了一个子类。

##### 案例 2：拦截所有方法（MethodInterceptor）

在创建一个类，如下：

```
public class Service2 {
    public void m1() {
        System.out.println("我是m1方法");
        this.m2(); //@1
    }

    public void m2() {
        System.out.println("我是m2方法");
    }
}
```

这个类和上面的 Service1 类似，有点不同是 @1，在 m1 方法中调用了 m2 方法。

下面来采用案例 1 中同样的方式来给 Service2 创建代理，如下：

```
@Test
public void test2() {
    Enhancer enhancer = new Enhancer();
    enhancer.setSuperclass(Service2.class);
    enhancer.setCallback((MethodInterceptor) (o, method, objects, methodProxy) -> {
        System.out.println("调用方法:" + method);
        Object result = methodProxy.invokeSuper(o, objects);
        return result;
    });
    Service2 proxy = (Service2) enhancer.create();
    proxy.m1(); //@1
}
```

从输出中可以看出 m1 和 m2 方法都被拦截器处理了，而 m2 方法是在 Service1 的 m1 方法中调用的，也被拦截处理了

spring 中的 @configuration 注解就是采用这种方式实现的

##### 案例 3：拦截所有方法并返回固定值（FixedValue）

当调用某个类的任何方法的时候，都希望返回一个固定的值，此时可以使用`FixedValue`接口，如下：

```
enhancer.setCallback(new FixedValue() {
            @Override
            public Object loadObject() throws Exception {
                return "111";
            }
        });
```

上面创建的代理对象，调用其任意方法返回的都是 "111"。

案例代码如下：

创建一个类 Service3，如下：

```
public class Service3 {
    public String m1() {
        System.out.println("我是m1方法");
        return "hello:m1";
    }

    public String m2() {
        System.out.println("我是m2方法");
        return "hello:m2";
    }
}
```

```
@Test
public void test3() {
    Enhancer enhancer = new Enhancer();
    enhancer.setSuperclass(Service3.class);
    enhancer.setCallback((FixedValue) () -> "111");
    Service3 proxy = (Service3) enhancer.create();
    System.out.println(proxy.m1());//@1
    System.out.println(proxy.m2()); //@2
    System.out.println(proxy.toString());//@3
}
```

@1、@2、@3 调用了代理对象的 3 个方法，运行输出

##### 案例 4：直接放行，不做任何操作（NoOp.INSTANCE）

`Callback`接口下面有个子接口`org.springframework.cglib.proxy.NoOp`，将这个作为 Callback 的时候，被调用的方法会直接放行，像没有任何代理一样，感受一下效果：

```
@Test
public void test6() {
    Enhancer enhancer = new Enhancer();
    enhancer.setSuperclass(Service3.class);
    enhancer.setCallback(NoOp.INSTANCE);
    Service3 proxy = (Service3) enhancer.create();
    System.out.println(proxy.m1());
    System.out.println(proxy.m2());
}
```

##### 案例 5：不同的方法使用不同的拦截器（CallbackFilter）

```
public class Service4 {
    public void insert1() {
        System.out.println("我是insert1");
    }

    public void insert2() {
        System.out.println("我是insert2");
    }

    public String get1() {
        System.out.println("我是get1");
        return "get1";
    }

    public String get2() {
        System.out.println("我是get2");
        return "get2";
    }
}
```

需求，给这个类创建一个代理需要实现下面的功能：

1. 以 insert 开头的方法需要统计方法耗时
2. 以 get 开头的的方法直接返回固定字符串

```
@Test
public void test4() {
    Enhancer enhancer = new Enhancer();
    enhancer.setSuperclass(Service4.class);
    //创建2个Callback
    Callback[] callbacks = {
            //这个用来拦截所有insert开头的方法
            (MethodInterceptor) (o, method, objects, methodProxy) -> {
                long starTime = System.nanoTime();
                Object result = methodProxy.invokeSuper(o, objects);
                long endTime = System.nanoTime();
                System.out.println(method + "，耗时(纳秒):" + (endTime - starTime));
                return result;
            },
            //下面这个用来拦截所有get开头的方法，返回固定值的
            (FixedValue) () -> "路人甲Java"
    };
    enhancer.setCallbackFilter(method -> 0);
    //调用enhancer的setCallbacks传递Callback数组
    enhancer.setCallbacks(callbacks);
    /**
     * 设置过滤器CallbackFilter
     * CallbackFilter用来判断调用方法的时候使用callbacks数组中的哪个Callback来处理当前方法
     * 返回的是callbacks数组的下标
     */
    enhancer.setCallbackFilter(method -> {
        //获取当前调用的方法的名称
        String methodName = method.getName();
        /**
         * 方法名称以insert开头，
         * 返回callbacks中的第1个Callback对象来处理当前方法，
         * 否则使用第二个Callback处理被调用的方法
         */
        return methodName.startsWith("insert") ? 0 : 1;
    });
    Service4 proxy = (Service4) enhancer.create();
    System.out.println("---------------");
    proxy.insert1();
    System.out.println("---------------");
    proxy.insert2();
    System.out.println("---------------");
    System.out.println(proxy.get1());
    System.out.println("---------------");
    System.out.println(proxy.get2());
}
```

由于需求中要对不同的方法做不同的处理，所以需要有 2 个 Callback 对象，当调用代理对象的方法的时候，具体会走哪个 Callback 呢，此时会通过`CallbackFilter`中的`accept`来判断，这个方法返回`callbacks数组的索引`。

##### 案例 6：对案例 5 的优5化（CallbackHelper）

cglib 中有个 CallbackHelper 类，可以对案例 5 的代码进行有环，CallbackHelper 类相当于对一些代码进行了封装，方便实现案例 5 的需求，实现如下：

```
@Test
public void test5() {
    Enhancer enhancer = new Enhancer();
    //创建2个Callback
    Callback costTimeCallback = (MethodInterceptor) (Object o, Method method, Object[] objects, MethodProxy methodProxy) -> {
        long starTime = System.nanoTime();
        Object result = methodProxy.invokeSuper(o, objects);
        long endTime = System.nanoTime();
        System.out.println(method + "，耗时(纳秒):" + (endTime - starTime));
        return result;
    };
    //下面这个用来拦截所有get开头的方法，返回固定值的
    Callback fixdValueCallback = (FixedValue) () -> "Java";
    CallbackHelper callbackHelper = new CallbackHelper(Service4.class, null) {
        @Override
        protected Object getCallback(Method method) {
            return method.getName().startsWith("insert") ? costTimeCallback : fixdValueCallback;
        }
    };
    enhancer.setSuperclass(Service4.class);
    //调用enhancer的setCallbacks传递Callback数组
    enhancer.setCallbacks(callbackHelper.getCallbacks());
    /**
     * 设置CallbackFilter,用来判断某个方法具体走哪个Callback
     */
    enhancer.setCallbackFilter(callbackHelper);
    Service4 proxy = (Service4) enhancer.create();
    System.out.println("---------------");
    proxy.insert1();
    System.out.println("---------------");
    proxy.insert2();
    System.out.println("---------------");
    System.out.println(proxy.get1());
    System.out.println("---------------");
    System.out.println(proxy.get2());
}
```

输出效果和案例 5 一模一样的，上面重点在于`CallbackHelper`，里面做了一些封装，有兴趣的可以去看一下源码，比较简单。

##### 案例 6：实现通用的统计任意类方法耗时代理类

```
public class CostTimeProxy implements MethodInterceptor {
    //目标对象
    private Object target;

    public CostTimeProxy(Object target) {
        this.target = target;
    }

    @Override
    public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
        long starTime = System.nanoTime();
        //调用被代理对象（即target）的方法，获取结果
        Object result = method.invoke(target, objects); //@1
        long endTime = System.nanoTime();
        System.out.println(method + "，耗时(纳秒)：" + (endTime - starTime));
        return result;
    }

    /**
     * 创建任意类的代理对象
     *
     * @param target
     * @param <T>
     * @return
     */
    public static <T> T createProxy(T target) {
        CostTimeProxy costTimeProxy = new CostTimeProxy(target);
        Enhancer enhancer = new Enhancer();
        enhancer.setCallback(costTimeProxy);
        enhancer.setSuperclass(target.getClass());
        return (T) enhancer.create();
    }
}
```

我们可以直接使用上面的静态方法`createProxy`来为目标对象 target 创建一个代理对象，被代理的对象自动实现方法调用耗时统计。

@1：调用被代理对象的方法获取真正的结果。

使用非常简单，来个测试用例，如下：

```
@Test
public void test7() {
    //创建Service1代理
    Service1 service1 = CostTimeProxy.createProxy(new Service1());
    service1.m1();

    //创建Service3代理
    Service3 service3 = CostTimeProxy.createProxy(new Service3());
    System.out.println(service3.m1());
}
```

### CGLIB 和 Java 动态代理的区别

1. **Java 动态代理只能够对接口进行代理，不能对普通的类进行代理（因为所有生成的代理类的父类为 Proxy，Java 类继承机制不允许多重继承）；CGLIB 能够代理普通类；**
2. **Java 动态代理使用 Java 原生的反射 API 进行操作，在生成类上比较高效；CGLIB 使用 ASM 框架直接对字节码进行操作，在类的执行过程中比较高效**

朋友被阿里面试官灵魂拷问，跑来求救。。。

**最近有个朋友去阿里面试，被面试官来了个灵魂拷问：**

1. **注解是干什么的？**
2. **一个注解可以使用多次么？如何使用？**
3. **@Inherited 是做什么的？**
4. **@Target 中的 `TYPE_PARAMETER 和 TYPE_USER` 用在什么地方？**
5. **泛型中如何使用注解？**
6. **注解定义可以实现继承么？**
7. **spring 中对注解有哪些增强？@Aliasfor 注解是干什么的？**

# 16、注解

## 什么是注解？

注解是给编译器和虚拟机看的，编译器和虚拟机在运行的过程中可以获取注解信息，然后可以根据这些注解的信息做各种想做的事情。比如@Override 就是一个注解，加在方法上，标注当前方法重写了父类的方法，当编译器编译代码的时候，会对 @Override 标注的方法进行验证，验证其父类中是否也有同样签名的方法，否则报错，通过这个注解是不是增强了代码的安全性。

**总的来说：注解是对代码的一种增强，可以在代码编译或者程序运行期间获取注解的信息，然后根据这些信息做各种牛逼的事情。**

## 注解如何使用？

**3 个步骤：**

1. **定义注解**
2. **使用注解**
3. **获取注解信息做各种事情**

## 定义注解

关于注解的定义，先来几个问题：

1. 如何为注解定义参数？
2. 注解可以用在哪里？
3. 注解会被保留到什么时候？

### 定义注解语法

jdk 中注解相关的类和接口都定义在`java.lang.annotation`包中。

注解的定义和我们常见的类、接口类似，只是注解使用`@interface`来定义，如下定义一个名称为`MyAnnotation`的注解：

```
public @interface MyAnnotation {
}
```

### 注解中定义参数

注解有没有参数都可以，定义参数如下：

```
public @interface 注解名称{
    [public] 参数类型 参数名称1() [default 参数默认值];
    [public] 参数类型 参数名称2() [default 参数默认值];
    [public] 参数类型 参数名称n() [default 参数默认值];
}
```

注解中可以定义多个参数，参数的定义有以下特点：

1. 访问修饰符必须为 public，不写默认为 public
2. 该元素的类型只能是基本数据类型、String、Class、枚举类型、注解类型（体现了注解的嵌套效果）以及上述类型的一位数组
3. 该元素的名称一般定义为名词，如果注解中只有一个元素，请把名字起为 value（后面使用会带来便利操作）
4. 参数名称后面的`()`不是定义方法参数的地方，也不能在括号中定义任何参数，仅仅只是一个特殊的语法
5. `default`代表默认值，值必须和第 2 点定义的类型一致
6. 如果没有默认值，代表后续使用注解时必须给该类型元素赋值

### 指定注解的使用范围：@Target

使用 @Target 注解定义注解的使用范围，如下：

```
@Target(value = {ElementType.TYPE,ElementType.METHOD})
public @interface MyAnnotation {
}
```

上面指定了`MyAnnotation`注解可以用在类、接口、注解类型、枚举类型以及方法上面，**自定义注解上也可以不使用 @Target 注解，如果不使用，表示自定义注解可以用在任何地方**。

看一下`@Target`源码：

```
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.ANNOTATION_TYPE)
public @interface Target {
    ElementType[] value();
}
```

有一个参数 value，是 ElementType 类型的一个数组，再来看一下`ElementType`，是个枚举，源码如下：

```
package java.lang.annotation;
/*注解的使用范围*/
public enum ElementType {
       /*类、接口、枚举、注解上面*/
    TYPE,
    /*字段上*/
    FIELD,
    /*方法上*/
    METHOD,
    /*方法的参数上*/
    PARAMETER,
    /*构造函数上*/
    CONSTRUCTOR,
    /*本地变量上*/
    LOCAL_VARIABLE,
    /*注解上*/
    ANNOTATION_TYPE,
    /*包上*/
    PACKAGE,
    /*类型参数上*/
    TYPE_PARAMETER,
    /*类型名称上*/
    TYPE_USE
}
```

### 指定注解的保留策略：@Retention

我们先来看一下 java 程序的 3 个过程

1. 源码阶段
2. 源码被编译为字节码之后变成 class 文件
3. 字节码被虚拟机加载然后运行

那么自定义注解会保留在上面哪个阶段呢？可以通过`@Retention`注解来指定，如：

```
@Retention(RetentionPolicy.SOURCE)
public @interface MyAnnotation {
}
```

上面指定了`MyAnnotation`只存在于源码阶段，后面的 2 个阶段都会丢失。

来看一下 @Retention

```
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.ANNOTATION_TYPE)
public @interface Retention {
    RetentionPolicy value();
}
```

有一个 value 参数，类型为 RetentionPolicy 枚举，如下：

```
public enum RetentionPolicy {
    /*注解只保留在源码中，编译为字节码之后就丢失了，也就是class文件中就不存在了*/
    SOURCE,
    /*注解只保留在源码和字节码中，运行阶段会丢失*/
    CLASS,
    /*源码、字节码、运行期间都存在*/
    RUNTIME
}
```

## 使用注解

### 语法

将注解加载使用的目标上面，如下：

```
@注解名称(参数1=值1,参数2=值2,参数n=值n)
目标对象
```

### 无参注解

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@interface Ann1 { //@1
}

@Ann1 //@2
public class UseAnnotation1 {
}
```

@1：Ann1 为无参注解

@2：类上使用 @Ann1 注解，没有参数

### 一个参数的注解

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@interface Ann2 { //@1
    String name();
}

@Ann2(name = "java") //@2
public class UseAnnotation2 {

}
```

### 一个参数为 value 的注解，可以省略参数名称

只有一个参数，名称为 value 的时候，使用时参数名称可以省略

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@interface Ann3 {
    String value();//@1
}

@Ann3("java") //@2
public class UseAnnotation3 {

}
```

@1：注解之后一个参数，名称为 value

@2：使用注解，参数名称 value 省略了

### 数组类型参数

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@interface Ann4 {
    String[] name();//@1
}

@Ann4(name = {"java", "spring"}) //@2
public class UseAnnotation4 {
    @Ann4("如果只有一个值，{}可以省略") //@3
    public class T1 {
    }
}
```

@1：name 的类型是一个 String 类型的数组

@2：name 有多个值的时候，需要使用 {} 包含起来

@3：如果 name 只有一个值，{} 可以省略

### 为参数指定默认值

通过 default 为参数指定默认值，用的时候如果没有设置值，则取默认值，没有指定默认值的参数，使用的时候必须为参数设置值，如下：

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@interface Ann5 {
    String[] name() default {"java", "spring"};//@1
    int[] score() default 1; //@2
    int age() default 30; //@3
    String address(); //@4
}

@Ann5(age = 32,address = "上海") //@5
public class UseAnnotation5 {

}
```

@1：数组类型通过 {} 指定默认值

@2：数组类型参数，默认值只有一个省略了 {} 符号

@3：默认值为 30

@4：未指定默认值

@5：age=32 对默认值进行了覆盖，并且为 address 指定了值

### 综合案例

```
@Target(value = {
        ElementType.TYPE,
        ElementType.METHOD,
        ElementType.FIELD,
        ElementType.PARAMETER,
        ElementType.CONSTRUCTOR,
        ElementType.LOCAL_VARIABLE
})
@Retention(RetentionPolicy.RUNTIME)
@interface Ann6 {
    String value();

    ElementType elementType();
}

@Ann6(value = "我用在类上", elementType = ElementType.TYPE)
public class UseAnnotation6 {
    @Ann6(value = "我用在字段上", elementType = ElementType.FIELD)
    private String a;

    @Ann6(value = "我用在构造方法上", elementType = ElementType.CONSTRUCTOR)
    public UseAnnotation6(@Ann6(value = "我用在方法参数上", elementType = ElementType.PARAMETER) String a) {
        this.a = a;
    }

    @Ann6(value = "我用在了普通方法上面", elementType = ElementType.METHOD)
    public void m1() {
        @Ann6(value = "我用在了本地变量上", elementType = ElementType.LOCAL_VARIABLE) String a;
    }
}
```

上面演示了自定义注解在在类、字段、构造器、方法参数、方法、本地变量上的使用，@Ann6 注解有个`elementType`参数，我想通过这个参数的值来告诉大家对应 @Target 中的那个值来限制使用目标的，大家注意一下上面每个`elementType`的值。

### @Target(ElementType.TYPE_PARAMETER)

这个是 1.8 加上的，用来标注类型参数，类型参数一般在类后面声明或者方法上声明，这块需要先了解一下泛型，不然理解起来比较吃力，来个案例感受一下：

```

@Target(value = {
        ElementType.TYPE_PARAMETER
})
@Retention(RetentionPolicy.RUNTIME)
@interface Ann7 {
    String value();
}

public class UseAnnotation7<@Ann7("T0是在类上声明的一个泛型类型变量") T0, @Ann7("T1是在类上声明的一个泛型类型变量") T1> {

    public static void main(String[] args) throws NoSuchMethodException {
        for (TypeVariable typeVariable : UseAnnotation7.class.getTypeParameters()) {
            print(typeVariable);
        }

        for (TypeVariable typeVariable : UseAnnotation7.class.getDeclaredMethod("m1").getTypeParameters()) {
            print(typeVariable);
        }
    }

    private static void print(TypeVariable typeVariable) {
        System.out.println("类型变量名称:" + typeVariable.getName());
        Arrays.stream(typeVariable.getAnnotations()).forEach(System.out::println);
    }

    public <@Ann7("T2是在方法上声明的泛型类型变量") T2> void m1() {
    }
}
```

### @Target(ElementType.TYPE_USE)

这个是 1.8 加上的，能用在任何类型名称上，来个案例感受一下：

```
@Target({ElementType.TYPE_USE})
@Retention(RetentionPolicy.RUNTIME)
@interface Ann10 {
    String value();
}

@Ann10("用在了类上")
public class UserAnnotation10<@Ann10("用在了类变量类型V1上") V1, @Ann10("用在了类变量类型V2上") V2> {

    private Map<@Ann10("用在了泛型类型上") String, Integer> map;

    public <@Ann10("用在了参数上") T> String m1(String name) {
        return null;
    }

}
```

类后面的 V1、V2 都是类型名称，Map 后面的尖括号也是类型名称，m1 方法前面也定义了一个类型变量，名称为 T

## 注解信息的获取

为了运行时能准确获取到注解的相关信息，Java 在`java.lang.reflect` 反射包下新增了`AnnotatedElement`接口，它主要用于表示目前正在虚拟机中运行的程序中已使用注解的元素，通过该接口提供的方法可以利用反射技术地读取注解的信息，看一下 UML 图:

![图片](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213161832.webp)

- Package：用来表示包的信息
- Class：用来表示类的信息
- Constructor：用来表示构造方法信息
- Field：用来表示类中属性信息
- Method：用来表示方法信息
- Parameter：用来表示方法参数信息
- TypeVariable：用来表示类型变量信息，如：类上定义的泛型类型变量，方法上面定义的泛型类型变量

### AnnotatedElement 常用方法

![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213161858.png)



### 案例

```
@Target({ElementType.PACKAGE,
        ElementType.TYPE,
        ElementType.FIELD,
        ElementType.CONSTRUCTOR,
        ElementType.METHOD,
        ElementType.PARAMETER,
        ElementType.TYPE_PARAMETER,
        ElementType.TYPE_USE})
@Retention(RetentionPolicy.RUNTIME)
@interface Ann11 {
    String value();
}

@Target({ElementType.PACKAGE,
        ElementType.TYPE,
        ElementType.FIELD,
        ElementType.CONSTRUCTOR,
        ElementType.METHOD,
        ElementType.PARAMETER,
        ElementType.TYPE_PARAMETER,
        ElementType.TYPE_USE})
@Retention(RetentionPolicy.RUNTIME)
@interface Ann11_0 {
    int value();
}

@Ann11("用在了类上")
@Ann11_0(0)
public class UseAnnotation11<@Ann11("用在了类变量类型V1上") @Ann11_0(1) V1, @Ann11("用在了类变量类型V2上") @Ann11_0(2) V2> {
    @Ann11("用在了字段上")
    @Ann11_0(3)
    private String name;

    private Map<@Ann11("用在了泛型类型上,String") @Ann11_0(4) String, @Ann11("用在了泛型类型上,Integer") @Ann11_0(5) Integer> map;

    @Ann11("用在了构造方法上")
    @Ann11_0(6)
    public UseAnnotation11() {
        this.name = name;
    }

    @Ann11("用在了返回值上")
    @Ann11_0(7)
    public String m1(@Ann11("用在了参数上") @Ann11_0(8) String name) {
        return null;
    }

}
```

#### 解析类上的注解

```
@Ann11("用在了类上")
```

```
@Test
public void m1() {
    for (Annotation annotation : UseAnnotation11.class.getAnnotations()) {
        System.out.println(annotation);
    }
}
```

#### 解析类上的类型变量

解析类名后面的尖括号的部分，即下面的部分：

```
UseAnnotation11<@Ann11("用在了类变量类型V1上") @Ann11_0(1) V1, @Ann11("用在了类变量类型V2上") @Ann11_0(2) V2>
```

```
@Test
public void m2() {
    TypeVariable<Class<UseAnnotation11>>[] typeParameters = UseAnnotation11.class.getTypeParameters();
    for (TypeVariable<Class<UseAnnotation11>> typeParameter : typeParameters) {
        System.out.println(typeParameter.getName() + "变量类型注解信息：");
        Annotation[] annotations = typeParameter.getAnnotations();
        for (Annotation annotation : annotations) {
            System.out.println(annotation);
        }
    }
}
```

#### 解析字段 name 上的注解

```
@Test
public void m3() throws NoSuchFieldException {
    Field nameField = UseAnnotation11.class.getDeclaredField("name");
    for (Annotation annotation : nameField.getAnnotations()) {
        System.out.println(annotation);
    }
}
```

#### 解析泛型字段 map 上的注解

```
@Test
public void m4() throws NoSuchFieldException {
    Field field = UseAnnotation11.class.getDeclaredField("map");
    Type genericType = field.getGenericType();
    Type[] actualTypeArguments = ((ParameterizedType) genericType).getActualTypeArguments();
    AnnotatedType annotatedType = field.getAnnotatedType();
    AnnotatedType[] annotatedActualTypeArguments = ((AnnotatedParameterizedType) annotatedType).getAnnotatedActualTypeArguments();
    int i = 0;
    for (AnnotatedType actualTypeArgument : annotatedActualTypeArguments) {
        Type actualTypeArgument1 = actualTypeArguments[i++];
        System.out.println(actualTypeArgument1.getTypeName() + "类型上的注解如下：");
        for (Annotation annotation : actualTypeArgument.getAnnotations()) {
            System.out.println(annotation);
        }
    }
}
```

#### 解析构造函数上的注解

```
@Test
public void m5() {
    Constructor<?> constructor = UseAnnotation11.class.getConstructors()[0];
    for (Annotation annotation : constructor.getAnnotations()) {
        System.out.println(annotation);
    }
}
```

#### 解析 m1 方法上的注解

```
@Test
public void m6() throws NoSuchMethodException {
    Method method = UseAnnotation11.class.getMethod("m1", String.class);
    for (Annotation annotation : method.getAnnotations()) {
        System.out.println(annotation);
    }
}
```

#### 解析 m1 方法参数注解

```
@Test
public void m7() throws NoSuchMethodException {
    Method method = UseAnnotation11.class.getMethod("m1", String.class);
    for (Parameter parameter : method.getParameters()) {
        System.out.println(String.format("参数%s上的注解如下:", parameter.getName()));
        for (Annotation annotation : parameter.getAnnotations()) {
            System.out.println(annotation);
        }
    }
}
```

##### 上面参数名称为 arg0，如果想让参数名称和源码中真实名称一致，操作如下：

```
如果你编译这个class的时候没有添加参数–parameters，运行的时候你会得到这个结果：

Parameter: arg0

编译的时候添加了–parameters参数的话，运行结果会不一样：

Parameter: args

对于有经验的Maven使用者，–parameters参数可以添加到maven-compiler-plugin的配置部分：

<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.1</version>
    <configuration>
        <compilerArgument>-parameters</compilerArgument>
        <source>1.8</source>
        <target>1.8</target>
    </configuration>
</plugin>
```

## @Inherit：实现类之间的注解继承

### 用法

来看一下这个注解的源码

```
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.ANNOTATION_TYPE)
public @interface Inherited {
}
```

我们通过 @Target 元注解的属性值可以看出，这个 @Inherited 是专门修饰注解的。

**作用：让子类可以继承父类中被 @Inherited 修饰的注解，注意是继承父类中的，如果接口中的注解也使用 @Inherited 修饰了，那么接口的实现类是无法继承这个注解的**

### 案例

```
public class InheritAnnotationTest {
    public static void main(String[] args) {
        for (Annotation annotation : C2.class.getAnnotations()) { //@6
            System.out.println(annotation);
        }
    }

    @Target(ElementType.TYPE)
    @Retention(RetentionPolicy.RUNTIME)
    @Inherited
    @interface A1 { //@1
    }

    @Target(ElementType.TYPE)
    @Retention(RetentionPolicy.RUNTIME)
    @Inherited
    @interface A2 { //@2
    }

    @A1 //@3
    interface I1 {
    }

    @A2 //@4
    static class C1 {
    }

    static class C2 extends C1 implements I1 {
    } //@5
}
```

@1：定义了一个注解 A1，上面使用了 @Inherited，表示这个具有继承功能

@2：定义了一个注解 A2，上面使用了 @Inherited，表示这个具有继承功能

@3：定义接口 I1，上面使用了 @A1 注解

@4：定义了一个 C1 类，使用了 A2 注解

@5：C2 继承了 C1 并且实现了 I1 接口

@6：获取 C2 上以及从父类继承过来的所有注解，然后输出

运行输出：

```
@com.InheritAnnotationTest$A2()
```

**从输出中可以看出类可以继承父类上被 @Inherited 修饰的注解，而不能继承接口上被 @Inherited 修饰的注解，这个一定要注意**

## @Repeatable 重复使用注解

来看一段代码：

```
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@interface Ann12{}

@Ann12
@Ann12
public class UseAnnotation12 {
}
```

上面代码会报错，原因是：UseAnnotation12 上面重复使用了 @Ann12 注解，默认情况下 @Ann12 注解是不允许重复使用的。

像上面这样，如果我们想重复使用注解的时候，需要用到`@Repeatable`注解

### 使用步骤

#### 先定义容器注解

```
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.FIELD})
@interface Ann12s {
    Ann12[] value(); //@1
}
```

容器注解中必须有个 value 类型的参数，参数类型为子注解类型的数组。

#### 为注解指定容器

要让一个注解可以重复使用，需要在注解上加上 @Repeatable 注解，@Repeatable 中 value 的值为容器注解，如下代码中的 @2

```
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.FIELD})
@Repeatable(Ann12s.class)//@2
@interface Ann12 {
    String name();
}
```

#### 使用注解

重复使用相同的注解有 2 种方式，如下面代码

1. 重复使用注解，如下面的类上重复使用 @Ann12 注解
2. 通过容器注解来使用更多个注解，如下面的字段 v1 上使用 @Ann12s 容器注解

```
@Ann12(name = "Java")
@Ann12(name = "Spring")
public class UseAnnotation12 {
    @Ann12s(
            {@Ann12(name = "Java"),
                    @Ann12(name = "mysql")}
    )
    private String v1;
}
```

#### 获取注解信息

```
@Test
public void test1() throws NoSuchFieldException {
    Annotation[] annotations = UseAnnotation12.class.getAnnotations();
    for (Annotation annotation : annotations) {
        System.out.println(annotation);
    }
    System.out.println("-------------");
    Field v1 = UseAnnotation12.class.getDeclaredField("v1");
    Annotation[] declaredAnnotations = v1.getDeclaredAnnotations();
    for (Annotation declaredAnnotation : declaredAnnotations) {
        System.out.println(declaredAnnotation);
    }
}
```

## 先看一个问题

代码如下：

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@interface A1 {
    String value() default "a";//@0
}

@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@A1
@interface B1 { //@1
    String value() default "b";//@2
}

@B1("Java") //@3
public class UseAnnotation13 {
    @Test
    public void test1() {
        //AnnotatedElementUtils是spring提供的一个查找注解的工具类
        System.out.println(AnnotatedElementUtils.getMergedAnnotation(UseAnnotation13.class, B1.class));
        System.out.println(AnnotatedElementUtils.getMergedAnnotation(UseAnnotation13.class, A1.class));
    }
}
```

@0：A1 注解 value 参数值默认为 a

@1：B1 注解上使用到了 @A1 注解

@2：B1 注解 value 参数值默认为 b

@2：UseAnnotation13 上面使用了 @B1 注解，value 参数的值为：java

test1 方法中使用到了 spring 中的一个类`AnnotatedElementUtils`，通过这个工具类可以很方便的获取注解的各种信息，方法中的 2 行代码用于获取 UseAnnotation13 类上 B1 注解和 A1 注解的信息。

运行 test1 方法输出：

```
@com.B1(value=Java)
@com.A1(value=a)
```

上面用法很简单，没什么问题。

**此时有个问题：此时如果想在`UseAnnotation13`上给 B1 上的 A1 注解设置值是没有办法的，注解定义无法继承导致的，如果注解定义上面能够继承，那用起来会爽很多，spring 通过 @Aliasfor 方法解决了这个问题。**

## Spring  @AliasFor：对注解进行增强

### 案例 1：通过 @AliasFor 解决刚才难题

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@interface A14 {
    String value() default "a";//@0
}

@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@A14 //@6
@interface B14 { //@1
    String value() default "b";//@2
    @AliasFor(annotation = A14.class, value = "value") //@5
    String a14Value();
}

@B14(value = "Java",a14Value = "通过B14给A14的value参数赋值") //@3
public class UseAnnotation14 {
    @Test
    public void test1() {
        //AnnotatedElementUtils是spring提供的一个查找注解的工具类
        System.out.println(AnnotatedElementUtils.getMergedAnnotation(UseAnnotation14.class, B14.class));
        System.out.println(AnnotatedElementUtils.getMergedAnnotation(UseAnnotation14.class, A14.class));
    }
}
```

运行输出：

```
@com.B14(a14Value=通过B14给A14的value参数赋值, value=Java)
@com.A14(value=通过B14给A14的value参数赋值)
```

注意上面 diam 的 @3 只使用了 B14 注解，大家认真看一下，上面输出汇总可以看出 A14 的 value 值和 B14 的 a14Value 参数值一样，说明通过 B14 给 A14 设置值成功了。

重点在于代码 @5，这个地方使用到了`@AliasFor`注解：

```
@AliasFor(annotation = A14.class, value = "value")
```

**这个相当于给某个注解指定别名，即将 B1 注解中`a14Value`参数作为`A14`中`value`参数的别名，当给`B1的a14Value`设置值的时候，就相当于给`A14的value设置值`，有个前提是 @AliasFor 注解的`annotation`参数指定的注解需要加载当前注解上面，如：@6**

### 案例 2：同一个注解中使用 @AliasFor

```
@Target({ElementType.TYPE, ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@interface A15 {
    @AliasFor("v2")//@1
    String v1() default "";

    @AliasFor("v1")//@2
    String v2() default "";
}

@A15(v1 = "我是v1") //@3
public class UseAnnotation15 {

    @A15(v2 = "我是v2") //@4
    private String name;

    @Test
    public void test1() throws NoSuchFieldException {
        //AnnotatedElementUtils是spring提供的一个查找注解的工具类
        System.out.println(AnnotatedElementUtils.getMergedAnnotation(UseAnnotation15.class, A15.class));
        System.out.println(AnnotatedElementUtils.getMergedAnnotation(UseAnnotation15.class.getDeclaredField("name"), A15.class));
    }
}
```

注意上面代码，A15 注解中（@1 和 @2）的 2 个参数都设置了 @AliasFor，@AliasFor 如果不指定`annotation`参数的值，那么`annotation`默认值就是当前注解，所以上面 2 个属性互为别名，当给 v1 设置值的时候也相当于给 v2 设置值，当给 v2 设置值的时候也相当于给 v1 设置值。

运行输出

```
@com.A15(v1=我是v1, v2=我是v1)
@com.A15(v1=我是v2, v2=我是v2)
```

从输出中可以看出 v1 和 v2 的值始终是相等的，上面如果同时给 v1 和 v2 设置值的时候运行代码会报错。

我们回头来看看 @AliasFor 的源码：

```
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@Documented
public @interface AliasFor {

    @AliasFor("attribute")
    String value() default "";

    @AliasFor("value")
    String attribute() default "";

    Class<? extends Annotation> annotation() default Annotation.class;

}
```

AliasFor 注解中`value`和`attribute`互为别名，随便设置一个，同时会给另外一个设置相同的值。

### 案例 2：@AliasFor 中不指定 value 和 attribute

当 @AliasFor 中不指定 value 或者 attribute 的时候，自动将 @AliasFor 修饰的参数作为 value 和 attribute 的值，如下 @AliasFor 注解的 value 参数值为 name

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@interface A16 {
    String name() default "a";//@0
}

@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@A16
@interface B16 { //@1
    @AliasFor(annotation = A16.class) //@5
    String name() default "b";//@2
}

@B16(name="我是v1") //@3
public class UseAnnotation16 {
    @Test
    public void test1() throws NoSuchFieldException {
        //AnnotatedElementUtils是spring提供的一个查找注解的工具类
        System.out.println(AnnotatedElementUtils.getMergedAnnotation(UseAnnotation16.class, A16.class));
        System.out.println(AnnotatedElementUtils.getMergedAnnotation(UseAnnotation16.class, B16.class));
    }
}
```

运行输出：

```
@com.A16(name=我是v1)
@com.B16(name=我是v1)
```

# 17、@Configration、@Bean

## @Configuration 注解

@Configuration 这个注解可以加在类上，让这个类的功能等同于一个 bean xml 配置文件，如下：

```
@Configuration
public class ConfigBean {
}
```

上面代码类似于下面的 xml：

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-4.3.xsd">

</beans>
```

通过`AnnotationConfigApplicationContext`来加载`@Configuration`修饰的类，如下：

```
AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(ConfigBean.class);
```

此时 ConfigBean 类中没有任何内容，相当于一个空的 xml 配置文件，此时我们要在 ConfigBean 类中注册 bean，那么我们就要用到 @Bean 注解了。

`@Configuration`使用步骤：

1. 在类上使用`@Configuration`注解
2. 通过`AnnotationConfigApplicationContext`容器来加`@Configuration`注解修饰的类

## @Bean 注解

这个注解类似于 bean xml 配置文件中的 bean 元素，用来在 spring 容器中注册一个 bean。

@Bean 注解用在方法上，表示通过方法来定义一个 bean，默认将方法名称作为 bean 名称，将方法返回值作为 bean 对象，注册到 spring 容器中。

如：

```
@Bean
public User user1() {
    return new User();
}
```

@Bean 注解还有很多属性，我们来看一下其源码：

```
@Target({ElementType.METHOD, ElementType.ANNOTATION_TYPE}) //@1
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Bean {

    @AliasFor("name")
    String[] value() default {};

    @AliasFor("value")
    String[] name() default {};

    @Deprecated
    Autowire autowire() default Autowire.NO;

    boolean autowireCandidate() default true;

    String initMethod() default "";

    String destroyMethod() default AbstractBeanDefinition.INFER_METHOD;
}
```

@1：说明这个注解可以用在方法和注解类型上面。

每个参数含义：

1. value 和 name 是一样的，设置的时候，这 2 个参数只能选一个，原因是 @AliasFor 导致的
2. value：字符串数组，第一个值作为 bean 的名称，其他值作为 bean 的别名
3. autowire：这个参数上面标注了 @Deprecated，表示已经过期了，不建议使用了
4. autowireCandidate：是否作为其他对象注入时候的候选 bean
5. initMethod：bean 初始化的方法，这个和生命周期有关，以后详解
6. destroyMethod：bean 销毁的方法，也是和生命周期相关的，以后详解

### 案例

```
public class User {
}
```

```
@Configuration
public class ConfigBean {

    //bean名称为方法默认值：user1
    @Bean
    public User user1() {
        return new User();
    }

    //bean名称通过value指定了：user2Bean
    @Bean("user2Bean")
    public User user2() {
        return new User();
    }

    //bean名称为：user3Bean，2个别名：[user3BeanAlias1,user3BeanAlias2]
    @Bean({"user3Bean", "user3BeanAlias1", "user3BeanAlias2"})
    public User user3() {
        return new User();
    }

}
```

```
public class ConfigurationTest {
    @Test
    public void test1() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(ConfigBean.class);//@1
        for (String beanName : context.getBeanDefinitionNames()) {
            //别名
            String[] aliases = context.getAliases(beanName);
            System.out.println(String.format("bean名称:%s,别名:%s,bean对象:%s",
                    beanName,
                    Arrays.asList(aliases),
                    context.getBean(beanName)));
        }
    }
}
```

@1：通过`AnnotationConfigApplicationContext`来加载配置类`ConfigBean`，会将配置类中所有的 bean 注册到 spring 容器中

for 循环中输出了 bean 名称、别名、bean 对象

![image-20201213164613095](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213164613.png)

上面的输出，我们主要关注与最后 4 行，前面的可以先忽略。

从输出中可以看出，有个名称为`configBean`的 bean，正是 ConfigBean 这个类型，可以得出，被 @Configuration 修饰的类，也被注册到 spring 容器中了

最后 3 行输出就是几个 User 的 bean 对象了。

## 去掉 @Configuration 会怎样？

```
public class ConfigBean1 {

    //bean名称为方法默认值：user1
    @Bean
    public User user1() {
        return new User();
    }

    //bean名称通过value指定了：user2Bean
    @Bean("user2Bean")
    public User user2() {
        return new User();
    }

    //bean名称为：user3Bean，2个别名：[user3BeanAlias1,user3BeanAlias2]
    @Bean({"user3Bean", "user3BeanAlias1", "user3BeanAlias2"})
    public User user3() {
        return new User();
    }
}
```

```
@Test
public void test2() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(ConfigBean1.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        //别名
        String[] aliases = context.getAliases(beanName);
        System.out.println(String.format("bean名称:%s,别名:%s,bean对象:%s",
                beanName,
                Arrays.asList(aliases),
                context.getBean(beanName)));
    }
}
```

![image-20201213164813091](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213164813.png)

有 @Configuration 注解的

![image-20201213164943770](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213164943.png)

没有 @Configuration 注解的

![image-20201213165021894](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213165021.png)

对比得出

1. 对比最后 3 行，可以看出：**有没有 @Configuration 注解，@Bean 都会起效，都会将 @Bean 修饰的方法作为 bean 注册到容器中**
2. 两个内容的第一行有点不一样，被 @Configuration 修饰的 bean 最后输出的时候带有`EnhancerBySpringCGLIB`的字样，而没有 @Configuration 注解的 bean 没有 Cglib 的字样；有`EnhancerBySpringCGLIB`字样的说明这个 bean 被 cglib 处理过的，变成了一个代理对象。

## @Configuration 加不加到底区别在哪？

通常情况下，bean 之间是有依赖关系的，我们来创建个有依赖关系的 bean，通过这个案例你就可以看出根本的区别了

```
public class ServiceA {
}
```

```
@AllArgsConstructor
@ToString
public class ServiceB {
    private ServiceA serviceA;
}
```

ServiceB 依赖于 ServiceA，ServiceB 通过构造器注入 ServiceA。

来个 @Configuration 类管理上面对象

```
@Configuration
public class ConfigBean2 {

    @Bean
    public ServiceA serviceA() {
        System.out.println("调用serviceA()方法"); //@0
        return new ServiceA();
    }

    @Bean
    ServiceB serviceB1() {
        System.out.println("调用serviceB1()方法");
        ServiceA serviceA = this.serviceA(); //@1
        return new ServiceB(serviceA);
    }

    @Bean
    ServiceB serviceB2() {
        System.out.println("调用serviceB2()方法");
        ServiceA serviceA = this.serviceA(); //@2
        return new ServiceB(serviceA);
    }
}
```

上面通过 @Bean 注解，向容器中注册了 3 个 bean

注意 @1 和 @2，通过 this.serviceA() 获取需要注入的 ServiceA 对象。

上面每个方法第一行都输出了一行日志。

**重点关注一下 @0 这行日志会输出几次，大家先思考一下 1 次还是 3 次？**

```
@Test
public void test3() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(ConfigBean2.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        //别名
        String[] aliases = context.getAliases(beanName);
        System.out.println(String.format("bean名称:%s,别名:%s,bean对象:%s",
                beanName,
                Arrays.asList(aliases),
                context.getBean(beanName)));
    }
}
```

![image-20201213180741469](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213180741.png)

从输出中可以看出

1. **前三行可以看出，被 @Bean 修饰的方法都只被调用了一次，这个很关键**
2. **最后三行中可以看出都是同一个 ServiceA 对象

这是为什么？

被 @Configuration 修饰的类，spring 容器中会通过 cglib 给这个类创建一个代理，代理会拦截所有被@Bean修饰的方法，默认情况（bean 为单例）下确保这些方法只被调用一次，从而确保这些 bean 是同一个 bean，即单例的。

我们再来看看将 ConfigBean2 上的的 @Configuration 去掉，效果如何，代码就不写了，直接上输出结果：

![image-20201213190740482](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201213190740.png)

结果分析

1. serviceA() 方法被调用了 3 次
2. configBean2 这个 bean 没有代理效果了
3. 最后 3 行可以看出，几个 ServiceA 对象都是不一样的

## spring 这块的源码

spring 中用下面这个类处理 @Configuration 这个注解：

```
org.springframework.context.annotation.ConfigurationClassPostProcessor
```

这里面重点关注这几个方法：

```
public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) 
public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory)
public void enhanceConfigurationClasses(ConfigurableListableBeanFactory beanFactory) 
```

最后一个方法会创建 cglib 代理

## 总结

1. @Configuration 注解修饰的类，会被 spring 通过 cglib 做增强处理，通过 cglib 会生成一个代理对象，代理会拦截所有被 @Bean 注解修饰的方法，可以确保一些 bean 是单例的
2. 不管 @Bean 所在的类上是否有 @Configuration 注解，都可以将 @Bean 修饰的方法作为一个 bean 注册到 spring 容器中

面试官说：Spring 这几个问题你回答下，月薪 3 万，下周来上班！

# 18、@ComponentScan、@ComponentScans

## @ComponentScan

@ComponentScan 用于批量注册 bean。

这个注解会让 spring 去扫描某些包及其子包中所有的类，然后将满足一定条件的类作为 bean 注册到 spring 容器容器中。

先来看一下这个注解的定义：

```
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Documented
@Repeatable(ComponentScans.class) //@1
public @interface ComponentScan {

    @AliasFor("basePackages")
    String[] value() default {};

    @AliasFor("value")
    String[] basePackages() default {};

    Class<?>[] basePackageClasses() default {};

    Class<? extends BeanNameGenerator> nameGenerator() default BeanNameGenerator.class;

    Class<? extends ScopeMetadataResolver> scopeResolver() default AnnotationScopeMetadataResolver.class;

    ScopedProxyMode scopedProxy() default ScopedProxyMode.DEFAULT;

    String resourcePattern() default "**/*.class";

    boolean useDefaultFilters() default true;

    Filter[] includeFilters() default {};

    Filter[] excludeFilters() default {};

    boolean lazyInit() default false;
}
```

定义上可以看出此注解可以用在任何类型上面，不过我们通常将其用在类上面。

常用参数：

value：指定需要扫描的包，如：com

basePackages：作用同 value；value 和 basePackages 不能同时存在设置，可二选一

basePackageClasses：指定一些类，spring 容器会扫描这些类所在的包及其子包中的类

nameGenerator：自定义 bean 名称生成器

resourcePattern：需要扫描包中的那些资源，默认是：**/*.class，即会扫描指定包中所有的 class 文件

useDefaultFilters：对扫描的类是否启用默认过滤器，默认为 true

includeFilters：过滤器：用来配置被扫描出来的那些类会被作为组件注册到容器中

excludeFilters：过滤器，和 includeFilters 作用刚好相反，用来对扫描的类进行排除的，被排除的类不会被注册到容器中

lazyInit：是否延迟初始化被注册的 bean

@1：@Repeatable(ComponentScans.class)，这个注解可以同时使用多个。

**@ComponentScan 工作的过程：**

1. **Spring 会扫描指定的包，且会递归下面子包，得到一批类的数组**
2. **然后这些类会经过上面的各种过滤器，最后剩下的类会被注册到容器中**

**所以玩这个注解，主要关注 2 个问题：**

**第一个：需要扫描哪些包？通过`value、backPackages、basePackageClasses`这 3 个参数来控制**

**第二：过滤器有哪些？通过`useDefaultFilters、includeFilters、excludeFilters`这 3 个参数来控制过滤器**

**这两个问题搞清楚了，就可以确定哪些类会被注册到容器中。**

**默认情况下，任何参数都不设置的情况下，此时，会将 @ComponentScan 修饰的类所在的包作为扫描包；默认情况下 useDefaultFilters 为 true，这个为 true 的时候，spring 容器内部会使用默认过滤器，规则是：凡是类上有`@Repository、@Service、@Controller、@Component`这几个注解中的任何一个的，那么这个类就会被作为 bean 注册到 spring 容器中，所以默认情况下，只需在类上加上这几个注解中的任何一个，这些类就会自动交给 spring 容器来管理了。**

## @Component、@Repository、@Service、@Controller

这几个注解都是 spring 提供的。

先说一下`@Component`这个注解，看一下其定义：

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Indexed
public @interface Component {
    String value() default "";
}
```

从定义中可以看出，这个注解可以用在任何类型上面。

通常情况下将这个注解用在类上面，标注这个类为一个组件，默认情况下，被扫描的时候会被作为 bean 注册到容器中。

value 参数：被注册为 bean 的时候，用来指定 bean 的名称，如果不指定，默认为类名首字母小写。如：类 UserService 对应的 beanname 为 userService

再来看看`@Repository`源码如下：

```
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Component
public @interface Repository {

    @AliasFor(annotation = Component.class)
    String value() default "";

}
```

Repository 上面有 @Component 注解。

value 参数上面有`@AliasFor(annotation = Component.class)`，设置 value 参数的时候，也相当于给`@Component`注解中的 value 设置值。

其他两个注解`@Service、@Controller`源码和`@Repository`源码类似。

这 4 个注解本质上是没有任何差别，都可以用在类上面，表示这个类被 spring 容器扫描的时候，可以作为一个 bean 组件注册到 spring 容器中。

spring 容器中对这 4 个注解的解析并没有进行区分，统一采用`@Component`注解的方式进行解析，所以这几个注解之间可以相互替换。

spring 提供这 4 个注解，是为了让系统更清晰，通常情况下，系统是分层结构的，多数系统一般分为 controller 层、service 层、dao 层。

@controller 通常用来标注 controller 层组件，@service 注解标注 service 层的组件，@Repository 标注 dao 层的组件，这样可以让整个系统的结构更清晰，当看到这些注解的时候，会和清晰的知道属于哪个层，对于 spring 来说，将这 3 个注解替换成 @Component 注解，对系统没有任何影响，产生的效果是一样的。

下面通过案例来感受 @ComponentScan 各种用法。

### 案例 1：任何参数未设置

```
@Controller
public class UserController {
}
```

```
@Service
public class UserService {
}
```

```
@Repository
public class UserDao {
}
```

```
@Component
public class UserModel {
}
```

```
@ComponentScan
public class ScanBean1 {
}
```

```
@Test
public void test1() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(ScanBean1.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(beanName + "->" + context.getBean(beanName));
    }
}
```

@1：使用 AnnotationConfigApplicationContext 作为 ioc 容器，将`ScanBean`作为参数传入。

默认会扫描`ScanBean`类所在的包中的所有类，类上有 @Component、@Repository、@Service、@Controller 任何一个注解的都会被注册到容器中

### 案例 2：指定需要扫描的包

指定需要扫毛哪些包，可以通过 value 或者 basePackage 来配置，二者选其一，都配置运行会报错，下面我们通过 value 来配置。

```
@ComponentScan({
        "com.controller",
        "com.service"
})
public class ScanBean2 {
}
```

上面指定了 2 需要扫描的包，这两个包中有 2 个类。

```
@Test
public void test2() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(ScanBean2.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(beanName + "->" + context.getBean(beanName));
    }
}
```

#### 注意

**指定包名的方式扫描存在的一个隐患，若包被重名了，会导致扫描会失效，一般情况下面我们使用 basePackageClasses 的方式来指定需要扫描的包，这个参数可以指定一些类型，默认会扫描这些类所在的包及其子包中所有的类，这种方式可以有效避免这种问题。**

### 案例：basePackageClasses 指定扫描范围

我们可以在需要扫描的包中定义一个标记的接口或者类，他们的唯一的作用是作为 basePackageClasses 的值，其他没有任何用途。

```
public interface ScanClass {
}
```

```
@Component
public class Service1 {
}

@Component
public class Service2 {
}
```

```
@ComponentScan(basePackageClasses = ScanClass.class)
public class ScanBean6 {
}
```

```
@Test
public void test6() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(ScanBean6.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(beanName + "->" + context.getBean(beanName));
    }
}
```

## includeFilters 的使用

再来看一下 includeFilters 这个参数的定义：

```
Filter[] includeFilters() default {};
```

是一个`Filter`类型的数组，**多个 Filter 之间为或者关系，即满足任意一个就可以了**，看一下`Filter`的代码：

```
@Retention(RetentionPolicy.RUNTIME)
@Target({})
@interface Filter {

    FilterType type() default FilterType.ANNOTATION;

    @AliasFor("classes")
    Class<?>[] value() default {};

    @AliasFor("value")
    Class<?>[] classes() default {};

    String[] pattern() default {};

}
```

可以看出 Filter 也是一个注解，参数：

**type：过滤器的类型，是个枚举类型，5 种类型**

ANNOTATION：通过注解的方式来筛选候选者，即判断候选者是否有指定的注解

ASSIGNABLE_TYPE：通过指定的类型来筛选候选者，即判断候选者是否是指定的类型

ASPECTJ：ASPECTJ 表达式方式，即判断候选者是否匹配 ASPECTJ 表达式

REGEX：正则表达式方式，即判断候选者的完整名称是否和正则表达式匹配

CUSTOM：用户自定义过滤器来筛选候选者，对候选者的筛选交给用户自己来判断

**value：和参数 classes 效果一样，二选一**

**classes：3 种情况如下**

当 type=FilterType.ANNOTATION 时，通过 classes 参数可以指定一些注解，用来判断被扫描的类上是否有 classes 参数指定的注解

当 type=FilterType.ASSIGNABLE_TYPE 时，通过 classes 参数可以指定一些类型，用来判断被扫描的类是否是 classes 参数指定的类型

当 type=FilterType.CUSTOM 时，表示这个过滤器是用户自定义的，classes 参数就是用来指定用户自定义的过滤器，自定义的过滤器需要实现 org.springframework.core.type.filter.TypeFilter 接口

**pattern：2 种情况如下**

当 type=FilterType.ASPECTJ 时，通过 pattern 来指定需要匹配的 ASPECTJ 表达式的值

当 type=FilterType.REGEX 时，通过 pattern 来自正则表达式的值

### 案例：扫描包含注解的类

自定义一个注解，让标注有这些注解的类自动注册到容器中

```
@Documented
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface MyBean {
}
```

```
@MyBean
public class Service1 {
}
```

```
@Component
public class Service2 {
}
```

```
@ComponentScan(includeFilters = {
        @ComponentScan.Filter(type = FilterType.ANNOTATION, classes = MyBean.class)
})
public class ScanBean3 {
}
```

上面指定了 Filter 的 type 为注解的类型，只要类上面有`@MyBean`注解的，都会被作为 bean 注册到容器中。

```
@Test
public void test3() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(ScanBean3.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(beanName + "->" + context.getBean(beanName));
    }
}
```

Service1 上标注了@MyBean注解，被注册到容器了，但是Service2上没有标注@MyBean啊，怎么也被注册到容器了？

原因：Service2 上标注了@Compontent注解，而 @CompontentScan 注解中的useDefaultFilters默认是true，表示也会启用默认的过滤器，而默认的过滤器会将标注有@Component、@Repository、@Service、@Controller这几个注解的类也注册到容器中

如果我们只想将标注有`@MyBean`注解的 bean 注册到容器，需要将默认过滤器关闭，即：useDefaultFilters=false，我们修改一下 ScanBean3 的代码如下：

```
@ComponentScan(
        useDefaultFilters = false, //不启用默认过滤器
        includeFilters = {
                @ComponentScan.Filter(type = FilterType.ANNOTATION, classes = MyBean.class)
        })
public class ScanBean3 {
}
```

#### 扩展：自定义注解支持定义 bean 名称

上面的自定义的 @MyBean 注解，是无法指定 bean 的名称的，可以对这个注解做一下改造，加个 value 参数来指定 bean 的名称，如下：

```
@Documented
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Component //@1
public @interface MyBean {
    @AliasFor(annotation = Component.class) //@2
    String value() default ""; //@3
}
```

重点在于 @1 和 @2 这 2 个地方的代码，通过上面的参数可以间接给 @Component 注解中的 value 设置值。

修改一下 Service1 的代码：

```
@MyBean("service1Bean")
public class Service1 {
}
```

### 案例：包含指定类型的类

```
public interface IService {
}
```

让 spring 来进行扫描，类型满足 IService 的都将其注册到容器中。

```
public class Service1 implements IService {
}

public class Service2 implements IService {
}
```

```
@ComponentScan(
        useDefaultFilters = false, //不启用默认过滤器
        includeFilters = {
                @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = IService.class) //@1
        })
public class ScanBean4 {
}
```

@1：被扫描的类满足`IService.class.isAssignableFrom(被扫描的类)`条件的都会被注册到 spring 容器中

```
@Test
public void test4() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(ScanBean4.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(beanName + "->" + context.getBean(beanName));
    }
}
```

## 自定义 Filter

有时候我们需要用到自定义的过滤器，使用自定义过滤器的步骤：

```
1.设置@Filter中type的类型为：FilterType.CUSTOM
2.自定义过滤器类，需要实现接口：org.springframework.core.type.filter.TypeFilter
3.设置@Filter中的classses为自定义的过滤器类型
```

来看一下`TypeFilter`这个接口的定义：

```
@FunctionalInterface
public interface TypeFilter {
    boolean match(MetadataReader metadataReader, MetadataReaderFactory metadataReaderFactory)
            throws IOException;
}
```

是一个函数式接口，包含一个 match 方法，方法返回 boolean 类型，有 2 个参数，都是接口类型的，下面介绍一下这 2 个接口。

MetadataReader 接口

类元数据读取器，可以读取一个类上的任意信息，如类上面的注解信息、类的磁盘路径信息、类的 class 对象的各种信息，spring 进行了封装，提供了各种方便使用的方法。

看一下这个接口的定义：

```
public interface MetadataReader {

    /**
     * 返回类文件的资源引用
     */
    Resource getResource();

    /**
     * 返回一个ClassMetadata对象，可以通过这个读想获取类的一些元数据信息，如类的class对象、是否是接口、是否有注解、是否是抽象类、父类名称、接口名称、内部包含的之类列表等等，可以去看一下源码
     */
    ClassMetadata getClassMetadata();

    /**
     * 获取类上所有的注解信息
     */
    AnnotationMetadata getAnnotationMetadata();

}
```

MetadataReaderFactory 接口

类元数据读取器工厂，可以通过这个类获取任意一个类的 MetadataReader 对象。

源码：

```
public interface MetadataReaderFactory {

    /**
     * 返回给定类名的MetadataReader对象
     */
    MetadataReader getMetadataReader(String className) throws IOException;

    /**
     * 返回指定资源的MetadataReader对象
     */
    MetadataReader getMetadataReader(Resource resource) throws IOException;

}
```

### 自定义 Filter 案例

自定义的 Filter，判断被扫描的类如果是`IService`接口类型的，就让其注册到容器中

```
public class MyFilter implements TypeFilter {
    @Override
    public boolean match(MetadataReader metadataReader, MetadataReaderFactory metadataReaderFactory) throws IOException {
        Class curClass = null;
        try {
            //当前被扫描的类
            curClass = Class.forName(metadataReader.getClassMetadata().getClassName());
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        //判断curClass是否是IService类型
        boolean result = IService.class.isAssignableFrom(curClass);
        return result;
    }
}
```

```
@ComponentScan(
        basePackages = {"com"},
        useDefaultFilters = false, //不启用默认过滤器
        includeFilters = {
                @ComponentScan.Filter(type = FilterType.CUSTOM, classes = MyFilter.class) //@1
        })
public class ScanBean5 {
}
```

@1：type 为 FilterType.CUSTOM，表示 Filter 是用户自定义的，classes 为自定义的过滤器

```
@Test
public void test5() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(ScanBean5.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(beanName + "->" + context.getBean(beanName));
    }
}
```

## excludeFilters

配置排除的过滤器，满足这些过滤器的类不会被注册到容器中，用法上面和 includeFilters 用一样

## @ComponentScan 重复使用

从这个注解的定义上可以看出这个注解可以同时使用多个，如：

```
@ComponentScan(basePackageClasses = ScanClass.class)
@ComponentScan(
        useDefaultFilters = false, //不启用默认过滤器
        includeFilters = {
                @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = IService.class)
        })
public class ScanBean7 {
}
```

还有一种写法，使用 @ComponentScans 的方式：

```
@ComponentScans({
        @ComponentScan(basePackageClasses = ScanClass.class),
        @ComponentScan(
                useDefaultFilters = false, //不启用默认过滤器
                includeFilters = {
                        @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = IService.class)
                })})
public class ScanBean7 {
}
```

## Spring 中这块的源码

**@CompontentScan 注解是被下面这个类处理的**

```
org.springframework.context.annotation.ConfigurationClassPostProcessor
```

**这个类非常非常关键，主要用户 bean 的注册，@Configuration,@Bean 注解也是被这个类处理的。**

还有下面这些注解：

```
@PropertySource
@Import
@ImportResource
@Compontent
```

以上这些注解都是被 ConfigurationClassPostProcessor 这个类处理的，内部会递归处理这些注解，完成 bean 的注册。

以 @CompontentScan 来说一下过程，第一次扫描之后会得到一批需要注册的类，然后会对这些需要注册的类进行遍历，判断是否有上面任意一个注解，如果有，会将这个类交给 ConfigurationClassPostProcessor 继续处理，直到递归完成所有 bean 的注册。

## 总结

1. @ComponentScan 用于批量注册 bean，spring 会按照这个注解的配置，递归扫描指定包中的所有类，将满足条件的类批量注册到 spring 容器中
2. 可以通过 value、basePackages、basePackageClasses 这几个参数来配置包的扫描范围
3. 可以通过 useDefaultFilters、includeFilters、excludeFilters 这几个参数来配置类的过滤器，被过滤器处理之后剩下的类会被注册到容器中
4. 指定包名的方式配置扫描范围存在隐患，包名被重命名之后，会导致扫描实现，所以一般我们在需要扫描的包中可以创建一个标记的接口或者类，作为 basePackageClasses 的值，通过这个来控制包的扫描范围
5. @CompontScan 注解会被 ConfigurationClassPostProcessor 类递归处理，最终得到所有需要注册的类。

月薪 5 万，恭喜你，面了几百人，这些问题你是第一个让我比较满意的，且超出了预期！

# 19、@import详解

## @Import 出现的背景

到目前，我们知道的批量定义 bean 的方式有 2 种：

1. @Configuration 结合 @Bean 注解的方式
2. @CompontentScan 扫描包的方式

**问题 1**

如果需要注册的类是在第三方的 jar 中，那么我们如果想注册这些 bean 有 2 种方式：

1. 通过 @Bean 标注方法的方式，一个个来注册
2. @CompontentScan 的方式：默认的 @CompontentScan 是无能为力的，默认情况下只会注册 @Compontent 标注的类，此时只能自定义 @CompontentScan 中的过滤器来实现了

这 2 种方式都不是太好，每次有变化，调整的代码都比较多。

**问题 2**

通常我们的项目中有很多子模块，可能每个模块都是独立开发的，最后通过 jar 的方式引进来，每个模块中都有各自的 @Configuration、@Bean 标注的类，或者使用 @CompontentScan 标注的类，**被 @Configuration、@Bean、@CompontentScan 标注的类，我们统称为 bean 配置类，配置类可以用来注册 bean**，此时如果我们只想使用其中几个模块的配置类，怎么办？

## @Import 使用

先看 Spring 对它的注释，总结下来作用就是和 xml 配置的 \<import /> 标签作用一样，允许通过它引入 @Configuration 标注的类 ， 引入 ImportSelector 接口和 ImportBeanDefinitionRegistrar 接口的实现，也包括 @Component 注解的普通类。

**总的来说：@Import 可以用来批量导入需要注册的各种类，如普通的类、配置类，完后完成普通类和配置类中所有 bean 的注册。**

@Import 的源码：

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Import {

    /**
     * {@link Configuration @Configuration}, {@link ImportSelector},
     * {@link ImportBeanDefinitionRegistrar}, or regular component classes to import.
     */
    Class<?>[] value();

}
```

@Import 可以使用在任何类型上，通常情况下，类和注解上用的比较多。

value：一个 Class 数组，设置需要导入的类，可以是 @Configuration 标注的列，可以是 ImportSelector 接口或者 ImportBeanDefinitionRegistrar 接口类型的，或者需要导入的普通组件类。

### 使用步骤

1. 将 @Import 标注在类上，设置 value 参数
2. 将 @Import 标注的类作为 AnnotationConfigApplicationContext 构造参数创建 AnnotationConfigApplicationContext 对象
3. 使用 AnnotationConfigApplicationContext 对象

## @Import 的 value 常见的有 5 种用法

1. **value 为普通的类**
2. **value 为 @Configuration 标注的类**
3. **value 为 @CompontentScan 标注的类**
4. **value 为 ImportBeanDefinitionRegistrar 接口类型**
5. **value 为 ImportSelector 接口类型**
6. **value 为 DeferredImportSelector 接口类型**

### value 为普通的类

```
public class Service1 {
}
```

```
public class Service2 {
}
```

```
@Import({Service1.class, Service2.class})
public class MainConfig1 {
}
```

@Import 中导入了 2 个普通的类：Service1、Service2，这两个类会被自动注册到容器中

```
public class ImportTest {
    @Test
    public void test1() {
        //1.通过AnnotationConfigApplicationContext创建spring容器，参数为@Import标注的类
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig1.class);
        //2.输出容器中定义的所有bean信息
        for (String beanName : context.getBeanDefinitionNames()) {
            System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
        }
    }
}
```

运行输出

![image-20201214102159934](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201214102200.png)

结果分析

从输出中可以看出：

1. Service1 和 Service2 成功注册到容器了。
2. 通过 @Import 导入的 2 个类，bean 名称为完整的类名

我们也可以指定被导入类的 bean 名称，使用 @Compontent 注解就可以了，如下：

```
@Component("service1")
public class Service1 {
}
```

### value 为 @Configuration 标注的配置类

项目比较大的情况下，会按照模块独立开发，每个模块在 maven 中就表现为一个个的构建，然后通过坐标的方式进行引入需要的模块。

假如项目中有 2 个模块，2 个模块都有各自的配置类，如下

```
/**
 * 模块1配置类
 */
@Configuration
public class ConfigModule1 {
    @Bean
    public String module1() {
        return "我是模块1配置类！";
    }
}
```

```
/**
 * 模块2配置类
 */
@Configuration
public class ConfigModule2 {
    @Bean
    public String module2() {
        return "我是模块2配置类！";
    }
}
```

总配置类：通过 @Import 导入 2 个模块的配置类

```
/**
 * 通过Import来汇总多个@Configuration标注的配置类
 */
@Import({ConfigModule1.class, ConfigModule2.class}) //@1
public class MainConfig2 {
}
```

@1 导入了 2 个模块中的模块配置类，可以按需导入。

```
@Test
public void test2() {
    //1.通过AnnotationConfigApplicationContext创建spring容器，参数为@Import标注的类
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig2.class);
    //2.输出容器中定义的所有bean信息
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

### value 为 @CompontentScan 标注的类

项目中分多个模块，每个模块有各自独立的包，我们在每个模块所在的包中配置一个 @CompontentScan 类，然后通过 @Import 来导入需要启用的模块。

定义模块 1

2 个组件和一个组件扫描类，模块 1 所有类所在的包为：

```
com.module1
```

组件 1：Module1Service1

```
@Component
public class Module1Service1 {
}
```

组件 2：Module1Service2

```
@Component
public class Module1Service2 {
}
```

组件扫描类：CompontentScanModule1

负责扫描当前模块中的组件

```
/**
 * 模块1的主键扫描
 */
@ComponentScan
public class ComponentScanModule1 {
}
```

同样的方式定义模块 2

2 个组件和一个组件扫描类，模块 1 所有类所在的包为：

```
com.module2
```

组件 1：Module2Service1

```
@Component
public class Module2Service1 {
}
```

组件 2：Module2Service2

```
@Component
public class Module2Service2 {
}
```

组件扫描类：CompontentScanModule1

负责扫描当前模块中的组件

```
/**
 * 模块2的组件扫描
 */
@ComponentScan
public class ComponentScanModule2 {
}
```

总配置类：通过 @Import 导入每个模块中的组件扫描类

```
/**
 * 通过@Import导入多个@CompontentScan标注的配置类
 */
@Import({ComponentScanModule1.class, CompontenScanModule2.class}) //@1
public class MainConfig3 {
}
```

@1 导入了 2 个模块中的组件扫描类，可以按需导入。

```
@Test
public void test3() {
    //1.通过AnnotationConfigApplicationContext创建spring容器，参数为@Import标注的类
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig3.class);
    //2.输出容器中定义的所有bean信息
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

## 先来了解一下相关的几个接口

### ImportBeanDefinitionRegistrar 接口

**这个接口提供了通过 spring 容器 api 的方式直接向容器中注册 bean**。

接口的完整名称：

```
org.springframework.context.annotation.ImportBeanDefinitionRegistrar
```

源码：

```
public interface ImportBeanDefinitionRegistrar {

    default void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry,
            BeanNameGenerator importBeanNameGenerator) {

        registerBeanDefinitions(importingClassMetadata, registry);
    }

    default void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
    }

}
```

2 个默认方法，都可以用来调用 spring 容器 api 来注册 bean。

2 个方法中主要有 3 个参数

importingClassMetadata

AnnotationMetadata 类型的，通过这个可以获取被 @Import 注解标注的类所有注解的信息。

registry

BeanDefinitionRegistry 类型，是一个接口，内部提供了注册 bean 的各种方法。

importBeanNameGenerator

BeanNameGenerator 类型，是一个接口，内部有一个方法，用来生成 bean 的名称。

关于 BeanDefinitionRegistry 和 BeanNameGenerator 接口在来细说一下。

### BeanDefinitionRegistry 接口：bean 定义注册器

bean 定义注册器，提供了 bean 注册的各种方法，来看一下源码：

```
public interface BeanDefinitionRegistry extends AliasRegistry {

    /**
     * 注册一个新的bean定义
     * beanName：bean的名称
     * beanDefinition：bean定义信息
     */
    void registerBeanDefinition(String beanName, BeanDefinition beanDefinition)
            throws BeanDefinitionStoreException;

    /**
     * 通过bean名称移除已注册的bean
     * beanName：bean名称
     */
    void removeBeanDefinition(String beanName) throws NoSuchBeanDefinitionException;

    /**
     * 通过名称获取bean的定义信息
     * beanName：bean名称
     */
    BeanDefinition getBeanDefinition(String beanName) throws NoSuchBeanDefinitionException;

    /**
     * 查看beanName是否注册过
     */
    boolean containsBeanDefinition(String beanName);

    /**
     * 获取已经定义（注册）的bean名称列表
     */
    String[] getBeanDefinitionNames();

    /**
     * 返回注册器中已注册的bean数量
     */
    int getBeanDefinitionCount();

    /**
     * 确定给定的bean名称或者别名是否已在此注册表中使用
     * beanName：可以是bean名称或者bean的别名
     */
    boolean isBeanNameInUse(String beanName);

}
```

基本上所有 bean 工厂都实现了这个接口，让 bean 工厂拥有 bean 注册的各种能力。

上面我们用到的`AnnotationConfigApplicationContext`类也实现了这个接口。

### BeanNameGenerator 接口：bean 名称生成器

bean 名称生成器，这个接口只有一个方法，用来生成 bean 的名称：

```
public interface BeanNameGenerator {
    String generateBeanName(BeanDefinition definition, BeanDefinitionRegistry registry);
}
```

spring 内置了 3 个实现

DefaultBeanNameGenerator

默认 bean 名称生成器，xml 中 bean 未指定名称的时候，默认就会使用这个生成器，默认为：完整的类名 #bean 编号

AnnotationBeanNameGenerator

注解方式的 bean 名称生成器，比如通过 @Component(bean 名称) 的方式指定 bean 名称，如果没有通过注解方式指定名称，默认会将完整的类名作为 bean 名称。

FullyQualifiedAnnotationBeanNameGenerator

将完整的类名作为 bean 的名称

### BeanDefinition 接口：bean 定义信息

用来表示 bean 定义信息的接口，我们向容器中注册 bean 之前，会通过 xml 或者其他方式定义 bean 的各种配置信息，bean 的所有配置信息都会被转换为一个 BeanDefinition 对象，然后通过容器中 BeanDefinitionRegistry 接口中的方法，将 BeanDefinition 注册到 spring 容器中，完成 bean 的注册操作。

这个接口有很多实现类，有兴趣的可以去看看源码，BeanDefinition 的各种用法，以后会通过专题细说。

### value 为 ImportBeanDefinitionRegistrar 接口类型

```
1. 定义ImportBeanDefinitionRegistrar接口实现类，在registerBeanDefinitions方法中使用registry来注册bean
2. 使用@Import来导入步骤1中定义的类
3. 使用步骤2中@Import标注的类作为AnnotationConfigApplicationContext构造参数创建spring容器
4. 使用AnnotationConfigApplicationContext操作bean
```

#### 案例

```
public class Service1 {
}
```

```
@Data
public class Service2 {
    private Service1 service1;
}
```

来个类实现 ImportBeanDefinitionRegistrar 接口，然后在里面实现上面 2 个类的注册，如下：

```
public class MyImportBeanDefinitionRegistrar implements ImportBeanDefinitionRegistrar {
    @Override
    public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
        //定义一个bean：Service1
        BeanDefinition service1BeanDinition = BeanDefinitionBuilder.genericBeanDefinition(Service1.class).getBeanDefinition();
        //注册bean
        registry.registerBeanDefinition("service1", service1BeanDinition);

        //定义一个bean：Service2，通过addPropertyReference注入service1
        BeanDefinition service2BeanDinition = BeanDefinitionBuilder.genericBeanDefinition(Service2.class).
                addPropertyReference("service1", "service1").
                getBeanDefinition();
        //注册bean
        registry.registerBeanDefinition("service2", service2BeanDinition);
    }
}
```

注意上面的 registerBeanDefinitions 方法，内部注册了 2 个 bean，Service1 和 Service2。

上面使用了 BeanDefinitionBuilder 这个类，这个是 BeanDefinition 的构造器，内部提供了很多静态方法方便构建 BeanDefinition 对象。

上面定义的 2 个 bean，和下面 xml 方式效果一样：

```
<bean id="service1" class="com.Service1" />
<bean id="service2" class="com.Service2">
    <property name="service1" ref="service1"/>
</bean>
```

```
@Test
public void test4() {
    //1.通过AnnotationConfigApplicationContext创建spring容器，参数为@Import标注的类
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig4.class);
    //2.输出容器中定义的所有bean信息
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

### value 为 ImportSelector 接口类型

先来看一下 ImportSelector 接口

ImportSelector 接口

导入选择器，看一下源码：

```
public interface ImportSelector {

    /**
     * 返回需要导入的类名的数组，可以是任何普通类，配置类（@Configuration、@Bean、@CompontentScan等标注的类）
     * @importingClassMetadata：用来获取被@Import标注的类上面所有的注解信息
     */
    String[] selectImports(AnnotationMetadata importingClassMetadata);

}
```

```
1. 定义ImportSelector接口实现类，在selectImports返回需要导入的类的名称数组
2. 使用@Import来导入步骤1中定义的类
3. 使用步骤2中@Import标注的类作为AnnotationConfigApplicationContext构造参数创建spring容器
4. 使用AnnotationConfigApplicationContext操作bean
```

#### 案例

```
public class Service1 {
}
```

```
@Configuration
public class Module1Config {
    @Bean
    public String name() {
        return "java";
    }

    @Bean
    public String address() {
        return "上海市";
    }
}
```

上面定义了两个 string 类型的 bean：name 和 address

下面自定义一个 ImportSelector，然后返回上面 2 个类的名称

```
public class MyImportSelector implements ImportSelector {
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        return new String[]{
                Service1.class.getName(),
                Module1Config.class.getName()
        };
    }
}
```

来个 @Import 标注的类，导入 MyImportSelector

```
/**
 * 通过@Import导入MyImportSelector接口实现类
 */
@Import({MyImportSelector.class})
public class MainConfig5 {
}
```

```
@Test
public void test5() {
    //1.通过AnnotationConfigApplicationContext创建spring容器，参数为@Import标注的类
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig5.class);
    //2.输出容器中定义的所有bean信息
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

## 案例

凡是类名中包含 service 的，调用他们内部任何方法，我们希望调用之后能够输出这些方法的耗时。

实现分析

之前我们讲过代理， 此处我们就可以通过代理来实现，bean 实例创建的过程中，我们可以给这些 bean 生成一个代理，在代理中统计方法的耗时，这里面有 2 点：

1. 创建一个代理类，通过代理来间接访问需要统计耗时的 bean 对象
2. 拦截 bean 的创建，给 bean 实例生成代理生成代理

```
@Component
public class Service1 {
    public void m1() {
        System.out.println(this.getClass() + ".m1()");
    }
}
```

```
@Component
public class Service2 {
    public void m1() {
        System.out.println(this.getClass() + ".m1()");
    }
}
```

创建统计耗时的代理类

```
public class CostTimeProxy implements MethodInterceptor {
    //目标对象
    private Object target;

    public CostTimeProxy(Object target) {
        this.target = target;
    }

    @Override
    public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
        long starTime = System.nanoTime();
        //调用被代理对象（即target）的方法，获取结果
        Object result = method.invoke(target, objects); //@1
        long endTime = System.nanoTime();
        System.out.println(method + "，耗时(纳秒)：" + (endTime - starTime));
        return result;
    }

    /**
     * 创建任意类的代理对象
     *
     * @param target
     * @param <T>
     * @return
     */
    public static <T> T createProxy(T target) {
        CostTimeProxy costTimeProxy = new CostTimeProxy(target);
        Enhancer enhancer = new Enhancer();
        enhancer.setCallback(costTimeProxy);
        enhancer.setSuperclass(target.getClass());
        return (T) enhancer.create();
    }
}
```

createProxy 方法可以用来给某个对象生成代理对象

拦截 bean 实例的创建，返回代理对象

这里我们需要用到 spring 中的一个接口：

```
org.springframework.beans.factory.config.BeanPostProcessor

public interface BeanPostProcessor {

    /**
     * bean初始化之后会调用的方法
     */
    @Nullable
    default Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        return bean;
    }

    /**
     * bean初始化之后会调用的方法
     */
    @Nullable
    default Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        return bean;
    }

}
```

这个接口是 bean 处理器，内部有 2 个方法，分别在 bean 初始化前后会进行调用，以后讲声明周期的时候还会细说的，这里你只需要知道 bean 初始化之后会调用`postProcessAfterInitialization`方法就行，这个方法中我们会给 bean 创建一个代理对象。

下面我们创建一个 BeanPostProcessor 实现类：

```
public class MethodCostTimeProxyBeanPostProcessor implements BeanPostProcessor {
    @Nullable
    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        if (bean.getClass().getName().toLowerCase().contains("service")) {
            return CostTimeProxy.createProxy(bean); //@1
        } else {
            return bean;
        }
    }
}
```

@1：使用上面创建代理类来给当前 bean 对象创建一个代理

需要将 MethodCostTimeProxyBeanPostProcessor 注册到容器中才会起作用，下面我们通过 @Import 结合 ImportSelector 的方式来导入这个类，将其注册到容器中。

```
public class MethodCostTimeImportSelector implements ImportSelector {
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        return new String[]{MethodCostTimeProxyBeanPostProcessor.class.getName()};
    }
}
```

来一个 @Import 来导入 MethodCostTimeImportSelector

下面我们使用注解的方式，在注解上使用 @Import，如下：

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Import(MethodCostTimeImportSelector.class)
public @interface EnableMethodCostTime {
}
```

来一个总的配置类

```
@ComponentScan
@EnableMethodCostTime //@1
public class MainConfig6 {
}
```

上面使用了 @CompontentScan 注解，此时会将 Servce1 和 Service2 这两个类注册到容器中。

@1：此处使用了 @EnableMethodCostTime 注解，而 @EnableMethodCostTime 注解上使用了 @Import(MethodCostTimeImportSelector.class)，此时 MethodCostTimeImportSelector 类中的 MethodCostTimeProxyBeanPostProcessor 会被注册到容器，会拦截 bean 的创建，创建耗时代理对象。

```
@Test
public void test6() {
    //1.通过AnnotationConfigApplicationContext创建spring容器，参数为@Import标注的类
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig6.class);
    Service1 service1 = context.getBean(Service1.class);
    Service2 service2 = context.getBean(Service2.class);
    service1.m1();
    service2.m1();
}
```

**如果我们不想开启方法耗时统计，只需要将 MainConfig6 上的 @EnableMethodCostTime 去掉就可以了**

**spring 中有很多类似的注解，以 @EnableXXX 开头的注解，基本上都是通过上面这种方式实现的，如：**

```
@EnableAspectJAutoProxy
@EnableCaching
@EnableAsync
```

继续向下看，还有一个更牛逼的接口 DeferredImportSelector。

## DeferredImportSelector 接口

**先给你透露一下，springboot 中的核心功能 @EnableAutoConfiguration 就是靠 DeferredImportSelector 来实现的。**

DeferredImportSelector 是 ImportSelector 的子接口，既然是 ImportSelector 的子接口，所以也可以通过 @Import 进行导入，这个接口和 ImportSelector 不同地方有两点：

1. 延迟导入
2. 指定导入的类的处理顺序

### 延迟导入

比如 @Import 的 value 包含了多个普通类、多个 @Configuration 标注的配置类、多个 ImportSelector 接口的实现类，多个 ImportBeanDefinitionRegistrar 接口的实现类，还有 DeferredImportSelector 接口实现类，此时 spring 处理这些被导入的类的时候，**会将 DeferredImportSelector 类型的放在最后处理，会先处理其他被导入的类，其他类会按照 value 所在的前后顺序进行处理**。

那么我们是可以做很多事情的，比如我们可以在 DeferredImportSelector 导入的类中判断一下容器中是否已经注册了某个 bean，如果没有注册过，那么再来注册。

以后我们会讲到另外一个注解 @Conditional，这个注解可以按条件来注册 bean，比如可以判断某个 bean 不存在的时候才进行注册，某个类存在的时候才进行注册等等各种条件判断，通过 @Conditional 来结合 DeferredImportSelector 可以做很多事情。

### 延迟导入的案例

来 3 个配置类，每个配置类中都通过 @Bean 定一个 string 类型的 bean，内部输出一句文字。

```
@Configuration
public class Configuration1 {
    @Bean
    public String name1() {
        System.out.println("name1");
        return "name1";
    }
}
```

```
@Configuration
public class Configuration2 {
    @Bean
    public String name2() {
        System.out.println("name2");
        return "name2";
    }
}
```

```
@Configuration
public class Configuration3 {
    @Bean
    public String name3() {
        System.out.println("name3");
        return "name3";
    }
}
```

```
public class ImportSelector1 implements ImportSelector {
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        return new String[]{
                Configuration1.class.getName()
        };
    }
}
```

```
public class DeferredImportSelector1 implements DeferredImportSelector {
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        return new String[]{Configuration2.class.getName()};
    }
}
```

```
@Import({
        DeferredImportSelector1.class,
        Configuration3.class,
        ImportSelector1.class,
})
public class MainConfig7 {
}
```

注意上面的 @Import 中被导入类的顺序：

DeferredImportSelector1->Configuration3->ImportSelector1

下面来个测试用例，看一下 3 个配置文件中 @Bean 标注的方法被执行的先后顺序。

```
@Test
public void test7() {
    //1.通过AnnotationConfigApplicationContext创建spring容器，参数为@Import标注的类
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig7.class);
}
```

**输出的结果结合一下 @Import 中被导入的 3 个类的顺序，可以看出 DeferredImportSelector1 是被最后处理的，其他 2 个是按照 value 中所在的先后顺序处理的。**

### 指定导入的类的处理顺序

当 @Import 中有多个 DeferredImportSelector 接口的实现类时候，可以指定他们的顺序，指定顺序常见 2 种方式

#### 实现 Ordered 接口的方式

```
org.springframework.core.Ordered

public interface Ordered {

    int HIGHEST_PRECEDENCE = Integer.MIN_VALUE;

    int LOWEST_PRECEDENCE = Integer.MAX_VALUE;

    int getOrder();

}
```

value 的值越小，优先级越高。

#### 实现 Order 注解的方式

```
org.springframework.core.annotation.Order

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.METHOD, ElementType.FIELD})
@Documented
public @interface Order {

    int value() default Ordered.LOWEST_PRECEDENCE;

}
```

value 的值越小，优先级越高。

### 指定导入类处理顺序的案例

来 2 个配置类，内部都有一个 @Bean 标注的方法，用来注册一个 bean，方法内部输出一行文字

```
@Configuration
public class Configuration1 {
    @Bean
    public String name1() {
        System.out.println("name1");
        return "name1";
    }
}
```

```
@Configuration
public class Configuration2 {
    @Bean
    public String name2() {
        System.out.println("name2");
        return "name2";
    }
}
```

来 2 个 DeferredImportSelector 实现类，分别来导入上面 2 个配置文件，顺便通过 Ordered 接口指定一下顺序

```
public class DeferredImportSelector1 implements DeferredImportSelector, Ordered {
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        return new String[]{Configuration1.class.getName()};
    }

    @Override
    public int getOrder() {
        return 2;
    }
}
```

```
public class DeferredImportSelector2 implements DeferredImportSelector, Ordered {
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        return new String[]{Configuration2.class.getName()};
    }

    @Override
    public int getOrder() {
        return 1;
    }
}
```

DeferredImportSelector1 的 order 为 2，DeferredImportSelector2 的 order 为 1，order 值越小优先级越高。

```
@Import({
        DeferredImportSelector1.class,
        DeferredImportSelector2.class,
})
public class MainConfig8 {
}
```

```
@Test
public void test8() {
    //1.通过AnnotationConfigApplicationContext创建spring容器，参数为@Import标注的类
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig8.class);
}
```

运行输出

![image-20201214104824742](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201214104824.png)

结果配合 order 的值，按照 order 从小到大来处理，可以看出 DeferredImportSelector2 先被处理的。

## Spring 中这块的源码

**@Import 注解是被下面这个类处理的**

```
org.springframework.context.annotation.ConfigurationClassPostProcessor
```

前面介绍的 @Configuration、@Bean、@CompontentScan、@CompontentScans 都是被这个类处理的，这个类是高手必经之路，建议花点时间研究研究。

## 总结

1. @Import 可以用来批量导入任何普通的组件、配置类，将这些类中定义的所有 bean 注册到容器中
2. @Import 常见的 5 种用法需要掌握
3. 掌握 ImportSelector、ImportBeanDefinitionRegistrar、DeferredImportSelector 的用法
4. DeferredImportSelector 接口可以实现延迟导入、按序导入的功能
5. spring 中很多以 @Enable 开头的都是使用 @Import 集合 ImportSelector 方式实现的
6. BeanDefinitionRegistry 接口：bean 定义注册器，这个需要掌握常见的方法

# 20、@Conditional通过条件来控制bean的注册

## @Conditional 注解

**@Conditional 注解是从 spring4.0 才有的，可以用在任何类型或者方法上面，通过 @Conditional 注解可以配置一些条件判断，当所有条件都满足的时候，被 @Conditional 标注的目标才会被 spring 容器处理。**

比如可以通过 @Conditional 来控制 bean 是否需要注册，控制被 @Configuration 标注的配置类是需要需要被解析等。

效果就像这段代码，相当于在 spring 容器解析目标前面加了一个条件判断：

```
if(@Conditional中配置的多个条件是否都匹配){
//spring继续处理被@Conditional注解标注的对象
}
```

@Conditional 源码：

```
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Conditional {
    Class<? extends Condition>[] value();
}
```

这个注解只有一个 value 参数，Condition 类型的数组，Condition 是一个接口，表示一个条件判断，内部有个方法返回 true 或 false，当所有 Condition 都成立的时候，@Conditional 的结果才成立。

下面我们来看一下 Condition 接口。

## Condition 接口

用来表示条件判断的接口，源码如下：

```
@FunctionalInterface
public interface Condition {

    /**
     * 判断条件是否匹配
     * context:条件判断上下文
     */
    boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata);

}
```

是一个函数式接口，内部只有一个 matches 方法，用来判断条件是否成立的，2 个参数：

- context：条件上下文，ConditionContext 接口类型的，可以用来获取容器中的个人信息
- metadata：用来获取被 @Conditional 标注的对象上的所有注解信息

## ConditionContext 接口

这个接口中提供了一些常用的方法，可以用来获取 spring 容器中的各种信息，看一下源码：

```
public interface ConditionContext {

    /**
     * 返回bean定义注册器，可以通过注册器获取bean定义的各种配置信息
     */
    BeanDefinitionRegistry getRegistry();

    /**
     * 返回ConfigurableListableBeanFactory类型的bean工厂，相当于一个ioc容器对象
     */
    @Nullable
    ConfigurableListableBeanFactory getBeanFactory();

    /**
     * 返回当前spring容器的环境配置信息对象
     */
    Environment getEnvironment();

    /**
     * 返回资源加载器
     */
    ResourceLoader getResourceLoader();

    /**
     * 返回类加载器
     */
    @Nullable
    ClassLoader getClassLoader();

}
```

## 比较关键性的问题：条件判断在什么时候执行？

Spring 对配置类的处理主要分为 2 个阶段：

### 配置类解析阶段

会得到一批配置类的信息，和一些需要注册的 bean

### bean 注册阶段

将配置类解析阶段得到的配置类和需要注册的 bean 注册到 spring 容器中

### 看一下什么是配置类

类中有下面任意注解之一的就属于配置类：

1. 类上有 @Compontent 注解
2. 类上有 @Configuration 注解
3. 类上有 @CompontentScan 注解
4. 类上有 @Import 注解
5. 类上有 @ImportResource 注解
6. 类中有 @Bean 标注的方法

判断一个类是不是一个配置类，是否的是下面这个方法，有兴趣的可以看一下：

org.springframework.context.annotation.ConfigurationClassUtils#isConfigurationCandidate

spring 中处理这 2 个过程会循环进行，直到完成所有配置类的解析及所有 bean 的注册。

### Spring 对配置类处理过程

源码位置：

```
org.springframework.context.annotation.ConfigurationClassPostProcessor#processConfigBeanDefinitions
```

整个过程大致的过程如下：

1. 通常我们会通过 new AnnotationConfigApplicationContext() 传入多个配置类来启动 spring 容器
2. spring 对传入的多个配置类进行解析
3. 配置类解析阶段：这个过程就是处理配置类上面 6 中注解的过程，此过程中又会发现很多新的配置类，比如 @Import 导入的一批新的类刚好也符合配置类，而被 @CompontentScan 扫描到的一些类刚好也是配置类；此时会对这些新产生的配置类进行同样的过程解析
4. bean 注册阶段：配置类解析后，会得到一批配置类和一批需要注册的 bean，此时 spring 容器会将这批配置类作为 bean 注册到 spring 容器，同样也会将这批需要注册的 bean 注册到 spring 容器
5. 经过上面第 3 个阶段之后，spring 容器中会注册很多新的 bean，这些新的 bean 中可能又有很多新的配置类
6. Spring 从容器中将所有 bean 拿出来，遍历一下，会过滤得到一批未处理的新的配置类，继续交给第 3 步进行处理
7. step3 到 step6，这个过程会经历很多次，直到完成所有配置类的解析和 bean 的注册

从上面过程中可以了解到：

1. 可以在配置类上面加上 @Conditional 注解，来控制是否需要解析这个配置类，配置类如果不被解析，那么这个配置上面 6 种注解的解析都会被跳过
2. 可以在被注册的 bean 上面加上 @Conditional 注解，来控制这个 bean 是否需要注册到 spring 容器中
3. 如果配置类不会被注册到容器，那么这个配置类解析所产生的所有新的配置类及所产生的所有新的 bean 都不会被注册到容器

一个配置类被 spring 处理有 2 个阶段：配置类解析阶段、bean 注册阶段（将配置类作为 bean 被注册到 spring 容器)。

如果将 Condition 接口的实现类作为配置类上 @Conditional 中，那么这个条件会对两个阶段都有效，此时通过 Condition 是无法精细的控制某个阶段的，如果想控制某个阶段，比如可以让他解析，但是不能让他注册，此时就就需要用到另外一个接口了：ConfigurationCondition

## ConfigurationCondition 接口

看一下这个接口的源码：

```
public interface ConfigurationCondition extends Condition {

    /**
     * 条件判断的阶段，是在解析配置类的时候过滤还是在创建bean的时候过滤
     */
    ConfigurationPhase getConfigurationPhase();


    /**
     * 表示阶段的枚举：2个值
     */
    enum ConfigurationPhase {

        /**
         * 配置类解析阶段，如果条件为false，配置类将不会被解析
         */
        PARSE_CONFIGURATION,

        /**
         * bean注册阶段，如果为false，bean将不会被注册
         */
        REGISTER_BEAN
    }

}
```

ConfigurationCondition 接口相对于 Condition 接口多了一个 getConfigurationPhase 方法，用来指定条件判断的阶段，是在解析配置类的时候过滤还是在创建 bean 的时候过滤。

## @Conditional 使用的 3 步骤

1. 自定义一个类，实现 Condition 或 ConfigurationCondition 接口，实现 matches 方法
2. 在目标对象上使用 @Conditional 注解，并指定 value 的指为自定义的 Condition 类型
3. 启动 spring 容器加载资源，此时 @Conditional 就会起作用了

## 案例 1：阻止配置类的处理

在配置类上面使用 @Conditional，这个注解的 value 指定的 Condition 当有一个为 false 的时候，spring 就会跳过处理这个配置类。

自定义一个 Condition 类：

```
package com.javacode2018.lesson001.demo25.test3;

import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.core.type.AnnotatedTypeMetadata;

public class MyCondition1 implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        return false;
    }
}
```

matches 方法内部我们可以随意发挥，此处为了演示效果就直接返回 false。

来个配置类，在配置类上面使用上面这个条件，此时会让配置类失效，如下：

```
package com.javacode2018.lesson001.demo25.test3;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;

@Conditional(MyCondition1.class) //@1
@Configuration
public class MainConfig3 {
    @Bean
    public String name() { //@1
        return "路人甲Java";
    }
}
```

@1：使用了自定义的条件类

@2：通过 @Bean 标注这 name 这个方法，如果这个配置类成功解析，会将 name 方法的返回值作为 bean 注册到 spring 容器

来个测试类，启动 spring 容器加载 MainConfig3 配置类，如下：

```
package com.javacode2018.lesson001.demo25;

import com.javacode2018.lesson001.demo25.test3.MainConfig3;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import java.util.Map;

public class ConditionTest {

    @Test
    public void test3() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig3.class);
        Map<String, String> serviceMap = context.getBeansOfType(String.class);
        serviceMap.forEach((beanName, bean) -> {
            System.out.println(String.format("%s->%s", beanName, bean));
        });
    }
}
```

test3 中，从容器中获取 String 类型的 bean，运行 test3 没有任何输出。

我们可以将 MainConfig3 上面的 @Conditional 去掉，再次运行输出：

```
name->路人甲Java
```

## 案例 2：阻止 bean 的注册

来个配置类，如下：

```
package com.javacode2018.lesson001.demo25.test4;

import com.javacode2018.lesson001.demo25.test3.MyCondition1;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MainConfig4 {
    @Conditional(MyCondition1.class) //@1
    @Bean
    public String name() {
        return "路人甲Java";
    }

    @Bean
    public String address() {
        return "上海市";
    }
}
```

上面 2 个方法上面使用了 @Bean 注解来定义了 2 个 bean，name 方法上面使用了 @Conditional 注解，这个条件会在 name 这个 bean 注册到容器之前会进行判断，当条件为 true 的时候，name 这个 bean 才会被注册到容器。

ConditionTest 中新增个测试用例来加载上面这个配置类，从容器中获取 String 类型所有 bean 输出，代码如下：

```
@Test
public void test4() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig4.class);
    Map<String, String> serviceMap = context.getBeansOfType(String.class);
    serviceMap.forEach((beanName, bean) -> {
        System.out.println(String.format("%s->%s", beanName, bean));
    });
}
```

运行输出：

```
address->上海市
```

可以看到容器中只有一个 address 被注册了，而 name 这个 bean 没有被注册。

## 案例 3：bean 不存在的时候才注册

### 需求

IService 接口有两个实现类 Service1 和 Service1，这两个类会放在 2 个配置类中通过 @Bean 的方式来注册到容器，此时我们想加个限制，只允许有一个 IService 类型的 bean 被注册到容器。

可以在 @Bean 标注的 2 个方法上面加上条件限制，当容器中不存在 IService 类型的 bean 时，才将这个方法定义的 bean 注册到容器，下面来看代码实现。

### 代码实现

#### 条件判断类：OnMissingBeanCondition

```
package com.javacode2018.lesson001.demo25.test1;

import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.context.annotation.ConfigurationCondition;
import org.springframework.core.type.AnnotatedTypeMetadata;

import java.util.Map;

public class OnMissingBeanCondition implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        //获取bean工厂
        ConfigurableListableBeanFactory beanFactory = context.getBeanFactory();
        //从容器中获取IService类型bean
        Map<String, IService> serviceMap = beanFactory.getBeansOfType(IService.class);
        //判断serviceMap是否为空
        return serviceMap.isEmpty();
    }

}
```

上面 matches 方法中会看容器中是否存在 IService 类型的 bean，不存在的时候返回 true

#### IService 接口

```
package com.javacode2018.lesson001.demo25.test1;

public interface IService {
}
```

#### 接口有 2 个实现类

##### Service1

```
package com.javacode2018.lesson001.demo25.test1;

public class Service1 implements IService {
}
```

##### Service2

```
package com.javacode2018.lesson001.demo25.test1;

public class Service2 implements IService {
}
```

#### 来一个配置类负责注册 Service1 到容器

```
package com.javacode2018.lesson001.demo25.test1;


import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;

@Configuration
public class BeanConfig1 {
    @Conditional(OnMissingBeanCondition.class) //@1
    @Bean
    public IService service1() {
        return new Service1();
    }
}
```

@1：方法之前使用了条件判断

#### 再来一个配置类负责注册 Service2 到容器

```
package com.javacode2018.lesson001.demo25.test1;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;

@Configuration
public class BeanConfig2 {
    @Conditional(OnMissingBeanCondition.class)//@1
    @Bean
    public IService service2() {
        return new Service2();
    }
}
```

@1：方法之前使用了条件判断

#### 来一个总的配置类，导入另外 2 个配置类

```
package com.javacode2018.lesson001.demo25.test1;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Configuration
@Import({BeanConfig1.class,BeanConfig2.class}) //@1
public class MainConfig1 {
}
```

@1：通过 @Import 将其他 2 个配置类导入

#### 来个测试用例

ConditionTest 新增一个方法，方法中从容器中获取 IService 类型的 bean，然后输出：

```
@Test
public void test1() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig1.class);
    Map<String, IService> serviceMap = context.getBeansOfType(IService.class);
    serviceMap.forEach((beanName, bean) -> {
        System.out.println(String.format("%s->%s", beanName, bean));
    });
}
```

运行输出：

```
service1->com.javacode2018.lesson001.demo25.test1.Service1@2cd76f31
```

可以看出容器中只有一个 IService 类型的 bean。

可以将 @Bean 标注的 2 个方法上面的 @Conditional 去掉，再运行会输出：

```
service1->com.javacode2018.lesson001.demo25.test1.Service1@49438269
service2->com.javacode2018.lesson001.demo25.test1.Service2@ba2f4ec
```

此时没有条件限制，2 个 Service 都会注册到容器。

## 案例 4：根据环境选择配置类

平常我们做项目的时候，有开发环境、测试环境、线上环境，每个环境中有些信息是不一样的，比如数据库的配置信息，下面我们来模拟不同环境中使用不同的配置类来注册不同的 bean。

### 自定义一个条件的注解

```
package com.javacode2018.lesson001.demo25.test2;

import org.springframework.context.annotation.Conditional;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Conditional(EnvCondition.class) //@1
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface EnvConditional {
    //环境(测试环境、开发环境、生产环境)
    enum Env { //@2
        TEST, DEV, PROD
    }

    //环境
    Env value() default Env.DEV; //@3
}
```

@1：注意这个注解比较特别，这个注解上面使用到了 @Conditional 注解，这个地方使用到了一个自定义 Conditione 类：EnvCondition

@2：枚举，表示环境，定义了 3 个环境

@3：这个参数用指定环境

上面这个注解一会我们会用在不同环境的配置类上面

### 下面来 3 个配置类

让 3 个配置类分别在不同环境中生效，会在这些配置类上面使用上面自定义的 @EnvConditional 注解来做条件限定。

每个配置类中通过 @Bean 来定义一个名称为 name 的 bean，一会通过输出这个 bean 来判断哪个配置类生效了。

下面来看 3 个配置类的代码

#### 测试环境配置类

```
package com.javacode2018.lesson001.demo25.test2;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnvConditional(EnvConditional.Env.TEST)//@1
public class TestBeanConfig {
    @Bean
    public String name() {
        return "我是测试环境!";
    }
}
```

@1 指定的测试环境

#### 开发环境配置类

```
package com.javacode2018.lesson001.demo25.test2;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnvConditional(EnvConditional.Env.DEV) //@1
public class DevBeanConfig {
    @Bean
    public String name() {
        return "我是开发环境!";
    }
}
```

@1：指定的开发环境

#### 生产环境配置类

```
package com.javacode2018.lesson001.demo25.test2;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnvConditional(EnvConditional.Env.PROD) //@1
public class ProdBeanConfig {
    @Bean
    public String name() {
        return "我是生产环境!";
    }
}
```

@1：指定的生产环境

### 下面来看一下条件类：EnvCondition

条件类会解析配置类上面 @EnvConditional 注解，得到环境信息。

然后和目前的环境对比，决定返回 true 还是 false，如下：

```
package com.javacode2018.lesson001.demo25.test2;

import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.core.type.AnnotatedTypeMetadata;

public class EnvCondition implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        //当前需要使用的环境
        EnvConditional.Env curEnv = EnvConditional.Env.DEV; //@1
        //获取使用条件的类上的EnvCondition注解中对应的环境
        EnvConditional.Env env = (EnvConditional.Env) metadata.getAllAnnotationAttributes(EnvConditional.class.getName()).get("value").get(0);
        return env.equals(curEnv);
    }

}
```

@1：这个用来指定当前使用的环境，此处假定当前使用的是开发环境，这个我们以后可以任意发挥，比如将这些放到配置文件中，此处方便演示效果。

### 来个测试用例

```
@Test
public void test2() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig2.class);
    System.out.println(context.getBean("name"));
}
```

### 运行输出

```
我是开发环境!
```

可以看到开发环境生效了。

修改一下 EnvCondition 的代码，切换到生产环境：

```
EnvConditional.Env curEnv = EnvConditional.Env.PROD;
```

再次运行 test2 方法输出：

```
我是生产环境!
```

生产环境配置类生效了。

## 案例 5：Condition 指定优先级

### 多个 Condition 按顺序执行

@Condtional 中 value 指定多个 Condtion 的时候，默认情况下会按顺序执行，还是通过代码来看一下效果。

下面代码中定义了 3 个 Condition，每个 Condition 的 matches 方法中会输出当前类名，然后在配置类上面同时使用这 3 个 Condition：

```
package com.javacode2018.lesson001.demo25.test5;

import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.type.AnnotatedTypeMetadata;

class Condition1 implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        System.out.println(this.getClass().getName());
        return true;
    }
}

class Condition2 implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        System.out.println(this.getClass().getName());
        return true;
    }
}

class Condition3 implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        System.out.println(this.getClass().getName());
        return true;
    }
}

@Configuration
@Conditional({Condition1.class, Condition2.class, Condition3.class})
public class MainConfig5 {
}
```

来个测试用例

```
@Test
public void test5() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig5.class);
}
```

运行输出：

```
com.javacode2018.lesson001.demo25.test5.Condition1
com.javacode2018.lesson001.demo25.test5.Condition2
com.javacode2018.lesson001.demo25.test5.Condition3
com.javacode2018.lesson001.demo25.test5.Condition1
com.javacode2018.lesson001.demo25.test5.Condition2
com.javacode2018.lesson001.demo25.test5.Condition3
com.javacode2018.lesson001.demo25.test5.Condition1
com.javacode2018.lesson001.demo25.test5.Condition2
com.javacode2018.lesson001.demo25.test5.Condition3
```

上面有多行输出，是因为 spring 解析整个配置类的过程中，有好几个地方都会执行条件判断。

咱们只用关注前 3 行，可以看出输出的属性和 @Conditional 中 value 值的顺序是一样的。

### 指定 Condition 的顺序

自定义的 Condition 可以实现 PriorityOrdered 接口或者继承 Ordered 接口，或者使用 @Order 注解，通过这些来指定这些 Condition 的优先级。

**排序规则：先按 PriorityOrdered 排序，然后按照 order 的值进行排序；也就是：PriorityOrdered asc,order 值 asc**

```
下面这几个都可以指定order的值
接口：org.springframework.core.Ordered，有个getOrder方法用来返回int类型的值
接口：org.springframework.core.PriorityOrdered，继承了Ordered接口，所以也有getOrder方法
注解：org.springframework.core.annotation.Order，有个int类型的value参数指定Order的大小
```

看案例代码：

```
package com.javacode2018.lesson001.demo25.test6;


import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.PriorityOrdered;
import org.springframework.core.annotation.Order;
import org.springframework.core.type.AnnotatedTypeMetadata;

@Order(1) //@1
class Condition1 implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        System.out.println(this.getClass().getName());
        return true;
    }
}

class Condition2 implements Condition, Ordered { //@2
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        System.out.println(this.getClass().getName());
        return true;
    }

    @Override
    public int getOrder() { //@3
        return 0;
    }
}

class Condition3 implements Condition, PriorityOrdered { //@4
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        System.out.println(this.getClass().getName());
        return true;
    }

    @Override
    public int getOrder() {
        return 1000;
    }
}

@Configuration
@Conditional({Condition1.class, Condition2.class, Condition3.class})//@5
public class MainConfig6 {
}
```

@1：Condition1 通过 @Order 指定顺序，值为 1

@2：Condition2 通过实现了 Ordered 接口来指定顺序，@3：getOrder 方法返回 1

@4：Condition3 实现了 PriorityOrdered 接口，实现这个接口需要重写 getOrder 方法，返回 1000

@5：Condtion 顺序为 1、2、3

根据排序的规则，PriorityOrdered 的会排在前面，然后会再按照 order 升序，最后可以顺序是：

```
Condtion3->Condtion2->Condtion1
```

来个测试用例看看效果是不是我们分析的这样：

```
@Test
public void test6() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig6.class);
}
```

运行 test6，部分输出如下：

```
com.javacode2018.lesson001.demo25.test6.Condition3
com.javacode2018.lesson001.demo25.test6.Condition2
com.javacode2018.lesson001.demo25.test6.Condition1
```

结果和我们分析的一致。

## 案例 6：ConfigurationCondition 使用

ConfigurationCondition 使用的比较少，很多地方对这个基本上也不会去介绍，Condition 接口基本上可以满足 99% 的需求了，但是 springboot 中却大量用到了 ConfigurationCondition 这个接口。

ConfigurationCondition 通过解释比较难理解，来个案例感受一下：

### 来一个普通的类：Service

```
package com.javacode2018.lesson001.demo25.test7;

public class Service {
}
```

### 来一个配置类，通过配置类注册上面这个 Service

```
package com.javacode2018.lesson001.demo25.test7;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class BeanConfig1 {
    @Bean
    public Service service() {
        return new Service();
    }
}
```

### 再来一个配置类：BeanConfig2

```
package com.javacode2018.lesson001.demo25.test7;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class BeanConfig2 {
    @Bean
    public String name() {
        return "路人甲Java";
    }
}
```

### 来一个总的配置类

```
package com.javacode2018.lesson001.demo25.test7;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Configuration
@Import({BeanConfig1.class, BeanConfig2.class})
public class MainConfig7 {
}
```

上面通过 @Import 引入了另外 2 个配置类

### 来个测试用例加载 MainConfig7 配置类

```
@Test
public void test7() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig7.class);
    context.getBeansOfType(String.class).forEach((beanName, bean) -> {
        System.out.println(String.format("%s->%s", beanName, bean));
    });
}
```

上面从容器中获取 String 类型的 bean，然后输出。

### 运行输出

```
name->路人甲Java
```

### 现在我们有个需求

当容器中有 Service 这种类型的 bean 的时候，BeanConfig2 才生效。

很简单吧，加个 Condition 就行了，内部判断容器中是否有 Service 类型的 bean，继续

### 来个自定义的 Condition

```
package com.javacode2018.lesson001.demo25.test7;


import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.core.type.AnnotatedTypeMetadata;

public class MyCondition1 implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        //获取spring容器
        ConfigurableListableBeanFactory beanFactory = context.getBeanFactory();
        //判断容器中是否存在Service类型的bean
        boolean existsService = !beanFactory.getBeansOfType(Service.class).isEmpty();
        return existsService;
    }
}
```

上面代码很简单，判断容器中是否有 IService 类型的 bean。

### BeanConfig2 上使用 Condition 条件判断

```
@Configuration
@Conditional(MyCondition1.class)
public class BeanConfig2 {
    @Bean
    public String name() {
        return "路人甲Java";
    }
}
```

### 再次运行 test7 输出

无任何输出

### 为什么？

在文章前面我们说过，配置类的处理会依次经过 2 个阶段：配置类解析阶段和 bean 注册阶段，Condition 接口类型的条件会对这两个阶段都有效，解析阶段的时候，容器中是还没有 Service 这个 bean 的，配置类中通过 @Bean 注解定义的 bean 在 bean 注册阶段才会被注册到 spring 容器，所以 BeanConfig2 在解析阶段去容器中是看不到 Service 这个 bean 的，所以就被拒绝了。

**此时我们需要用到 ConfigurationCondition 了，让条件判断在 bean 注册阶段才起效。**

### 自定义一个 ConfigurationCondition 类

```
package com.javacode2018.lesson001.demo25.test7;

import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.context.annotation.ConfigurationCondition;
import org.springframework.core.type.AnnotatedTypeMetadata;

public class MyConfigurationCondition1 implements ConfigurationCondition {
    @Override
    public ConfigurationPhase getConfigurationPhase() {
        return ConfigurationPhase.REGISTER_BEAN; //@1
    }

    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        //获取spring容器
        ConfigurableListableBeanFactory beanFactory = context.getBeanFactory();
        //判断容器中是否存在Service类型的bean
        boolean existsService = !beanFactory.getBeansOfType(Service.class).isEmpty();
        return existsService;
    }
}
```

@1：指定条件在 bean 注册阶段，这个条件才有效

matches 方法中的内容直接复制过来，判断规则不变。

### 修改 BeanConfig2 的类容

```
将
@Conditional(MyCondition1.class)
替换为
@Conditional(MyConfigurationCondition1.class)
```

### 再次运行 test7 输出

```
name->路人甲Java
```

此时 name 这个 bean 被输出了。

可以再试试将 BeanConfig1 中 service 方法上面的 @Bean 去掉，此时 Service 就不会被注册到容器，再运行一下 test7，会发现没有输出了，此时 BeanConfig2 会失效。

**判断 bean 存不存在的问题，通常会使用 ConfigurationCondition 这个接口，阶段为：REGISTER_BEAN，这样可以确保条件判断是在 bean 注册阶段执行的。**

对 springboot 比较熟悉的，它里面有很多 @Conditionxxx 这样的注解，可以去看一下这些注解，很多都实现了 ConfigurationCondition 接口。

## Spring 中这块的源码 

**@Conditional 注解是被下面这个类处理的**

```
org.springframework.context.annotation.ConfigurationClassPostProcessor
```

## 总结

1. @Conditional 注解可以标注在 spring 需要处理的对象上（配置类、@Bean 方法），相当于加了个条件判断，通过判断的结果，让 spring 觉得是否要继续处理被这个注解标注的对象
2. spring 处理配置类大致有 2 个过程：解析配置类、注册 bean，这两个过程中都可以使用 @Conditional 来进行控制 spring 是否需要处理这个过程
3. Condition 默认会对 2 个过程都有效
4. ConfigurationCondition 控制得更细一些，可以控制到具体那个阶段使用条件判断

# 21、@Autowired、@Resource、@Primary、@Qulifier

你期望月薪 4 万，出门右拐，不送，这几个点，你也就是个初级的水平

## 先来看几个问题

1. 通过注解的方式注入依赖对象，介绍一下你知道的几种方式
2. @Autowired 和 @Resource 有何区别
3. 说一下 @Autowired 查找候选者的过程
4. 说一下 @Resource 查找候选者的过程
5. @Qulifier 有哪些用法？
6. @Qulifier 加在类上面是干什么用的？
7. @Primary 是做什么的？
8. 泛型注入用过么？

## 本文内容

1. 介绍 spring 中通过注解实现依赖注入的所有方式

- @Autowired 注解
- @Qualifier 注解
- @Resource 注解
- @Primary 注解
- @Bean 中注入的几种方式

1. 将指定类型的所有 bean，注入到集合中
2. 将指定类型的所有 bean，注入到 map 中
3. 注入泛型
4. 依赖注入源码方面的一些介绍

**本文内容比较多，所有知识点均有详细案例，大家一定要敲一遍，加深理解。**

## @Autowired：注入依赖对象

### 作用

**实现依赖注入，spring 容器会对 bean 中所有字段、方法进行遍历，标注有 @Autowired 注解的，都会进行注入。**

看一下其定义：

```
@Target({ElementType.CONSTRUCTOR, ElementType.METHOD, ElementType.PARAMETER, ElementType.FIELD, ElementType.ANNOTATION_TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Autowired {

    /**
     * Declares whether the annotated dependency is required.
     * <p>Defaults to {@code true}.
     */
    boolean required() default true;

}
```

可以用在构造器、方法、方法参数、字段、注解上。

参数：

required：标注的对象是否必须注入，可能这个对象在容器中不存在，如果为 true 的时候，找不到匹配的候选者就会报错，为 false 的时候，找不到也没关系 。

### @Autowire 查找候选者的过程

**查找过程有点复杂，看不懂的可以先跳过，先看后面案例，本文看完之后，可以回头再来看这个过程。**

#### @Autowired 标注在字段上面：假定字段类型为一个自定义的普通的类型，候选者查找过程如下



![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201214114152.png)



#### @Autowired 标注在方法上或者方法参数上面：假定参数类型为为一个自定义的普通的类型，候选者查找过程如下：



![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201214114149.png)



上图中深色的表示方法注入和字段注入查找过程的不同点。

上图中展示的是方法中只有一个参数的情况，如果有多个参数，就重复上面的过程，直到找到所有需要注入的参数。

#### 将指定类型的所有 bean 注入到 Collection 中

如果被注入的对象是 Collection 类型的，可以指定泛型的类型，然后会按照上面的方式查找所有满足泛型类型所有的 bean

#### 将指定类型的所有 bean 注入到 Map 中

如果被注入的对象是 Map 类型的，可以指定泛型的类型，key 通常为 String 类型，value 为需要查找的 bean 的类型，然后会按照上面方式查找所有注入 value 类型的 bean，将 bean 的 name 作为 key，bean 对象作为 value，放在 HashMap 中，然后注入。

#### @Autowired 查找候选者可以简化为下面这样

```
按类型找->通过限定符@Qualifier过滤->@Primary->@Priority->根据名称找（字段名称或者方法名称）
```

**概括为：先按类型找，然后按名称找**

### 案例 1：@Autowired 标注在构造器上，通过构造器注入依赖对象

#### Service1

```
package com.javacode2018.lesson001.demo26.test0;

import org.springframework.stereotype.Component;

@Component
public class Service1 {
}
```

#### Service2

```
package com.javacode2018.lesson001.demo26.test0;

import org.springframework.stereotype.Component;

@Component
public class Service2 {
    private Service1 service1;

    public Service2() { //@1
        System.out.println(this.getClass() + "无参构造器");
    }

    public Service2(Service1 service1) { //@2
        System.out.println(this.getClass() + "有参构造器");
        this.service1 = service1;
    }

    @Override
    public String toString() { //@2
        return "Service2{" +
                "service1=" + service1 +
                '}';
    }
}
```

Service2 中依赖于 Service1，有 2 个构造方法

@1：无参构造器

@2：有参构造器，可以通过这个传入依赖的 Service1

@3：重写了 toString 方法，一会打印测试的时候方便查看

#### 来个总的配置文件

```
package com.javacode2018.lesson001.demo26.test0;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan //@1
public class MainConfig0 {
}
```

@1：会自动扫描当前类所在的包，会将 Service1 和 Service2 注册到容器。

#### 来个测试用例

```
package com.javacode2018.lesson001.demo26;

import com.javacode2018.lesson001.demo26.test0.MainConfig0;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class InjectTest {

    @Test
    public void test0() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig0.class);
        for (String beanName : context.getBeanDefinitionNames()) {
            System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
        }
    }

}
```

main 方法中启动容器，加载 MainConfig0 配置类，然后输出容器中所有的 bean

#### 运行部分输出

```
class com.javacode2018.lesson001.demo26.test0.Service2无参构造器
service1->com.javacode2018.lesson001.demo26.test0.Service1@4a94ee4
service2->Service2{service1=null}
```

输出中可以看出调用了 Service2 的无参构造器，service2 中的 service1 为 null

#### 通过 @Autowired 指定注入的构造器

在 Service2 有参有参构造器上面加上 @Autowired 注解，如下：

```
@Autowired
public Service2(Service1 service1) {
    System.out.println(this.getClass() + "有参构造器");
    this.service1 = service1;
}
```

#### 再次运行 test0()

```
class com.javacode2018.lesson001.demo26.test0.Service2有参构造器
service1->com.javacode2018.lesson001.demo26.test0.Service1@4ec4f3a0
service2->Service2{service1=com.javacode2018.lesson001.demo26.test0.Service1@4ec4f3a0}
```

Service2 有参构造器被调用了，service2 中的 service1 有值了。

### 案例 2：@Autowired 标注在方法上，通过方法注入依赖的对象

#### Service1

```
package com.javacode2018.lesson001.demo26.test1;

import org.springframework.stereotype.Component;

@Component
public class Service1 {
}
```

#### Service2

```
package com.javacode2018.lesson001.demo26.test1;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Service2 {
    private Service1 service1;

    @Autowired
    public void injectService1(Service1 service1) { //@1
        System.out.println(this.getClass().getName() + ".injectService1()");
        this.service1 = service1;
    }

    @Override
    public String toString() {
        return "Service2{" +
                "service1=" + service1 +
                '}';
    }
}
```

@1：方法上标注了 @Autowired，spring 容器会调用这个方法，从容器中查找 Service1 类型的 bean，然后注入。

#### 来个总的配置文件

```
package com.javacode2018.lesson001.demo26.test1;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig1 {
}
```

#### 来个测试用例

InjectTest 中加个方法

```
@Test
public void test1() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig1.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
com.javacode2018.lesson001.demo26.test1.Service2.injectService1()
service1->com.javacode2018.lesson001.demo26.test1.Service1@9597028
service2->Service2{service1=com.javacode2018.lesson001.demo26.test1.Service1@9597028}
```

通过 injectService1 方法成功注入 service1

### 案例 3：@Autowired 标注在 setter 方法上，通过 setter 方法注入

上面 2 种通过构造器，和通过普通的一个方法注入，不是很常见，可以将 @Autowired 标注在 set 方法上面，来注入指定的对象

#### Service1

```
package com.javacode2018.lesson001.demo26.test2;

import org.springframework.stereotype.Component;

@Component
public class Service1 {
}
```

#### Service2

```
package com.javacode2018.lesson001.demo26.test2;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Service2 {

    private Service1 service1;

    @Autowired
    public void setService1(Service1 service1) { //@1
        System.out.println(this.getClass().getName() + ".setService1方法");
        this.service1 = service1;
    }

    @Override
    public String toString() {
        return "Service2{" +
                "service1=" + service1 +
                '}';
    }
}
```

@1：标准的 set 方法，方法上使用了 @Autowired，会通过这个方法注入 Service1 类型的 bean 对象。

#### 来个总的配置文件

```
package com.javacode2018.lesson001.demo26.test2;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig2 {
}
```

#### 来个测试用例

```
@Test
public void test2() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig2.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
com.javacode2018.lesson001.demo26.test2.Service2.setService1方法
service1->com.javacode2018.lesson001.demo26.test2.Service1@6069db50
service2->Service2{service1=com.javacode2018.lesson001.demo26.test2.Service1@6069db50}
```

### 案例 4：@Autowired 标注在方法参数上

#### Service1

```
package com.javacode2018.lesson001.demo26.test3;

import org.springframework.stereotype.Component;

@Component
public class Service1 {
}
```

#### Service2

```
package com.javacode2018.lesson001.demo26.test3;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Service2 {

    private Service1 service1;

    @Autowired
    public void injectService1(Service1 service1, String name) { //@1
        System.out.println(String.format("%s.injectService1(),{service1=%s,name=%s}", this.getClass().getName(), service1, name));
        this.service1 = service1;
    }

    @Override
    public String toString() {
        return "Service2{" +
                "service1=" + service1 +
                '}';
    }
}
```

@1：方法上标注了 @Autowired，表示会将这个方法作为注入方法，这个方法有 2 个参数，spring 查找这 2 个参数对应的 bean，然后注入。

第一个参数对应的 bean 是存在的，第二个是一个 String 类型的，我们并没有定义 String 类型 bean，一会看看效果

#### 来个总的配置文件

```
package com.javacode2018.lesson001.demo26.test3;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig3 {
}
```

#### 来个测试用例

```
@Test
public void test3() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig3.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'service2': Unsatisfied dependency expressed through method 'injectService1' parameter 1; nested exception is org.springframework.beans.factory.NoSuchBeanDefinitionException: No qualifying bean of type 'java.lang.String' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {}
```

报错了，从错误信息中可以看出，通过 injectService1 方法注入的时候，第二个参数为 String 类型，spring 从容器中没有找到 String 类型的候选 bean，所以报错了。

#### 我们可以这么做

**多个参数的时候，方法上面的 @Autowire 默认对方法中所有参数起效，如果我们想对某个参数进行特定的配置，可以在参数上加上 @Autowired，这个配置会覆盖方法上面的 @Autowired 配置。**

在第二个参数上面加上 @Autowired，设置 required 为 false：表示这个 bean 不是强制注入的，能找到就注入，找不到就注入一个 null 对象，调整一下代码，如下：

```
@Autowired
public void injectService1(Service1 service1, @Autowired(required = false) String name) { //@1
    System.out.println(String.format("%s.injectService1(),{service1=%s,name=%s}", this.getClass().getName(), service1, name));
    this.service1 = service1;
}
```

此时方法的第一个参数被方法上面的 @Autowired 约束

第二个参数受 @Autowired(required = false) 约束

#### 再次运行输出

```
com.javacode2018.lesson001.demo26.test3.Service2.injectService1(),{service1=com.javacode2018.lesson001.demo26.test3.Service1@59309333,name=null}
service1->com.javacode2018.lesson001.demo26.test3.Service1@59309333
service2->Service2{service1=com.javacode2018.lesson001.demo26.test3.Service1@59309333}
```

注入成功了，service1 有值，name 为 null

### 案例 5：@Autowired 用在字段上

#### Service1

```
package com.javacode2018.lesson001.demo26.test4;

import org.springframework.stereotype.Component;

@Component
public class Service1 {
}
```

#### Service2

```
package com.javacode2018.lesson001.demo26.test4;

import org.springframework.stereotype.Component;

@Component
public class Service2 {
}
```

#### Service3

```
package com.javacode2018.lesson001.demo26.test4;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Service3 {

    @Autowired
    private Service1 service1;//@1

    @Autowired
    private Service2 service2;//@2

    @Override
    public String toString() {
        return "Service3{" +
                "service1=" + service1 +
                ", service2=" + service2 +
                '}';
    }
}
```

@1 和 @2：定义了 2 个字段，上面都标注了 @Autowired，spring 会去容器中按照类型查找这 2 种类型的 bean，然后设置给这 2 个属性。

#### 来个总的配置文件

```
package com.javacode2018.lesson001.demo26.test4;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig4 {
}
```

#### 来个测试用例

```
@Test
public void test4() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig4.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
service1->com.javacode2018.lesson001.demo26.test4.Service1@7e07db1f
service2->com.javacode2018.lesson001.demo26.test4.Service2@1189dd52
service3->Service3{service1=com.javacode2018.lesson001.demo26.test4.Service1@7e07db1f, service2=com.javacode2018.lesson001.demo26.test4.Service2@1189dd52}
```

service3 中标注 @Autowired 的 2 个属性都有值了，都被注入成功了。

### 案例 6：@Autowire 标注字段，多个候选者的时候，按字段名称注入

#### IService 接口

```
package com.javacode2018.lesson001.demo26.test5;

public interface IService {
}
```

#### 接口来 2 个实现

2 个实现类上都标注了 @Component 注解，都会被注册到容器中。

##### Service0

```
package com.javacode2018.lesson001.demo26.test5;

import org.springframework.stereotype.Component;

@Component
public class Service0 implements IService {
}
```

##### Service1

```
package com.javacode2018.lesson001.demo26.test5;

import org.springframework.stereotype.Component;

@Component
public class Service1 implements IService {
}
```

#### 来个 Service2

```
package com.javacode2018.lesson001.demo26.test5;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Service2 {
    @Autowired
    private IService service1; //@1

    @Override
    public String toString() {
        return "Service2{" +
                "service1=" + service1 +
                '}';
    }
}
```

@1：标注了 @Autowired 注解，需要注入类型为 IService 类型的 bean，满足这种类型的有 2 个：service0 和 service1

按照上面介绍的候选者查找过程，最后会注入和字段名称一样的 bean，即：service1

#### 来个总的配置类，负责扫描当前包中的组件

```
package com.javacode2018.lesson001.demo26.test5;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig5 {
}
```

#### 来个测试用例

```
@Test
public void test5() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig5.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
service0->com.javacode2018.lesson001.demo26.test5.Service0@36902638
service1->com.javacode2018.lesson001.demo26.test5.Service1@223d2c72
service2->Service2{service1=com.javacode2018.lesson001.demo26.test5.Service1@223d2c72}
```

注意最后一行，service2 中的 service1 被注入了 bean：service1

### 案例 7：将指定类型的所有 bean，注入到 Collection、Map 中

#### 注入到 Collection 中

**被注入的类型为 Collection 类型或者 Collection 子接口类型，注意必须是接口类型**，如：

```
Collection<IService>
List<IService>
Set<IService>
```

**会在容器中找到所有 IService 类型的 bean，放到这个集合中**。

#### 注入到 Map 中

**被注入的类型为 Map 类型或者 Map 子接口类型，注意必须是接口类型**，如：

```
Map<String,IService>
```

**会在容器中找到所有 IService 类型的 bean，放到这个 Map 中，key 为 bean 的名称，value 为 bean 对象**。

来看案例代码。

#### 来个接口

```
package com.javacode2018.lesson001.demo26.test6;

public interface IService {
}
```

#### 来 2 个实现类，标注 @Component 注解

##### Service0

```
package com.javacode2018.lesson001.demo26.test6;

import org.springframework.stereotype.Component;

@Component
public class Service0 implements IService {
}
```

##### Service1

```
package com.javacode2018.lesson001.demo26.test6;

import org.springframework.stereotype.Component;

@Component
public class Service1 implements IService {
}
```

#### 再来个类 Service2

```
package com.javacode2018.lesson001.demo26.test6;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

@Component
public class Service2 {

    @Autowired
    private List<IService> services;

    @Autowired
    private Map<String, IService> serviceMap;

    @Override
    public String toString() {
        return "Service2{\n" +
                "services=" + services +
                ", \n serviceMap=" + serviceMap +
                '}';
    }
}
```

@1：注入 IService 类型的所有 bean

@2：注入一个 map

#### 来个总的配置类

```
package com.javacode2018.lesson001.demo26.test6;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig6 {
}
```

#### 来个测试用例

```
@Test
public void test6() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig6.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
service0->com.javacode2018.lesson001.demo26.test6.Service0@1189dd52
service1->com.javacode2018.lesson001.demo26.test6.Service1@36bc55de
service2->Service2{
services=[com.javacode2018.lesson001.demo26.test6.Service0@1189dd52, com.javacode2018.lesson001.demo26.test6.Service1@36bc55de], 
 serviceMap={service0=com.javacode2018.lesson001.demo26.test6.Service0@1189dd52, service1=com.javacode2018.lesson001.demo26.test6.Service1@36bc55de}}
```

注意看一下上面 services 和 serviceMap 的值。

### @Autowired 源码

spring 使用下面这个类处理 @Autowired 注解

```
org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor
```

## @Resource：注意依赖对象

### 作用

**和 @Autowired 注解类似，也是用来注入依赖的对象的，spring 容器会对 bean 中所有字段、方法进行遍历，标注有 @Resource 注解的，都会进行注入。**

看一下这个注解定义：

```
javax.annotation.Resource

@Target({TYPE, FIELD, METHOD})
@Retention(RUNTIME)
public @interface Resource {
    String name() default "";
    ..其他不常用的参数省略
}
```

这个注解是 javax 中定义的，并不是 spring 中定义的注解。

从定义上可以见，这个注解可以用在任何类型上面、字段、方法上面。

注意点：

**用在方法上的时候，方法参数只能有一个。**

### @Resource 查找候选者的过程

**查找过程有点复杂，看不懂的可以先跳过，先看后面案例，本文看完之后，可以回头再来看这个过程。**

#### @Resource 标注在字段上面：假定字段类型为一个自定义的普通的类型，候选者查找过程如下



![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201214114124.png)



#### @Autowired 标注在方法上或者方法参数上面：假定参数类型为为一个自定义的普通的类型，候选者查找过程如下：



![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201214114120.png)



#### 将指定类型的所有 bean 注入到 Collection 中

如果被注入的对象是 Collection 类型的，可以指定泛型的类型，然后会按照上面的方式查找所有满足泛型类型所有的 bean

#### 将指定类型的所有 bean 注入到 Map 中

如果被注入的对象是 Map 类型的，可以指定泛型的类型，key 通常为 String 类型，value 为需要查找的 bean 的类型，然后会按照上面方式查找所有注入 value 类型的 bean，将 bean 的 name 作为 key，bean 对象作为 value，放在 HashMap 中，然后注入。

#### @Resource 查找候选者可以简化为

```
先按Resource的name值作为bean名称找->按名称（字段名称、方法名称、set属性名称）找->按类型找->通过限定符@Qualifier过滤->@Primary->@Priority->根据名称找（字段名称或者方法参数名称）
```

**概括为：先按名称找，然后按类型找**

### 案例 1：将 @Resource 标注在字段上

#### IService 接口

```
package com.javacode2018.lesson001.demo26.test7;

public interface IService {
}
```

#### 2 个实现类

##### Service0

```
package com.javacode2018.lesson001.demo26.test7;

import org.springframework.stereotype.Component;

@Component
public class Service0 implements IService {
}
```

@Component 标注的 bean 名称默认为 service0

##### Service1

```
package com.javacode2018.lesson001.demo26.test7;

import org.springframework.stereotype.Component;

@Component
public class Service1 implements IService {
}
```

@Component 标注的 bean 名称默认为 service1

再来一个类

```
package com.javacode2018.lesson001.demo26.test7;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

@Component
public class Service2 {

    @Resource
    private IService service1;//@1

    @Override
    public String toString() {
        return "Service2{" +
                "service1=" + service1 +
                '}';
    }
}
```

@1：字段名称为 service1，按照字段名称查找 bean，会找到 Service1

#### 来个配置类

```
package com.javacode2018.lesson001.demo26.test7;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig7 {
}
```

#### 测试用例

```
@Test
public void test7() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig7.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
service0->com.javacode2018.lesson001.demo26.test7.Service0@222545dc
service1->com.javacode2018.lesson001.demo26.test7.Service1@5c5eefef
service2->Service2{service1=com.javacode2018.lesson001.demo26.test7.Service1@5c5eefef}
```

最后一行可以看出注入了 service1

#### 如果将 Service2 中的代码调整一下

```
@Resource
private IService service0;
```

此时会注入 service0 这个 bean

同样 @Resource 可以用在方法上，也可以将所有类型的 bean 注入到 Collection、Map 中，这里就不演示了，重点了解一下候选者查找的过程，使用上就比较简单了，@Resource 的其他案例，大家可以自己写写练练。

下面来说另外几个注解，也是比较重要的。

### @Resource 源码

spring 使用下面这个类处理 @Resource 注解

```
org.springframework.context.annotation.CommonAnnotationBeanPostProcessor
```

## @Qualifier：限定符

### 作用

这个单词的意思是：限定符。

**可以在依赖注入查找候选者的过程中对候选者进行过滤。**

看一下其定义：

```
@Target({ElementType.FIELD, ElementType.METHOD, ElementType.PARAMETER, ElementType.TYPE, ElementType.ANNOTATION_TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
@Documented
public @interface Qualifier {

    String value() default "";

}
```

可以用在字段、方法、参数、任意类型、注解上面

有一个参数 value

还是来看案例，通过案例理解更容易。

### 案例 1：用在类上

用在类上，你可以理解为给通过 @Qulifier 给这个 bean 打了一个标签。

#### 先来一个接口

```
package com.javacode2018.lesson001.demo26.test8;

public interface IService {
}
```

#### 来 3 个实现类

**前 2 个 @Qulifier 的 value 为 tag1，第 3 个实现类为 tag2**

#### Service1

```
package com.javacode2018.lesson001.demo26.test8;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Component
@Qualifier("tag1") //@1
public class Service1 implements IService {
}
```

@1：tag1

Service2

```
package com.javacode2018.lesson001.demo26.test8;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Component
@Qualifier("tag1")
public class Service2 implements IService {
}
```

@1：tag1

#### Service3

```
package com.javacode2018.lesson001.demo26.test8;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Component
@Qualifier("tag2")//@1
public class Service3 implements IService {
}
```

@1：tag2

#### 来一个类，来注入上面几个 bean

```
package com.javacode2018.lesson001.demo26.test8;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class InjectService {
    @Autowired
    @Qualifier("tag1") //@1
    private Map<String, IService> serviceMap1;

    @Autowired
    @Qualifier("tag2") //@2
    private Map<String, IService> serviceMap2;

    @Override
    public String toString() {
        return "InjectService{" +
                "serviceMap1=" + serviceMap1 +
                ", serviceMap2=" + serviceMap2 +
                '}';
    }
}
```

@1：限定符的值为 tag1，此时会将类上限定符为 tag1 的所有 bean 注入进来

@2：限定符的值为 tag2，此时会将类上限定符为 tag2 的所有 bean 注入进来

#### 来个配置类

```
package com.javacode2018.lesson001.demo26.test8;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig8 {
}
```

#### 测试用例

```
@Test
public void test8() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig8.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

运行输出

```
injectService->InjectService{serviceMap1={service1=com.javacode2018.lesson001.demo26.test8.Service1@9597028, service2=com.javacode2018.lesson001.demo26.test8.Service2@6069db50}, serviceMap2={service3=com.javacode2018.lesson001.demo26.test8.Service3@4efbca5a}}
service1->com.javacode2018.lesson001.demo26.test8.Service1@9597028
service2->com.javacode2018.lesson001.demo26.test8.Service2@6069db50
service3->com.javacode2018.lesson001.demo26.test8.Service3@4efbca5a
```

注意第一行的输出，看一下 serviceMap1 和 serviceMap2 的值。

serviceMap1 注入了 @Qulifier 的 value 为 tag1 的所有 IService 类型的 bean

serviceMap1 注入了 @Qulifier 的 value 为 tag2 的所有 IService 类型的 bean

实现了 bean 分组的效果。

### 案例 2：@Autowired 结合 @Qulifier 指定注入的 bean

被注入的类型有多个的时候，可以使用 @Qulifier 来指定需要注入那个 bean，将 @Qulifier 的 value 设置为需要注入 bean 的名称

看案例代码

#### 来个接口

```
package com.javacode2018.lesson001.demo26.test9;

public interface IService {
}
```

#### 有 2 个实现类

2 个实现类上面没有使用 @Qulifier 注解了

##### Service1

```
package com.javacode2018.lesson001.demo26.test9;

import org.springframework.stereotype.Component;

@Component
public class Service1 implements IService {
}
```

##### Service2

```
package com.javacode2018.lesson001.demo26.test9;

import org.springframework.stereotype.Component;

@Component
public class Service2 implements IService {
}
```

我们可以知道上面 2 个 bean 的名称分别为：service1、service2

#### 来个类，注入 IService 类型的 bean

```
package com.javacode2018.lesson001.demo26.test9;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Component
public class InjectService {
    @Autowired
    @Qualifier("service2") //@1
    private IService service;

    @Override
    public String toString() {
        return "InjectService{" +
                "service=" + service +
                '}';
    }
}
```

**@1：这里限定符的值为 service2，容器中 IService 类型的 bean 有 2 个 [service1 和 service2]，当类上没有标注 @Qualifier 注解的时候，可以理解为：bean 的名称就是限定符的值，所以 @1 这里会匹配到 service2**

#### 来个配置类

```
package com.javacode2018.lesson001.demo26.test9;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.stereotype.Component;

@ComponentScan
public class MainConfig9 {
}
```

#### 来个测试用例

```
@Test
public void test9() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig9.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
injectService->InjectService{service=com.javacode2018.lesson001.demo26.test9.Service2@223d2c72}
service1->com.javacode2018.lesson001.demo26.test9.Service1@8f4ea7c
service2->com.javacode2018.lesson001.demo26.test9.Service2@223d2c72
```

从第一行可以看出注入了 service1

### 案例 3：用在方法参数上

#### 代码

```
package com.javacode2018.lesson001.demo26.test10;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Component
public class InjectService {

    private IService s1;
    private IService s2;

    @Autowired
    public void injectBean(@Qualifier("service2") IService s1, @Qualifier("service1") IService s2) { //@1
        this.s1 = s1;
        this.s2 = s2;
    }

    @Override
    public String toString() {
        return "InjectService{" +
                "s1=" + s1 +
                ", s2=" + s2 +
                '}';
    }
}
```

@1：方法上标注了 @Autowired 注解，说明会被注入依赖，2 个参数上分别使用了限定符来指定具体需要注入哪个 bean

#### 测试用例

```
@Test
public void test10() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig10.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
injectService->InjectService{s1=com.javacode2018.lesson001.demo26.test10.Service2@55183b20, s2=com.javacode2018.lesson001.demo26.test10.Service1@4f83df68}
service1->com.javacode2018.lesson001.demo26.test10.Service1@4f83df68
service2->com.javacode2018.lesson001.demo26.test10.Service2@55183b20
```

第一行中的

s1：service2

s2：service1

### 案例 4：用在 setter 方法上

不管是用在 setter 方法还是普通方法上面，都是一样的效果

#### 代码

```
package com.javacode2018.lesson001.demo26.test11;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Component
public class InjectService {

    private IService s1;
    private IService s2;

    @Autowired
    @Qualifier("service2")
    public void setS1(IService s1) {
        this.s1 = s1;
    }

    @Autowired
    @Qualifier("service2")
    public void setS2(IService s2) {
        this.s2 = s2;
    }

    @Override
    public String toString() {
        return "InjectService{" +
                "s1=" + s1 +
                ", s2=" + s2 +
                '}';
    }
}
```

上面 2 个 setter 方法上都有 @Autowired 注解，并且结合了 @Qulifier 注解来限定需要注入哪个 bean

#### 测试用例

```
@Test
public void test11() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig11.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

运行输出

```
injectService->InjectService{s1=com.javacode2018.lesson001.demo26.test11.Service2@35e2d654, s2=com.javacode2018.lesson001.demo26.test11.Service2@35e2d654}
service1->com.javacode2018.lesson001.demo26.test11.Service1@1bd4fdd
service2->com.javacode2018.lesson001.demo26.test11.Service2@35e2d654
```

输出中可以看出：s1 为 service2，s2 为 service1

## @Primary：设置为主要候选者

注入依赖的过程中，当有多个候选者的时候，可以指定哪个候选者为主要的候选者。

看一下其定义

```
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Primary {

}
```

可以用在类上或者方法上面。

通常定义 bean 常见的有 2 种方式：

方式 1：在类上标注 @Component 注解，此时可以配合 @Primary，标注这个 bean 为主要候选者

方式 2：在配置文件中使用 @Bean 注解标注方法，来注册 bean，可以在 @Bean 标注的方法上加上 @Primary，标注这个 bean 为主要候选 bean。

看案例。

### 案例 1：用在类上

#### 来个接口

```
package com.javacode2018.lesson001.demo26.test12;

public interface IService {
}
```

#### 2 个实现类

##### Service1

```
package com.javacode2018.lesson001.demo26.test12;

import org.springframework.stereotype.Component;

@Component
public class Service1 implements IService {
}
```

##### Service2

```
package com.javacode2018.lesson001.demo26.test12;

import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;

@Component
@Primary
public class Service2 implements IService {
}
```

Service2 上面使用了 @Primary，表示这是个主要的候选者

#### 再来个类，注入 IService 类型的 bean

```
package com.javacode2018.lesson001.demo26.test12;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class InjectService {

    @Autowired
    private IService service1; //@1

    @Override
    public String toString() {
        return "InjectService{" +
                "service1=" + service1 +
                '}';
    }
}
```

@1：容器中 IService 类型的 bean 有 2 个，但是 service2 为主要的候选者，所以此处会注入 service2

#### 总的配置类

```
package com.javacode2018.lesson001.demo26.test12;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig12 {
}
```

#### 测试用例

```
@Test
public void test12() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig12.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
injectService->InjectService{service1=com.javacode2018.lesson001.demo26.test12.Service2@49ec71f8}
service1->com.javacode2018.lesson001.demo26.test12.Service1@1d2adfbe
service2->com.javacode2018.lesson001.demo26.test12.Service2@49ec71f8
```

### 案例 2：用在方法上，结合 @Bean 使用

#### 来个接口

```
package com.javacode2018.lesson001.demo26.test13;

public interface IService {
}
```

#### 2 个实现类

##### Service1

```
package com.javacode2018.lesson001.demo26.test13;

public class Service1 implements IService {
}
```

#### Service2

```
package com.javacode2018.lesson001.demo26.test13;

public class Service2 implements IService {
}
```

#### InjectService

```
package com.javacode2018.lesson001.demo26.test13;

import org.springframework.beans.factory.annotation.Autowired;

public class InjectService {

    @Autowired
    private IService service1;//@1

    @Override
    public String toString() {
        return "InjectService{" +
                "service1=" + service1 +
                '}';
    }
}
```

使用了 @Autowired，需要注入

#### 来个配置类，通过 @Bean 定义上面 3 个类型的 bean

```
package com.javacode2018.lesson001.demo26.test13;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Configuration
public class MainConfig13 {

    @Bean
    public IService service1() {
        return new Service1();
    }

    @Bean
    @Primary //@1
    public IService service2() {
        return new Service2();
    }

    @Bean
    public InjectService injectService() {
        return new InjectService();
    }
}
```

上面是一个配置类，定义了 3 个 bean

@1：这个 bean 被标注为主要的候选者

#### 来个测试用例

```
@Test
public void test13() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig13.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
service1->com.javacode2018.lesson001.demo26.test13.Service1@6913c1fb
service2->com.javacode2018.lesson001.demo26.test13.Service2@66d18979
injectService->InjectService{service1=com.javacode2018.lesson001.demo26.test13.Service2@66d18979}
```

注意最后一行，service1 注入的是 service2 这个 bean

## @Bean 定义 bean 时注入依赖的几种方式

### 常见 3 种方式

1. **硬编码方式**
2. **@Autowired、@Resource 的方式**
3. **@Bean 标注的方法参数的方式**

### 方式 1：硬编码方式

来 3 个类

#### Service1

```
package com.javacode2018.lesson001.demo26.test14;

public class Service1 {
}
```

#### Service2

```
package com.javacode2018.lesson001.demo26.test14;

public class Service2 {
}
```

#### Service3

```
package com.javacode2018.lesson001.demo26.test14;

public class Service3 {
    private Service1 service1;
    private Service2 service2;

    public Service1 getService1() {
        return service1;
    }

    public void setService1(Service1 service1) {
        this.service1 = service1;
    }

    public Service2 getService2() {
        return service2;
    }

    public void setService2(Service2 service2) {
        this.service2 = service2;
    }

    @Override
    public String toString() {
        return "Service3{" +
                "service1=" + service1 +
                ", service2=" + service2 +
                '}';
    }
}
```

上面类中会用到 service1 和 service2，提供了对应的 setter 方法，一会我们通过 setter 方法注入依赖对象

#### 来个配置类，通过 @Bean 的方式创建上面对象

```
package com.javacode2018.lesson001.demo26.test14;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MainConfig14 {
    @Bean
    public Service1 service1() {
        return new Service1();
    }

    @Bean
    public Service2 service2() {
        return new Service2();
    }

    @Bean
    public Service3 service3() {
        Service3 service3 = new Service3(); //@0
        service3.setService1(this.service1()); //@1
        service3.setService2(this.service2()); //@2
        return service3;
    }
}
```

上面代码中通过 @Bean 定义了 3 个 bean

Service3 中需要用到 Service1 和 Service2，注意 @1 和 @2 直接调用当前方法获取另外 2 个 bean，注入到 service3 中

#### 测试用例

```
@Test
public void test14() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig14.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

#### 运行输出

```
service1->com.javacode2018.lesson001.demo26.test14.Service1@41a2befb
service2->com.javacode2018.lesson001.demo26.test14.Service2@6c40365c
service3->Service3{service1=com.javacode2018.lesson001.demo26.test14.Service1@41a2befb, service2=com.javacode2018.lesson001.demo26.test14.Service2@6c40365c}
```

### 方式 2：@Autowired、@Resource 的方式

这种方式就不讲了直接在需要注入的对象上面加上这 2 个注解的任意一个就行了，可以参考文章前面的部分。

### 方式 3：@Bean 标注的方法使用参数来进行注入

```
package com.javacode2018.lesson001.demo26.test15;

import com.javacode2018.lesson001.demo26.test14.Service1;
import com.javacode2018.lesson001.demo26.test14.Service2;
import com.javacode2018.lesson001.demo26.test14.Service3;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MainConfig15 {
    @Bean
    public Service1 service1() {
        return new Service1();
    }

    @Bean
    public Service2 service2() {
        return new Service2();
    }

    @Bean
    public Service3 service3(Service1 s1, Service2 s2) { //@0
        Service3 service3 = new Service3();
        service3.setService1(s1); //@1
        service3.setService2(s2); //@2
        return service3;
    }
}
```

@0：这个地方是关键，方法上标注了 @Bean，并且方法中是有参数的，spring 调用这个方法创建 bean 的时候，会将参数中的两个参数注入进来。

注入对象的查找逻辑可以参考上面 @Autowired 标注方法时查找候选者的逻辑。

来个测试用例

```
@Test
public void test15() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig15.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

运行输出

```
service1->com.javacode2018.lesson001.demo26.test14.Service1@4009e306
service2->com.javacode2018.lesson001.demo26.test14.Service2@43c1b556
service3->Service3{service1=com.javacode2018.lesson001.demo26.test14.Service1@4009e306, service2=com.javacode2018.lesson001.demo26.test14.Service2@43c1b556}
```

同样注入成功了。

### 其他

#### @Bean 标注的方法参数上使用 @Autowired 注解

```
@Bean
public Service3 service3_0(Service1 s1, @Autowired(required = false) Service2 s2) { //@0
    Service3 service3 = new Service3();
    service3.setService1(s1); //@1
    service3.setService2(s2); //@2
    return service3;
}
```

@0：方法由 2 个参数，第二个参数上标注了 @Autowired(required = false)，说明第二个参数候选者不是必须的，找不到会注入一个 null 对象；第一个参数候选者是必须的，找不到会抛出异常

#### @Bean 结合 @Qualifier

```
package com.javacode2018.lesson001.demo26.test17;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Map;

@Configuration
public class MainConfig17 {

    @Bean
    @Qualifier("tag1") //@1
    public Service1 service1() {
        return new Service1();
    }

    @Bean
    @Qualifier("tag1") //@2
    public Service2 service2() {
        return new Service2();
    }

    @Bean
    @Qualifier("tag2") //@3
    public Service3 service3() {
        return new Service3();
    }

    @Bean
    public InjectService injectService(@Qualifier("tag1") Map<String, IService> map1) { //@4
        InjectService injectService = new InjectService();
        injectService.setServiceMap1(map1);
        return injectService;
    }
}
```

Service1,Service2,Service3 都实现了 IService 接口

@1,@2,@3 这 3 个方法上面使用了 @Bean 注解，用来定义 3 个 bean，这 3 个方法上还是用了 @Qualifier 注解，用来给这些 bean 定义标签，service1() 方法类似于下面的写法：

```
@Compontent
@Qualifier("tag1")
public class Service1 implements IService{
}
```

再回到 MainConfig17 中的 @4：参数中需要注入 Map<String, IService>，会查找 IService 类型的 bean，容器中有 3 个，但是这个参数前面加上了 @Qualifier 限定符，值为 tag1，所以会通过这个过滤，最后满足的候选者为：[service1,service]

对应测试用例

```
@Test
public void test17() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig17.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

运行输出

```
service1->com.javacode2018.lesson001.demo26.test17.Service1@1190200a
service2->com.javacode2018.lesson001.demo26.test17.Service2@6a2f6f80
service3->com.javacode2018.lesson001.demo26.test17.Service3@45b4c3a9
injectService->InjectService{serviceMap1={service1=com.javacode2018.lesson001.demo26.test17.Service1@1190200a, service2=com.javacode2018.lesson001.demo26.test17.Service2@6a2f6f80}, serviceMap2=null}
```

注意最后一行 serviceMap1，注入了 service1 和 service2

## 泛型注入

### 先来 2 个普通的类

#### UserModel

```
package com.javacode2018.lesson001.demo26.test18;

public class UserModel {
}
```

#### OrderModel

```
package com.javacode2018.lesson001.demo26.test18;

public class OrderModel {
}
```

记住上面 2 个普通的类 UserModel 和 OrderModel，一会下面会用到。

### 来个泛型接口

```
package com.javacode2018.lesson001.demo26.test18;

public interface IDao<T> {
}
```

上面是个泛型类，类名后面后尖括号

### 来 2 个实现类

两个实现类都会标注 @Compontent，交给 spring 容器管理

#### UserDao

```
package com.javacode2018.lesson001.demo26.test18;

import org.springframework.stereotype.Component;

@Component
public class UserDao implements IDao<UserModel> { //@1
}
```

@1：指定了 IDao 后面泛型的类型为 UserModel

#### OrderDao

```
package com.javacode2018.lesson001.demo26.test18;

import org.springframework.stereotype.Component;

@Component
public class OrderDao implements IDao<OrderModel> {//@1
}
```

@1：指定了 IDao 后面泛型的类型为 OrderModel

### 在来个泛型类型

```
package com.javacode2018.lesson001.demo26.test18;

import org.springframework.beans.factory.annotation.Autowired;

public class BaseService<T> {
    @Autowired
    private IDao<T> dao; //@1

    public IDao<T> getDao() {
        return dao;
    }

    public void setDao(IDao<T> dao) {
        this.dao = dao;
    }
}
```

BaseService 同样是个泛型类

@1：这个地方要注意了，上面使用了 @Autowired，来注入 IDao 对象

### BaseService 来 2 个子类

两个子类都会标注 @Compontent，交给 spring 容器管理

#### UserService

```
package com.javacode2018.lesson001.demo26.test18;

import org.springframework.stereotype.Component;

@Component
public class UserService extends BaseService<UserModel> {//@1
}
```

@1：指定了 BaseService 后面泛型的类型为 UserModel

#### OrderService

```
package com.javacode2018.lesson001.demo26.test18;

import org.springframework.stereotype.Component;

@Component
public class OrderService extends BaseService<OrderModel> {//@1
}
```

@1：指定了 BaseService 后面泛型的类型为 OrderModel

**UserService 和 OrderService 继承了 BaseService，所以一会 BaseService 中的 dao 属性会被注入，一会我们关注一下 dao 这个属性的值，会是什么样的**

### 来个总的配置类

```
package com.javacode2018.lesson001.demo26.test18;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig18 {
}
```

上面有 @CompontentScan 注解，会自动扫描当前包中的所有类，并进行自动注入

### 来个测试用例

```
@Test
public void test18() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig18.class);
    System.out.println(context.getBean(UserService.class).getDao());
    System.out.println(context.getBean(OrderService.class).getDao());
}
```

上面代码中会将两个 service 中的 dao 输出，我们来看一下效果

### 运行输出

```
com.javacode2018.lesson001.demo26.test18.UserDao@6adbc9d
com.javacode2018.lesson001.demo26.test18.OrderDao@4550bb58
```

结果就是重点了，dao 属性并没有指定具体需要注入那个 bean，此时是根据尖括号中的泛型类型来匹配的，这个功能也是相当厉害的。

## 总结

1. @Autowired：先通过类型找，然后通过名称找

2. @Resource：先通过名称找，然后通过类型找

3. @Autowired 和 @Resource，建议开发中使用 @Autowired 来实现依赖注入，spring 的注解用起来更名正言顺一些

4. @Qulifier：限定符，可以用在类上；也可以用在依赖注入的地方，可以对候选者的查找进行过滤

5. @Primary：多个候选者的时候，可以标注某个候选者为主要的候选者

   

# 22、@Scope、@DependsOn、@ImportResource、@Lazy 详解

## 面试问题

1. **@Scope 是做什么的？常见的用法有几种？**
2. **@DependsOn 是做什么的？常见的用法有几种？**
3. **@ImportResource 干什么的？通常用在什么地方？**
4. **@Lazy 做什么的，通常用在哪些地方？常见的用法有几种？**

## @Scope：指定 bean 的作用域

### 用法

关于什么是 bean 的作用域，可以去看一下之前的一篇文章：[Spring 系列第 6 篇：玩转 bean scope，避免跳坑里！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933960&idx=1&sn=f4308f8955f87d75963c379c2a0241f4&chksm=88621e76bf159760d404c253fa6716d3ffce4de8df0fc1d0d5dd0cf00a81bc170a30829ee58f&token=1314297026&lang=zh_CN&scene=21#wechat_redirect)

@Scope 用来配置 bean 的作用域，等效于 bean xml 中的 bean 元素中的 scope 属性。

看一下其源码：

```
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Scope {

    @AliasFor("scopeName")
    String value() default "";

    @AliasFor("value")
    String scopeName() default "";

    ScopedProxyMode proxyMode() default ScopedProxyMode.DEFAULT;

}
```

@Scope 可以用在类上和方法上

参数：value 和 scopeName 效果一样，用来指定 bean 作用域名称，如：singleton、prototype

### 常见 2 种用法

1. 和 @Compontent 一起使用在类上
2. 和 @Bean 一起标注在方法上

### 案例 1：和 @Compontent 一起使用在类上

```
@Component
@Scope(ConfigurableBeanFactory.SCOPE_SINGLETON)//@1
public class ServiceA {
}
```

上面定义了一个 bean，作用域为单例的。

@1：ConfigurableBeanFactory 接口中定义了几个作用域相关的常量，可以直接拿来使用，如：

String SCOPE_SINGLETON = "singleton";

String SCOPE_PROTOTYPE = "prototype";

### 案例 2：和 @Bean 一起标注在方法上

@Bean 标注在方法上，可以通过这个方法来向 spring 容器中注册一个 bean，在此方法上加上 @Scope 可以指定这个 bean 的作用域，如：

```
@Configurable
public class MainConfig2 {
    @Bean
    @Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
    public ServiceA serviceA() {
        return new ServiceA();
    }
}
```

## @DependsOn：指定当前 bean 依赖的 bean

### 用法

前面有篇文章中介绍了 bean xml 中 depend-on 的使用，建议先看一下：[Spring 系列第 9 篇：depend-on 到底是干什么的？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933982&idx=1&sn=69a2906f5db1953030ff40225b3ac788&chksm=88621e60bf159776093398f89652fecc99fb78ddf6f7434afbe65f8511d3e41c65d729303507&token=880944996&lang=zh_CN&scene=21#wechat_redirect)

@DependsOn 等效于 bean xml 中的 bean 元素中的 depend-on 属性。

spring 在创建 bean 的时候，如果 bean 之间没有依赖关系，那么 spring 容器很难保证 bean 实例创建的顺序，如果想确保容器在创建某些 bean 之前，需要先创建好一些其他的 bean，可以通过 @DependsOn 来实现，**@DependsOn 可以指定当前 bean 依赖的 bean，通过这个可以确保 @DependsOn 指定的 bean 在当前 bean 创建之前先创建好**

看一下其源码：

```
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface DependsOn {

    String[] value() default {};

}
```

可以用在任意类型和方法上。

value：string 类型的数组，用来指定当前 bean 需要依赖的 bean 名称，可以确保当前容器在创建被 @DependsOn 标注的 bean 之前，先将 value 指定的多个 bean 先创建好。

### 常见 2 种用法

1. 和 @Compontent 一起使用在类上
2. 和 @Bean 一起标注在方法上

### 案例 1：和 @Compontent 一起使用在类上

下面定义 3 个 bean：service1、service2、service3；service1 需要依赖于其他 2 个 service，需要确保容器在创建 service1 之前需要先将其他 2 个 bean 先创建好。

看代码：

#### Service2

```
package com.javacode2018.lesson001.demo27.test3;

import org.springframework.stereotype.Component;

@Component
public class Service2 {
    public Service2() {
        System.out.println("create Service2");
    }
}
```

#### Service3

```
package com.javacode2018.lesson001.demo27.test3;

import org.springframework.stereotype.Component;

@Component
public class Service3 {
    public Service3() {
        System.out.println("create Service3");
    }
}
```

#### Service1

```
package com.javacode2018.lesson001.demo27.test3;

import org.springframework.context.annotation.DependsOn;
import org.springframework.stereotype.Component;

@DependsOn({"service2", "service3"}) //@1
@Component
public class Service1 {
    public Service1() {
        System.out.println("create Service1");
    }
}
```

@1：使用了 @DependsOn，指定了 2 个 bean：service2 和 service3，那么 spring 容器在创建上面这个 service1 的时候会先将 @DependsOn 中指定的 2 个 bean 先创建好

#### 来个配置类

```
package com.javacode2018.lesson001.demo27.test3;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig3 {
}
```

#### 测试用例

```
@Test
public void test3() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig3.class);
    System.out.println(context.getBean(Service1.class));
}
```

#### 运行输出

```
create Service2
create Service3
create Service1
com.javacode2018.lesson001.demo27.test3.Service1@9f116cc
```

从输出中可以看到，spring 容器在创建 service1 之前，先将 service2 和 service3 创建好了。

### 案例 2：和 @Bean 一起标注在方法上

下面通过配置文件的方式来创建 bean，如下：

```
package com.javacode2018.lesson001.demo27.test4;

import org.springframework.beans.factory.annotation.Configurable;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.DependsOn;

@Configurable
public class MainConfig4 {

    @Bean
    @DependsOn({"service2", "service3"})//@1
    public Service1 service1() {
        return new Service1();
    }

    @Bean
    public Service2 service2() {
        return new Service2();
    }

    @Bean
    public Service3 service3() {
        return new Service3();
    }

}
```

上面是一个 spring 的配置类，类中 3 个方法定义了 3 个 bean

@1：这个地方使用了 @DependsOn，表示 service1 这个 bean 创建之前，会先创建好 service2 和 service3

来个测试用例

```
@Test
public void test4() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig4.class);
    System.out.println(context.getBean(com.javacode2018.lesson001.demo27.test4.Service1.class));
}
```

运行输出

```
create Service2
create Service3
create Service1
com.javacode2018.lesson001.demo27.test4.Service1@6e20b53a
```

## @ImportResource：配置类中导入 bean 定义的配置文件

### 用法

有些项目，前期可能采用 xml 的方式配置 bean，后期可能想采用 spring 注解的方式来重构项目，但是有些老的模块可能还是 xml 的方式，spring 为了方便在注解方式中兼容老的 xml 的方式，提供了 @ImportResource 注解来引入 bean 定义的配置文件。

bean 定义配置文件：目前我们主要介绍了 xml 的方式，还有一种 properties 文件的方式，以后我们会介绍，此时我们还是以引入 bean xml 来做说明。

看一下这个注解的定义：

```
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Documented
public @interface ImportResource {

    @AliasFor("locations")
    String[] value() default {};

    @AliasFor("value")
    String[] locations() default {};

    Class<? extends BeanDefinitionReader> reader() default BeanDefinitionReader.class;

}
```

**通常将其用在配置类上。**

有 3 个参数：

- value 和 locations 效果一样，只能配置其中一个，是一个 string 类型的数组，用来指定需要导入的配置文件的路径。
- reader：用来指定 bean 定义的读取器，目前我们知道的配置 bean 的方式有 xml 文件的方式，注解的方式，其实还有其他的方式，比如 properties 文件的方式，如果用其他的方式，你得告诉 spring 具体要用那种解析器去解析这个 bean 配置文件，这个解析器就是 BeanDefinitionReader，以后我们讲 BeanDefinition 的时候再细说。

### 资源文件路径的写法

通常我们的项是采用 maven 来组织的，配置文件一般会放在 resources 目录，这个目录中的文件被编译之后会在 target/classes 目录中。

spring 中资源文件路径最常用的有 2 种写法：

1. **以 classpath: 开头**：检索目标为当前项目的 classes 目录
2. **以 classpath\*: 开头**：检索目标为当前项目的 classes 目录，以及项目中所有 jar 包中的目录，如果你确定 jar 不是检索目标，就不要用这种方式，由于需要扫描所有 jar 包，所以速度相对于第一种会慢一些

那我们再来说 classpath: 和 classpath*: 后面的部分，后面的部分是确定资源文件的位置地方，几种常见的如下：

#### 相对路径的方式

```
classpath:com/javacode2018/lesson001/demo27/test5/beans.xml
或者
classpath*:com/javacode2018/lesson001/demo27/test5/beans.xml
```

#### /：绝对路径的方式

```
classpath:/com/javacode2018/lesson001/demo27/test5/beans.xml
```

#### *：文件通配符的方式

```
classpath:/com/javacode2018/lesson001/demo27/test5/beans-*.xml
```

会匹配 test5 目录中所有以 beans - 开头的 xml 结尾的文件

#### *：目录通配符的方式

```
classpath:/com/javacode2018/lesson001/demo27/*/beans-*.xml
```

会匹配 demo27 中所有子目录中所有以 beans - 开头的 xml 结尾的文件，注意这个地方只包含 demo27 的子目录，不包含子目录的子目录，不会进行递归

#### **：递归任意子目录的方式

```
classpath:/com/javacode2018/**/beans-*.xml
```

** 会递归当前目录以及下面任意级的子目录

ok，继续回到 @ImportResource 上来，来看案例

### 案例代码

来 2 个类，这两个类我们分别用 2 个 xml 来定义 bean

#### ServiceA

```
package com.javacode2018.lesson001.demo27.test5;

public class ServiceA {
}
```

#### ServiceB

```
package com.javacode2018.lesson001.demo27.test5;

public class ServiceB {
}
```

#### beans1.xml 来定义 serviceA 这个 bean，如下

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-4.3.xsd">

    <bean id="serviceA" class="com.javacode2018.lesson001.demo27.test5.ServiceA"/>

</beans>
```

#### beans2.xml 来定义 serviceB 这个 bean，如下

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-4.3.xsd">

    <bean id="serviceB" class="com.javacode2018.lesson001.demo27.test5.ServiceB"/>

</beans>
```

#### 下面来个配置类，来引入上面 2 个配置文件

```
package com.javacode2018.lesson001.demo27.test5;

import org.springframework.beans.factory.annotation.Configurable;
import org.springframework.context.annotation.ImportResource;

@Configurable
@ImportResource("classpath:/com/javacode2018/lesson001/demo27/test5/beans*.xml")
public class MainConfig5 {
}
```

这个类上使用了 @Configurable 表示这是个配置类

并且使用了 @ImportResource 注解来导入上面 2 个配置文件

#### 来个测试用例加载上面这个配置类

```
@Test
public void test5() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig5.class);
    for (String beanName : context.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
    }
}
```

上面会输出 MainConfig5 配置类中所有定义的 bean

#### 运行输出

```
mainConfig5->com.javacode2018.lesson001.demo27.test5.MainConfig5@4ec4f3a0
serviceA->com.javacode2018.lesson001.demo27.test5.ServiceA@223191a6
serviceB->com.javacode2018.lesson001.demo27.test5.ServiceB@49139829
```

从输出中可以看出 2 个 xml 中定义的 bean 也被注册了

## @Lazy：延迟初始化

### 用法

@Lazy 等效于 bean xml 中 bean 元素的 lazy-init 属性，可以实现 bean 的延迟初始化。

**所谓延迟初始化：就是使用到的时候才会去进行初始化。**

来看一下其定义：

```
@Target({ElementType.TYPE, ElementType.METHOD, ElementType.CONSTRUCTOR, ElementType.PARAMETER, ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Lazy {

    boolean value() default true;

}
```

可以用在任意类型、方法、构造器、参数、字段上面

参数：

value：boolean 类型，用来配置是否应发生延迟初始化，默认为 true。

### 常用 3 种方式

1. 和 @Compontent 一起标注在类上，可以是这个类延迟初始化
2. 和 @Configuration 一起标注在配置类中，可以让当前配置类中通过 @Bean 注册的 bean 延迟初始化
3. 和 @Bean 一起使用，可以使当前 bean 延迟初始化

来看一下这 3 种方式案例代码。

### 案例 1：和 @Compontent 一起使用

#### Service1

```
package com.javacode2018.lesson001.demo27.test6;

import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

@Component
@Lazy //@1
public class Service1 {
    public Service1() {
        System.out.println("创建Service1");
    }
}
```

@1：使用到了 @Lazy，默认值为 true，表示会被延迟初始化，在容器启动过程中不会被初始化，当从容器中查找这个 bean 的时候才会被初始化。

#### 配置类

```
package com.javacode2018.lesson001.demo27.test6;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig6 {
}
```

#### 测试用例

```
@Test
public void test6() {
    System.out.println("准备启动spring容器");
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig6.class);
    System.out.println("spring容器启动完毕");
    System.out.println(context.getBean(com.javacode2018.lesson001.demo27.test6.Service1.class));
}
```

运行输出

```
准备启动spring容器
spring容器启动完毕
创建Service1
com.javacode2018.lesson001.demo27.test6.Service1@4fb61f4a
```

可以看出 service1 这个 bean 在 spring 容器启动过程中并没有被创建，而是在我们调用 getBean 进行查找的时候才进行创建的，此时起到了延迟创建的效果。

### 案例 2：和 @Configuration 一起使用加在配置类上

@Lazy 和 @Configuration 一起使用，此时配置类中所有通过 @Bean 方式注册的 bean 都会被延迟初始化，不过也可以在 @Bean 标注的方法上使用 @Lazy 来覆盖配置类上的 @Lazy 配置，看下面代码：

#### 配置类 MainConfig7

```
package com.javacode2018.lesson001.demo27.test7;

import org.springframework.beans.factory.annotation.Configurable;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Lazy;

@Lazy //@1
@Configurable
public class MainConfig7 {

    @Bean
    public String name() {
        System.out.println("create bean:name");
        return "路人甲Java";
    }

    @Bean
    public String address() {
        System.out.println("create bean:address");
        return "上海市";
    }

    @Bean
    @Lazy(false) //@2
    public Integer age() {
        System.out.println("create bean:age");
        return 30;
    }
}
```

@1：配置类上使用了 @Lazy，此时会对当前类中所有 @Bean 标注的方法生效

@2：这个方法上面使用到了 @Lazy(false)，此时 age 这个 bean 不会被延迟初始化。其他 2 个 bean 会被延迟初始化。

#### 测试用例

```
@Test
public void test7() {
    System.out.println("准备启动spring容器");
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig7.class);
    System.out.println("spring容器启动完毕");

    for (String beanName : Arrays.asList("name", "age", "address")) {
        System.out.println("----------");
        System.out.println("getBean:" + beanName + ",start");
        System.out.println(String.format("%s->%s", beanName, context.getBean(beanName)));
        System.out.println("getBean:" + beanName + ",end");
    }
}
```

上面会输出配置类中定义的 3 个 bean 的信息。

#### 运行输出

```
准备启动spring容器
create bean:age
spring容器启动完毕
----------
getBean:name,start
create bean:name
name->路人甲Java
getBean:name,end
----------
getBean:age,start
age->30
getBean:age,end
----------
getBean:address,start
create bean:address
address->上海市
getBean:address,end
```

输出中可以看到 age 是在容器启动过程中创建的，其他 2 个是在通过 getBean 查找的时候才创建的。

## 总结

1. 本文介绍的几个注解也算是比较常用的，大家一定要熟悉他们的用法
2. @Scope：用来定义 bean 的作用域；2 种用法：第 1 种：标注在类上；第 2 种：和 @Bean 一起标注在方法上
3. @DependsOn：用来指定当前 bean 依赖的 bean，可以确保在创建当前 bean 之前，先将依赖的 bean 创建好；2 种用法：第 1 种：标注在类上；第 2 种：和 @Bean 一起标注在方法上
4. @ImportResource：标注在配置类上，用来引入 bean 定义的配置文件
5. @Lazy：让 bean 延迟初始化；常见 3 种用法：第 1 种：标注在类上；第 2 种：标注在配置类上，会对配置类中所有的 @Bean 标注的方法有效；第 3 种：和 @Bean 一起标注在方法上

