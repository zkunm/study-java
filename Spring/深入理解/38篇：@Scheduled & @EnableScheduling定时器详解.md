> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935890&idx=2&sn=f8a8e01e7399161621152b2e4caa8128&scene=21#wechat_redirect)

spring 中 `@Scheduled & @EnableScheduling` 这 2 个注解，可以用来快速开发定时器，使用特别的简单。

如何使用？
-----

### 用法

1、需要定时执行的方法上加上 @Scheduled 注解，这个注解中可以指定定时执行的规则，稍后详细介绍。

2、Spring 容器中使用 @EnableScheduling 开启定时任务的执行，此时 spring 容器才可以识别 @Scheduled 标注的方法，然后自动定时执行。

### 案例

db 中有很多需要推送的任务，然后将其检索出来，推送到手机端，来个定时器，每秒一次从库中检测需要推送的消息，然后推送到手机端。

```
package com.javacode2018.scheduled.demo1;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class PushJob {

    //推送方法，每秒执行一次
    @Scheduled(fixedRate = 1000)
    public void push() throws InterruptedException {
        System.out.println("模拟推送消息，" + System.currentTimeMillis());
    }

}


```

来个 spring 配置类，需要使用`@EnableScheduling`标注

```
package com.javacode2018.scheduled.demo1;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;

@ComponentScan
@EnableScheduling //在spring容器中启用定时任务的执行
public class MainConfig1 {

    @Bean
    public ScheduledExecutorService scheduledExecutorService() {
        return Executors.newScheduledThreadPool(20);
    }
}


```

测试类

```
package com.javacode2018.scheduled;

import com.javacode2018.scheduled.demo1.MainConfig1;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import java.util.concurrent.TimeUnit;

public class ScheduledTest {
    @Test
    public void test1() throws InterruptedException {
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
        context.register(MainConfig1.class);
        context.refresh();
        //休眠一段时间，房子junit自动退出
        TimeUnit.SECONDS.sleep(10000);
    }

}


```

运行输出，每秒会输出一次，如下：

```
模拟推送消息，1595840822998
模拟推送消息，1595840823998
模拟推送消息，1595840824998
模拟推送消息，1595840825998
模拟推送消息，1595840826998
模拟推送消息，1595840827998
模拟推送消息，1595840828998


```

@Scheduled 配置定时规则
-----------------

@Scheduled 可以用来配置定时器的执行规则，非常强大，@Scheduled 中主要有 8 个参数，我们一一来了解一下。

```
@Target({ElementType.METHOD, ElementType.ANNOTATION_TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Repeatable(Schedules.class)
public @interface Scheduled {

 String cron() default "";

 String zone() default "";

 long fixedDelay() default -1;

 String fixedDelayString() default "";

 long fixedRate() default -1;

 String fixedRateString() default "";

 long initialDelay() default -1;

 String initialDelayString() default "";

}


```

### 1. cron

该参数接收一个`cron表达式`，`cron表达式`是一个字符串，字符串以 5 或 6 个空格隔开，分开共 6 或 7 个域，每一个域代表一个含义。

#### cron 表达式语法

```
[秒] [分] [小时] [日] [月] [周] [年]


```

> “
> 
> 注：[年] 不是必须的域，可以省略 [年]，则一共 6 个域

<table data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)"><thead data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)"><tr data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183041999="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">序号</th><th data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183041999="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">说明</th><th data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183041999="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">必填</th><th data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183041999="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">允许填写的值</th><th data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183041999="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">允许的通配符</th></tr></thead><tbody data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)"><tr data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">1</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">秒</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">0-59</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">, - * /</td></tr><tr data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">2</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">分</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">0-59</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">, - * /</td></tr><tr data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">3</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">时</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">0-23</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">, - * /</td></tr><tr data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">4</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">日</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">1-31</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">, - * ? / L W</td></tr><tr data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">5</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">月</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">1-12 / JAN-DEC</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">, - * /</td></tr><tr data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">6</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">周</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">是</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">1-7 or SUN-SAT</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183041999="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">, - * ? / L #</td></tr><tr data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">7</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">年</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">否</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">1970-2099</td><td data-darkmode-color-16079183041999="rgb(163, 163, 163)" data-darkmode-original-color-16079183041999="rgb(0,0,0)" data-darkmode-bgcolor-16079183041999="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183041999="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">, - * /</td></tr></tbody></table>

##### 通配符说明:

*   `*` 表示所有值。例如: 在分的字段上设置 *, 表示每一分钟都会触发。
    
*   `?` 表示不指定值。使用的场景为不需要关心当前设置这个字段的值。例如: 要在每月的 10 号触发一个操作，但不关心是周几，所以需要周位置的那个字段设置为”?” 具体设置为 0 0 0 10 * ?
    
*   `-` 表示区间。例如 在小时上设置 “10-12”, 表示 10,11,12 点都会触发。
    
*   `,` 表示指定多个值，例如在周字段上设置 “MON,WED,FRI” 表示周一，周三和周五触发
    
*   `/` 用于递增触发。如在秒上面设置”5/15” 表示从 5 秒开始，每增 15 秒触发 (5,20,35,50)。在日字段上设置’1/3’所示每月 1 号开始，每隔三天触发一次。
    
