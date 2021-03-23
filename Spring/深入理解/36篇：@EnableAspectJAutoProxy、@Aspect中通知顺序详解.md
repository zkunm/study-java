> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935500&idx=2&sn=5fb794139e476a275963432948e29362&scene=21#wechat_redirect)

**这是 aop 最后一篇文章了，本文带你深入理解 @EnableAspectJAutoProxy，这篇文章可能会颠覆你以前所掌握的一些知识，让你醍醐灌顶，欣喜若狂！**

1、Aop 相关阅读
----------

阅读本文之前，需要先掌握下面几篇文章内容，不然会比较吃力。

1.  [Spring 系列第 15 篇：代理详解（java 动态代理 & CGLIB 代理)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934082&idx=1&sn=c919886400135a0152da23eaa1f276c7&chksm=88621efcbf1597eab943b064147b8fb8fd3dfbac0dc03f41d15d477ef94b60d4e8f78c66b262&token=1042984313&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [Spring 系列第 30 篇：jdk 动态代理和 cglib 代理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934783&idx=1&sn=5531f14475a4addc6d4d47f0948b3208&chksm=88621141bf159857bc19d7bb545ed3ddc4152dcda9e126f27b83afc2e975dee1682de2d98ad6&token=1672930952&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Spring 系列第 31 篇：Aop 概念详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934876&idx=1&sn=7794b50e658e0ec3e0aff6cf5ed4aa2e&chksm=886211e2bf1598f4e0e636170a4b36a5a5edd8811c8b7c30d61135cb114b0ce506a6fa84df0b&token=1672930952&lang=zh_CN&scene=21#wechat_redirect)
    
4.  [Spring 系列第 32 篇：AOP 核心源码、原理详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934930&idx=1&sn=4030960657cc72006122ef8b6f0de889&scene=21#wechat_redirect)
    
5.  [Spring 系列第 33 篇：ProxyFactoryBean 创建 AOP 代理](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934977&idx=1&sn=8e4caf6a17bf5e123884df81a6382214&scene=21#wechat_redirect)
    
6.  [Spring 系列第 34 篇：@Aspect 中 @Pointcut 12 种用法](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935037&idx=2&sn=cf813ac4cdfa3a0a0d6b5ed770255779&chksm=88621243bf159b554be2fe75eda7f5631ca29eed54edbfb97b08244625e03957429f2414d1e3&token=883563940&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [Spring 系列第 35 篇：@Aspect 中 5 中通知详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935466&idx=2&sn=f536d7a2834e6e590bc7af0527e4de1f&scene=21#wechat_redirect)
    

目前为止，上面的文章基本上都是硬编码的方式一个个为目标对象创建代理的，但是，我们使用 spring 的过程中，可能需要对大量 bean 创建代理，比如我们需拦截所有的 service 的方法，打印耗时日志，对大量 service bean 做权限校验，做事务处理等等，这些功能都可以通过 aop 的方式来实现，若采用硬编码的方式一个个创建，那是相当难受的事情。

Spring 中提供了批量的方式，为容器中符合条件的 bean，自动创建代理对象，也就是我们本文要说的`@EnableAspectJAutoProxy`。

2、@EnableAspectJAutoProxy 自动为 bean 创建代理对象
-----------------------------------------

`@EnableAspectJAutoProxy`可以自动为 spring 容器中符合条件的 bean 创建代理对象，`@EnableAspectJAutoProxy`需要结合`@Aspect`注解一起使用。用法比较简单，下面我们通过案例来看一下。

先在`com.javacode2018.aop.demo11.test1`包中定义 2 个 bean

UserService bean

```
package com.javacode2018.aop.demo11.test1;

import org.springframework.stereotype.Component;

@Component
public class UserService {
    public void say(){
        System.out.println("我是UserService");
    }
}


```

CarService bean

```
package com.javacode2018.aop.demo11.test1;

import org.springframework.stereotype.Component;

@Component
public class CarService {
    public void say() {
        System.out.println("我是CarService");
    }
}


```

通过 Aspect 来定义一个前置通知，需要拦截上面 2 个 bean 的所有方法，在方法执行之前输出一行日志

```
package com.javacode2018.aop.demo11.test1;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;

@Component //@1
@Aspect //@2
public class Aspect1 {

    @Pointcut("execution(* com.javacode2018.aop.demo11.test1..*(..))") //@3
    public void pc() {
    }

    @Before("com.javacode2018.aop.demo11.test1.Aspect1.pc()") //@4
    public void before(JoinPoint joinPoint) {
        System.out.println("我是前置通知,target:" + joinPoint.getTarget()); //5
    }
}


```

> “
> 
> Aspect1 中有 4 个关键信息
> 
> **@1**：使用 @Component 将这个类注册到 spring 容器；
> 
> **@2**：使用 @Aspect 标注着是一个 AspectJ 来定义通知的配置类；
> 
> **@3**：定义切入点，目前的配置，会拦截 test1 包及其子包中所有类的所有方法，而 CarService 和 UserService 刚好满足，所以会被拦截；
> 
> **@4**：定义一个前置通知，这个通知会对 @3 定义的切入点起效；
> 
> @5：目标方法执行执行，输出一行日志；

下面来一个 spring 配置类

```
package com.javacode2018.aop.demo11.test1;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

@ComponentScan //@1
@EnableAspectJAutoProxy //@2
public class MainConfig1 {
}


```

> “  
> 
> **@1**：@ComponentScan 注解的作用会扫描当前包中的类，将标注有 @Component 的类注册到 spring 容器；
> 
> **@2**：@EnableAspectJAutoProxy 这个注解比较关键，用来启用自动代理的创建，简单点理解：会找到容器中所有标注有 @Aspect 注解的 bean 以及 Advisor 类型的 bean，会将他们转换为 Advisor 集合，spring 会通过 Advisor 集合对容器中满足切入点表达式的 bean 生成代理对象，整个都是 spring 容器启动的过程中自动完成的，原理稍后介绍。

下面来测试用例代码，启动 spring 容器，加载配置类，验证

```
package com.javacode2018.aop.demo11;

import com.javacode2018.aop.demo11.test1.CarService;
import com.javacode2018.aop.demo11.test1.MainConfig1;
import com.javacode2018.aop.demo11.test1.UserService;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class AspectTest11 {

    @Test
    public void test1() {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(MainConfig1.class);
        context.refresh();
        UserService userService = context.getBean(UserService.class);
        userService.say();
        CarService carService = context.getBean(CarService.class);
        carService.say();
    }
  
}


```

运行输出

```
我是前置通知,target:com.javacode2018.aop.demo11.test1.UserService@dc7df28
我是UserService
我是前置通知,target:com.javacode2018.aop.demo11.test1.CarService@821330f
我是CarService


```

3、通知执行顺序
--------

`@EnableAspectJAutoProxy` 允许 spring 容器中通过 Advisor 、@Aspect 来定义通知，当 spring 容器中存在多个 Advisor、@Aspect 时，组成的拦截器调用链顺序是什么样的呢？在介绍这个之前，我们需要先回顾一下 aop 中 4 种通知相关知识。

### spring aop 中 4 种通知（Advice）

```
org.aopalliance.intercept.MethodInterceptor
org.springframework.aop.MethodBeforeAdvice
org.springframework.aop.AfterReturningAdvice
org.springframework.aop.ThrowsAdvice


```

所有的通知最终都需要转换为`MethodInterceptor`类型的通知，然后组成一个`MethodInterceptor列表`，我们称之为方法调用链或者拦截器链，上面列表中后面 3 通过下面的转换器将其包装为`MethodInterceptor`类型的通知：

```
org.springframework.aop.MethodBeforeAdvice -> org.springframework.aop.framework.adapter.MethodBeforeAdviceInterceptor
org.springframework.aop.AfterReturningAdvice -> org.springframework.aop.framework.adapter.AfterReturningAdviceInterceptor
org.springframework.aop.ThrowsAdvice -> org.springframework.aop.framework.adapter.ThrowsAdviceInterceptor


```

下面我们再来看一下 4 种通知的用法和执行过程，以方便我们理解其执行顺序。

#### org.aopalliance.intercept.MethodInterceptor：方法拦截器

方法拦截器，这个比较强大，可以在方法执行前后执行一些增强操作，其他类型的通知最终都会被包装为 MethodInterceptor 来执行。

下面我们自定义一个 MethodInterceptor

```
class MyMethodInterceptor implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation invocation) throws Throwable {
        System.out.println("我是MethodInterceptor start");
        //调用invocation.proceed()执行下一个拦截器
        Object result = invocation.proceed();
        System.out.println("我是MethodInterceptor end");
        //返回结果
        return result;
    }
}


```

#### org.springframework.aop.MethodBeforeAdvice：方法前置通知

方法前置通知，可以在方法之前定义增强操作。

下面我们自定义一个 MethodBeforeAdvice

```
class MyMethodBeforeAdvice implements MethodBeforeAdvice {

    @Override
    public void before(Method method, Object[] args, @Nullable Object target) throws Throwable {
        System.out.println("我是MethodBeforeAdvice");
    }
}


```

**MethodBeforeAdvice 最终会被包装为 MethodBeforeAdviceInterceptor 类型，然后放到拦截器链中去执行，通过 MethodBeforeAdviceInterceptor 代码可以理解 MethodBeforeAdvice 的执行过程**

```
public class MethodBeforeAdviceInterceptor implements MethodInterceptor, BeforeAdvice, Serializable {

    private final MethodBeforeAdvice advice;

    public MethodBeforeAdviceInterceptor(MethodBeforeAdvice advice) {
        this.advice = advice;
    }


    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        //调用MethodBeforeAdvice的before方法，执行前置通知
        this.advice.before(mi.getMethod(), mi.getArguments(), mi.getThis());
        //执行下一个拦截器
        return mi.proceed();
    }

}


```

#### org.springframework.aop.AfterReturningAdvice：方法返回通知

方法返回通知，用来在方法执行完毕之后执行一些增强操作。

下面我们自定义一个 AfterReturningAdvice

```
class MyAfterReturningAdvice implements AfterReturningAdvice {

    @Override
    public void afterReturning(@Nullable Object returnValue, Method method, Object[] args, @Nullable Object target) throws Throwable {
        System.out.println("我是AfterReturningAdvice");
    }
}


```

**AfterReturningAdvice 最终会被包装为 AfterReturningAdviceInterceptor 类型，然后放到拦截器链中去执行，通过 AfterReturningAdviceInterceptor 代码可以理解 AfterReturningAdvice 的执行过程**

```
public class AfterReturningAdviceInterceptor implements MethodInterceptor, AfterAdvice, Serializable {

    private final AfterReturningAdvice advice;

    public AfterReturningAdviceInterceptor(AfterReturningAdvice advice) {
        this.advice = advice;
    }


    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        //执行下一个拦截器，可以获取目标方法的返回结果
        Object retVal = mi.proceed();
        //调用方法返回通知的afterReturning方法，会传入目标方法的返回值等信息
        this.advice.afterReturning(retVal, mi.getMethod(), mi.getArguments(), mi.getThis());
        return retVal;
    }

}


```

#### org.springframework.aop.ThrowsAdvice：异常通知

当目标方法发生异常时，可以通过 ThrowsAdvice 来指定需要回调的方法，我们在此可以记录一些异常信息，或者将异常信息发送到监控系统等。

下面我们自定义一个 ThrowsAdvice

```
/**
 * 用来定义异常通知
 * 方法名必须是afterThrowing，格式参考下面2种定义
 * 1. public void afterThrowing(Exception ex)
 * 2. public void afterThrowing(Method method, Object[] args, Object target, Exception ex)
 */
class MyThrowsAdvice implements ThrowsAdvice {
    public void afterThrowing(Method method, Object[] args, Object target, Exception ex) {
        System.out.println("我是ThrowsAdvice");
    }
}


```

**ThrowsAdvice 最终会被包装为 ThrowsAdviceInterceptor 类型，然后放到拦截器链中去执行，通过 ThrowsAdviceInterceptor 代码可以理解 ThrowsAdvice 的执行过程，ThrowsAdviceInterceptor 构造参数传入一个自定义的 ThrowsAdvice 对象**

```
public class ThrowsAdviceInterceptor implements MethodInterceptor, AfterAdvice {

    private final Object throwsAdvice;

    public ThrowsAdviceInterceptor(Object throwsAdvice) {
        this.throwsAdvice = throwsAdvice;
    }

    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        try {
            return mi.proceed();
        } catch (Throwable ex) {
            //调用 ThrowsAdvice 中的 afterThrowing 方法来处理异常
            this.throwsAdvice.afterThrowing(。。。。);
            //将异常继续往外抛
            throw ex;
        }
    }
}


```

### 拦截器链执行过程

假如目标方法上面有好几个通知，调用目标方法执行，spring 会将所有的通知转换得到一个`MethodInterceptor`列表，然后依次按照下面的方式执行，会先调用第一个拦截器的`MethodInterceptor#invoke(MethodInvocation invocation)`方法，会传递一个`MethodInvocation`类型的参数，在此方法中，我们可以调用`MethodInvocation#processd`方法去执行第二个拦截器，然后依次按照这样的过程执行，到了最后一个`MethodInterceptor`中，再次调用`MethodInvocation#processd`时，会调用目标方法。

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06BnyLOp6r4cc29GA5qh9VJ4YNc03ak48yZEpYspmOWfNnbHXTuOiaSpjjs2Hw2tgLSAibWicbhibRibS5g/640?wx_fmt=png)

### 4 种通知的执行顺序

结合上面的过程，假如目标方法上面依次添加了下面 4 种通知，我们来分析一下他们的执行过程

```
class MyMethodInterceptor implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation invocation) throws Throwable {
        System.out.println("我是MethodInterceptor start");
        //调用invocation.proceed()执行下一个拦截器
        Object result = invocation.proceed();
        System.out.println("我是MethodInterceptor end");
        //返回结果
        return result;
    }
}

class MyMethodBeforeAdvice implements MethodBeforeAdvice {

    @Override
    public void before(Method method, Object[] args, @Nullable Object target) throws Throwable {
        System.out.println("我是MethodBeforeAdvice");
    }
}

class MyAfterReturningAdvice implements AfterReturningAdvice {

    @Override
    public void afterReturning(@Nullable Object returnValue, Method method, Object[] args, @Nullable Object target) throws Throwable {
        System.out.println("我是AfterReturningAdvice");
    }
}

class MyThrowsAdvice implements ThrowsAdvice {
    public void afterThrowing(Method method, Object[] args, Object target, Exception ex) {
        System.out.println("我是ThrowsAdvice");
    }
}


```

根据通知的规定，非`MethodInterceptor`类型的通知，都会被包装为`MethodInterceptor`类型的，上面除了第一个之外，其他 3 个都会被转换为`MethodInterceptor`，转换之后变成了下面这样：

```
class MyMethodInterceptor implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        System.out.println("我是MethodInterceptor start");
        //调用mi.proceed()执行下一个拦截器
        Object retVal = mi.proceed();
        System.out.println("我是MethodInterceptor end");
        //返回结果
        return retVal;
    }
}

class MyMethodBeforeAdvice implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        System.out.println("我是MethodBeforeAdvice");
        //调用mi.proceed()执行下一个拦截器
        Object retVal = mi.proceed();
        return retVal;
    }
}

class MyAfterReturningAdvice implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        //调用mi.proceed()执行下一个拦截器
        Object retVal = mi.proceed();
        System.out.println("我是AfterReturningAdvice");
        return retVal;
    }
}

class MyThrowsAdvice implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        try {
            //调用mi.proceed()执行下一个拦截器
            return mi.proceed();
        } catch (Throwable ex) {
            System.out.println("我是ThrowsAdvice");
            throw ex;
        }
    }
}


```

根据通知链的执行过程，最终变成了下面这样：

```
System.out.println("我是MethodInterceptor start");
System.out.println("我是MethodBeforeAdvice");
Object retVal = null;
try {
    retVal = 通过反射调用目标方法获取返回值;
} catch (Throwable ex) {
    System.out.println("我是ThrowsAdvice");
    throw ex;
}
System.out.println("我是AfterReturningAdvice");
System.out.println("我是MethodInterceptor end");
return retVal;


```

将上面 4 个通知用到下面目标对象中

```
public static class Service3 {
    public String say(String name) {
        return "你好：" + name;
    }
}


```

执行下面代码生成代理，然后通过代理调用 say 方法

```
Service3 target = new Service3();
Service3 proxy = 对target通过aop生成代理对象;
System.out.println(proxy.say("路人"));


```

被 4 个拦截器链包裹之后，`System.out.println(proxy.say("路人"));`执行过程变成了下面这样

```
System.out.println("我是MethodInterceptor start");
System.out.println("我是MethodBeforeAdvice");
Object retVal = null;
try {
    retVal = target.say("路人");
} catch (Throwable ex) {
    System.out.println("我是ThrowsAdvice");
    throw ex;
}
System.out.println("我是AfterReturningAdvice");
System.out.println("我是MethodInterceptor end");
System.out.println(retVal);


```

再次简化

```
System.out.println("我是MethodInterceptor start");
System.out.println("我是MethodBeforeAdvice");
Object retVal = null;
try {
    retVal = "你好：" + name;
} catch (Throwable ex) {
    System.out.println("我是ThrowsAdvice");
    throw ex;
}
System.out.println("我是AfterReturningAdvice");
System.out.println("我是MethodInterceptor end");
System.out.println(retVal);


```

最终会输出

```
我是MethodInterceptor start
我是MethodBeforeAdvice
我是AfterReturningAdvice
我是MethodInterceptor end
你好：路人


```

上案例代码，我们来看一下最终的执行结果是不是和我们分析的一样，下面为需要被代理的类`Service3`以及需要使用的 4 个通知。

```
package com.javacode2018.aop.demo11.test3;

import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;
import org.springframework.aop.AfterReturningAdvice;
import org.springframework.aop.MethodBeforeAdvice;
import org.springframework.aop.ThrowsAdvice;
import org.springframework.lang.Nullable;

import java.lang.reflect.Method;

public class MoreAdvice {

    public static class Service3 {
        public String say(String name) {
            return "你好：" + name;
        }
    }

    public static class MyMethodInterceptor implements MethodInterceptor {
        @Override
        public Object invoke(MethodInvocation invocation) throws Throwable {
            System.out.println("我是MethodInterceptor start");
            //调用invocation.proceed()执行下一个拦截器
            Object result = invocation.proceed();
            System.out.println("我是MethodInterceptor end");
            //返回结果
            return result;
        }
    }

    public static class MyMethodBeforeAdvice implements MethodBeforeAdvice {

        @Override
        public void before(Method method, Object[] args, @Nullable Object target) throws Throwable {
            System.out.println("我是MethodBeforeAdvice");
        }
    }

    public static class MyAfterReturningAdvice implements AfterReturningAdvice {

        @Override
        public void afterReturning(@Nullable Object returnValue, Method method, Object[] args, @Nullable Object target) throws Throwable {
            System.out.println("我是AfterReturningAdvice");
        }
    }

    public static class MyThrowsAdvice implements ThrowsAdvice {
        public void afterThrowing(Method method, Object[] args, Object target, Exception ex) {
            System.out.println("我是ThrowsAdvice");
        }
    }
}


```

对应测试代码

```
@Test
public void test3() {
    //创建目标对象
    MoreAdvice.Service3 target = new MoreAdvice.Service3();
    //创建代理工厂，通过代理工厂来创建代理对象
    ProxyFactory proxyFactory = new ProxyFactory();
    proxyFactory.setTarget(target);
    //依次为目标对象添加4种通知
    proxyFactory.addAdvice(new MoreAdvice.MyMethodInterceptor());
    proxyFactory.addAdvice(new MoreAdvice.MyMethodBeforeAdvice());
    proxyFactory.addAdvice(new MoreAdvice.MyAfterReturningAdvice());
    proxyFactory.addAdvice(new MoreAdvice.MyThrowsAdvice());
    //获取到代理对象
    MoreAdvice.Service3 proxy = (MoreAdvice.Service3) proxyFactory.getProxy();
    //通过代理对象访问目标方法say
    System.out.println(proxy.say("路人"));
}


```

运行输出

```
我是MethodInterceptor start
我是MethodBeforeAdvice
我是AfterReturningAdvice
我是MethodInterceptor end
你好：路人


```

和我们上面分析的确实一模一样。

4、单个 @Aspect 中多个通知的执行顺序
-----------------------

`@Aspect`标注的类中可以使用下面 5 种注解来定义通知

```
@Before
@Around
@After
@AfterReturning
@AfterThrowing


```

**当单个`@Aspect`中定义了多种类型的通知时，@EnableAspectJAutoProxy 内部会对其进行排序，排序顺序如下**

```
@AfterThrowing
@AfterReturning
@After
@Around
@Before


```

下面我们来个`@Aspect`类，同时定义 5 种通知，然后来一步步分析一下其执行的属性。

```
package com.javacode2018.aop.demo11.test4;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

@Component
@Aspect
public class Aspect4 {
    @Pointcut("execution(* com.javacode2018.aop.demo11.test4.Service4.*(..))")
    public void pc() {
    }

    @Before("pc()")
    public void before() {
        System.out.println("@Before通知!");
    }

    @Around("pc()")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        System.out.println("@Around通知start");
        Object result = joinPoint.proceed();
        System.out.println("@Around绕通知end");
        return result;
    }

    @After("pc()")
    public void after() throws Throwable {
        System.out.println("@After通知!");
    }

    @AfterReturning("pc()")
    public void afterReturning() throws Throwable {
        System.out.println("@AfterReturning通知!");
    }

    @AfterThrowing("pc()")
    public void afterThrowing() {
        System.out.println("@AfterThrowing通知!");
    }

}


```

上面会拦截`com.javacode2018.aop.demo11.test4.Service4`这个类中的所有方法，下面是`Service4`的源码。

```
package com.javacode2018.aop.demo11.test4;

import org.springframework.stereotype.Component;

@Component
public class Service4 {
    public String say(String name) {
        return "你好：" + name;
    }
}


```

来个 spring 的配置类，使用`@EnableAspectJAutoProxy`标注

```
package com.javacode2018.aop.demo11.test4;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

@EnableAspectJAutoProxy
@ComponentScan
public class MainConfig4 {
}


```

测试代码

```
@Test
public void test4(){
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig4.class);
    context.refresh();
    Service4 service4 = context.getBean(Service4.class);
    System.out.println(service4.say("路人"));
}


```

运行依次输出如下

```
@Around通知start
@Before通知!
@Around绕通知end
@After通知!
@AfterReturning通知!
你好：路人


```

**卧槽，这输出好像和我们上面说的不一样的，上面说的会按照下面的顺序执行，这到底是什么情况？**

```
@AfterThrowing
@AfterReturning
@After
@Around
@Before


```

**别急，排序规则和输出结果都没有问题，听我慢慢分析，下面的分析非常重要，注意看了**

5、@Aspect 中 5 种通知回顾
-------------------

### 5 种通知对应的 Advice 类

@Aspect 中通过 5 中注解来定义通知，这些注解最终都需要转换为 Advice 去执行，转换关系如下

<table data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)"><thead data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)"><tr data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183001309="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204) currentcolor currentcolor; border-style: solid none none; border-width: 1px 0px 0px; background-color: white;"><th data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183001309="rgb(240, 240, 240)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; font-weight: bold; background-color: rgb(240, 240, 240); min-width: 85px;">通知</th><th data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183001309="rgb(240, 240, 240)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; font-weight: bold; background-color: rgb(240, 240, 240); min-width: 85px;">对应的 Advice 类</th></tr></thead><tbody data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)"><tr data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183001309="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204) currentcolor currentcolor; border-style: solid none none; border-width: 1px 0px 0px; background-color: white;"><td data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183001309="rgb(255,255,255)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; min-width: 85px;">@AfterThrowing</td><td data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183001309="rgb(255,255,255)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; min-width: 85px;">org.springframework.aop.aspectj.AspectJAfterThrowingAdvice</td></tr><tr data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183001309="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204) currentcolor currentcolor; border-style: solid none none; border-width: 1px 0px 0px; background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183001309="rgb(248, 248, 248)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; min-width: 85px;">@AfterReturning</td><td data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183001309="rgb(248, 248, 248)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; min-width: 85px;">org.springframework.aop.aspectj.AspectJAfterReturningAdvice</td></tr><tr data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183001309="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204) currentcolor currentcolor; border-style: solid none none; border-width: 1px 0px 0px; background-color: white;"><td data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183001309="rgb(255,255,255)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; min-width: 85px;">@After</td><td data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183001309="rgb(255,255,255)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; min-width: 85px;">org.springframework.aop.aspectj.AspectJAfterAdvice</td></tr><tr data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183001309="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204) currentcolor currentcolor; border-style: solid none none; border-width: 1px 0px 0px; background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183001309="rgb(248, 248, 248)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; min-width: 85px;">@Around</td><td data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183001309="rgb(248, 248, 248)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; min-width: 85px;">org.springframework.aop.aspectj.AspectJAroundAdvice</td></tr><tr data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183001309="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204) currentcolor currentcolor; border-style: solid none none; border-width: 1px 0px 0px; background-color: white;"><td data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183001309="rgb(255,255,255)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; min-width: 85px;">@Before</td><td data-darkmode-color-16079183001309="rgb(163, 163, 163)" data-darkmode-original-color-16079183001309="rgb(0,0,0)" data-darkmode-bgcolor-16079183001309="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183001309="rgb(255,255,255)" data-style="font-size: 16px; border-color: rgb(204, 204, 204); border-style: solid; border-width: 1px; padding: 5px 10px; text-align: left; min-width: 85px;">org.springframework.aop.aspectj.AspectJMethodBeforeAdvice</td></tr></tbody></table>

