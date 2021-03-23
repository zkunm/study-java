> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648936152&idx=2&sn=5d5dcaa28fe5aec867ce05bf5119829e&scene=21#wechat_redirect)

**本文带你玩转 spring 中强大的 spel 表达式！**

Spel 概述
-------

Spring 表达式语言全称为 “Spring Expression Language”，缩写为 “SpEL”，类似于 Struts2x 中使用的 OGNL 表达式语言，能在运行时构建复杂表达式、存取对象图属性、对象方法调用等等，并且能与 Spring 功能完美整合，如能用来配置 Bean 定义。

**表达式语言给静态 Java 语言增加了动态功能。**

SpEL 是单独模块，只依赖于 core 模块，不依赖于其他模块，可以单独使用。

Spel 能干什么?
----------

表达式语言一般是用最简单的形式完成最主要的工作，减少我们的工作量。

SpEL 支持如下表达式：

**一、基本表达式：** 字面量表达式、关系，逻辑与算数运算表达式、字符串连接及截取表达式、三目运算及 Elivis 表达式、正则表达式、括号优先级表达式；

**二、类相关表达式：** 类类型表达式、类实例化、instanceof 表达式、变量定义及引用、赋值表达式、自定义函数、对象属性存取及安全导航表达式、对象方法调用、Bean 引用；

**三、集合相关表达式：** 内联 List、内联数组、集合，字典访问、列表，字典，数组修改、集合投影、集合选择；不支持多维内联数组初始化；不支持内联字典定义；

**四、其他表达式**：模板表达式。

**注：SpEL 表达式中的关键字是不区分大小写的。**

SpEL 基础
-------

### HelloWorld

首先准备支持 SpEL 的 Jar 包：“org.springframework.expression-3.0.5.RELEASE.jar” 将其添加到类路径中。

SpEL 在求表达式值时一般分为四步，其中第三步可选：首先构造一个解析器，其次解析器解析字符串表达式，在此构造上下文，最后根据上下文得到表达式运算后的值。

让我们看下代码片段吧：

```
package com.javacode2018.spel;

import org.junit.Test;
import org.springframework.expression.EvaluationContext;
import org.springframework.expression.Expression;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.expression.spel.support.StandardEvaluationContext;

public class SpelTest {
    @Test
    public void test1() {
        ExpressionParser parser = new SpelExpressionParser();
        Expression expression = parser.parseExpression("('Hello' + ' World').concat(#end)");
        EvaluationContext context = new StandardEvaluationContext();
        context.setVariable("end", "!");
        System.out.println(expression.getValue(context));
    }
}


```

输出

```
Hello World!


```

接下来让我们分析下代码：

1）创建解析器：**SpEL 使用 ExpressionParser 接口表示解析器，提供 SpelExpressionParser 默认实现；**

2）解析表达式：使用 ExpressionParser 的 parseExpression 来解析相应的表达式为 Expression 对象。

3）构造上下文：准备比如变量定义等等表达式需要的上下文数据。

4）求值：通过 Expression 接口的 getValue 方法根据上下文获得表达式值。

是不是很简单，接下来让我们看下其具体实现及原理吧。

### SpEL 原理及接口

SpEL 提供简单的接口从而简化用户使用，在介绍原理前让我们学习下几个概念：

**一、表达式：** 表达式是表达式语言的核心，所以表达式语言都是围绕表达式进行的，从我们角度来看是 “干什么”；

**二、解析器：** 用于将字符串表达式解析为表达式对象，从我们角度来看是 “谁来干”；

**三、上下文：** 表达式对象执行的环境，该环境可能定义变量、定义自定义函数、提供类型转换等等，从我们角度看是 “在哪干”；

**四、根对象及活动上下文对象：** 根对象是默认的活动上下文对象，活动上下文对象表示了当前表达式操作的对象，从我们角度看是 “对谁干”。

理解了这些概念后，让我们看下 SpEL 如何工作的呢，如图所示：

