> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937788&idx=2&sn=21030dc8fff11dfdfb6d005cb8a8d526&scene=21#wechat_redirect)

1、本文 2 个目的
----------

1、讨论一下消息投递的 5 种方式

2、带你手写代码，实现事务消息的投递

2、讨论一下消息投递的 5 种方式
-----------------

### 2.1、业务场景

电商中有这样的一个场景：商品下单之后，需给用户送积分，订单表和积分表分别在不同的 db 中，涉及到分布式事务的问题。

我们通过可靠消息来解决这个问题：

1.  商品下单成功之后送积分的操作，我们使用 mq 来实现
    
2.  商品下单成功之后，投递一条消息到 mq，积分系统消费消息，给用户增加积分
    

我们主要讨论一下，商品下单及投递消息到 mq 的操作，如何实现？每种方式优缺点？

### 2.2、方式一

#### 过程

*   **step1**：开启本地事务
    
*   **step2**：生成购物订单
    
*   **step3**：投递消息到 mq
    
*   **step4**：提交本地事务
    

**这种方式是将发送消息放在了事务提交之前。**

#### 可能存在的问题

*   **step3 发生异常**：导致 step4 失败，商品下单失败，直接影响到商品下单业务
    
*   **step4 发生异常，其他 step 成功**：商品下单失败，消息投递成功，给用户增加了积分
    

### 2.3、方式二

下面我们换种方式，我们将发送消息放到事务之后进行。

#### 过程

*   **step1**：开启本地事务
    
*   **step2**：生成购物订单
    
*   **step3**：提交本地事务
    
*   **step4**：投递消息到 mq
    

#### 可能会出现的问题

**step4 发生异常，其他 step 成功**：导致商品下单成功，投递消息失败，用户未增加积分

上面两种是比较常见的做法，也是最容易出错的。

### 2.4、方式三

*   **step1**：开启本地事务
    
*   **step2**：生成购物订单
    
*   **step3**：本地库中插入一条需要发送消息的记录 t_msg_record
    
*   **step3**：提交本地事务
    
*   **step5**：新增一个定时器，轮询 t_msg_record，将待发送的记录投递到 mq 中
    

这种方式借助了数据库的事务，业务和消息记录作为了一个原子操作，业务成功之后，消息日志必定是存在的。解决了前两种方式遇到的问题。如果我们的业务系统比较单一，可以采用这种方式。

对于微服务化的情况，上面这种方式不是太好，每个服务都需要上面的操作；也不利于扩展。

### 2.5、方式四

增加一个**消息服务**及**消息库**，负责消息的落库、将消息发送投递到 mq。

*   **step1**：开启本地事务
    
*   **step2**：生成购物订单
    
*   **step3**：当前事务库插入一条日志：生成一个唯一的业务 id（msg_order_id），将 msg_order_id 和订单关联起来保存到当前事务所在的库中
    
*   **step4**：调用消息服务：携带 msg_order_id，将消息先落地入库，此时消息的状态为待发送状态，返回消息 id(msg_id)
    
*   **step5**：提交本地事务
    
*   **step6**：如果上面都成功，调用消息服务，将消息投递到 mq 中；如果上面有失败的情况，则调用消息服务取消消息的发送
    

能想到上面这种方式，已经算是有很大进步了，我们继续分析一下可能存在的问题：

1.  系统中增加了一个消息服务，商品下单操作依赖于该服务，业务对该服务依赖性比较高，当消息服务不可用时，整个业务将不可用。
    
2.  若 step6 失败，消息将处于待发送状态，此时业务方需要提供一个回查接口（通过 msg_order_id 查询）, 验证业务是否执行成功；消息服务需新增一个定时任务，对于状态为待发送状态的消息做补偿处理，检查一下业务是否处理成功；从而确定消息是投递还是取消发送
    
3.  step4 依赖于消息服务，如果消息服务性能不佳，会导致当前业务的事务提交时间延长，**容易产生死锁，并导致并发性能降低**。我们通常是比较忌讳在事务中做远程调用处理的，远程调用的性能和时间往往不可控，会导致当前事务变为一个大事务，从而引发其他故障。
    

### 2.6、方式五

在以上方式中，我们继续改进，进而出现了更好的一种方式：

*   **step1**：生成一个全局唯一业务消息 id（bus_msg_id)，调用消息服务，携带 bus_msg_id，将消息先落地入库，此时消息的状态为待发送状态，返回消息 id（msg_id）
    