重点就在于表格右边的 Advice 类，当了解这些 Advice 的源码之后，他们的执行顺序大家就可以理解了，我们来看一下这些类的源码，重点看`invoke`方法

### @AfterThrowing：AspectJAfterThrowingAdvice

```
public class AspectJAfterThrowingAdvice implements MethodInterceptor {

    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        try {
            //执行下一个拦截器
            return mi.proceed();
        } catch (Throwable ex) {
            //通过反射调用@AfterThrowing标注的方法
            //继续抛出异常
            throw ex;
        }
    }
}


```

`AspectJAfterThrowingAdvice` 实现了 `MethodInterceptor` 接口，不需要进行包装。

### @AfterReturning：AspectJAfterReturningAdvice

`AspectJAfterReturningAdvice` 源码：

```
public class AspectJAfterReturningAdvice implements AfterReturningAdvice {
    @Override
    public void afterReturning(@Nullable Object returnValue, Method method, Object[] args, @Nullable Object target) throws Throwable {
        // 调用@AfterReturning标注的方法
    }
}


```

`AspectJAfterReturningAdvice` 实现了 `AfterReturningAdvice` 接口，是一个方法返回通知，不是`MethodInterceptor`类型的，所以最终需包装为`MethodInterceptor`类型，变成下面这样