![](https://mmbiz.qpic.cn/sz_mmbiz_jpg/xicEJhWlK06C9qszwnG12APgYIPNHbYAlsycdB0S6SMdUiczic6mc461LMPmuLKGIS9ucnvgLPwNkhticYb8JVyQQQ/640?wx_fmt=jpeg)

#### 工作原理

```
1.首先定义表达式：“1+2”；
2.定义解析器ExpressionParser实现，SpEL提供默认实现SpelExpressionParser；
  2.1.SpelExpressionParser解析器内部使用Tokenizer类进行词法分析，即把字符串流分析为记号流，记号在SpEL使用Token类来表示；
  2.2.有了记号流后，解析器便可根据记号流生成内部抽象语法树；在SpEL中语法树节点由SpelNode接口实现代表：如OpPlus表示加操作节点、IntLiteral表示int型字面量节点；使用SpelNodel实现组成了抽象语法树；
  2.3.对外提供Expression接口来简化表示抽象语法树，从而隐藏内部实现细节，并提供getValue简单方法用于获取表达式值；SpEL提供默认实现为SpelExpression；
3.定义表达式上下文对象（可选），SpEL使用EvaluationContext接口表示上下文对象，用于设置根对象、自定义变量、自定义函数、类型转换器等，SpEL提供默认实现StandardEvaluationContext；
4.使用表达式对象根据上下文对象（可选）求值（调用表达式对象的getValue方法）获得结果。


```

接下来让我们看下 SpEL 的主要接口吧：

#### ExpressionParser 接口

表示解析器，默认实现是 org.springframework.expression.spel.standard 包中的 SpelExpressionParser 类，使用 parseExpression 方法将字符串表达式转换为 Expression 对象，对于 ParserContext 接口用于定义字符串表达式是不是模板，及模板开始与结束字符：

```
public interface ExpressionParser {
 Expression parseExpression(String expressionString) throws ParseException;
 Expression parseExpression(String expressionString, ParserContext context) throws ParseException;
}


```

来看下示例：

```
@Test
public void testParserContext() {
    ExpressionParser parser = new SpelExpressionParser();
    ParserContext parserContext = new ParserContext() {
        @Override
        public boolean isTemplate() {
            return true;
        }

        @Override
        public String getExpressionPrefix() {
            return "#{";
        }

        @Override
        public String getExpressionSuffix() {
            return "}";
        }
    };
    String template = "#{'Hello '}#{'World!'}";
    Expression expression = parser.parseExpression(template, parserContext);
    System.out.println(expression.getValue());
}


```

在此我们演示的是使用 ParserContext 的情况，此处定义了 ParserContext 实现：定义表达式是模块，表达式前缀为 “#{”，后缀为“}”；使用 parseExpression 解析时传入的模板必须以“#{” 开头，以 “}” 结尾，如 "#{'Hello '}#{'World!'}"。

默认传入的字符串表达式不是模板形式，如之前演示的 Hello World。

#### EvaluationContext 接口

表示上下文环境，默认实现是 org.springframework.expression.spel.support 包中的 StandardEvaluationContext 类，使用 setRootObject 方法来设置根对象，使用 setVariable 方法来注册自定义变量，使用 registerFunction 来注册自定义函数等等。

#### Expression 接口

表示表达式对象，默认实现是 org.springframework.expression.spel.standard 包中的 SpelExpression，提供 getValue 方法用于获取表达式值，提供 setValue 方法用于设置对象值。

了解了 SpEL 原理及接口，接下来的事情就是 SpEL 语法了。

SpEL 语法
-------

### 基本表达式

#### 字面量表达式

SpEL 支持的字面量包括：字符串、数字类型（int、long、float、double）、布尔类型、null 类型。

<table data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)"><thead data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)"><tr data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183053334="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">类型</th><th data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183053334="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">示例</th></tr></thead><tbody data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)"><tr data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">字符串</td><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">String str1 = parser.parseExpression("'Hello World!'").getValue(String.class);</td></tr><tr data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">数字类型</td><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">int int1 = parser.parseExpression("1").getValue(Integer.class);<br data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)">long long1 = parser.parseExpression("-1L").getValue(long.class);<br data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)">float float1 = parser.parseExpression("1.1").getValue(Float.class);<br data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)">double double1 = parser.parseExpression("1.1E+2").getValue(double.class);<br data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)">int hex1 = parser.parseExpression("0xa").getValue(Integer.class);<br data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)">long hex2 = parser.parseExpression("0xaL").getValue(long.class);</td></tr><tr data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">布尔类型</td><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">boolean true1 = parser.parseExpression("true").getValue(boolean.class);<br data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)">boolean false1 = parser.parseExpression("false").getValue(boolean.class);</td></tr><tr data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">null 类型</td><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">Object null1 = parser.parseExpression("null").getValue(Object.class);</td></tr></tbody></table>

```
@Test
public void test2() {
    ExpressionParser parser = new SpelExpressionParser();

    String str1 = parser.parseExpression("'Hello World!'").getValue(String.class);
    int int1 = parser.parseExpression("1").getValue(Integer.class);
    long long1 = parser.parseExpression("-1L").getValue(long.class);
    float float1 = parser.parseExpression("1.1").getValue(Float.class);
    double double1 = parser.parseExpression("1.1E+2").getValue(double.class);
    int hex1 = parser.parseExpression("0xa").getValue(Integer.class);
    long hex2 = parser.parseExpression("0xaL").getValue(long.class);
    boolean true1 = parser.parseExpression("true").getValue(boolean.class);
    boolean false1 = parser.parseExpression("false").getValue(boolean.class);
    Object null1 = parser.parseExpression("null").getValue(Object.class);

    System.out.println("str1=" + str1);
    System.out.println("int1=" + int1);
    System.out.println("long1=" + long1);
    System.out.println("float1=" + float1);
    System.out.println("double1=" + double1);
    System.out.println("hex1=" + hex1);
    System.out.println("hex2=" + hex2);
    System.out.println("true1=" + true1);
    System.out.println("false1=" + false1);
    System.out.println("null1=" + null1);
}


```

输出