*   **step2**：开启本地事务
    
*   **step3**：生成购物订单
    
*   **step4**：当前事务库插入一条日志（将 step3 中的业务和 bus_msg_id 关联起来）
    
*   **step5**：提交本地事务
    
*   **step6**：分 2 种情况：如果上面都成功，调用消息服务，将消息投递到 mq 中；如果上面有失败的情况，则调用消息服务取消消息的发送
    

若 step6 失败，消息将处于待发送状态，此时业务方需要提供一个回查接口（通过 bus_msg_id 查询）, 验证业务是否执行成功；

消息服务需新增一个定时任务，对于状态为待发送状态的消息做补偿处理，检查一下业务是否处理成功；从而确定消息是投递还是取消发送。

方式五和方式四对比，比较好的一个地方：将调用消息服务，消息落地操作，放在了事务之外进行，这点小的改进其实算是一个非常好的优化，减少了本地事务的执行时间，从而可以提升并发量，阿里有个消息中间件 **RocketMQ** 就支持方式 5 这种，大家可以去用用。

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06A1NNibx5QgpdJ6YXmjXJPt3SEfGuxuNDiaqBKn0MORAdibzdOxantYr8ftEjHeanQU8PwOz9s5ibD77g/640?wx_fmt=png)

下面我们通过代码来实现方式 4。

3、方式 4 代码实现
-----------

### 3.1、准备数据库

3 张表：

t_user：业务库中的用户表，一会用来模拟用户注册，注册成功之后投递消息。

t_msg_order：消息订单表，这个表放在业务库中，业务操作中若需要发送消息，则在业务操作的事务中同时向 t_msg_order 表插入一条数据，若业务操作成功，那么 t_msg_order 表肯定也会成功插入一条数据，发送消息的时候携带上 t_msg_order 的 id，消息服务可以通过这个 id 去业务库回查 t_msg_order 中的记录，如果记录存在，则说明业务操作成功了。

t_msg：消息表，所有发送的消息信息放在这个表中，主要字段有：消息内容，msg_order_id：来源于 t_msg_order 表的 id

```
DROP DATABASE IF EXISTS javacode2018;
CREATE DATABASE if NOT EXISTS javacode2018;

USE javacode2018;
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user(
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(256) NOT NULL DEFAULT '' COMMENT '姓名'
);

DROP TABLE IF EXISTS t_msg;
CREATE TABLE t_msg(
  id INT PRIMARY KEY AUTO_INCREMENT,
  msg VARCHAR(256) NOT NULL DEFAULT '' COMMENT '消息内容，可以json格式的数据',
  msg_order_id BIGINT NOT NULL DEFAULT 0 COMMENT '消息订单id',
  status SMALLINT NOT NULL DEFAULT 0 COMMENT '消息状态,0:待投递，1：已发送，2：取消发送'
) COMMENT '消息表';

DROP TABLE IF EXISTS t_msg_order;
CREATE TABLE t_msg_order(
  id INT PRIMARY KEY AUTO_INCREMENT,
  ref_type BIGINT NOT NULL DEFAULT 0 COMMENT '关联业务类型',
  ref_id VARCHAR(256) NOT NULL DEFAULT '' COMMENT '关联业务id（ref_type & ref_id 唯一）'
) COMMENT '消息订单表,放在业务库中';

alter table t_msg_order add UNIQUE INDEX idx1 (ref_type,ref_id);


```

### 3.2、关键 java 代码

#### 配置类 MainConfig11

```
package com.javacode2018.tx.demo11;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;

/**
 * 公众号：路人甲Java，工作10年的前阿里P7分享Java、算法、数据库方面的技术干货！
 * <a href="http://www.itsoku.com">个人博客</a>
 */
@ComponentScan
@EnableTransactionManagement
public class MainConfig11 {
    @Bean
    public DataSource dataSource() {
        org.apache.tomcat.jdbc.pool.DataSource dataSource = new org.apache.tomcat.jdbc.pool.DataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:3306/javacode2018?characterEncoding=UTF-8");
        dataSource.setUsername("root");
        dataSource.setPassword("root123");
        dataSource.setInitialSize(5);
        return dataSource;
    }

    //定义一个jdbcTemplate
    @Bean
    public JdbcTemplate jdbcTemplate(DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }

    //定义事务管理器transactionManager
    @Bean
    public PlatformTransactionManager transactionManager(DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }

}


```