*   `L` 表示最后的意思。在日字段设置上，表示当月的最后一天 (依据当前月份，如果是二月还会依据是否是润年[leap]), 在周字段上表示星期六，相当于”7” 或”SAT”。如果在”L”前加上数字，则表示该数据的最后一个。例如在周字段上设置”6L”这样的格式, 则表示“本月最后一个星期五”
    
*   `W` 表示离指定日期的最近那个工作日 (周一至周五). 例如在日字段上置”15W”，表示离每月 15 号最近的那个工作日触发。如果 15 号正好是周六，则找最近的周五(14 号) 触发, 如果 15 号是周未，则找最近的下周一 (16 号) 触发. 如果 15 号正好在工作日 (周一至周五)，则就在该天触发。如果指定格式为 “1W”, 它则表示每月 1 号往后最近的工作日触发。如果 1 号正是周六，则将在 3 号下周一触发。(注，”W” 前只能设置具体的数字, 不允许区间”-“)。
    
*   `#` 序号 (表示每月的第几个周几)，例如在周字段上设置”6#3” 表示在每月的第三个周六. 注意如果指定”#5”, 正好第五周没有周六，则不会触发该配置(用在母亲节和父亲节再合适不过了) ；小提示：’L’和 ‘W’可以一组合使用。如果在日字段上设置”LW”, 则表示在本月的最后一个工作日触发；周字段的设置，若使用英文字母是不区分大小写的，即 MON 与 mon 相同。
    

##### 示例

每隔 5 秒执行一次：*/5 * * * * ?

每隔 1 分钟执行一次：0 */1 * * * ?

每天 23 点执行一次：0 0 23 * * ?

每天凌晨 1 点执行一次：0 0 1 * * ?

每月 1 号凌晨 1 点执行一次：0 0 1 1 * ?

每月最后一天 23 点执行一次：0 0 23 L * ?

每周星期六凌晨 1 点实行一次：0 0 1 ? * L

在 26 分、29 分、33 分执行一次：0 26,29,33 * * * ?

每天的 0 点、13 点、18 点、21 点都执行一次：0 0 0,13,18,21 * * ?

##### cron 表达式使用占位符

另外，`cron`属性接收的`cron表达式`支持占位符。

如：配置文件：

```
time:
  cron: */5 * * * * *
  interval: 5


```

每 5 秒执行一次：

```
@Scheduled(cron="${time.cron}")
void testPlaceholder1() {
    System.out.println("Execute at " + System.currentTimeMillis());
}

@Scheduled(cron="*/${time.interval} * * * * *")
void testPlaceholder2() {
    System.out.println("Execute at " + System.currentTimeMillis());
}


```

### 2. zone

时区，接收一个`java.util.TimeZone#ID`。`cron表达式`会基于该时区解析。默认是一个空字符串，即取服务器所在地的时区。比如我们一般使用的时区`Asia/Shanghai`。该字段我们一般留空。

### 3. fixedDelay

上一次执行完毕时间点之后多长时间再执行。

如：

```
@Scheduled(fixedDelay = 5000) //上一次执行完毕时间点之后5秒再执行


```

### 4. fixedDelayString

与 `3. fixedDelay` 意思相同，只是使用字符串的形式。唯一不同的是支持占位符。

如：

```
@Scheduled(fixedDelayString = "5000") //上一次执行完毕时间点之后5秒再执行


```

占位符的使用（配置文件中有配置：time.fixedDelay=5000）

```
@Scheduled(fixedDelayString = "${time.fixedDelay}")
void testFixedDelayString() {
    System.out.println("Execute at " + System.currentTimeMillis());
}


```

### 5. fixedRate

上一次开始执行时间点之后多长时间再执行。

如：

```
@Scheduled(fixedRate = 5000) //上一次开始执行时间点之后5秒再执行


```

### 6. fixedRateString

与 `fixedRate` 意思相同，只是使用字符串的形式，唯一不同的是支持占位符。

### 7. initialDelay

第一次延迟多长时间后再执行。

如：

```
@Scheduled(initialDelay=1000, fixedRate=5000) //第一次延迟1秒后执行，之后按fixedRate的规则每5秒执行一次


```

### 8. initialDelayString

与 `initialDelay` 意思相同，只是使用字符串的形式，唯一不同的是支持占位符。

@Schedules 注解
-------------

这个注解不用多解释，看一下源码就知道作用了，当一个方法上面需要同时指定多个定时规则的时候，可以通过这个来配置

```
@Target({ElementType.METHOD, ElementType.ANNOTATION_TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Schedules {
 Scheduled[] value();
}


```

如：

```
//2个定时器，500毫秒的，1000毫秒的
@Schedules({@Scheduled(fixedRate = 500), @Scheduled(fixedRate = 1000)})
public void push3() {
}


```

为定时器定义线程池
---------

定时器默认情况下使用下面的线程池来执行定时任务的

```
new ScheduledThreadPoolExecutor(1)


```

只有一个线程，相当于只有一个干活的人，如果需要定时执行的任务太多，这些任务只能排队执行，会出现什么问题？

