Aop 相关阅读
--------

阅读本文之前，需要先掌握下面 3 篇文章内容，不然会比较吃力。

1.  [Spring 系列第 15 篇：代理详解（java 动态代理 & CGLIB 代理)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934082&idx=1&sn=c919886400135a0152da23eaa1f276c7&chksm=88621efcbf1597eab943b064147b8fb8fd3dfbac0dc03f41d15d477ef94b60d4e8f78c66b262&token=1042984313&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [Spring 系列第 30 篇：jdk 动态代理和 cglib 代理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934783&idx=1&sn=5531f14475a4addc6d4d47f0948b3208&chksm=88621141bf159857bc19d7bb545ed3ddc4152dcda9e126f27b83afc2e975dee1682de2d98ad6&token=1672930952&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Spring 系列第 31 篇：Aop 概念详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934876&idx=1&sn=7794b50e658e0ec3e0aff6cf5ed4aa2e&chksm=886211e2bf1598f4e0e636170a4b36a5a5edd8811c8b7c30d61135cb114b0ce506a6fa84df0b&token=1672930952&lang=zh_CN&scene=21#wechat_redirect)
    
4.  [Spring 系列第 32 篇：AOP 核心源码、原理详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934930&idx=1&sn=4030960657cc72006122ef8b6f0de889&scene=21#wechat_redirect)
    
5.  [Spring 系列第 33 篇：ProxyFactoryBean 创建 AOP 代理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934977&idx=1&sn=8e4caf6a17bf5e123884df81a6382214&scene=21#wechat_redirect)
    

本文继续 AOP，目前手动 Aop 中三种方式已经介绍 2 种了，本文将介绍另外一种：`AspectJProxyFactory`，可能大家对这个比较陌生，但是`@Aspect`这个注解大家应该很熟悉吧，通过这个注解在 spring 环境中实现 aop 特别的方便。

而`AspectJProxyFactory`这个类可以通过解析`@Aspect`标注的类来生成代理 aop 代理对象，对开发者来说，使创建代理变的更简洁了。

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06Bib15BbgLkWfMpOhWMYdDc7DE6GbcrACxeBv0xAAqzLNNDZEEgoW0w8UrLQAkVsPP37cqoQ2hYHxg/640?wx_fmt=png)

先了解几个概念
-------

文中会涉及几个概念，先了解一下。

### target

用来表示目标对象，即需要通过 aop 来增强的对象。

### proxy

代理对象，target 通过 aop 增强之后生成的代理对象。

AspectJ
-------

### AspectJ 是什么?

AspectJ 是一个面向切面的框架，是目前最好用，最方便的 AOP 框架，和 spring 中的 aop 可以集成在一起使用，通过 Aspectj 提供的一些功能实现 aop 代理变得非常方便。

### AspectJ 使用步骤

```
1.创建一个类，使用@Aspect标注
2.@Aspect标注的类中，通过@Pointcut定义切入点
3.@Aspect标注的类中，通过AspectJ提供的一些通知相关的注解定义通知
4.使用AspectJProxyFactory结合@Ascpect标注的类，来生成代理对象


```

先来个案例，感受一下 AspectJ 是多么的方便。

来个类

```
package com.javacode2018.aop.demo9.test1;

public class Service1 {

    public void m1() {
        System.out.println("我是 m1 方法");
    }

    public void m2() {
        System.out.println(10 / 0);
        System.out.println("我是 m2 方法");
    }
}


```

通过`AspectJ`来对`Service1`进行增强，来 2 个通知，一个前置通知，一个异常通知，这 2 个通知需要对`Service1`中的所有方法生效，实现如下：

```
package com.javacode2018.aop.demo9.test1;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

//@1：这个类需要使用@Aspect进行标注
@Aspect
public class Aspect1 {

    //@2：定义了一个切入点，可以匹配Service1中所有方法
    @Pointcut("execution(* com.javacode2018.aop.demo9.test1.Service1.*(..))")
    public void pointcut1() {
    }

    //@3：定义了一个前置通知，这个通知对刚刚上面我们定义的切入点中的所有方法有效
    @Before(value = "pointcut1()")
    public void before(JoinPoint joinPoint) {
        //输出连接点的信息
        System.out.println("前置通知，" + joinPoint);
    }

    //@4：定义了一个异常通知，这个通知对刚刚上面我们定义的切入点中的所有方法有效
    @AfterThrowing(value = "pointcut1()", throwing = "e")
    public void afterThrowing(JoinPoint joinPoint, Exception e) {
        //发生异常之后输出异常信息
        System.out.println(joinPoint + ",发生异常：" + e.getMessage());
    }

}


```

> @1：类上使用 @Aspect 标注
> 
> @2：通过 @Pointcut 注解标注在方法上面，用来定义切入点
> 
> @3：使用 @Before 标注在方法上面，定义了一个前置通知，通过 value 引用了上面已经定义的切入点，表示这个通知会对 Service1 中的所有方法生效，在通知中可以通过这个`类名.方法名()`引用`@Pointcut`定义的切入点，表示这个通知对这些切入点有效，若`@Before和@Pointcut`在一个类的时候，直接通过`方法名()`引用当前类中定义的切入点
> 
> @4：这个使用`@AfterThrowing`定义了一个异常通知，也是对通过 value 引用了上面已经定义的切入点，表示这个通知会对 Service1 中的所有方法生效，若 Service1 中的方法抛出了 Exception 类型的异常，都会回调`afterThrowing`方法。

来个测试类

```
package com.javacode2018.aop.demo9;

import com.javacode2018.aop.demo9.test1.Aspect1;
import com.javacode2018.aop.demo9.test1.Service1;
import org.junit.Test;
import org.springframework.aop.aspectj.annotation.AspectJProxyFactory;

public class AopTest9 {
    @Test
    public void test1() {
        try {
            //对应目标对象
            Service1 target = new Service1();
            //创建AspectJProxyFactory对象
            AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
            //设置被代理的目标对象
            proxyFactory.setTarget(target);
            //设置标注了@Aspect注解的类
            proxyFactory.addAspect(Aspect1.class);
            //生成代理对象
            Service1 proxy = proxyFactory.getProxy();
            //使用代理对象
            proxy.m1();
            proxy.m2();
        } catch (Exception e) {
        }
    }
}


```

运行输出

```
前置通知，execution(void com.javacode2018.aop.demo9.test1.Service1.m1())
我是 m1 方法
前置通知，execution(void com.javacode2018.aop.demo9.test1.Service1.m2())
execution(void com.javacode2018.aop.demo9.test1.Service1.m2()),发生异常：/ by zero


```

使用是不是特方便。

### AspectJProxyFactory 原理

`@Aspect`标注的类上，这个类中，可以通过通过`@Pointcut`来定义切入点，可以通过`@Before、@Around、@After、@AfterRunning、@AfterThrowing`标注在方法上来定义通知，定义好了之后，将`@Aspect`标注的这个类交给`AspectJProxyFactory`来解析生成`Advisor`链，进而结合目标对象一起来生成代理对象，大家可以去看一下源码，比较简单，这里就不多解释了。

本文的重点在`@Aspect`标注的类上，`@Aspect`中有 2 个关键点比较重要

*   @Pointcut：标注在方法上，用来定义切入点，有 11 种用法，本文主要讲解这 11 种用法。
    
*   @Aspect 类中定义通知：可以通过`@Before、@Around、@After、@AfterRunning、@AfterThrowing`标注在方法上来定义通知，这个下一篇介绍。
    

@Pointcut 的 12 种用法
------------------

### 作用

用来标注在方法上来定义切入点。

### 定义

格式：@ 注解 (value=“表达标签 (表达式格式)”)

如：

```
@Pointcut("execution(* com.javacode2018.aop.demo9.test1.Service1.*(..))")


```

### 表达式标签（10 种）

*   execution：用于匹配方法执行的连接点
    
*   within：用于匹配指定类型内的方法执行
    
*   this：用于匹配当前 AOP 代理对象类型的执行方法；注意是 AOP 代理对象的类型匹配，这样就可能包括引入接口也类型匹配
    
*   target：用于匹配当前目标对象类型的执行方法；注意是目标对象的类型匹配，这样就不包括引入接口也类型匹配
    
*   args：用于匹配当前执行的方法传入的参数为指定类型的执行方法
    
*   @within：用于匹配所以持有指定注解类型内的方法
    
*   @target：用于匹配当前目标对象类型的执行方法，其中目标对象持有指定的注解
    
*   @args：用于匹配当前执行的方法传入的参数持有指定注解的执行
    
*   @annotation：用于匹配当前执行方法持有指定注解的方法
    
*   bean：Spring AOP 扩展的，AspectJ 没有对于指示符，用于匹配特定名称的 Bean 对象的执行方法
    

**10 种标签组成了 12 种用法**

### 1、execution

使用`execution(方法表达式)`匹配方法执行。

#### execution 格式

```
execution(modifiers-pattern? ret-type-pattern declaring-type-pattern? name-pattern(param-pattern) throws-pattern?)


```

*   其中带 ? 号的 modifiers-pattern?，declaring-type-pattern?，hrows-pattern? 是可选项
    
*   ret-type-pattern,name-pattern, parameters-pattern 是必选项
    
*   modifier-pattern? 修饰符匹配，如 public 表示匹配公有方法
    
*   ret-type-pattern 返回值匹配，* 表示任何返回值，全路径的类名等
    
*   declaring-type-pattern? 类路径匹配
    
*   name-pattern 方法名匹配，* 代表所有，set*，代表以 set 开头的所有方法
    
*   (param-pattern) 参数匹配，指定方法参数 (声明的类型)，(..) 代表所有参数，(*,String)代表第一个参数为任何值, 第二个为 String 类型，(..,String)代表最后一个参数是 String 类型
    
*   throws-pattern? 异常类型匹配
    

#### 举例说明

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06Bib15BbgLkWfMpOhWMYdDc7f0fbML6PrbbMyGBY6vzGZiaAIzLiaEglLnrcQRbNlI7lNC2dC85fDFYw/640?wx_fmt=png)

#### 类型匹配语法  

很多地方会按照类型的匹配，先来说一下类型匹配的语法。

首先让我们来了解下 AspectJ 类型匹配的通配符：

*   *****：匹配任何数量字符
    
*   **..**：匹配任何数量字符的重复，如在类型模式中匹配任何数量子包；而在方法参数模式中匹配任何数量参数（0 个或者多个参数）
    
*   **+：**匹配指定类型及其子类型；仅能作为后缀放在类型模式后边
    

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06Bib15BbgLkWfMpOhWMYdDc7V3lk3RF4NysjaQAI3QaOeVy09yAlQ9sYib8Dq1K3Bw3Zg6g22d5FCGw/640?wx_fmt=png)