```
public class AspectJAfterReturningAdvice implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        //执行下一个拦截器
        Object retVal = mi.proceed();
        //调用@AfterReturning标注的方法
        return retVal;
    }
}


```

### @After：AspectJAfterAdvice

`AspectJAfterAdvice` 源码：

```
public class AspectJAfterAdvice implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        try {
            //执行下一个拦截器
            return mi.proceed();
        } finally {
            //调用@After标注的方法
        }
    }
}


```

`AspectJAfterAdvice` 实现了 `MethodInterceptor`接口，所以最终执行的时候不需要进行包装。

**注意 invoke 方法内部使用了 try...finally 的方式，@After 方法的调用放在了 finally 中，所以不管是否有异常，@After 类型的通知都会被执行。**

### @Around：AspectJAroundAdvice

`AspectJAroundAdvice` 源码：

```
public class AspectJAroundAdvice extends AbstractAspectJAdvice implements MethodInterceptor, Serializable {
    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        return 调用 @Around标注的方法 ;
    }
}


```

`AspectJAroundAdvice`  实现了 `MethodInterceptor`接口，最终执行的时候也不需要进行包装。

### @Before：AspectJMethodBeforeAdvice

`AspectJMethodBeforeAdvice` 源码：

```
public class AspectJMethodBeforeAdvice implements MethodBeforeAdvice, Serializable {
    @Override
    public void before(Method method, Object[] args, @Nullable Object target) throws Throwable {
        invokeAdviceMethod(getJoinPointMatch(), null, null);
    }
}


```