```
str1=Hello World!
int1=1
long1=-1
float1=1.1
double1=110.0
hex1=10
hex2=10
true1=true
false1=false
null1=null


```

#### 算数运算表达式

SpEL 支持加 (+)、减 (-)、乘 (*)、除 (/)、求余（%）、幂（^）运算。

<table data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)"><thead data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)"><tr data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183053334="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">类型</th><th data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079183053334="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">示例</th></tr></thead><tbody data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)"><tr data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">加减乘除</td><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">int result1 = parser.parseExpression("1+2-3*4/2").getValue(Integer.class);//-3</td></tr><tr data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">求余</td><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079183053334="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">int result2 = parser.parseExpression("4%3").getValue(Integer.class);//1</td></tr><tr data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">幂运算</td><td data-darkmode-color-16079183053334="rgb(163, 163, 163)" data-darkmode-original-color-16079183053334="rgb(0,0,0)" data-darkmode-bgcolor-16079183053334="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079183053334="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">int result3 = parser.parseExpression("2^3").getValue(Integer.class);//8</td></tr></tbody></table>

SpEL 还提供求余（MOD）和除（DIV）而外两个运算符，与 “%” 和“/”等价，不区分大小写。

#### 关系表达式

等于（==）、不等于 (!=)、大于 (>)、大于等于 (>=)、小于 (<)、小于等于 (<=)，区间（between）运算。

如`parser.parseExpression("1>2").getValue(boolean.class);`将返回 false；

而`parser.parseExpression("1 between {1, 2}").getValue(boolean.class);`将返回 true。

`between运算符右边操作数必须是列表类型，且只能包含2个元素。第一个元素为开始，第二个元素为结束，区间运算是包含边界值的，即 xxx>=list.get(0) && xxx<=list.get(1)`。

SpEL 同样提供了等价的 “EQ” 、“NE”、 “GT”、“GE”、 “LT” 、“LE” 来表示等于、不等于、大于、大于等于、小于、小于等于，不区分大小写。

```
@Test
public void test3() {
    ExpressionParser parser = new SpelExpressionParser();
    boolean v1 = parser.parseExpression("1>2").getValue(boolean.class);
    boolean between1 = parser.parseExpression("1 between {1,2}").getValue(boolean.class);
    System.out.println("v1=" + v1);
    System.out.println("between1=" + between1);
}


```

输出

```
v1=false
between1=true


```

#### 逻辑表达式

且（and 或者 &&）、或 (or 或者 ||)、非 (! 或 NOT)。

```
@Test
public void test4() {
    ExpressionParser parser = new SpelExpressionParser();

    boolean result1 = parser.parseExpression("2>1 and (!true or !false)").getValue(boolean.class);
    boolean result2 = parser.parseExpression("2>1 && (!true || !false)").getValue(boolean.class);

    boolean result3 = parser.parseExpression("2>1 and (NOT true or NOT false)").getValue(boolean.class);
    boolean result4 = parser.parseExpression("2>1 && (NOT true || NOT false)").getValue(boolean.class);

    System.out.println("result1=" + result1);
    System.out.println("result2=" + result2);
    System.out.println("result3=" + result3);
    System.out.println("result4=" + result4);
}


```

输出

```
result1=true
result2=true
result3=true
result4=false


```

#### 字符串连接及截取表达式

使用 “+” 进行字符串连接，使用 “'String'[0] [index]” 来截取一个字符，目前只支持截取一个，如 “'Hello' + 'World!'” 得到 “Hello World!”；而“'Hello World!'[0]” 将返回“H”。

#### 三目运算

三目运算符 **“表达式 1? 表达式 2: 表达式 3”** 用于构造三目运算表达式，如 “2>1?true:false” 将返回 true；

#### Elivis 运算符

Elivis 运算符 **“表达式 1?: 表达式 2”** 从 Groovy 语言引入用于简化三目运算符的，当表达式 1 为非 null 时则返回表达式 1，当表达式 1 为 null 时则返回表达式 2，简化了三目运算符方式 “表达式 1? 表达式 1: 表达式 2”，如“null?:false” 将返回 false，而 “true?:false” 将返回 true；

#### 正则表达式

使用 “str matches regex，如“'123' matches '\d{3}'” 将返回 true；

#### 括号优先级表达式

使用 “(表达式)” 构造，括号里的具有高优先级。

### 类相关表达式

#### 类类型表达式

使用 “T(Type)” 来表示 java.lang.Class 实例，“Type”必须是类全限定名，“java.lang”包除外，即该包下的类可以不指定包名；使用类类型表达式还可以进行访问类静态方法及类静态字段。

具体使用方法如下：

```
@Test
public void testClassTypeExpression() {
    ExpressionParser parser = new SpelExpressionParser();
    //java.lang包类访问
    Class<String> result1 = parser.parseExpression("T(String)").getValue(Class.class);
    System.out.println(result1);

    //其他包类访问
    String expression2 = "T(com.javacode2018.spel.SpelTest)";
    Class<SpelTest> value = parser.parseExpression(expression2).getValue(Class.class);
    System.out.println(value == SpelTest.class);

    //类静态字段访问
    int result3 = parser.parseExpression("T(Integer).MAX_VALUE").getValue(int.class);
    System.out.println(result3 == Integer.MAX_VALUE);

    //类静态方法调用
    int result4 = parser.parseExpression("T(Integer).parseInt('1')").getValue(int.class);
    System.out.println(result4);
}


```