### 2、within

#### 用法

`within(类型表达式)`：目标对象 target 的类型是否和 within 中指定的类型匹配

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06Bib15BbgLkWfMpOhWMYdDc7YpA3UhE2LibKA2W5OmdbexxHYQsjG9fq0spBcibBTvpLP6iccSYSYicEsg/640?wx_fmt=png)

#### 匹配原则

```
target.getClass().equals(within表达式中指定的类型)


```

#### 案例

有 2 个类，父子关系

父类 C1

```
package com.javacode2018.aop.demo9.test2;

public class C1 {
    public void m1() {
        System.out.println("我是m1");
    }

    public void m2() {
        System.out.println("我是m2");
    }
}


```

子类 C2

```
package com.javacode2018.aop.demo9.test2;

public class C2 extends C1 {
    @Override
    public void m2() {
        super.m2();
    }

    public void m3() {
        System.out.println("我是m3");
    }
}


```

来个 Aspect 类

```
package com.javacode2018.aop.demo9.test2;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class AspectTest2 {

    @Pointcut("within(C1)") //@1
    public void pc() {
    }

    @Before("pc()") //@2
    public void beforeAdvice(JoinPoint joinpoint) {
        System.out.println(joinpoint);
    }

}


```

> 注意`@1`匹配的类型是`C1`，也就是说被代理的对象的类型必须是 C1 类型的才行，需要和 C1 完全匹配