#### MsgModel

```
package com.javacode2018.tx.demo11;

import lombok.*;

/**
 * 公众号：路人甲Java，工作10年的前阿里P7分享Java、算法、数据库方面的技术干货！
 * <a href="http://www.itsoku.com">个人博客</a>
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class MsgModel {
    private Long id;
    //消息内容
    private String msg;
    //消息订单id
    private Long msg_order_id;
    //消息状态,0:待投递，1：已发送，2：取消发送
    private Integer status;
}


```

#### MsgOrderModel

```
package com.javacode2018.tx.demo11;

import lombok.*;

/**
 * 公众号：路人甲Java，工作10年的前阿里P7分享Java、算法、数据库方面的技术干货！
 * <a href="http://www.itsoku.com">个人博客</a>
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MsgOrderModel {
    private Long id;
    //关联业务类型
    private Integer ref_type;
    //关联业务id（ref_type & ref_id 唯一）
    private String ref_id;
}


```

#### MsgOrderService

提供了对 t_msg_order 表的一些操作，2 个方法，一个用来插入数据，一个用来查询。

```
package com.javacode2018.tx.demo11;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;

/**
 * 公众号：路人甲Java，工作10年的前阿里P7分享Java、算法、数据库方面的技术干货！
 * <a href="http://www.itsoku.com">个人博客</a>
 */
@Component
public class MsgOrderService {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 插入消息订单
     *
     * @param ref_type
     * @param ref_id
     * @return
     */
    @Transactional
    public MsgOrderModel insert(Integer ref_type, String ref_id) {
        MsgOrderModel msgOrderModel = MsgOrderModel.builder().ref_type(ref_type).ref_id(ref_id).build();
        //插入消息
        this.jdbcTemplate.update("insert into t_msg_order (ref_type,ref_id) values (?,?)",
                ref_type,
                ref_id
        );
        //获取消息订单id
        msgOrderModel.setId(this.jdbcTemplate.queryForObject("SELECT LAST_INSERT_ID()", Long.class));
        return msgOrderModel;
    }

    /**
     * 根据消息id获取消息
     *
     * @param id
     * @return
     */
    public MsgOrderModel getById(Long id) {
        List<MsgOrderModel> list = this.jdbcTemplate.query("select * from t_msg_order where id = ? limit 1", new BeanPropertyRowMapper<MsgOrderModel>(MsgOrderModel.class), id);
        return Objects.nonNull(list) && !list.isEmpty() ? list.get(0) : null;
    }

}


```

#### MsgService

消息服务，提供了对 t_msg 表的一些操作以及消息投递的一些方法

<table data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)"><thead data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)"><tr data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079185090594="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><th data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079185090594="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">方法</th><th data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(40, 40, 40)" data-darkmode-original-bgcolor-16079185090594="rgb(240, 240, 240)" data-style="border-top-width: 1px; border-color: rgb(204, 204, 204); text-align: left; background-color: rgb(240, 240, 240); min-width: 85px;">说明</th></tr></thead><tbody data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)"><tr data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079185090594="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079185090594="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">addMsg</td><td data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079185090594="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">添加消息，消息会落库，处于待发送状态</td></tr><tr data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079185090594="rgb(248, 248, 248)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: rgb(248, 248, 248);"><td data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079185090594="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">confirmSendMsg</td><td data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(32, 32, 32)" data-darkmode-original-bgcolor-16079185090594="rgb(248, 248, 248)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">确定投递消息，事务成功后可以调用</td></tr><tr data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079185090594="rgb(255,255,255)" data-style="border-width: 1px 0px 0px; border-right-style: initial; border-bottom-style: initial; border-left-style: initial; border-right-color: initial; border-bottom-color: initial; border-left-color: initial; border-top-style: solid; border-top-color: rgb(204, 204, 204); background-color: white;"><td data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079185090594="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">cancelSendMsg</td><td data-darkmode-color-16079185090594="rgb(163, 163, 163)" data-darkmode-original-color-16079185090594="rgb(0,0,0)" data-darkmode-bgcolor-16079185090594="rgb(25, 25, 25)" data-darkmode-original-bgcolor-16079185090594="rgb(255,255,255)" data-style="border-color: rgb(204, 204, 204); min-width: 85px;">取消投递消息，事务回滚可以调用</td></tr></tbody></table>