`AspectJMethodBeforeAdvice` 实现了 `MethodBeforeAdvice`接口，是一个前置通知，不是`MethodInterceptor`类型的，所以最终需包装为`MethodInterceptor`类型，变成下面这样

```
public class AspectJMethodBeforeAdvice implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation mi) throws Throwable {
        //调用@Before标注的方法
        //执行下一个拦截器
        return mi.proceed();
    }
}


```

6、分析单个 @Aspect 中多个通知执行顺序
------------------------

大家对 @Aspect 中 5 种通知内容理解之后，我们再回头看一下代码`Aspect4`中定义的 5 个通知

```
public class Aspect4 {
    @Pointcut("execution(* com.javacode2018.aop.demo11.test4.Service4.*(..))")
    public void pc() {
    }

    @Before("pc()")
    public void before() {
        System.out.println("@Before通知!");
    }

    @Around("pc()")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        System.out.println("@Around通知start");
        Object result = joinPoint.proceed();
        System.out.println("@Around绕通知end");
        return result;
    }

    @After("pc()")
    public void after() throws Throwable {
        System.out.println("@After通知!");
    }

    @AfterReturning("pc()")
    public void afterReturning() throws Throwable {
        System.out.println("@AfterReturning通知!");
    }

    @AfterThrowing("pc()")
    public void afterThrowing() {
        System.out.println("@AfterThrowing通知!");
    }

}


```