下面我们对`C2`创建代理

```
@Test
public void test2(){
    C2 target = new C2();
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(AspectTest2.class);

    C2 proxy = proxyFactory.getProxy();
    proxy.m1();
    proxy.m2();
    proxy.m3();
}


```

运行输出

```
我是m1
我是m2
我是m3


```

原因是目标对象是 C2 类型的，C2 虽然是 C1 的子类，但是 within 中表达式指定的是要求类型必须是 C1 类型的才匹配。

如果将 within 表达式修改为下面任意一种就可以匹配了

```
@Pointcut("within(C1+)") 
@Pointcut("within(C2)") 


```

再次运行输出

```
execution(void com.javacode2018.aop.demo9.test2.C1.m1())
我是m1
execution(void com.javacode2018.aop.demo9.test2.C2.m2())
我是m2
execution(void com.javacode2018.aop.demo9.test2.C2.m3())
我是m3


```

### 3、this

#### 用法

`this(类型全限定名)`：通过 aop 创建的代理对象的类型是否和 this 中指定的类型匹配；注意判断的目标是代理对象；this 中使用的表达式必须是类型全限定名，不支持通配符。

#### 匹配原则

```
如:this(x)，则代理对象proxy满足下面条件时会匹配
x.getClass().isAssignableFrom(proxy.getClass());


```

#### 案例

来个接口

```
package com.javacode2018.aop.demo9.test3;

public interface I1 {
    void m1();
}


```

来个实现类

```
package com.javacode2018.aop.demo9.test3;

public class Service3 implements I1 {

    @Override
    public void m1() {
        System.out.println("我是m1");
    }

}


```

来个 @Aspect 类

```
package com.javacode2018.aop.demo9.test3;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class AspectTest3 {

    //@1：匹配proxy是Service3类型的所有方法
    @Pointcut("this(Service3)")
    public void pc() {
    }

    @Before("pc()")
    public void beforeAdvice(JoinPoint joinpoint) {
        System.out.println(joinpoint);
    }

}


```

测试代码

```
@Test
public void test3() {
    Service3 target = new Service3();
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    //获取目标对象上的接口列表
    Class<?>[] allInterfaces = ClassUtils.getAllInterfaces(target);
    //设置需要代理的接口
    proxyFactory.setInterfaces(allInterfaces);
    proxyFactory.addAspect(AspectTest3.class);
    //获取代理对象
    Object proxy = proxyFactory.getProxy();
    //调用代理对象的方法
    ((I1) proxy).m1();

    System.out.println("proxy是否是jdk动态代理对象：" + AopUtils.isJdkDynamicProxy(proxy));
    System.out.println("proxy是否是cglib代理对象：" + AopUtils.isCglibProxy(proxy));
    //判断代理对象是否是Service3类型的
    System.out.println(Service3.class.isAssignableFrom(proxy.getClass()));
}


```

运行输出

```
我是m1
proxy是否是jdk动态代理对象：true
proxy是否是cglib代理对象：false
false


```

从输出中可以看出 m1 方法没有被增强，原因：this 表达式要求代理对象必须是 Service3 类型的，输出中可以看出代理对象并不是 Service3 类型的，此处代理对象 proxy 是使用 jdk 动态代理生成的。

我们可以将代码调整一下，使用 cglib 来创建代理

```
proxyFactory.setProxyTargetClass(true);


```

