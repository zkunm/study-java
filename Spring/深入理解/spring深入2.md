# 23、Bean生命周期详解

## Spring bean 生命周期 13 个环节

1. 阶段 1：Bean 元信息配置阶段
2. 阶段 2：Bean 元信息解析阶段
3. 阶段 3：将 Bean 注册到容器中
4. 阶段 4：BeanDefinition 合并阶段
5. 阶段 5：Bean Class 加载阶段
6. 阶段 6：Bean 实例化阶段（2 个小阶段）

- Bean 实例化前阶段
- Bean 实例化阶段

1. 阶段 7：合并后的 BeanDefinition 处理
2. 阶段 8：属性赋值阶段（3 个小阶段）

- Bean 实例化后阶段
- Bean 属性赋值前阶段
- Bean 属性赋值阶段

1. 阶段 9：Bean 初始化阶段（5 个小阶段）

- Bean Aware 接口回调阶段
- Bean 初始化前阶段
- Bean 初始化阶段
- Bean 初始化后阶段

1. 阶段 10：所有单例 bean 初始化完成后阶段
2. 阶段 11：Bean 的使用阶段
3. 阶段 12：Bean 销毁前阶段
4. 阶段 13：Bean 销毁阶段

## 阶段 1：Bean 元信息配置阶段

这个阶段主要是 bean 信息的定义阶段。

### Bean 信息定义 4 种方式

- API 的方式
- Xml 文件方式
- properties 文件的方式
- 注解的方式

### API 的方式

先来说这种方式，因为其他几种方式最终都会采用这种方式来定义 bean 配置信息。

**Spring 容器启动的过程中，会将 Bean 解析成 Spring 内部的 BeanDefinition 结构**。
不管是是通过 xml 配置文件的`<Bean>`标签，还是通过注解配置的`@Bean`，还是`@Compontent`标注的类，还是扫描得到的类，它最终都会被解析成一个 BeanDefinition 对象，最后我们的 Bean 工厂就会根据这份 Bean 的定义信息，对 bean 进行实例化、初始化等等操作。

你可以把 BeanDefinition 丢给 Bean 工厂，然后 Bean 工厂就会根据这个信息帮你生产一个 Bean 实例，拿去使用。

BeanDefinition 里面里面包含了 bean 定义的各种信息，如：bean 对应的 class、scope、lazy 信息、dependOn 信息、autowireCandidate（是否是候选对象）、primary（是否是主要的候选者）等信息。

BeanDefinition 是个接口，有几个实现类，看一下类图：



![img](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06CrIYFap4nHD49qQocotb08U3z48gRWU7YF4LQulGg83HdSPplbXKA64ibNTtRTJNNMdvMufJne2ag/640?wx_fmt=png)



#### BeanDefinition 接口：bean 定义信息接口

表示 bean 定义信息的接口，里面定义了一些获取 bean 定义配置信息的各种方法，来看一下源码：

```
public interface BeanDefinition extends AttributeAccessor, BeanMetadataElement {

    /**
     * 设置此bean的父bean名称（对应xml中bean元素的parent属性）
     */
    void setParentName(@Nullable String parentName);

    /**
     * 返回此bean定义时指定的父bean的名称
     */
    @Nullable
    String getParentName();

    /**
     * 指定此bean定义的bean类名(对应xml中bean元素的class属性)
     */
    void setBeanClassName(@Nullable String beanClassName);

    /**
     * 返回此bean定义的当前bean类名
     * 注意，如果子定义重写/继承其父类的类名，则这不一定是运行时使用的实际类名。此外，这可能只是调用工厂方法的类，或者在调用方法的工厂bean引用的情况下，它甚至可能是空的。因此，不要认为这是运行时的最终bean类型，而只将其用于单个bean定义级别的解析目的。
     */
    @Nullable
    String getBeanClassName();

    /**
     * 设置此bean的生命周期，如：singleton、prototype（对应xml中bean元素的scope属性）
     */
    void setScope(@Nullable String scope);

    /**
     * 返回此bean的生命周期，如：singleton、prototype
     */
    @Nullable
    String getScope();

    /**
     * 设置是否应延迟初始化此bean（对应xml中bean元素的lazy属性）
     */
    void setLazyInit(boolean lazyInit);

    /**
     * 返回是否应延迟初始化此bean，只对单例bean有效
     */
    boolean isLazyInit();

    /**
     * 设置此bean依赖于初始化的bean的名称,bean工厂将保证dependsOn指定的bean会在当前bean初始化之前先初始化好
     */
    void setDependsOn(@Nullable String... dependsOn);

    /**
     * 返回此bean所依赖的bean名称
     */
    @Nullable
    String[] getDependsOn();

    /**
     * 设置此bean是否作为其他bean自动注入时的候选者
     * autowireCandidate
     */
    void setAutowireCandidate(boolean autowireCandidate);

    /**
     * 返回此bean是否作为其他bean自动注入时的候选者
     */
    boolean isAutowireCandidate();

    /**
     * 设置此bean是否为自动注入的主要候选者
     * primary：是否为主要候选者
     */
    void setPrimary(boolean primary);

    /**
     * 返回此bean是否作为自动注入的主要候选者
     */
    boolean isPrimary();

    /**
     * 指定要使用的工厂bean（如果有）。这是要对其调用指定工厂方法的bean的名称。
     * factoryBeanName：工厂bean名称
     */
    void setFactoryBeanName(@Nullable String factoryBeanName);

    /**
     * 返回工厂bean名称（如果有）（对应xml中bean元素的factory-bean属性）
     */
    @Nullable
    String getFactoryBeanName();

    /**
     * 指定工厂方法（如果有）。此方法将使用构造函数参数调用，如果未指定任何参数，则不使用任何参数调用。该方法将在指定的工厂bean（如果有的话）上调用，或者作为本地bean类上的静态方法调用。
     * factoryMethodName：工厂方法名称
     */
    void setFactoryMethodName(@Nullable String factoryMethodName);

    /**
     * 返回工厂方法名称（对应xml中bean的factory-method属性）
     */
    @Nullable
    String getFactoryMethodName();

    /**
     * 返回此bean的构造函数参数值
     */
    ConstructorArgumentValues getConstructorArgumentValues();

    /**
     * 是否有构造器参数值设置信息（对应xml中bean元素的<constructor-arg />子元素）
     */
    default boolean hasConstructorArgumentValues() {
        return !getConstructorArgumentValues().isEmpty();
    }

    /**
     * 获取bean定义是配置的属性值设置信息
     */
    MutablePropertyValues getPropertyValues();

    /**
     * 这个bean定义中是否有属性设置信息（对应xml中bean元素的<property />子元素）
     */
    default boolean hasPropertyValues() {
        return !getPropertyValues().isEmpty();
    }

    /**
     * 设置bean初始化方法名称
     */
    void setInitMethodName(@Nullable String initMethodName);

    /**
     * bean初始化方法名称
     */
    @Nullable
    String getInitMethodName();

    /**
     * 设置bean销毁方法的名称
     */
    void setDestroyMethodName(@Nullable String destroyMethodName);

    /**
     * bean销毁的方法名称
     */
    @Nullable
    String getDestroyMethodName();

    /**
     * 设置bean的role信息
     */
    void setRole(int role);

    /**
     * bean定义的role信息
     */
    int getRole();

    /**
     * 设置bean描述信息
     */
    void setDescription(@Nullable String description);

    /**
     * bean描述信息
     */
    @Nullable
    String getDescription();

    /**
     * bean类型解析器
     */
    ResolvableType getResolvableType();

    /**
     * 是否是单例的bean
     */
    boolean isSingleton();

    /**
     * 是否是多列的bean
     */
    boolean isPrototype();

    /**
     * 对应xml中bean元素的abstract属性，用来指定是否是抽象的
     */
    boolean isAbstract();

    /**
     * 返回此bean定义来自的资源的描述（以便在出现错误时显示上下文）
     */
    @Nullable
    String getResourceDescription();

    @Nullable
    BeanDefinition getOriginatingBeanDefinition();

}
```

BeanDefinition 接口上面还继承了 2 个接口：

- AttributeAccessor
- BeanMetadataElement

##### AttributeAccessor 接口：属性访问接口

```
public interface AttributeAccessor {

    /**
     * 设置属性->值
     */
    void setAttribute(String name, @Nullable Object value);

    /**
     * 获取某个属性对应的值
     */
    @Nullable
    Object getAttribute(String name);

    /**
     * 移除某个属性
     */
    @Nullable
    Object removeAttribute(String name);

    /**
     * 是否包含某个属性
     */
    boolean hasAttribute(String name);

    /**
     * 返回所有的属性名称
     */
    String[] attributeNames();

}
```

这个接口相当于 key->value 数据结构的一种操作，BeanDefinition 继承这个，内部实际上是使用了 LinkedHashMap 来实现这个接口中的所有方法，通常我们通过这些方法来保存 BeanDefinition 定义过程中产生的一些附加信息。

##### BeanMetadataElement 接口

看一下其源码：

```
public interface BeanMetadataElement {

    @Nullable
    default Object getSource() {
        return null;
    }

}
```

BeanDefinition 继承这个接口，getSource 返回 BeanDefinition 定义的来源，比如我们通过 xml 定义 BeanDefinition 的，此时 getSource 就表示定义 bean 的 xml 资源；若我们通过 api 的方式定义 BeanDefinition，我们可以将 source 设置为定义 BeanDefinition 时所在的类，出错时，可以根据这个来源方便排错。

#### RootBeanDefinition 类：表示根 bean 定义信息

通常 bean 中没有父 bean 的就使用这种表示

#### ChildBeanDefinition 类：表示子 bean 定义信息

如果需要指定父 bean 的，可以使用 ChildBeanDefinition 来定义子 bean 的配置信息，里面有个`parentName`属性，用来指定父 bean 的名称。

#### GenericBeanDefinition 类：通用的 bean 定义信息

既可以表示没有父 bean 的 bean 配置信息，也可以表示有父 bean 的子 bean 配置信息，这个类里面也有 parentName 属性，用来指定父 bean 的名称。

#### ConfigurationClassBeanDefinition 类：表示通过配置类中 @Bean 方法定义 bean 信息

可以通过配置类中使用 @Bean 来标注一些方法，通过这些方法来定义 bean，这些方法配置的 bean 信息最后会转换为 ConfigurationClassBeanDefinition 类型的对象

#### AnnotatedBeanDefinition 接口：表示通过注解的方式定义的 bean 信息

里面有个方法

```
AnnotationMetadata getMetadata();
```

用来获取定义这个 bean 的类上的所有注解信息。

#### BeanDefinitionBuilder：构建 BeanDefinition 的工具类

spring 中为了方便操作 BeanDefinition，提供了一个类：`BeanDefinitionBuilder`，内部提供了很多静态方法，通过这些方法可以非常方便的组装 BeanDefinition 对象，下面我们通过案例来感受一下。

#### 案例 1：组装一个简单的 bean

##### 来个简单的类

```
package com.javacode2018.lesson002.demo1;

public class Car {
    private String name;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "Car{" +
                "name='" + name + '\'' +
                '}';
    }
}
```

##### 测试用例

```
@Test
public void test1() {
    //指定class
    BeanDefinitionBuilder beanDefinitionBuilder = BeanDefinitionBuilder.rootBeanDefinition(Car.class.getName());
    //获取BeanDefinition
    BeanDefinition beanDefinition = beanDefinitionBuilder.getBeanDefinition();
    System.out.println(beanDefinition);
}
```

等效于

```
<bean class="com.javacode2018.lesson002.demo1.Car" />
```

##### 运行输出

```
Root bean: class [com.javacode2018.lesson002.demo1.Car]; scope=; abstract=false; lazyInit=null; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null
```

#### 案例 2：组装一个有属性的 bean

##### 代码

```
@Test
public void test2() {
    //指定class
    BeanDefinitionBuilder beanDefinitionBuilder = BeanDefinitionBuilder.rootBeanDefinition(Car.class.getName());
    //设置普通类型属性
    beanDefinitionBuilder.addPropertyValue("name", "奥迪"); //@1
    //获取BeanDefinition
    BeanDefinition carBeanDefinition = beanDefinitionBuilder.getBeanDefinition();
    System.out.println(carBeanDefinition);

    //创建spring容器
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory(); //@2
    //调用registerBeanDefinition向容器中注册bean
    factory.registerBeanDefinition("car", carBeanDefinition); //@3
    Car bean = factory.getBean("car", Car.class); //@4
    System.out.println(bean);
}
```

@1：调用 addPropertyValue 给 Car 中的 name 设置值

@2：创建了一个 spring 容器

@3：将 carBeanDefinition 这个 bean 配置信息注册到 spring 容器中，bean 的名称为 car

@4：从容器中获取 car 这个 bean，最后进行输出

##### 运行输出

```
Root bean: class [com.javacode2018.lesson002.demo1.Car]; scope=; abstract=false; lazyInit=null; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null
Car{name='奥迪'}
```

第二行输出了从容器中获取的 car 这个 bean 实例对象。

#### 案例 3：组装一个有依赖关系的 bean

##### 再来个类

下面这个类中有个 car 属性，我们通过 spring 将这个属性注入进来。

```
package com.javacode2018.lesson002.demo1;

public class User {
    private String name;

    private Car car;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Car getCar() {
        return car;
    }

    public void setCar(Car car) {
        this.car = car;
    }

    @Override
    public String toString() {
        return "User{" +
                "name='" + name + '\'' +
                ", car=" + car +
                '}';
    }
}
```

##### 重点代码

```
@Test
public void test3() {
    //先创建car这个BeanDefinition
    BeanDefinition carBeanDefinition = BeanDefinitionBuilder.rootBeanDefinition(Car.class.getName()).addPropertyValue("name", "奥迪").getBeanDefinition();
    //创建User这个BeanDefinition
    BeanDefinition userBeanDefinition = BeanDefinitionBuilder.rootBeanDefinition(User.class.getName()).
            addPropertyValue("name", "路人甲Java").
            addPropertyReference("car", "car"). //@1
            getBeanDefinition();

    //创建spring容器
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
    //调用registerBeanDefinition向容器中注册bean
    factory.registerBeanDefinition("car", carBeanDefinition); 
    factory.registerBeanDefinition("user", userBeanDefinition);
    System.out.println(factory.getBean("car"));
    System.out.println(factory.getBean("user"));
}
```

@1：注入依赖的 bean，需要使用 addPropertyReference 方法，2 个参数，第一个为属性的名称，第二个为需要注入的 bean 的名称

上面代码等效于

```
<bean id="car" class="com.javacode2018.lesson002.demo1.Car">
    <property name="name" value="奥迪"/>
</bean>

<bean id="user" class="com.javacode2018.lesson002.demo1.User">
    <property name="name" value="路人甲Java"/>
    <property name="car" ref="car"/>
</bean>
```

##### 运行输出

```
Car{name='奥迪'}
User{name='路人甲Java', car=Car{name='奥迪'}}
```

#### 案例 4：来 2 个有父子关系的 bean

```
@Test
public void test4() {
    //先创建car这个BeanDefinition
    BeanDefinition carBeanDefinition1 = BeanDefinitionBuilder.
            genericBeanDefinition(Car.class).
            addPropertyValue("name", "保时捷").
            getBeanDefinition();

    BeanDefinition carBeanDefinition2 = BeanDefinitionBuilder.
            genericBeanDefinition(). //内部生成一个GenericBeanDefinition对象
            setParentName("car1"). //@1：设置父bean的名称为car1
            getBeanDefinition();

    //创建spring容器
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
    //调用registerBeanDefinition向容器中注册bean
    //注册car1->carBeanDefinition1
    factory.registerBeanDefinition("car1", carBeanDefinition1);
    //注册car2->carBeanDefinition2
    factory.registerBeanDefinition("car2", carBeanDefinition2);
    //从容器中获取car1
    System.out.println(String.format("car1->%s", factory.getBean("car1")));
    //从容器中获取car2
    System.out.println(String.format("car2->%s", factory.getBean("car2")));
}
```

等效于

```
<bean id="car1" class="com.javacode2018.lesson002.demo1.Car">
    <property name="name" value="保时捷"/>
</bean>
<bean id="car2" parent="car1" />
```

##### 运行输出

```
car1->Car{name='保时捷'}
car2->Car{name='保时捷'}
```

#### 案例 5：通过 api 设置（Map、Set、List）属性

下面我们来演示注入 List、Map、Set，内部元素为普通类型及其他 bean 元素。

##### 来个类

```
package com.javacode2018.lesson002.demo1;

import java.util.List;
import java.util.Map;
import java.util.Set;

public class CompositeObj {

    private String name;
    private Integer salary;

    private Car car1;
    private List<String> stringList;
    private List<Car> carList;

    private Set<String> stringSet;
    private Set<Car> carSet;

    private Map<String, String> stringMap;
    private Map<String, Car> stringCarMap;

    //此处省略了get和set方法，大家写的时候记得补上

    @Override
    public String toString() {
        return "CompositeObj{" +
                "name='" + name + '\'' +
                "\n\t\t\t, salary=" + salary +
                "\n\t\t\t, car1=" + car1 +
                "\n\t\t\t, stringList=" + stringList +
                "\n\t\t\t, carList=" + carList +
                "\n\t\t\t, stringSet=" + stringSet +
                "\n\t\t\t, carSet=" + carSet +
                "\n\t\t\t, stringMap=" + stringMap +
                "\n\t\t\t, stringCarMap=" + stringCarMap +
                '}';
    }
}
```

**注意：上面省略了 get 和 set 方法，大家写的时候记得补上**

##### 先用 xml 来定义一个 CompositeObj 的 bean，如下

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-4.3.xsd">

    <bean id="car1" class="com.javacode2018.lesson002.demo1.Car">
        <property name="name" value="奥迪"/>
    </bean>

    <bean id="car2" class="com.javacode2018.lesson002.demo1.Car">
        <property name="name" value="保时捷"/>
    </bean>

    <bean id="compositeObj" class="com.javacode2018.lesson002.demo1.CompositeObj">
        <property name="name" value="路人甲Java"/>
        <property name="salary" value="50000"/>
        <property name="car1" ref="car1"/>
        <property name="stringList">
            <list>
                <value>java高并发系列</value>
                <value>mysql系列</value>
                <value>maven高手系列</value>
            </list>
        </property>
        <property name="carList">
            <list>
                <ref bean="car1"/>
                <ref bean="car2"/>
            </list>
        </property>
        <property name="stringSet">
            <set>
                <value>java高并发系列</value>
                <value>mysql系列</value>
                <value>maven高手系列</value>
            </set>
        </property>
        <property name="carSet">
            <set>
                <ref bean="car1"/>
                <ref bean="car2"/>
            </set>
        </property>
        <property name="stringMap">
            <map>
                <entry key="系列1" value="java高并发系列"/>
                <entry key="系列2" value="Maven高手系列"/>
                <entry key="系列3" value="mysql系列"/>
            </map>
        </property>
        <property name="stringCarMap">
            <map>
                <entry key="car1" value-ref="car1"/>
                <entry key="car2" value-ref="car2"/>
            </map>
        </property>
    </bean>
</beans>
```

##### 下面我们采用纯 api 的方式实现，如下

```
@Test
public void test5() {
    //定义car1
    BeanDefinition car1 = BeanDefinitionBuilder.
            genericBeanDefinition(Car.class).
            addPropertyValue("name", "奥迪").
            getBeanDefinition();
    //定义car2
    BeanDefinition car2 = BeanDefinitionBuilder.
            genericBeanDefinition(Car.class).
            addPropertyValue("name", "保时捷").
            getBeanDefinition();

    //定义CompositeObj这个bean
    //创建stringList这个属性对应的值
    ManagedList<String> stringList = new ManagedList<>();
    stringList.addAll(Arrays.asList("java高并发系列", "mysql系列", "maven高手系列"));

    //创建carList这个属性对应的值,内部引用其他两个bean的名称[car1,car2]
    ManagedList<RuntimeBeanReference> carList = new ManagedList<>();
    carList.add(new RuntimeBeanReference("car1"));
    carList.add(new RuntimeBeanReference("car2"));

    //创建stringList这个属性对应的值
    ManagedSet<String> stringSet = new ManagedSet<>();
    stringSet.addAll(Arrays.asList("java高并发系列", "mysql系列", "maven高手系列"));

    //创建carSet这个属性对应的值,内部引用其他两个bean的名称[car1,car2]
    ManagedList<RuntimeBeanReference> carSet = new ManagedList<>();
    carSet.add(new RuntimeBeanReference("car1"));
    carSet.add(new RuntimeBeanReference("car2"));

    //创建stringMap这个属性对应的值
    ManagedMap<String, String> stringMap = new ManagedMap<>();
    stringMap.put("系列1", "java高并发系列");
    stringMap.put("系列2", "Maven高手系列");
    stringMap.put("系列3", "mysql系列");

    ManagedMap<String, RuntimeBeanReference> stringCarMap = new ManagedMap<>();
    stringCarMap.put("car1", new RuntimeBeanReference("car1"));
    stringCarMap.put("car2", new RuntimeBeanReference("car2"));


    //下面我们使用原生的api来创建BeanDefinition
    GenericBeanDefinition compositeObj = new GenericBeanDefinition();
    compositeObj.setBeanClassName(CompositeObj.class.getName());
    compositeObj.getPropertyValues().add("name", "路人甲Java").
            add("salary", 50000).
            add("car1", new RuntimeBeanReference("car1")).
            add("stringList", stringList).
            add("carList", carList).
            add("stringSet", stringSet).
            add("carSet", carSet).
            add("stringMap", stringMap).
            add("stringCarMap", stringCarMap);

    //将上面bean 注册到容器
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
    factory.registerBeanDefinition("car1", car1);
    factory.registerBeanDefinition("car2", car2);
    factory.registerBeanDefinition("compositeObj", compositeObj);

    //下面我们将容器中所有的bean输出
    for (String beanName : factory.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, factory.getBean(beanName)));
    }
}
```

有几点需要说一下：

RuntimeBeanReference：用来表示 bean 引用类型，类似于 xml 中的 ref

ManagedList：属性如果是 List 类型的，t 需要用到这个类进行操作，这个类继承了 ArrayList

ManagedSet：属性如果是 Set 类型的，t 需要用到这个类进行操作，这个类继承了 LinkedHashSet

ManagedMap：属性如果是 Map 类型的，t 需要用到这个类进行操作，这个类继承了 LinkedHashMap

上面也就是这几个类结合的结果。

##### 看一下效果，运行输出

```
car1->Car{name='奥迪'}
car2->Car{name='保时捷'}
compositeObj->CompositeObj{name='路人甲Java'
            , salary=50000
            , car1=Car{name='奥迪'}
            , stringList=[java高并发系列, mysql系列, maven高手系列]
            , carList=[Car{name='奥迪'}, Car{name='保时捷'}]
            , stringSet=[java高并发系列, mysql系列, maven高手系列]
            , carSet=[Car{name='奥迪'}, Car{name='保时捷'}]
            , stringMap={系列1=java高并发系列, 系列2=Maven高手系列, 系列3=mysql系列}
            , stringCarMap={car1=Car{name='奥迪'}, car2=Car{name='保时捷'}}}
```

### Xml 文件方式

这种方式已经讲过很多次了，大家也比较熟悉，即通过 xml 的方式来定义 bean，如下

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-4.3.xsd">

    <bean id="bean名称" class="bean完整类名"/>

</beans>
```

xml 中的 bean 配置信息会被解析器解析为 BeanDefinition 对象，一会在第二阶段详解。

### properties 文件的方式

这种方式估计大家比较陌生，将 bean 定义信息放在 properties 文件中，然后通过解析器将配置信息解析为 BeanDefinition 对象。

properties 内容格式如下：

```
employee.(class)=MyClass       // 等同于：<bean />
employee.(abstract)=true       // 等同于：<bean abstract="true" />
employee.group=Insurance       // 为属性设置值，等同于：<property name="group" value="Insurance" />
employee.usesDialUp=false      // 为employee这个bean中的usesDialUp属性设置值,等同于：等同于：<property name="usesDialUp" value="false" />

salesrep.(parent)=employee     // 定义了一个id为salesrep的bean，指定父bean为employee，等同于：<bean parent="employee" />
salesrep.(lazy-init)=true      // 设置延迟初始化，等同于：<bean lazy-init="true" />
salesrep.manager(ref)=tony     // 设置这个bean的manager属性值，是另外一个bean，名称为tony，等同于：<property name="manager" ref="tony" />
salesrep.department=Sales      // 等同于：<property name="department" value="Sales" />

techie.(parent)=employee       // 定义了一个id为techie的bean，指定父bean为employee，等同于：<bean parent="employee" />
techie.(scope)=prototype       // 设置bean的作用域，等同于<bean scope="prototype" />
techie.manager(ref)=jeff       // 等同于：<property name="manager" ref="jeff" />
techie.department=Engineering  // <property name="department" value="Engineering" />
techie.usesDialUp=true         // <property name="usesDialUp" value="true" />

ceo.$0(ref)=secretary          // 设置构造函数第1个参数值，等同于：<constructor-arg index="0" ref="secretary" />
ceo.$1=1000000                 // 设置构造函数第2个参数值，等同于：<constructor-arg index="1" value="1000000" />
```

### 注解的方式

常见的 2 种：

1. 类上标注 @Compontent 注解来定义一个 bean
2. 配置类中使用 @Bean 注解来定义 bean

### 小结

**bean 注册者只识别 BeanDefinition 对象，不管什么方式最后都会将这些 bean 定义的信息转换为 BeanDefinition 对象，然后注册到 spring 容器中。**

## 阶段 2：Bean 元信息解析阶段

Bean 元信息的解析就是将各种方式定义的 bean 配置信息解析为 BeanDefinition 对象。

### Bean 元信息的解析主要有 3 种方式

1. xml 文件定义 bean 的解析
2. properties 文件定义 bean 的解析
3. 注解方式定义 bean 的解析

### XML 方式解析：XmlBeanDefinitionReader

spring 中提供了一个类`XmlBeanDefinitionReader`，将 xml 中定义的 bean 解析为 BeanDefinition 对象。

直接来看案例代码

#### 来一个 bean xml 配置文件

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-4.3.xsd">

    <bean id="car" class="com.javacode2018.lesson002.demo1.Car">
        <property name="name" value="奥迪"/>
    </bean>

    <bean id="car1" class="com.javacode2018.lesson002.demo1.Car">
        <property name="name" value="保时捷"/>
    </bean>

    <bean id="car2" parent="car1"/>

    <bean id="user" class="com.javacode2018.lesson002.demo1.User">
        <property name="name" value="路人甲Java"/>
        <property name="car" ref="car1"/>
    </bean>
</beans>
```

上面注册了 4 个 bean，不多解释了。

#### 将 bean xml 解析为 BeanDefinition 对象

```
/**
 * xml方式bean配置信息解析
 */
@Test
public void test1() {
    //定义一个spring容器，这个容器默认实现了BeanDefinitionRegistry，所以本身就是一个bean注册器
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

    //定义一个xml的BeanDefinition读取器，需要传递一个BeanDefinitionRegistry（bean注册器）对象
    XmlBeanDefinitionReader xmlBeanDefinitionReader = new XmlBeanDefinitionReader(factory);

    //指定bean xml配置文件的位置
    String location = "classpath:/com/javacode2018/lesson002/demo2/beans.xml";
    //通过XmlBeanDefinitionReader加载bean xml文件，然后将解析产生的BeanDefinition注册到容器容器中
    int countBean = xmlBeanDefinitionReader.loadBeanDefinitions(location);
    System.out.println(String.format("共注册了 %s 个bean", countBean));

    //打印出注册的bean的配置信息
    for (String beanName : factory.getBeanDefinitionNames()) {
        //通过名称从容器中获取对应的BeanDefinition信息
        BeanDefinition beanDefinition = factory.getBeanDefinition(beanName);
        //获取BeanDefinition具体使用的是哪个类
        String beanDefinitionClassName = beanDefinition.getClass().getName();
        //通过名称获取bean对象
        Object bean = factory.getBean(beanName);
        //打印输出
        System.out.println(beanName + ":");
        System.out.println("    beanDefinitionClassName：" + beanDefinitionClassName);
        System.out.println("    beanDefinition：" + beanDefinition);
        System.out.println("    bean：" + bean);
    }
}
```

上面注释比较详细，这里就不解释了。

注意一点：创建 XmlBeanDefinitionReader 的时候需要传递一个 bean 注册器 (BeanDefinitionRegistry)，解析过程中生成的 BeanDefinition 会丢到 bean 注册器中。

#### 运行输出

```
共注册了 4 个bean
car:
    beanDefinitionClassName：org.springframework.beans.factory.support.GenericBeanDefinition
    beanDefinition：Generic bean: class [com.javacode2018.lesson002.demo1.Car]; scope=; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null; defined in class path resource [com/javacode2018/lesson002/demo2/beans.xml]
    bean：Car{name='奥迪'}
car1:
    beanDefinitionClassName：org.springframework.beans.factory.support.GenericBeanDefinition
    beanDefinition：Generic bean: class [com.javacode2018.lesson002.demo1.Car]; scope=; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null; defined in class path resource [com/javacode2018/lesson002/demo2/beans.xml]
    bean：Car{name='保时捷'}
car2:
    beanDefinitionClassName：org.springframework.beans.factory.support.GenericBeanDefinition
    beanDefinition：Generic bean with parent 'car1': class [null]; scope=; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null; defined in class path resource [com/javacode2018/lesson002/demo2/beans.xml]
    bean：Car{name='保时捷'}
user:
    beanDefinitionClassName：org.springframework.beans.factory.support.GenericBeanDefinition
    beanDefinition：Generic bean: class [com.javacode2018.lesson002.demo1.User]; scope=; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null; defined in class path resource [com/javacode2018/lesson002/demo2/beans.xml]
    bean：User{name='路人甲Java', car=Car{name='奥迪'}}
```

上面的输出认真看一下，这几个 BeanDefinition 都是`GenericBeanDefinition`这种类型的，也就是说 xml 中定义的 bean 被解析之后都是通过`GenericBeanDefinition`这种类型表示的。

### properties 文件定义 bean 的解析：PropertiesBeanDefinitionReader

spring 中提供了一个类`XmlBeanDefinitionReader`，将 xml 中定义的 bean 解析为 BeanDefinition 对象，过程和 xml 的方式类似。

来看案例代码。

下面通过 properties 文件的方式实现上面 xml 方式定义的 bean。

#### 来个 properties 文件：beans.properties

```
car.(class)=com.javacode2018.lesson002.demo1.Car
car.name=奥迪

car1.(class)=com.javacode2018.lesson002.demo1.Car
car1.name=保时捷

car2.(parent)=car1

user.(class)=com.javacode2018.lesson002.demo1.User
user.name=路人甲Java
user.car(ref)=car
```

#### 将 bean properties 文件解析为 BeanDefinition 对象

```
/**
 * properties文件方式bean配置信息解析
 */
@Test
public void test2() {
    //定义一个spring容器，这个容器默认实现了BeanDefinitionRegistry，所以本身就是一个bean注册器
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

    //定义一个properties的BeanDefinition读取器，需要传递一个BeanDefinitionRegistry（bean注册器）对象
    PropertiesBeanDefinitionReader propertiesBeanDefinitionReader = new PropertiesBeanDefinitionReader(factory);

    //指定bean xml配置文件的位置
    String location = "classpath:/com/javacode2018/lesson002/demo2/beans.properties";
    //通过PropertiesBeanDefinitionReader加载bean properties文件，然后将解析产生的BeanDefinition注册到容器容器中
    int countBean = propertiesBeanDefinitionReader.loadBeanDefinitions(location);
    System.out.println(String.format("共注册了 %s 个bean", countBean));

    //打印出注册的bean的配置信息
    for (String beanName : factory.getBeanDefinitionNames()) {
        //通过名称从容器中获取对应的BeanDefinition信息
        BeanDefinition beanDefinition = factory.getBeanDefinition(beanName);
        //获取BeanDefinition具体使用的是哪个类
        String beanDefinitionClassName = beanDefinition.getClass().getName();
        //通过名称获取bean对象
        Object bean = factory.getBean(beanName);
        //打印输出
        System.out.println(beanName + ":");
        System.out.println("    beanDefinitionClassName：" + beanDefinitionClassName);
        System.out.println("    beanDefinition：" + beanDefinition);
        System.out.println("    bean：" + bean);
    }
}
```

#### 运行输出

```
user:
    beanDefinitionClassName：org.springframework.beans.factory.support.GenericBeanDefinition
    beanDefinition：Generic bean: class [com.javacode2018.lesson002.demo1.User]; scope=singleton; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null
    bean：User{name='路人甲Java', car=Car{name='奥迪'}}
