> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935466&idx=2&sn=f536d7a2834e6e590bc7af0527e4de1f&scene=21#wechat_redirect)

**本文内容：详解 @Aspect 中 5 中通知的使用。**

Aop 相关阅读
--------

阅读本文之前，需要先掌握下面几篇文章内容，不然会比较吃力。

1.  [Spring 系列第 15 篇：代理详解（java 动态代理 & CGLIB 代理)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934082&idx=1&sn=c919886400135a0152da23eaa1f276c7&chksm=88621efcbf1597eab943b064147b8fb8fd3dfbac0dc03f41d15d477ef94b60d4e8f78c66b262&token=1042984313&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [Spring 系列第 30 篇：jdk 动态代理和 cglib 代理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934783&idx=1&sn=5531f14475a4addc6d4d47f0948b3208&chksm=88621141bf159857bc19d7bb545ed3ddc4152dcda9e126f27b83afc2e975dee1682de2d98ad6&token=1672930952&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Spring 系列第 31 篇：Aop 概念详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934876&idx=1&sn=7794b50e658e0ec3e0aff6cf5ed4aa2e&chksm=886211e2bf1598f4e0e636170a4b36a5a5edd8811c8b7c30d61135cb114b0ce506a6fa84df0b&token=1672930952&lang=zh_CN&scene=21#wechat_redirect)
    
4.  [Spring 系列第 32 篇：AOP 核心源码、原理详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934930&idx=1&sn=4030960657cc72006122ef8b6f0de889&scene=21#wechat_redirect)
    
5.  [Spring 系列第 33 篇：ProxyFactoryBean 创建 AOP 代理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934977&idx=1&sn=8e4caf6a17bf5e123884df81a6382214&scene=21#wechat_redirect)
    
6.  [Spring 系列第 34 篇：@Aspect 中 @Pointcut 12 种用法](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935037&idx=2&sn=cf813ac4cdfa3a0a0d6b5ed770255779&chksm=88621243bf159b554be2fe75eda7f5631ca29eed54edbfb97b08244625e03957429f2414d1e3&token=883563940&lang=zh_CN&scene=21#wechat_redirect)
    

@Aspect 中有 5 种通知
----------------

1.  @Before：前置通知, 在方法执行之前执行
    
2.  @Aroud：环绕通知, 围绕着方法执行
    
3.  @After：后置通知, 在方法执行之后执行
    
4.  @AfterReturning：返回通知, 在方法返回结果之后执行
    
5.  @AfterThrowing：异常通知, 在方法抛出异常之后
    

这几种通知用起来都比较简单，都是通过注解的方式，将这些注解标注在 @Aspect 类的方法上，这些方法就会对目标方法进行拦截，下面我们一个个来看一下。

@Before：前置通知
------------

### 介绍

定义一个前置通知

```
@Aspect
public class BeforeAspect {

    @Before("execution(* com.javacode2018.aop.demo10.test1.Service1.*(..))")
    public void before(JoinPoint joinPoint) {
        System.out.println("我是前置通知!");
    }
}


```

1.  类上需要使用`@Aspect`标注
    
2.  任意方法上使用`@Before`标注，将这个方法作为前置通知，目标方法被调用之前，会自动回调这个方法
    
3.  被`@Before`标注的方法参数可以为空，或者为`JoinPoint`类型，当为`JoinPoint`类型时，必须为第一个参数
    
4.  被`@Before`标注的方法名称可以随意命名，符合 java 规范就可以，其他通知也类似
    

`@Before`中 value 的值为切入点表达式，也可以采用引用的方式指定切入点，如：

```
package com.javacode2018.aop.demo10.test1;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class BeforeAspect {

    @Pointcut("execution(* com.javacode2018.aop.demo10.test1.Service1.*(..))")
    public void pc() {
    }

    @Before("com.javacode2018.aop.demo10.test1.BeforeAspect.pc()")
    public void before(JoinPoint joinPoint) {
        System.out.println("我是前置通知!");
    }
}


```

此时，before 方法上面的切入引用了 pc 方法上面的`@Pointcut`的值

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06CGJC1QCgPv7up3fBNVEW0pXYRiboPLhH73hhrY3xlHFNaHNsJ47PeU9XsRgyX05oV5SxlCYJIErtQ/640?wx_fmt=png)

### 案例

来个普通的 service

```
package com.javacode2018.aop.demo10.test1;

public class Service1 {
    public String say(String name) {
        return "你好：" + name;
    }

    public String work(String name) {
        return "开始工作了：" + name;
    }
}


```

给上面的类定义一个前置通知，`Service1`中的所有方法执行执行，输出一段文字`我是前置通知!`

```
package com.javacode2018.aop.demo10.test1;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class BeforeAspect1 {

    @Pointcut("execution(* com.javacode2018.aop.demo10.test1.Service1.*(..))")
    public void pc() {
    }

    @Before("com.javacode2018.aop.demo10.test1.BeforeAspect1.pc()")
    public void before(JoinPoint joinPoint) {
        System.out.println("我是前置通知!");
    }
}


```

测试代码

```
package com.javacode2018.aop.demo10;

import com.javacode2018.aop.demo10.test1.BeforeAspect1;
import com.javacode2018.aop.demo10.test1.Service1;
import org.junit.Test;
import org.springframework.aop.aspectj.annotation.AspectJProxyFactory;

public class AopTest10 {

    @Test
    public void test1() {
        Service1 target = new Service1();
        Class<BeforeAspect1> aspectClass = BeforeAspect1.class;
        AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
        proxyFactory.setTarget(target);
        proxyFactory.addAspect(aspectClass);
        Service1 proxy = proxyFactory.getProxy();
        System.out.println(proxy.say("路人"));
        System.out.println(proxy.work("路人"));
    }
}


```

运行输出

```
我是前置通知!
你好：路人
我是前置通知!
开始工作了：路人


```

### 对应的通知类

@Before 通知最后会被解析为下面这个通知类

```
org.springframework.aop.aspectj.AspectJMethodBeforeAdvice


```

通知中获取被调方法信息
-----------

通知中如果想获取被调用方法的信息，分 2 种情况

1.  非环绕通知，可以将`org.aspectj.lang.JoinPoint`作为通知方法的第 1 个参数，通过这个参数获取被调用方法的信息
    
2.  如果是环绕通知，可以将`org.aspectj.lang.ProceedingJoinPoint`作为方法的第 1 个参数，通过这个参数获取被调用方法的信息
    

### JoinPoint：连接点信息

```
org.aspectj.lang.JoinPoint


```

提供访问当前被通知方法的目标对象、代理对象、方法参数等数据：

```
package org.aspectj.lang;  
import org.aspectj.lang.reflect.SourceLocation;

public interface JoinPoint {  
    String toString();         //连接点所在位置的相关信息  
    String toShortString();     //连接点所在位置的简短相关信息  
    String toLongString();     //连接点所在位置的全部相关信息  
    Object getThis();         //返回AOP代理对象
    Object getTarget();       //返回目标对象  
    Object[] getArgs();       //返回被通知方法参数列表，也就是目前调用目标方法传入的参数  
    Signature getSignature();  //返回当前连接点签名，这个可以用来获取目标方法的详细信息，如方法Method对象等
    SourceLocation getSourceLocation();//返回连接点方法所在类文件中的位置  
    String getKind();        //连接点类型  
    StaticPart getStaticPart(); //返回连接点静态部分  
} 


```

### ProceedingJoinPoint：环绕通知连接点信息

用于环绕通知，内部主要关注 2 个方法，一个有参的，一个无参的，用来继续执行拦截器链上的下一个通知。

```
package org.aspectj.lang;
import org.aspectj.runtime.internal.AroundClosure;

public interface ProceedingJoinPoint extends JoinPoint {

    /**
     * 继续执行下一个通知或者目标方法的调用
     */
    public Object proceed() throws Throwable;

    /**
     * 继续执行下一个通知或者目标方法的调用
     */
    public Object proceed(Object[] args) throws Throwable;

}


```

### Signature：连接点签名信息

注意`JoinPoint#getSignature()`这个方法，用来获取连接点的签名信息，这个比较重要

```
Signature getSignature();


```

通常情况，spring 中的 aop 都是用来对方法进行拦截，所以通常情况下连接点都是一个具体的方法，`Signature`有个子接口

```
org.aspectj.lang.reflect.MethodSignature


```

`JoinPoint#getSignature()`都可以转换转换为`MethodSignature`类型，然后可以通过这个接口提供的一些方法来获取被调用的方法的详细信息。

下面对上面的前置通知的案例改造一下，获取被调用方法的详细信息，新建一个 Aspect 类：`BeforeAspect2`

```
package com.javacode2018.aop.demo10.test2;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.Signature;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;

import java.lang.reflect.Method;

@Aspect
public class BeforeAspect2 {

    @Pointcut("execution(* com.javacode2018.aop.demo10.test1.Service1.*(..))")
    public void pc() {
    }

    @Before("com.javacode2018.aop.demo10.test2.BeforeAspect2.pc()")
    public void before(JoinPoint joinPoint) {
        //获取连接点签名
        Signature signature = joinPoint.getSignature();
        //将其转换为方法签名
        MethodSignature methodSignature = (MethodSignature) signature;
        //通过方法签名获取被调用的目标方法
        Method method = methodSignature.getMethod();
        //输出方法信息
        System.out.println(method);
    }
}


```

测试用例

```
@Test
public void test2() {
    Service1 target = new Service1();
    Class<BeforeAspect2> aspectClass = BeforeAspect2.class;
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(aspectClass);
    Service1 proxy = proxyFactory.getProxy();
    System.out.println(proxy.say("路人"));
    System.out.println(proxy.work("路人"));
}


```

运行输出

```
public java.lang.String com.javacode2018.aop.demo10.test1.Service1.say(java.lang.String)
你好：路人
public java.lang.String com.javacode2018.aop.demo10.test1.Service1.work(java.lang.String)
开始工作了：路人


```

@Around：环绕通知
------------

### 介绍

环绕通知会包裹目标目标方法的执行，可以在通知内部调用`ProceedingJoinPoint.process`方法继续执行下一个拦截器。

用起来和 @Before 类似，但是有 2 点不一样

1.  若需要获取目标方法的信息，需要将 ProceedingJoinPoint 作为第一个参数
    
2.  通常使用 Object 类型作为方法的返回值，返回值也可以为 void
    

### 特点

环绕通知比较特殊，其他 4 种类型的通知都可以用环绕通知来实现。

### 案例

通过环绕通知来统计方法的耗时。

```
package com.javacode2018.aop.demo10.test3;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.Signature;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;

import java.lang.reflect.Method;

@Aspect
public class AroundAspect3 {

    @Pointcut("execution(* com.javacode2018.aop.demo10.test1.Service1.*(..))")
    public void pc() {
    }

    @Around("com.javacode2018.aop.demo10.test3.AroundAspect3.pc()")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        //获取连接点签名
        Signature signature = joinPoint.getSignature();
        //将其转换为方法签名
        MethodSignature methodSignature = (MethodSignature) signature;
        //通过方法签名获取被调用的目标方法
        Method method = methodSignature.getMethod();

        long startTime = System.nanoTime();
        //调用proceed方法，继续调用下一个通知
        Object returnVal = joinPoint.proceed();
        long endTime = System.nanoTime();
        long costTime = endTime - startTime;
        //输出方法信息
        System.out.println(String.format("%s，耗时(纳秒)：%s", method.toString(), costTime));
        //返回方法的返回值
        return returnVal;
    }
}


```

测试用例

```
@Test
public void test3() {
    Service1 target = new Service1();
    Class<AroundAspect3> aspectClass = AroundAspect3.class;
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(aspectClass);
    Service1 proxy = proxyFactory.getProxy();
    System.out.println(proxy.say("路人"));
    System.out.println(proxy.work("路人"));
}


```

运行输出

```
public java.lang.String com.javacode2018.aop.demo10.test1.Service1.say(java.lang.String)，耗时(纳秒)：19000500
你好：路人
public java.lang.String com.javacode2018.aop.demo10.test1.Service1.work(java.lang.String)，耗时(纳秒)：59600
开始工作了：路人


```

### 对应的通知类

@Around 通知最后会被解析为下面这个通知类

```
org.springframework.aop.aspectj.AspectJAroundAdvice


```

@After：后置通知
-----------

### 介绍

后置通知，在方法执行之后执行，用法和前置通知类似。

### 特点

*   **不管目标方法是否有异常，后置通知都会执行**
    
*   这种通知无法获取方法返回值
    
*   可以使用`JoinPoint`作为方法的第一个参数，用来获取连接点的信息
    

### 案例

在`Service1`中任意方法执行完毕之后，输出一行日志。

```
package com.javacode2018.aop.demo10.test4;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.After;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;

@Aspect
public class AfterAspect4 {

    @Pointcut("execution(* com.javacode2018.aop.demo10.test1.Service1.*(..))")
    public void pc() {
    }

    @After("com.javacode2018.aop.demo10.test4.AfterAspect4.pc()")
    public void after(JoinPoint joinPoint) throws Throwable {
        MethodSignature methodSignature = (MethodSignature) joinPoint.getSignature();
        System.out.println(String.format("%s,执行完毕!", methodSignature.getMethod()));
    }
}


```

测试案例

```
@Test
public void test4() {
    Service1 target = new Service1();
    Class<AfterAspect4> aspectClass = AfterAspect4.class;
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(aspectClass);
    Service1 proxy = proxyFactory.getProxy();
    System.out.println(proxy.say("路人"));
    System.out.println(proxy.work("路人"));
}


```

运行输出

```
public java.lang.String com.javacode2018.aop.demo10.test1.Service1.say(java.lang.String),执行完毕!
你好：路人
public java.lang.String com.javacode2018.aop.demo10.test1.Service1.work(java.lang.String),执行完毕!
开始工作了：路人


```

### 对应的通知类

@After 通知最后会被解析为下面这个通知类

```
org.springframework.aop.aspectj.AspectJAfterAdvice


```

这个类中有`invoke`方法，这个方法内部会调用被通知的方法，其内部采用`try..finally`的方式实现的，所以不管目标方法是否有异常，通知一定会被执行。

```
@Override
public Object invoke(MethodInvocation mi) throws Throwable {
    try {
        //继续执行下一个拦截器
        return mi.proceed();
    }
    finally {
        //内部通过反射调用被@After标注的方法
        invokeAdviceMethod(getJoinPointMatch(), null, null);
    }
}


```

@AfterReturning：返回通知
--------------------

### 用法

返回通知，在方法返回结果之后执行。

### 特点

*   可以获取到方法的返回值
    
*   当目标方法返回异常的时候，这个通知不会被调用，这点和 @After 通知是有区别的
    

### 案例

后置通知中打印出方法及返回值信息。

```
package com.javacode2018.aop.demo10.test5;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;

@Aspect
public class AfterReturningAspect5 {
    @Pointcut("execution(* com.javacode2018.aop.demo10.test1.Service1.*(..))")
    public void pc() {
    }

    @AfterReturning(value = "com.javacode2018.aop.demo10.test5.AfterReturningAspect5.pc()", returning = "retVal")
    public void afterReturning(JoinPoint joinPoint, Object retVal) throws Throwable {
        MethodSignature methodSignature = (MethodSignature) joinPoint.getSignature();
        System.out.println(String.format("%s返回值：%s", methodSignature.getMethod(), retVal));
    }

}


```

> “
> 
> 注意`@AfterReturning`注解，用到了 2 个参数
> 
> *   value：用来指定切入点
>     
> *   returning：用来指定返回值对应方法的参数名称，返回值对应方法的第二个参数，名称为 retVal
>     

### 对应的通知类

@AfterReturning 通知最后会被解析为下面这个通知类

```
org.springframework.aop.aspectj.AspectJAfterReturningAdvice


```

@AfterThrowing：异常通知
-------------------

### 用法

在方法抛出异常之后会回调`@AfterThrowing`标注的方法。

@AfterThrowing 标注的方法可以指定异常的类型，当被调用的方法触发该异常及其子类型的异常之后，会触发异常方法的回调。也可以不指定异常类型，此时会匹配所有异常。

#### 未指定异常类型

> “
> 
> 未指定异常类型，可以匹配所有异常类型，如下

```
@AfterThrowing(value = "切入点")
public void afterThrowing()


```

#### 指定异常类型

> “
> 
> 通过`@AfterThrowing`的`throwing`指定参数异常参数名称，我们用方法的第二个参数用来接收异常，第二个参数名称为 e，下面的代码，当目标方法发生`IllegalArgumentException`异常及其子类型异常时，下面的方法会被回调。

```
@AfterThrowing(value = "com.javacode2018.aop.demo10.test6.AfterThrowingAspect6.pc()", throwing = "e")
public void afterThrowing(JoinPoint joinPoint, IllegalArgumentException e)


```

### 特点

*   不论异常是否被异常通知捕获，异常还会继续向外抛出。
    

### 案例

Service1 中加了 login 方法，用户名不是`路人甲java`时抛出异常。

```
package com.javacode2018.aop.demo10.test1;

public class Service1 {
    public String say(String name) {
        return "你好：" + name;
    }

    public String work(String name) {
        return "开始工作了：" + name;
    }

    public boolean login(String name) {
        if (!"路人甲java".equals(name)) {
            throw new IllegalArgumentException("非法访问!");
        }
        return true;
    }
}


```

来个异常通知

```
package com.javacode2018.aop.demo10.test6;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;

@Aspect
public class AfterThrowingAspect6 {
    @Pointcut("execution(* com.javacode2018.aop.demo10.test1.Service1.*(..))")
    public void pc() {
    }

    @AfterThrowing(value = "com.javacode2018.aop.demo10.test6.AfterThrowingAspect6.pc()", throwing = "e")
    public void afterThrowing(JoinPoint joinPoint, IllegalArgumentException e) {
        MethodSignature methodSignature = (MethodSignature) joinPoint.getSignature();
        System.out.println(String.format("%s发生异常,异常信息：%s", methodSignature.getMethod(), e.getMessage()));
    }

}


```

测试用例

```
@Test
public void test6() {
    Service1 target = new Service1();
    Class<AfterThrowingAspect6> aspectClass = AfterThrowingAspect6.class;
    AspectJProxyFactory proxyFactory = new AspectJProxyFactory();
    proxyFactory.setTarget(target);
    proxyFactory.addAspect(aspectClass);
    Service1 proxy = proxyFactory.getProxy();
    proxy.login("路人");
}


```

运行输出

```
public boolean com.javacode2018.aop.demo10.test1.Service1.login(java.lang.String)发生异常,异常信息：非法访问!

java.lang.IllegalArgumentException: 非法访问!

 at com.javacode2018.aop.demo10.test1.Service1.login(Service1.java:14)
 at com.javacode2018.aop.demo10.test1.Service1$$FastClassBySpringCGLIB$$ea03ccbe.invoke(<generated>)
 at org.springframework.cglib.proxy.MethodProxy.invoke(MethodProxy.java:218)
 at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.invokeJoinpoint(CglibAopProxy.java:769)


```

### 对应的通知类

@AfterThrowing 通知最后会被解析为下面这个通知类

```
org.springframework.aop.aspectj.AspectJAfterThrowingAdvice


```

来看一下这个类的`invoke`方法，这个方法是关键

```
@Override
public Object invoke(MethodInvocation mi) throws Throwable {
    try {
        //继续调用下一个拦截器链
        return mi.proceed();
    }
    catch (Throwable ex) {
        //判断ex和需要不糊的异常是否匹配
        if (shouldInvokeOnThrowing(ex)) {
            //通过反射调用@AfterThrowing标注的方法
            invokeAdviceMethod(getJoinPointMatch(), null, ex);
        }
        //继续向外抛出异常
        throw ex;
    }
}


```

几种通知对比
------

<table data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)"><thead data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)"><tr data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079182295586="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">通知类型</th><th data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079182295586="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">执行时间点</th><th data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079182295586="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">可获取返回值</th><th data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079182295586="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">目标方法异常时是否会执行</th></tr></thead><tbody data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)"><tr data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">@Before</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">方法执行之前</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">否</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是</td></tr><tr data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079182295586="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079182295586="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">@Around</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079182295586="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">环绕方法执行</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079182295586="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079182295586="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">自己控制</td></tr><tr data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">@After</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">方法执行后</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">否</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是</td></tr><tr data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079182295586="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079182295586="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">@AfterReturning</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079182295586="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">方法执行后</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079182295586="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079182295586="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">否</td></tr><tr data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">@AfterThrowing</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">方法发生异常后</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">否</td><td data-darkmode-color-16079182295586="rgb(163, 163, 163)" data-darkmode-original-color-16079182295586="rgb(0,0,0)" data-darkmode-bgcolor-16079182295586="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079182295586="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是</td></tr></tbody></table>

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06CGJC1QCgPv7up3fBNVEW0pw4aQxWNxns56Ath7vhqTAaDR62pibJTuQvBNQyGAiazVibwphkzpFicIvw/640?wx_fmt=png)

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
    