我们给出的结论是，会按照下面的顺序执行

```
@AfterThrowing
@AfterReturning
@After
@Around
@Before


```

按照上面的顺序，一步步来分析。

先执行第 1 个通知`@AfterThrowing`，变成下面这样

```
try {
    //执行下一个拦截器
    return mi.proceed();
} catch (Throwable ex) {
    System.out.println("@AfterThrowing通知!");
    //继续抛出异常
    throw ex;
}


```

`mi.processed()`会执行第 2 个通知`@AfterReturning`，变成了下面这样

```
try {
    //执行下一个拦截器
    Object retVal = mi.proceed();
    System.out.println("@AfterReturning通知!");
    return retVal;
} catch (Throwable ex) {
    System.out.println("@AfterThrowing通知!");
    //继续抛出异常
    throw ex;
}


```

继续`mi.proceed()`执行第 3 个通知`@After`，变成了下面这样

```
try {
    Object result = null;
    try {
        //执行下一个拦截器
        result = mi.proceed();
    } finally {
        System.out.println("@After通知!");
    }
    System.out.println("@AfterReturning通知!");
    return retVal;
} catch (Throwable ex) {
    System.out.println("@AfterThrowing通知!");
    //继续抛出异常
    throw ex;
}


```

继续`mi.proceed()`执行第 4 个通知`@Around`，变成了下面这样