car1:
    beanDefinitionClassName：org.springframework.beans.factory.support.GenericBeanDefinition
    beanDefinition：Generic bean: class [com.javacode2018.lesson002.demo1.Car]; scope=singleton; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null
    bean：Car{name='保时捷'}
car:
    beanDefinitionClassName：org.springframework.beans.factory.support.GenericBeanDefinition
    beanDefinition：Generic bean: class [com.javacode2018.lesson002.demo1.Car]; scope=singleton; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null
    bean：Car{name='奥迪'}
car2:
    beanDefinitionClassName：org.springframework.beans.factory.support.GenericBeanDefinition
    beanDefinition：Generic bean with parent 'car1': class [null]; scope=singleton; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null
    bean：Car{name='保时捷'}
```

输出和 xml 方式输出基本上一致。

properties 方式使用起来并不是太方便，所以平时我们很少看到有人使用。

### 注解方式：PropertiesBeanDefinitionReader

注解的方式定义的 bean，需要使用 PropertiesBeanDefinitionReader 这个类来进行解析，方式也和上面 2 种方式类似，直接来看案例。

#### 通过注解来标注 2 个类

##### Service1

```
package com.javacode2018.lesson002.demo2;


import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Scope;

@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
@Primary
@Lazy
public class Service1 {
}
```

这个类上面使用了 3 个注解，这些注解前面都介绍过，可以用来配置 bean 的信息

上面这个 bean 是个多例的。

##### Service2

```
package com.javacode2018.lesson002.demo2;

import org.springframework.beans.factory.annotation.Autowired;

public class Service2 {

    @Autowired
    private Service1 service1; //@1

    @Override
    public String toString() {
        return "Service2{" +
                "service1=" + service1 +
                '}';
    }
}
```

@1：标注了 @Autowired，说明需要注入这个对象

#### 注解定义的 bean 解析为 BeanDefinition，如下：

```
@Test
public void test3() {
    //定义一个spring容器，这个容器默认实现了BeanDefinitionRegistry，所以本身就是一个bean注册器
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

    //定义一个注解方式的BeanDefinition读取器，需要传递一个BeanDefinitionRegistry（bean注册器）对象
    AnnotatedBeanDefinitionReader annotatedBeanDefinitionReader = new AnnotatedBeanDefinitionReader(factory);

    //通过PropertiesBeanDefinitionReader加载bean properties文件，然后将解析产生的BeanDefinition注册到容器容器中
    annotatedBeanDefinitionReader.register(Service1.class, Service2.class);

    //打印出注册的bean的配置信息
    for (String beanName : new String[]{"service1", "service2"}) {
        //通过名称从容器中获取对应的BeanDefinition信息
        BeanDefinition beanDefinition = factory.getBeanDefinition(beanName);
        //获取BeanDefinition具体使用的是哪个类
        String beanDefinitionClassName = beanDefinition.getClass().getName();
        //通过名称获取bean对象
        Object bean = factory.getBean(beanName);
        //打印输出
        System.out.println(beanName + ":");
        System.out.println("    beanDefinitionClassName：" + beanDefinitionClassName);
        System.out.println("    beanDefinition：" + beanDefinition);
        System.out.println("    bean：" + bean);
    }
}
```

#### 运行输出

```
service1:
    beanDefinitionClassName：org.springframework.beans.factory.annotation.AnnotatedGenericBeanDefinition
    beanDefinition：Generic bean: class [com.javacode2018.lesson002.demo2.Service1]; scope=prototype; abstract=false; lazyInit=true; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=true; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null
    bean：com.javacode2018.lesson002.demo2.Service1@21a947fe
service2:
    beanDefinitionClassName：org.springframework.beans.factory.annotation.AnnotatedGenericBeanDefinition
    beanDefinition：Generic bean: class [com.javacode2018.lesson002.demo2.Service2]; scope=singleton; abstract=false; lazyInit=null; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null
    bean：Service2{service1=null}
```

输出中可以看出 service1 这个 bean 的 beanDefinition 中 lazyInit 确实为 true，primary 也为 true，scope 为 prototype，说明类 Service1 注解上标注 3 个注解信息被解析之后放在了 beanDefinition 中。

**注意下：最后一行中的 service1 为什么为 null，不是标注了 @Autowired 么？**

这个地方提前剧透一下，看不懂的没关系，这篇文章都结束之后，就明白了。

调整一下上面的代码，加上下面 @1 这行代码，如下：

```
@Test
public void test3() {
    //定义一个spring容器，这个容器默认实现了BeanDefinitionRegistry，所以本身就是一个bean注册器
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

    //定义一个注解方式的BeanDefinition读取器，需要传递一个BeanDefinitionRegistry（bean注册器）对象
    AnnotatedBeanDefinitionReader annotatedBeanDefinitionReader = new AnnotatedBeanDefinitionReader(factory);

    //通过PropertiesBeanDefinitionReader加载bean properties文件，然后将解析产生的BeanDefinition注册到容器容器中
    annotatedBeanDefinitionReader.register(Service1.class, Service2.class);

    factory.getBeansOfType(BeanPostProcessor.class).values().forEach(factory::addBeanPostProcessor); // @1
    //打印出注册的bean的配置信息
    for (String beanName : new String[]{"service1", "service2"}) {
        //通过名称从容器中获取对应的BeanDefinition信息
        BeanDefinition beanDefinition = factory.getBeanDefinition(beanName);
        //获取BeanDefinition具体使用的是哪个类
        String beanDefinitionClassName = beanDefinition.getClass().getName();
        //通过名称获取bean对象
        Object bean = factory.getBean(beanName);
        //打印输出
        System.out.println(beanName + ":");
        System.out.println("    beanDefinitionClassName：" + beanDefinitionClassName);
        System.out.println("    beanDefinition：" + beanDefinition);
        System.out.println("    bean：" + bean);
    }
}
```

再次运行一下，最后一行有值了：

```
service1:
    beanDefinitionClassName：org.springframework.beans.factory.annotation.AnnotatedGenericBeanDefinition
    beanDefinition：Generic bean: class [com.javacode2018.lesson002.demo2.Service1]; scope=prototype; abstract=false; lazyInit=true; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=true; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null
    bean：com.javacode2018.lesson002.demo2.Service1@564718df
service2:
    beanDefinitionClassName：org.springframework.beans.factory.annotation.AnnotatedGenericBeanDefinition
    beanDefinition：Generic bean: class [com.javacode2018.lesson002.demo2.Service2]; scope=singleton; abstract=false; lazyInit=null; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null
    bean：Service2{service1=com.javacode2018.lesson002.demo2.Service1@52aa2946}
```

**目前进行到第二个阶段了，还有 14 个阶段，本文内容比较长，建议先收藏起来，慢慢看，咱们继续。**

## 阶段 3：Spring Bean 注册阶段

bean 注册阶段需要用到一个非常重要的接口：BeanDefinitionRegistry

### Bean 注册接口：BeanDefinitionRegistry

这个接口中定义了注册 bean 常用到的一些方法，源码如下：

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

### 别名注册接口：AliasRegistry

`BeanDefinitionRegistry`接口继承了`AliasRegistry`接口，这个接口中定义了操作 bean 别名的一些方法，看一下其源码：

```
public interface AliasRegistry {

    /**
     * 给name指定别名alias
     */
    void registerAlias(String name, String alias);

    /**
     * 从此注册表中删除指定的别名
     */
    void removeAlias(String alias);

    /**
     * 判断name是否作为别名已经被使用了
     */
    boolean isAlias(String name);

    /**
     * 返回name对应的所有别名
     */
    String[] getAliases(String name);

}
```

### BeanDefinitionRegistry 唯一实现：DefaultListableBeanFactory

spring 中 BeanDefinitionRegistry 接口有一个唯一的实现类：

```
org.springframework.beans.factory.support.DefaultListableBeanFactory
```

大家可能看到有很多类也实现了`BeanDefinitionRegistry`接口，比如我们经常用到的`AnnotationConfigApplicationContext`，但实际上其内部是转发给了`DefaultListableBeanFactory`进行处理的，所以真正实现这个接口的类是`DefaultListableBeanFactory`。

大家再回头看一下开头的几个案例，都使用的是`DefaultListableBeanFactory`作为 bean 注册器，此时你们应该可以理解为什么了。

下面我们来个案例演示一下上面常用的一些方法。

### 案例

#### 代码

```
package com.javacode2018.lesson002.demo3;

import org.junit.Test;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;
import org.springframework.beans.factory.support.GenericBeanDefinition;

import java.util.Arrays;

/**
 * BeanDefinitionRegistry 案例
 */
public class BeanDefinitionRegistryTest {

    @Test
    public void test1() {
        //创建一个bean工厂，这个默认实现了BeanDefinitionRegistry接口，所以也是一个bean注册器
        DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

        //定义一个bean
        GenericBeanDefinition nameBdf = new GenericBeanDefinition();
        nameBdf.setBeanClass(String.class);
        nameBdf.getConstructorArgumentValues().addIndexedArgumentValue(0, "路人甲Java");

        //将bean注册到容器中
        factory.registerBeanDefinition("name", nameBdf);

        //通过名称获取BeanDefinition
        System.out.println(factory.getBeanDefinition("name"));
        //通过名称判断是否注册过BeanDefinition
        System.out.println(factory.containsBeanDefinition("name"));
        //获取所有注册的名称
        System.out.println(Arrays.asList(factory.getBeanDefinitionNames()));
        //获取已注册的BeanDefinition的数量
        System.out.println(factory.getBeanDefinitionCount());
        //判断指定的name是否使用过
        System.out.println(factory.isBeanNameInUse("name"));

        //别名相关方法
        //为name注册2个别名
        factory.registerAlias("name", "alias-name-1");
        factory.registerAlias("name", "alias-name-2");

        //判断alias-name-1是否已被作为别名使用
        System.out.println(factory.isAlias("alias-name-1"));

        //通过名称获取对应的所有别名
        System.out.println(Arrays.asList(factory.getAliases("name")));

        //最后我们再来获取一下这个bean
        System.out.println(factory.getBean("name"));


    }
}
```

#### 运行输出

```
Generic bean: class [java.lang.String]; scope=; abstract=false; lazyInit=null; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null
true
[name]
1
true
true
[alias-name-2, alias-name-1]
路人甲Java
```

**下面要介绍的从阶段 4 到阶段 14，也就是从：`BeanDefinition合并阶段`到`Bean初始化完成阶段`，都是在调用 getBean 从容器中获取 bean 对象的过程中发送的操作，要注意细看了，大家下去了建议去看 getBean 这个方法的源码，以下过程均来自于这个方法：**

```
org.springframework.beans.factory.support.AbstractBeanFactory#doGetBean
```

## 阶段 4：BeanDefinition 合并阶段

### 合并阶段是做什么的？

可能我们定义 bean 的时候有父子 bean 关系，此时子 BeanDefinition 中的信息是不完整的，比如设置属性的时候配置在父 BeanDefinition 中，此时子 BeanDefinition 中是没有这些信息的，需要将子 bean 的 BeanDefinition 和父 bean 的 BeanDefinition 进行合并，得到最终的一个`RootBeanDefinition`，合并之后得到的`RootBeanDefinition`包含 bean 定义的所有信息，包含了从父 bean 中继继承过来的所有信息，后续 bean 的所有创建工作就是依靠合并之后 BeanDefinition 来进行的。

合并 BeanDefinition 会使用下面这个方法：

```
org.springframework.beans.factory.support.AbstractBeanFactory#getMergedBeanDefinition
```

**bean 定义可能存在多级父子关系，合并的时候进进行递归合并，最终得到一个包含完整信息的 RootBeanDefinition**

### 案例

#### 来一个普通的类

```
package com.javacode2018.lesson002.demo4;

public class LessonModel {
    //课程名称
    private String name;
    //课时
    private int lessonCount;
    //描述信息
    private String description;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getLessonCount() {
        return lessonCount;
    }

    public void setLessonCount(int lessonCount) {
        this.lessonCount = lessonCount;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return "LessonModel{" +
                "name='" + name + '\'' +
                ", lessonCount=" + lessonCount +
                ", description='" + description + '\'' +
                '}';
    }
}
```

#### 通过 xml 定义 3 个具有父子关系的 bean

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-4.3.xsd">

    <bean id="lesson1" class="com.javacode2018.lesson002.demo4.LessonModel"/>

    <bean id="lesson2" parent="lesson1">
        <property name="name" value="spring高手系列"/>
        <property name="lessonCount" value="100"/>
    </bean>

    <bean id="lesson3" parent="lesson2">
        <property name="description" value="路人甲Java带你学spring，超越90%开发者!"/>
    </bean>

</beans>
```

lesson2 相当于 lesson1 的儿子，lesson3 相当于 lesson1 的孙子。

#### 解析 xml 注册 bean

下面将解析 xml，进行 bean 注册，然后遍历输出 bean 的名称，解析过程中注册的原始的 BeanDefinition，合并之后的 BeanDefinition，以及合并前后 BeanDefinition 中的属性信息

```
package com.javacode2018.lesson002.demo4;

import org.junit.Test;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;
import org.springframework.beans.factory.xml.XmlBeanDefinitionReader;

/**
 * BeanDefinition 合并
 */
public class MergedBeanDefinitionTest {
    @Test
    public void test1() {
        //创建bean容器
        DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
        //创建一个bean xml解析器
        XmlBeanDefinitionReader beanDefinitionReader = new XmlBeanDefinitionReader(factory);
        //解析bean xml，将解析过程中产生的BeanDefinition注册到DefaultListableBeanFactory中
        beanDefinitionReader.loadBeanDefinitions("com/javacode2018/lesson002/demo4/beans.xml");
        //遍历容器中注册的所有bean信息
        for (String beanName : factory.getBeanDefinitionNames()) {
            //通过bean名称获取原始的注册的BeanDefinition信息
            BeanDefinition beanDefinition = factory.getBeanDefinition(beanName);
            //获取合并之后的BeanDefinition信息
            BeanDefinition mergedBeanDefinition = factory.getMergedBeanDefinition(beanName);

            System.out.println(beanName);
            System.out.println("解析xml过程中注册的beanDefinition：" + beanDefinition);
            System.out.println("beanDefinition中的属性信息" + beanDefinition.getPropertyValues());
            System.out.println("合并之后得到的mergedBeanDefinition：" + mergedBeanDefinition);
            System.out.println("mergedBeanDefinition中的属性信息" + mergedBeanDefinition.getPropertyValues());
            System.out.println("---------------------------");
        }
    }
}
```

#### 运行输出

```
lesson1
解析xml过程中注册的beanDefinition：Generic bean: class [com.javacode2018.lesson002.demo4.LessonModel]; scope=; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null; defined in class path resource [com/javacode2018/lesson002/demo4/beans.xml]
beanDefinition中的属性信息PropertyValues: length=0
合并之后得到的mergedBeanDefinition：Root bean: class [com.javacode2018.lesson002.demo4.LessonModel]; scope=singleton; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null; defined in class path resource [com/javacode2018/lesson002/demo4/beans.xml]
mergedBeanDefinition中的属性信息PropertyValues: length=0
---------------------------
lesson2
解析xml过程中注册的beanDefinition：Generic bean with parent 'lesson1': class [null]; scope=; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null; defined in class path resource [com/javacode2018/lesson002/demo4/beans.xml]
beanDefinition中的属性信息PropertyValues: length=2; bean property 'name'; bean property 'lessonCount'
合并之后得到的mergedBeanDefinition：Root bean: class [com.javacode2018.lesson002.demo4.LessonModel]; scope=singleton; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null; defined in class path resource [com/javacode2018/lesson002/demo4/beans.xml]
mergedBeanDefinition中的属性信息PropertyValues: length=2; bean property 'name'; bean property 'lessonCount'
---------------------------
lesson3
解析xml过程中注册的beanDefinition：Generic bean with parent 'lesson2': class [null]; scope=; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null; defined in class path resource [com/javacode2018/lesson002/demo4/beans.xml]
beanDefinition中的属性信息PropertyValues: length=1; bean property 'description'
合并之后得到的mergedBeanDefinition：Root bean: class [com.javacode2018.lesson002.demo4.LessonModel]; scope=singleton; abstract=false; lazyInit=false; autowireMode=0; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=null; factoryMethodName=null; initMethodName=null; destroyMethodName=null; defined in class path resource [com/javacode2018/lesson002/demo4/beans.xml]
mergedBeanDefinition中的属性信息PropertyValues: length=3; bean property 'name'; bean property 'lessonCount'; bean property 'description'
---------------------------
```

从输出的结果中可以看到，合并之前，BeanDefinition 是不完整的，比 lesson2 和 lesson3 中的 class 是 null，属性信息也不完整，但是合并之后这些信息都完整了。

合并之前是`GenericBeanDefinition`类型的，合并之后得到的是`RootBeanDefinition`类型的。

获取 lesson3 合并的 BeanDefinition 时，内部会递归进行合并，先将 lesson1 和 lesson2 合并，然后将 lesson2 再和 lesson3 合并，最后得到合并之后的 BeanDefinition。

**后面的阶段将使用合并产生的 RootBeanDefinition。**

## 阶段 5：Bean Class 加载阶段

**这个阶段就是将 bean 的 class 名称转换为 Class 类型的对象。**

BeanDefinition 中有个 Object 类型的字段：beanClass

```
private volatile Object beanClass;
```

用来表示 bean 的 class 对象，通常这个字段的值有 2 种类型，一种是 bean 对应的 Class 类型的对象，另一种是 bean 对应的 Class 的完整类名，第一种情况不需要解析，第二种情况：即这个字段是 bean 的类名的时候，就需要通过类加载器将其转换为一个 Class 对象。

此时会对阶段 4 中合并产生的`RootBeanDefinition`中的`beanClass`进行解析，将 bean 的类名转换为`Class对象`，然后赋值给`beanClass`字段。

源码位置：

```
org.springframework.beans.factory.support.AbstractBeanFactory#resolveBeanClass
```

上面得到了 Bean Class 对象以及合并之后的 BeanDefinition，下面就开始进入实例化这个对象的阶段了。

**Bean 实例化分为 3 个阶段：前阶段、实例化阶段、后阶段；下面详解介绍。**

## 阶段 6：Bean 实例化阶段

### 分 2 个小的阶段

1. Bean 实例化前操作
2. Bean 实例化操作

### Bean 实例化前操作

先来看一下`DefaultListableBeanFactory`，这个类中有个非常非常重要的字段：

```
private final List<BeanPostProcessor> beanPostProcessors = new CopyOnWriteArrayList<>();
```

是一个`BeanPostProcessor`类型的集合

**BeanPostProcessor 是一个接口，还有很多子接口，这些接口中提供了很多方法，spring 在 bean 生命周期的不同阶段，会调用上面这个列表中的 BeanPostProcessor 中的一些方法，来对生命周期进行扩展，bean 生命周期中的所有扩展点都是依靠这个集合中的 BeanPostProcessor 来实现的，所以如果大家想对 bean 的生命周期进行干预，这块一定要掌握好。**

**注意：本文中很多以 BeanPostProcessor 结尾的，都实现了 BeanPostProcessor 接口，有些是直接实现的，有些是实现了它的子接口。**

Bean 实例化之前会调用一段代码：

```
@Nullable
    protected Object applyBeanPostProcessorsBeforeInstantiation(Class<?> beanClass, String beanName) {
        for (BeanPostProcessor bp : getBeanPostProcessors()) {
            if (bp instanceof InstantiationAwareBeanPostProcessor) {
                InstantiationAwareBeanPostProcessor ibp = (InstantiationAwareBeanPostProcessor) bp;
                Object result = ibp.postProcessBeforeInstantiation(beanClass, beanName);
                if (result != null) {
                    return result;
                }
            }
        }
        return null;
    }
```

这段代码在 bean 实例化之前给开发者留了个口子，开发者自己可以在这个地方直接去创建一个对象作为 bean 实例，而跳过 spring 内部实例化 bean 的过程。

上面代码中轮询`beanPostProcessors`列表，如果类型是`InstantiationAwareBeanPostProcessor`， 尝试调用`InstantiationAwareBeanPostProcessor#postProcessBeforeInstantiation`获取 bean 的实例对象，如果能够获取到，那么将返回值作为当前 bean 的实例，那么 spring 自带的实例化 bean 的过程就被跳过了。

`postProcessBeforeInstantiation`方法如下：

```
default Object postProcessBeforeInstantiation(Class<?> beanClass, String beanName) throws BeansException {
    return null;
}
```

这个地方给开发者提供了一个扩展点，允许开发者在这个方法中直接返回 bean 的一个实例。

下面我们来个案例看一下。

#### 案例

```
package com.javacode2018.lesson002.demo5;

import com.javacode2018.lesson002.demo1.Car;
import org.junit.Test;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.InstantiationAwareBeanPostProcessor;
import org.springframework.beans.factory.support.AbstractBeanDefinition;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;
import org.springframework.lang.Nullable;

/**
 * bean初始化前阶段，会调用：{@link org.springframework.beans.factory.config.InstantiationAwareBeanPostProcessor#postProcessBeforeInitialization(Object, String)}
 */
public class InstantiationAwareBeanPostProcessorTest {
    @Test
    public void test1() {
        DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

        //添加一个BeanPostProcessor：InstantiationAwareBeanPostProcessor
        factory.addBeanPostProcessor(new InstantiationAwareBeanPostProcessor() { //@1
            @Nullable
            @Override
            public Object postProcessBeforeInstantiation(Class<?> beanClass, String beanName) throws BeansException {
                System.out.println("调用postProcessBeforeInstantiation()");
                //发现类型是Car类型的时候，硬编码创建一个Car对象返回
                if (beanClass == Car.class) {
                    Car car = new Car();
                    car.setName("保时捷");
                    return car;
                }
                return null;
            }
        });

        //定义一个car bean,车名为：奥迪
        AbstractBeanDefinition carBeanDefinition = BeanDefinitionBuilder.
                genericBeanDefinition(Car.class).
                addPropertyValue("name", "奥迪").  //@2
                getBeanDefinition();
        factory.registerBeanDefinition("car", carBeanDefinition);
        //从容器中获取car这个bean的实例，输出
        System.out.println(factory.getBean("car"));

    }
}
```

@1：创建了一个 InstantiationAwareBeanPostProcessor，丢到了容器中的 BeanPostProcessor 列表中

@2：创建了一个 car bean，name 为奥迪

#### 运行输出

```
调用postProcessBeforeInstantiation()
Car{name='保时捷'}
```

bean 定义的时候，名称为：奥迪，最后输出的为：保时捷

定义和输出不一致的原因是因为我们在`InstantiationAwareBeanPostProcessor#postProcessBeforeInstantiation`方法中手动创建了一个实例直接返回了，而不是依靠 spring 内部去创建这个实例。

#### 小结

实际上，在实例化前阶段对 bean 的创建进行干预的情况，用的非常少，所以大部分 bean 的创建还会继续走下面的阶段。

### Bean 实例化操作

#### 这个过程可以干什么？

这个过程会通过反射来调用 bean 的构造器来创建 bean 的实例。

具体需要使用哪个构造器，spring 为开发者提供了一个接口，允许开发者自己来判断用哪个构造器。

看一下这块的代码逻辑：

```
for (BeanPostProcessor bp : getBeanPostProcessors()) {
    if (bp instanceof SmartInstantiationAwareBeanPostProcessor) {
        SmartInstantiationAwareBeanPostProcessor ibp = (SmartInstantiationAwareBeanPostProcessor) bp;
        Constructor<?>[] ctors = ibp.determineCandidateConstructors(beanClass, beanName);
        if (ctors != null) {
            return ctors;
        }
    }
}
```

会调用`SmartInstantiationAwareBeanPostProcessor接口的determineCandidateConstructors`方法，这个方法会返回候选的构造器列表，也可以返回空，看一下这个方法的源码：

```
@Nullable
default Constructor<?>[] determineCandidateConstructors(Class<?> beanClass, String beanName)
throws BeansException {

    return null;
}
```

这个方法有个比较重要的实现类

```
org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor
```

可以将`@Autowired`标注的方法作为候选构造器返回，有兴趣的可以去看一下代码。

#### 案例

**下面我们来个案例，自定义一个注解，当构造器被这个注解标注的时候，让 spring 自动选择使用这个构造器创建对象。**

##### 自定义一个注解

下面这个注解可以标注在构造器上面，使用这个标注之后，创建 bean 的时候将使用这个构造器。

```
package com.javacode2018.lesson002.demo6;

import java.lang.annotation.*;

@Target(ElementType.CONSTRUCTOR)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface MyAutowried {
}
```

##### 来个普通的类

下面这个类 3 个构造器，其中一个使用`@MyAutowried`，让其作为 bean 实例化的方法。

```
package com.javacode2018.lesson002.demo6;

public class Person {
    private String name;
    private Integer age;

    public Person() {
        System.out.println("调用 Person()");
    }

    @MyAutowried
    public Person(String name) {
        System.out.println("调用 Person(String name)");
        this.name = name;
    }

    public Person(String name, Integer age) {
        System.out.println("调用 Person(String name, int age)");
        this.name = name;
        this.age = age;
    }

    @Override
    public String toString() {
        return "Person{" +
                "name='" + name + '\'' +
                ", age=" + age +
                '}';
    }
}
```

##### 自定义一个 SmartInstantiationAwareBeanPostProcessor

代码的逻辑：将`@MyAutowried`标注的构造器列表返回

```
package com.javacode2018.lesson002.demo6;


import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.SmartInstantiationAwareBeanPostProcessor;
import org.springframework.lang.Nullable;

import java.lang.reflect.Constructor;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class MySmartInstantiationAwareBeanPostProcessor implements SmartInstantiationAwareBeanPostProcessor {
    @Nullable
    @Override
    public Constructor<?>[] determineCandidateConstructors(Class<?> beanClass, String beanName) throws BeansException {
        System.out.println(beanClass);
        System.out.println("调用 MySmartInstantiationAwareBeanPostProcessor.determineCandidateConstructors 方法");
        Constructor<?>[] declaredConstructors = beanClass.getDeclaredConstructors();
        if (declaredConstructors != null) {
            //获取有@MyAutowried注解的构造器列表
            List<Constructor<?>> collect = Arrays.stream(declaredConstructors).
                    filter(constructor -> constructor.isAnnotationPresent(MyAutowried.class)).
                    collect(Collectors.toList());
            Constructor[] constructors = collect.toArray(new Constructor[collect.size()]);
            return constructors.length != 0 ? constructors : null;
        } else {
            return null;
        }
    }
}
```

##### 来个测试用例

```
package com.javacode2018.lesson002.demo6;

import org.junit.Test;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;

/**
 * 通过{@link org.springframework.beans.factory.config.SmartInstantiationAwareBeanPostProcessor#determineCandidateConstructors(Class, String)}来确定使用哪个构造器来创建bean实例
 */
public class SmartInstantiationAwareBeanPostProcessorTest {
    @Test
    public void test1() {
        DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

        //创建一个SmartInstantiationAwareBeanPostProcessor,将其添加到容器中
        factory.addBeanPostProcessor(new MySmartInstantiationAwareBeanPostProcessor());

        factory.registerBeanDefinition("name",
                BeanDefinitionBuilder.
                        genericBeanDefinition(String.class).
                        addConstructorArgValue("路人甲Java").
                        getBeanDefinition());

        factory.registerBeanDefinition("age",
                BeanDefinitionBuilder.
                        genericBeanDefinition(Integer.class).
                        addConstructorArgValue(30).
                        getBeanDefinition());

        factory.registerBeanDefinition("person",
                BeanDefinitionBuilder.
                        genericBeanDefinition(Person.class).
                        getBeanDefinition());

        Person person = factory.getBean("person", Person.class);
        System.out.println(person);

    }
}
```

##### 运行输出

```
class com.javacode2018.lesson002.demo6.Person
调用 MySmartInstantiationAwareBeanPostProcessor.determineCandidateConstructors 方法
class java.lang.String
调用 MySmartInstantiationAwareBeanPostProcessor.determineCandidateConstructors 方法
调用 Person(String name)
Person{name='路人甲Java', age=null}
```

从输出中可以看出调用了 Person 中标注 @MyAutowired 标注的构造器。

到目前为止 bean 实例化阶段结束了，继续进入后面的阶段。

## 阶段 7：合并后的 BeanDefinition 处理

这块的源码如下

```
protected void applyMergedBeanDefinitionPostProcessors(RootBeanDefinition mbd, Class<?> beanType, String beanName) {
        for (BeanPostProcessor bp : getBeanPostProcessors()) {
            if (bp instanceof MergedBeanDefinitionPostProcessor) {
                MergedBeanDefinitionPostProcessor bdp = (MergedBeanDefinitionPostProcessor) bp;
                bdp.postProcessMergedBeanDefinition(mbd, beanType, beanName);
            }
        }
    }
```

会调用`MergedBeanDefinitionPostProcessor接口的postProcessMergedBeanDefinition`方法，看一下这个方法的源码：

```
void postProcessMergedBeanDefinition(RootBeanDefinition beanDefinition, Class<?> beanType, String beanName);
```

spring 会轮询`BeanPostProcessor`，依次调用`MergedBeanDefinitionPostProcessor#postProcessMergedBeanDefinition`

第一个参数为 beanDefinition，表示合并之后的 RootBeanDefinition，我们可以在这个方法内部对合并之后的`BeanDefinition`进行再次处理

**postProcessMergedBeanDefinition 有 2 个实现类，前面我们介绍过，用的也比较多，面试的时候也会经常问的：**

```
org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor
在 postProcessMergedBeanDefinition 方法中对 @Autowired、@Value 标注的方法、字段进行缓存

org.springframework.context.annotation.CommonAnnotationBeanPostProcessor
在 postProcessMergedBeanDefinition 方法中对 @Resource 标注的字段、@Resource 标注的方法、 @PostConstruct 标注的字段、 @PreDestroy标注的方法进行缓存
```

## 阶段 8：Bean 属性设置阶段

### 属性设置阶段分为 3 个小的阶段

- 实例化后阶段
- Bean 属性赋值前处理
- Bean 属性赋值

### 实例化后阶段

会调用`InstantiationAwareBeanPostProcessor`接口的`postProcessAfterInstantiation`这个方法，调用逻辑如下：

看一下具体的调用逻辑如下：

```
for (BeanPostProcessor bp : getBeanPostProcessors()) {
    if (bp instanceof InstantiationAwareBeanPostProcessor) {
        InstantiationAwareBeanPostProcessor ibp = (InstantiationAwareBeanPostProcessor) bp;
        if (!ibp.postProcessAfterInstantiation(bw.getWrappedInstance(), beanName)) {
            return;
        }
    }
}
```

`postProcessAfterInstantiation`方法返回 false 的时候，后续的 **Bean 属性赋值前处理、Bean 属性赋值**都会被跳过了。

来看一下`postProcessAfterInstantiation`这个方法的定义

```
default boolean postProcessAfterInstantiation(Object bean, String beanName) throws BeansException {
    return true;
}
```

**来看个案例，案例中返回 false，跳过属性的赋值操作。**

#### 案例

##### 来个类

```
package com.javacode2018.lesson002.demo7;


public class UserModel {
    private String name;
    private Integer age;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    @Override
    public String toString() {
        return "UserModel{" +
                "name='" + name + '\'' +
                ", age=" + age +
                '}';
    }
}
```

##### 测试用例

下面很简单，来注册一个 UserModel 的 bean