再次运行，会发现 m2 被拦截了，结果如下

```
execution(void com.javacode2018.aop.demo9.test3.Service3.m1())
我是m1
proxy是否是jdk动态代理对象：false
proxy是否是cglib代理对象：true
true


```

### 4、target

#### 用法

`target(类型全限定名)`：判断目标对象的类型是否和指定的类型匹配；注意判断的是目标对象的类型；表达式必须是类型全限定名，不支持通配符。

#### 匹配原则

```
如:target(x)，则目标对象target满足下面条件时会匹配
x.getClass().isAssignableFrom(target.getClass());


```

#### 案例

```
package com.javacode2018.aop.demo9.test4;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class AspectTest4 {

    //@1：目标类型必须是Service3类型的
    @Pointcut("target(com.javacode2018.aop.demo9.test3.Service3)")
    public void pc() {
    }

    @Before("pc()")
    public void beforeAdvice(JoinPoint joinpoint) {
        System.out.println(joinpoint);
    }

}


```

测试代码

```
@Test
public void test4() {
    Service3 target = new Service3();
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setProxyTargetClass(true);
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(AspectTest4.class);
    //获取代理对象
    Object proxy = proxyFactory.getProxy();
    //调用代理对象的方法
    ((I1) proxy).m1();
    //判断target对象是否是Service3类型的
    System.out.println(Service3.class.isAssignableFrom(target.getClass()));
}


```

运行输出

```
execution(void com.javacode2018.aop.demo9.test3.Service3.m1())
我是m1
true


```

#### within、this、target 对比

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06Bib15BbgLkWfMpOhWMYdDc7XeMzFVYmictYjyqem0QYs0fwRUYSxdNjoryBp39dAj5vz4HzJhD4wew/640?wx_fmt=png)

### 5、args

#### 用法

`args(参数类型列表)`匹配当前执行的方法传入的参数是否为 args 中指定的类型；注意是匹配传入的参数类型，不是匹配方法签名的参数类型；参数类型列表中的参数必须是类型全限定名，不支持通配符；args 属于动态切入点，也就是执行方法的时候进行判断的，这种切入点开销非常大，非特殊情况最好不要使用。

#### 举例说明

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06Bib15BbgLkWfMpOhWMYdDc7xbMiaLV5SCic2NU5DO9ibgM9hKCGwJRKkLcoibPKd7fiahY9hFd2ibMJQjNA/640?wx_fmt=png)

#### 案例

下面的 m1 方法参数是 Object 类型的。

```
package com.javacode2018.aop.demo9.test5;

public class Service5 {
    public void m1(Object object) {
        System.out.println("我是m1方法,参数：" + object);
    }
}


```

Aspect 类

```
package com.javacode2018.aop.demo9.test5;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

import java.util.Arrays;
import java.util.stream.Collectors;

@Aspect
public class AspectTest5 {
    //@1：匹配只有1个参数其类型是String类型的
    @Pointcut("args(String)")
    public void pc() {
    }

    @Before("pc()")
    public void beforeAdvice(JoinPoint joinpoint) {
        System.out.println("请求参数：" + Arrays.stream(joinpoint.getArgs()).collect(Collectors.toList()));
    }
}


```

测试代码，调用 2 次 m1 方法，第一次传入一个 String 类型的，第二次传入一个 int 类型的，看看效果

```
@Test
public void test5() {
    Service5 target = new Service5();
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(AspectTest5.class);
    Service5 proxy = proxyFactory.getProxy();
    proxy.m1("路人");
    proxy.m1(100);
}


```

运行输出

```
请求参数：[路人]
我是m1方法,参数：路人
我是m1方法,参数：100


```

输出中可以看出，m1 第一次调用被增强了，第二次没有被增强。

**args 会在调用的过程中对参数实际的类型进行匹配，比较耗时，慎用。**

### 6、@within

#### 用法

`@within(注解类型)`：匹配指定的注解内定义的方法。

#### 匹配规则

调用目标方法的时候，通过 java 中`Method.getDeclaringClass()`获取当前的方法是哪个类中定义的，然后会看这个类上是否有指定的注解。

```
被调用的目标方法Method对象.getDeclaringClass().getAnnotation(within中指定的注解类型) != null


```

来看 3 个案例。

#### 案例 1

**目标对象上有 @within 中指定的注解，这种情况时，目标对象的所有方法都会被拦截。**

##### 来个注解

```
package com.javacode2018.aop.demo9.test9;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface Ann9 {
}


```

##### 来个目标类，用 @Ann9 标注

```
package com.javacode2018.aop.demo9.test9;

@Ann9
public class S9 {
    public void m1() {
        System.out.println("我是m1方法");
    }
}


```

##### 来个 Aspect 类

```
package com.javacode2018.aop.demo9.test9;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class AspectTest9 {
    /**
     * 定义目标方法的类上有Ann9注解
     */
    @Pointcut("@within(Ann9)")
    public void pc() {
    }

    @Before("pc()")
    public void beforeAdvice(JoinPoint joinPoint) {
        System.out.println(joinPoint);
    }
}


```

##### 测试代码