代码：

```
package com.javacode2018.tx.demo11;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;

/**
 * 公众号：路人甲Java，工作10年的前阿里P7分享Java、算法、数据库方面的技术干货！
 * <a href="http://www.itsoku.com">个人博客</a>
 */
@Component
public class MsgService {

    //添加一条消息(独立的事务中执行)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public Long addMsg(String msg, Long msg_order_id, boolean isSend) {
        MsgModel msgModel = MsgModel.builder().msg(msg).msg_order_id(msg_order_id).status(0).build();
        //先插入消息
        Long msg_id = this.insert(msgModel).getId();
        if (isSend) {
            //如果需要投递，则调用投递的方法
            this.confirmSendMsg(msg_id);
        }
        return msg_id;
    }

    /**
     * 确认消息投递(不需要事务)
     *
     * @param msg_id 消息id
     */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public void confirmSendMsg(Long msg_id) {
        MsgModel msgModel = this.getById(msg_id);
        //向mq中投递消息
        System.out.println(String.format("投递消息：%s", msgModel));
        //将消息状态置为已投递
        this.updateStatus(msg_id, 1);
    }

    /**
     * 取消消息投递(不需要事务)
     *
     * @param msg_id 消息id
     */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public void cancelSendMsg(Long msg_id) {
        MsgModel msgModel = this.getById(msg_id);
        System.out.println(String.format("取消投递消息：%s", msgModel));
        //将消息状态置为取消投递
        this.updateStatus(msg_id, 2);
    }

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 插入消息
     *
     * @param msgModel
     * @return
     */
    private MsgModel insert(MsgModel msgModel) {
        //插入消息
        this.jdbcTemplate.update("insert into t_msg (msg,msg_order_id,status) values (?,?,?)",
                msgModel.getMsg(),
                msgModel.getMsg_order_id(),
                msgModel.getStatus());
        //获取消息id
        msgModel.setId(this.jdbcTemplate.queryForObject("SELECT LAST_INSERT_ID()", Long.class));
        System.out.println("插入消息：" + msgModel);
        return msgModel;
    }

    /**
     * 根据消息id获取消息
     *
     * @param id
     * @return
     */
    private MsgModel getById(Long id) {
        List<MsgModel> list = this.jdbcTemplate.query("select * from t_msg where id = ? limit 1", new BeanPropertyRowMapper<MsgModel>(MsgModel.class), id);
        return Objects.nonNull(list) && !list.isEmpty() ? list.get(0) : null;
    }

    /**
     * 更新消息状态
     *
     * @param id
     * @param status
     */
    private void updateStatus(long id, int status) {
        this.jdbcTemplate.update("update t_msg set status = ? where id = ?", status, id);
    }

}


```

#### 消息投递器 MsgSender

消息投递器，给业务方使用，内部只有一个方法，用来发送消息。