```
package com.javacode2018.lesson002.demo7;


import org.junit.Test;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.InstantiationAwareBeanPostProcessor;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;

/**
 * {@link InstantiationAwareBeanPostProcessor#postProcessAfterInstantiation(java.lang.Object, java.lang.String)}
 * 返回false，可以阻止bean属性的赋值
 */
public class InstantiationAwareBeanPostProcessoryTest1 {

    @Test
    public void test1() {
        DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

        factory.registerBeanDefinition("user1", BeanDefinitionBuilder.
                genericBeanDefinition(UserModel.class).
                addPropertyValue("name", "路人甲Java").
                addPropertyValue("age", 30).
                getBeanDefinition());

        factory.registerBeanDefinition("user2", BeanDefinitionBuilder.
                genericBeanDefinition(UserModel.class).
                addPropertyValue("name", "刘德华").
                addPropertyValue("age", 50).
                getBeanDefinition());

        for (String beanName : factory.getBeanDefinitionNames()) {
            System.out.println(String.format("%s->%s", beanName, factory.getBean(beanName)));
        }
    }

}
```

上面定义了 2 个 bean：[user1,user2]，获取之后输出

##### 运行输出

```
user1->UserModel{name='路人甲Java', age=30}
user2->UserModel{name='刘德华', age=50}
```

此时 UserModel 中 2 个属性都是有值的。

下面来阻止 user1 的赋值，对代码进行改造，加入下面代码：

```
factory.addBeanPostProcessor(new InstantiationAwareBeanPostProcessor() {
    @Override
    public boolean postProcessAfterInstantiation(Object bean, String beanName) throws BeansException {
        if ("user1".equals(beanName)) {
            return false;
        } else {
            return true;
        }
    }
});
```

再次运行测试输出：

```
user1->UserModel{name='null', age=null}
user2->UserModel{name='刘德华', age=50}
```

user1 的属性赋值被跳过了。

### Bean 属性赋值前阶段

这个阶段会调用`InstantiationAwareBeanPostProcessor`接口的`postProcessProperties`方法，调用逻辑：

```
for (BeanPostProcessor bp : getBeanPostProcessors()) {
    if (bp instanceof InstantiationAwareBeanPostProcessor) {
        InstantiationAwareBeanPostProcessor ibp = (InstantiationAwareBeanPostProcessor) bp;
        PropertyValues pvsToUse = ibp.postProcessProperties(pvs, bw.getWrappedInstance(), beanName);
        if (pvsToUse == null) {
            if (filteredPds == null) {
                filteredPds = filterPropertyDescriptorsForDependencyCheck(bw, mbd.allowCaching);
            }
            pvsToUse = ibp.postProcessPropertyValues(pvs, filteredPds, bw.getWrappedInstance(), beanName);
            if (pvsToUse == null) {
                return;
            }
        }
        pvs = pvsToUse;
    }
}
```

从上面可以看出，如果`InstantiationAwareBeanPostProcessor`中的`postProcessProperties`和`postProcessPropertyValues`都返回空的时候，表示这个 bean 不需要设置属性，直接返回了，直接进入下一个阶段。

来看一下`postProcessProperties`这个方法的定义：

```
@Nullable
default PropertyValues postProcessProperties(PropertyValues pvs, Object bean, String beanName)
    throws BeansException {

    return null;
}
```

PropertyValues 中保存了 bean 实例对象中所有属性值的设置，所以我们可以在这个这个方法中对 PropertyValues 值进行修改。

#### 这个方法有 2 个比较重要的实现类

##### AutowiredAnnotationBeanPostProcessor 在这个方法中对 @Autowired、@Value 标注的字段、方法注入值。

##### CommonAnnotationBeanPostProcessor 在这个方法中对 @Resource 标注的字段和方法注入值。

**来个案例，我们在案例中对 pvs 进行修改。**

#### 案例

##### 案例代码

```
@Test
public void test3() {
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

    factory.addBeanPostProcessor(new InstantiationAwareBeanPostProcessor() { // @0
        @Nullable
        @Override
        public PropertyValues postProcessProperties(PropertyValues pvs, Object bean, String beanName) throws BeansException {
            if ("user1".equals(beanName)) {
                if (pvs == null) {
                    pvs = new MutablePropertyValues();
                }
                if (pvs instanceof MutablePropertyValues) {
                    MutablePropertyValues mpvs = (MutablePropertyValues) pvs;
                    //将姓名设置为：路人
                    mpvs.add("name", "路人");
                    //将年龄属性的值修改为18
                    mpvs.add("age", 18);
                }
            }
            return null;
        }
    });

    //注意 user1 这个没有给属性设置值
    factory.registerBeanDefinition("user1", BeanDefinitionBuilder.
            genericBeanDefinition(UserModel.class).
            getBeanDefinition()); //@1

    factory.registerBeanDefinition("user2", BeanDefinitionBuilder.
            genericBeanDefinition(UserModel.class).
            addPropertyValue("name", "刘德华").
            addPropertyValue("age", 50).
            getBeanDefinition());

    for (String beanName : factory.getBeanDefinitionNames()) {
        System.out.println(String.format("%s->%s", beanName, factory.getBean(beanName)));
    }
}
```

@1：user1 这个 bean 没有设置属性的值

@0：这个实现 org.springframework.beans.factory.config.InstantiationAwareBeanPostProcessor#postProcessProperties 方法，在其内部对 user1 这个 bean 进行属性值信息进行修改。

##### 运行输出

```
user1->UserModel{name='路人', age=18}
user2->UserModel{name='刘德华', age=50}
```

上面过程都 ok，进入 bean 赋值操作

### Bean 属性赋值阶段

这个过程比较简单了，循环处理`PropertyValues`中的属性值信息，通过反射调用 set 方法将属性的值设置到 bean 实例中。

PropertyValues 中的值是通过 bean xml 中 property 元素配置的，或者调用 MutablePropertyValues 中 add 方法设置的值。

## 阶段 9：Bean 初始化阶段

### 这个阶段分为 5 个小的阶段

- Bean Aware 接口回调
- Bean 初始化前操作
- Bean 初始化操作
- Bean 初始化后操作
- Bean 初始化完成操作

### Bean Aware 接口回调

这块的源码：

```
private void invokeAwareMethods(final String beanName, final Object bean) {
        if (bean instanceof Aware) {
            if (bean instanceof BeanNameAware) {
                ((BeanNameAware) bean).setBeanName(beanName);
            }
            if (bean instanceof BeanClassLoaderAware) {
                ClassLoader bcl = getBeanClassLoader();
                if (bcl != null) {
                    ((BeanClassLoaderAware) bean).setBeanClassLoader(bcl);
                }
            }
            if (bean instanceof BeanFactoryAware) {
                ((BeanFactoryAware) bean).setBeanFactory(AbstractAutowireCapableBeanFactory.this);
            }
        }
    }
```

如果我们的 bean 实例实现了上面的接口，会按照下面的顺序依次进行调用：

```
BeanNameAware：将bean的名称注入进去
BeanClassLoaderAware：将BeanClassLoader注入进去
BeanFactoryAware：将BeanFactory注入进去
```

来个案例感受一下

来个类，实现上面 3 个接口。

```
package com.javacode2018.lesson002.demo8;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanClassLoaderAware;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.beans.factory.BeanFactoryAware;
import org.springframework.beans.factory.BeanNameAware;

public class AwareBean implements BeanNameAware, BeanClassLoaderAware, BeanFactoryAware {

    @Override
    public void setBeanName(String name) {
        System.out.println("setBeanName：" + name);
    }

    @Override
    public void setBeanFactory(BeanFactory beanFactory) throws BeansException {
        System.out.println("setBeanFactory：" + beanFactory);
    }

    @Override
    public void setBeanClassLoader(ClassLoader classLoader) {
        System.out.println("setBeanClassLoader：" + classLoader);
    }

}
```

来个测试类，创建上面这个对象的的 bean

```
package com.javacode2018.lesson002.demo8;

import org.junit.Test;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;

public class InvokeAwareTest {

    @Test
    public void test1() {
        DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
        factory.registerBeanDefinition("awareBean", BeanDefinitionBuilder.genericBeanDefinition(AwareBean.class).getBeanDefinition());
        //调用getBean方法获取bean，将触发bean的初始化
        factory.getBean("awareBean");
    }
}
```

运行输出

```
setBeanName：awareBean
setBeanClassLoader：sun.misc.Launcher$AppClassLoader@18b4aac2
setBeanFactory：org.springframework.beans.factory.support.DefaultListableBeanFactory@5bb21b69: defining beans [awareBean]; root of factory hierarchy
```

### Bean 初始化前操作

这个阶段的源码：

```
@Override
public Object applyBeanPostProcessorsBeforeInitialization(Object existingBean, String beanName)
    throws BeansException {

    Object result = existingBean;
    for (BeanPostProcessor processor : getBeanPostProcessors()) {
        Object current = processor.postProcessBeforeInitialization(result, beanName);
        if (current == null) {
            return result;
        }
        result = current;
    }
    return result;
}
```

会调用`BeanPostProcessor的postProcessBeforeInitialization`方法，若返回 null，当前方法将结束。

**通常称 postProcessBeforeInitialization 这个方法为：bean 初始化前操作。**

这个接口有 2 个实现类，比较重要：

```
org.springframework.context.support.ApplicationContextAwareProcessor
org.springframework.context.annotation.CommonAnnotationBeanPostProcessor
```

#### ApplicationContextAwareProcessor 注入 6 个 Aware 接口对象

如果 bean 实现了下面的接口，在`ApplicationContextAwareProcessor#postProcessBeforeInitialization`中会依次调用下面接口中的方法，将`Aware`前缀对应的对象注入到 bean 实例中。

```
EnvironmentAware：注入Environment对象
EmbeddedValueResolverAware：注入EmbeddedValueResolver对象
ResourceLoaderAware：注入ResourceLoader对象
ApplicationEventPublisherAware：注入ApplicationEventPublisher对象
MessageSourceAware：注入MessageSource对象
ApplicationContextAware：注入ApplicationContext对象
```

从名称上可以看出这个类以`ApplicationContext`开头的，说明这个类只能在`ApplicationContext`环境中使用。

#### CommonAnnotationBeanPostProcessor 调用 @PostConstruct 标注的方法

`CommonAnnotationBeanPostProcessor#postProcessBeforeInitialization`中会调用 bean 中所有标注 @PostConstruct 注解的方法

来个案例，感受一下。

#### 案例

##### 来个类

下面的类有 2 个方法标注了`@PostConstruct`，并且实现了上面说的那 6 个 Aware 接口。

```
package com.javacode2018.lesson002.demo9;

import org.springframework.beans.BeansException;
import org.springframework.context.*;
import org.springframework.core.env.Environment;
import org.springframework.core.io.ResourceLoader;
import org.springframework.util.StringValueResolver;

import javax.annotation.PostConstruct;

public class Bean1 implements EnvironmentAware, EmbeddedValueResolverAware, ResourceLoaderAware, ApplicationEventPublisherAware, MessageSourceAware, ApplicationContextAware {

    @PostConstruct
    public void postConstruct1() { //@1
        System.out.println("postConstruct1()");
    }

    @PostConstruct
    public void postConstruct2() { //@2
        System.out.println("postConstruct2()");
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        System.out.println("setApplicationContext:" + applicationContext);
    }

    @Override
    public void setApplicationEventPublisher(ApplicationEventPublisher applicationEventPublisher) {
        System.out.println("setApplicationEventPublisher:" + applicationEventPublisher);
    }

    @Override
    public void setEmbeddedValueResolver(StringValueResolver resolver) {
        System.out.println("setEmbeddedValueResolver:" + resolver);
    }

    @Override
    public void setEnvironment(Environment environment) {
        System.out.println("setEnvironment:" + environment.getClass());
    }

    @Override
    public void setMessageSource(MessageSource messageSource) {
        System.out.println("setMessageSource:" + messageSource);
    }

    @Override
    public void setResourceLoader(ResourceLoader resourceLoader) {
        System.out.println("setResourceLoader:" + resourceLoader);
    }
}
```

##### 来个测试案例

```
package com.javacode2018.lesson002.demo9;


import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class PostProcessBeforeInitializationTest {

    @Test
    public void test1() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(Bean1.class);
        context.refresh();
    }
}
```

##### 运行输出

```
setEmbeddedValueResolver:org.springframework.beans.factory.config.EmbeddedValueResolver@15b204a1
setResourceLoader:org.springframework.context.annotation.AnnotationConfigApplicationContext@64bf3bbf, started on Sun Apr 05 21:16:00 CST 2020
setApplicationEventPublisher:org.springframework.context.annotation.AnnotationConfigApplicationContext@64bf3bbf, started on Sun Apr 05 21:16:00 CST 2020
setMessageSource:org.springframework.context.annotation.AnnotationConfigApplicationContext@64bf3bbf, started on Sun Apr 05 21:16:00 CST 2020
setApplicationContext:org.springframework.context.annotation.AnnotationConfigApplicationContext@64bf3bbf, started on Sun Apr 05 21:16:00 CST 2020
postConstruct1()
postConstruct2()
```

大家可以去看一下 AnnotationConfigApplicationContext 的源码，其内部会添加很多`BeanPostProcessor`到`DefaultListableBeanFactory`中。

### Bean 初始化阶段

#### 2 个步骤

1. 调用 InitializingBean 接口的 afterPropertiesSet 方法
2. 调用定义 bean 的时候指定的初始化方法。

#### 调用 InitializingBean 接口的 afterPropertiesSet 方法

来看一下 InitializingBean 这个接口

```
public interface InitializingBean {

    void afterPropertiesSet() throws Exception;

}
```

当我们的 bean 实现了这个接口的时候，会在这个阶段被调用

#### 调用 bean 定义的时候指定的初始化方法

**先来看一下如何指定 bean 的初始化方法，3 种方式**

##### 方式 1：xml 方式指定初始化方法

```
<bean init-method="bean中方法名称"/>
```

##### 方式 2：@Bean 的方式指定初始化方法

```
@Bean(initMethod = "初始化的方法")
```

##### 方式 3：api 的方式指定初始化方法

```
this.beanDefinition.setInitMethodName(methodName);
```

初始化方法最终会赋值给下面这个字段

```
org.springframework.beans.factory.support.AbstractBeanDefinition#initMethodName
```

#### 案例

##### 来个类

```
package com.javacode2018.lesson002.demo10;

import org.springframework.beans.factory.InitializingBean;

public class Service implements InitializingBean{
    public void init() {
        System.out.println("调用init()方法");
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("调用afterPropertiesSet()");
    }
}
```

##### 下面我们定义 Service 这个 bean，指定 init 方法为初始化方法

```
package com.javacode2018.lesson002.demo10;

import org.junit.Test;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;

/**
 * 初始化方法测试
 */
public class InitMethodTest {

    @Test
    public void test1() {
        DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
        BeanDefinition service = BeanDefinitionBuilder.genericBeanDefinition(Service.class).
                setInitMethodName("init"). //@1：指定初始化方法
                getBeanDefinition();

        factory.registerBeanDefinition("service", service);

        System.out.println(factory.getBean("service"));
    }
}
```

##### 运行输出

```
调用afterPropertiesSet()
调用init()方法
com.javacode2018.lesson002.demo10.Service@12f41634
```

调用顺序：InitializingBean 中的 afterPropertiesSet、然后在调用自定义的初始化方法

### Bean 初始化后阶段

这块的源码：

```
@Override
public Object applyBeanPostProcessorsAfterInitialization(Object existingBean, String beanName)
    throws BeansException {

    Object result = existingBean;
    for (BeanPostProcessor processor : getBeanPostProcessors()) {
        Object current = processor.postProcessAfterInitialization(result, beanName);
        if (current == null) {
            return result;
        }
        result = current;
    }
    return result;
}
```

调用`BeanPostProcessor接口的postProcessAfterInitialization方法`，返回 null 的时候，会中断上面的操作。

**通常称 postProcessAfterInitialization 这个方法为：bean 初始化后置操作。**

来个案例：

```
package com.javacode2018.lesson002.demo11;

import org.junit.Test;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;
import org.springframework.lang.Nullable;

/**
 * {@link BeanPostProcessor#postProcessAfterInitialization(java.lang.Object, java.lang.String)}
 * bean初始化后置处理
 */
public class PostProcessAfterInitializationTest {

    @Test
    public void test1() {
        DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

        //加入bean初始化后置处理器方法实现
        factory.addBeanPostProcessor(new BeanPostProcessor() {
            @Nullable
            @Override
            public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
                System.out.println("postProcessAfterInitialization：" + beanName);
                return bean;
            }
        });

        //下面注册2个String类型的bean
        factory.registerBeanDefinition("name",
                BeanDefinitionBuilder.
                        genericBeanDefinition(String.class).
                        addConstructorArgValue("公众号：【路人甲Java】").
                        getBeanDefinition());
        factory.registerBeanDefinition("personInformation",
                BeanDefinitionBuilder.genericBeanDefinition(String.class).
                        addConstructorArgValue("带领大家成为java高手！").
                        getBeanDefinition());

        System.out.println("-------输出bean信息---------");

        for (String beanName : factory.getBeanDefinitionNames()) {
            System.out.println(String.format("%s->%s", beanName, factory.getBean(beanName)));
        }
    }
}
```

运行输出

```
-------输出bean信息---------
postProcessAfterInitialization：name
name->公众号：【路人甲Java】
postProcessAfterInitialization：personInformation
personInformation->带领大家成为java高手！
```

## 阶段 10：所有单例 bean 初始化完成后阶段

所有单例 bean 实例化完成之后，spring 会回调下面这个接口：

```
public interface SmartInitializingSingleton {
    void afterSingletonsInstantiated();
}
```

调用逻辑在下面这个方法中

```
/**
 * 确保所有非lazy的单例都被实例化，同时考虑到FactoryBeans。如果需要，通常在工厂设置结束时调用。
 */
org.springframework.beans.factory.support.DefaultListableBeanFactory#preInstantiateSingletons
```

这个方法内部会先触发所有非延迟加载的单例 bean 初始化，然后从容器中找到类型是`SmartInitializingSingleton`的 bean，调用他们的`afterSingletonsInstantiated`方法。

有兴趣的可以去看一下带有 ApplicationContext 的容器，内部最终都会调用上面这个方法触发所有单例 bean 的初始化。

来个 2 个案例演示一下 SmartInitializingSingleton 的使用。

### 案例 1：ApplicationContext 自动回调 SmartInitializingSingleton 接口

Service1：

```
package com.javacode2018.lesson002.demo12;

import org.springframework.stereotype.Component;

@Component
public class Service1 {

    public Service1() {
        System.out.println("create " + this.getClass());
    }
}
```

Service2：

```
package com.javacode2018.lesson002.demo12;

import org.springframework.stereotype.Component;

@Component
public class Service2 {
    public Service2() {
        System.out.println("create " + this.getClass());
    }
}
```

自定义一个 SmartInitializingSingleton

```
package com.javacode2018.lesson002.demo12;

import org.springframework.beans.factory.SmartInitializingSingleton;
import org.springframework.stereotype.Component;

@Component
public class MySmartInitializingSingleton implements SmartInitializingSingleton {
    @Override
    public void afterSingletonsInstantiated() {
        System.out.println("所有bean初始化完毕！");
    }
}
```

来个测试类，通过包扫描的方式注册上面 3 个 bean

```
package com.javacode2018.lesson002.demo12;

import org.junit.Test;
import org.springframework.beans.factory.SmartInitializingSingleton;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.ComponentScan;

/**
 * 所有bean初始化完毕，容器会回调{@link SmartInitializingSingleton#afterSingletonsInstantiated()}
 */
@ComponentScan
public class SmartInitializingSingletonTest {
    @Test
    public void test1() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(SmartInitializingSingletonTest.class);
        System.out.println("开始启动容器!");
        context.refresh();
        System.out.println("容器启动完毕!");
    }
}
```

运行输出

```
开始启动容器!
create class com.javacode2018.lesson002.demo12.Service1
create class com.javacode2018.lesson002.demo12.Service2
所有bean初始化完毕！
容器启动完毕!
```

### 案例 2：通过 api 的方式让 DefaultListableBeanFactory 去回调 SmartInitializingSingleton

```
@Test
public void test2() {
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
    factory.registerBeanDefinition("service1", BeanDefinitionBuilder.genericBeanDefinition(Service1.class).getBeanDefinition());
    factory.registerBeanDefinition("service2", BeanDefinitionBuilder.genericBeanDefinition(Service2.class).getBeanDefinition());
    factory.registerBeanDefinition("mySmartInitializingSingleton", BeanDefinitionBuilder.genericBeanDefinition(MySmartInitializingSingleton.class).getBeanDefinition());
    System.out.println("准备触发所有单例bean初始化");
    //触发所有bean初始化，并且回调 SmartInitializingSingleton#afterSingletonsInstantiated 方法
    factory.preInstantiateSingletons();
}
```

上面通过 api 的方式注册 bean

最后调用`factory.preInstantiateSingletons`触发所有非 lazy 单例 bean 初始化，所有 bean 装配完毕之后，会回调 SmartInitializingSingleton 接口。

## 阶段 11：Bean 使用阶段

这个阶段就不说了，调用 getBean 方法得到了 bean 之后，大家可以随意使用，任意发挥。

## 阶段 12：Bean 销毁阶段

### 触发 bean 销毁的几种方式

1. 调用 org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#destroyBean
2. 调用 org.springframework.beans.factory.config.ConfigurableBeanFactory#destroySingletons
3. 调用 ApplicationContext 中的 close 方法

### Bean 销毁阶段会依次执行

1. 轮询 beanPostProcessors 列表，如果是 DestructionAwareBeanPostProcessor 这种类型的，会调用其内部的 postProcessBeforeDestruction 方法
2. 如果 bean 实现了 org.springframework.beans.factory.DisposableBean 接口，会调用这个接口中的 destroy 方法
3. 调用 bean 自定义的销毁方法

### DestructionAwareBeanPostProcessor 接口

看一下源码：

```
public interface DestructionAwareBeanPostProcessor extends BeanPostProcessor {

    /**
     * bean销毁前调用的方法
     */
    void postProcessBeforeDestruction(Object bean, String beanName) throws BeansException;

    /**
     * 用来判断bean是否需要触发postProcessBeforeDestruction方法
     */
    default boolean requiresDestruction(Object bean) {
        return true;
    }

}
```

这个接口有个关键的实现类：

```
org.springframework.context.annotation.CommonAnnotationBeanPostProcessor
```

**CommonAnnotationBeanPostProcessor#postProcessBeforeDestruction 方法中会调用 bean 中所有标注了 @PreDestroy 的方法。**

### 再来说一下自定义销毁方法有 3 种方式

#### 方式 1：xml 中指定销毁方法

```
<bean destroy-method="bean中方法名称"/>
```

#### 方式 2：@Bean 中指定销毁方法

```
@Bean(destroyMethod = "初始化的方法")
```

#### 方式 3：api 的方式指定销毁方法

```
this.beanDefinition.setDestroyMethodName(methodName);
```

初始化方法最终会赋值给下面这个字段

```
org.springframework.beans.factory.support.AbstractBeanDefinition#destroyMethodName
```

下面来看销毁的案例

### 案例 1：自定义 DestructionAwareBeanPostProcessor

#### 来个类

```
package com.javacode2018.lesson002.demo13;

public class ServiceA {
    public ServiceA() {
        System.out.println("create " + this.getClass());
    }
}
```

#### 自定义一个 DestructionAwareBeanPostProcessor

```
package com.javacode2018.lesson002.demo13;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.DestructionAwareBeanPostProcessor;

public class MyDestructionAwareBeanPostProcessor implements DestructionAwareBeanPostProcessor {
    @Override
    public void postProcessBeforeDestruction(Object bean, String beanName) throws BeansException {
        System.out.println("准备销毁bean：" + beanName);
    }
}
```

#### 来个测试类

```
package com.javacode2018.lesson002.demo13;

import org.junit.Test;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;

/**
 * 自定义 {@link org.springframework.beans.factory.config.DestructionAwareBeanPostProcessor}
 */
public class DestructionAwareBeanPostProcessorTest {

    @Test
    public void test1() {
        DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

        //添加自定义的DestructionAwareBeanPostProcessor
        factory.addBeanPostProcessor(new MyDestructionAwareBeanPostProcessor());

        //向容器中注入3个单例bean
        factory.registerBeanDefinition("serviceA1", BeanDefinitionBuilder.genericBeanDefinition(ServiceA.class).getBeanDefinition());
        factory.registerBeanDefinition("serviceA2", BeanDefinitionBuilder.genericBeanDefinition(ServiceA.class).getBeanDefinition());
        factory.registerBeanDefinition("serviceA3", BeanDefinitionBuilder.genericBeanDefinition(ServiceA.class).getBeanDefinition());

        //触发所有单例bean初始化
        factory.preInstantiateSingletons(); //@1

        System.out.println("销毁serviceA1"); 
        //销毁指定的bean
        factory.destroySingleton("serviceA1");//@2

        System.out.println("触发所有单例bean的销毁");
        factory.destroySingletons();
    }
}
```

上面使用了 2 种方式来触发 bean 的销毁 [@1 和 @2]

#### 运行输出

```
create class com.javacode2018.lesson002.demo13.ServiceA
create class com.javacode2018.lesson002.demo13.ServiceA
create class com.javacode2018.lesson002.demo13.ServiceA
销毁serviceA1
准备要销毁bean：serviceA1
触发所有单例bean的销毁
准备要销毁bean：serviceA3
准备要销毁bean：serviceA2
```

可以看到 postProcessBeforeDestruction 被调用了 3 次，依次销毁 3 个自定义的 bean

### 案例 2：触发 @PreDestroy 标注的方法被调用

上面说了这个注解是在`CommonAnnotationBeanPostProcessor#postProcessBeforeDestruction`中被处理的，所以只需要将这个加入 BeanPostProcessor 列表就可以了。

#### 再来个类

```
package com.javacode2018.lesson002.demo13;

import javax.annotation.PreDestroy;

public class ServiceB {
    public ServiceB() {
        System.out.println("create " + this.getClass());
    }

    @PreDestroy
    public void preDestroy() { //@1
        System.out.println("preDestroy()");
    }
}
```

@1：标注了 @PreDestroy 注解

#### 测试用例

```
@Test
public void test2() {
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory();

    //添加自定义的DestructionAwareBeanPostProcessor
    factory.addBeanPostProcessor(new MyDestructionAwareBeanPostProcessor()); //@1
    //将CommonAnnotationBeanPostProcessor加入
    factory.addBeanPostProcessor(new CommonAnnotationBeanPostProcessor()); //@2

    //向容器中注入bean
    factory.registerBeanDefinition("serviceB", BeanDefinitionBuilder.genericBeanDefinition(ServiceB.class).getBeanDefinition());

    //触发所有单例bean初始化
    factory.preInstantiateSingletons();

    System.out.println("销毁serviceB");
    //销毁指定的bean
    factory.destroySingleton("serviceB");
}
```

@1：放入了一个自定义的 DestructionAwareBeanPostProcessor

@2：放入了 CommonAnnotationBeanPostProcessor，这个会处理 bean 中标注 @PreDestroy 注解的方法

#### 看效果运行输出

```
create class com.javacode2018.lesson002.demo13.ServiceB
销毁serviceB
准备销毁bean：serviceB
preDestroy()
```

### 案例 3：看一下销毁阶段的执行顺序

实际上 ApplicationContext 内部已经将 spring 内部一些常见的必须的`BeannPostProcessor`自动装配到`beanPostProcessors列表中`，比如我们熟悉的下面的几个：

```
1.org.springframework.context.annotation.CommonAnnotationBeanPostProcessor
  用来处理@Resource、@PostConstruct、@PreDestroy的
2.org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor
  用来处理@Autowired、@Value注解
3.org.springframework.context.support.ApplicationContextAwareProcessor
  用来回调Bean实现的各种Aware接口
```

所以通过 ApplicationContext 来销毁 bean，会触发 3 中方式的执行。

下面我们就以 AnnotationConfigApplicationContext 来演示一下销毁操作。

来一个类

```
package com.javacode2018.lesson002.demo14;

import org.springframework.beans.factory.DisposableBean;

import javax.annotation.PreDestroy;

public class ServiceA implements DisposableBean {

    public ServiceA() {
        System.out.println("创建ServiceA实例");
    }

    @PreDestroy
    public void preDestroy1() {
        System.out.println("preDestroy1()");
    }

    @PreDestroy
    public void preDestroy2() {
        System.out.println("preDestroy2()");
    }

    @Override
    public void destroy() throws Exception {
        System.out.println("DisposableBean接口中的destroy()");
    }

    //自定义的销毁方法
    public void customDestroyMethod() { //@1
        System.out.println("我是自定义的销毁方法:customDestroyMethod()");
    }
}
```

上面的类中有 2 个方法标注了 @PreDestroy

这个类实现了 DisposableBean 接口，重写了接口的中的 destroy 方法

@1：这个 destroyMethod 我们一会通过 @Bean 注解的方式，将其指定为自定义方法。

来看测试用例

```
package com.javacode2018.lesson002.demo14;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Configurable;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;

@Configurable
public class DestroyTest {

    @Bean(destroyMethod = "customDestroyMethod") //@1
    public ServiceA serviceA() {
        return new ServiceA();
    }

    @Test
    public void test1() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(DestroyTest.class);
        //启动容器
        System.out.println("准备启动容器");
        context.refresh();
        System.out.println("容器启动完毕");
        System.out.println("serviceA：" + context.getBean(ServiceA.class));
        //关闭容器
        System.out.println("准备关闭容器");
        //调用容器的close方法，会触发bean的销毁操作
        context.close(); //@2
        System.out.println("容器关闭完毕");
    }
}
```

上面这个类标注了 @Configuration，表示是一个配置类，内部有个 @Bean 标注的方法，表示使用这个方法来定义一个 bean。

@1：通过 destroyMethod 属性将 customDestroyMethod 指定为自定义销毁方法

@2：关闭容器，触发 bean 销毁操作

来运行 test1，输出

```
准备启动容器
创建ServiceA实例
容器启动完毕
serviceA：com.javacode2018.lesson002.demo14.ServiceA@243c4f91
准备关闭容器
preDestroy1()
preDestroy2()
DisposableBean接口中的destroy()
我是自定义的销毁方法:customDestroyMethod()
容器关闭完毕
```

可以看出销毁方法调用的顺序：

1. @PreDestroy 标注的所有方法
2. DisposableBean 接口中的 destroy()
3. 自定义的销毁方法

下面来说一个非常非常重要的类，打起精神，一定要注意看。

## AbstractApplicationContext 类（非常重要的类）

来看一下 UML 图：



![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201214114515.png)



### BeanFactory 接口

这个我们已经很熟悉了，Bean 工厂的顶层接口

### DefaultListableBeanFactory 类

实现了 BeanFactory 接口，可以说这个可以是 BeanFactory 接口真正的唯一实现，内部真正实现了 bean 生命周期中的所有代码。

其他的一些类都是依赖于 DefaultListableBeanFactory 类，将请求转发给 DefaultListableBeanFactory 进行 bean 的处理的。

### 其他 3 个类

我们经常用到的就是这 3 个类：AnnotationConfigApplicationContext/ClassPathXmlApplicationContext/FileSystemXmlApplicationContext 这 3 个类，他们的主要内部的功能是依赖他的父类 AbstractApplicationContext 来实现的，所以大家主要看`AbstractApplicationContext`这个类。

### AbstractApplicationContext 类

这个类中有 2 个比较重要的方法

```
public abstract ConfigurableListableBeanFactory getBeanFactory() throws IllegalStateException;
protected void registerBeanPostProcessors(ConfigurableListableBeanFactory beanFactory)
```

大家是否注意过我们使用`AnnotationConfigApplicationContext`的时候，经常调用`reflush方法`，这个方法内部就会调用上面这 2 个方法。

#### 第一个方法：getBeanFactory()

返回当前应用上下文中的`ConfigurableListableBeanFactory`，这也是个接口类型的，这个接口有一个唯一的实现类：`DefaultListableBeanFactory`。