```
@Test
public void test9() {
    S9 target = new S9();
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(AspectTest9.class);
    S9 proxy = proxyFactory.getProxy();
    proxy.m1();
}


```

> m1 方法在类 S9 中定义的，S9 上面有 Ann9 注解，所以匹配成功

##### 运行输出

```
execution(void com.javacode2018.aop.demo9.test9.S9.m1())
我是m1方法


```

#### 案例 2

**定义注解时未使用`@Inherited`，说明子类无法继承父类上的注解**，这个案例中我们将定义一个这样的注解，将注解放在目标类的父类上，来看一下效果。

##### 定义注解 Ann10

```
package com.javacode2018.aop.demo9.test10;

import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Inherited
public @interface Ann10 {
}


```

##### 来 2 个父子类

> 注意：
> 
> S10Parent 为父类，并且使用了 Anno10 注解，内部定义了 2 个方法大家注意一下
> 
> 而 S10 位代理的目标类，继承了 S10Parent，内部重写了父类的 m2 方法，并且又新增了一个 m3 方法

```
package com.javacode2018.aop.demo9.test10;

@Ann10
class S10Parent {

    public void m1() {
        System.out.println("我是S10Parent.m1()方法");
    }

    public void m2() {
        System.out.println("我是S10Parent.m2()方法");
    }
}

public class S10 extends S10Parent {

    @Override
    public void m2() {
        System.out.println("我是S10.m2()方法");
    }

    public void m3() {
        System.out.println("我是S10.m3()方法");
    }
}


```

##### 来个 Aspect 类

```
package com.javacode2018.aop.demo9.test10;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class AspectTest10 {
    //匹配目标方法声明的类上有@Anno10注解
    @Pointcut("@within(com.javacode2018.aop.demo9.test10.Ann10)")
    public void pc() {
    }

    @Before("pc()")
    public void beforeAdvice(JoinPoint joinPoint) {
        System.out.println(joinPoint);
    }
}


```

##### 测试用例

> S10 为目标类，依次执行代理对象的 m1、m2、m3 方法，最终会调用目标类 target 中对应的方法。

```
@Test
public void test10() {
    S10 target = new S10();
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(AspectTest10.class);
    S10 proxy = proxyFactory.getProxy();
    proxy.m1();
    proxy.m2();
    proxy.m3();
}


```

##### 运行输出

```
execution(void com.javacode2018.aop.demo9.test10.S10Parent.m1())
我是S10Parent.m1()方法
我是S10.m2()方法
我是S10.m3()方法


```

##### 分析结果

从输出中可以看出，只有 m1 方法被拦截了，其他 2 个方法没有被拦截。

确实是这样的，m1 方法的是由 S10Parent 定义的，这个类上面有 Ann10 注解。

而 m2 方法虽然也在 S10Parent 中定义了，但是这个方法被子类 S10 重写了，所以调用目标对象中的 m2 方法的时候，此时发现 m2 方法是由 S10 定义的，而`S10.class.getAnnotation(Ann10.class)`为空，所以这个方法不会被拦截。

同样 m3 方法也是 S10 中定义的，也不会被拦截。

#### 案例 3

对案例 2 进行改造，在注解的定义上面加上`@Inherited`，此时子类可以继承父类的注解，此时 3 个方法都会被拦截了。

下面上代码，下面代码为案例 2 代码的一个拷贝，不同地方只是注解的定义上多了`@Inherited`

##### 定义注解 Ann11

```
import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Inherited
public @interface Ann11 {
}


```

##### 2 个父子类

```
package com.javacode2018.aop.demo9.test11;

@Ann11
class S11Parent {

    public void m1() {
        System.out.println("我是S11Parent.m1()方法");
    }

    public void m2() {
        System.out.println("我是S11Parent.m2()方法");
    }
}

public class S11 extends S11Parent {

    @Override
    public void m2() {
        System.out.println("我是S11.m2()方法");
    }

    public void m3() {
        System.out.println("我是S11.m3()方法");
    }
}


```

##### Aspect 类

```
package com.javacode2018.aop.demo9.test11;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class AspectTest11 {

    @Pointcut("@within(com.javacode2018.aop.demo9.test11.Ann11)")
    public void pc() {
    }

    @Before("pc()")
    public void beforeAdvice(JoinPoint joinPoint) {
        System.out.println(joinPoint);
    }
}


```

##### 测试用例

```
@Test
public void test11() {
    S11 target = new S11();
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(AspectTest11.class);
    S11 proxy = proxyFactory.getProxy();
    proxy.m1();
    proxy.m2();
    proxy.m3();
}


```

##### 运行输出

```
execution(void com.javacode2018.aop.demo9.test11.S11Parent.m1())
我是S11Parent.m1()方法
execution(void com.javacode2018.aop.demo9.test11.S11.m2())
我是S11.m2()方法
execution(void com.javacode2018.aop.demo9.test11.S11.m3())
我是S11.m3()方法


```

> 这次 3 个方法都被拦截了。

### 7、@target

#### 用法

`@target(注解类型)`：判断目标对象 target 类型上是否有指定的注解；@target 中注解类型也必须是全限定类型名。

#### 匹配规则

```
target.class.getAnnotation(指定的注解类型) != null


```

2 种情况可以匹配

*   注解直接标注在目标类上
    
