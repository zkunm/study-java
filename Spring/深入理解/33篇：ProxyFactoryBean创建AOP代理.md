AOP 创建代理的方式主要分为 2 大类
--------------------

### 手动方式

也称为手动的方式，需要通过硬编码一个个创建代理。

### 自动化的方式

也称为批量的方式，批量的方式用在 spring 环境中，通过 bean 后置处理器来对符合条件的 bean 创建代理

手动的方式基本上是采用硬编码的方式，相对来说更灵活一些，可以脱离 spring 环境使用，而自动化的方式主要用在 spring 环境中，和 spring 集成起来更容易一些，更强大一些。

AOP 创建代理相关的类

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06AJxu6zWRbs7ic8Xd0mZClWRWJQ6CAxul7ibqmtWneZvyJfgvz04LoLvAbcw0VfpGUnXBTjp9HhxZ7w/640?wx_fmt=png)

左边的`ProxyCreatorSupport`下面的都是手动的方式，有 3 个类。

右边的`AbstractAutoProxyCreator`下面挂的都是自动创建代理的方式，主要有 5 个实现类。

手动 3 种方式
--------

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06AJxu6zWRbs7ic8Xd0mZClWRONtNEboYSbu27vniaLicGBJ6EVDWac6HVN4cub3eok8M2aOw77Daia7jg/640?wx_fmt=png)

### ProxyFactory 方式