输出

```
class java.lang.String
true
true
1


```

对于 java.lang 包里的可以直接使用 “T(String)” 访问；其他包必须是类全限定名；可以进行静态字段访问如“T(Integer).MAX_VALUE”；也可以进行静态方法访问如“T(Integer).parseInt('1')”。

#### 类实例化

类实例化同样使用 java 关键字 “new”，类名必须是全限定名，但 java.lang 包内的类型除外，如 String、Integer。

```
@Test
public void testConstructorExpression() {
    ExpressionParser parser = new SpelExpressionParser();
    String result1 = parser.parseExpression("new String('路人甲java')").getValue(String.class);
    System.out.println(result1);

    Date result2 = parser.parseExpression("new java.util.Date()").getValue(Date.class);
    System.out.println(result2);
}


```

实例化完全跟 Java 内方式一样，运行输出

```
路人甲java
Tue Aug 03 20:22:43 CST 2020


```

#### instanceof 表达式

SpEL 支持 instanceof 运算符，跟 Java 内使用同义；如 “'haha' instanceof T(String)” 将返回 true。

```
@Test
public void testInstanceOfExpression() {
    ExpressionParser parser = new SpelExpressionParser();
    Boolean value = parser.parseExpression("'路人甲' instanceof T(String)").getValue(Boolean.class);
    System.out.println(value);
}


```

输出

```
true


```

#### 变量定义及引用

变量定义通过 EvaluationContext 接口的 setVariable(variableName, value) 方法定义；在表达式中使用`"#variableName"`引用；除了引用自定义变量，SpE 还允许引用根对象及当前上下文对象，使用`"#root"`引用根对象，使用`"#this"`引用当前上下文对象；

```
@Test
public void testVariableExpression() {
    ExpressionParser parser = new SpelExpressionParser();
    EvaluationContext context = new StandardEvaluationContext();
    context.setVariable("name", "路人甲java");
    context.setVariable("lesson", "Spring系列");

    //获取name变量，lesson变量
    String name = parser.parseExpression("#name").getValue(context, String.class);
    System.out.println(name);
    String lesson = parser.parseExpression("#lesson").getValue(context, String.class);
    System.out.println(lesson);

    //StandardEvaluationContext构造器传入root对象，可以通过#root来访问root对象
    context = new StandardEvaluationContext("我是root对象");
    String rootObj = parser.parseExpression("#root").getValue(context, String.class);
    System.out.println(rootObj);

    //#this用来访问当前上线文中的对象
    String thisObj = parser.parseExpression("#this").getValue(context, String.class);
    System.out.println(thisObj);
}


```

输出

```
路人甲java
Spring系列
我是root对象
我是root对象


```

使用 “#variable” 来引用在 EvaluationContext 定义的变量；除了可以引用自定义变量，还可以使用 “#root” 引用根对象，“#this”引用当前上下文对象，此处 “#this” 即根对象。

#### 自定义函数

目前只支持类静态方法注册为自定义函数；SpEL 使用 StandardEvaluationContext 的 registerFunction 方法进行注册自定义函数，其实完全可以使用 setVariable 代替，两者其实本质是一样的；

```
@Test
public void testFunctionExpression() throws SecurityException, NoSuchMethodException {
    //定义2个函数,registerFunction和setVariable都可以，不过从语义上面来看用registerFunction更恰当
    StandardEvaluationContext context = new StandardEvaluationContext();
    Method parseInt = Integer.class.getDeclaredMethod("parseInt", String.class);
    context.registerFunction("parseInt1", parseInt);
    context.setVariable("parseInt2", parseInt);

    ExpressionParser parser = new SpelExpressionParser();
    System.out.println(parser.parseExpression("#parseInt1('3')").getValue(context, int.class));
    System.out.println(parser.parseExpression("#parseInt2('3')").getValue(context, int.class));
    
    String expression1 = "#parseInt1('3') == #parseInt2('3')";
    boolean result1 = parser.parseExpression(expression1).getValue(context, boolean.class);
    System.out.println(result1);
}


```

此处可以看出 “registerFunction” 和“setVariable”都可以注册自定义函数，但是两个方法的含义不一样，推荐使用 “registerFunction” 方法注册自定义函数。

运行输出

```
3
3
true


```

#### 表达式赋值

使用`Expression#setValue`方法可以给表达式赋值