```
try {
    Object result = null;
    try {
        System.out.println("@Around通知start");
        result = joinPoint.proceed();
        System.out.println("@Around绕通知end");
        return result;
    } finally {
        System.out.println("@After通知!");
    }
    System.out.println("@AfterReturning通知!");
    return retVal;
} catch (Throwable ex) {
    System.out.println("@AfterThrowing通知!");
    //继续抛出异常
    throw ex;
}


```

继续`joinPoint.proceed()`执行第 5 个通知`@Before`，变成了下面这样

```
try {
    Object result = null;
    try {
        System.out.println("@Around通知start");
        System.out.println("@Before通知!");
        result = mi.proceed();
        System.out.println("@Around绕通知end");
        return result;
    } finally {
        System.out.println("@After通知!");
    }
    System.out.println("@AfterReturning通知!");
    return retVal;
} catch (Throwable ex) {
    System.out.println("@AfterThrowing通知!");
    //继续抛出异常
    throw ex;
}


```

继续`joinPoint.proceed()`会调用目标方法，变成了下面这样

```
try {
    Object result = null;
    try {
        System.out.println("@Around通知start");
        System.out.println("@Before通知!");
        result = // 通过反射调用目标方法; //@1
        System.out.println("@Around绕通知end");
        return result;
    } finally {
        System.out.println("@After通知!");
    }
    System.out.println("@AfterReturning通知!");
    return retVal;
} catch (Throwable ex) {
    System.out.println("@AfterThrowing通知!");
    //继续抛出异常
    throw ex;
}


```

将上面的`@1`替换为目标方法的调用，就变成下面这样了

```
try {
    Object result = null;
    try {
        System.out.println("@Around通知start");
        System.out.println("@Before通知!");
        result = service4.say("路人");
        System.out.println("@Around绕通知end");
        return result;
    } finally {
        System.out.println("@After通知!");
    }
    System.out.println("@AfterReturning通知!");
    return retVal;
} catch (Throwable ex) {
    System.out.println("@AfterThrowing通知!");
    //继续抛出异常
    throw ex;
}


```

所以最终输出

```
@Around通知start
@Before通知!
@Around绕通知end
@After通知!
@AfterReturning通知!
你好：路人


```

7、@EnableAspectJAutoProxy 中为通知指定顺序
----------------------------------

`@EnableAspectJAutoProxy`用在 spring 环境中，可以通过`@Aspect`以及`Advisor`来定义多个通知，当 spring 容器中有多个`@Aspect、Advisor`时，他们的顺序是什么样的呢？

我们先看一下如何为`@Aspect`、`自定义Advisor`指定顺序。

### 为 @Aspect 指定顺序：用 @Order 注解

需要在`@Aspect`标注的类上使用`@org.springframework.core.annotation.Order`注解，值越小，通知的优先级越高。

```
@Aspect
@Order(1)
public class AspectOrder1{}


```

### 为 Advisor 指定顺序：实现 Ordered 接口

自定义的`Advisor`通过`org.springframework.core.Ordered`接口来指定顺序，这个接口有个`public int getOrder()`方法，用来返回通知的顺序。

spring 为我们提供了一个`Advisor`类型的抽象类`org.springframework.aop.support.AbstractPointcutAdvisor`，这个类实现了`Ordered`接口，spring 中大部分`Advisor`会是继承`AbstractPointcutAdvisor`，若需要自定义`Advisor`，也可以继承这个类，这个类的`getOrder`方法比较关键，来看一下

```
public abstract class AbstractPointcutAdvisor implements PointcutAdvisor, Ordered, Serializable {

    @Nullable
    private Integer order;

    public void setOrder(int order) {
        this.order = order;
    }

    @Override
    public int getOrder() {
        //若当前Advisor指定了order，则直接返回
        if (this.order != null) {
            return this.order;
        }
        //获取当前类中配置的通知对象Advice
        Advice advice = getAdvice();
        //若advice实现了Ordered接口，这从advice中获取通知的顺序
        if (advice instanceof Ordered) {
            return ((Ordered) advice).getOrder();
        }
        //否则通知的优先级最低，Integer.MAX_VALUE
        return Ordered.LOWEST_PRECEDENCE;
    }
}


```

Spring 为我们提供了一个默认的`Advisor`类：`DefaultPointcutAdvisor`，这个类就继承了`AbstractPointcutAdvisor`，通常我们可以直接使用`DefaultPointcutAdvisor`来自定义通知。