有没有很熟悉，上面说过：DefaultListableBeanFactory 是 BeanFactory 真正的唯一实现。

应用上线文中就会使用这个`ConfigurableListableBeanFactory`来操作 spring 容器。

#### 第二个方法：registerBeanPostProcessors

**说的通俗点：这个方法就是向 ConfigurableListableBeanFactory 中注册 BeanPostProcessor，内容会从 spring 容器中获取所有类型的 BeanPostProcessor，将其添加到 DefaultListableBeanFactory#beanPostProcessors 列表中**

看一下这个方法的源码：

```
protected void registerBeanPostProcessors(ConfigurableListableBeanFactory beanFactory) {
    PostProcessorRegistrationDelegate.registerBeanPostProcessors(beanFactory, this);
}
```

会将请求转发给`PostProcessorRegistrationDelegate#registerBeanPostProcessors`。

内部比较长，大家可以去看一下源码，这个方法内部主要用到了 4 个`BeanPostProcessor`类型的 List 集合。

```
List<BeanPostProcessor> priorityOrderedPostProcessors = new ArrayList<>();
List<BeanPostProcessor> orderedPostProcessors
List<BeanPostProcessor> nonOrderedPostProcessors;
List<BeanPostProcessor> internalPostProcessors = new ArrayList<>();
```

**先说一下：当到方法的时候，spring 容器中已经完成了所有 Bean 的注册。**

spring 会从容器中找出所有类型的 BeanPostProcessor 列表，然后按照下面的规则将其分别放到上面的 4 个集合中，上面 4 个集合中的`BeanPostProcessor`会被依次添加到 DefaultListableBeanFactory#beanPostProcessors 列表中，来看一下 4 个集合的分别放的是那些 BeanPostProcessor：

##### priorityOrderedPostProcessors（指定优先级的 BeanPostProcessor）

实现 org.springframework.core.PriorityOrdered 接口的 BeanPostProcessor，但是不包含 MergedBeanDefinitionPostProcessor 类型的

##### orderedPostProcessors（指定了顺序的 BeanPostProcessor）

标注有 @Order 注解，或者实现了 org.springframework.core.annotation.Order 接口的 BeanPostProcessor，但是不包含 MergedBeanDefinitionPostProcessor 类型的

##### nonOrderedPostProcessors（未指定顺序的 BeanPostProcessor）

上面 2 中类型置为以及 MergedBeanDefinitionPostProcessor 之外的

##### internalPostProcessors

MergedBeanDefinitionPostProcessor 类型的 BeanPostProcessor 列表。

大家可以去看一下`CommonAnnotationBeanPostProcessor`和`AutowiredAnnotationBeanPostProcessor`，这两个类都实现了`PriorityOrdered`接口，但是他们也实现了`MergedBeanDefinitionPostProcessor`接口，所以最终他们会被丢到`internalPostProcessors`这个集合中，会被放入 BeanPostProcessor 的最后面。

## Bean 生命周期流程图



![img](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201214114509.jpeg)





# 24、父子容器详解

## 我们先来看一个案例

系统中有 2 个模块：module1 和 module2，两个模块是独立开发的，module2 会使用到 module1 中的一些类，module1 会将自己打包为 jar 提供给 module2 使用，我们来看一下这 2 个模块的代码。

### 模块 1

放在 module1 包中，有 3 个类

#### Service1

```
package com.javacode2018.lesson002.demo17.module1;

import org.springframework.stereotype.Component;

@Component
public class Service1 {
    public String m1() {
        return "我是module1中的Servce1中的m1方法";
    }
}
```

#### Service2

```
package com.javacode2018.lesson002.demo17.module1;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Service2 {

    @Autowired
    private com.javacode2018.lesson002.demo17.module1.Service1 service1; //@1

    public String m1() { //@2
        return this.service1.m1();
    }

}
```

上面 2 个类，都标注了 @Compontent 注解，会被 spring 注册到容器中。

@1：Service2 中需要用到 Service1，标注了 @Autowired 注解，会通过 spring 容器注入进来

@2：Service2 中有个 m1 方法，内部会调用 service 的 m1 方法。

#### 来个 spring 配置类：Module1Config

```
package com.javacode2018.lesson002.demo17.module1;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class Module1Config {
}
```

上面使用了 @CompontentScan 注解，会自动扫描当前类所在的包中的所有类，将标注有 @Compontent 注解的类注册到 spring 容器，即 Service1 和 Service2 会被注册到 spring 容器。

### 再来看模块 2

放在 module2 包中，也是有 3 个类，和模块 1 中的有点类似。

#### Service1

模块 2 中也定义了一个 Service1，内部提供了一个 m2 方法，如下：

```
package com.javacode2018.lesson002.demo17.module2;

import org.springframework.stereotype.Component;

@Component
public class Service1 {
    public String m2() {
        return "我是module2中的Servce1中的m2方法";
    }
}
```

#### Service3

```
package com.javacode2018.lesson002.demo17.module2;

import com.javacode2018.lesson002.demo17.module1.Service2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Service3 {
    //使用模块2中的Service1
    @Autowired
    private com.javacode2018.lesson002.demo17.module2.Service1 service1; //@1
    //使用模块1中的Service2
    @Autowired
    private com.javacode2018.lesson002.demo17.module1.Service2 service2; //@2

    public String m1() {
        return this.service2.m1();
    }

    public String m2() {
        return this.service1.m2();
    }

}
```

@1：使用 module2 中的 Service1

@2：使用 module1 中的 Service2

#### 先来思考一个问题

**上面的这些类使用 spring 来操作会不会有问题？会有什么问题？**

这个问题还是比较简单的，大部分人都可以看出来，会报错，因为两个模块中都有 Service1，被注册到 spring 容器的时候，bean 名称会冲突，导致注册失败。

#### 来个测试类，看一下效果

```
package com.javacode2018.lesson002.demo17;

import com.javacode2018.lesson001.demo21.Config;
import com.javacode2018.lesson002.demo17.module1.Module1Config;
import com.javacode2018.lesson002.demo17.module2.Module2Config;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class ParentFactoryTest {

    @Test
    public void test1() {
        //定义容器
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        //注册bean
        context.register(Module1Config.class, Module2Config.class); //@1
        //启动容器
        context.refresh();
    }
}
```

@1：将`Module1Config、Module2Config`注册到容器，spring 内部会自动解析这两个类上面的注解，即：`@CompontentScan`注解，然后会进行包扫描，将标注了`@Compontent`的类注册到 spring 容器。

#### 运行 test1 输出

下面是部分输出：

```
Caused by: org.springframework.context.annotation.ConflictingBeanDefinitionException: Annotation-specified bean name 'service1' for bean class [com.javacode2018.lesson002.demo17.module2.Service1] conflicts with existing, non-compatible bean definition of same name and class [com.javacode2018.lesson002.demo17.module1.Service1]
```

service1 这个 bean 的名称冲突了。

#### 那么我们如何解决？

对 module1 中的 Service1 进行修改？这个估计是行不通的，module1 是别人以 jar 的方式提供给我们的，源码我们是无法修改的。

而 module2 是我们自己的开发的，里面的东西我们可以随意调整，那么我们可以去修改一下 module2 中的 Service1，可以修改一下类名，或者修改一下这个 bean 的名称，此时是可以解决问题的。

不过大家有没有想过一个问题：如果我们的模块中有很多类都出现了这种问题，此时我们一个个去重构，还是比较痛苦的，并且代码重构之后，还涉及到重新测试的问题，工作量也是蛮大的，这些都是风险。

而 spring 中的父子容器就可以很好的解决上面这种问题。

## 什么是父子容器

创建 spring 容器的时候，可以给当前容器指定一个父容器。

### BeanFactory 的方式

```
//创建父容器parentFactory
DefaultListableBeanFactory parentFactory = new DefaultListableBeanFactory();
//创建一个子容器childFactory
DefaultListableBeanFactory childFactory = new DefaultListableBeanFactory();
//调用setParentBeanFactory指定父容器
childFactory.setParentBeanFactory(parentFactory);
```

### ApplicationContext 的方式

```
//创建父容器
AnnotationConfigApplicationContext parentContext = new AnnotationConfigApplicationContext();
//启动父容器
parentContext.refresh();

//创建子容器
AnnotationConfigApplicationContext childContext = new AnnotationConfigApplicationContext();
//给子容器设置父容器
childContext.setParent(parentContext);
//启动子容器
childContext.refresh();
```

上面代码还是比较简单的，大家都可以看懂。

我们需要了解父子容器的特点，这些是比较关键的，如下。

### 父子容器特点

1. **父容器和子容器是相互隔离的，他们内部可以存在名称相同的 bean**
2. **子容器可以访问父容器中的 bean，而父容器不能访问子容器中的 bean**
3. **调用子容器的 getBean 方法获取 bean 的时候，会沿着当前容器开始向上面的容器进行查找，直到找到对应的 bean 为止**
4. **子容器中可以通过任何注入方式注入父容器中的 bean，而父容器中是无法注入子容器中的 bean，原因是第 2 点**

## 使用父子容器解决开头的问题

### 关键代码

```
@Test
public void test2() {
    //创建父容器
    AnnotationConfigApplicationContext parentContext = new AnnotationConfigApplicationContext();
    //向父容器中注册Module1Config配置类
    parentContext.register(Module1Config.class);
    //启动父容器
    parentContext.refresh();

    //创建子容器
    AnnotationConfigApplicationContext childContext = new AnnotationConfigApplicationContext();
    //向子容器中注册Module2Config配置类
    childContext.register(Module2Config.class);
    //给子容器设置父容器
    childContext.setParent(parentContext);
    //启动子容器
    childContext.refresh();

    //从子容器中获取Service3
    Service3 service3 = childContext.getBean(Service3.class);
    System.out.println(service3.m1());
    System.out.println(service3.m2());
}
```

### 运行输出

```
我是module1中的Servce1中的m1方法
我是module2中的Servce1中的m2方法
```

这次正常了。

## 父子容器使用注意点

我们使用容器的过程中，经常会使用到的一些方法，这些方法通常会在下面的两个接口中

```
org.springframework.beans.factory.BeanFactory
org.springframework.beans.factory.ListableBeanFactory
```

这两个接口中有很多方法，这里就不列出来了，大家可以去看一下源码，这里要说的是使用父子容器的时候，有些需要注意的地方。

BeanFactory 接口，是 spring 容器的顶层接口，这个接口中的方法是支持容器嵌套结构查找的，比如我们常用的 getBean 方法，就是这个接口中定义的，调用 getBean 方法的时候，会从沿着当前容器向上查找，直到找到满足条件的 bean 为止。

而 ListableBeanFactory 这个接口中的方法是不支持容器嵌套结构查找的，比如下面这个方法

```
String[] getBeanNamesForType(@Nullable Class<?> type)
```

获取指定类型的所有 bean 名称，调用这个方法的时候只会返回当前容器中符合条件的 bean，而不会去递归查找其父容器中的 bean。

来看一下案例代码，感受一下：

```
@Test
public void test3() {
    //创建父容器parentFactory
    DefaultListableBeanFactory parentFactory = new DefaultListableBeanFactory();
    //向父容器parentFactory注册一个bean[userName->"路人甲Java"]
    parentFactory.registerBeanDefinition("userName",
            BeanDefinitionBuilder.
                    genericBeanDefinition(String.class).
                    addConstructorArgValue("路人甲Java").
                    getBeanDefinition());

    //创建一个子容器childFactory
    DefaultListableBeanFactory childFactory = new DefaultListableBeanFactory();
    //调用setParentBeanFactory指定父容器
    childFactory.setParentBeanFactory(parentFactory);
    //向子容器parentFactory注册一个bean[address->"上海"]
    childFactory.registerBeanDefinition("address",
            BeanDefinitionBuilder.
                    genericBeanDefinition(String.class).
                    addConstructorArgValue("上海").
                    getBeanDefinition());

    System.out.println("获取bean【userName】：" + childFactory.getBean("userName"));//@1

    System.out.println(Arrays.asList(childFactory.getBeanNamesForType(String.class))); //@2
}
```

上面定义了 2 个容器

父容器：parentFactory，内部定义了一个 String 类型的 bean：userName-> 路人甲 Java

子容器：childFactory，内部也定义了一个 String 类型的 bean：address-> 上海

@1：调用子容器的 getBean 方法，获取名称为 userName 的 bean，userName 这个 bean 是在父容器中定义的，而 getBean 方法是 BeanFactory 接口中定义的，支持容器层次查找，所以 getBean 是可以找到 userName 这个 bean 的

@2：调用子容器的 getBeanNamesForType 方法，获取所有 String 类型的 bean 名称，而 getBeanNamesForType 方法是 ListableBeanFactory 接口中定义的，这个接口中方法不支持层次查找，只会在当前容器中查找，所以这个方法只会返回子容器的 address

我们来运行一下看看效果：

```
获取bean【userName】：路人甲Java
[address]
```

结果和分析的一致。

**那么问题来了：有没有方式解决 ListableBeanFactory 接口不支持层次查找的问题？**

spring 中有个工具类就是解决这个问题的，如下：

```
org.springframework.beans.factory.BeanFactoryUtils
```

这个类中提供了很多静态方法，有很多支持层次查找的方法，源码你们可以去细看一下，名称中包含有`Ancestors`的都是支持层次查找的。

在 test2 方法中加入下面的代码：

```
//层次查找所有符合类型的bean名称
String[] beanNamesForTypeIncludingAncestors = BeanFactoryUtils.beanNamesForTypeIncludingAncestors(childFactory, String.class);
System.out.println(Arrays.asList(beanNamesForTypeIncludingAncestors));

Map<String, String> beansOfTypeIncludingAncestors = BeanFactoryUtils.beansOfTypeIncludingAncestors(childFactory, String.class);
System.out.println(Arrays.asList(beansOfTypeIncludingAncestors));
```

运行输出

```
[address, userName]
[{address=上海, userName=路人甲Java}]
```

查找过程是按照层次查找所有满足条件的 bean。

## 回头看一下 springmvc 父子容器的问题

**问题 1：springmvc 中只使用一个容器是否可以？**

只使用一个容器是可以正常运行的。

**问题 2：那么 springmvc 中为什么需要用到父子容器？**

通常我们使用 springmvc 的时候，采用 3 层结构，controller 层，service 层，dao 层；父容器中会包含 dao 层和 service 层，而子容器中包含的只有 controller 层；这 2 个容器组成了父子容器的关系，controller 层通常会注入 service 层的 bean。

采用父子容器可以避免有些人在 service 层去注入 controller 层的 bean，导致整个依赖层次是比较混乱的。

父容器和子容器的需求也是不一样的，比如父容器中需要有事务的支持，会注入一些支持事务的扩展组件，而子容器中 controller 完全用不到这些，对这些并不关心，子容器中需要注入一下 springmvc 相关的 bean，而这些 bean 父容器中同样是不会用到的，也是不关心一些东西，将这些相互不关心的东西隔开，可以有效的避免一些不必要的错误，而父子容器加载的速度也会快一些。

# 25、@Value【用法、数据来源、动态刷新】

## @Value 的用法

系统中需要连接 db，连接 db 有很多配置信息。

系统中需要发送邮件，发送邮件需要配置邮件服务器的信息。

还有其他的一些配置信息。

我们可以将这些配置信息统一放在一个配置文件中，上线的时候由运维统一修改。

那么系统中如何使用这些配置信息呢，spring 中提供了 @Value 注解来解决这个问题。

通常我们会将配置信息以 key=value 的形式存储在 properties 配置文件中。

通过 @Value("${配置文件中的 key}") 来引用指定的 key 对应的 value。

### @Value 使用步骤

#### 步骤一：使用 @PropertySource 注解引入配置文件

将 @PropertySource 放在类上面，如下

```
@PropertySource({"配置文件路径1","配置文件路径2"...})
```

@PropertySource 注解有个 value 属性，字符串数组类型，可以用来指定多个配置文件的路径。

如：

```
@Component
@PropertySource({"classpath:com/javacode2018/lesson002/demo18/db.properties"})
public class DbConfig {
}
```

#### 步骤二：使用 @Value 注解引用配置文件的值

通过 @Value 引用上面配置文件中的值：

语法

```
@Value("${配置文件中的key:默认值}")
@Value("${配置文件中的key}")
```

如：

```
@Value("${password:123}")
```

上面如果 password 不存在，将 123 作为值

```
@Value("${password}")
```

上面如果 password 不存在，值为 ${password}

假如配置文件如下

```
jdbc.url=jdbc:mysql://localhost:3306/javacode2018?characterEncoding=UTF-8
jdbc.username=javacode
jdbc.password=javacode
```

使用方式如下：

```
@Value("${jdbc.url}")
private String url;

@Value("${jdbc.username}")
private String username;

@Value("${jdbc.password}")
private String password;
```

下面来看案例

#### 案例

##### 来个配置文件 db.properties

```
jdbc.url=jdbc:mysql://localhost:3306/javacode2018?characterEncoding=UTF-8
jdbc.username=javacode
jdbc.password=javacode
```

##### 来个配置类，使用 @PropertySource 引入上面的配置文件

```
package com.javacode2018.lesson002.demo18.test1;

import org.springframework.beans.factory.annotation.Configurable;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.PropertySource;

@Configurable
@ComponentScan
@PropertySource({"classpath:com/javacode2018/lesson002/demo18/db.properties"})
public class MainConfig1 {
}
```

##### 来个类，使用 @Value 来使用配置文件中的信息

```
package com.javacode2018.lesson002.demo18.test1;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class DbConfig {

    @Value("${jdbc.url}")
    private String url;

    @Value("${jdbc.username}")
    private String username;

    @Value("${jdbc.password}")
    private String password;

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Override
    public String toString() {
        return "DbConfig{" +
                "url='" + url + '\'' +
                ", username='" + username + '\'' +
                ", password='" + password + '\'' +
                '}';
    }
}
```

上面重点在于注解 @Value 注解，注意 @Value 注解中的

##### 来个测试用例

```
package com.javacode2018.lesson002.demo18;

import com.javacode2018.lesson002.demo18.test1.DbConfig;
import com.javacode2018.lesson002.demo18.test1.MainConfig1;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class ValueTest {

    @Test
    public void test1() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(MainConfig1.class);
        context.refresh();

        DbConfig dbConfig = context.getBean(DbConfig.class);
        System.out.println(dbConfig);
    }
}
```

##### 运行输出

```
DbConfig{url='jdbc:mysql://localhost:3306/javacode2018?characterEncoding=UTF-8', username='javacode', password='javacode'}
```

上面用起来比较简单，很多用过的人看一眼就懂了，这也是第一个问题，多数人都是 ok 的，下面来看 @Value 中数据来源除了配置文件的方式，是否还有其他方式。

## @Value 数据来源

通常情况下我们 @Value 的数据来源于配置文件，不过，还可以用其他方式，比如我们可以将配置文件的内容放在数据库，这样修改起来更容易一些。

我们需要先了解一下 @Value 中数据来源于 spring 的什么地方。

spring 中有个类

```
org.springframework.core.env.PropertySource
```

可以将其理解为一个配置源，里面包含了 key->value 的配置信息，可以通过这个类中提供的方法获取 key 对应的 value 信息

内部有个方法：

```
public abstract Object getProperty(String name);
```

通过 name 获取对应的配置信息。

系统有个比较重要的接口

```
org.springframework.core.env.Environment
```

用来表示环境配置信息，这个接口有几个方法比较重要

```
String resolvePlaceholders(String text);
MutablePropertySources getPropertySources();
```

resolvePlaceholders 用来解析`${text}`的，@Value 注解最后就是调用这个方法来解析的。

getPropertySources 返回 MutablePropertySources 对象，来看一下这个类

```
public class MutablePropertySources implements PropertySources {

    private final List<PropertySource<?>> propertySourceList = new CopyOnWriteArrayList<>();

}
```

内部包含一个`propertySourceList`列表。

spring 容器中会有一个`Environment`对象，最后会调用这个对象的`resolvePlaceholders`方法解析 @Value。

大家可以捋一下，最终解析 @Value 的过程：

```
1. 将@Value注解的value参数值作为Environment.resolvePlaceholders方法参数进行解析
2. Environment内部会访问MutablePropertySources来解析
3. MutablePropertySources内部有多个PropertySource，此时会遍历PropertySource列表，调用PropertySource.getProperty方法来解析key对应的值
```

通过上面过程，如果我们想改变 @Value 数据的来源，只需要将配置信息包装为 PropertySource 对象，丢到 Environment 中的 MutablePropertySources 内部就可以了。

下面我们就按照这个思路来一个。

来个邮件配置信息类，内部使用 @Value 注入邮件配置信息

```
package com.javacode2018.lesson002.demo18.test2;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * 邮件配置信息
 */
@Component
public class MailConfig {

    @Value("${mail.host}")
    private String host;

    @Value("${mail.username}")
    private String username;

    @Value("${mail.password}")
    private String password;

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Override
    public String toString() {
        return "MailConfig{" +
                "host='" + host + '\'' +
                ", username='" + username + '\'' +
                ", password='" + password + '\'' +
                '}';
    }
}
```

再来个类`DbUtil`，`getMailInfoFromDb`方法模拟从 db 中获取邮件配置信息，存放在 map 中

```
package com.javacode2018.lesson002.demo18.test2;

import java.util.HashMap;
import java.util.Map;

public class DbUtil {
    /**
     * 模拟从db中获取邮件配置信息
     *
     * @return
     */
    public static Map<String, Object> getMailInfoFromDb() {
        Map<String, Object> result = new HashMap<>();
        result.put("mail.host", "smtp.qq.com");
        result.put("mail.username", "路人");
        result.put("mail.password", "123");
        return result;
    }
}
```

来个 spring 配置类

```
package com.javacode2018.lesson002.demo18.test2;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ComponentScan
public class MainConfig2 {
}
```

下面是重点代码

```
@Test
public void test2() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();

    /*下面这段是关键 start*/
    //模拟从db中获取配置信息
    Map<String, Object> mailInfoFromDb = DbUtil.getMailInfoFromDb();
    //将其丢在MapPropertySource中（MapPropertySource类是spring提供的一个类，是PropertySource的子类）
    MapPropertySource mailPropertySource = new MapPropertySource("mail", mailInfoFromDb);
    //将mailPropertySource丢在Environment中的PropertySource列表的第一个中，让优先级最高
    context.getEnvironment().getPropertySources().addFirst(mailPropertySource);
    /*上面这段是关键 end*/

    context.register(MainConfig2.class);
    context.refresh();
    MailConfig mailConfig = context.getBean(MailConfig.class);
    System.out.println(mailConfig);
}
```

注释比较详细，就不详细解释了。

直接运行，看效果

```
MailConfig{host='smtp.qq.com', username='路人', password='123'}
```

有没有感觉很爽，此时你们可以随意修改`DbUtil.getMailInfoFromDb`，具体数据是从 db 中来，来时从 redis 或者其他介质中来，任由大家发挥。

上面重点是下面这段代码，大家需要理解

```
/*下面这段是关键 start*/
//模拟从db中获取配置信息
Map<String, Object> mailInfoFromDb = DbUtil.getMailInfoFromDb();
//将其丢在MapPropertySource中（MapPropertySource类是spring提供的一个类，是PropertySource的子类）
MapPropertySource mailPropertySource = new MapPropertySource("mail", mailInfoFromDb);
//将mailPropertySource丢在Environment中的PropertySource列表的第一个中，让优先级最高
context.getEnvironment().getPropertySources().addFirst(mailPropertySource);
/*上面这段是关键 end*/
```

咱们继续看下一个问题

**如果我们将配置信息放在 db 中，可能我们会通过一个界面来修改这些配置信息，然后保存之后，希望系统在不重启的情况下，让这些值在 spring 容器中立即生效。**

@Value 动态刷新的问题的问题，springboot 中使用 @RefreshScope 实现了。

## 实现 @Value 动态刷新

### 先了解一个知识点

这块需要先讲一个知识点，用到的不是太多，所以很多人估计不太了解，但是非常重要的一个点，我们来看一下。