更多好文章
-----

1.  [Java 高并发系列（共 34 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933285&idx=1&sn=f5507c251b84c3405f2fe0f7fb1da97d&chksm=88621b9bbf15928dd4c26f52b2abb0e130cde02100c432f33f0e90123b5e4b20d43017c1030e&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [MySql 高手系列（共 27 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933461&idx=1&sn=67cd31469273b68a258d963e53b56325&chksm=88621c6bbf15957d7308d81cd8ba1761b356222f4c6df75723aee99c265bd94cc869faba291c&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Maven 高手系列（共 10 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933753&idx=1&sn=0b41083939980be87a61c4f573792459&chksm=88621d47bf1594516092b662c545abfac299d296e232bf25e9f50be97e002e2698ea78218828&scene=21#wechat_redirect)
    
4.  [Mybatis 系列（共 12 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933868&idx=1&sn=ed16ef4afcbfcb3423a261422ff6934e&chksm=88621dd2bf1594c4baa21b7adc47456e5f535c3358cd11ddafb1c80742864bb19d7ccc62756c&token=1400407286&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [聊聊 db 和缓存一致性常见的实现方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933452&idx=1&sn=48b3b1cbd27c50186122fef8943eca5f&chksm=88621c72bf159564e629ee77d180424274ae9effd8a7c2997f853135b28f3401970793d8098d&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [接口幂等性这么重要，它是什么？怎么实现？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933334&idx=1&sn=3a68da36e4e21b7339418e40ab9b6064&chksm=88621be8bf1592fe5301aab732fbed8d1747475f4221da341350e0cc9935225d41bf79375d43&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [泛型，有点难度，会让很多人懵逼，那是因为你没有看这篇文章！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933878&idx=1&sn=bebd543c39d02455456680ff12e3934b&chksm=88621dc8bf1594de6b50a760e4141b80da76442ba38fb93a91a3d18ecf85e7eee368f2c159d3&token=799820369&lang=zh_CN&scene=21#wechat_redirect)
    

世界上最好的关系是相互成就，点赞转发 感恩开心😃

路人甲 java  

![](https://mmbiz.qpic.cn/mmbiz_png/9Xne6pfLaexiaK8h8pVuFJibShbdbS0QEE9V2UuWiakgeMWbXLgrrT114RwXKZfEJicvtz3jsUslfVhpOGZS62mQvg/640?wx_fmt=png)

▲长按图片识别二维码关注

路人甲 Java：工作 10 年的前阿里 P7，所有文章以系列的方式呈现，带领大家成为 java 高手，目前已出：java 高并发系列、mysql 高手系列、Maven 高手系列、mybatis 系列、spring 系列，正在连载 springcloud 系列，欢迎关注！