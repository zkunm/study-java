> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937715&idx=2&sn=2d8534f9788bfa4678554d858ec93ab3&scene=21#wechat_redirect)

大家好，今天咱们通过源码来了解一下 spring 中 @Transaction 事务的原理。

开始本文之前，下面这些知识需提前了解下

1、[吃透 Spring AOP](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935500&idx=2&sn=5fb794139e476a275963432948e29362&scene=21#wechat_redirect)

2、[**Spring 编程式事务源码解析**](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937564&idx=2&sn=549f841b7935c6f5f98957e4d443f893&scene=21#wechat_redirect)

**在这里插播两句，整个系列前后知识是有依赖的，大家最好按顺序阅读，这样不会出现无法理解的情况，若跳着读，可能会比较懵。。。**

### 1、环境

1.  jdk1.8
    
2.  Spring 版本：5.2.3.RELEASE
    
3.  mysql5.7
    

### 2、@Transaction 事务的用法

咱们先来回顾一下，@Transaction 事务的用法，特别简单，2 个步骤

1、在需要让 spring 管理事务的方法上添加 @Transaction 注解

2、在 spring 配置类上添加 @EnableTransactionManagement 注解，这步特别重要，别给忘了，有了这个注解之后，@Trasaction 标注的方法才会生效。

### 3、@Transaction 事务原理

原理比较简单，内部是通过 spring aop 的功能，通过拦截器拦截 @Transaction 方法的执行，在方法前后添加事务的功能。

### 4、@EnableTransactionManagement 注解作用

@EnableTransactionManagement 注解会开启 spring 自动管理事务的功能，有了这个注解之后，spring 容器启动的过程中，会拦截所有 bean 的创建过程，判断 bean 是否需要让 spring 来管理事务，即判断 bean 中是否有 @Transaction 注解，判断规则如下

1、一直沿着当前 bean 的类向上找，先从当前类中，然后父类、父类的父类，当前类的接口、接口父接口，父接口的父接口，一直向上找，一下这些类型上面是否有 @Transaction 注解

2、类的任意 public 方法上面是否有 @Transaction 注解

如果 bean 满足上面任意一个规则，就会被 spring 容器通过 aop 的方式创建代理，代理中会添加一个拦截器

```
org.springframework.transaction.interceptor.TransactionInterceptor


```

TransactionInterceptor 拦截器是关键，它会拦截 @Trasaction 方法的执行，在方法执行前后添加事务的功能，这个拦截器中大部分都是编程式事务的代码，若 [编程式事务的源码](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937266&idx=2&sn=dec5380383ed768b734ffe02e0322724&scene=21#wechat_redirect) 大家看懂了，这个拦截器源码看起来就是小儿科了。

### 5、@EnableTransactionManagement 源码解析

```
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import(TransactionManagementConfigurationSelector.class) //@1
public @interface EnableTransactionManagement {

 // 是基于类的代理（cglib），还是基于接口的代理（jdk动态代理），默认为false，表示是基于jdk动态代理
 boolean proxyTargetClass() default false;
    
    //通知的模式，默认是通过aop的方式
    AdviceMode mode() default AdviceMode.PROXY;

 // 我们知道这个注解的功能最终是通过aop的方式来实现的，对bean创建了一个代理，代理中添加了一个拦截器
    // 当代理中还有其他拦截器的是时候，可以通过order这个属性来指定事务拦截器的顺序
    // 默认值是 LOWEST_PRECEDENCE = Integer.MAX_VALUE,拦截器的执行顺序是order升序
 int order() default Ordered.LOWEST_PRECEDENCE;

}


```

注意`@1`这个代码

```
@Import(TransactionManagementConfigurationSelector.class)


```

用到了 @Import 注解，对这个注解不熟悉的可以看一下 [Spring 系列第 18 篇：@import 详解 (bean 批量注册)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648934173&idx=1&sn=60bb7d58fd408db985a785bfed6e1eb2&chksm=88621f23bf15963589f06b7ce4e521a7c8d615b1675788f383cbb0bcbb05b117365327e1941a&token=704646761&lang=zh_CN&scene=21#wechat_redirect)，这个注解的 value 是 TransactionManagementConfigurationSelector，看一下这个类的源码，重点是他的`selectImports`方法，这个方法会返回一个类名数组，spring 容器启动过程中会自动调用这个方法，将这个方法指定的类注册到 spring 容器中；方法的参数是 AdviceMode，这个就是 @EnableTransactionManagement 注解中 mode 属性的值，默认是 PROXY，所以会走到 @1 代码处

```
public class TransactionManagementConfigurationSelector extends AdviceModeImportSelector<EnableTransactionManagement> {

 @Override
 protected String[] selectImports(AdviceMode adviceMode) {
  switch (adviceMode) {
   case PROXY: //@1
    return new String[] {AutoProxyRegistrar.class.getName(),
      ProxyTransactionManagementConfiguration.class.getName()};
   case ASPECTJ:
    return new String[] {determineTransactionAspectClass()};
   default:
    return null;
  }
 }

}


```

最终会在 spirng 容器中注册下面这 2 个 bean

```
AutoProxyRegistrar
ProxyTransactionManagementConfiguration


```

下面来看一下这 2 个类的代码。

##### AutoProxyRegistrar

这个类实现了 ImportBeanDefinitionRegistrar 接口，这个接口中有个方法`registerBeanDefinitions`，spring 容器在启动过程中会调用这个方法，开发者可以在这个方法中做一些 bean 注册的事情，而 AutoProxyRegistrar 在这个方法中主要做的事情就是下面`@1`的代码，大家可以点进去看看，这里我就不点进去了，这个代码的作用就是在容器中做了一个非常关键的 bean：InfrastructureAdvisorAutoProxyCreator，这个类之前在 aop 中介绍过，是 bean 后置处理器，会拦截所有 bean 的创建，对符合条件的 bean 创建代理。

```
public class AutoProxyRegistrar implements ImportBeanDefinitionRegistrar {

 @Override
 public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
  boolean candidateFound = false;
  Set<String> annTypes = importingClassMetadata.getAnnotationTypes();
  for (String annType : annTypes) {
   AnnotationAttributes candidate = AnnotationConfigUtils.attributesFor(importingClassMetadata, annType);
   if (candidate == null) {
    continue;
   }
   Object mode = candidate.get("mode");
   Object proxyTargetClass = candidate.get("proxyTargetClass");
   if (mode != null && proxyTargetClass != null && AdviceMode.class == mode.getClass() &&
     Boolean.class == proxyTargetClass.getClass()) {
    candidateFound = true;
    if (mode == AdviceMode.PROXY) {
     AopConfigUtils.registerAutoProxyCreatorIfNecessary(registry);//@1
     if ((Boolean) proxyTargetClass) {
      AopConfigUtils.forceAutoProxyCreatorToUseClassProxying(registry);
      return;
     }
    }
   }
  }
 }
}


```

**说的简单点：AutoProxyRegistrar 的作用就是启用 spring aop 的功能，对符合条件的 bean 创建代理。**

##### ProxyTransactionManagementConfiguration

```
@Configuration(proxyBeanMethods = false)
public class ProxyTransactionManagementConfiguration extends AbstractTransactionManagementConfiguration {
 //注册bean：事务顾问（spring aop中拦截器链就是一个个的Advisor对象）
 @Bean(name = TransactionManagementConfigUtils.TRANSACTION_ADVISOR_BEAN_NAME)
 @Role(BeanDefinition.ROLE_INFRASTRUCTURE)
 public BeanFactoryTransactionAttributeSourceAdvisor transactionAdvisor(
   TransactionAttributeSource transactionAttributeSource,
   TransactionInterceptor transactionInterceptor) {
  BeanFactoryTransactionAttributeSourceAdvisor advisor = new BeanFactoryTransactionAttributeSourceAdvisor();
  advisor.setTransactionAttributeSource(transactionAttributeSource);
        //设置事务拦截器
  advisor.setAdvice(transactionInterceptor);
  if (this.enableTx != null) {
            //设置aop中事务拦截器的顺序
   advisor.setOrder(this.enableTx.<Integer>getNumber("order"));
  }
  return advisor;
 }

    //注册bean:TransactionAttributeSource，TransactionAttributeSource用来获取获取事务属性配置信息：TransactionAttribute
 @Bean
 @Role(BeanDefinition.ROLE_INFRASTRUCTURE)
 public TransactionAttributeSource transactionAttributeSource() { //@1
  return new AnnotationTransactionAttributeSource();
 }

    //注册bean：事务拦截器
 @Bean
 @Role(BeanDefinition.ROLE_INFRASTRUCTURE)
 public TransactionInterceptor transactionInterceptor(
   TransactionAttributeSource transactionAttributeSource) {
  TransactionInterceptor interceptor = new TransactionInterceptor();
  interceptor.setTransactionAttributeSource(transactionAttributeSource);
        //拦截器中设置事务管理器，txManager可以为空
  if (this.txManager != null) {
   interceptor.setTransactionManager(this.txManager);
  }
  return interceptor;
 }

}


```

是个配置类，代码比较简单，注册了 3 个 bean，最重要的一点就是添加了事务事务拦截器：TransactionInterceptor。

AutoProxyRegistrar 负责启用 aop 的功能，而 ProxyTransactionManagementConfiguration 负责在 aop 中添加事务拦截器，二者结合起来的效果就是：对 @Transaction 标注的 bean 创建代理对象，代理对象中通过 TransactionInterceptor 拦截器来实现事务管理的功能。

再看下代码`@1`，注册了一个 TransactionAttributeSource 类型的 bean

TransactionAttributeSource 接口源码：

```
public interface TransactionAttributeSource {

 /**
  * 确定给定的类是否是这个TransactionAttributeSource元数据格式中的事务属性的候选类。
  * 如果此方法返回false，则不会遍历给定类上的方法，以进行getTransactionAttribute内省。
  * 因此，返回false是对不受影响的类的优化，而返回true仅仅意味着类需要对给定类上的每个方法进行完全自省。
  **/
 default boolean isCandidateClass(Class<?> targetClass) {
  return true;
 }

 //返回给定方法的事务属性，如果该方法是非事务性的，则返回null。
 TransactionAttribute getTransactionAttribute(Method method, @Nullable Class<?> targetClass);

}


```

getTransactionAttribute 方法用来获取指定方法上的事务属性信息 TransactionAttribute，大家对 TransactionDefinition 比较熟悉吧，用来配置事务属性信息的，而 TransactionAttribute 继承了 TransactionDefinition 接口，源码如下，而 TransactionAttribute 中新定义了 2 个方法，一个方法用来指定事务管理器 bean 名称的，一个用来判断给定的异常是否需要回滚事务

```
public interface TransactionAttribute extends TransactionDefinition {

 //事务管理器的bean名称
 @Nullable
 String getQualifier();

 //判断指定的异常是否需要回滚事务
 boolean rollbackOn(Throwable ex);

}


```

TransactionAttributeSource 接口有个实现类 AnnotationTransactionAttributeSource，负责将 @Transaction 解析为 TransactionAttribute 对象，大家可以去这个类中设置一下断点看一下 @Transaction 注解查找的顺序，这样可以深入理解 @Transaction 放在什么地方才会让事务起效。

AnnotationTransactionAttributeSource 内部最会委托给 SpringTransactionAnnotationParser#parseTransactionAnnotation 方法来解析 @Transaction 注解，进而得到事务属性配置信息：RuleBasedTransactionAttribute，代码如下：

```
org.springframework.transaction.annotation.SpringTransactionAnnotationParser

protected TransactionAttribute parseTransactionAnnotation(AnnotationAttributes attributes) {
    RuleBasedTransactionAttribute rbta = new RuleBasedTransactionAttribute();

    Propagation propagation = attributes.getEnum("propagation");
    rbta.setPropagationBehavior(propagation.value());
    Isolation isolation = attributes.getEnum("isolation");
    rbta.setIsolationLevel(isolation.value());
    rbta.setTimeout(attributes.getNumber("timeout").intValue());
    rbta.setReadOnly(attributes.getBoolean("readOnly"));
    rbta.setQualifier(attributes.getString("value"));
 
    //回滚规则
    List<RollbackRuleAttribute> rollbackRules = new ArrayList<>();
    for (Class<?> rbRule : attributes.getClassArray("rollbackFor")) {
        rollbackRules.add(new RollbackRuleAttribute(rbRule));
    }
    for (String rbRule : attributes.getStringArray("rollbackForClassName")) {
        rollbackRules.add(new RollbackRuleAttribute(rbRule));
    }
    for (Class<?> rbRule : attributes.getClassArray("noRollbackFor")) {
        rollbackRules.add(new NoRollbackRuleAttribute(rbRule));
    }
    for (String rbRule : attributes.getStringArray("noRollbackForClassName")) {
        rollbackRules.add(new NoRollbackRuleAttribute(rbRule));
    }
    rbta.setRollbackRules(rollbackRules);

    return rbta;
}


```

下面来看重点了事务拦截器。

### 6、TransactionInterceptor

负责拦截 @Transaction 方法的执行，在方法执行之前开启 spring 事务，方法执行完毕之后提交或者回滚事务。

在讲这个类的源码之前，先提几个问题，大家带着问题去看代码，理解更深一些。

1、事务管理器是如何获取的？

2、什么情况下事务会提交？

3、什么异常会导致事务回滚？

#### 6.1、invokeWithinTransaction 方法

这个方法是事务拦截器的入口，需要 spring 管理事务的业务方法会被这个方法拦截，大家可以设置断点跟踪一下

```
protected Object invokeWithinTransaction(Method method, @Nullable Class<?> targetClass,
   final InvocationCallback invocation) throws Throwable {

    TransactionAttributeSource tas = getTransactionAttributeSource();
 //@6-1：获取事务属性配置信息：通过TransactionAttributeSource.getTransactionAttribute解析@Trasaction注解得到事务属性配置信息
    final TransactionAttribute txAttr = (tas != null ? tas.getTransactionAttribute(method, targetClass) : null);
    //@6-2：获取事务管理器
    final TransactionManager tm = determineTransactionManager(txAttr);

    //将事务管理器tx转换为 PlatformTransactionManager
    PlatformTransactionManager ptm = asPlatformTransactionManager(tm);

    if (txAttr == null || !(ptm instanceof CallbackPreferringPlatformTransactionManager)) {
        // createTransactionIfNecessary内部，这里就不说了，内部主要就是使用spring事务硬编码的方式开启事务，最终会返回一个TransactionInfo对象
        TransactionInfo txInfo = createTransactionIfNecessary(ptm, txAttr, joinpointIdentification);
  // 业务方法返回值
        Object retVal;
        try {
            //调用aop中的下一个拦截器，最终会调用到业务目标方法，获取到目标方法的返回值
            retVal = invocation.proceedWithInvocation();
        }
        catch (Throwable ex) {
            //6-3：异常情况下，如何走？可能只需提交，也可能只需回滚，这个取决于事务的配置
            completeTransactionAfterThrowing(txInfo, ex);
            throw ex;
        }
        finally {
            //清理事务信息
            cleanupTransactionInfo(txInfo);
        }
  //6-4：业务方法返回之后，只需事务提交操作
        commitTransactionAfterReturning(txInfo);
        //返回执行结果
        return retVal;
    }
}


```

#### 6.2、获取事务管理器

```
//@6-2：获取事务管理器
final TransactionManager tm = determineTransactionManager(txAttr);


```

determineTransactionManager 源码如下：

```
org.springframework.transaction.interceptor.TransactionAspectSupport#determineTransactionManager

protected TransactionManager determineTransactionManager(@Nullable TransactionAttribute txAttr) {
    // txAttr == null || this.beanFactory == null ，返回拦截器中配置的事务管理器
    if (txAttr == null || this.beanFactory == null) {
        return getTransactionManager();
    }
 
    //qualifier就是@Transactional注解中通过value或者transactionManager来指定事务管理器的bean名称
    String qualifier = txAttr.getQualifier();
    if (StringUtils.hasText(qualifier)) {
        //从spring容器中查找[beanName:qualifier,type:TransactionManager]的bean
        return determineQualifiedTransactionManager(this.beanFactory, qualifier);
    }
    else if (StringUtils.hasText(this.transactionManagerBeanName)) {
        //从spring容器中查找[beanName:this.transactionManagerBeanName,type:TransactionManager]的bean
        return determineQualifiedTransactionManager(this.beanFactory, this.transactionManagerBeanName);
    }
    else {
        //最后通过类型TransactionManager在spring容器中找事务管理器
        TransactionManager defaultTransactionManager = getTransactionManager();
        if (defaultTransactionManager == null) {
            defaultTransactionManager = this.transactionManagerCache.get(DEFAULT_TRANSACTION_MANAGER_KEY);
            if (defaultTransactionManager == null) {
                defaultTransactionManager = this.beanFactory.getBean(TransactionManager.class);
                this.transactionManagerCache.putIfAbsent(
                    DEFAULT_TRANSACTION_MANAGER_KEY, defaultTransactionManager);
            }
        }
        return defaultTransactionManager;
    }
}


```

**从上面可知，事务管理器的查找顺序：**

1、先看 @Transactional 中是否通过 value 或者 transactionManager 指定了事务管理器

2、TransactionInterceptor.transactionManagerBeanName 是否有值，如果有，将通过这个值查找事务管理器

3、如果上面 2 种都没有，将从 spring 容器中查找 TransactionManager 类型的事务管理器

#### 6.3、异常情况下，如何走？

```
try{
    //....
}catch (Throwable ex) {
    //6-3：异常情况下，如何走？可能只需提交，也可能只需回滚，这个取决于事务的配置
    completeTransactionAfterThrowing(txInfo, ex);
    throw ex;
}


```

源码中可以看出，发生异常了会进入`completeTransactionAfterThrowing`方法，completeTransactionAfterThrowing 源码如下

```
protected void completeTransactionAfterThrowing(@Nullable TransactionInfo txInfo, Throwable ex) {
    if (txInfo != null && txInfo.getTransactionStatus() != null) {
        //@6-3-1：判断事务是否需要回滚
        if (txInfo.transactionAttribute != null && txInfo.transactionAttribute.rollbackOn(ex)) {
            //通过事务管理器回滚事务
            txInfo.getTransactionManager().rollback(txInfo.getTransactionStatus());
        }
        else {
            //通过事务管理器提交事务
            txInfo.getTransactionManager().commit(txInfo.getTransactionStatus());
        }
    }
}


```

注意上面的`@6-3-1`代码，判断事务是否需要回滚，调用的是`transactionAttribute.rollbackOn(ex)`，最终会进入下面这个方法内部

```
org.springframework.transaction.interceptor.RuleBasedTransactionAttribute#rollbackOn

public boolean rollbackOn(Throwable ex) {
    RollbackRuleAttribute winner = null;
    int deepest = Integer.MAX_VALUE;

    //@Trasaction中可以通过rollbackFor指定需要回滚的异常列表，通过noRollbackFor属性指定不需要回滚的异常
    //根据@Transactional中指定的回滚规则判断ex类型的异常是否需要回滚
    if (this.rollbackRules != null) {
        for (RollbackRuleAttribute rule : this.rollbackRules) {
            int depth = rule.getDepth(ex);
            if (depth >= 0 && depth < deepest) {
                deepest = depth;
                winner = rule;
            }
        }
    }
    //若@Transactional注解中没有匹配到，这走默认的规则，将通过super.rollbackOn来判断
    if (winner == null) {
        return super.rollbackOn(ex);
    }

    return !(winner instanceof NoRollbackRuleAttribute);
}


```

super.rollbackOn(ex) 源码如下，**可以看出默认情况下，异常类型是 RuntimeException 或者 Error 的情况下，事务才会回滚**。

```
@Override
public boolean rollbackOn(Throwable ex) {
    return (ex instanceof RuntimeException || ex instanceof Error);
}


```

#### 6.4、没有异常如何走？

```
//6-4：业务方法返回之后，只需事务提交操作
commitTransactionAfterReturning(txInfo);


```

没有异常的情况下会进入`commitTransactionAfterReturning`方法，`commitTransactionAfterReturning`源码如下，比较简单，就是调用事务管理器的 commit 方法提交事务

```
protected void commitTransactionAfterReturning(@Nullable TransactionInfo txInfo) {
    if (txInfo != null && txInfo.getTransactionStatus() != null) {
        txInfo.getTransactionManager().commit(txInfo.getTransactionStatus());
    }
}


```

源码解析的差不多了，建议大家设置断点跟踪一下，加深对事务原理的理解。

### 7、重点回顾

1、使用 @Transaction 的时候，一定别忘记 @EnableTransactionManagement 注解，否则事务不起效

2、@Transaction 的功能主要是通过 aop 来实现的，关键代码在 TransactionInterceptor 拦截器中

3、默认情况下，事务只会在 RuntimeException 或 Error 异常下回滚，可以通 @Transaction 来配置其他需要回滚或不需要回滚的异常类型

### 8、课堂讨论

下面代码的执行结果是什么？为什么？

```
@Component
public class ServiceA {

    @Autowired
    ServiceB serviceB;

    @Transactional
    public void m1() {
        try {
            serviceB.m2();
        } catch (Exception e) {
            e.printStackTrace();
        }
        "insert into t_user (name) values ('张三')";
    }
}

@Component
public class ServiceB {

    @Transactional
    public void m2() {
        "insert into t_user (name) values ('李四')";
        throw new RuntimeException("手动抛出异常!");
    }
}


```

欢迎留言和我分享你的想法。如果有收获，也欢迎你把这篇文章分享给你的朋友。

### Spring 系列

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
    
42.  [Spring 系列第 42 篇：玩转 JdbcTemplate](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936449&idx=2&sn=da1e98e5914821f040d5530e8ca9d9bc&scene=21#wechat_redirect)
    
43.  [Spring 系列第 43 篇：spring 中编程式事务怎么用的？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936779&idx=2&sn=a6255c7d436a62af380dfa6b326fd4e7&scene=21#wechat_redirect)
    
44.  [Spring 系列第 44 篇：详解 spring 声明式事务 (@Transactional)](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936892&idx=2&sn=473a156dc141a2efc0580f93567f0630&scene=21#wechat_redirect)
    
45.  [Spring 系列第 45 篇：带你吃透 Spring 事务 7 种传播行为](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937136&idx=2&sn=73d60cc0e6d9734d675aec369704992e&scene=21#wechat_redirect)
    
46.  [Spring 系列第 46 篇：Spring 如何管理多数据源事务？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937266&idx=2&sn=dec5380383ed768b734ffe02e0322724&scene=21#wechat_redirect)
    
47.  [Spring 系列第 47 篇：spring 事务源码解析](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937564&idx=2&sn=549f841b7935c6f5f98957e4d443f893&scene=21#wechat_redirect)
    

### 更多好文章

1.  [Java 高并发系列（共 34 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933285&idx=1&sn=f5507c251b84c3405f2fe0f7fb1da97d&chksm=88621b9bbf15928dd4c26f52b2abb0e130cde02100c432f33f0e90123b5e4b20d43017c1030e&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [MySql 高手系列（共 27 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933461&idx=1&sn=67cd31469273b68a258d963e53b56325&chksm=88621c6bbf15957d7308d81cd8ba1761b356222f4c6df75723aee99c265bd94cc869faba291c&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Maven 高手系列（共 10 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933753&idx=1&sn=0b41083939980be87a61c4f573792459&chksm=88621d47bf1594516092b662c545abfac299d296e232bf25e9f50be97e002e2698ea78218828&scene=21#wechat_redirect)
    
4.  [Mybatis 系列（共 12 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933868&idx=1&sn=ed16ef4afcbfcb3423a261422ff6934e&chksm=88621dd2bf1594c4baa21b7adc47456e5f535c3358cd11ddafb1c80742864bb19d7ccc62756c&token=1400407286&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [聊聊 db 和缓存一致性常见的实现方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933452&idx=1&sn=48b3b1cbd27c50186122fef8943eca5f&chksm=88621c72bf159564e629ee77d180424274ae9effd8a7c2997f853135b28f3401970793d8098d&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [接口幂等性这么重要，它是什么？怎么实现？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933334&idx=1&sn=3a68da36e4e21b7339418e40ab9b6064&chksm=88621be8bf1592fe5301aab732fbed8d1747475f4221da341350e0cc9935225d41bf79375d43&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [泛型，有点难度，会让很多人懵逼，那是因为你没有看这篇文章！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933878&idx=1&sn=bebd543c39d02455456680ff12e3934b&chksm=88621dc8bf1594de6b50a760e4141b80da76442ba38fb93a91a3d18ecf85e7eee368f2c159d3&token=799820369&lang=zh_CN&scene=21#wechat_redirect)
    

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06AibRrjQicuaJj6Mq4hmnCUlIibUvzyXLROGOKSGfz9FrjG1Cjy4bicNmFdO4yWE2ibiaQJ1F6eic95FWc9Q/640?wx_fmt=png)