*   注解标注在父类上，但是注解必须是可以继承的，即定义注解的时候，需要使用`@Inherited`标注
    

#### 案例 1

**注解直接标注在目标类上，这种情况目标类会被匹配到。**

##### 自定义一个注解 `Ann6`

```
package com.javacode2018.aop.demo9.test6;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface Ann6 {
}


```

##### 目标类 `S6` 上直接使用 `@Ann1`

```
package com.javacode2018.aop.demo9.test6;

@Ann6
public class S6 {
    public void m1() {
        System.out.println("我是m1");
    }
}


```

##### 来个 `Aspect` 类

```
package com.javacode2018.aop.demo9.test6;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class AspectTest6 {
    //@1：目标类上有@Ann1注解
    @Pointcut("@target(Ann1)")
    public void pc() {
    }

    @Before("pc()")
    public void beforeAdvice(JoinPoint joinPoint) {
        System.out.println(joinPoint);
    }
}


```

##### 测试代码

```
@Test
public void test6() {
    S6 target = new S6();
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(AspectTest6.class);
    S6 proxy = proxyFactory.getProxy();
    proxy.m1();
    System.out.println("目标类上是否有 @Ann6 注解：" + (target.getClass().getAnnotation(Ann6.class) != null));
}


```

##### 运行输出

```
execution(void com.javacode2018.aop.demo9.test6.S6.m1())
我是m1
目标类上是否有 @Ann6 注解：true


```

#### 案例 2

**注解标注在父类上，注解上没有`@Inherited`，这种情况下，目标类无法匹配到，下面看代码**

##### 注解 Ann7

```
package com.javacode2018.aop.demo9.test7;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface Ann7 {
}


```

##### 来 2 个父子类，父类上有 `@Ann7`，之类 `S7` 为目标类

```
package com.javacode2018.aop.demo9.test7;

import java.lang.annotation.Target;

@Ann7
class S7Parent {
}

public class S7 extends S7Parent {
    public void m1() {
        System.out.println("我是m1");
    }

    public static void main(String[] args) {
        System.out.println(S7.class.getAnnotation(Target.class));
    }
}


```

##### 来个 Aspect 类

```
package com.javacode2018.aop.demo9.test7;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class AspectTest7 {
    /**
     * 匹配目标类上有Ann7注解
     */
    @Pointcut("@target(com.javacode2018.aop.demo9.test7.Ann7)")
    public void pc() {
    }

    @Before("pc()")
    public void beforeAdvice(JoinPoint joinPoint) {
        System.out.println(joinPoint);
    }
}


```

##### 测试代码

```
@Test
public void test7() {
    S7 target = new S7();
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(AspectTest7.class);
    S7 proxy = proxyFactory.getProxy();
    proxy.m1();
    System.out.println("目标类上是否有 @Ann7 注解：" + (target.getClass().getAnnotation(Ann7.class) != null));
}


```

##### 运行输出

```
我是m1
目标类上是否有 @Ann7 注解：false


```

##### 分析结果

@Ann7 标注在了父类上，但是 @Ann7 定义的时候没有使用`@Inherited`，说明之类无法继承父类上面的注解，所以上面的目标类没有被拦截，下面我们将`@Ann7`的定义改一下，加上`@Inherited`

```
package com.javacode2018.aop.demo9.test7;

import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Inherited
public @interface Ann7 {
}


```

##### 再次运行输出

```
execution(void com.javacode2018.aop.demo9.test7.S7.m1())
我是m1
目标类上是否有 @Ann7 注解：true


```

此时目标对象被拦截了。

### 8、@args

#### 用法

@args(注解类型)：方法参数所属的类上有指定的注解；注意不是参数上有指定的注解，而是参数类型的类上有指定的注解。

#### 案例 1

```
@Pointcut("@args(Ann8)")：匹配方法只有一个参数，并且参数所属的类上有Ann8注解


```

可以匹配下面的代码，m1 方法的第一个参数类型是 Car 类型，Car 类型上有注解 Ann8

```
@Ann8
class Car {
}

public void m1(Car car) {
    System.out.println("我是m1");
}


```

#### 案例 2

```
@Pointcut("@args(*,Ann8)")：匹配方法只有2个参数，且第2个参数所属的类型上有Ann8注解


```

可以匹配下面代码

```
@Ann8
class Car {
}

public void m1(String name,Car car) {
    System.out.println("我是m1");
}


```

#### 案例 3

```
@Pointcut("@args(..,com.javacode2018.aop.demo9.test8.Ann8)")：匹配参数数量大于等于1，且最后一个参数所属的类型上有Ann8注解
@Pointcut("@args(*,com.javacode2018.aop.demo9.test8.Ann8,..)")：匹配参数数量大于等于2，且第2个参数所属的类型上有Ann8注解
@Pointcut("@args(..,com.javacode2018.aop.demo9.test8.Ann8,*)")：匹配参数数量大于等于2，且倒数第2个参数所属的类型上有Ann8注解


```

这个案例代码，大家自己写一下，体验一下。

### 9、@annotation

#### 用法

@annotation(注解类型)：匹配被调用的方法上有指定的注解。

#### 案例

##### 定义一个注解，可以用在方法上