这个知识点是`自定义bean作用域`，对这块不了解的先看一下这篇文章：[bean 作用域详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933960&idx=1&sn=f4308f8955f87d75963c379c2a0241f4&chksm=88621e76bf159760d404c253fa6716d3ffce4de8df0fc1d0d5dd0cf00a81bc170a30829ee58f&token=1314297026&lang=zh_CN&scene=21#wechat_redirect)

bean 作用域中有个地方没有讲，来看一下 @Scope 这个注解的源码，有个参数是：

```
ScopedProxyMode proxyMode() default ScopedProxyMode.DEFAULT;
```

这个参数的值是个 ScopedProxyMode 类型的枚举，值有下面 4 中

```
public enum ScopedProxyMode {
    DEFAULT,
    NO,
    INTERFACES,
    TARGET_CLASS;
}
```

前面 3 个，不讲了，直接讲最后一个值是干什么的。

当 @Scope 中 proxyMode 为 TARGET_CLASS 的时候，会给当前创建的 bean 通过 cglib 生成一个代理对象，通过这个代理对象来访问目标 bean 对象。

理解起来比较晦涩，还是来看代码吧，容易理解一些，来个自定义的 Scope 案例。

**自定义一个 bean 作用域的注解**

```
package com.javacode2018.lesson002.demo18.test3;

import org.springframework.context.annotation.Scope;
import org.springframework.context.annotation.ScopedProxyMode;

import java.lang.annotation.*;

@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Scope(BeanMyScope.SCOPE_MY) //@1
public @interface MyScope {
    /**
     * @see Scope#proxyMode()
     */
    ScopedProxyMode proxyMode() default ScopedProxyMode.TARGET_CLASS;//@2
}
```

@1：使用了 @Scope 注解，value 为引用了一个常量，值为 my，一会下面可以看到。

@2：注意这个地方，参数名称也是 proxyMode，类型也是 ScopedProxyMode，而 @Scope 注解中有个和这个同样类型的参数，spring 容器解析的时候，会将这个参数的值赋给 @MyScope 注解上面的 @Scope 注解的 proxyMode 参数，所以此处我们设置 proxyMode 值，最后的效果就是直接改变了 @Scope 中 proxyMode 参数的值。此处默认值取的是 ScopedProxyMode.TARGET_CLASS

**@MyScope 注解对应的 Scope 实现如下**

```
package com.javacode2018.lesson002.demo18.test3;

import org.springframework.beans.factory.ObjectFactory;
import org.springframework.beans.factory.config.Scope;
import org.springframework.lang.Nullable;

/**
 * @see MyScope 作用域的实现
 */
public class BeanMyScope implements Scope {

    public static final String SCOPE_MY = "my"; //@1

    @Override
    public Object get(String name, ObjectFactory<?> objectFactory) { 
        System.out.println("BeanMyScope >>>>>>>>> get:" + name); //@2
        return objectFactory.getObject(); //@3
    }

    @Nullable
    @Override
    public Object remove(String name) {
        return null;
    }

    @Override
    public void registerDestructionCallback(String name, Runnable callback) {

    }

    @Nullable
    @Override
    public Object resolveContextualObject(String key) {
        return null;
    }

    @Nullable
    @Override
    public String getConversationId() {
        return null;
    }
}
```

@1：定义了一个常量，作为作用域的值

@2：这个 get 方法是关键，自定义作用域会自动调用这个 get 方法来创建 bean 对象，这个地方输出了一行日志，为了一会方便看效果

@3：通过 objectFactory.getObject() 获取 bean 实例返回。

**下面来创建个类，作用域为上面自定义的作用域**

```
package com.javacode2018.lesson002.demo18.test3;

import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@MyScope //@1 
public class User {

    private String username;

    public User() { 
        System.out.println("---------创建User对象" + this); //@2
        this.username = UUID.randomUUID().toString(); //@3
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

}
```

@1：使用了自定义的作用域 @MyScope

@2：构造函数中输出一行日志

@3：给 username 赋值，通过 uuid 随机生成了一个

**来个 spring 配置类，加载上面 @Compontent 标注的组件**

```
package com.javacode2018.lesson002.demo18.test3;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@ComponentScan
@Configuration
public class MainConfig3 {
}
```

**下面重点来了，测试用例**

```
@Test
public void test3() throws InterruptedException {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    //将自定义作用域注册到spring容器中
    context.getBeanFactory().registerScope(BeanMyScope.SCOPE_MY, new BeanMyScope());//@1
    context.register(MainConfig3.class);
    context.refresh();

    System.out.println("从容器中获取User对象");
    User user = context.getBean(User.class); //@2
    System.out.println("user对象的class为：" + user.getClass()); //@3

    System.out.println("多次调用user的getUsername感受一下效果\n");
    for (int i = 1; i <= 3; i++) {
        System.out.println(String.format("********\n第%d次开始调用getUsername", i));
        System.out.println(user.getUsername());
        System.out.println(String.format("第%d次调用getUsername结束\n********\n", i));
    }
}
```

@1：将自定义作用域注册到 spring 容器中

@2：从容器中获取 User 对应的 bean

@3：输出这个 bean 对应的 class，一会认真看一下，这个类型是不是 User 类型的

代码后面又搞了 3 次循环，调用 user 的 getUsername 方法，并且方法前后分别输出了一行日志。

**见证奇迹的时候到了，运行输出**

```
从容器中获取User对象
user对象的class为：class com.javacode2018.lesson002.demo18.test3.User$$EnhancerBySpringCGLIB$$80233127
多次调用user的getUsername感受一下效果

********
第1次开始调用getUsername
BeanMyScope >>>>>>>>> get:scopedTarget.user
---------创建User对象com.javacode2018.lesson002.demo18.test3.User@6a370f4
7b41aa80-7569-4072-9d40-ec9bfb92f438
第1次调用getUsername结束
********

********
第2次开始调用getUsername
BeanMyScope >>>>>>>>> get:scopedTarget.user
---------创建User对象com.javacode2018.lesson002.demo18.test3.User@1613674b
01d67154-95f6-44bb-93ab-05a34abdf51f
第2次调用getUsername结束
********

********
第3次开始调用getUsername
BeanMyScope >>>>>>>>> get:scopedTarget.user
---------创建User对象com.javacode2018.lesson002.demo18.test3.User@27ff5d15
76d0e86f-8331-4303-aac7-4acce0b258b8
第3次调用getUsername结束
********
```

从输出的前 2 行可以看出：

1. 调用 context.getBean(User.class) 从容器中获取 bean 的时候，此时并没有调用 User 的构造函数去创建 User 对象
2. 第二行输出的类型可以看出，getBean 返回的 user 对象是一个 cglib 代理对象。

**后面的日志输出可以看出，每次调用 user.getUsername 方法的时候，内部自动调用了 BeanMyScope#get 方法和 User 的构造函数。**

**通过上面的案例可以看出，当自定义的 Scope 中 proxyMode=ScopedProxyMode.TARGET_CLASS 的时候，会给这个 bean 创建一个代理对象，调用代理对象的任何方法，都会调用这个自定义的作用域实现类（上面的 BeanMyScope）中 get 方法来重新来获取这个 bean 对象。**

### 动态刷新 @Value 具体实现

那么我们可以利用上面讲解的这种特性来实现 @Value 的动态刷新，可以实现一个自定义的 Scope，这个自定义的 Scope 支持 @Value 注解自动刷新，需要使用 @Value 注解自动刷新的类上面可以标注这个自定义的注解，当配置修改的时候，调用这些 bean 的任意方法的时候，就让 spring 重启初始化一下这个 bean，这个思路就可以实现了，下面我们来写代码。

#### 先来自定义一个 Scope：RefreshScope

```
package com.javacode2018.lesson002.demo18.test4;

import org.springframework.context.annotation.Scope;
import org.springframework.context.annotation.ScopedProxyMode;

import java.lang.annotation.*;

@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Scope(BeanRefreshScope.SCOPE_REFRESH)
@Documented
public @interface RefreshScope {
    ScopedProxyMode proxyMode() default ScopedProxyMode.TARGET_CLASS; //@1
}
```

要求标注 @RefreshScope 注解的类支持动态刷新 @Value 的配置

@1：这个地方是个关键，使用的是 ScopedProxyMode.TARGET_CLASS

#### 这个自定义 Scope 对应的解析类

下面类中有几个无关的方法去掉了，可以忽略

```
package com.javacode2018.lesson002.demo18.test4;


import org.springframework.beans.factory.ObjectFactory;
import org.springframework.beans.factory.config.Scope;
import org.springframework.lang.Nullable;

import java.util.concurrent.ConcurrentHashMap;

public class BeanRefreshScope implements Scope {

    public static final String SCOPE_REFRESH = "refresh";

    private static final BeanRefreshScope INSTANCE = new BeanRefreshScope();

    //来个map用来缓存bean
    private ConcurrentHashMap<String, Object> beanMap = new ConcurrentHashMap<>(); //@1

    private BeanRefreshScope() {
    }

    public static BeanRefreshScope getInstance() {
        return INSTANCE;
    }

    /**
     * 清理当前
     */
    public static void clean() {
        INSTANCE.beanMap.clear();
    }

    @Override
    public Object get(String name, ObjectFactory<?> objectFactory) {
        Object bean = beanMap.get(name);
        if (bean == null) {
            bean = objectFactory.getObject();
            beanMap.put(name, bean);
        }
        return bean;
    }

}
```

上面的 get 方法会先从 beanMap 中获取，获取不到会调用 objectFactory 的 getObject 让 spring 创建 bean 的实例，然后丢到 beanMap 中

上面的 clean 方法用来清理 beanMap 中当前已缓存的所有 bean

#### 来个邮件配置类，使用 @Value 注解注入配置，这个 bean 作用域为自定义的 @RefreshScope

```
package com.javacode2018.lesson002.demo18.test4;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * 邮件配置信息
 */
@Component
@RefreshScope //@1
public class MailConfig {

    @Value("${mail.username}") //@2
    private String username;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    @Override
    public String toString() {
        return "MailConfig{" +
                "username='" + username + '\'' +
                '}';
    }
}
```

@1：使用了自定义的作用域 @RefreshScope

@2：通过 @Value 注入 mail.username 对一个的值

重写了 toString 方法，一会测试时候可以看效果。

#### 再来个普通的 bean，内部会注入 MailConfig

```
package com.javacode2018.lesson002.demo18.test4;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class MailService {
    @Autowired
    private MailConfig mailConfig;

    @Override
    public String toString() {
        return "MailService{" +
                "mailConfig=" + mailConfig +
                '}';
    }
}
```

代码比较简单，重写了 toString 方法，一会测试时候可以看效果。

#### 来个类，用来从 db 中获取邮件配置信息

```
package com.javacode2018.lesson002.demo18.test4;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class DbUtil {
    /**
     * 模拟从db中获取邮件配置信息
     *
     * @return
     */
    public static Map<String, Object> getMailInfoFromDb() {
        Map<String, Object> result = new HashMap<>();
        result.put("mail.username", UUID.randomUUID().toString());
        return result;
    }
}
```

#### 来个 spring 配置类，扫描加载上面的组件

```
package com.javacode2018.lesson002.demo18.test4;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ComponentScan
public class MainConfig4 {
}
```

#### 来个工具类

内部有 2 个方法，如下：

```
package com.javacode2018.lesson002.demo18.test4;

import org.springframework.context.support.AbstractApplicationContext;
import org.springframework.core.env.MapPropertySource;

import java.util.Map;

public class RefreshConfigUtil {
    /**
     * 模拟改变数据库中都配置信息
     */
    public static void updateDbConfig(AbstractApplicationContext context) {
        //更新context中的mailPropertySource配置信息
        refreshMailPropertySource(context);

        //清空BeanRefreshScope中所有bean的缓存
        BeanRefreshScope.getInstance().clean();
    }

    public static void refreshMailPropertySource(AbstractApplicationContext context) {
        Map<String, Object> mailInfoFromDb = DbUtil.getMailInfoFromDb();
        //将其丢在MapPropertySource中（MapPropertySource类是spring提供的一个类，是PropertySource的子类）
        MapPropertySource mailPropertySource = new MapPropertySource("mail", mailInfoFromDb);
        context.getEnvironment().getPropertySources().addFirst(mailPropertySource);
    }

}
```

updateDbConfig 方法模拟修改 db 中配置的时候需要调用的方法，方法中 2 行代码，第一行代码调用 refreshMailPropertySource 方法修改容器中邮件的配置信息

BeanRefreshScope.getInstance().clean() 用来清除 BeanRefreshScope 中所有已经缓存的 bean，那么调用 bean 的任意方法的时候，会重新出发 spring 容器来创建 bean，spring 容器重新创建 bean 的时候，会重新解析 @Value 的信息，此时容器中的邮件配置信息是新的，所以 @Value 注入的信息也是新的。

来个测试用例

```
@Test
public void test4() throws InterruptedException {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.getBeanFactory().registerScope(BeanRefreshScope.SCOPE_REFRESH, BeanRefreshScope.getInstance());
    context.register(MainConfig4.class);
    //刷新mail的配置到Environment
    RefreshConfigUtil.refreshMailPropertySource(context);
    context.refresh();

    MailService mailService = context.getBean(MailService.class);
    System.out.println("配置未更新的情况下,输出3次");
    for (int i = 0; i < 3; i++) { //@1
        System.out.println(mailService);
        TimeUnit.MILLISECONDS.sleep(200);
    }

    System.out.println("模拟3次更新配置效果");
    for (int i = 0; i < 3; i++) { //@2
        RefreshConfigUtil.updateDbConfig(context); //@3
        System.out.println(mailService);
        TimeUnit.MILLISECONDS.sleep(200);
    }
}
```

@1：循环 3 次，输出 mailService 的信息

@2：循环 3 次，内部先通过 @3 来模拟更新 db 中配置信息，然后在输出 mailService 信息

#### 见证奇迹的时刻，来看效果

```
配置未更新的情况下,输出3次
MailService{mailConfig=MailConfig{username='df321543-8ca7-4563-993a-bd64cbf50d53'}}
MailService{mailConfig=MailConfig{username='df321543-8ca7-4563-993a-bd64cbf50d53'}}
MailService{mailConfig=MailConfig{username='df321543-8ca7-4563-993a-bd64cbf50d53'}}
模拟3次更新配置效果
MailService{mailConfig=MailConfig{username='6bab8cea-9f4f-497d-a23a-92f15d0d6e34'}}
MailService{mailConfig=MailConfig{username='581bf395-f6b8-4b87-84e6-83d3c7342ca2'}}
MailService{mailConfig=MailConfig{username='db337f54-20b0-4726-9e55-328530af6999'}}
```

上面 MailService 输出了 6 次，前 3 次 username 的值都是一样的，后面 3 次 username 的值不一样了，说明修改配置起效了。

### 小结

**动态 @Value 实现的关键是 @Scope 中 proxyMode 参数，值为 ScopedProxyMode.DEFAULT，会生成一个代理，通过这个代理来实现 @Value 动态刷新的效果，这个地方是关键。**

**有兴趣的可以去看一下 springboot 中的 @RefreshScope 注解源码，和我们上面自定义的 @RefreshScope 类似，实现原理类似的。**

# 26、国际化详解

面试不易，控场情况下，感觉少要了 1 万！

**所有文章以系列的方式呈现，带领大家成为 java 高手，目前已出：java 高并发系列、mysql 高手系列、Maven 高手系列、mybatis 系列、spring 系列，****需要 PDF 版本的，加我微信 itsoku 获取****!**

**前两天去一个电商公司面试：**

**面试官：Spring 中国际化这块的东西用过么？可以介绍一下么？**

**我：spring 中对国际化支持挺好的，比较简单，只需要按照语言配置几个 properties 文件，然后主要注册一个国际化的相关的 bean，同时需指定一下配置文件的位置，基本上就可以了**

**面试官：那如果配置文件内容有变化？你们怎么解决的？**

**我：这块啊，spring 国际化这块有个实现类，可以检测到配置文件的变化，就可以解决你这个问题**

**面试官：那我们是否可以将这些国际化的配置丢到 db 中去管理呢？**

**我：这个地方我没有搞过，基本上我们这边都是将国际化的配置文件放在项目中的 properties 文件中；不过以我对 spring 的理解，spring 扩展方面是非常优秀的，应该是可以这么做的，自己去实现一下 spring 国际化相关接口就可以了。**

**面试官：工资期望多少？**

**我：2 万**

**面试官：恭喜你，下周来上班！**

为了方便大家，准备把这块知识细化一下，方便大家面试及使用。

## 本次问题

1. Spring 中国际化怎么用？
2. 国际化如何处理资源文件变化的问题？
3. 国际化资源配置放在 db 中如何实现？

## 先说一下什么是国际化

**简单理解，就是对于不同的语言，做出不同的响应。**

比如页面中有个填写用户信息的表单，有个姓名的输入框

浏览器中可以选择语言

选中文的时候会显示：

```
姓名：一个输入框
```

选英文的时候会显示：

```
Full name：一个输入框
```

国际化就是做这个事情的，根据不同的语言显示不同的信息。

所以需要支持国际化，得先知道选择的是哪种地区的哪种语言，java 中使用`java.util.Locale`来表示地区语言这个对象，内部包含了国家和语言的信息。

Locale 中有个比较常用的构造方法

```
public Locale(String language, String country) {
    this(language, country, "");
}
```

2 个参数：

language：语言

country：国家

语言和国家这两个参数的值不是乱写的，国际上有统一的标准：

比如 language 的值：zh 表示中文，en 表示英语，而中文可能很多地区在用，比如大陆地区可以用：CN，新加坡用：SG；英语也是有很多国家用的，GB 表示英国，CA 表示加拿大

国家语言简写格式：language-country，如：zh-CN（中文【中国】），zh-SG（中文【新加坡】），en-GB（英语【英国】），

en-CA（英语【加拿大】）。

还有很多，这里就不细说了，国家语言编码给大家提供一个表格：http://www.itsoku.com/article/282

**Locale 类中已经创建好了很多常用的 Locale 对象，直接可以拿过来用**，随便列几个看一下：

```
static public final Locale SIMPLIFIED_CHINESE = createConstant("zh", "CN"); //zh_CN
static public final Locale UK = createConstant("en", "GB"); //en_GB
static public final Locale US = createConstant("en", "US"); //en_US
static public final Locale CANADA = createConstant("en", "CA"); //en_CA
```

再回头看前面的问题：页面中显示姓名对应的标签，需要我们根据一个 key 及 Locale 信息来获取对应的国际化信息，spring 中提供了这部分的实现，下面我们来看详情。

## Spring 中国际化怎么用？

### MessageSource 接口

spring 中国际化是通过 MessageSource 这个接口来支持的

```
org.springframework.context.MessageSource
```

内部有 3 个常用的方法用来获取国际化信息，来看一下

```
public interface MessageSource {

    /**
     * 获取国际化信息
     * @param code 表示国际化资源中的属性名；
     * @param args用于传递格式化串占位符所用的运行参数；
     * @param defaultMessage 当在资源找不到对应属性名时，返回defaultMessage参数所指定的默认信息；
     * @param locale 表示本地化对象
     */
    @Nullable
    String getMessage(String code, @Nullable Object[] args, @Nullable String defaultMessage, Locale locale);

    /**
     * 与上面的方法类似，只不过在找不到资源中对应的属性名时，直接抛出NoSuchMessageException异常
     */
    String getMessage(String code, @Nullable Object[] args, Locale locale) throws NoSuchMessageException;

    /**
     * @param MessageSourceResolvable 将属性名、参数数组以及默认信息封装起来，它的功能和第一个方法相同
     */
    String getMessage(MessageSourceResolvable resolvable, Locale locale) throws NoSuchMessageException;

}
```

### 常见 3 个实现类

#### ResourceBundleMessageSource

这个是基于 Java 的 ResourceBundle 基础类实现，允许仅通过资源名加载国际化资源

#### ReloadableResourceBundleMessageSource

这个功能和第一个类的功能类似，多了定时刷新功能，允许在不重启系统的情况下，更新资源的信息

#### StaticMessageSource

它允许通过编程的方式提供国际化信息，一会我们可以通过这个来实现 db 中存储国际化信息的功能。

## Spring 中使用国际化的 3 个步骤

通常我们使用 spring 的时候，都会使用带有 ApplicationContext 字样的 spring 容器，这些容器一般是继承了 AbstractApplicationContext 接口，而这个接口实现了上面说的国际化接口 MessageSource，所以通常我们用到的 ApplicationContext 类型的容器都自带了国际化的功能。

通常我们在 ApplicationContext 类型的容器中使用国际化 3 个步骤

**步骤一：创建国际化文件**

**步骤二：向容器中注册一个 MessageSource 类型的 bean，bean 名称必须为：messageSource**

**步骤三：调用 AbstractApplicationContext 中的 getMessage 来获取国际化信息，其内部将交给第二步中注册的 messageSource 名称的 bean 进行处理**

### 来个案例感受一下

#### 创建国际化文件

**国际化文件命名格式：名称_语言_地区. properties**

我们来 3 个文件，文件都放在下面这个目录中

```
com/javacode2018/lesson002/demo19/
```

##### message.properties

```
name=您的姓名
personal_introduction=默认个人介绍:{0},{1}
```

这个文件名称没有指定 Local 信息，当系统找不到的时候会使用这个默认的

##### message_zh_CN.properties：中文【中国】

```
name=姓名
personal_introduction=个人介绍:{0},{1},{0}
```

##### message_en_GB.properties：英文【英国】

```
name=Full name
personal_introduction=personal_introduction:{0},{1},{0}
```

#### spring 中注册国际化的 bean

注意必须是 MessageSource 类型的，bean 名称必须为 messageSource，此处我们就使用 ResourceBundleMessageSource 这个类

```
package com.javacode2018.lesson002.test19.demo1;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ResourceBundleMessageSource;

@Configuration
public class MainConfig1 {
    @Bean
    public ResourceBundleMessageSource messageSource() {
        ResourceBundleMessageSource result = new ResourceBundleMessageSource();
        //可以指定国际化化配置文件的位置，格式：路径/文件名称,注意不包含【语言_国家.properties】含这部分
        result.setBasenames("com/javacode2018/lesson002/demo19/message"); //@1
        return result;
    }
}
```

@1：这个地方的写法需要注意，可以指定国际化化配置文件的位置，格式：路径 / 文件名称, 注意不包含**【语言_国家. properties】**含这部分

#### 来个测试用例

```
package com.javacode2018.lesson002.test19;

import com.javacode2018.lesson002.test19.demo1.MainConfig1;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import java.util.Locale;

public class MessageSourceTest {

    @Test
    public void test1() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(MainConfig1.class);
        context.refresh();
        //未指定Locale，此时系统会取默认的locale对象，本地默认的值中文【中国】，即：zh_CN
        System.out.println(context.getMessage("name", null, null));
        System.out.println(context.getMessage("name", null, Locale.CHINA)); //CHINA对应：zh_CN
        System.out.println(context.getMessage("name", null, Locale.UK)); //UK对应en_GB
    }
}
```

#### 运行输出

```
您的姓名
您的姓名
Full name
```

第一行未指定 Locale，此时系统会取默认的 locale 对象，本地默认的值中文【中国】，即：zh_CN，所以会获取到`message_zh_CN.properties`中的内容。

后面 2 行，都指定了 Locale 对象，找到对应的国际化文件，取值。

#### 动态参数使用

注意配置文件中的`personal_introduction`，个人介绍，比较特别，包含了`{0},{1},{0}`这样一部分内容，这个就是动态参数，调用`getMessage`的时候，通过第二个参数传递过去，来看一下用法：

```
@Test
public void test2() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig1.class);
    context.refresh();
    //未指定Locale，此时系统会取默认的，本地电脑默认的值中文【中国】，即：zh_CN
    System.out.println(context.getMessage("personal_introduction", new String[]{"spring高手", "java高手"}, Locale.CHINA)); //CHINA对应：zh_CN
    System.out.println(context.getMessage("personal_introduction", new String[]{"spring", "java"}, Locale.UK)); //UK对应en_GB
}
```

#### 运行输出

```
默认个人介绍:spring高手,java高手
personal_introduction:spring,java,spring
```

## 监控国际化文件的变化

用`ReloadableResourceBundleMessageSource`这个类，功能和上面案例中的`ResourceBundleMessageSource`类似，不过多了个可以监控国际化资源文件变化的功能，有个方法用来设置缓存时间：

```
public void setCacheMillis(long cacheMillis)
```

-1：表示永远缓存

0：每次获取国际化信息的时候，都会重新读取国际化文件

大于 0：上次读取配置文件的时间距离当前时间超过了这个时间，重新读取国际化文件

还有个按秒设置缓存时间的方法`setCacheSeconds`，和`setCacheMillis`类似

下面我们来案例

```
package com.javacode2018.lesson002.test19.demo2;

import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ReloadableResourceBundleMessageSource;

@Configuration
public class MainConfig2 {
    @Bean
    public MessageSource messageSource() {
        ReloadableResourceBundleMessageSource result = new ReloadableResourceBundleMessageSource();
        result.setBasenames("com/javacode2018/lesson002/demo19/message");
        //设置缓存时间1000毫秒
        result.setCacheMillis(1000);
        return result;
    }
}
```

message_zh_CN.properties 中新增一行内容

```
address=上海
```

对应的测试用例

```
@Test
public void test3() throws InterruptedException {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig2.class);
    context.refresh();
    //输出2次
    for (int i = 0; i < 2; i++) {
        System.out.println(context.getMessage("address", null, Locale.CHINA));
        TimeUnit.SECONDS.sleep(5);
    }
}
```

上面有个循环，当第一次输出之后，修改一下`message_zh_CN.properties`中的 address 为`上海松江`，最后运行结果如下：

```
上海
上海松江
```

**使用注意：线上环境，缓存时间最好设置大一点，性能会好一些。**

## 国际化信息存在 db 中

上面我们介绍了一个类：`StaticMessageSource`，这个类它允许通过编程的方式提供国际化信息，我们通过这个类来实现从 db 中获取国际化信息的功能。

这个类中有 2 个方法比较重要：

```
public void addMessage(String code, Locale locale, String msg);
public void addMessages(Map<String, String> messages, Locale locale);
```

通过这两个方法来添加国际化配置信息。

下面来看案例

自定义一个 StaticMessageSource 类

```
package com.javacode2018.lesson002.test19.demo3;

import org.springframework.beans.factory.InitializingBean;
import org.springframework.context.support.StaticMessageSource;

import java.util.Locale;

public class MessageSourceFromDb extends StaticMessageSource implements InitializingBean {
    @Override
    public void afterPropertiesSet() throws Exception {
        //此处我们在当前bean初始化之后，模拟从db中获取国际化信息，然后调用addMessage来配置国际化信息
        this.addMessage("desc", Locale.CHINA, "我是从db来的信息");
        this.addMessage("desc", Locale.UK, "MessageSource From Db");
    }
}
```

上面的类实现了 spring 的 InitializingBean 接口，重写了接口中干掉 afterPropertiesSet 方法，这个方法会在当前 bean 初始化之后调用，在这个方法中模拟从 db 中获取国际化信息，然后调用 addMessage 来配置国际化信息

来个 spring 配置类，将 MessageSourceFromDb 注册到 spring 容器

```
package com.javacode2018.lesson002.test19.demo3;

import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MainConfig3 {
    @Bean
    public MessageSource messageSource(){
        return new MessageSourceFromDb();
    }
}
```

上测试用例

```
@Test
public void test4() throws InterruptedException {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig3.class);
    context.refresh();
    System.out.println(context.getMessage("desc", null, Locale.CHINA));
    System.out.println(context.getMessage("desc", null, Locale.UK));
}
```

运行输出

```
我是从db来的信息
MessageSource From Db
```

## bean 名称为什么必须是 messageSource

上面我容器启动的时候会调用`refresh`方法，过程如下：

```
org.springframework.context.support.AbstractApplicationContext#refresh
内部会调用
org.springframework.context.support.AbstractApplicationContext#initMessageSource
这个方法用来初始化MessageSource,方法内部会查找当前容器中是否有messageSource名称的bean，如果有就将其作为处理国际化的对象
如果没有找到，此时会注册一个名称为messageSource的MessageSource
```

## 自定义 bean 中使用国际化

自定义的 bean 如果想使用国际化，比较简单，只需实现下面这个接口，spring 容器会自动调用这个方法，将`MessageSource`注入，然后我们就可以使用`MessageSource`获取国际化信息了。

```
public interface MessageSourceAware extends Aware {
    void setMessageSource(MessageSource messageSource);
}
```

## 总结 

**本文介绍了国际化的使用，涉及到了 java 中的 Locale 类，这个类用来表示语言国家信息，获取国际化信息的时候需要携带这个参数，spring 中通过`MessageSource`接口来支持国际化的功能，有 3 个常用的实现类需要了解，`StaticMessageSource`支持硬编码的方式配置国际化信息。**

**如果需要 spring 支撑国际化，需要注册一个 bean 名称为 messageSource 的 MessageSource，这个一定要注意。**

# 27篇：spring事件机制详解

## 为什么需要使用时间这种模式？

先来看一个业务场景：

产品经理：路人，这两天你帮我实现一个注册的功能

我：注册功能比较简单，将用户信息入库就可以了，伪代码如下：

```
public void registerUser(UserModel user){
    //插入用户信息到db，完成注册
    this.insertUser(user);
}
```

过了几天，产品经理：路人，注册成功之后，给用户发送一封注册成功的邮件

我：修改了一下上面注册代码，如下：

```
public void registerUser(UserModel user){
    //插入用户信息到db，完成注册
    this.insertUser(user);
    //发送邮件
    this.sendEmailToUser(user);
}
```

由于修改了注册接口，所以所有调用这个方法的地方都需要重新测试一遍，让测试的兄弟们帮忙跑了一遍。

又过了几天，产品经理：路人，注册成功之后，给用户发一下优惠券

我：好的，又调整了一下代码

```
public void registerUser(UserModel user){
    //插入用户信息到db，完成注册
    this.insertUser(user);
    //发送邮件
    this.sendEmailToUser(user);
    //发送优惠券
    this.sendCouponToUser(user);
}
```

我：测试的兄弟们，辛苦一下大家，注册接口又修改了，帮忙再过一遍。

过了一段时间，公司效益太好，产品经理：路人，注册的时候，取消给用户发送优惠券的功能。

我：又跑去调整了一下上面代码，将发送优惠券的功能干掉了，如下

```
public void registerUser(UserModel user){
    //插入用户信息到db，完成注册
    this.insertUser(user);
    //发送邮件
    this.sendEmailToUser(user);
}
```

由于调整了代码，而注册功能又属于核心业务，所以需要让测试再次帮忙过一遍，又要麻烦测试来一遍了。

突然有一天，产品经理：路人，注册接口怎么这么慢啊，并且还经常失败？你这让公司要损失多少用户啊

我：赶紧跑去查看了一下运行日志，发现注册的时候给用户发送邮件不稳定，依赖于第三方邮件服务器，耗时比较长，并且容易失败。

跑去给产品经理说：由于邮件服务器不稳定的原因，导致注册不稳定。

产品经理：邮件你可以不发，但是你得确保注册功能必须可以用啊。

我想了想，将上面代码改成了下面这样，发送邮件放在了子线程中执行：

```
public void registerUser(UserModel user){
    //插入用户信息到db，完成注册
    this.insertUser(user);
    //发送邮件，放在子线程中执行，邮件的发送结果对注册逻辑不会有干扰作用
    new Thread(()->{
        this.sendEmailToUser(user);
    }).start();
}
```

又过了几天，产品经理又跑来了说：路人，最近效益不好，需要刺激用户消费，注册的时候继续发送优惠券。

我：倒，这是玩我么，反反复复让我调整注册的代码，让我改还好，让测试也反反复复来回搞，这是要玩死我们啊。

花了点时间，好好复盘整理了一下：发现问题不在于产品经理，从业务上来看，产品提的这些需求都是需求合理的，而结果代码反复调整、测试反复测试，以及一些次要的功能导致注册接口不稳定，这些问题归根到底，主要还是我的设计不合理导致的，将注册功能中的一些次要的功能耦合到注册的方法中了，并且这些功能可能会经常调整，导致了注册接口的不稳定性。

其实上面代码可以这么做：

找3个人：注册器、路人A、路人B。

注册器：负责将用户信息落库，落库成功之后，喊一声：用户XXX注册成功了。

路人A和路人B，竖起耳朵，当听到有人喊：XXX注册成功 的声音之后，立即行动做出下面反应：

路人A：负责给XXX发送一封注册邮件

路人B：负责给XXX发送优惠券

我们来看一下：

注册器只负责将用户信息落库，及广播一条用户注册成功的消息。

A和B相当于一个监听者，只负责监听用户注册成功的消息，当听到有这个消息产生的时候，A和B就去做自己的事情。

这里面注册器是感知不到A/B存在的，A和B也不用感知注册器的存在，A/B只用关注是否有人广播：`XXX注册成功了`的消息，当AB听到有人广播注册成功的消息，他们才做出反应，其他时间闲着休息。

这种方式就非常好：

当不想给用户发送优惠券的时候，只需要将B去掉就行了，此时基本上也不用测试，注册一下B的代码就行了。

若注册成功之后需要更多业务，比如还需要给用户增加积分，只需新增一个监听者C，监听到注册成功消息后，负责给用户添加积分，此时根本不用去调整注册的代码，开发者和测试人员只需要确保监听者C中的正确性就可以了。

上面这种模式就是事件模式。

## 事件模式中的几个概念

**事件源**：事件的触发者，比如上面的注册器就是事件源。

**事件**：描述发生了什么事情的对象，比如上面的：xxx注册成功的事件

**事件监听器**：监听到事件发生的时候，做一些处理，比如上面的：路人A、路人B

## 下面我们使用事件模式实现用户注册的业务

我们先来定义和事件相关的几个类。

### 事件对象

> 表示所有事件的父类，内部有个source字段，表示事件源；我们自定义的事件需要继承这个类。

```
package com.javacode2018.lesson003.demo1.test0.event;

/**
 * 事件对象
 */
public abstract class AbstractEvent {

    //事件源
    protected Object source;

    public AbstractEvent(Object source) {
        this.source = source;
    }

    public Object getSource() {
        return source;
    }

    public void setSource(Object source) {
        this.source = source;
    }
}
```

### 事件监听器

> 我们使用一个接口来表示事件监听器，是个泛型接口，后面的类型`E`表示当前监听器需要监听的事件类型，此接口中只有一个方法，用来实现处理事件的业务；其定义的监听器需要实现这个接口。

```
package com.javacode2018.lesson003.demo1.test0.event;

/**
 * 事件监听器
 *
 * @param <E> 当前监听器感兴趣的事件类型
 */
public interface EventListener<E extends AbstractEvent> {
    /**
     * 此方法负责处理事件
     *
     * @param event 要响应的事件对象
     */
    void onEvent(E event);
}
```

### 事件广播器

> - 负责事件监听器的管理（注册监听器&移除监听器，将事件和监听器关联起来）
> - 负责事件的广播（将事件广播给所有的监听器，对该事件感兴趣的监听器会处理该事件）

```
package com.javacode2018.lesson003.demo1.test0.event;

/**
 * 事件广播器：
 * 1.负责事件监听器的管理（注册监听器&移除监听器，将事件和监听器关联起来）
 * 2.负责事件的广播（将事件广播给所有的监听器，对该事件感兴趣的监听器会处理该事件）
 */
public interface EventMulticaster {

    /**
     * 广播事件给所有的监听器，对该事件感兴趣的监听器会处理该事件
     *
     * @param event
     */
    void multicastEvent(AbstractEvent event);

    /**
     * 添加一个事件监听器（监听器中包含了监听器中能够处理的事件）
     *
     * @param listener 需要添加监听器
     */
    void addEventListener(EventListener<?> listener);


    /**
     * 将事件监听器移除
     *
     * @param listener 需要移除的监听器
     */
    void removeEventListener(EventListener<?> listener);
}
```

### 事件广播默认实现

```
package com.javacode2018.lesson003.demo1.test0.event;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 事件广播器简单实现
 */
public class SimpleEventMulticaster implements EventMulticaster {

    private Map<Class<?>, List<EventListener>> eventObjectEventListenerMap = new ConcurrentHashMap<>();

    @Override
    public void multicastEvent(AbstractEvent event) {
        List<EventListener> eventListeners = this.eventObjectEventListenerMap.get(event.getClass());
        if (eventListeners != null) {
            for (EventListener eventListener : eventListeners) {
                eventListener.onEvent(event);
            }
        }
    }

    @Override
    public void addEventListener(EventListener<?> listener) {
        Class<?> eventType = this.getEventType(listener);
        List<EventListener> eventListeners = this.eventObjectEventListenerMap.get(eventType);
        if (eventListeners == null) {
            eventListeners = new ArrayList<>();
            this.eventObjectEventListenerMap.put(eventType, eventListeners);
        }
        eventListeners.add(listener);
    }

    @Override
    public void removeEventListener(EventListener<?> listener) {
        Class<?> eventType = this.getEventType(listener);
        List<EventListener> eventListeners = this.eventObjectEventListenerMap.get(eventType);
        if (eventListeners != null) {
            eventListeners.remove(listener);
        }
    }

    /**
     * 获取事件监听器需要监听的事件类型
     *
     * @param listener
     * @return
     */
    protected Class<?> getEventType(EventListener listener) {
        ParameterizedType parameterizedType = (ParameterizedType) listener.getClass().getGenericInterfaces()[0];
        Type eventType = parameterizedType.getActualTypeArguments()[0];
        return (Class<?>) eventType;
    }

}
```

**上面3个类支撑了整个时间模型，下面我们使用上面三个类来实现注册的功能，目标是：高内聚低耦合，让注册逻辑方便扩展。**

### 自定义用户注册成功事件类

继承了`AbstractEvent`类

```
package com.javacode2018.lesson003.demo1.test0.userregister;

import com.javacode2018.lesson003.demo1.test0.event.AbstractEvent;

/**
 * 用户注册成功事件
 */
public class UserRegisterSuccessEvent extends AbstractEvent {
    //用户名
    private String userName;

    /**
     * 创建用户注册成功事件对象
     *
     * @param source   事件源
     * @param userName 当前注册的用户名
     */
    public UserRegisterSuccessEvent(Object source, String userName) {
        super(source);
        this.userName = userName;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }
}
```

### 用户注册服务

> 负责实现用户注册逻辑

```
package com.javacode2018.lesson003.demo1.test0.userregister;

import com.javacode2018.lesson003.demo1.test0.event.EventMulticaster;

/**
 * 用户注册服务
 */
public class UserRegisterService {
    //事件发布者
    private EventMulticaster eventMulticaster; //@0

    /**
     * 注册用户
     *
     * @param userName 用户名
     */
    public void registerUser(String userName) { //@1
        //用户注册(将用户信息入库等操作)
        System.out.println(String.format("用户【%s】注册成功", userName)); //@2
        //广播事件
        this.eventMulticaster.multicastEvent(new UserRegisterSuccessEvent(this, userName)); //@3
    }

    public EventMulticaster getEventMulticaster() {
        return eventMulticaster;
    }

    public void setEventMulticaster(EventMulticaster eventMulticaster) {
        this.eventMulticaster = eventMulticaster;
    }
}
```

> @0：事件发布者
>
> @1：registerUser这个方法负责用户注册，内部主要做了2个事情
>
> @2：模拟将用户信息落库
>
> @3：使用事件发布者eventPublisher发布用户注册成功的消息:

### 下面我们使用spring来将上面的对象组装起来

```
package com.javacode2018.lesson003.demo1.test0.userregister;

import com.javacode2018.lesson003.demo1.test0.event.EventListener;
import com.javacode2018.lesson003.demo1.test0.event.EventMulticaster;
import com.javacode2018.lesson003.demo1.test0.event.SimpleEventMulticaster;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
@ComponentScan
public class MainConfig0 {

    /**
     * 注册一个bean：事件发布者
     *
     * @param eventListeners
     * @return
     */
    @Bean
    @Autowired(required = false)
    public EventMulticaster eventMulticaster(List<EventListener> eventListeners) { //@1
        EventMulticaster eventPublisher = new SimpleEventMulticaster();
        if (eventListeners != null) {
            eventListeners.forEach(eventPublisher::addEventListener);
        }
        return eventPublisher;
    }

    /**
     * 注册一个bean：用户注册服务
     *
     * @param eventMulticaster
     * @return
     */
    @Bean
    public UserRegisterService userRegisterService(EventMulticaster eventMulticaster) { //@2
        UserRegisterService userRegisterService = new UserRegisterService();
        userRegisterService.setEventMulticaster(eventMulticaster);
        return userRegisterService;
    }
}
```

> 上面有2个方法，负责向spring容器中注册2个bean。
>
> @1：向spring容器中注册了一个bean：`事件发布者`，方法传入了`EventListener`类型的List，这个地方会将容器中所有的事件监听器注入进来，丢到`EventMulticaster`中。
>
> @2：向spring容器中注册了一个bean：`用户注册服务`

### 来个测试用例模拟用户注册

```
package com.javacode2018.lesson003.demo1;

import com.javacode2018.lesson003.demo1.test0.userregister.MainConfig0;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class EventTest {

    @Test
    public void test0() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig0.class);
        //获取用户注册服务
        com.javacode2018.lesson003.demo1.test0.userregister.UserRegisterService userRegisterService =
                context.getBean(com.javacode2018.lesson003.demo1.test0.userregister.UserRegisterService.class);
        //模拟用户注册
        userRegisterService.registerUser("路人甲Java");
    }

}
```

### 运行输出

```
用户【路人甲Java】注册成功
```

### 添加注册成功发送邮件功能

下面添加一个注册成功发送邮件的功能，只需要自定义一个监听用户注册成功事件的监听器就可以了，其他代码不需要任何改动，如下

```
package com.javacode2018.lesson003.demo1.test0.userregister;


import com.javacode2018.lesson003.demo1.test0.event.EventListener;
import org.springframework.stereotype.Component;

/**
 * 用户注册成功事件监听器->负责给用户发送邮件
 */
@Component
public class SendEmailOnUserRegisterSuccessListener implements EventListener<UserRegisterSuccessEvent> {
    @Override
    public void onEvent(UserRegisterSuccessEvent event) {
        System.out.println(
                String.format("给用户【%s】发送注册成功邮件!", event.getUserName()));
    }
}
```

> 上面这个类使用了`@Component`，会被自动扫描注册到spring容器。

### 再次运行测试用例输出

```
用户【路人甲Java】注册成功
给用户【路人甲Java】发送注册成功邮件!
```

### 小结

上面将注册的主要逻辑（用户信息落库）和次要的业务逻辑（发送邮件）通过事件的方式解耦了。次要的业务做成了可插拔的方式，比如不想发送邮件了，只需要将邮件监听器上面的`@Component`注释就可以了，非常方便扩展。

上面用到的和事件相关的几个类，都是我们自己实现的，其实这些功能在spring中已经帮我们实现好了，用起来更容易一些，下面带大家来体验一下。

## Spring中实现事件模式

### 事件相关的几个类

Spring中事件相关的几个类需要先了解一下，下面来个表格，将spring中事件相关的类和我们上面自定义的类做个对比，方便大家理解

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

这些类和我们自定义的类中代码有点类似，有兴趣的可以去看一下源码，这里就不列出来了。

### 硬编码的方式使用spring事件3步骤

#### 步骤1：定义事件

自定义事件，需要继承`ApplicationEvent`类，

#### 步骤2：定义监听器

自定义事件监听器，需要实现`ApplicationListener`接口，这个接口有个方法`onApplicationEvent`需要实现，用来处理感兴趣的事件。

```
@FunctionalInterface
public interface ApplicationListener<E extends ApplicationEvent> extends EventListener {

    /**
     * Handle an application event.
     * @param event the event to respond to
     */
    void onApplicationEvent(E event);

}
```

#### 步骤3：创建事件广播器

创建事件广播器`ApplicationEventMulticaster`，这是个接口，你可以自己实现这个接口，也可以直接使用系统给我们提供的`SimpleApplicationEventMulticaster`，如下：

```
ApplicationEventMulticaster applicationEventMulticaster = new SimpleApplicationEventMulticaster();
```

#### 步骤4：向广播器中注册事件监听器

将事件监听器注册到广播器`ApplicationEventMulticaster`中，如：

```
ApplicationEventMulticaster applicationEventMulticaster = new SimpleApplicationEventMulticaster();
applicationEventMulticaster.addApplicationListener(new SendEmailOnOrderCreateListener());
```

#### 步骤5：通过广播器发布事件

广播事件，调用`ApplicationEventMulticaster#multicastEvent方法`广播事件，此时广播器中对这个事件感兴趣的监听器会处理这个事件。

```
applicationEventMulticaster.multicastEvent(new OrderCreateEvent(applicationEventMulticaster, 1L));
```

下面我们来个案例将这5个步骤串起来感受一下。

### 案例

实现功能：电商中订单创建成功之后，给下单人发送一封邮件，发送邮件的功能放在监听器中实现。

下面上代码

#### 来个事件类：订单创建成功事件

```
package com.javacode2018.lesson003.demo1.test1;

import org.springframework.context.ApplicationEvent;

/**
 * 订单创建事件
 */
public class OrderCreateEvent extends ApplicationEvent {
    //订单id
    private Long orderId;

    /**
     * @param source  事件源
     * @param orderId 订单id
     */
    public OrderCreateEvent(Object source, Long orderId) {
        super(source);
        this.orderId = orderId;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }
}
```

#### 来个监听器：负责监听订单成功事件，发送邮件

```
package com.javacode2018.lesson003.demo1.test1;

import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

/**
 * 订单创建成功给用户发送邮件
 */
@Component
public class SendEmailOnOrderCreateListener implements ApplicationListener<OrderCreateEvent> {
    @Override
    public void onApplicationEvent(OrderCreateEvent event) {
        System.out.println(String.format("订单【%d】创建成功，给下单人发送邮件通知!", event.getOrderId()));
    }
}
```

#### 测试用例

```
@Test
public void test2() throws InterruptedException {
    //创建事件广播器
    ApplicationEventMulticaster applicationEventMulticaster = new SimpleApplicationEventMulticaster();
    //注册事件监听器
    applicationEventMulticaster.addApplicationListener(new SendEmailOnOrderCreateListener());
    //广播事件订单创建事件
    applicationEventMulticaster.multicastEvent(new OrderCreateEvent(applicationEventMulticaster, 1L));
}
```

#### 运行输出

```
订单【1】创建成功，给下单人发送邮件通知!
```

### ApplicationContext容器中事件的支持

上面演示了spring中事件的使用，那么平时我们使用spring的时候就这么使用？

非也非也，上面只是我给大家演示了一下原理。

通常情况下，我们会使用以`ApplicationContext`结尾的类作为spring的容器来启动应用，下面2个是比较常见的

```
AnnotationConfigApplicationContext
ClassPathXmlApplicationContext
```

来看一个类图

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

对这个图我们来解释一下：

```
1.AnnotationConfigApplicationContext和ClassPathXmlApplicationContext都继承了AbstractApplicationContext
2.AbstractApplicationContext实现了ApplicationEventPublisher接口
3.AbstractApplicationContext内部有个ApplicationEventMulticaster类型的字段
```

上面第三条，说明了`AbstractApplicationContext`内部已经集成了事件广播器`ApplicationEventMulticaster`，说明`AbstractApplicationContext`内部是具体事件相关功能的，这些功能是通过其内部的`ApplicationEventMulticaster`来实现的，也就是说将事件的功能委托给了内部的`ApplicationEventMulticaster`来实现。

### ApplicationEventPublisher接口

上面类图中多了一个新的接口`ApplicationEventPublisher`，来看一下源码

```
@FunctionalInterface
public interface ApplicationEventPublisher {

    default void publishEvent(ApplicationEvent event) {
        publishEvent((Object) event);
    }

    void publishEvent(Object event);

}
```

这个接口用来发布事件的，内部定义2个方法都是用来发布事件的。

spring中不是有个`ApplicationEventMulticaster`接口么，此处怎么又来了一个发布事件的接口？

这个接口的实现类中，比如`AnnotationConfigApplicationContext`内部将这2个方法委托给`ApplicationEventMulticaster#multicastEvent`进行处理了。

所以调用`AbstractApplicationContext中的publishEvent`方法，也实现广播事件的效果，不过使用`AbstractApplicationContext`也只能通过调用`publishEvent`方法来广播事件。

### 获取ApplicationEventPublisher对象

如果我们想在普通的bean中获取`ApplicationEventPublisher`对象，需要实现`ApplicationEventPublisherAware`接口

```
public interface ApplicationEventPublisherAware extends Aware {
    void setApplicationEventPublisher(ApplicationEventPublisher applicationEventPublisher);
}
```

spring容器会自动通过上面的`setApplicationEventPublisher`方法将`ApplicationEventPublisher`注入进来，此时我们就可以使用这个来发布事件了。

### Spring为了简化事件的使用，提供了2种使用方式

1. **面相接口的方式**
2. **面相@EventListener注解的方式**

## 面相接口的方式

### 案例

实现用户注册成功后发布事件，然后在监听器中发送邮件的功能。

#### 用户注册事件

> 需要继承`ApplicationEvent`

```
package com.javacode2018.lesson003.demo1.test2;

import org.springframework.context.ApplicationEvent;

/**
 * 用户注册事件
 */
public class UserRegisterEvent extends ApplicationEvent {
    //用户名
    private String userName;

    public UserRegisterEvent(Object source, String userName) {
        super(source);
        this.userName = userName;
    }

    public String getUserName() {
        return userName;
    }
}
```

#### 发送邮件监听器

> 需实现`ApplicationListener`接口

```
package com.javacode2018.lesson003.demo1.test2;

import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

/**
 * 用户注册成功发送邮件
 */
@Component
public class SendEmailListener implements ApplicationListener<UserRegisterEvent> {

    @Override
    public void onApplicationEvent(UserRegisterEvent event) {
        System.out.println(String.format("给用户【%s】发送注册成功邮件!", event.getUserName()));

    }
}
```

#### 用户注册服务

> 内部提供用户注册的功能，并发布用户注册事件

```
package com.javacode2018.lesson003.demo1.test2;


import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.ApplicationEventPublisherAware;
import org.springframework.stereotype.Component;

/**
 * 用户注册服务
 */
@Component
public class UserRegisterService implements ApplicationEventPublisherAware {

    private ApplicationEventPublisher applicationEventPublisher;

    /**
     * 负责用户注册及发布事件的功能
     *
     * @param userName 用户名
     */
    public void registerUser(String userName) {
        //用户注册(将用户信息入库等操作)
        System.out.println(String.format("用户【%s】注册成功", userName));
        //发布注册成功事件
        this.applicationEventPublisher.publishEvent(new UserRegisterEvent(this, userName));
    }

    @Override
    public void setApplicationEventPublisher(ApplicationEventPublisher applicationEventPublisher) { //@1
        this.applicationEventPublisher = applicationEventPublisher;
    }
}
```

> 注意上面实现了`ApplicationEventPublisherAware接口`，spring容器会通过`@1`将`ApplicationEventPublisher`注入进来，然后我们就可以使用这个来发布事件了。

#### 来个spring配置类

```
package com.javacode2018.lesson003.demo1.test2;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig2 {
}
```

#### 上测试用例

```
@Test
public void test2() throws InterruptedException {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig2.class);
    context.refresh();
    //获取用户注册服务
    com.javacode2018.lesson003.demo1.test2.UserRegisterService userRegisterService =
            context.getBean(com.javacode2018.lesson003.demo1.test2.UserRegisterService.class);
    //模拟用户注册
    userRegisterService.registerUser("路人甲Java");
}
```

#### 运行输出

```
用户【路人甲Java】注册成功
给用户【路人甲Java】发送注册成功邮件!
```

### 原理

spring容器在创建bean的过程中，会判断bean是否为`ApplicationListener`类型，进而会将其作为监听器注册到`AbstractApplicationContext#applicationEventMulticaster`中，这块的源码在下面这个方法中，有兴趣的可以看一下

```
org.springframework.context.support.ApplicationListenerDetector#postProcessAfterInitialization
```

### 小结

从上面这个案例中可以看出，事件类、监听器类都是通过基于spring中的事件相关的一些接口来实现事件的功能，这种方式我们就称作面相接口的方式。

## 面相@EventListener注解方式

### 用法

上面是通过接口的方式创建一个监听器，spring还提供了通过`@EventListener`注解的方式来创建一个监听器，直接将这个注解标注在一个bean的方法上，那么这个方法就可以用来处理感兴趣的事件，使用更简单，如下，方法参数类型为事件的类型：

```
@Component
public class UserRegisterListener {
    @EventListener
    public void sendMail(UserRegisterEvent event) {
        System.out.println(String.format("给用户【%s】发送注册成功邮件!", event.getUserName()));
    }
}
```

### 案例

注册成功之后：来2个监听器：一个负责发送邮件、一个负责发送优惠券。

其他代码都不上了，和上面案例中的一样，主要看监听器的代码，如下：

```
package com.javacode2018.lesson003.demo1.test3;

import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

/**
 * 用户注册监听器
 */
@Component
public class UserRegisterListener {
    @EventListener
    public void sendMail(UserRegisterEvent event) {
        System.out.println(String.format("给用户【%s】发送注册成功邮件!", event.getUserName()));
    }

    @EventListener
    public void sendCompon(UserRegisterEvent event) {
        System.out.println(String.format("给用户【%s】发送优惠券!", event.getUserName()));
    }
}
```

这块案例代码

```
com.javacode2018.lesson003.demo1.EventTest#test3
```

运行结果

```
用户【路人甲Java】注册成功
给用户【路人甲Java】发送优惠券!
给用户【路人甲Java】发送注册成功邮件!
```

### 原理

spring中处理@EventListener注解源码位于下面的方法中

```
org.springframework.context.event.EventListenerMethodProcessor#afterSingletonsInstantiated
```

EventListenerMethodProcessor实现了SmartInitializingSingleton接口，SmartInitializingSingleton接口中的`afterSingletonsInstantiated`方法会在所有单例的bean创建完成之后被spring容器调用，这块的内容可以去看一下：[Bean生命周期详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934322&idx=1&sn=647edffeedeb8978c18ad403b1f3d8d7&chksm=88621f8cbf15969af1c5396903dcce312c1f316add1af325327d287e90be49bbeda52bc1e736&token=718443976&lang=zh_CN&scene=21#wechat_redirect)

### idea对注解的方式支持比较好

注解的方式实现监听器，idea对这块支持比较好，时间发布的地方会显示一个`耳机`，点击这个`耳机`的时候，spring会帮我们列出这个事件有哪些监听器

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

点击`耳机`列出了2个监听器，可以快速定位到监听器，如下

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

同样监听器的地方也有一个广播的图标，如下图

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

点击上面这个`广播`的图标，可以快速导航到事件发布的地方，相当方便。

## 监听器支持排序功能

如果某个事件有多个监听器，默认情况下，监听器执行顺序是无序的，不过我们可以为监听器指定顺序。

### 通过接口实现监听器的情况

如果自定义的监听器是通过ApplicationListener接口实现的，那么指定监听器的顺序有三种方式

#### 方式1：实现org.springframework.core.Ordered接口

需要实现一个getOrder方法，返回顺序值，值越小，顺序越高

```
int getOrder();
```

#### 方式2：实现org.springframework.core.PriorityOrdered接口

PriorityOrdered接口继承了方式一中的Ordered接口，所以如果你实现PriorityOrdered接口，也需要实现getOrder方法。

#### 方式3：类上使用@org.springframework.core.annotation.Order注解

看一下这个注解的源码

```
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.METHOD, ElementType.FIELD})
@Documented
public @interface Order {

    int value() default Ordered.LOWEST_PRECEDENCE;

}
```

> value属性用来指定顺序

#### 这几种方式排序规则

```
PriorityOrdered#getOrder ASC,Ordered或@Order ASC
```

### 通过@EventListener实现事件监听器的情况

可以在标注`@EventListener`的方法上面使用`@Order(顺序值)`注解来标注顺序，如：

```
@EventListener
@Order(1)
public void sendMail(com.javacode2018.lesson003.demo1.test3.UserRegisterEvent event) {
    System.out.println(String.format("给用户【%s】发送注册成功邮件!", event.getUserName()));
}
```

### 案例

```
package com.javacode2018.lesson003.demo1.test4;

import org.springframework.context.event.EventListener;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * 用户注册监听器
 */
@Component
public class UserRegisterListener {
    @EventListener
    @Order(1)
    public void sendMail(UserRegisterEvent event) {
        System.out.println(String.format("【%s】，给用户【%s】发送注册成功邮件!", Thread.currentThread(), event.getUserName()));
    }

    @EventListener
    @Order(0)
    public void sendCompon(UserRegisterEvent event) {
        System.out.println(String.format("【%s】，给用户【%s】发送优惠券!", Thread.currentThread(), event.getUserName()));
    }
}
```

> 上面会先发送优惠券、然后再发送邮件。
>
> 上面输出中顺便将线程信息也输出了。

对应测试用例

```
com.javacode2018.lesson003.demo1.EventTest#test4
```

运行输出

```
【Thread[main,5,main]】,用户【路人甲Java】注册成功
【Thread[main,5,main]】，给用户【路人甲Java】发送优惠券!
【Thread[main,5,main]】，给用户【路人甲Java】发送注册成功邮件!
```

从输出中可以看出上面程序的执行都在主线程中执行的，说明监听器中的逻辑和注册逻辑在一个线程中执行的，此时如果监听器中的逻辑比较耗时或者失败，直接会导致注册失败，通常我们将一些非主要逻辑可以放在监听器中执行，至于这些非主要逻辑成功或者失败，最好不要对主要的逻辑产生影响，所以我们最好能将监听器的运行和主业务隔离开，放在不同的线程中执行，主业务不用关注监听器的结果，spring中支持这种功能，下面继续看。

## 监听器异步模式

### 先来看看到底如何实现？

监听器最终是通过`ApplicationEventMulticaster`内部的实现来调用的，所以我们关注的重点就是这个类，这个类默认有个实现类`SimpleApplicationEventMulticaster`，这个类是支持监听器异步调用的，里面有个字段：

```
private Executor taskExecutor;
```

高并发比较熟悉的朋友对`Executor`这个接口是比较熟悉的，可以用来异步执行一些任务。

我们常用的线程池类`java.util.concurrent.ThreadPoolExecutor`就实现了`Executor`接口。

再来看一下`SimpleApplicationEventMulticaster`中事件监听器的调用，最终会执行下面这个方法

```
@Override
public void multicastEvent(final ApplicationEvent event, @Nullable ResolvableType eventType) {
    ResolvableType type = (eventType != null ? eventType : resolveDefaultEventType(event));
    Executor executor = getTaskExecutor();
    for (ApplicationListener<?> listener : getApplicationListeners(event, type)) {
        if (executor != null) { //@1
            executor.execute(() -> invokeListener(listener, event));
        }
        else {
            invokeListener(listener, event);
        }
    }
}
```

上面的`invokeListener`方法内部就是调用监听器，从代码`@1`可以看出，如果当前`executor`不为空，监听器就会被异步调用，所以如果需要异步只需要让`executor`不为空就可以了，但是默认情况下`executor`是空的，此时需要我们来给其设置一个值，下面我们需要看容器中是如何创建广播器的，我们在那个地方去干预。

通常我们使用的容器是`AbstractApplicationContext`类型的，需要看一下`AbstractApplicationContext`中广播器是怎么初始化的，就是下面这个方法，容器启动的时候会被调用，用来初始化`AbstractApplicationContext`中的事件广播器`applicationEventMulticaster`

```
public static final String APPLICATION_EVENT_MULTICASTER_BEAN_NAME = "applicationEventMulticaster";

protected void initApplicationEventMulticaster() {
    ConfigurableListableBeanFactory beanFactory = getBeanFactory();
    if (beanFactory.containsLocalBean(APPLICATION_EVENT_MULTICASTER_BEAN_NAME)) {
        this.applicationEventMulticaster =
            beanFactory.getBean(APPLICATION_EVENT_MULTICASTER_BEAN_NAME, ApplicationEventMulticaster.class);
    }
    else {
        this.applicationEventMulticaster = new SimpleApplicationEventMulticaster(beanFactory);
        beanFactory.registerSingleton(APPLICATION_EVENT_MULTICASTER_BEAN_NAME, this.applicationEventMulticaster);
    }
}
```

上面逻辑解释一下：判断spring容器中是否有名称为`applicationEventMulticaster`的bean，如果有就将其作为事件广播器，否则创建一个SimpleApplicationEventMulticaster作为广播器，并将其注册到spring容器中。

从上面可以得出结论：我们只需要自定义一个类型为`SimpleApplicationEventMulticaster`名称为`applicationEventMulticaster`的bean就可以了，顺便给`executor`设置一个值，就可以实现监听器异步执行了。

### 具体实现如下

```
package com.javacode2018.lesson003.demo1.test5;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.ApplicationEventMulticaster;
import org.springframework.context.event.SimpleApplicationEventMulticaster;
import org.springframework.scheduling.concurrent.ThreadPoolExecutorFactoryBean;

import java.util.concurrent.Executor;

@ComponentScan
@Configuration
public class MainConfig5 {
    @Bean
    public ApplicationEventMulticaster applicationEventMulticaster() { //@1
        //创建一个事件广播器
        SimpleApplicationEventMulticaster result = new SimpleApplicationEventMulticaster();
        //给广播器提供一个线程池，通过这个线程池来调用事件监听器
        Executor executor = this.applicationEventMulticasterThreadPool().getObject();
        //设置异步执行器
        result.setTaskExecutor(executor);//@1
        return result;
    }

    @Bean
    public ThreadPoolExecutorFactoryBean applicationEventMulticasterThreadPool() {
        ThreadPoolExecutorFactoryBean result = new ThreadPoolExecutorFactoryBean();
        result.setThreadNamePrefix("applicationEventMulticasterThreadPool-");
        result.setCorePoolSize(5);
        return result;
    }
}
```

> @1：定义了一个名称为`applicationEventMulticaster`的事件广播器，内部设置了一个线程池用来异步调用监听器

这段代码对应的测试用例

```
com.javacode2018.lesson003.demo1.EventTest#test5
```

运行输出

```
当前线程【Thread[main,5,main]】,用户【路人甲Java】注册成功
当前线程【Thread[applicationEventMulticasterThreadPool-2,5,main]】,给用户【路人甲Java】发送注册成功邮件!
当前线程【Thread[applicationEventMulticasterThreadPool-1,5,main]】,给用户【路人甲Java】发放一些优惠券!
```

此时实现了监听器异步执行的效果。

# 28篇：Bean循环依赖详解

年薪 50 万的一个面试题，看着不难，却刷掉了 99% 的人！

**今天要说的是 spring 中循环依赖的问题，最近有大量粉丝问这个问题，也是高薪面试中经常会被问到的一个问题。**

关于循环依赖的问题，来感受一下连环炮，试试自己否可以过关斩将，轻松应对。

1. **什么是循环依赖？**
2. **如何检测是否存在循环依赖？**
3. **如何解决循环依赖？**
4. **多例的情况下，循环依赖问题为什么无法解决？**
5. **单例的情况下，虽然可以解决循环依赖，是否存在其他问题？**
6. **为什么采用三级缓存解决循环依赖？如果直接将早期 bean 丢到二级缓存可以么？**

前面 4 个 ok 的，超越了 80% 的人，后面 2 个难度指数递增，能回答出来的算是千分之一，如果能回答上来，会让面试官相当佩服你的。

下面我们来一个个突破。

## 什么是循环依赖？

这个很好理解，多个 bean 之间相互依赖，形成了一个闭环。

比如：A 依赖于 B、B 依赖于 C、C 依赖于 A。

代码中表示：

```
public class A{
    B b;
}
public class B{
    C c;
}
public class C{
    A a;
}
```

## 如何检测是否存在循环依赖？

检测循环依赖比较简单，使用一个列表来记录正在创建中的 bean，bean 创建之前，先去记录中看一下自己是否已经在列表中了，如果在，说明存在循环依赖，如果不在，则将其加入到这个列表，bean 创建完毕之后，将其再从这个列表中移除。

源码方面来看一下，spring 创建单例 bean 时候，会调用下面方法

```
protected void beforeSingletonCreation(String beanName) {
        if (!this.inCreationCheckExclusions.contains(beanName) && !this.singletonsCurrentlyInCreation.add(beanName)) {
            throw new BeanCurrentlyInCreationException(beanName);
        }
    }
```

`singletonsCurrentlyInCreation`就是用来记录目前正在创建中的 bean 名称列表，`this.singletonsCurrentlyInCreation.add(beanName)`返回`false`，说明 beanName 已经在当前列表中了，此时会抛循环依赖的异常`BeanCurrentlyInCreationException`，这个异常对应的源码：

```
public BeanCurrentlyInCreationException(String beanName) {
        super(beanName,
                "Requested bean is currently in creation: Is there an unresolvable circular reference?");
    }
```

上面是单例 bean 检测循环依赖的源码，再来看看非单例 bean 的情况。

以 prototype 情况为例，源码位于`org.springframework.beans.factory.support.AbstractBeanFactory#doGetBean`方法中，将主要代码列出来看一下：

```
//检查正在创建的bean列表中是否存在beanName，如果存在，说明存在循环依赖，抛出循环依赖的异常
if (isPrototypeCurrentlyInCreation(beanName)) {
    throw new BeanCurrentlyInCreationException(beanName);
}

//判断scope是否是prototype
if (mbd.isPrototype()) {
    Object prototypeInstance = null;
    try {
        //将beanName放入正在创建的列表中
        beforePrototypeCreation(beanName);
        prototypeInstance = createBean(beanName, mbd, args);
    }
    finally {
        //将beanName从正在创建的列表中移除
        afterPrototypeCreation(beanName);
    }
}
```

## Spring 如何解决循环依赖的问题

这块建议大家先看一下：[**详解 bean 生命周期**](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934322&idx=1&sn=647edffeedeb8978c18ad403b1f3d8d7&chksm=88621f8cbf15969af1c5396903dcce312c1f316add1af325327d287e90be49bbeda52bc1e736&token=718443976&lang=zh_CN&scene=21#wechat_redirect)

spring 创建 bean 主要的几个步骤：

1. **步骤 1：实例化 bean，即调用构造器创建 bean 实例**
2. **步骤 2：填充属性，注入依赖的 bean，比如通过 set 方式、@Autowired 注解的方式注入依赖的 bean**
3. **步骤 3：bean 的初始化，比如调用 init 方法等。**

从上面 3 个步骤中可以看出，注入依赖的对象，有 2 种情况：

1. 通过步骤 1 中构造器的方式注入依赖
2. 通过步骤 2 注入依赖

先来看构造器的方式注入依赖的 bean，下面两个 bean 循环依赖

```
@Component
public class ServiceA {
    private ServiceB serviceB;

    public ServiceA(ServiceB serviceB) {
        this.serviceB = serviceB;
    }
}

@Component
public class ServiceB {
    private ServiceA serviceA;

    public ServiceB(ServiceA serviceA) {
        this.serviceA = serviceA;
    }
}
```

构造器的情况比较容易理解，实例化 ServiceA 的时候，需要有 serviceB，而实例化 ServiceB 的时候需要有 serviceA，构造器循环依赖是无法解决的，大家可以尝试一下使用编码的方式创建上面 2 个对象，是无法创建成功的！

再来看看非构造器的方式注入相互依赖的 bean，以 set 方式注入为例，下面是 2 个单例的 bean：serviceA 和 serviceB：

```
@Component
public class ServiceA {
    private ServiceB serviceB;

    @Autowired
    public void setServiceB(ServiceB serviceB) {
        this.serviceB = serviceB;
    }
}


@Component
public class ServiceB {
    private ServiceA serviceA;

    @Autowired
    public void setServiceA(ServiceA serviceA) {
        this.serviceA = serviceA;
    }
}
```

如果我们采用硬编码的方式创建上面 2 个对象，过程如下：

```
//创建serviceA
ServiceA serviceA = new ServiceA();
//创建serviceB
ServiceB serviceB = new ServiceB();
//将serviceA注入到serviceB中
serviceB.setServiceA(serviceA);
//将serviceB注入到serviceA中
serviceA.setServiceB(serviceB);
```

由于单例 bean 在 spring 容器中只存在一个，所以 spring 容器中肯定是有一个缓存来存放所有已创建好的单例 bean；获取单例 bean 之前，可以先去缓存中找，找到了直接返回，找不到的情况下再去创建，创建完毕之后再将其丢到缓存中，可以使用一个 map 来存储单例 bean，比如下面这个

```
Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);
```

下面来看一下 spring 中 set 方法创建上面 2 个 bean 的过程

```
1.spring轮询准备创建2个bean：serviceA和serviceB
2.spring容器发现singletonObjects中没有serviceA
3.调用serviceA的构造器创建serviceA实例
4.serviceA准备注入依赖的对象，发现需要通过setServiceB注入serviceB
5.serviceA向spring容器查找serviceB
6.spring容器发现singletonObjects中没有serviceB
7.调用serviceB的构造器创建serviceB实例
8.serviceB准备注入依赖的对象，发现需要通过setServiceA注入serviceA
9.serviceB向spring容器查找serviceA
10.此时又进入步骤2了
```

卧槽，上面过程死循环了，怎么才能终结？

可以在第 3 步后加一个操作：将实例化好的 serviceA 丢到 singletonObjects 中，此时问题就解决了。

spring 中也采用类似的方式，稍微有点区别，上面使用了一个缓存，而 spring 内部采用了 3 级缓存来解决这个问题，我们一起来细看一下。

3 级缓存对应的代码：

```
/** 第一级缓存：单例bean的缓存 */
private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);

/** 第二级缓存：早期暴露的bean的缓存 */
private final Map<String, Object> earlySingletonObjects = new HashMap<>(16);

/** 第三级缓存：单例bean工厂的缓存 */
private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16);
```

下面来看 spring 中具体的过程，我们一起来分析源码

开始的时候，获取 serviceA，会调用下面代码

```
org.springframework.beans.factory.support.AbstractBeanFactory#doGetBean

protected <T> T doGetBean(final String name, @Nullable final Class<T> requiredType,
                              @Nullable final Object[] args, boolean typeCheckOnly) throws BeansException {
    //1.查看缓存中是否已经有这个bean了
    Object sharedInstance = getSingleton(beanName); //@1
    if (sharedInstance != null && args == null) {
        bean = getObjectForBeanInstance(sharedInstance, name, beanName, null);
    }else {
        //若缓存中不存在，准备创建这个bean
        if (mbd.isSingleton()) {
            //2.下面进入单例bean的创建过程
            sharedInstance = getSingleton(beanName, () -> {
                try {
                    return createBean(beanName, mbd, args);
                }
                catch (BeansException ex) {
                    throw ex;
                }
            });
            bean = getObjectForBeanInstance(sharedInstance, name, beanName, mbd);
        }
    }
    return (T) bean;
}
```

@1：查看缓存中是否已经有这个 bean 了，如下：

```
public Object getSingleton(String beanName) {
    return getSingleton(beanName, true);
}
```

然后进入下面方法，会依次尝试从 3 级缓存中查找 bean，注意下面的第 2 个参数，为 ture 的时候，才会从第 3 级中查找，否则只会查找 1、2 级缓存

```
//allowEarlyReference:是否允许从三级缓存singletonFactories中通过getObject拿到bean
protected Object getSingleton(String beanName, boolean allowEarlyReference) {
    //1.先从一级缓存中找
    Object singletonObject = this.singletonObjects.get(beanName);
    if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
        synchronized (this.singletonObjects) {
            //2.从二级缓存中找
            singletonObject = this.earlySingletonObjects.get(beanName);
            if (singletonObject == null && allowEarlyReference) {
                //3.二级缓存中没找到 && allowEarlyReference为true的情况下,从三级缓存中找
                ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
                if (singletonFactory != null) {
                    //三级缓存返回的是一个工厂，通过工厂来获取创建bean
                    singletonObject = singletonFactory.getObject();
                    //将创建好的bean丢到二级缓存中
                    this.earlySingletonObjects.put(beanName, singletonObject);
                    //从三级缓存移除
                    this.singletonFactories.remove(beanName);
                }
            }
        }
    }
    return singletonObject;
}
```

刚开始，3 个缓存中肯定是找不到的，会返回 null，接着会执行下面代码准备创建`serviceA`

```
if (mbd.isSingleton()) {
    sharedInstance = getSingleton(beanName, () -> { //@1
        try {
            return createBean(beanName, mbd, args);
        }
        catch (BeansException ex) {
            destroySingleton(beanName);
            throw ex;
        }
    });
}
```

@1：进入`getSingleton`方法，而`getSingleton`方法代码比较多，为了方便大家理解，无关的代码我给剔除了，如下：

```
public Object getSingleton(String beanName, ObjectFactory<?> singletonFactory) {
    synchronized (this.singletonObjects) {
        Object singletonObject = this.singletonObjects.get(beanName);
        if (singletonObject == null) {
            //单例bean创建之前调用，将其加入正在创建的列表中，上面有提到过，主要用来检测循环依赖用的
            beforeSingletonCreation(beanName);
            boolean newSingleton = false;

            try {
                //调用工厂创建bean
                singletonObject = singletonFactory.getObject();//@1
                newSingleton = true;
            }
            finally {
                 //单例bean创建之前调用,主要是将其从正在创建的列表中移除
                afterSingletonCreation(beanName);
            }
            if (newSingleton) {
                //将创建好的单例bean放入缓存中
                addSingleton(beanName, singletonObject);//@2
            }
        }
        return singletonObject;
    }
}
```

上面 @1 和 @2 是关键代码，先来看一下 @1，这个是一个 ObjectFactory 类型的，从外面传入的，如下



![img](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06AFFLfvEV2Niae11TWJibymIZ20HvHgAVRSjtqZ2XjSl63UF6xfsRDC5htonyDQjj7iarVaVl8GoJlVw/640?wx_fmt=png)



红框中的`createBean`最终会调用下面这个方法

```
org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#doCreateBean
```

其内部主要代码如下：

```
BeanWrapper instanceWrapper = null;

if (instanceWrapper == null) {
    //通过反射调用构造器实例化serviceA
    instanceWrapper = createBeanInstance(beanName, mbd, args);
}
//变量bean：表示刚刚同构造器创建好的bean示例
final Object bean = instanceWrapper.getWrappedInstance();

//判断是否需要暴露早期的bean，条件为（是否是单例bean && 当前容器允许循环依赖 && bean名称存在于正在创建的bean名称清单中）
boolean earlySingletonExposure = (mbd.isSingleton() && this.allowCircularReferences &&
                                  isSingletonCurrentlyInCreation(beanName));
if (earlySingletonExposure) {
    //若earlySingletonExposure为true，通过下面代码将早期的bean暴露出去
    addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));//@1
}
```

**这里需要理解一下什么是早期 bean？**

**刚刚实例化好的 bean 就是早期的 bean，此时 bean 还未进行属性填充，初始化等操作**

`@1`：通过`addSingletonFactory`用于将早期的 bean 暴露出去，主要是将其丢到第 3 级缓存中，代码如下：

```
protected void addSingletonFactory(String beanName, ObjectFactory<?> singletonFactory) {
    Assert.notNull(singletonFactory, "Singleton factory must not be null");
    synchronized (this.singletonObjects) {
        //第1级缓存中不存在bean
        if (!this.singletonObjects.containsKey(beanName)) {
            //将其丢到第3级缓存中
            this.singletonFactories.put(beanName, singletonFactory);
            //后面的2行代码不用关注
            this.earlySingletonObjects.remove(beanName);
            this.registeredSingletons.add(beanName);
        }
    }
}
```

上面的方法执行之后，serviceA 就被丢到第 3 级的缓存中了。

后续的过程 serviceA 开始注入依赖的对象，发现需要注入 serviceB，会从容器中获取 serviceB，而 serviceB 的获取又会走上面同样的过程实例化 serviceB，然后将 serviceB 提前暴露出去，然后 serviceB 开始注入依赖的对象，serviceB 发现自己需要注入 serviceA，此时去容器中找 serviceA，找 serviceA 会先去缓存中找，会执行`getSingleton("serviceA",true)`，此时会走下面代码：

```
protected Object getSingleton(String beanName, boolean allowEarlyReference) {
    //1.先从一级缓存中找
    Object singletonObject = this.singletonObjects.get(beanName);
    if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
        synchronized (this.singletonObjects) {
            //2.从二级缓存中找
            singletonObject = this.earlySingletonObjects.get(beanName);
            if (singletonObject == null && allowEarlyReference) {
                //3.二级缓存中没找到 && allowEarlyReference为true的情况下,从三级缓存中找
                ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
                if (singletonFactory != null) {
                    //三级缓存返回的是一个工厂，通过工厂来获取创建bean
                    singletonObject = singletonFactory.getObject();
                    //将创建好的bean丢到二级缓存中
                    this.earlySingletonObjects.put(beanName, singletonObject);
                    //从三级缓存移除
                    this.singletonFactories.remove(beanName);
                }
            }
        }
    }
    return singletonObject;
}
```

上面的方法走完之后，serviceA 会被放入二级缓存`earlySingletonObjects`中，会将 serviceA 返回，此时 serviceB 中的 serviceA 注入成功，serviceB 继续完成创建，然后将自己返回给 serviceA，此时 serviceA 通过 set 方法将 serviceB 注入。

serviceA 创建完毕之后，会调用`addSingleton`方法将其加入到缓存中，这块代码如下：

```
protected void addSingleton(String beanName, Object singletonObject) {
    synchronized (this.singletonObjects) {
        //将bean放入第1级缓存中
        this.singletonObjects.put(beanName, singletonObject);
        //将其从第3级缓存中移除
        this.singletonFactories.remove(beanName);
        //将其从第2级缓存中移除
        this.earlySingletonObjects.remove(beanName);
    }
}
```

到此，serviceA 和 serviceB 之间的循环依赖注入就完成了。

下面捋一捋整个过程：

```
1.从容器中获取serviceA
2.容器尝试从3个缓存中找serviceA，找不到
3.准备创建serviceA
4.调用serviceA的构造器创建serviceA，得到serviceA实例，此时serviceA还未填充属性，未进行其他任何初始化的操作
5.将早期的serviceA暴露出去：即将其丢到第3级缓存singletonFactories中
6.serviceA准备填充属性，发现需要注入serviceB，然后向容器获取serviceB
7.容器尝试从3个缓存中找serviceB，找不到
8.准备创建serviceB
9.调用serviceB的构造器创建serviceB，得到serviceB实例，此时serviceB还未填充属性，未进行其他任何初始化的操作
10.将早期的serviceB暴露出去：即将其丢到第3级缓存singletonFactories中
11.serviceB准备填充属性，发现需要注入serviceA，然后向容器获取serviceA
12.容器尝试从3个缓存中找serviceA，发现此时serviceA位于第3级缓存中，经过处理之后，serviceA会从第3级缓存中移除，然后会存到第2级缓存中，然后将其返回给serviceB，此时serviceA通过serviceB中的setServiceA方法被注入到serviceB中
13.serviceB继续执行后续的一些操作，最后完成创建工作，然后会调用addSingleton方法，将自己丢到第1级缓存中，并将自己从第2和第3级缓存中移除
14.serviceB将自己返回给serviceA
15.serviceA通过setServiceB方法将serviceB注入进去
16.serviceB继续执行后续的一些操作，最后完成创建工作,然后会调用addSingleton方法，将自己丢到第1级缓存中，并将自己从第2和第3级缓存中移除
```

## 循环依赖无法解决的情况

**只有单例的 bean 会通过三级缓存提前暴露来解决循环依赖的问题，而非单例的 bean，每次从容器中获取都是一个新的对象，都会重新创建，所以非单例的 bean 是没有缓存的，不会将其放到三级缓存中。**

那就会有下面几种情况需要注意。

还是以 2 个 bean 相互依赖为例：serviceA 和 serviceB

### 情况 1

#### 条件

serviceA：多例

serviceB：多例

#### 结果

此时不管是任何方式都是无法解决循环依赖的问题，最终都会报错，因为每次去获取依赖的 bean 都会重新创建。

### 情况 2

#### 条件

serviceA：单例

serviceB：多例

#### 结果

若使用构造器的方式相互注入，是无法完成注入操作的，会报错。

若采用 set 方式注入，所有 bean 都还未创建的情况下，若去容器中获取 serviceB，会报错，为什么？我们来看一下过程：

```
1.从容器中获取serviceB
2.serviceB由于是多例的，所以缓存中肯定是没有的
3.检查serviceB是在正在创建的bean名称列表中，没有
4.准备创建serviceB
5.将serviceB放入正在创建的bean名称列表中
6.实例化serviceB（由于serviceB是多例的，所以不会提前暴露，必须是单例的才会暴露）
7.准备填充serviceB属性，发现需要注入serviceA
8.从容器中查找serviceA
9.尝试从3级缓存中找serviceA，找不到
10.准备创建serviceA
11.将serviceA放入正在创建的bean名称列表中
12.实例化serviceA
13.由于serviceA是单例的，将早期serviceA暴露出去，丢到第3级缓存中
14.准备填充serviceA的属性，发现需要注入serviceB
15.从容器中获取serviceB
16.先从缓存中找serviceB，找不到
17.检查serviceB是在正在创建的bean名称列表中,发现已经存在了，抛出循环依赖的异常
```

这个有演示的源码，位置：

```
com.javacode2018.lesson003.demo2.CircleDependentTest#test2
```

**在这里给大家留个问题，如果此处不是去获取 serviceB，而是先去获取 serviceA 呢，会不会报错？欢迎各位留言。**

## 探讨：为什么需要用 3 级缓存

### 问题

**如果只使用 2 级缓存，直接将刚实例化好的 bean 暴露给二级缓存出是否可以否？**

先下个结论吧：不行。

### 原因

**这样做是可以解决：早期暴露给其他依赖者的 bean 和最终暴露的 bean 不一致的问题。**

若将刚刚实例化好的 bean 直接丢到二级缓存中暴露出去，如果后期这个 bean 对象被更改了，比如可能在上面加了一些拦截器，将其包装为一个代理了，那么暴露出去的 bean 和最终的这个 bean 就不一样的，将自己暴露出去的时候是一个原始对象，而自己最终却是一个代理对象，最终会导致被暴露出去的和最终的 bean 不是同一个 bean 的，将产生意向不到的效果，而三级缓存就可以发现这个问题，会报错。

下面我们通过代码来演示一下效果。

### 案例

下面来 2 个 bean，相互依赖，通过 set 方法相互注入，并且其内部都有一个 m1 方法，用来输出一行日志。

#### Service1

```
package com.javacode2018.lesson003.demo2.test3;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Service1 {
    public void m1() {
        System.out.println("Service1 m1");
    }

    private Service2 service2;

    @Autowired
    public void setService2(Service2 service2) {
        this.service2 = service2;
    }

}
```

#### Service2

```
package com.javacode2018.lesson003.demo2.test3;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Service2 {

    public void m1() {
        System.out.println("Service2 m1");
        this.service1.m1();//@1
    }

    private Service1 service1;

    @Autowired
    public void setService1(Service1 service1) {
        this.service1 = service1;
    }

    public Service1 getService1() {
        return service1;
    }
}
```

注意上面的`@1`，service2 的 m1 方法中会调用 service1 的 m1 方法。

#### 需求

在 service1 上面加个拦截器，要求在调用 service1 的任何方法之前需要先输出一行日志

```
你好,service1
```

#### 实现

新增一个 Bean 后置处理器来对 service1 对应的 bean 进行处理，将其封装为一个代理暴露出去。

```
package com.javacode2018.lesson003.demo2.test3;

import org.springframework.aop.MethodBeforeAdvice;
import org.springframework.aop.framework.ProxyFactory;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;

@Component
public class MethodBeforeInterceptor implements BeanPostProcessor {
    @Nullable
    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        if ("service1".equals(beanName)) {
            //代理创建工厂，需传入被代理的目标对象
            ProxyFactory proxyFactory = new ProxyFactory(bean);
            //添加一个方法前置通知，会在方法执行之前调用通知中的before方法
            proxyFactory.addAdvice(new MethodBeforeAdvice() {
                @Override
                public void before(Method method, Object[] args, @Nullable Object target) throws Throwable {
                    System.out.println("你好,service1");
                }
            });
            //返回代理对象
            return proxyFactory.getProxy();
        }
        return bean;
    }
}
```

上面的`postProcessAfterInitialization`方法内部会在 service1 初始化之后调用，内部会对 service1 这个 bean 进行处理，返回一个代理对象，通过代理来访问 service1 的方法，访问 service1 中的任何方法之前，会先输出：`你好，service1`。

代码中使用了`ProxyFactory`，这块不熟悉的没关系，后面介绍 aop 的时候会细说。

#### 来个配置类

```
@ComponentScan
public class MainConfig3 {

}
```

#### 来个测试用例

```
@Test
public void test3() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig3.class);
    context.refresh();
}
```

#### 运行：报错了

```
org.springframework.beans.factory.BeanCurrentlyInCreationException: Error creating bean with name 'service1': Bean with name 'service1' has been injected into other beans [service2] in its raw version as part of a circular reference, but has eventually been wrapped. This means that said other beans do not use the final version of the bean. This is often the result of over-eager type matching - consider using 'getBeanNamesOfType' with the 'allowEagerInit' flag turned off, for example.

    at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.doCreateBean(AbstractAutowireCapableBeanFactory.java:624)
```

可以看出是`AbstractAutowireCapableBeanFactory.java:624`这个地方整出来的异常，将这块代码贴出来给大家看一下：

```
if (earlySingletonExposure) {
    //@1
    Object earlySingletonReference = getSingleton(beanName, false);
    if (earlySingletonReference != null) {
        //@2
        if (exposedObject == bean) {
            exposedObject = earlySingletonReference;
        }
        //@3
        else if (!this.allowRawInjectionDespiteWrapping && hasDependentBean(beanName)) {
            String[] dependentBeans = getDependentBeans(beanName);
            Set<String> actualDependentBeans = new LinkedHashSet<>(dependentBeans.length);
            for (String dependentBean : dependentBeans) {
                if (!removeSingletonIfCreatedForTypeCheckOnly(dependentBean)) {
                    actualDependentBeans.add(dependentBean);
                }
            }
            if (!actualDependentBeans.isEmpty()) {
                throw new BeanCurrentlyInCreationException(beanName,
                                                           "Bean with name '" + beanName + "' has been injected into other beans [" +
                                                           StringUtils.collectionToCommaDelimitedString(actualDependentBeans) +
                                                           "] in its raw version as part of a circular reference, but has eventually been " +
                                                           "wrapped. This means that said other beans do not use the final version of the " +
                                                           "bean. This is often the result of over-eager type matching - consider using " +
                                                           "'getBeanNamesOfType' with the 'allowEagerInit' flag turned off, for example.");
            }
        }
    }
}
```

上面代码主要用来判断当有循环依赖的情况下，早期暴露给别人使用的 bean 是否和最终的 bean 不一样的情况下，会抛出一个异常。

我们再来通过代码级别的来解释上面代码：

@1：调用 getSingleton(beanName, false) 方法，这个方法用来从 3 个级别的缓存中获取 bean，但是注意了，这个地方第二个参数是 false，此时只会尝试从第 1 级和第 2 级缓存中获取 bean，如果能够获取到，说明了什么？说明了第 2 级缓存中已经有这个 bean 了，而什么情况下第 2 级缓存中会有 bean？说明这个 bean 从第 3 级缓存中已经被别人获取过，然后从第 3 级缓存移到了第 2 级缓存中，说明这个早期的 bean 被别人通过 getSingleton(beanName, true) 获取过

@2：这个地方用来判断早期暴露的 bean 和最终 spring 容器对这个 bean 走完创建过程之后是否还是同一个 bean，上面我们的 service1 被代理了，所以这个地方会返回 false，此时会走到`@3`

@3：`allowRawInjectionDespiteWrapping`这个参数用来控制是否允许循环依赖的情况下，早期暴露给被人使用的 bean 在后期是否可以被包装，通俗点理解就是：是否允许早期给别人使用的 bean 和最终 bean 不一致的情况，这个值默认是 false，表示不允许，也就是说你暴露给别人的 bean 和你最终的 bean 需要是一直的，你给别人的是 1，你后面不能将其修改成 2 了啊，不一样了，你给我用个鸟。

而上面代码注入到 service2 中的 service1 是早期的 service1，而最终 spring 容器中的 service1 变成一个代理对象了，早期的和最终的不一致了，而`allowRawInjectionDespiteWrapping`又是 false，所以报异常了。

那么如何解决这个问题：

很简单，将`allowRawInjectionDespiteWrapping`设置为 true 就可以了，下面改一下代码如下：

```
@Test
public void test4() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    //创建一个BeanFactoryPostProcessor：BeanFactory后置处理器
    context.addBeanFactoryPostProcessor(beanFactory -> {
        if (beanFactory instanceof DefaultListableBeanFactory) {
            //将allowRawInjectionDespiteWrapping设置为true
            ((DefaultListableBeanFactory) beanFactory).setAllowRawInjectionDespiteWrapping(true);
        }
    });
    context.register(MainConfig3.class);
    context.refresh();

    System.out.println("容器初始化完毕");
}
```

上面代码中将`allowRawInjectionDespiteWrapping`设置为 true 了，是通过一个`BeanFactoryPostProcessor`来实现的，后面会有一篇文章来详解`BeanFactoryPostProcessor`，目前你只需要知道`BeanFactoryPostProcessor`可以在 bean 创建之前用来干预`BeanFactory`的创建过程，可以用来修改`BeanFactory`中的一些配置。

#### 再次输出

```
容器初始化完毕
```

此时正常了，我们继续，看看我们加在`service1`上的拦截器起效了没有，上面代码中加入下面代码：

```
//获取service1
Service1 service1 = context.getBean(Service1.class);
//获取service2
Service2 service2 = context.getBean(Service2.class);

System.out.println("----A-----");
service2.m1(); //@1
System.out.println("----B-----");
service1.m1(); //@2
System.out.println("----C-----");
System.out.println(service2.getService1() == service1);
```

上面为了区分结果，使用了`----`格式的几行日志将输出结果分开了，来运行一下，输出：

```
容器初始化完毕
----A-----
Service2 m1
Service1 m1
----B-----
你好,service1
Service1 m1
----C-----
false
```

从输出中可以看出。

service2.m1() 对应输出：

```
Service2 m1
Service1 m1
```

service1.m1() 对应输出：

```
你好,service1
Service1 m1
```

而 service2.m1 方法中调用了 service1.m1, 这个里面拦截器没有起效啊，但是单独调用 service1.m1 方法，却起效了，说明 service2 中注入的 service1 不是代理对象，所以没有加上拦截器的功能，那是因为 service2 中注入的是早期的 service1，注入的时候 service1 还不是一个代理对象，所以没有拦截器中的功能。

再看看最后一行输出为 false，说明 service2 中的 service1 确实和 spring 容器中的 service1 不是一个对象了。

ok，那么这种情况是不是很诧异，如何解决这个问题？

既然最终 service1 是一个代理对象，那么你提前暴露出去的时候，注入到 service2 的时候，你也必须得是个代理对象啊，需要确保给别人和最终是同一个对象。

这个怎么整？继续看暴露早期 bean 的源码，注意了下面是重点：

```
addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));
```

注意有个`getEarlyBeanReference`方法，来看一下这个方法是干什么的，源码如下：

```
protected Object getEarlyBeanReference(String beanName, RootBeanDefinition mbd, Object bean) {
    Object exposedObject = bean;
    if (!mbd.isSynthetic() && hasInstantiationAwareBeanPostProcessors()) {
        for (BeanPostProcessor bp : getBeanPostProcessors()) {
            if (bp instanceof SmartInstantiationAwareBeanPostProcessor) {
                SmartInstantiationAwareBeanPostProcessor ibp = (SmartInstantiationAwareBeanPostProcessor) bp;
                exposedObject = ibp.getEarlyBeanReference(exposedObject, beanName);
            }
        }
    }
    return exposedObject;
}
```

从 3 级缓存中获取 bean 的时候，会调用上面这个方法来获取 bean，这个方法内部会看一下容器中是否有`SmartInstantiationAwareBeanPostProcessor`这种处理器，然后会依次调用这种处理器中的`getEarlyBeanReference`方法，那么思路来了，我们可以自定义一个`SmartInstantiationAwareBeanPostProcessor`，然后在其`getEarlyBeanReference`中来创建代理不就可以了，聪明，我们来试试，将`MethodBeforeInterceptor`代码改成下面这样：

```
@Component
public class MethodBeforeInterceptor implements SmartInstantiationAwareBeanPostProcessor {
    @Override
    public Object getEarlyBeanReference(Object bean, String beanName) throws BeansException {
        if ("service1".equals(beanName)) {
            //代理创建工厂，需传入被代理的目标对象
            ProxyFactory proxyFactory = new ProxyFactory(bean);
            //添加一个方法前置通知，会在方法执行之前调用通知中的before方法
            proxyFactory.addAdvice(new MethodBeforeAdvice() {
                @Override
                public void before(Method method, Object[] args, @Nullable Object target) throws Throwable {
                    System.out.println("你好,service1");
                }
            });
            //返回代理对象
            return proxyFactory.getProxy();
        }
        return bean;
    }
}
```

对应测试用例

```
@Test
public void test5() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig4.class);
    System.out.println("容器初始化完毕");

    //获取service1
    com.javacode2018.lesson003.demo2.test4.Service1  service1 = context.getBean(com.javacode2018.lesson003.demo2.test4.Service1.class);
    //获取service2
    com.javacode2018.lesson003.demo2.test4.Service2 service2 = context.getBean(com.javacode2018.lesson003.demo2.test4.Service2.class);

    System.out.println("----A-----");
    service2.m1(); //@1
    System.out.println("----B-----");
    service1.m1(); //@2
    System.out.println("----C-----");
    System.out.println(service2.getService1() == service1);
}
```

运行输出

```
容器初始化完毕
----A-----
Service2 m1
你好,service1
Service1 m1
----B-----
你好,service1
Service1 m1
----C-----
true
```

## 单例 bean 解决了循环依赖，还存在什么问题？

循环依赖的情况下，由于注入的是早期的 bean，此时早期的 bean 中还未被填充属性，初始化等各种操作，也就是说此时 bean 并没有被完全初始化完毕，此时若直接拿去使用，可能存在有问题的风险。

# 29篇：BeanFactory扩展（BeanFactoryPostProcessor、BeanDefinitionRegistryPostProcessor）

月薪 5 万，回家媳妇把我当大爷伺候！

**Spring 中有 2 个非常重要的接口：BeanFactoryPostProcessor 和 BeanDefinitionRegistryPostProcessor，这 2 个接口面试中也会经常问到，本文我们一起来拿下他们俩。**

## 先来看几个问题

1. **BeanFactoryPostProcessor 是做什么的？**
2. **BeanDefinitionRegistryPostProcessor 是干什么的？**
3. **BeanFactoryPostProcessor 和 BeanDefinitionRegistryPostProcessor 有什么区别？**
4. **这几个接口的执行顺序是什么样的？**

## Spring 容器中主要的 4 个阶段

- 阶段 1：Bean 注册阶段，此阶段会完成所有 bean 的注册
- 阶段 2：BeanFactory 后置处理阶段
- 阶段 3：注册 BeanPostProcessor
- 阶段 4：bean 创建阶段，此阶段完成所有单例 bean 的注册和装载操作，这个阶段不是我们本文关注的重点，有兴趣的，可以去看之前的文章中有详细介绍：[Bean 生命周期详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934322&idx=1&sn=647edffeedeb8978c18ad403b1f3d8d7&chksm=88621f8cbf15969af1c5396903dcce312c1f316add1af325327d287e90be49bbeda52bc1e736&token=718443976&lang=zh_CN&scene=21#wechat_redirect)

本文介绍的 2 个接口主要和前 2 个阶段有关系，下面我们主要来看前 2 个阶段。

## 阶段 1：Bean 注册阶段

### 概述

spring 中所有 bean 的注册都会在此阶段完成，按照规范，所有 bean 的注册必须在此阶段进行，其他阶段不要再进行 bean 的注册。

这个阶段 spring 为我们提供 1 个接口：BeanDefinitionRegistryPostProcessor，spring 容器在这个阶段中会获取容器中所有类型为`BeanDefinitionRegistryPostProcessor`的 bean，然后会调用他们的`postProcessBeanDefinitionRegistry`方法，源码如下，方法参数类型是`BeanDefinitionRegistry`，这个类型大家都比较熟悉，即 bean 定义注册器，内部提供了一些方法可以用来向容器中注册 bean。

```
public interface BeanDefinitionRegistryPostProcessor extends BeanFactoryPostProcessor {
    void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) throws BeansException;
}
```

这个接口还继承了`BeanFactoryPostProcessor`接口，这个大家先不用关心，一会阶段 2 中会介绍。

当容器中有多个`BeanDefinitionRegistryPostProcessor`的时候，可以通过下面任意一种方式来指定顺序

1. 实现`org.springframework.core.PriorityOrdered`接口
2. 实现`org.springframework.core.Ordered`接口

执行顺序：

```
PriorityOrdered.getOrder() asc,Ordered.getOrder() asc
```

下面通过案例来感受一下效果。

### 案例 1：简单实用

此案例演示`BeanDefinitionRegistryPostProcessor`的简单使用

#### 自定义一个 BeanDefinitionRegistryPostProcessor

下面我们定义了一个类，需要实现`BeanDefinitionRegistryPostProcessor`接口，然后会让我们实现 2 个方法，大家重点关注`postProcessBeanDefinitionRegistry`这个方法，另外一个方法来自于`BeanFactoryPostProcessor`，一会我们后面在介绍这个方法，在`postProcessBeanDefinitionRegistry`方法中，我们定义了一个 bean，然后通过`registry`将其注册到容器了，代码很简单

```
package com.javacode2018.lesson003.demo3.test0;

@Component
public class MyBeanDefinitionRegistryPostProcessor implements BeanDefinitionRegistryPostProcessor {
    @Override
    public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) throws BeansException {
        //定义一个字符串类型的bean
        AbstractBeanDefinition userNameBdf = BeanDefinitionBuilder.
                genericBeanDefinition(String.class).
                addConstructorArgValue("路人").
                getBeanDefinition();
        //将userNameBdf注册到spring容器中
        registry.registerBeanDefinition("userName", userNameBdf);
    }

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {

    }
}
```

#### 同包中来个配置类

```
package com.javacode2018.lesson003.demo3.test0;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig0 {
}
```

#### 测试用例

```
package com.javacode2018.lesson003.demo3;

import com.javacode2018.lesson003.demo3.test0.MainConfig0;
import com.javacode2018.lesson003.demo3.test1.MainConfig1;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class BeanDefinitionRegistryPostProcessorTest {
    @Test
    public void test0() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(MainConfig0.class);
        context.refresh();
        System.out.println(context.getBean("userName"));
    }
}
```

#### 运行输出

```
路人
```

### 案例 2：多个指定顺序

下面我们定义 2 个`BeanDefinitionRegistryPostProcessor`，都实现`Ordered`接口，第一个 order 的值为 2，第二个 order 的值为 1，我们来看一下具体执行的顺序。

#### 第一个

```
package com.javacode2018.lesson003.demo3.test1;

@Component
public class BeanDefinitionRegistryPostProcessor1 implements BeanDefinitionRegistryPostProcessor, Ordered {
    @Override
    public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) throws BeansException {
        System.out.println(String.format("BeanDefinitionRegistryPostProcessor1{order=%d},注册name bean,", this.getOrder()));
        //定义一个bean
        AbstractBeanDefinition nameBdf = BeanDefinitionBuilder.
                genericBeanDefinition(String.class).
                addConstructorArgValue("路人甲java").
                getBeanDefinition();
        //将定义的bean注册到容器
        registry.registerBeanDefinition("name", nameBdf);
    }

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {

    }

    @Override
    public int getOrder() {
        return 2;
    }
}
```

#### 第二个

```
package com.javacode2018.lesson003.demo3.test1;

@Component
public class BeanDefinitionRegistryPostProcessor2 implements BeanDefinitionRegistryPostProcessor, Ordered {
    @Override
    public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) throws BeansException {
        System.out.println(String.format("BeanDefinitionRegistryPostProcessor2{order=%d},注册car bean,", this.getOrder()));
        //定义一个bean
        AbstractBeanDefinition nameBdf = BeanDefinitionBuilder.
                genericBeanDefinition(String.class).
                addConstructorArgValue("保时捷").
                getBeanDefinition();
        //将定义的bean注册到容器
        registry.registerBeanDefinition("car", nameBdf);
    }

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {

    }

    @Override
    public int getOrder() {
        return 1;
    }
}
```

上面 2 个类中的 postProcessBeanDefinitionRegistry 方法第一行都有输出，一个可以通过运行结果看到执行的顺序。

#### 同包中添加配置类

```
package com.javacode2018.lesson003.demo3.test1;

import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class MainConfig1 {
}
```

#### 测试案例

```
@Test
public void test1() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig1.class);
    context.refresh();
    context.getBeansOfType(String.class).forEach((beanName, bean) -> {
        System.out.println(String.format("%s->%s", beanName, bean));
    });
}
```

#### 运行输出

```
BeanDefinitionRegistryPostProcessor2{order=1},注册car bean,
BeanDefinitionRegistryPostProcessor1{order=2},注册name bean,
car->保时捷
name->路人甲java
```

### 小结

`BeanDefinitionRegistryPostProcessor`有个非常重要的实现类：

```
org.springframework.context.annotation.ConfigurationClassPostProcessor
```

这个类可能有些人不熟悉，下面这些注解大家应该比较熟悉吧，这些注解都是在上面这个类中实现的，通过这些注解来实现 bean 的批量注册

```
@Configuration
@ComponentScan
@Import
@ImportResource
@PropertySource
```

有兴趣的朋友可以去看一下`ConfigurationClassPostProcessor#postProcessBeanDefinitionRegistry`研究一下上面这些注解的解析过程，可以学到很多东西。

## 阶段 2：BeanFactory 后置处理阶段

### 概述

到这个阶段的时候，spring 容器已经完成了所有 bean 的注册，这个阶段中你可以对 BeanFactory 中的一些信息进行修改，比如修改阶段 1 中一些 bean 的定义信息，修改 BeanFactory 的一些配置等等，此阶段 spring 也提供了一个接口来进行扩展：`BeanFactoryPostProcessor`，简称`bfpp`，接口中有个方法`postProcessBeanFactory`，spring 会获取容器中所有 BeanFactoryPostProcessor 类型的 bean，然后调用他们的`postProcessBeanFactory`，来看一下这个接口的源码：

```
@FunctionalInterface
public interface BeanFactoryPostProcessor {

    void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException;

}
```

当容器中有多个`BeanFactoryPostProcessor`的时候，可以通过下面任意一种方式来指定顺序

1. 实现`org.springframework.core.PriorityOrdered`接口
2. 实现`org.springframework.core.Ordered`接口

执行顺序：

```
PriorityOrdered.getOrder() asc,Ordered.getOrder() asc
```

下面通过案例来感受一下效果。

### 案例

这个案例中演示，在 BeanFactoryPostProcessor 来修改 bean 中已经注册的 bean 定义的信息，给一个 bean 属性设置一个值。

#### 先来定义一个 bean

```
package com.javacode2018.lesson003.demo3.test2;

import org.springframework.stereotype.Component;

@Component
public class LessonModel {
    //课程名称
    private String name;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "LessonModel{" +
                "name='" + name + '\'' +
                '}';
    }
}
```

上面这个 bean 有个 name 字段，并没有设置值，下面我们在 BeanFactoryPostProcessor 来对其设置值。

#### 自定义的 BeanFactoryPostProcessor

下面代码中，我们先获取`lessonModel`这个 bean 的定义信息，然后给其`name`属性设置了一个值。

```
package com.javacode2018.lesson003.demo3.test2;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.stereotype.Component;

@Component
public class MyBeanFactoryPostProcessor implements BeanFactoryPostProcessor {

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
        System.out.println("准备修改lessonModel bean定义信息!");
        BeanDefinition beanDefinition = beanFactory.getBeanDefinition("lessonModel");
        beanDefinition.getPropertyValues().add("name", "spring高手系列!");
    }

}
```

#### 测试用例

```
@Test
public void test2() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig2.class);
    context.refresh();

    System.out.println(context.getBean(LessonModel.class));
}
```

#### 运行输出

```
准备修改lessonModel bean定义信息!
LessonModel{name='spring高手系列!'}
```

结果中可以看出，通过`BeanFactoryPostProcessor`修改了容器中已经注册的 bean 定义信息。

### 这个接口的几个重要实现类

#### PropertySourcesPlaceholderConfigurer

这个接口做什么的，大家知道么？来看一段代码

```
<bean class="xxxxx">
    <property name="userName" value="${userName}"/>
    <property name="address" value="${address}"/>
</bean>
```

这个大家比较熟悉吧，spring 就是在`PropertySourcesPlaceholderConfigurer#postProcessBeanFactory`中来处理 xml 中属性中的`${xxx}`，会对这种格式的进行解析处理为真正的值。

#### CustomScopeConfigurer

向容器中注册自定义的 Scope 对象，即注册自定义的作用域实现类，关于自定义的作用域，不了解的朋友，建议先看一下：[Spring 系列第 6 篇：玩转 bean scope，避免跳坑里！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933960&idx=1&sn=f4308f8955f87d75963c379c2a0241f4&chksm=88621e76bf159760d404c253fa6716d3ffce4de8df0fc1d0d5dd0cf00a81bc170a30829ee58f&token=1314297026&lang=zh_CN&scene=21#wechat_redirect)

这个用法比较简单，定义一个`CustomScopeConfigurer`的 bean 就可以了，然后通过这个类来注册自定义的 bean。

#### EventListenerMethodProcessor

处理`@EventListener`注解的，即 spring 中事件机制，需要了解 spring 事件的：[spring 事件机制详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934522&idx=1&sn=7653141d01b260875797bbf1305dd196&chksm=88621044bf15995257129e33068f66fc5e39291e159e5e0de367a14e0195595c866b3aaa1972&token=1081910573&lang=zh_CN&scene=21#wechat_redirect)

还有一些实现类，这里就不介绍了。

### 使用注意

`BeanFactoryPostProcessor`接口的使用有一个需要注意的地方，在其`postProcessBeanFactory`方法中，强烈禁止去通过容器获取其他 bean，此时会导致 bean 的提前初始化，会出现一些意想不到的问题，因为这个阶段中`BeanPostProcessor`还未准备好，本文开头 4 个阶段中有介绍，`BeanPostProcessor`是在第 3 个阶段中注册到 spring 容器的，而`BeanPostProcessor`可以对 bean 的创建过程进行干预，比如 spring 中的 aop 就是在`BeanPostProcessor`的一些子类中实现的，`@Autowired`也是在`BeanPostProcessor`的子类中处理的，此时如果去获取 bean，此时 bean 不会被`BeanPostProcessor`处理，所以创建的 bean 可能是有问题的，还是通过一个案例给大家演示一下把，通透一些。

#### 来一个简单的类

```
package com.javacode2018.lesson003.demo3.test3;

import org.springframework.beans.factory.annotation.Autowired;

public class UserModel {
    @Autowired
    private String name; //@1

    @Override
    public String toString() {
        return "UserModel{" +
                "name='" + name + '\'' +
                '}';
    }
}
```

@1：使用了 @Autowired，会指定注入

### 来个配置类

配置类中定义了 2 个 UserModel 类型的 bean：user1、user2

并且定义了一个 String 类型的 bean：name，这个会注入到 UserModel 中的 name 属性中去。

```
package com.javacode2018.lesson003.demo3.test3;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ComponentScan
public class MainConfig3 {
    @Bean
    public UserModel user1() {
        return new UserModel();
    }

    @Bean
    public UserModel user2() {
        return new UserModel();
    }

    @Bean
    public String name() {
        return "路人甲Java,带大家成功java高手!";
    }
}
```

#### 测试用例

输出容器中所有 UserModel 类型的 bean

```
@Test
public void test3() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig3.class);
    context.refresh();

    context.getBeansOfType(UserModel.class).forEach((beanName, bean) -> {
        System.out.println(String.format("%s->%s", beanName, bean));
    });
}
```

#### 运行输出

```
user1->UserModel{name='路人甲Java,带大家成功java高手!'}
user2->UserModel{name='路人甲Java,带大家成功java高手!'}
```

效果不用多解释，大家一看就懂，下面来重点。

### 添加一个 BeanFactoryPostProcessor

在`postProcessBeanFactory`方法中去获取一下 user1 这个 bean

```
package com.javacode2018.lesson003.demo3.test3;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.stereotype.Component;

@Component
public class MyBeanFactoryPostProcessor implements BeanFactoryPostProcessor {

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
        beanFactory.getBean("user1");
    }

}
```

#### 再次运行输出

```
user1->UserModel{name='null'}
user2->UserModel{name='路人甲Java,带大家成功java高手!'}
```

注意，user1 中的 name 变成 null 了，什么情况？

是因为 @Autowired 注解是在`AutowiredAnnotationBeanPostProcessor`中解析的，spring 容器调用`BeanFactoryPostProcessor#postProcessBeanFactory`的使用，此时 spring 容器中还没有`AutowiredAnnotationBeanPostProcessor`，所以此时去获取 user1 这个 bean 的时候，@Autowired 并不会被处理，所以 name 是 null。

## 源码

### 4 个阶段的源码

4 个阶段的源码为位于下面这个方法中

```
org.springframework.context.support.AbstractApplicationContext#refresh
```

这个方法中截取部分代码如下：

```
// 对应阶段1和阶段2：调用上下文中注册为bean的工厂处理器，即调用本文介绍的2个接口中的方法
invokeBeanFactoryPostProcessors(beanFactory);

// 对应阶段3：注册拦截bean创建的bean处理器，即注册BeanPostProcessor
registerBeanPostProcessors(beanFactory);

// 对应阶段3：实例化所有剩余的（非延迟初始化）单例。
finishBeanFactoryInitialization(beanFactory);
```

阶段 1 和阶段 2 的源码位于下面方法中，代码比较简单，强烈建议大家去看一下，几分钟就可以看懂了。

```
org.springframework.context.support.PostProcessorRegistrationDelegate#invokeBeanFactoryPostProcessors(org.springframework.beans.factory.config.ConfigurableListableBeanFactory, java.util.List<org.springframework.beans.factory.config.BeanFactoryPostProcessor>)
```

## 总结

1. **注意 spring 的 4 个阶段：bean 定义阶段、BeanFactory 后置处理阶段、BeanPostProcessor 注册阶段、单例 bean 创建组装阶段**
2. **BeanDefinitionRegistryPostProcessor 会在第一个阶段被调用，用来实现 bean 的注册操作，这个阶段会完成所有 bean 的注册**
3. **BeanFactoryPostProcessor 会在第 2 个阶段被调用，到这个阶段时候，bean 此时已经完成了所有 bean 的注册操作，这个阶段中你可以对 BeanFactory 中的一些信息进行修改，比如修改阶段 1 中一些 bean 的定义信息，修改 BeanFactory 的一些配置等等**
4. **阶段 2 的时候，2 个禁止操作：禁止注册 bean、禁止从容器中获取 bean**
5. **本文介绍的 2 个接口的实现类可以通过****`PriorityOrdered`接口或者`Ordered`接口来指定顺序**

# 30篇：jdk动态代理和cglib代理

小心，99% 的面试者，都倒在了这里。。。

**Spring 中有个非常重要的知识点，AOP，即面相切面编程，spring 中提供的一些非常牛逼的功能都是通过 aop 实现的，比如下面这些大家比较熟悉的功能**

1. **spring 事务管理：@Transactional**
2. **spring 异步处理：@EnableAsync**
3. **spring 缓存技术的使用：@EnableCaching**
4. **spring 中各种拦截器：@EnableAspectJAutoProxy**

大家想玩转 spring，成为一名 spring 高手，aop 是必须要掌握的，aop 这块东西比较多，我们将通过三四篇文章来详解介绍这块的内容，由浅入深，让大家全面掌握这块知识。

说的简单点，spring 中的 aop 就是依靠代理实现的各种功能，通过代理来对 bean 进行增强。

spring 中的 aop 功能主要是通过 2 种代理来实现的

1. jdk 动态代理
2. cglib 代理

继续向下之前，必须先看一下这篇文章：[Spring 系列第 15 篇：代理详解（Java 动态代理 & cglib 代理）？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934082&idx=1&sn=c919886400135a0152da23eaa1f276c7&chksm=88621efcbf1597eab943b064147b8fb8fd3dfbac0dc03f41d15d477ef94b60d4e8f78c66b262&token=1042984313&lang=zh_CN&scene=21#wechat_redirect)

spring aop 中用到了更多的一些特性，上面这边文章中没有介绍到，所以通过本文来做一个补充，这 2 篇文章看过之后，再去看 spring aop 的源码，理解起来会容易一些，这 2 篇算是最基础的知识，所以一定要消化理解，不然 aop 那块的原理你很难了解，会晕车，

## jdk 动态代理

### 特征

1. 只能为接口创建代理对象
2. 创建出来的代理都是 java.lang.reflect.Proxy 的子类

### 案例

案例源码位置：

```
com.javacode2018.aop.demo1.JdkAopTest1
```

有 2 个接口

```
interface IService1 {
    void m1();
}

interface IService2 {
    void m2();
}
```

下面的类实现了上面 2 个接口

```
public static class Service implements IService1, IService2 {
    @Override
    public void m1() {
        System.out.println("我是m1");
    }

    @Override
    public void m2() {
        System.out.println("我是m2");
    }
}
```

下面通过 jdk 动态代理创建一个代理对象，实现上面定义的 2 个接口，将代理对象所有的请求转发给 Service 去处理，需要在代理中统计 2 个接口中所有方法的耗时。

比较简单，自定义一个 InvocationHandler

```
public static class CostTimeInvocationHandler implements InvocationHandler {

    private Object target;

    public CostTimeInvocationHandler(Object target) {
        this.target = target;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        long startime = System.nanoTime();
        Object result = method.invoke(this.target, args); //将请求转发给target去处理
        System.out.println(method + "，耗时(纳秒):" + (System.nanoTime() - startime));
        return result;
    }
}
```

测试方法

```
{
    Service target = new Service();
    CostTimeInvocationHandler costTimeInvocationHandler = new CostTimeInvocationHandler(target);
    //创建代理对象
    Object proxyObject = Proxy.newProxyInstance(
            target.getClass().getClassLoader(),
            new Class[]{IService1.class, IService2.class}, //创建的代理对象实现了2个接口
            costTimeInvocationHandler);
    //判断代理对象是否是Service类型的，肯定是false咯
    System.out.println(String.format("proxyObject instanceof Service = %s", proxyObject instanceof Service));
    //判断代理对象是否是IService1类型的，肯定是true
    System.out.println(String.format("proxyObject instanceof IService1 = %s", proxyObject instanceof IService1));
    //判断代理对象是否是IService2类型的，肯定是true
    System.out.println(String.format("proxyObject instanceof IService2 = %s", proxyObject instanceof IService2));

    //将代理转换为IService1类型
    IService1 service1 = (IService1) proxyObject;
    //调用IService2的m1方法
    service1.m1();
    //将代理转换为IService2类型
    IService2 service2 = (IService2) proxyObject;
    //调用IService2的m2方法
    service2.m2();
    //输出代理的类型
    System.out.println("代理对象的类型:" + proxyObject.getClass());
}
```

运行输出

```
proxyObject instanceof Service = false
proxyObject instanceof IService1 = true
proxyObject instanceof IService2 = true
我是m1
public abstract void com.javacode2018.aop.demo1.JdkAopTest1$IService1.m1()，耗时(纳秒):225600
我是m2
public abstract void com.javacode2018.aop.demo1.JdkAopTest1$IService2.m2()，耗时(纳秒):36000
代理对象的类型:class com.javacode2018.aop.demo1.$Proxy0
```

m1 方法和 m2 方法被`CostTimeInvocationHandler#invoke`给增强了，调用目标方法的过程中统计了耗时。

最后一行输出可以看出代理对象的类型，类名中包含了`$Proxy`的字样，所以以后注意，看到这种字样的，基本上都是通过 jdk 动态代理创建的代理对象。

下面来说 cglib 代理的一些特殊案例。

## cglib 代理

### cglib 的特点

1. **cglib 弥补了 jdk 动态代理的不足，jdk 动态代理只能为接口创建代理，而 cglib 非常强大，不管是接口还是类，都可以使用 cglib 来创建代理**
2. **cglib 创建代理的过程，相当于创建了一个新的类，可以通过 cglib 来配置这个新的类需要实现的接口，以及需要继承的父类**
3. **cglib 可以为类创建代理，但是这个类不能是 final 类型的，cglib 为类创建代理的过程，实际上为通过继承来实现的，相当于给需要被代理的类创建了一个子类，然后会重写父类中的方法，来进行增强，继承的特性大家应该都知道，final 修饰的类是不能被继承的，final 修饰的方法不能被重写，static 修饰的方法也不能被重写，private 修饰的方法也不能被\**子\**类重写，而其他类型的方法都可以被子类重写，被重写的这些方法可以通过 cglib 进行拦截增强**

### cglib 整个过程如下

1. Cglib 根据父类, Callback, Filter 及一些相关信息生成 key
2. 然后根据 key 生成对应的子类的二进制表现形式
3. 使用 ClassLoader 装载对应的二进制, 生成 Class 对象, 并缓存
4. 最后实例化 Class 对象, 并缓存

### 案例 1：为多个接口创建代理

代码比较简单，定义了 2 个接口，然后通过 cglib 来创建一个代理类，代理类会实现这 2 个接口，通过 setCallback 来对 2 个接口的方法进行增强。

```
public class CglibTest1 {
    interface IService1 {
        void m1();
    }

    interface IService2 {
        void m2();
    }

    public static void main(String[] args) {
        Enhancer enhancer = new Enhancer();
        //设置代理对象需要实现的接口
        enhancer.setInterfaces(new Class[]{IService1.class, IService2.class});
        //通过Callback来对被代理方法进行增强
        enhancer.setCallback(new MethodInterceptor() {
            @Override
            public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
                System.out.println("方法：" + method.getName());
                return null;
            }
        });
        Object proxy = enhancer.create();
        if (proxy instanceof IService1) {
            ((IService1) proxy).m1();
        }
        if (proxy instanceof IService2) {
            ((IService2) proxy).m2();
        }
        //看一下代理对象的类型
        System.out.println(proxy.getClass());
        //看一下代理类实现的接口
        System.out.println("创建代理类实现的接口如下：");
        for (Class<?> cs : proxy.getClass().getInterfaces()) {
            System.out.println(cs);
        }
    }
}
```

运行输出

```
方法：m1
方法：m2
class com.javacode2018.aop.demo2.CglibTest1$IService1$$EnhancerByCGLIB$$1d32a82
创建代理类实现的接口如下：
interface com.javacode2018.aop.demo2.CglibTest1$IService1
interface com.javacode2018.aop.demo2.CglibTest1$IService2
interface org.springframework.cglib.proxy.Factory
```

上面创建的代理类相当于下面代码

```
public class CglibTest1$IService1$$EnhancerByCGLIB$$1d32a82 implements IService1, IService2 {
    @Override
    public void m1() {
        System.out.println("方法：m1");
    }

    @Override
    public void m2() {
        System.out.println("方法：m2");

    }
}
```

### 案例 2：为类和接口同时创建代理

下面定义了 2 个接口：IService1 和 IService2，2 个接口有个实现类：Service，然后通过 cglib 创建了个代理类，实现了这 2 个接口，并且将 Service 类作为代理类的父类。

```
public class CglibTest2 {
    interface IService1 {
        void m1();
    }

    interface IService2 {
        void m2();
    }

    public static class Service implements IService1, IService2 {
        @Override
        public void m1() {
            System.out.println("m1");
        }

        @Override
        public void m2() {
            System.out.println("m2");
        }
    }

    public static void main(String[] args) {
        Enhancer enhancer = new Enhancer();
        //设置代理类的父类
        enhancer.setSuperclass(Service.class);
        //设置代理对象需要实现的接口
        enhancer.setInterfaces(new Class[]{IService1.class, IService2.class});
        //通过Callback来对被代理方法进行增强
        enhancer.setCallback(new MethodInterceptor() {
            @Override
            public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
                long startime = System.nanoTime();
                Object result = methodProxy.invokeSuper(o, objects); //调用父类中的方法
                System.out.println(method + "，耗时(纳秒):" + (System.nanoTime() - startime));
                return result;
            }
        });
        //创建代理对象
        Object proxy = enhancer.create();
        //判断代理对象是否是Service类型的
        System.out.println("proxy instanceof Service" + (proxy instanceof Service));
        if (proxy instanceof Service) {
            Service service = (Service) proxy;
            service.m1();
            service.m2();
        }
        //看一下代理对象的类型
        System.out.println(proxy.getClass());
        //输出代理对象的父类
        System.out.println("代理类的父类：" + proxy.getClass().getSuperclass());
        //看一下代理类实现的接口
        System.out.println("创建代理类实现的接口如下：");
        for (Class<?> cs : proxy.getClass().getInterfaces()) {
            System.out.println(cs);
        }
    }
}
```

运行输出

```
proxy instanceof Servicetrue
m1
public void com.javacode2018.aop.demo2.CglibTest2$Service.m1()，耗时(纳秒):14219700
m2
public void com.javacode2018.aop.demo2.CglibTest2$Service.m2()，耗时(纳秒):62800
class com.javacode2018.aop.demo2.CglibTest2$Service$$EnhancerByCGLIB$$80494536
代理类的父类：class com.javacode2018.aop.demo2.CglibTest2$Service
创建代理类实现的接口如下：
interface com.javacode2018.aop.demo2.CglibTest2$IService1
interface com.javacode2018.aop.demo2.CglibTest2$IService2
interface org.springframework.cglib.proxy.Factory
```

输出中可以代理对象的类型是：

```
class com.javacode2018.aop.demo2.CglibTest2$Service$$EnhancerByCGLIB$$80494536
```

带有`$$EnhancerByCGLIB$$`字样的，在调试 spring 的过程中，发现有这样字样的，基本上都是 cglib 创建的代理对象。

上面创建的代理类相当于下面代码

```
public class CglibTest2$Service$$EnhancerByCGLIB$$80494536 extends Service implements IService1, IService2 {
    @Override
    public void m1() {
        long starttime = System.nanoTime();
        super.m1();
        System.out.println("方法m1，耗时(纳秒):" + (System.nanoTime() - starttime));
    }

    @Override
    public void m2() {
        long starttime = System.nanoTime();
        super.m1();
        System.out.println("方法m1，耗时(纳秒):" + (System.nanoTime() - starttime));
    }
}
```

### 案例 3：LazyLoader 的使用

LazyLoader 是 cglib 用于实现懒加载的 callback。当被增强 bean 的方法初次被调用时，会触发回调，之后每次再进行方法调用都是对 LazyLoader 第一次返回的 bean 调用，hibernate 延迟加载有用到过这个。

看案例吧，通过案例理解容易一些。

```
public class LazyLoaderTest1 {

    public static class UserModel {
        private String name;

        public UserModel() {
        }

        public UserModel(String name) {
            this.name = name;
        }

        public void say() {
            System.out.println("你好：" + name);
        }
    }

    public static void main(String[] args) {
        Enhancer enhancer = new Enhancer();
        enhancer.setSuperclass(UserModel.class);
        //创建一个LazyLoader对象
        LazyLoader lazyLoader = new LazyLoader() {
            @Override
            public Object loadObject() throws Exception {
                System.out.println("调用LazyLoader.loadObject()方法");
                return new UserModel("路人甲java");
            }
        };
        enhancer.setCallback(lazyLoader);
        Object proxy = enhancer.create();
        UserModel userModel = (UserModel) proxy;
        System.out.println("第1次调用say方法");
        userModel.say();
        System.out.println("第1次调用say方法");
        userModel.say();
    }
}
```

运行输出

```
第1次调用say方法
调用LazyLoader.loadObject()方法
你好：路人甲java
第1次调用say方法
你好：路人甲java
```

当第 1 次调用 say 方法的时候，会被 cglib 拦截，进入 lazyLoader 的 loadObject 内部，将这个方法的返回值作为 say 方法的调用者，loadObject 中返回了一个`路人甲Java`的 UserModel，cglib 内部会将 loadObject 方法的返回值和 say 方法关联起来，然后缓存起来，而第 2 次调用 say 方法的时候，通过方法名去缓存中找，会直接拿到第 1 次返回的 UserModel，所以第 2 次不会进入到 loadObject 方法中了。

将下代码拆分开来

```
System.out.println("第1次调用say方法");
userModel.say();
System.out.println("第1次调用say方法");
userModel.say();
```

相当于下面的代码

```
System.out.println("第1次调用say方法");
System.out.println("调用LazyLoader.loadObject()方法");
userModel = new UserModel("路人甲java");
userModel.say();
System.out.println("第1次调用say方法");
userModel.say();
```

下面通过 LazyLoader 实现延迟加载的效果。

### 案例 4：LazyLoader 实现延迟加载

博客的内容一般比较多，需要用到内容的时候，我们再去加载，下面来模拟博客内容延迟加载的效果。

```
public class LazyLoaderTest2 {
    //博客信息
    public static class BlogModel {
        private String title;
        //博客内容信息比较多，需要的时候再去获取
        private BlogContentModel blogContentModel;

        public BlogModel() {
            this.title = "spring aop详解!";
            this.blogContentModel = this.getBlogContentModel();
        }

        private BlogContentModel getBlogContentModel() {
            Enhancer enhancer = new Enhancer();
            enhancer.setSuperclass(BlogContentModel.class);
            enhancer.setCallback(new LazyLoader() {
                @Override
                public Object loadObject() throws Exception {
                    //此处模拟从数据库中获取博客内容
                    System.out.println("开始从数据库中获取博客内容.....");
                    BlogContentModel result = new BlogContentModel();
                    result.setContent("欢迎大家和我一起学些spring，我们一起成为spring高手！");
                    return result;
                }
            });
            return (BlogContentModel) enhancer.create();
        }
    }

    //表示博客内容信息
    public static class BlogContentModel {
        //博客内容
        private String content;

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }
    }

    public static void main(String[] args) {
        //创建博客对象
        BlogModel blogModel = new BlogModel();
        System.out.println(blogModel.title);
        System.out.println("博客内容");
        System.out.println(blogModel.blogContentModel.getContent()); //@1
    }
}
```

@1：调用 blogContentModel.getContent() 方法的时候，才会通过 LazyLoader#loadObject 方法从 db 中获取到博客内容信息

运行输出

```
spring aop详解!
博客内容
开始从数据库中获取博客内容.....
欢迎大家和我一起学些spring，我们一起成为spring高手！
```

### 案例 5：Dispatcher

Dispatcher 和 LazyLoader 作用很相似，区别是用 Dispatcher 的话每次对增强 bean 进行方法调用都会触发回调。

看案例代码

```
public class DispatcherTest1 {
    public static class UserModel {
        private String name;

        public UserModel() {
        }

        public UserModel(String name) {
            this.name = name;
        }

        public void say() {
            System.out.println("你好：" + name);
        }
    }

    public static void main(String[] args) {
        Enhancer enhancer = new Enhancer();
        enhancer.setSuperclass(LazyLoaderTest1.UserModel.class);
        //创建一个Dispatcher对象
        Dispatcher dispatcher = new Dispatcher() {
            @Override
            public Object loadObject() throws Exception {
                System.out.println("调用Dispatcher.loadObject()方法");
                return new LazyLoaderTest1.UserModel("路人甲java," + UUID.randomUUID().toString());
            }
        };
        enhancer.setCallback(dispatcher);
        Object proxy = enhancer.create();
        LazyLoaderTest1.UserModel userModel = (LazyLoaderTest1.UserModel) proxy;
        System.out.println("第1次调用say方法");
        userModel.say();
        System.out.println("第1次调用say方法");
        userModel.say();
    }
}
```

运行输出

```
第1次调用say方法
调用Dispatcher.loadObject()方法
你好：路人甲java,514f911e-06ac-4e3b-aee4-595f82c16a5f
第1次调用say方法
调用Dispatcher.loadObject()方法
你好：路人甲java,bc062990-bc16-4226-97e3-b1b321a03468
```

### 案例 6：通过 Dispathcer 对类扩展一些接口

下面有个 UserService 类，我们需要对这个类创建一个代理。

代码中还定义了一个接口：IMethodInfo，用来统计被代理类的一些方法信息，有个实现类：DefaultMethodInfo。

通过 cglib 创建一个代理类，父类为 UserService，并且实现 IMethodInfo 接口，将接口 IMethodInfo 所有方法的转发给 DefaultMethodInfo 处理，代理类中的其他方法，转发给其父类 UserService 处理。

这个代码相当于对 UserService 这个类进行了增强，使其具有了 IMethodInfo 接口中的功能。

```
public class DispatcherTest2 {

    public static class UserService {
        public void add() {
            System.out.println("新增用户");
        }

        public void update() {
            System.out.println("更新用户信息");
        }
    }

    //用来获取方法信息的接口
    public interface IMethodInfo {
        //获取方法数量
        int methodCount();

        //获取被代理的对象中方法名称列表
        List<String> methodNames();
    }

    //IMethodInfo的默认实现
    public static class DefaultMethodInfo implements IMethodInfo {

        private Class<?> targetClass;

        public DefaultMethodInfo(Class<?> targetClass) {
            this.targetClass = targetClass;
        }

        @Override
        public int methodCount() {
            return targetClass.getDeclaredMethods().length;
        }

        @Override
        public List<String> methodNames() {
            return Arrays.stream(targetClass.getDeclaredMethods()).
                    map(Method::getName).
                    collect(Collectors.toList());
        }
    }

    public static void main(String[] args) {
        Class<?> targetClass = UserService.class;
        Enhancer enhancer = new Enhancer();
        //设置代理的父类
        enhancer.setSuperclass(targetClass);
        //设置代理需要实现的接口列表
        enhancer.setInterfaces(new Class[]{IMethodInfo.class});
        //创建一个方法统计器
        IMethodInfo methodInfo = new DefaultMethodInfo(targetClass);
        //创建会调用器列表，此处定义了2个，第1个用于处理UserService中所有的方法，第2个用来处理IMethodInfo接口中的方法
        Callback[] callbacks = {
                new MethodInterceptor() {
                    @Override
                    public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
                        return methodProxy.invokeSuper(o, objects);
                    }
                },
                new Dispatcher() {
                    @Override
                    public Object loadObject() throws Exception {
                        /**
                         * 用来处理代理对象中IMethodInfo接口中的所有方法
                         * 所以此处返回的为IMethodInfo类型的对象，
                         * 将由这个对象来处理代理对象中IMethodInfo接口中的所有方法
                         */
                        return methodInfo;
                    }
                }
        };
        enhancer.setCallbacks(callbacks);
        enhancer.setCallbackFilter(new CallbackFilter() {
            @Override
            public int accept(Method method) {
                //当方法在IMethodInfo中定义的时候，返回callbacks中的第二个元素
                return method.getDeclaringClass() == IMethodInfo.class ? 1 : 0;
            }
        });

        Object proxy = enhancer.create();
        //代理的父类是UserService
        UserService userService = (UserService) proxy;
        userService.add();
        //代理实现了IMethodInfo接口
        IMethodInfo mf = (IMethodInfo) proxy;
        System.out.println(mf.methodCount());
        System.out.println(mf.methodNames());
    }
}
```

运行输出

```
新增用户
2
[add, update]
```

### 案例 7：cglib 中的 NamingPolicy 接口

接口 NamingPolicy 表示生成代理类的名字的策略，通过`Enhancer.setNamingPolicy`方法设置命名策略。

默认的实现类：DefaultNamingPolicy， 具体 cglib 动态生成类的命名控制。

DefaultNamingPolicy 中有个 getTag 方法。

DefaultNamingPolicy 生成的代理类的类名命名规则：

```
被代理class name + "$$" + 使用cglib处理的class name + "ByCGLIB" + "$$" + key的hashcode
```

如：

```
com.javacode2018.aop.demo2.DispatcherTest2$UserService$$EnhancerByCGLIB$$e7ec0be5@17d10166
```

自定义 NamingPolicy，通常会继承 DefaultNamingPolicy 来实现，spring 中默认就提供了一个，如下

```
public class SpringNamingPolicy extends DefaultNamingPolicy {

    public static final SpringNamingPolicy INSTANCE = new SpringNamingPolicy();

    @Override
    protected String getTag() {
        return "BySpringCGLIB";
    }

}
```

案例代码

```
public class NamingPolicyTest {
    public static void main(String[] args) {
        Enhancer enhancer = new Enhancer();
        enhancer.setSuperclass(NamingPolicyTest.class);
        enhancer.setCallback(NoOp.INSTANCE);
        //通过Enhancer.setNamingPolicy来设置代理类的命名策略
        enhancer.setNamingPolicy(new DefaultNamingPolicy() {
            @Override
            protected String getTag() {
                return "-test-";
            }
        });
        Object proxy = enhancer.create();
        System.out.println(proxy.getClass());
    }
}
```

输出

```
class com.javacode2018.aop.demo2.NamingPolicyTest$$Enhancer-test-$$5946713
```

## Objenesis：实例化对象的一种方式

先来看一段代码，有一个有参构造函数：

```
public static class User {
    private String name;

    public User(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "User{" +
                "name='" + name + '\'' +
                '}';
    }
}
```

**大家来思考一个问题：如果不使用这个有参构造函数的情况下，如何创建这个对象？**

通过反射？大家可以试试，如果不使用有参构造函数，是无法创建对象的。

cglib 中提供了一个接口：Objenesis，通过这个接口可以解决上面这种问题，它专门用来创建对象，即使你没有空的构造函数，都木有问题，它不使用构造方法创建 Java 对象，所以即使你有空的构造方法，也是不会执行的。

用法比较简单：

```
@Test
public void test1() {
    Objenesis objenesis = new ObjenesisStd();
    User user = objenesis.newInstance(User.class);
    System.out.println(user);
}
```

输出

```
User{name='null'}
```

大家可以在 User 类中加一个默认构造函数，来验证一下上面的代码会不会调用默认构造函数？

```
public User() {
    System.out.println("默认构造函数");
}
```

再次运行会发现，并不会调用默认构造函数。

如果需要多次创建 User 对象，可以写成下面方式重复利用

```
@Test
public void test2() {
    Objenesis objenesis = new ObjenesisStd();
    ObjectInstantiator<User> userObjectInstantiator = objenesis.getInstantiatorOf(User.class);
    User user1 = userObjectInstantiator.newInstance();
    System.out.println(user1);
    User user2 = userObjectInstantiator.newInstance();
    System.out.println(user2);
    System.out.println(user1 == user2);
}
```

运行输出

```
User{name='null'}
User{name='null'}
false
```

代码位置

```
com.javacode2018.aop.demo2.CreateObjectTest
```

## 总结

1. **代理这 2 篇文章是 spring aop 的基础，基础牢靠了，才能走的更远，大家一定要将这 2 篇文章中的内容吃透，全面掌握 jdk 动态代理和 cglib 代理的使用**
2. 这些知识点 spring aop 中全部都用到了，大家消化一下，下一篇讲解 spring aop 具体是如何玩的