若上下文没有事务，则消息落地之后立即投递；若存在事务，则消息投递分为 2 步走：消息先落地，事务执行完毕之后再确定是否投递，用到了事务扩展点：**TransactionSynchronization**，事务执行完毕之后会回调 TransactionSynchronization 接口中的 afterCompletion 方法，在这个方法中确定是否投递消息。对事务扩展点 **TransactionSynchronization** 不熟悉的建议先看一下这篇文章：[Spring 系列第 47 篇：spring 事务源码解析](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937564&idx=2&sn=549f841b7935c6f5f98957e4d443f893&scene=21#wechat_redirect)

```
package com.javacode2018.tx.demo11;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationAdapter;
import org.springframework.transaction.support.TransactionSynchronizationManager;


/**
 * 公众号：路人甲Java，工作10年的前阿里P7分享Java、算法、数据库方面的技术干货！
 * <a href="http://www.itsoku.com">个人博客</a>
 * 消息发送器，所有使用者调用send方法发送消息
 */
@Component
public class MsgSender {
    @Autowired
    private MsgOrderService msgOrderService;
    @Autowired
    private MsgService msgService;

    //发送消息
    public void send(String msg, int ref_type, String ref_id) {
        MsgOrderModel msgOrderModel = this.msgOrderService.insert(ref_type, ref_id);

        Long msg_order_id = msgOrderModel.getId();
        //TransactionSynchronizationManager.isSynchronizationActive 可以用来判断事务同步是否开启了
        boolean isSynchronizationActive = TransactionSynchronizationManager.isSynchronizationActive();
        /**
         * 若事务同步开启了，那么可以在事务同步中添加事务扩展点，则先插入消息，暂不发送，则在事务扩展点中添加回调
         * 事务结束之后会自动回调扩展点TransactionSynchronizationAdapter的afterCompletion()方法
         * 咱们在这个方法中确定是否投递消息
         */
        if (isSynchronizationActive) {
            final Long msg_id = this.msgService.addMsg(msg, msg_order_id, false);
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronizationAdapter() {
                @Override
                public void afterCompletion(int status) {
                    //代码走到这里时，事务已经完成了（可能是回滚了、或者是提交了）
                    //看一下消息关联的订单是否存在，如果存在，说明事务是成功的，业务是执行成功的，那么投递消息
                    if (msgOrderService.getById(msg_order_id) != null) {
                        System.out.println(String.format("准备投递消息,{msg_id:%s}", msg_id));
                        //事务成功：投递消息
                        msgService.confirmSendMsg(msg_id);
                    } else {
                        System.out.println(String.format("准备取消投递消息，{msg_id:%s}", msg_id));
                        //事务是不：取消投递消息
                        msgService.cancelSendMsg(msg_id);
                    }
                }
            });
        } else {
            //无事务的，直接插入并投递消息
            this.msgService.addMsg(msg, msg_order_id, true);
        }
    }
}


```

### 3.3、测试（3 种场景）

#### 3.3.1、场景 1：业务成功，消息投递成功

##### UserService

下面的 register 方法是有事务的，内部会插入一条用户信息，然后会投递一条消息

```
package com.javacode2018.tx.demo11;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * 公众号：路人甲Java，工作10年的前阿里P7分享Java、算法、数据库方面的技术干货！
 * <a href="http://www.itsoku.com">个人博客</a>
 */
@Component
public class UserService {
    @Autowired
    private JdbcTemplate jdbcTemplate;
    //消息投递器
    @Autowired
    private MsgSender msgSender;

    /**
     * 模拟用户注册成功，顺便发送消息
     */
    @Transactional
    public void register(Long user_id, String user_name) {
        //先插入用户
        this.jdbcTemplate.update("insert into t_user(id,name) VALUES (?,?)", user_id, user_name);
        System.out.println(String.format("用户注册：[user_id:%s,user_name:%s]", user_id, user_name));
        //发送消息
        String msg = String.format("[user_id:%s,user_name:%s]", user_id, user_name);
        //调用投递器的send方法投递消息
        this.msgSender.send(msg, 1, user_id.toString());
    }

}


```

##### 测试类

```
package com.javacode2018.tx.demo11;

import org.junit.Before;
import org.junit.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.jdbc.core.JdbcTemplate;

/**
 * 公众号：路人甲Java，工作10年的前阿里P7分享Java、算法、数据库方面的技术干货！
 * <a href="http://www.itsoku.com">个人博客</a>
 */
public class Demo11Test {

    private AnnotationConfigApplicationContext context;
    private UserService userService;
    private JdbcTemplate jdbcTemplate;

    @Before
    public void before() {
        this.context = new AnnotationConfigApplicationContext(MainConfig11.class);
        userService = context.getBean(UserService.class);
        this.jdbcTemplate = context.getBean("jdbcTemplate", JdbcTemplate.class);
        jdbcTemplate.update("truncate table t_user");
        jdbcTemplate.update("truncate table t_msg");
        jdbcTemplate.update("truncate table t_msg_order");
    }

    @Test
    public void test1() {
        this.userService.register(1L, "路人");
    }

}


```

##### 运行输出

```
用户注册：[user_id:1,user_name:路人]
插入消息：MsgModel(id=1, msg=[user_id:1,user_name:路人], msg_order_id=1, status=0)
准备投递消息,{msg_id:1}
投递消息：MsgModel(id=1, msg=[user_id:1,user_name:路人], msg_order_id=1, status=0)


```

#### 3.3.2、场景 2：业务失败，消息取消投递

##### UserService 中添加代码

手动抛出异常，让事务回滚。

```
/**
 * 模拟用户注册失败，咱们通过弹出异常让事务回滚，结果也会导致消息发送被取消
 *
 * @param user_id
 * @param user_name
 */
@Transactional
public void registerFail(Long user_id, String user_name) {
    this.register(user_id, user_name);
    throw new RuntimeException("故意失败!");
}


```

##### Demo11Test 添加用例

```
@Test
public void test2() {
    this.userService.registerFail(1L, "张三");
}


```

##### 运行输出

弹出了异常，信息比较多，我们截了关键的部分，如下，可以看出事务被回滚了，消息被取消投递了。

```
用户注册：[user_id:1,user_name:张三]
插入消息：MsgModel(id=1, msg=[user_id:1,user_name:张三], msg_order_id=1, status=0)
准备取消投递消息，{msg_id:1}
取消投递消息：MsgModel(id=1, msg=[user_id:1,user_name:张三], msg_order_id=1, status=0)

java.lang.RuntimeException: 故意失败!

 at com.javacode2018.tx.demo11.UserService.registerFail(UserService.java:44)
 at com.javacode2018.tx.demo11.UserService$$FastClassBySpringCGLIB$$5dd21f5c.invoke(<generated>)


```

#### 3.3.3、嵌套事务

事务发送是跟随当前所在的事务的，当前事务提交了，消息一定会被投递出去，当前事务是不，消息会被取消投递。

下面看嵌套事务的代码

##### UserService 中添加代码

注意下面方法的事务传播行为是：REQUIRES_NEW，当前如果有事务，会重启一个事务。

```
//事务传播属性是REQUIRES_NEW,会在独立的事务中运行
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void registerRequiresNew(Long user_id, String user_name) {
    this.register(user_id, user_name);
}


```

##### 添加一个类 UserService1

```
package com.javacode2018.tx.demo11;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * 公众号：路人甲Java，工作10年的前阿里P7分享Java、算法、数据库方面的技术干货！
 * <a href="http://www.itsoku.com">个人博客</a>
 */
@Component
public class UserService1 {
    @Autowired
    private UserService userService;

    @Autowired
    private MsgSender msgSender;

    //嵌套事务案例
    @Transactional
    public void nested() {
        this.msgSender.send("消息1", 2, "1");
        //registerRequiresNew事务传播属性是REQUIRES_NEW:会在一个新事务中运行
        this.userService.registerRequiresNew(1L, "张三");
        //registerFail事务传播属性是默认的，会在当前事务中运行，registerFail弹出异常会导致当前事务回滚
        this.userService.registerFail(2L, "李四");
    }
}


```

nested 是外围方法，这个方法上有 @Transactional，运行的时候会开启一个事务，内部 3 行代码：

@1：发送消息，会在当前事务中执行

@2：registerRequiresNew 事务传播行为是 REQUIRES_NEW，所以会重启一个事务

@3：registerFail 事务传播行为是默认的 REQUIRED，会参与到 nested() 开启的事务中运行，registerFail 方法内部会抛出一个异常，最终会导致外部方法事务回滚。

上面方法需要投递 3 条消息，而 @1 和 @3 投递的消息由于事务回滚会导致消息被回滚，而 @2 在独立的事务中执行，@2 的消息会投递成功，下面来看看执行结果，是不是和分析的一致。

##### Demo11Test 添加用例

```
@Test
public void test3() {
    UserService1 userService1 = this.context.getBean(UserService1.class);
    userService1.nested();
}


```

##### 运行输出

```
插入消息：MsgModel(id=1, msg=消息1, msg_order_id=1, status=0)
用户注册：[user_id:1,user_name:张三]
插入消息：MsgModel(id=2, msg=[user_id:1,user_name:张三], msg_order_id=2, status=0)
准备投递消息,{msg_id:2}
投递消息：MsgModel(id=2, msg=[user_id:1,user_name:张三], msg_order_id=2, status=0)
用户注册：[user_id:2,user_name:李四]
插入消息：MsgModel(id=3, msg=[user_id:2,user_name:李四], msg_order_id=3, status=0)
准备取消投递消息，{msg_id:1}
取消投递消息：MsgModel(id=1, msg=消息1, msg_order_id=1, status=0)
准备取消投递消息，{msg_id:3}
取消投递消息：MsgModel(id=3, msg=[user_id:2,user_name:李四], msg_order_id=3, status=0)

java.lang.RuntimeException: 故意失败!

 at com.javacode2018.tx.demo11.UserService.registerFail(UserService.java:44)


```

大家细看一下结果，和分析的是一致的。

### 3.4、小结

事务消息分 2 步走，先落库，此时消息待投递，等到事务执行完毕之后，再确定是否投递，用到的关键技术点是事务扩展接口：TransactionSynchronization，事务执行完毕之后会自动回调接口中的 afterCompletion 方法。

**遗留的一个问题：消息补偿操作**

当事务消息刚落地，此时处于待投递状态，系统刚好 down 机了，此时系统恢复之后，需要有个定时器来处理这种消息，拿着消息中的 msg_order_id 去业务库查一下订单是否存在，如果存在，则投递消息，否则取消投递，这个留给大家去实现。

4、总结
----

好了，今天的内容就到此就讲完了，我们一块来总结回顾一下，你需要重点掌握的内容。

1、消息投递的 5 种方式的推演，要熟练掌握其优缺点

2、方式 4 中事务消息的代码实现，需要大家掌握

消息服务使用频率挺高的，通常作为系统中的基础服务使用，大家可以尝试一下开发一个独立的消息服务，提供给其他服务使用。

**欢迎留言和我分享你的想法，如果有收获，也欢迎你把这篇文章分享给你的朋友，谢谢！**

5、案例源码
------

```
git地址：
https://gitee.com/javacode2018/spring-series

本文案例对应源码：
    spring-series\lesson-002-tx\src\main\java\com\javacode2018\tx\demo11


```

**路人甲 java 所有案例代码以后都会放到这个上面，大家 watch 一下，可以持续关注动态。**

6、Spring 系列
-----------

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
    
47.  [Spring 系列第 47 篇：spring 编程式事务源码解析](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937564&idx=2&sn=549f841b7935c6f5f98957e4d443f893&scene=21#wechat_redirect)
    
48.  [Spring 系列第 48 篇：@Transaction 事务源码解析](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648937715&idx=2&sn=2d8534f9788bfa4678554d858ec93ab3&scene=21#wechat_redirect)
    

7、更多好文章
-------

1.  [Java 高并发系列（共 34 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933285&idx=1&sn=f5507c251b84c3405f2fe0f7fb1da97d&chksm=88621b9bbf15928dd4c26f52b2abb0e130cde02100c432f33f0e90123b5e4b20d43017c1030e&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
2.  [MySql 高手系列（共 27 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933461&idx=1&sn=67cd31469273b68a258d963e53b56325&chksm=88621c6bbf15957d7308d81cd8ba1761b356222f4c6df75723aee99c265bd94cc869faba291c&token=1916804008&lang=zh_CN&scene=21#wechat_redirect)
    
3.  [Maven 高手系列（共 10 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933753&idx=1&sn=0b41083939980be87a61c4f573792459&chksm=88621d47bf1594516092b662c545abfac299d296e232bf25e9f50be97e002e2698ea78218828&scene=21#wechat_redirect)
    
4.  [Mybatis 系列（共 12 篇）](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933868&idx=1&sn=ed16ef4afcbfcb3423a261422ff6934e&chksm=88621dd2bf1594c4baa21b7adc47456e5f535c3358cd11ddafb1c80742864bb19d7ccc62756c&token=1400407286&lang=zh_CN&scene=21#wechat_redirect)
    
5.  [聊聊 db 和缓存一致性常见的实现方式](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933452&idx=1&sn=48b3b1cbd27c50186122fef8943eca5f&chksm=88621c72bf159564e629ee77d180424274ae9effd8a7c2997f853135b28f3401970793d8098d&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
6.  [接口幂等性这么重要，它是什么？怎么实现？](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933334&idx=1&sn=3a68da36e4e21b7339418e40ab9b6064&chksm=88621be8bf1592fe5301aab732fbed8d1747475f4221da341350e0cc9935225d41bf79375d43&token=1919005508&lang=zh_CN&scene=21#wechat_redirect)
    
7.  [泛型，有点难度，会让很多人懵逼，那是因为你没有看这篇文章！](https://mp.weixin.qq.com/s?__biz=MzA5MTkxMDQ4MQ==&mid=2648933878&idx=1&sn=bebd543c39d02455456680ff12e3934b&chksm=88621dc8bf1594de6b50a760e4141b80da76442ba38fb93a91a3d18ecf85e7eee368f2c159d3&token=799820369&lang=zh_CN&scene=21#wechat_redirect)
    

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06AibRrjQicuaJj6Mq4hmnCUlIibUvzyXLROGOKSGfz9FrjG1Cjy4bicNmFdO4yWE2ibiaQJ1F6eic95FWc9Q/640?wx_fmt=png)