8、多个 @Aspect、Advisor 排序规则
-------------------------

### 排序规则

**1、在 spring 容器中获取 @Aspect、Advisor 类型的所有 bean，得到一个列表 list1**

**2、对 list1 按照 order 的值升序排序，得到结果 list2**

**3、然后再对 list2 中 @Aspect 类型的 bean 内部的通知进行排序，规则**

```
@AfterThrowing
@AfterReturning
@After
@Around
@Before


```

4、最后运行的时候会得到上面排序产生的方法调用链列表去执行。

### 案例

下面我们定义 2 个 @Aspect 类，一个 Advisor 类，并且给这 3 个都指定，然后来验证一下通知执行的顺序。

#### 先定义目标类

```
package com.javacode2018.aop.demo11.test2;

import org.springframework.stereotype.Component;

@Component
public class Service2 {
    public String say(String name) {
        return "你好：" + name;
    }
}


```

#### Aspect1：第 2 个 @Aspect

```
package com.javacode2018.aop.demo11.test2;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Aspect
@Order(1)
@Component
public class MyAspect1 {

    @Pointcut("execution(* com.javacode2018.aop.demo11.test2.Service2.*(..))")
    public void pc() {
    }

    @Before("pc()")
    public void before() {
        System.out.println("MyAspect1 @Before通知!");
    }

    @Around("pc()")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        System.out.println("MyAspect1 @Around通知start");
        Object result = joinPoint.proceed();
        System.out.println("MyAspect1 @Around绕通知end");
        return result;
    }

    @After("pc()")
    public void after() throws Throwable {
        System.out.println("MyAspect1 @After通知!");
    }

    @AfterReturning("pc()")
    public void afterReturning() throws Throwable {
        System.out.println("MyAspect1 @AfterReturning通知!");
    }

    @AfterThrowing("pc()")
    public void afterThrowing() {
        System.out.println("MyAspect1 @AfterThrowing通知!");
    }

}


```

#### Aspect1：第 2 个 @Aspect

```
package com.javacode2018.aop.demo11.test2;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Aspect
@Order(3)
@Component
public class MyAspect2 {

    @Pointcut("execution(* com.javacode2018.aop.demo11.test2.Service2.*(..))")
    public void pc() {
    }

    @Before("pc()")
    public void before() {
        System.out.println("MyAspect2 @Before通知!");
    }

    @Around("pc()")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        System.out.println("MyAspect2 @Around通知start");
        Object result = joinPoint.proceed();
        System.out.println("MyAspect2 @Around绕通知end");
        return result;
    }

    @After("pc()")
    public void after() throws Throwable {
        System.out.println("MyAspect2 @After通知!");
    }

    @AfterReturning("pc()")
    public void afterReturning() throws Throwable {
        System.out.println("MyAspect2 @AfterReturning通知!");
    }

    @AfterThrowing("pc()")
    public void afterThrowing() {
        System.out.println("MyAspect2 @AfterThrowing通知!");
    }

}


```

#### 自定义一个 Advisor

```
package com.javacode2018.aop.demo11.test2;

import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;
import org.springframework.aop.support.DefaultPointcutAdvisor;
import org.springframework.stereotype.Component;

@Component
public class Advisor1 extends DefaultPointcutAdvisor {

    public Advisor1() {
        MethodInterceptor methodInterceptor = new MethodInterceptor() {
            @Override
            public Object invoke(MethodInvocation invocation) throws Throwable {
                System.out.println("Advisor1 start");
                Object result = invocation.proceed();
                System.out.println("Advisor1 end");
                return result;
            }
        };
        this.setAdvice(methodInterceptor);
    }

    @Override
    public int getOrder() {
        return 2;
    }
}


```

#### 来个 spring 配置类

标注`@EnableAspectJAutoProxy`来启用自动化的 aop 功能

```
package com.javacode2018.aop.demo11.test2;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

@ComponentScan
@EnableAspectJAutoProxy
public class MainConfig2 {
}


```

#### 测试代码

```
@Test
public void test2() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig2.class);
    context.refresh();
    Service2 service2 = context.getBean(Service2.class);
    System.out.println(service2.say("路人"));
}


```

#### 运行输出

```
MyAspect1 @Around通知start
MyAspect1 @Before通知!
Advisor1 start
MyAspect2 @Around通知start
MyAspect2 @Before通知!
MyAspect2 @Around绕通知end
MyAspect2 @After通知!
MyAspect2 @AfterReturning通知!
Advisor1 end
MyAspect1 @Around绕通知end
MyAspect1 @After通知!
MyAspect1 @AfterReturning通知!
你好：路人


```

#### 结果分析

下面我们一步步来推出结果为什么是上面这样。

先获取 spring 容器中 @Aspect、Advisor 类型的所有 bean，根据其 order 升序排序，得到：

```
Aspect1：顺序是1
Advisor1：顺序是2
MyAspect2：顺序是3


```

然后对每个`Aspect`内部的通知进行排序，根据单个`@Aspect`内部通知排序规则，可以得到：

```
Aspect1：顺序是1
 @AfterThrowing
    @AfterReturning
    @After
    @Around
    @Before

Advisor1：顺序是2

MyAspect2：顺序是3
 @AfterThrowing
    @AfterReturning
    @After
    @Around
    @Before


```

下面将代码拿过来一步步填充。

先对`Aspect1`进行填充，得到：

```
try {
    Object result = null;
    try {
        System.out.println("MyAspect1 @Around通知start");
        System.out.println("MyAspect1 @Before通知!");
        result = mi.proceed(); //@1
        System.out.println("MyAspect1 @Around绕通知end");
        return result;
    } finally {
        System.out.println("MyAspect1 @After通知!");
    }
    System.out.println("MyAspect1 @AfterReturning通知!");
    return retVal;
} catch (Throwable ex) {
    System.out.println("MyAspect1 @AfterThrowing通知!");
    //继续抛出异常
    throw ex;
}


```

`@1`执行`mi.proceed()`会调用下一个拦截器，即`Advisor1`中定义的拦截器，然后会得到下面代码：