```
package com.javacode2018.aop.demo9.test12;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Ann12 {
}


```

##### 定义 2 个类

> S12Parent 为父类，内部定义了 2 个方法，2 个方法上都有 @Ann12 注解
> 
> S12 是代理的目标类，也是 S12Parent 的子类，内部重写了 m2 方法，重写之后 m2 方法上并没有 @Ann12 注解，S12 内部还定义 2 个方法 m3 和 m4，而 m3 上面有注解 @Ann12

```
package com.javacode2018.aop.demo9.test12;

class S12Parent {

    @Ann12
    public void m1() {
        System.out.println("我是S12Parent.m1()方法");
    }

    @Ann12
    public void m2() {
        System.out.println("我是S12Parent.m2()方法");
    }
}

public class S12 extends S12Parent {

    @Override
    public void m2() {
        System.out.println("我是S12.m2()方法");
    }

    @Ann12
    public void m3() {
        System.out.println("我是S12.m3()方法");
    }

    public void m4() {
        System.out.println("我是S12.m4()方法");
    }
}


```

##### 来个 Aspect 类

> 当被调用的目标方法上有 @Ann12 注解的时，会被 beforeAdvice 处理。

```
package com.javacode2018.aop.demo9.test12;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class AspectTest12 {

    @Pointcut("@annotation(com.javacode2018.aop.demo9.test12.Ann12)")
    public void pc() {
    }

    @Before("pc()")
    public void beforeAdvice(JoinPoint joinPoint) {
        System.out.println(joinPoint);
    }
}


```

##### 测试用例

> S12 作为目标对象，创建代理，然后分别调用 4 个方法

```
@Test
public void test12() {
    S12 target = new S12();
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(AspectTest12.class);
    S12 proxy = proxyFactory.getProxy();
    proxy.m1();
    proxy.m2();
    proxy.m3();
    proxy.m4();
}


```

##### 运行输出

```
execution(void com.javacode2018.aop.demo9.test12.S12Parent.m1())
我是S12Parent.m1()方法
我是S12.m2()方法
execution(void com.javacode2018.aop.demo9.test12.S12.m3())
我是S12.m3()方法
我是S12.m4()方法


```

##### 分析结果

m1 方法位于 S12Parent 中，上面有 @Ann12 注解，被连接了，m3 方法上有 @Ann12 注解，被拦截了，而 m4 上没有 @Ann12 注解，没有被拦截，这 3 个方法的执行结果都很容易理解。

重点在于 m2 方法的执行结果，没有被拦截，m2 方法虽然在 S12Parent 中定义的时候也有 @Ann12 注解标注，但是这个方法被 S1 给重写了，在 S1 中定义的时候并没有 @Ann12 注解，代码中实际上调用的是 S1 中的 m2 方法，发现这个方法上并没有 @Ann12 注解，所以没有被拦截。

### 10、bean

#### 用法

bean(bean 名称)：这个用在 spring 环境中，匹配容器中指定名称的 bean。

#### 案例

##### 来个类 BeanService

```
package com.javacode2018.aop.demo9.test13;

public class BeanService {
    private String beanName;

    public BeanService(String beanName) {
        this.beanName = beanName;
    }

    public void m1() {
        System.out.println(this.beanName);
    }
}


```

##### 来个 Aspect 类

```
package com.javacode2018.aop.demo9.test13;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;

@Aspect
public class Aspect13 {
    //拦截spring容器中名称为beanService2的bean
    @Pointcut("bean(beanService2)")
    public void pc() {
    }

    @Before("pc()")
    public void beforeAdvice(JoinPoint joinPoint) {
        System.out.println(joinPoint);
    }
}


```

##### 来个 spring 配置类

```
package com.javacode2018.aop.demo9.test13;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

@Configuration
@EnableAspectJAutoProxy // 这个可以启用通过AspectJ方式自动为符合条件的bean创建代理
public class MainConfig13 {

    //将Aspect13注册到spring容器
    @Bean
    public Aspect13 aspect13() {
        return new Aspect13();
    }

    @Bean
    public BeanService beanService1() {
        return new BeanService("beanService1");
    }

    @Bean
    public BeanService beanService2() {
        return new BeanService("beanService2");
    }
}


```

> 这个配置类中有个`@EnableAspectJAutoProxy`，这个注解大家可能比较陌生，这个属于 aop 中自动代理的范围，后面会有文章详细介绍这块，这里大家暂时先不用关注。

##### 测试用例

> 下面启动 spring 容器，加载配置类 MainConfig13，然后分别获取 beanService1 和 beanService2，调用他们的 m1 方法，看看效果

```
@Test
public void test13() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig13.class);
    //从容器中获取beanService1
    BeanService beanService1 = context.getBean("beanService1", BeanService.class);
    beanService1.m1();
    //从容器中获取beanService2
    BeanService beanService2 = context.getBean("beanService2", BeanService.class);
    beanService2.m1();
}


```

##### 运行输出

```
beanService1
execution(void com.javacode2018.aop.demo9.test13.BeanService.m1())
beanService2


```

> beanService2 的 m1 方法被拦截了。

### 11、reference pointcut

表示引用其他命名切入点。

有时，我们可以将切入专门放在一个类中集中定义。