```
@Test
public void testAssignExpression1() {
    Object user = new Object() {
        private String name;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        @Override
        public String toString() {
            return "$classname{" +
                    " + name + '\'' +
                    '}';
        }
    };
    {
        //user为root对象
        ExpressionParser parser = new SpelExpressionParser();
        EvaluationContext context = new StandardEvaluationContext(user);
        parser.parseExpression("#root.name").setValue(context, "路人甲java");
        System.out.println(parser.parseExpression("#root").getValue(context, user.getClass()));
    }
    {
        //user为变量
        ExpressionParser parser = new SpelExpressionParser();
        EvaluationContext context = new StandardEvaluationContext();
        context.setVariable("user", user);
        parser.parseExpression("#user.name").setValue(context, "路人甲java");
        System.out.println(parser.parseExpression("#user").getValue(context, user.getClass()));
    }
}


```

运行输出

```
$classname{name='路人甲java'}
$classname{name='路人甲java'}


```

#### 对象属性存取及安全导航表达式

对象属性获取非常简单，即使用如 “a.property.property” 这种点缀式获取，SpEL 对于属性名首字母是不区分大小写的；SpEL 还引入了 Groovy 语言中的安全导航运算符“**(对象 | 属性)?. 属性**”，用来避免 “?.” 前边的表达式为 null 时抛出空指针异常，而是返回 null；修改对象属性值则可以通过赋值表达式或 Expression 接口的 setValue 方法修改。

```
public static class Car {
    private String name;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "Car{" +
                " + name + '\'' +
                '}';
    }
}

public static class User {
    private Car car;

    public Car getCar() {
        return car;
    }

    public void setCar(Car car) {
        this.car = car;
    }

    @Override
    public String toString() {
        return "User{" +
                "car=" + car +
                '}';
    }
}

@Test
public void test5() {
    User user = new User();
    EvaluationContext context = new StandardEvaluationContext();
    context.setVariable("user", user);

    ExpressionParser parser = new SpelExpressionParser();
    //使用.符号，访问user.car.name会报错，原因：user.car为空
    try {
        System.out.println(parser.parseExpression("#user.car.name").getValue(context, String.class));
    } catch (EvaluationException | ParseException e) {
        System.out.println("出错了：" + e.getMessage());
    }
    //使用安全访问符号?.，可以规避null错误
    System.out.println(parser.parseExpression("#user?.car?.name").getValue(context, String.class));

    Car car = new Car();
    car.setName("保时捷");
    user.setCar(car);

    System.out.println(parser.parseExpression("#user?.car?.toString()").getValue(context, String.class));
}


```

运行输出

```
出错了：EL1007E: Property or field 'name' cannot be found on null
null
Car{name='保时捷'}


```

#### 对象方法调用

对象方法调用更简单，跟 Java 语法一样；如 “'haha'.substring(2,4)” 将返回“ha”；而对于根对象可以直接调用方法；

#### Bean 引用

SpEL 支持使用 “@” 符号来引用 Bean，在引用 Bean 时需要使用 BeanResolver 接口实现来查找 Bean，Spring 提供 BeanFactoryResolver 实现。

```
@Test
public void test6() {
    DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
    User user = new User();
    Car car = new Car();
    car.setName("保时捷");
    user.setCar(car);
    factory.registerSingleton("user", user);

    StandardEvaluationContext context = new StandardEvaluationContext();
    context.setBeanResolver(new BeanFactoryResolver(factory));

    ExpressionParser parser = new SpelExpressionParser();
    User userBean = parser.parseExpression("@user").getValue(context, User.class);
    System.out.println(userBean);
    System.out.println(userBean == factory.getBean("user"));
}


```

运行输出

```
User{car=Car{name='保时捷'}}
true


```

### 集合相关表达式

#### 内联 List

从 Spring3.0.4 开始支持内联 List，使用 {表达式，……} 定义内联 List，如 “{1,2,3}” 将返回一个整型的 ArrayList，而 “{}” 将返回空的 List，对于字面量表达式列表，SpEL 会使用 java.util.Collections.unmodifiableList 方法将列表设置为不可修改。

```
@Test
public void test7() {
    ExpressionParser parser = new SpelExpressionParser();
    //将返回不可修改的空List
    List<Integer> result2 = parser.parseExpression("{}").getValue(List.class);
    //对于字面量列表也将返回不可修改的List
    List<Integer> result1 = parser.parseExpression("{1,2,3}").getValue(List.class);
    Assert.assertEquals(new Integer(1), result1.get(0));
    try {
        result1.set(0, 2);
    } catch (Exception e) {
        e.printStackTrace();
    }
    //对于列表中只要有一个不是字面量表达式，将只返回原始List，
    //不会进行不可修改处理
    String expression3 = "{{1+2,2+4},{3,4+4}}";
    List<List<Integer>> result3 = parser.parseExpression(expression3).getValue(List.class);
    result3.get(0).set(0, 1);
    System.out.println(result3);
    //声明二维数组并初始化
    int[] result4 = parser.parseExpression("new int[2]{1,2}").getValue(int[].class);
    System.out.println(result4[1]);
    //定义一维数组并初始化
    int[] result5 = parser.parseExpression("new int[1]").getValue(int[].class);
    System.out.println(result5[0]);
}


```

输出