如果有些任务耗时比较长，导致其他任务排队时间比较长，不能有效的正常执行，直接影响到业务。

看下面代码，2 个方法，都使用了`@Scheduled(fixedRate = 1000)`，表示每秒执行一次，而`push1`方法中模拟耗时 2 秒，方法会中打印出线程名称、时间等信息，一会注意观察输出

```
package com.javacode2018.scheduled.demo2;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Component
public class PushJob {

    //推送方法，每秒执行一次
    @Scheduled(fixedRate = 1000)
    public void push1() throws InterruptedException {
        //休眠2秒，模拟耗时操作
        TimeUnit.SECONDS.sleep(2);
        System.out.println(Thread.currentThread().getName() + " push1 模拟推送消息，" + System.currentTimeMillis());
    }

    //推送方法，每秒执行一次
    @Scheduled(fixedRate = 1000)
    public void push2() {
        System.out.println(Thread.currentThread().getName() + " push2 模拟推送消息，" + System.currentTimeMillis());
    }

}


```

运行输出

```
pool-1-thread-1 push1 模拟推送消息，1595902615507
pool-1-thread-1 push2 模拟推送消息，1595902615507
pool-1-thread-1 push1 模拟推送消息，1595902617507
pool-1-thread-1 push2 模拟推送消息，1595902617507
pool-1-thread-1 push1 模拟推送消息，1595902619508
pool-1-thread-1 push2 模拟推送消息，1595902619508


```

注意上面的输出，线程名称都是`pool-1-thread-1`，并且有个问题，push2 中 2 次输出时间间隔是 2 秒，这就是由于线程池中只有一个线程导致了排队执行而产生的问题。

可以通过自定义定时器中的线程池来解决这个问题，定义一个`ScheduledExecutorService`类型的 bean，名称为`taskScheduler`

```
@Bean
public ScheduledExecutorService taskScheduler() {
    //设置需要并行执行的任务数量
    int corePoolSize = 20;
    return new ScheduledThreadPoolExecutor(corePoolSize);
}


```

此时问题就解决了，再次运行一下上面案例代码，结果如下，此时线程名称不一样了，且 push2 运行正常了

```
pool-1-thread-2 push2 模拟推送消息，1595903154636
pool-1-thread-2 push2 模拟推送消息，1595903155636
pool-1-thread-1 push1 模拟推送消息，1595903156636
pool-1-thread-3 push2 模拟推送消息，1595903156636
pool-1-thread-1 push2 模拟推送消息，1595903157636


```

源码 & 原理
-------

从`EnableScheduling`注解开始看，这个注解会导入`SchedulingConfiguration`类

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06BdfGr4tsZopvhqXlcqEzQH6ibuEcGZIPn5Z2ibIuvy7onaia84VVYGu0oPp4zos069SxtoUOc3mM8hA/640?wx_fmt=png)

`SchedulingConfiguration`是一个配置类，内部定义了`ScheduledAnnotationBeanPostProcessor`类型的 bean

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06BdfGr4tsZopvhqXlcqEzQHP8EA3Z7b498MB6DQx83NswKPzF39UdQaly3g4rFbRqPyrogY9nSj7A/640?wx_fmt=png)

`ScheduledAnnotationBeanPostProcessor`是一个 bean 后置处理器，内部有个`postProcessAfterInitialization`方法，spring 中任何 bean 在初始化完毕之后，会自动调用`postProcessAfterInitialization`方法，而`ScheduledAnnotationBeanPostProcessor`在这个方法中会解析 bean 中标注有`@Scheduled`注解的方法，这些方法也就是需要定时执行的方法。

`ScheduledAnnotationBeanPostProcessor`还实现了一个接口：`SmartInitializingSingleton`，`SmartInitializingSingleton`中有个方法`afterSingletonsInstantiated`会在 spring 容器中所有单例 bean 初始化完毕之后调用，定期器的装配及启动都是在这个方法中进行的。

```
org.springframework.scheduling.annotation.ScheduledAnnotationBeanPostProcessor#afterSingletonsInstantiated


```

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
    
34.  [Spring 系列第 34 篇：@Aspect 中 @Pointcut 12 种用法](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935037&idx=2&sn=cf813ac4cdfa3a0a0d6b5ed770255779&chksm=88621243bf159b554be2fe75eda7f5631ca29eed54edbfb97b08244625e03957429f2414d1e3&token=883563940&lang=zh_CN&scene=21#wechat_redirect)
    
35.  [Spring 系列第 35 篇：@Aspect 中 5 中通知详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935466&idx=2&sn=f536d7a2834e6e590bc7af0527e4de1f&scene=21#wechat_redirect)
    
36.  [Spring 系列第 36 篇：@EnableAspectJAutoProxy、@Aspect 中通知顺序详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935500&idx=2&sn=5fb794139e476a275963432948e29362&scene=21#wechat_redirect)
    
37.  [Spring 系列第 37 篇：@EnableAsync & @Async 实现方法异步调用](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935642&idx=2&sn=6b9ac2b42f5c5da424a424ec909392fe&scene=21#wechat_redirect)
    

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