这种是硬编码的方式，可以脱离 spring 直接使用，用到的比较多，自动化方式创建代理中都是依靠`ProxyFactory`来实现的，所以这种方式的原理大家一定要了解，上篇文章中已经有介绍过了，不清楚的可以去看一下：[Spring 系列第 32 篇：AOP 核心源码、原理详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934930&idx=1&sn=4030960657cc72006122ef8b6f0de889&scene=21#wechat_redirect)

### AspectJProxyFactory 方式

AspectJ 是一个面向切面的框架，是目前最好用，最方便的 AOP 框架，Spring 将其集成进来了，通过 Aspectj 提供的一些功能实现 aop 代理非常方便，下篇文章将详解。

### ProxyFactoryBean 方式

Spring 环境中给指定的 bean 创建代理的一种方式，本文主要介绍这个。

ProxyFactoryBean
----------------

这个类实现了一个接口`FactoryBean`，`FactoryBean`不清楚的可以看一下：[Spring 系列第 5 篇：创建 bean 实例这些方式你们都知道？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933955&idx=2&sn=bbf4c1c9c996df9454b71a9f68d59779&chksm=88621e7dbf15976ba26c8919394b9049c3906223c4e97b88ccfed62e75ec4688668555dd200f&token=1045303334&lang=zh_CN&scene=21#wechat_redirect)

`ProxyFactoryBean`就是通过`FactoryBean`的方式来给指定的 bean 创建一个代理对象。

创建代理，有 3 个信息比较关键：

1.  需要增强的功能，这个放在通知（Advice）中实现
    
2.  目标对象（target）：表示你需要给哪个对象进行增强
    
3.  代理对象（proxy）：将增强的功能和目标对象组合在一起，然后形成的一个代理对象，通过代理对象来访问目标对象，起到对目标对象增强的效果。
    

使用`ProxyFactoryBean`也是围绕着 3 部分来的，`ProxyFactoryBean`使用的步骤：

```
1.创建ProxyFactoryBean对象
2.通过ProxyFactoryBean.setTargetName设置目标对象的bean名称，目标对象是spring容器中的一个bean
3.通过ProxyFactoryBean。setInterceptorNames添加需要增强的通知
4.将ProxyFactoryBean注册到Spring容器，假设名称为proxyBean
5.从Spring查找名称为proxyBean的bean，这个bean就是生成好的代理对象


```

上案例。

来个类`Service1`

```
package com.javacode2018.aop.demo8.test1;

public class Service1 {

    public void m1() {
        System.out.println("我是 m1 方法");
    }

    public void m2() {
        System.out.println("我是 m2 方法");
    }
}


```

需求

> 在 spring 容器中注册上面这个类的 bean，名称为`service1`，通过代理的方式来对这个 bean 进行增强，来 2 个通知
> 
> 一个前置通知：在调用`service1`中的任意方法之前，输出一条信息：准备调用 xxxx 方法
> 
> 一个环绕通知：复制统计所有方法的耗时。

下面是代码的实现

```
package com.javacode2018.aop.demo8.test1;

import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;
import org.springframework.aop.MethodBeforeAdvice;
import org.springframework.aop.framework.ProxyFactoryBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.lang.Nullable;

import java.lang.reflect.Method;

@Configuration
public class MainConfig1 {
    //注册目标对象
    @Bean
    public Service1 service1() {
        return new Service1();
    }

    //注册一个前置通知
    @Bean
    public MethodBeforeAdvice beforeAdvice() {
        MethodBeforeAdvice advice = new MethodBeforeAdvice() {
            @Override
            public void before(Method method, Object[] args, @Nullable Object target) throws Throwable {
                System.out.println("准备调用：" + method);
            }
        };
        return advice;
    }

    //注册一个后置通知
    @Bean
    public MethodInterceptor costTimeInterceptor() {
        MethodInterceptor methodInterceptor = new MethodInterceptor() {
            @Override
            public Object invoke(MethodInvocation invocation) throws Throwable {
                long starTime = System.nanoTime();
                Object result = invocation.proceed();
                long endTime = System.nanoTime();
                System.out.println(invocation.getMethod() + ",耗时(纳秒)：" + (endTime - starTime));
                return result;
            }
        };
        return methodInterceptor;
    }

    //注册ProxyFactoryBean
    @Bean
    public ProxyFactoryBean service1Proxy() {
        //1.创建ProxyFactoryBean
        ProxyFactoryBean proxyFactoryBean = new ProxyFactoryBean();
        //2.设置目标对象的bean名称
        proxyFactoryBean.setTargetName("service1");
        //3.设置拦截器的bean名称列表，此处2个（advice1和advice2)
        proxyFactoryBean.setInterceptorNames("beforeAdvice", "costTimeInterceptor");
        return proxyFactoryBean;
    }
}


```

下面启动 spring 容器，并获取代理对象

```
AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig1.class);
//获取代理对象，代理对象bean的名称为注册ProxyFactoryBean的名称，即：service1Proxy
Service1 bean = context.getBean("service1Proxy", Service1.class);
System.out.println("----------------------");
//调用代理的方法
bean.m1();
System.out.println("----------------------");
//调用代理的方法
bean.m2();


```

运行输出

```
----------------------
准备调用：public void com.javacode2018.aop.demo8.test1.Service1.m1()
我是 m1 方法
public void com.javacode2018.aop.demo8.test1.Service1.m1(),耗时(纳秒)：8680400
----------------------
准备调用：public void com.javacode2018.aop.demo8.test1.Service1.m2()
我是 m2 方法
public void com.javacode2018.aop.demo8.test1.Service1.m2(),耗时(纳秒)：82400


```

从输出中可以看到，目标对象`service1`已经被增强了。

ProxyFactoryBean 中的 interceptorNames
------------------------------------

`interceptorNames`用来指定拦截器的 bean 名称列表，常用的 2 种方式。

*   批量的方式
    
*   非批量的方式
    

### 批量的方式

#### 使用方法

```
proxyFactoryBean.setInterceptorNames("需要匹配的bean名称*");


```

需要匹配的 bean 名称后面跟上一个`*`，可以用来批量的匹配，如：`interceptor*`，此时 spring 会从容器中找到下面 2 中类型的所有 bean，bean 名称以`interceptor`开头的将作为增强器

```
org.springframework.aop.Advisor
org.aopalliance.intercept.Interceptor


```

这个地方使用的时候需要注意，批量的方式注册的时候，如果增强器的类型不是上面 2 种类型的，比如下面 3 种类型通知，我们需要将其包装为`Advisor`才可以，而`MethodInterceptor`是`Interceptor`类型的，可以不用包装为`Advisor`类型的。

```
MethodBeforeAdvice（方法前置通知）
AfterReturningAdvice（方法后置通知）
ThrowsAdvice（异常通知）


```

下面来个案例感受一下。

#### 案例

下面批量注册 2 个增强器。

```
package com.javacode2018.aop.demo8.test2;

import com.javacode2018.aop.demo8.test1.Service1;
import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;
import org.springframework.aop.Advisor;
import org.springframework.aop.MethodBeforeAdvice;
import org.springframework.aop.framework.ProxyFactoryBean;
import org.springframework.aop.support.DefaultPointcutAdvisor;
import org.springframework.context.annotation.Bean;
import org.springframework.lang.Nullable;

import java.lang.reflect.Method;

public class MainConfig2 {
    //注册目标对象
    @Bean
    public Service1 service1() {
        return new Service1();
    }

    //定义一个增强器：interceptor1，内部是一个前置通知，需要将其包装为Advisor类型的
    @Bean
    public Advisor interceptor1() {
        MethodBeforeAdvice advice = new MethodBeforeAdvice() {
            @Override
            public void before(Method method, Object[] args, @Nullable Object target) throws Throwable {
                System.out.println("准备调用：" + method);
            }
        };
        DefaultPointcutAdvisor advisor = new DefaultPointcutAdvisor();
        advisor.setAdvice(advice);
        return advisor;
    }

    //定义一个增强器：interceptor2
    @Bean
    public MethodInterceptor interceptor2() {
        MethodInterceptor methodInterceptor = new MethodInterceptor() {
            @Override
            public Object invoke(MethodInvocation invocation) throws Throwable {
                long starTime = System.nanoTime();
                Object result = invocation.proceed();
                long endTime = System.nanoTime();
                System.out.println(invocation.getMethod() + ",耗时(纳秒)：" + (endTime - starTime));
                return result;
            }
        };
        return methodInterceptor;
    }

    //注册ProxyFactoryBean
    @Bean
    public ProxyFactoryBean service1Proxy() {
        //1.创建ProxyFactoryBean
        ProxyFactoryBean proxyFactoryBean = new ProxyFactoryBean();
        //2.设置目标对象的bean名称
        proxyFactoryBean.setTargetName("service1");
        //3.设置拦截器的bean名称列表，此处批量注册
        proxyFactoryBean.setInterceptorNames("interceptor*"); //@1
        return proxyFactoryBean;
    }
}


```

> 上面定义了 2 个增强器：
> 
> interceptor1：前置通知，包装为 Advisor 类型了
> 
> interceptor2：环绕通知，MethodInterceptor 类型的

测试代码

```
@Test
public void test2() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig2.class);
    //获取代理对象，代理对象bean的名称为注册ProxyFactoryBean的名称，即：service1Proxy
    Service1 bean = context.getBean("service1Proxy", Service1.class);
    System.out.println("----------------------");
    //调用代理的方法
    bean.m1();
    System.out.println("----------------------");
    //调用代理的方法
    bean.m2();
}


```

运行输出

```
----------------------
准备调用：public void com.javacode2018.aop.demo8.test1.Service1.m1()
我是 m1 方法
public void com.javacode2018.aop.demo8.test1.Service1.m1(),耗时(纳秒)：10326200
----------------------
准备调用：public void com.javacode2018.aop.demo8.test1.Service1.m2()
我是 m2 方法
public void com.javacode2018.aop.demo8.test1.Service1.m2(),耗时(纳秒)：52000


```

### 非批量的方式

#### 用法

非批量的方式，需要注册多个增强器，需明确的指定多个增强器的 bean 名称，多个增强器按照参数中指定的顺序执行，如

```
proxyFactoryBean.setInterceptorNames("advice1","advice2");


```

`advice1、advice2`对应的 bean 类型必须为下面列表中指定的类型，类型这块比匹配的方式范围广一些

```
MethodBeforeAdvice（方法前置通知）
AfterReturningAdvice（方法后置通知）
ThrowsAdvice（异常通知）
org.aopalliance.intercept.MethodInterceptor（环绕通知）
org.springframework.aop.Advisor（顾问）


```

下面来个案例。

#### 案例

这次给`service1`来 3 个通知：前置、环绕、后置

```
package com.javacode2018.aop.demo8.test3;

import com.javacode2018.aop.demo8.test1.Service1;
import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;
import org.springframework.aop.AfterReturningAdvice;
import org.springframework.aop.MethodBeforeAdvice;
import org.springframework.aop.framework.ProxyFactoryBean;
import org.springframework.context.annotation.Bean;
import org.springframework.lang.Nullable;

import java.lang.reflect.Method;

public class MainConfig3 {
    //注册目标对象
    @Bean
    public Service1 service1() {
        return new Service1();
    }

    //定义一个前置通知
    @Bean
    public MethodBeforeAdvice methodBeforeAdvice() {
        MethodBeforeAdvice methodBeforeAdvice = new MethodBeforeAdvice() {
            @Override
            public void before(Method method, Object[] args, @Nullable Object target) throws Throwable {
                System.out.println("准备调用：" + method);
            }
        };
        return methodBeforeAdvice;
    }

    //定义一个环绕通知
    @Bean
    public MethodInterceptor methodInterceptor() {
        MethodInterceptor methodInterceptor = new MethodInterceptor() {
            @Override
            public Object invoke(MethodInvocation invocation) throws Throwable {
                long starTime = System.nanoTime();
                Object result = invocation.proceed();
                long endTime = System.nanoTime();
                System.out.println(invocation.getMethod() + ",耗时(纳秒)：" + (endTime - starTime));
                return result;
            }
        };
        return methodInterceptor;
    }

    //定义一个后置通知
    @Bean
    public AfterReturningAdvice afterReturningAdvice() {
        AfterReturningAdvice afterReturningAdvice = new AfterReturningAdvice() {
            @Override
            public void afterReturning(@Nullable Object returnValue, Method method, Object[] args, @Nullable Object target) throws Throwable {
                System.out.println(method + "，执行完毕!");
            }
        };
        return afterReturningAdvice;
    }

    //注册ProxyFactoryBean
    @Bean
    public ProxyFactoryBean service1Proxy() {
        //1.创建ProxyFactoryBean
        ProxyFactoryBean proxyFactoryBean = new ProxyFactoryBean();
        //2.设置目标对象的bean名称
        proxyFactoryBean.setTargetName("service1");
        //3.设置拦截器的bean名称列表，此处批量注册
        proxyFactoryBean.setInterceptorNames("methodBeforeAdvice", "methodInterceptor", "afterReturningAdvice");
        return proxyFactoryBean;
    }
}


```

测试代码

```
@Test
public void test3() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(MainConfig3.class);
    //获取代理对象，代理对象bean的名称为注册ProxyFactoryBean的名称，即：service1Proxy
    Service1 bean = context.getBean("service1Proxy", Service1.class);
    System.out.println("----------------------");
    //调用代理的方法
    bean.m1();
    System.out.println("----------------------");
    //调用代理的方法
    bean.m2();
}


```

运行输出

```
----------------------
准备调用：public void com.javacode2018.aop.demo8.test1.Service1.m1()
我是 m1 方法
public void com.javacode2018.aop.demo8.test1.Service1.m1()，执行完毕!
public void com.javacode2018.aop.demo8.test1.Service1.m1(),耗时(纳秒)：12724100
----------------------
准备调用：public void com.javacode2018.aop.demo8.test1.Service1.m2()
我是 m2 方法
public void com.javacode2018.aop.demo8.test1.Service1.m2()，执行完毕!
public void com.javacode2018.aop.demo8.test1.Service1.m2(),耗时(纳秒)：76700


```

源码解析
----

重点在于下面这个方法

```
org.springframework.aop.framework.ProxyFactoryBean#getObject


```

源码：

```
public Object getObject() throws BeansException {
    //初始化advisor(拦截器)链
    initializeAdvisorChain();
    //是否是单例
    if (isSingleton()) {
        //创建单例代理对象
        return getSingletonInstance();
    }
    else {
        //创建多例代理对象
        return newPrototypeInstance();
    }
}


```

`initializeAdvisorChain`方法，用来初始化 advisor(拦截器) 链，是根据`interceptorNames`配置，找到 spring 容器中符合条件的拦截器，将其放入创建 aop 代理的配置中

```
private synchronized void initializeAdvisorChain() throws AopConfigException, BeansException {
    if (!ObjectUtils.isEmpty(this.interceptorNames)) {
        // 轮询 interceptorNames
        for (String name : this.interceptorNames) {
            //批量注册的方式：判断name是否以*结尾
            if (name.endsWith(GLOBAL_SUFFIX)) {
                //@1：从容器中匹配查找匹配的增强器，将其添加到aop配置中
                addGlobalAdvisor((ListableBeanFactory) this.beanFactory,
                                 name.substring(0, name.length() - GLOBAL_SUFFIX.length()));
            }
            else {
                //非匹配的方式：按照name查找bean，将其包装为Advisor丢到aop配置中
                Object advice;
                //从容器中查找bean
                advice = this.beanFactory.getBean(name);
                //@2：将advice添加到拦截器列表中
                addAdvisorOnChainCreation(advice, name);
            }
        }
    }
}


```

`@1：addGlobalAdvisor`批量的方式 Advisor，看一下源码，比较简单

```
/**
 * 添加所有全局拦截器和切入点，
 * 容器中所有类型为Advisor/Interceptor的bean，bean名称prefix开头的都会将其添加到拦截器链中
 */
private void addGlobalAdvisor(ListableBeanFactory beanFactory, String prefix) {
    //获取容器中所有类型为Advisor的bean
    String[] globalAdvisorNames =
        BeanFactoryUtils.beanNamesForTypeIncludingAncestors(beanFactory, Advisor.class);
    //获取容器中所有类型为Interceptor的bean
    String[] globalInterceptorNames =
        BeanFactoryUtils.beanNamesForTypeIncludingAncestors(beanFactory, Interceptor.class);
    List<Object> beans = new ArrayList<>(globalAdvisorNames.length + globalInterceptorNames.length);
    Map<Object, String> names = new HashMap<>(beans.size());
    for (String name : globalAdvisorNames) {
        Object bean = beanFactory.getBean(name);
        beans.add(bean);
        names.put(bean, name);
    }
    for (String name : globalInterceptorNames) {
        Object bean = beanFactory.getBean(name);
        beans.add(bean);
        names.put(bean, name);
    }
    //对beans进行排序，可以实现Ordered接口，排序规则：order asc
    AnnotationAwareOrderComparator.sort(beans);
    for (Object bean : beans) {
        String name = names.get(bean);
        //判断bean是否已prefix开头
        if (name.startsWith(prefix)) {
            //将其添加到拦截器链中
            addAdvisorOnChainCreation(bean, name);
        }
    }
}


```

`@2：addAdvisorOnChainCreation`

```
private void addAdvisorOnChainCreation(Object next, String name) {
    //namedBeanToAdvisor用来将bean转换为advisor
    Advisor advisor = namedBeanToAdvisor(next);
    //将advisor添加到拦截器链中
    addAdvisor(advisor);
}


```

`namedBeanToAdvisor`方法

```
private AdvisorAdapterRegistry advisorAdapterRegistry = new DefaultAdvisorAdapterRegistry();

private Advisor namedBeanToAdvisor(Object next) {
    //将对象包装为Advisor对象
    return this.advisorAdapterRegistry.wrap(next);
}


```

对`AdvisorAdapterRegistry`不清楚的，看一下上一篇文章：[Spring 系列第 32 篇：AOP 核心源码、原理详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934930&idx=1&sn=4030960657cc72006122ef8b6f0de889&scene=21#wechat_redirect)

`advisorAdapterRegistry#wrap`方法将`adviceObject`包装为`Advisor`对象，代码如下，比较简单

```
public Advisor wrap(Object adviceObject) throws UnknownAdviceTypeException {
    if (adviceObject instanceof Advisor) {
        return (Advisor) adviceObject;
    }
    if (!(adviceObject instanceof Advice)) {
        throw new UnknownAdviceTypeException(adviceObject);
    }
    Advice advice = (Advice) adviceObject;
    if (advice instanceof MethodInterceptor) {
        return new DefaultPointcutAdvisor(advice);
    }
    for (AdvisorAdapter adapter : this.adapters) {
        if (adapter.supportsAdvice(advice)) {
            return new DefaultPointcutAdvisor(advice);
        }
    }
    throw new UnknownAdviceTypeException(advice);
}


```

总结
--

1.  Spring 中创建代理主要分为 2 种：手动方式和自动化的方式
    
2.  手动方式采用硬编码的方式，一次只能给一个目标对象创建代理对象，相对来说灵活一下，对开发者来说更灵活一些，通常可以独立 spring 环境使用；自动化的方式主要在 spring 环境中使用，通常是匹配的方式来为符合条件的目标 bean 创建代理，使用起来更简单一些
    
3.  本文介绍的`ProxyFactoryBean`用来在 spring 环境中给指定的 bean 创建代理对象，用到的不是太多，大家可以作为了解即可
    