```
try {
    Object result = null;
    try {
        System.out.println("MyAspect1 @Around通知start");
        System.out.println("MyAspect1 @Before通知!");
        System.out.println("Advisor1 start");
        result = invocation.proceed(); //@2
        System.out.println("Advisor1 end");
        System.out.println("MyAspect1 @Around绕通知end");
        return result;
    } finally {
        System.out.println("MyAspect1 @After通知!");
    }
    System.out.println("MyAspect1 @AfterReturning通知!");
    return retVal;
} catch (Throwable ex) {
    System.out.println("MyAspect1 @AfterThrowing通知!");
    //继续抛出异常
    throw ex;
}


```

`@2`执行`mi.proceed()`会调用下一个拦截器，即`Aspect2`中定义的拦截器，而`Aspect2`和`Aspect1`类似，然后会得到下面代码：

```
try {
    Object result = null;
    try {
        System.out.println("MyAspect1 @Around通知start");
        System.out.println("MyAspect1 @Before通知!");
        System.out.println("Advisor1 start");
        try {
            try {
                System.out.println("MyAspect2 @Around通知start");
                System.out.println("MyAspect2 @Before通知!");
                result = mi.proceed(); //@3
                System.out.println("MyAspect2 @Around绕通知end");
                return result;
            } finally {
                System.out.println("MyAspect2 @After通知!");
            }
            System.out.println("MyAspect2 @AfterReturning通知!");
        } catch (Throwable ex) {
            System.out.println("MyAspect2 @AfterThrowing通知!");
            //继续抛出异常
            throw ex;
        }
        System.out.println("Advisor1 end");
        System.out.println("MyAspect1 @Around绕通知end");
        return result;
    } finally {
        System.out.println("MyAspect1 @After通知!");
    }
    System.out.println("MyAspect1 @AfterReturning通知!");
    return retVal;
} catch (Throwable ex) {
    System.out.println("MyAspect1 @AfterThrowing通知!");
    //继续抛出异常
    throw ex;
}


```

`@3`继续执行`mi.proceed()`，此时会调用目标方法`say("路人")`，然后就进化成下面这样了

```
try {
    Object result = null;
    try {
        System.out.println("MyAspect1 @Around通知start");
        System.out.println("MyAspect1 @Before通知!");
        System.out.println("Advisor1 start");
        try {
            try {
                System.out.println("MyAspect2 @Around通知start");
                System.out.println("MyAspect2 @Before通知!");
                result = "你好：路人";
                System.out.println("MyAspect2 @Around绕通知end");
                return result;
            } finally {
                System.out.println("MyAspect2 @After通知!");
            }
            System.out.println("MyAspect2 @AfterReturning通知!");
        } catch (Throwable ex) {
            System.out.println("MyAspect2 @AfterThrowing通知!");
            //继续抛出异常
            throw ex;
        }
        System.out.println("Advisor1 end");
        System.out.println("MyAspect1 @Around绕通知end");
        return result;
    } finally {
        System.out.println("MyAspect1 @After通知!");
    }
    System.out.println("MyAspect1 @AfterReturning通知!");
    return retVal;
} catch (Throwable ex) {
    System.out.println("MyAspect1 @AfterThrowing通知!");
    //继续抛出异常
    throw ex;
}


```

再来和输出结果对比一下，是完全一致的。

```
MyAspect1 @Around通知start
MyAspect1 @Before通知!
Advisor1 start
MyAspect2 @Around通知start
MyAspect2 @Before通知!
MyAspect2 @Around绕通知end
MyAspect2 @After通知!
MyAspect2 @AfterReturning通知!
Advisor1 end
MyAspect1 @Around绕通知end
MyAspect1 @After通知!
MyAspect1 @AfterReturning通知!
你好：路人


```

9、@EnableAspectJAutoProxy 另外 2 个功能
----------------------------------

这个注解还有 2 个参数，大家看一下下面的注释，比较简单，就不用案例演示了。

```
public @interface EnableAspectJAutoProxy {

 /**
  * 是否基于类来创建代理，而不是基于接口来创建代理
  * 当为true的时候会使用cglib来直接对目标类创建代理对象
  * 默认为 false：即目标bean如果有接口的会采用jdk动态代理来创建代理对象，没有接口的目标bean，会采用cglib来创建代理对象
  */
 boolean proxyTargetClass() default false;

 /**
  * 是否需要将代理对象暴露在ThreadLocal中，当为true的时候
  * 可以通过org.springframework.aop.framework.AopContext#currentProxy获取当前代理对象
  */
 boolean exposeProxy() default false;

}


```

10、@EnableAspectJAutoProxy 原理
-----------------------------

`@EnableAspectJAutoProxy`会在 spring 容器中注册一个 bean

```
org.springframework.aop.aspectj.annotation.AnnotationAwareAspectJAutoProxyCreator


```

`AnnotationAwareAspectJAutoProxyCreator`是`BeanPostProcessor`类型的，`BeanPostProcessor`大家应该比较熟悉了，bean 后置处理器，可以在 bean 声明周期中对 bean 进行操作，比如对 bean 生成代理等；而`AnnotationAwareAspectJAutoProxyCreator`就是对符合条件的 bean，自动生成代理对象，源码就这里就不细说了，有兴趣的可以从`postProcessAfterInitialization`方法看，比较简单。

11、总结
-----

今天内容还是挺多的，大家好好消化一下。

主要要掌握`@EnableAspectJAutoProxy`中多个`@Aspect、Advisor`时，通知的执行顺序，这个多看看，要理解其原理，记起来才会更容易，用起来也会更顺手。

**如发现文章有错误、对内容有疑问，都可以在文章下面留言，或者加我微信（itsoku）交流，每周会挑选出一位热心小伙伴，送上一份精美的小礼品，快来关注我吧！**

12、案例源码
-------

```
https://gitee.com/javacode2018/spring-series


```

**路人甲 java 所有案例代码以后都会放到这个上面，大家 watch 一下，可以持续关注动态。**

13、Spring 系列
------------

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
    

14、更多好文章
--------

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