其他地方可以通过引用的方式引入其他类中定义的切入点。

语法如下：

```
@Pointcut("完整包名类名.方法名称()")


```

> 若引用同一个类中定义切入点，包名和类名可以省略，直接通过方法就可以引用。

比如下面，我们可以将所有切入点定义在一个类中

```
package com.javacode2018.aop.demo9.test14;

import org.aspectj.lang.annotation.Pointcut;

public class AspectPcDefine {
    @Pointcut("bean(bean1)")
    public void pc1() {
    }

    @Pointcut("bean(bean2)")
    public void pc2() {
    }
}


```

下面顶一个一个 Aspect 类，来引用上面的切入点

```
package com.javacode2018.aop.demo9.test14;

import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class Aspect14 {

    @Pointcut("com.javacode2018.aop.demo9.test14.AspectPcDefine.pc1()")
    public void pointcut1() {
    }

    @Pointcut("com.javacode2018.aop.demo9.test14.AspectPcDefine.pc1() || com.javacode2018.aop.demo9.test14.AspectPcDefine.pc2()")
    public void pointcut2() {
    }

}


```

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06Bib15BbgLkWfMpOhWMYdDc7siaDZ691lJ0icFfBxG7Kmqc0xDyxRbcaMWT38rU9znXQKNXn4hkPczXw/640?wx_fmt=png)

### 12、组合型的 pointcut

Pointcut 定义时，还可以使用 &&、||、! 运算符。

*   &&：多个匹配都需要满足
    
*   ||：多个匹配中只需满足一个
    
*   !：匹配不满足的情况下
    

```
@Pointcut("bean(bean1) || bean(bean2)") //匹配bean1或者bean2
@Pointcut("@target(Ann1) && @Annotation(Ann2)") //匹配目标类上有Ann1注解并且目标方法上有Ann2注解
@Pointcut("@target(Ann1) && !@target(Ann2)") // 匹配目标类上有Ann1注解但是没有Ann2注解


```

总结
--

本文详解了 @Pointcut 的 12 种用法，案例大家一定要敲一遍，敲的过程中，会遇到问题，然后解决问题，才能够加深理解。

有问题的也欢迎大家留言交流，谢谢！

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06Bib15BbgLkWfMpOhWMYdDc7UoZgNK7QLSNSeQOelOA1UicMJPkYagZibNxricRCibicx3EIpgvFtxsgDxQ/640?wx_fmt=png)

案例源码
----

```
https://gitee.com/javacode2018/spring-series


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


更多好文章
-----

1.  [Java 高并发系列（共 34 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933285&idx=1&sn=f5507c251b84c3405f2fe0f7fb1da97d&chksm=88621b9bbf15928dd4c26f52b2abb0e130cde02100c432f33f0e90123b5e4b20d43017c1030e&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [MySql 高手系列（共 27 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933461&idx=1&sn=67cd31469273b68a258d963e53b56325&chksm=88621c6bbf15957d7308d81cd8ba1761b356222f4c6df75723aee99c265bd94cc869faba291c&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Maven 高手系列（共 10 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933753&idx=1&sn=0b41083939980be87a61c4f573792459&chksm=88621d47bf1594516092b662c545abfac299d296e232bf25e9f50be97e002e2698ea78218828&scene=21#wechat_redirect)
    
4.  [Mybatis 系列（共 12 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933868&idx=1&sn=ed16ef4afcbfcb3423a261422ff6934e&chksm=88621dd2bf1594c4baa21b7adc47456e5f535c3358cd11ddafb1c80742864bb19d7ccc62756c&token=1400407286&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [聊聊 db 和缓存一致性常见的实现方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933452&idx=1&sn=48b3b1cbd27c50186122fef8943eca5f&chksm=88621c72bf159564e629ee77d180424274ae9effd8a7c2997f853135b28f3401970793d8098d&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [接口幂等性这么重要，它是什么？怎么实现？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933334&idx=1&sn=3a68da36e4e21b7339418e40ab9b6064&chksm=88621be8bf1592fe5301aab732fbed8d1747475f4221da341350e0cc9935225d41bf79375d43&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [泛型，有点难度，会让很多人懵逼，那是因为你没有看这篇文章！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933878&idx=1&sn=bebd543c39d02455456680ff12e3934b&chksm=88621dc8bf1594de6b50a760e4141b80da76442ba38fb93a91a3d18ecf85e7eee368f2c159d3&token=799820369&lang=zh_CN&scene=21#wechat_redirect)
    

********世界上最好的关系是相互成就，点赞转发 感恩开心😃********

**路人甲 java**  

![](https://mmbiz.qpic.cn/mmbiz_png/9Xne6pfLaexiaK8h8pVuFJibShbdbS0QEE9V2UuWiakgeMWbXLgrrT114RwXKZfEJicvtz3jsUslfVhpOGZS62mQvg/640?wx_fmt=png)

▲长按图片识别二维码关注

**路人甲 Java：工作 10 年的前阿里 P7，所有文章以系列的方式呈现，带领大家成为 java 高手，目前已出：java 高并发系列、mysql 高手系列、Maven 高手系列、mybatis 系列、spring 系列，正在连载 springcloud 系列，欢迎关注！**