```
java.lang.UnsupportedOperationException
 at java.util.Collections$UnmodifiableList.set(Collections.java:1311)
 at com.javacode2018.spel.SpelTest.test7(SpelTest.java:315)
[[1, 6], [3, 8]]
2
0


```

#### 内联数组

和 Java 数组定义类似，只是在定义时进行多维数组初始化。

```
int[][][] result4 = parser.parseExpression("new int[1][2][3]{{1}{2}{3}}").getValue(int[][][].class);


```

#### 集合，字典元素访问

SpEL 目前支持所有集合类型和字典类型的元素访问，使用 “集合[索引]” 访问集合元素，使用 “map[key]” 访问字典元素；

```
//SpEL内联List访问  
int result1 = parser.parseExpression("{1,2,3}[0]").getValue(int.class);  

//SpEL目前支持所有集合类型的访问  
Collection<Integer> collection = new HashSet<Integer>();  
collection.add(1);  
collection.add(2);  

EvaluationContext context2 = new StandardEvaluationContext();  
context2.setVariable("collection", collection);  
int result2 = parser.parseExpression("#collection[1]").getValue(context2, int.class);  


//SpEL对Map字典元素访问的支持  
Map<String, Integer> map = new HashMap<String, Integer>();  
map.put("a", 1);  

EvaluationContext context3 = new StandardEvaluationContext();  
context3.setVariable("map", map);  
int result3 = parser.parseExpression("#map['a']").getValue(context3, int.class);  


```

#### 列表，字典，数组元素修改

可以使用赋值表达式或 Expression 接口的 setValue 方法修改；

```
@Test
public void test8() {
    ExpressionParser parser = new SpelExpressionParser();

    //修改list元素值
    List<Integer> list = new ArrayList<Integer>();
    list.add(1);
    list.add(2);

    EvaluationContext context1 = new StandardEvaluationContext();
    context1.setVariable("collection", list);
    parser.parseExpression("#collection[1]").setValue(context1, 4);
    int result1 = parser.parseExpression("#collection[1]").getValue(context1, int.class);
    System.out.println(result1);

    //修改map元素值
    Map<String, Integer> map = new HashMap<String, Integer>();
    map.put("a", 1);
    EvaluationContext context2 = new StandardEvaluationContext();
    context2.setVariable("map", map);
    parser.parseExpression("#map['a']").setValue(context2, 4);
    Integer result2 = parser.parseExpression("#map['a']").getValue(context2, int.class);
    System.out.println(result2);
}


```

输出

```
4
4


```

#### 集合投影

在 SQL 中投影指从表中选择出列，而在 SpEL 指根据集合中的元素中通过选择来构造另一个集合，该集合和原集合具有相同数量的元素；SpEL 使用 “（list|map）.![投影表达式]” 来进行投影运算：

```
@Test
public void test9() {
    ExpressionParser parser = new SpelExpressionParser();

    //1.测试集合或数组
    List<Integer> list = new ArrayList<Integer>();
    list.add(4);
    list.add(5);
    EvaluationContext context1 = new StandardEvaluationContext();
    context1.setVariable("list", list);
    Collection<Integer> result1 = parser.parseExpression("#list.![#this+1]").getValue(context1, Collection.class);
    result1.forEach(System.out::println);

    System.out.println("------------");
    //2.测试字典
    Map<String, Integer> map = new HashMap<String, Integer>();
    map.put("a", 1);
    map.put("b", 2);
    EvaluationContext context2 = new StandardEvaluationContext();
    context2.setVariable("map", map);
    List<Integer> result2 = parser.parseExpression("#map.![value+1]").getValue(context2, List.class);
    result2.forEach(System.out::println);
}


```

对于集合或数组使用如上表达式进行投影运算，其中投影表达式中 “#this” 代表每个集合或数组元素，可以使用比如 “#this.property” 来获取集合元素的属性，其中 “#this” 可以省略。

Map 投影最终只能得到 List 结果，如上所示，对于投影表达式中的 “#this” 将是 Map.Entry，所以可以使用 “value” 来获取值，使用 “key” 来获取键。

#### 集合选择

在 SQL 中指使用 select 进行选择行数据，而在 SpEL 指根据原集合通过条件表达式选择出满足条件的元素并构造为新的集合，SpEL 使用 “(list|map).?[选择表达式]”，其中选择表达式结果必须是 boolean 类型，如果 true 则选择的元素将添加到新集合中，false 将不添加到新集合中。

```
@Test
public void test10() {
    ExpressionParser parser = new SpelExpressionParser();

    //1.测试集合或数组
    List<Integer> list = new ArrayList<Integer>();
    list.add(1);
    list.add(4);
    list.add(5);
    list.add(7);
    EvaluationContext context1 = new StandardEvaluationContext();
    context1.setVariable("list", list);
    Collection<Integer> result1 = parser.parseExpression("#list.?[#this>4]").getValue(context1, Collection.class);
    result1.forEach(System.out::println);

    System.out.println("------------");
    
}


```

输出

```
5
7


```

对于集合或数组选择，如 “#collection.?[#this>4]” 将选择出集合元素值大于 4 的所有元素。选择表达式必须返回布尔类型，使用 “#this” 表示当前元素。

```
//2.测试字典
Map<String, Integer> map = new HashMap<String, Integer>();
map.put("a", 1);
map.put("b", 2);
map.put("c", 3);
EvaluationContext context2 = new StandardEvaluationContext();
context2.setVariable("map", map);
Map<String, Integer> result2 = parser.parseExpression("#map.?[key!='a']").getValue(context2, Map.class);
result2.forEach((key, value) -> {
    System.out.println(key + ":" + value);
});
System.out.println("------------");
List<Integer> result3 = parser.parseExpression("#map.?[key!='a'].![value+1]").getValue(context2, List.class);
result3.forEach(System.out::println);


```

输出

```
b:2
c:3
------------
3
4


```

对于字典选择，如 “#map.?[#this.key != 'a']” 将选择键值不等于”a”的，其中选择表达式中 “#this” 是 Map.Entry 类型，而最终结果还是 Map，这点和投影不同；集合选择和投影可以一起使用，如 “#map.?[key != 'a'].![value+1]” 将首先选择键值不等于”a”的，然后在选出的 Map 中再进行 “value+1” 的投影。

### 表达式模板

模板表达式就是由字面量与一个或多个表达式块组成。每个表达式块由 “前缀 + 表达式 + 后缀” 形式组成，如 “${1+2}” 即表达式块。在前边我们已经介绍了使用 ParserContext 接口实现来定义表达式是否是模板及前缀和后缀定义。在此就不多介绍了，如 “Error ${#v0} ${#v1}” 表达式表示由字面量 “Error ”、模板表达式“#v0”、模板表达式“#v1” 组成，其中 v0 和 v1 表示自定义变量，需要在上下文定义。

解析表达式的时候需要指定模板，模板通过`ParserContext`接口来定义

```
public interface ParserContext {
 //是否是模板
 boolean isTemplate();
 //模板表达式前缀
 String getExpressionPrefix();
 //模板表达式后缀
 String getExpressionSuffix();
}


```

有个子类，我们直接可以拿来用：`TemplateParserContext`。

```
@Test
public void test11() {
    //创建解析器
    SpelExpressionParser parser = new SpelExpressionParser();
    //创建解析器上下文
    ParserContext context = new TemplateParserContext("%{", "}");
    Expression expression = parser.parseExpression("你好:%{#name},我们正在学习:%{#lesson}", context);

    //创建表达式计算上下文
    EvaluationContext evaluationContext = new StandardEvaluationContext();
    evaluationContext.setVariable("name", "路人甲java");
    evaluationContext.setVariable("lesson", "spring高手系列!");
    //获取值
    String value = expression.getValue(evaluationContext, String.class);
    System.out.println(value);
}


```

运行输出

```
你好:路人甲java,我们正在学习:spring高手系列!


```

在 Bean 定义中使用 spel 表达式
---------------------

### xml 风格的配置

SpEL 支持在 Bean 定义时注入，默认使用 “#{SpEL 表达式}” 表示，其中 “#root” 根对象默认可以认为是 ApplicationContext，只有 ApplicationContext 实现默认支持 SpEL，获取根对象属性其实是获取容器中的 Bean。

如：

```
<bean id="world" class="java.lang.String">  
    <constructor-arg value="#{' World!'}"/>  
</bean>  

<bean id="hello1" class="java.lang.String">  
    <constructor-arg value="#{'Hello'}#{world}"/>  
</bean>    

<bean id="hello2" class="java.lang.String">  
    <constructor-arg value="#{'Hello' + world}"/>
</bean>  

<bean id="hello3" class="java.lang.String">  
    <constructor-arg value="#{'Hello' + @world}"/>  
</bean>


```

模板默认以前缀 “#{” 开头，以后缀 “}” 结尾，且不允许嵌套，如 “#{'Hello'#{world}}” 错误，如 “#{'Hello' + world}” 中“world”默认解析为 Bean。当然可以使用 “@bean” 引用了。

是不是很简单，除了 XML 配置方式，Spring 还提供一种注解方式 @Value，接着往下看吧。

### 注解风格的配置

基于注解风格的 SpEL 配置也非常简单，使用 @Value 注解来指定 SpEL 表达式，该注解可以放到字段、方法及方法参数上。

测试 Bean 类如下，使用 @Value 来指定 SpEL 表达式：

```
public class SpELBean {  
    @Value("#{'Hello' + world}")  
    private String value;  
}


```

### 在 Bean 定义中 SpEL 的问题

如果有同学问 “#{我不是 SpEL 表达式}” 不是 SpEL 表达式，而是公司内部的模板，想换个前缀和后缀该如何实现呢？

我们使用 BeanFactoryPostProcessor 接口提供 postProcessBeanFactory 回调方法，它是在 IoC 容器创建好但还未进行任何 Bean 初始化时被 ApplicationContext 实现调用，因此在这个阶段把 SpEL 前缀及后缀修改掉是安全的，具体代码如下：

```
package com.javacode2018.spel.test1;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanExpressionResolver;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.expression.StandardBeanExpressionResolver;
import org.springframework.stereotype.Component;

@Component
public class SpelBeanFactoryPostProcessor implements BeanFactoryPostProcessor {
    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
        BeanExpressionResolver beanExpressionResolver = beanFactory.getBeanExpressionResolver();
        if (beanExpressionResolver instanceof StandardBeanExpressionResolver) {
            StandardBeanExpressionResolver resolver = (StandardBeanExpressionResolver) beanExpressionResolver;
            resolver.setExpressionPrefix("%{");
            resolver.setExpressionSuffix("}");
        }
    }
}


```

上测试代码

```
package com.javacode2018.spel.test1;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class LessonModel {
    @Value("你好,%{@name},%{@msg}")
    private String desc;

    @Override
    public String toString() {
        return "LessonModel{" +
                "desc='" + desc + '\'' +
                '}';
    }
}


```

@name：容器中 name 的 bean

@msg：容器中 msg 的 bean

下面我们来个配置类，顺便定义 name 和 msg 这 2 个 bean，顺便扫描上面 2 个配置类

```
package com.javacode2018.spel.test1;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@ComponentScan
@Configuration
public class MainConfig {
    @Bean
    public String name() {
        return "路粉";
    }

    @Bean
    public String msg() {
        return "欢迎和我一起学习java各种技术！";
    }
}


```

测试用例

```
@Test
public void test12() {
    AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext();
    context.register(MainConfig.class);
    context.refresh();
    LessonModel lessonModel = context.getBean(LessonModel.class);
    System.out.println(lessonModel);
}


```

运行输出

```
LessonModel{desc='你好,路粉,欢迎和我一起学习java各种技术！'}


```

总结
--

1.  Spel 功能还是比较强大的，可以脱离 spring 环境独立运行
    
2.  spel 可以用在一些动态规则的匹配方面，比如监控系统中监控规则的动态匹配；其他的一些条件动态判断等等
    
3.  本文内容比较长，建议大家把案例都敲一遍，可以设置一些断点去研究一下源码，有问题的，欢迎大家留言交流。
    

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
    
38.  [Spring 系列第 38 篇：@Scheduled & @EnableScheduling 定时器详解](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648935890&idx=2&sn=f8a8e01e7399161621152b2e4caa8128&scene=21#wechat_redirect)
    

更多好文章
-----

1.  [Java 高并发系列（共 34 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933285&idx=1&sn=f5507c251b84c3405f2fe0f7fb1da97d&chksm=88621b9bbf15928dd4c26f52b2abb0e130cde02100c432f33f0e90123b5e4b20d43017c1030e&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [MySql 高手系列（共 27 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933461&idx=1&sn=67cd31469273b68a258d963e53b56325&chksm=88621c6bbf15957d7308d81cd8ba1761b356222f4c6df75723aee99c265bd94cc869faba291c&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Maven 高手系列（共 10 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933753&idx=1&sn=0b41083939980be87a61c4f573792459&chksm=88621d47bf1594516092b662c545abfac299d296e232bf25e9f50be97e002e2698ea78218828&scene=21#wechat_redirect)
    
4.  [Mybatis 系列（共 12 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933868&idx=1&sn=ed16ef4afcbfcb3423a261422ff6934e&chksm=88621dd2bf1594c4baa21b7adc47456e5f535c3358cd11ddafb1c80742864bb19d7ccc62756c&token=1400407286&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [聊聊 db 和缓存一致性常见的实现方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933452&idx=1&sn=48b3b1cbd27c50186122fef8943eca5f&chksm=88621c72bf159564e629ee77d180424274ae9effd8a7c2997f853135b28f3401970793d8098d&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [接口幂等性这么重要，它是什么？怎么实现？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933334&idx=1&sn=3a68da36e4e21b7339418e40ab9b6064&chksm=88621be8bf1592fe5301aab732fbed8d1747475f4221da341350e0cc9935225d41bf79375d43&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [泛型，有点难度，会让很多人懵逼，那是因为你没有看这篇文章！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933878&idx=1&sn=bebd543c39d02455456680ff12e3934b&chksm=88621dc8bf1594de6b50a760e4141b80da76442ba38fb93a91a3d18ecf85e7eee368f2c159d3&token=799820369&lang=zh_CN&scene=21#wechat_redirect)
    

```
世界上最好的关系是相互成就，点赞转发 感恩开心😃




```

路人甲 java  

![](https://mmbiz.qpic.cn/mmbiz_png/9Xne6pfLaexiaK8h8pVuFJibShbdbS0QEE9V2UuWiakgeMWbXLgrrT114RwXKZfEJicvtz3jsUslfVhpOGZS62mQvg/640?wx_fmt=png)

▲长按图片识别二维码关注

路人甲 Java：工作 10 年的前阿里 P7，所有文章以系列的方式呈现，带领大家成为 java 高手，目前已出：java 高并发系列、mysql 高手系列、Maven 高手系列、mybatis 系列、spring 系列，正在连载 springcloud 系列，欢迎关注！