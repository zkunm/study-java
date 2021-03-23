# 1、什么是 maven？为什么需要它？

### 为什么要学习 maven?

maven 还未出世的时候，我们有很多痛苦的经历。

* 痛点 1：jar 包难以寻找

* 痛点 2：jar 包依赖的问题

* 痛点 3：jar 包版本冲突问题

-  痛点 4：Jar 不方便管理

- 痛点 5：项目结构五花八门

- 痛点 6：项目的生命周期控制方式五花八门

### maven 是什么呢？

使用 maven 搭建的项目架构，都需要遵循同样的结构，java 源文件、资源文件、测试用例类文件、静态资源文件这些都是约定好的，大家都按照这个约定来，所有如果你们的项目是使用 maven 创建的，招新人来接手，如果他们懂 maven，根本不需要培训，上来就可以看懂整个项目的结构。

maven 给每个 jar 定义了唯一的标志，这个在 maven 中叫做项目的坐标，通过这个坐标可以找到你需要用到的任何版本的 jar 包。

maven 会自动解决 jar 依赖的问题，比如你用到了 a-1.0.jar，而 a-1.0.jar 依赖于 b-1.1.jar 和 c-1.5.jar，当我们通过 maven 把 a-1.0.jar 引入之后，b-1.1.jar 和 c-1.5.jar 会自动被引入进来。

maven 可以很容易的解决不同版本之间的 jar 冲突的问题。

maven 使开发者更加方便的控制整个项目的生命周期，比如：

```
mvn clear 	可以清理上次已编译好的代码
mvn compile 可以自动编译项目
mvn test 	可以自动运行所有测试用例
mvn package 可以完成打包需要的所有操作(自动包含了清理、编译、测试的过程)
```

还有更多更多好用的操作，由于 maven 使所有项目结构都是约定好的，所以这些操作都被简化为了非常简单的命令。

我们自己开发了一些工具包，需要给其他人使用时，只需要一个简单的`mvn install`命令就可以公布出去了，然后将这个 jar 的坐标告知使用者，使用者就可以找到了，根本不需要你将 jar 包传输给他。

由于 maven 项目结构都是约定好的，所以非常方便扩展，上面说的各种 maven 命令都是以插件的形式集成进来的，如果你愿意，你也可以自己开发一些 maven 插件给其他人使用，比如阿里内部自己开发的插件自动将项目发布到阿里云上面，非常方便开发发布项目。

再来看一下官方解释什么是 maven：**maven 是 apache 软件基金会组织维护的一款自动化构建工具，专注服务于 java 平台的项目构建和依赖管理**。

# 2、mvn 运行过程详解

### Maven 的运行原理详解

> 本文后面会用到`~`这个符号，先对这个符号做一下说明，这个符号表示当前用户的目录
>
> window 中默认在`C:\Users\用户名`
>
> linux root 用户默认在`/root`目录，其他用户的~ 对应`/home/用户名`
>
> 后面的文章中我们就用~ 表示用户目录，这个地方不再说明。

运行下面命令，看一下效果

![image-20201206204629493](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201206204629.png)

上面运行`mvn help:system`命令之后，好像从`https://repo.maven.apache.org`站点中在下载很多东西，最后又输出了系统所有环境变量的信息。

我们来详细看一下`mvn help:system`这个命令的运行过程：

> 1.  运行`mvn help:system`之后
>
> 2.  系统会去环境变量 PATH 对应的所有目录中寻找 mvn 命令
>
> 3.  运行 mvn 文件，也就是执行 mvn 命令
>
> 4.  通常一些软件启动的时候，会有一个启动配置文件，maven 也有，mvn 命令启动的时候会去`~/.m2`目录寻找配置文件`settings.xml`，这个文件是 mvn 命令启动配置文件，可以对 maven 进行一些启动设置（如本地插件缓存放在什么位置等等），若`~/.m2`目录中找不到`settings.xml`文件，那么会去`M2_HOME/conf`目录找这个配置文件，然后运行 maven 程序
>
> 5.  mvn 命令后面跟了一个参数：`help:sytem`，这个是什么意思呢？这个表示运行`help`插件，然后给 help 插件发送`system`命令
>
> 6.  maven 查看本地缓存目录（默认为`~/.m2`目录）寻找是否有 help 插件，如果本地没有继续下面的步骤
>
> 7.  maven 会去默认的一个站点（apache 为 maven 提供的一个网站 [repo.maven.apache.org]，这个叫中央仓库）下载 help 插件到`~/.m2`目录
>
> 8.  运行 help 插件，然后给 help 插件发送`system`指令，help 插件收到`system`指令之后，输出了本地环境变量的信息，如果系统找不到指定的插件或者给插件发送无法识别的命令，都会报错

maven 中所有的命令都是以插件的形式提供的，所以 maven 扩展也是相当容易的。

### Maven 的一些配置

**启动文件设置**

上面提到了`mvn`运行的时候，会加载启动的配置文件`settings.xml`，这个文件默认在`M2_HOME/conf`目录，一般我们会拷贝一个放在`~/.m2`目录中，前者是全局范围的配置文件，整个机器上所有用户都会受到该配置的影响，而后者是用户范围级别的，只有当前用户才会受到该配置的影响。推荐使用用户级别的，将其放在`~/.m2`目录，而不去使用全局的配置，以免影响到其他用户的使用。还有这样使用方便日后 maven 版本升级，一般情况下 maven 整个安装目录我们都不要去动，升级的时候只需要替换一下安装文件就可以了，很方便。

**配置本地缓存目录**

settings.xml 中有个`localRepository`标签，可以设置本地缓存目录，maven 从远程仓库下载下来的插件以及以后所有我们用到的 jar 包都会放在这个目录中，如下：

```
<localRepository>D:\Env\apache-maven-3.6.3\repo</localRepository>
```

# 3、maven 解决依赖问题

### 约定配置

Maven 提倡使用一个共同的标准目录结构，Maven 使用约定优于配置的原则，大家尽可能的遵守这样的目录结构，如下所示：

| 目录                                | 用处                                    |
| ----------------------------------- | --------------------------------------- |
| $(basedir)                          | 存放pom.xml和所有子目录                 |
| $(basedir)/src/main/java            | 项目java源文件                          |
| $(basedir)/src/main/resource        | 项目的资源                              |
| $(basedir)/src/test/java            | 项目的测试类                            |
| $(basedir)/src/test/resource        | 测试用的资源                            |
| $(basedir)/src/main/rwebapp/WEB-INF | web应用文件目录                         |
| $(basedir)/target                   | 打包输出目录                            |
| $(basedir)/target/classes           | 编译输出目录                            |
| $(basedir)/target/test-classes      | 测试编译输出的目录                      |
| Test.java                           | Maven指挥自动运行符合该明明规则的测试类 |
| ~/.m2/repository                    | Maven本地默认的仓库                     |

### pom 文件

当我们在项目中需要用到 maven 帮我们解决 jar 包依赖问题，帮我们解决项目中的编译、测试、打包、部署时，项目中必须要有 pom.xml 文件，这些都是依靠 pom 的配置来完成的。

POM(Project Object Model，项目对象模型) 是 Maven 工程的基本工作单元，是一个 XML 文件，包含了项目的基本信息，用于描述项目如何构件，声明项目依赖，等等。

执行任务或目标时，Maven 会在当前目录中查找 POM。它读取 POM，获取所需的配置信息，然后执行目标。

POM 中可以指定以下配置：

*   项目依赖

*   插件

*   执行目标

*   项目构件 profile

*   项目版本

*   项目开发者列表

*   相关邮件列表信息

在创建 POM 之前，我们首先需要描述项目组 (groupId)，项目的唯一 ID。

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <modelVersion>4.0.0</modelVersion>
    <groupId>com.zkunm</groupId>
    <artifactId>maven1</artifactId>
    <version>1.0-SNAPSHOT</version>
</project>
```

### maven 坐标

maven 中引入了坐标的概念，每个构件都有唯一的坐标，我们使用 maven 创建一个项目需要标注其坐标信息，而项目中用到其他的一些构件，也需要知道这些构件的坐标信息。

maven 中构件坐标是通过一些元素定义的，他们是 groupId、artifactId、version、packaging、classifier，如我们刚刚上面创建的 springboot 项目，它的 pom 中坐标信息如下：

```
<groupId>com.zkunm</groupId>
<artifactId>maven1</artifactId>
<version>1.0-SNAPSHOT</version>
<packaging>jar</packaging>
```

> goupId：定义当前构件所属的组，通常与域名反向一一对应。
>
> artifactId：项目组中构件的编号。
>
> version：当前构件的版本号，每个构件可能会发布多个版本，通过版本号来区分不同版本的构件。
>
> package：定义该构件的打包方式，比如我们需要把项目打成 jar 包，采用`java -jar`去运行这个 jar 包，那这个值为 jar；若当前是一个 web 项目，需要打成 war 包部署到 tomcat 中，那这个值就是 war，可选（jar、war、ear、pom、maven-plugin），比较常用的是 jar、war、pom，这些后面会详解。

上面接元素中，groupId、artifactId、version 是必须要定义的，packeage 可以省略，默认为 jar。

### maven 导入依赖的构件

maven 可以帮我们引入需要依赖的构件 (jar 等)，而 maven 是如何定位到某个构件的呢？

项目中如果需要使用第三方的 jar，我们需要知道其坐标信息，然后将这些信息放入 pom.xml 文件中的`dependencies`元素中：

```
<project>
    <dependencies>
        <dependency>
            <groupId></groupId>
            <artifactId></artifactId>
            <version></version>
            <type></type>
            <scope></scope>
            <optional></optional>
            <exclusions>
                <exclusion></exclusion>
                <exclusion></exclusion>
            </exclusions>
        </dependency>
    </dependencies>
</project>
```

*   dependencies 元素中可以包含多个`dependency`，每个`dependency`就表示当前项目需要依赖的一个构件的信息

*   dependency 中 groupId、artifactId、version 是定位一个构件必须要提供的信息，所以这几个是必须的

*   type：依赖的类型，表示所要依赖的构件的类型，对应于被依赖的构件的 packaging。大部分情况下，该元素不被声明，默认值为 jar，表示被依赖的构件是一个 jar 包。

*   scope：依赖的范围，后面详解

*   option：标记依赖是否可选，后面详解

*   exclusions：用来排除传递性的依赖

通常情况下我们依赖的都是一些 jar 包，所以大多数情况下，只需要提供`groupId、artifactId、version`信息就可以了。

### maven 依赖范围（scope）

**maven 用到 classpath 的地方有：编译源码、编译测试代码、运行测试代码、运行项目，这几个步骤都需要用到 classpath。**

scope 是用来控制被依赖的构件与 classpath 的关系（编译、打包、运行所用到的 classpath），scope 有以下几种值：

#### compile

编译依赖范围，如果没有指定，默认使用该依赖范围，对于编译源码、编译测试代码、测试、运行 4 种 classpath 都有效，比如上面的 spring-web。

#### test

测试依赖范围，使用此依赖范围的 maven 依赖，只对编译测试、运行测试的 classpath 有效，在编译主代码、运行项目时无法使用此类依赖。比如 junit，它只有在编译测试代码及运行测试的时候才需要。

#### provide

已提供依赖范围。表示项目的运行环境中已经提供了所需要的构件，对于此依赖范围的 maven 依赖，对于编译源码、编译测试、运行测试中 classpath 有效，但在运行时无效。比如servlet-api，这个在编译和测试的时候需要用到，但是在运行的时候，web 容器已经提供了，就不需要 maven 帮忙引入了。

#### runtime

运行时依赖范围，使用此依赖范围的 maven 依赖，对于编译测试、运行测试和运行项目的 classpath 有效，但在编译主代码时无效，比如 jdbc 驱动实现，运行的时候才需要具体的 jdbc 驱动实现

#### system

系统依赖范围，该依赖与 3 中 classpath 的关系，和 provided 依赖范围完全一致。但是，使用 system 范围的依赖时必须通过 systemPath 元素显示第指定依赖文件的路径。这种依赖直接依赖于本地路径中的构件，可能每个开发者机器中构件的路径不一致，所以如果使用这种写法，你的机器中可能没有问题，别人的机器中就会有问题，所以建议谨慎使用。

#### import

这个比较特殊，springboot 和 springcloud 中用到的比较多

**依赖范围与 classpath 的关系如下：**

| 依赖范围 | 编译源码 | 编译测试源码 | 运行测试 | 运行项目 | 示例        |
| -------- | -------- | ------------ | -------- | -------- | ----------- |
| compile  | √        | √            | √        | √        | spring-web  |
| test     |          | √            | √        |          | junit       |
| provide  | √        | √            | √        |          | servlet-api |
| runtime  |          | √            | √        | √        | jdbc        |
| system   | √        | √            | √        |          | 本地jar     |

> scope 如果对于运行范围有效，意思是指依赖的 jar 包会被打包到项目的运行包中，最后运行的时候会被添加到 classpath 中运行。如果 scope 对于运行项目无效，那么项目打包的时候，这些依赖不会被打包到运行包中。

### 依赖的传递

我们只引入了`spring-web`依赖，而 spring-web 又依赖了`spring-beans、spring-core、spring-jcl`，这 3 个依赖也被自动加进来了，这种叫做依赖的传递。

不过上面我们说的 scope 元素的值会对这种传递依赖会有影响。

假设 A 依赖于 B，B 依赖于 C，我们说 A 对于 B 是第一直接依赖，B 对于 C 是第二直接依赖，而 A 对于 C 是传递性依赖，而第一直接依赖的 scope 和第二直接依赖的 scope 决定了传递依赖的范围，即决定了 A 对于 C 的 scope 的值。

下面我们用表格来列一下这种依赖的效果，表格最左边一列表示第一直接依赖（即 A->B 的 scope 的值）, 而表格中的第一行表示第二直接依赖（即 B->C 的 scope 的值），行列交叉的值显示的是 A 对于 C 最后产生的依赖效果。

|          | compile  | test | provided | runtime  |
| -------- | -------- | ---- | -------- | -------- |
| compile  | compile  | -    | -        | runtime  |
| test     | test     | -    | -        | test     |
| provided | provided | -    | provided | provided |
| runtime  | runtime  | -    | -        | runtime  |

> 解释一下：
>
> 1.  比如 A->B 的 scope 是`compile`，而 B->C 的 scope 是`test`，那么按照上面表格中，对应第 2 行第 3 列的值`-`，那么 A 对于 C 是没有依赖的，A 对 C 的依赖没有从 B->C 传递过来，所以 A 中是无法使用 C 的
>
> 2.  比如 A->B 的 scope 是`compile`，而 B->C 的 scope 是`runtime`，那么按照上面表格中，对应第 2 行第 5 列的值为`runtime`，那么 A 对于 C 是的依赖范围是`runtime`，表示 A 只有在运行的时候 C 才会被添加到 A 的 classpath 中，即对 A 进行运行打包的时候，C 会被打包到 A 的包中
>
> 3.  大家仔细看一下，上面的表格是有规律的，当 B->C 依赖是 compile 的时候（表中第 2 列），那么 A->C 的依赖范围和 A->B 的 sope 是一样的；当 B->C 的依赖是 test 时（表中第 3 列），那么 B->C 的依赖无法传递给 A；当 B->C 的依赖是 provided（表第 4 列），只传递 A->C 的 scope 为 provided 的情况，其他情况 B->C 的依赖无法传递给 A；当 B->C 的依赖是 runtime（表第 5 列），那么 C 按照 B->C 的 scope 传递给 A

### maven 依赖调解功能

现实中可能存在这样的情况，A->B->C->Y(1.0)，A->D->Y(2.0)，此时 Y 出现了 2 个版本，1.0 和 2.0，此时 maven 会选择 Y 的哪个版本？

解决这种问题，maven 有 2 个原则：

#### 路径最近原则

上面`A->B->C->Y(1.0)，A->D->Y(2.0)`，Y 的 2.0 版本距离 A 更近一些，所以 maven 会选择 2.0。

但是如果出现了路径是一样的，如：`A->B->Y(1.0)，A->D->Y(2.0)`，此时 maven 又如何选择呢？

#### 最先声明原则

如果出现了路径一样的，此时会看 A 的 pom.xml 中所依赖的 B、D 在`dependencies`中的位置，谁的声明在最前面，就以谁的为主，比如`A->B`在前面，那么最后 Y 会选择 1.0 版本。

**这两个原则希望大家记住：路径最近原则、最先声明原则。**

### 可选依赖（optional 元素）

有这么一种情况：

```
A->B中scope:compile B->C中scope:compile
```

按照上面介绍的依赖传递性，C 会传递给 A，被 A 依赖。

假如 B 不想让 C 被 A 自动依赖，可以怎么做呢？

`dependency元素下面有个optional，是一个boolean值，表示是一个可选依赖`，B->C 时将这个值置为 true，那么 C 不会被 A 自动引入。

### 排除依赖

A 项目的 pom.xml 中

```
<dependency>
    <groupId>com.zkunm</groupId>
    <artifactId>B</artifactId>
    <version>1.0</version>
</dependency>
```

B 项目 1.0 版本的 pom.xml 中

```
<dependency>
    <groupId>com.zkunm</groupId>
    <artifactId>C</artifactId>
    <version>1.0</version>
</dependency>
```

上面 A->B 的 1.0 版本，B->C 的 1.0 版本，而 scope 都是默认的 compile，根据前面讲的依赖传递性，C 会传递给 A，会被 A 自动依赖，但是 C 此时有个更新的版本 2.0，A 想使用 2.0 的版本，此时 A 的 pom.xml 中可以这么写：

```
<dependency>
    <groupId>com.zkunm</groupId>
    <artifactId>B</artifactId>
    <version>1.0</version>
    <exclusions>
        <exclusion>
            <groupId>com.zkunm</groupId>
            <artifactId>C</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

上面使用使用 exclusions 元素排除了 B->C 依赖的传递，也就是 B->C 不会被传递到 A 中。

exclusions 中可以有多个`exclusion`元素，可以排除一个或者多个依赖的传递，声明 exclusion 时只需要写上 groupId、artifactId 就可以了，version 可以省略。

# 4、仓库详解

### Maven 寻找依赖的 jar

我们可以看到，当我们项目中需要使用某些 jar 时，只需要将这些 jar 的 maven 坐标添加到 pom.xml 中就可以了，这背后 maven 是如何找到这些 jar 的呢？

maven 官方为我们提供了一个站点，这个站点中存放了很多第三方常用的构建（jar、war、zip、pom 等等），当我们需要使用这些构件时，只需将其坐标加入到 pom.xml 中，此时 maven 会自动将这些构建下载到本地一个目录，然后进行自动引用。

上面提到的 maven 站点，我们叫做 maven 中央仓库，本地目录叫做本地仓库。

默认情况下，当项目中引入依赖的 jar 包时，maven 先在本地仓库检索 jar，若本地仓库没有，maven 再去从中央仓库寻找，然后从中央仓库中将依赖的构件下载到本地仓库，然后才可以使用，如果 2 个地方都没有，maven 会报错。

下面我们来看看什么是仓库？

### Maven 仓库

在 Maven 中，任何一个依赖、插件或者项目构建的输出，都可以称之为构件。

在 Maven 中，仓库是一个位置，这个位置是用来存放各种第三方构件的，所有 maven 项目可以共享这个仓库中的构件。

Maven 仓库能帮助我们管理构件（主要是 jar 包），它就是放置所有 jar 文件（jar、war、zip、pom 等等）的地方。

**仓库的分类**

主要分为 2 大类：

1. **本地仓库**

2. **远程仓库**

   **而远程仓库又分为：中央仓库、私服、其他公共远程仓库**

当 maven 根据坐标寻找构件的时候，会首先查看本地仓库，如果本地仓库存在，则直接使用；如果本地不存在，maven 会去远程仓库中查找，如果找到了，会将其下载到本地仓库中进行使用，如果本地和远程仓库都没有找到构件，maven 会报错，构件只有在本地仓库中存在了，才能够被 maven 项目使用。

#### 本地仓库

默认情况下，maven 本地仓库默认地址是`~/.m2/respository`目录，这个默认我们也可以在`~/.m2/settings.xml`文件中进行修改：

```xml
<localRepository>本地仓库地址</localRepository>
```

当我们使用 maven 的时候，依赖的构件都会从远程仓库下载到本地仓库目录中。

Maven 的本地仓库，在安装 Maven 后并不会创建，当我们执行第一条 maven 命令的时候本地仓库才会创建，此时会从远程仓库下载构建到本地仓库给 maven 项目使用。

需要我们注意，默认情况下，`~/.m2/settings.xml`这个文件是不存在的（`~`是指用户目录，前面的文章中有介绍过，此处不再做说明），我们需要从 Maven 安装目录中拷贝`conf/settings.xml`文件，将`M2_HOME/conf/settings.xml`拷贝到`~/.m2`目录中，然后对`~/.m2/settings.xml`进行编辑，`M2_HOME/config/settings.xml`这个文件其实也是可以使用的，不过我们不建议直接使用，这个修改可能会影响其他所有使用者，还有修改了这个文件，也不利于以后 maven 的升级，如果我们使用`~/.m2/settings.xml`，而 maven 安装目录中的配置不动，升级的时候只需要替换一下安装包就好了，所以我们建议将 maven 安装目录中的`settings.xml`拷贝到`~/.m2`中进行编辑，这个是用户级别的，只会影响当前用户。

#### 远程仓库

最开始我们使用 maven 的时候，本地仓库中的构件是空的，此时 maven 必须要提供一种功能，要能够从外部获取这些构件，这个外部就是所谓的远程仓库，远程仓库可以有多个，当本地仓库找不到构件时，可以去远程仓库找，然后放置到本地仓库中进行使用。

#### 中央仓库

由于 maven 刚安装好的时候，本地仓库是空的，此时我们什么都没有配置，去执行 maven 命令的时候，我们会看到 maven 默认执行了一些下载操作，这个下载地址就是中央仓库的地址，这个地址是 maven 社区为我们提供的，是 maven 内置的一个默认的远程仓库地址，不需要用户去配置。

这个地址在 maven 安装包的什么地方呢？

我们使用的是 3.6.3，在下面这个位置

```
apache-maven-3.6.3\lib\maven-model-builder-3.6.3.jar\org\apache\maven\model\pom-4.0.0.xml
```

在 pom-4.0.0.xml 中，如下：

```
<repositories>
    <repository>
        <id>central</id>
        <name>CentralRepository</name>
        <url>https://repo.maven.apache.org/maven2</url>
        <layout>default</layout>
        <snapshots>
            <enabled>false</enabled>
        </snapshots>
    </repository>
</repositories>
```

就是：

```
https://repo.maven.apache.org/maven2
```

可以去访问一下，如下：

![image-20201207122130567](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207122443.png)

上面站点中包含了很多常用的构建。

中央仓库有几个特点：

1.  中央仓库是由 maven 官方社区提供给大家使用的

2.  不需要我们手动去配置，maven 内部集成好了

3.  使用中央仓库时，机器必须是联网状态，需要可以访问中央仓库的地址

中央仓库还为我们提供了一个检索构件的站点：

```
https://search.maven.org/
```

非常方便我们查找需要依赖的构件。

中央仓库中包含了这个世界上大多数流行的开源 java 构件，基本上所有的 jave 开发者都会使用这个仓库，一般我们需要的第三方构件在这里都可以找到。

#### 私服

私服也是远程仓库中的一种，我们为什么需要私服呢？

如果我们一个团队中有几百个人在开发一些项目，都是采用 maven 的方式来组织项目，那么我们每个人都需要从远程仓库中把需要依赖的构件下载到本地仓库，这对公司的网络要求也比较高，为了节省这个宽带和加快下载速度，我们在公司内部局域网内部可以架设一台服务器，这台服务器起到一个代理的作用，公司里面的所有开发者去访问这个服务器，这台服务器将需要的构建返回给我们，如果这台服务器中也没有我们需要的构建，那么这个代理服务器会去远程仓库中查找，然后将其先下载到代理服务器中，然后再返回给开发者本地的仓库。

还有公司内部有很多项目之间会相互依赖，你可能是架构组的，你需要开发一些 jar 包给其他组使用，此时，我们可以将自己 jar 发布到私服中给其他同事使用，如果没有私服，可能需要我们手动发给别人或者上传到共享机器中，不过管理起来不是很方便。

**总体上来说私服有以下好处：**

1.  加速 maven 构件的下载速度

2.  节省宽带

3.  方便部署自己的构件以供他人使用

4.  提高 maven 的稳定性，中央仓库需要本机能够访问外网，而如果采用私服的方式，只需要本机可以访问内网私服就可以了

#### 其他远程仓库

中央仓库是在国外的，访问速度不是特别快，所以有很多比较大的公司做了一些好事，自己搭建了一些 maven 仓库服务器，公开出来给其他开发者使用，比如像阿里、网易等等，他们对外提供了一些 maven 仓库给全球开发者使用，在国内的访问速度相对于 maven 中央仓库来说还是快了不少。

还有一些公司比较牛，只在自己公开的仓库中发布构件，这种情况如果要使用他们的构件时，需要去访问他们提供的远程仓库地址。

#### 构建文件的布局

我们来看一下构件在仓库的文件结构中是如何组成的？

这块我们以本地仓库来做说明，远程仓库中组织构件的方式和本地仓库是一样的，以 fastjson 在本地仓库中的信息为例来做说明，如下：

```
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.70</version>
</dependency>
```

fastjson 这个 jar 的地址是：

```
~\.m2\repository\com\alibaba\fastjson\1.2.70\fastjson-1.2.70.jar
```

`~\.m2\repository\`是仓库的目录，所有本地构件都位于该目录中，我们主要看一下后面的部分，是怎么构成的。

构件所在目录的构成如下：

```
groupId+"."+artifactId+"."+版本号
```

通过上面获取一个字符串，字符串由`groupId、artifactId、版本号`之间用`.`连接，然后将这个字符串中的`.`替换为文件目录分隔符然后创建多级目录。

而构件文件名称的组成如下：

```
[artifactId][-verion][-classifier].[type]
```

上面的 fastjson-1.2.70.jar 信息如下：

```
artifactId为fastjson
version为1.2.70
classifier为空
type没有指定，默认为jar
```

所以构件文件名称为`fastjson-1.2.70jar`。

### 关于构件版本问题

平时我们开发项目的时候，打包测试，或者将自己开发的构建提供给他人使用时，中间我们反反复复的打包测试，会给使用方提供很多不稳定的版本，最终经过同事和测试反复验证修改，我们会发布一个稳定的版本。

在发布稳定版本之前，会有很多个不稳定的测试版本，我们版本我们称为快照版本，用 SNAPSHOT 表示

version 以`-SNAPSHOT`结尾的，表示这是一个不稳定的版本，这个版本我们最好只在公司内部测试的时候使用，最终发布的时候，我们需要将`-SNAPSHOT`去掉，然后发布一个稳定的版本，表示这个版本是稳定的，可以直接使用，这种稳定的版本我们叫做`release`版本。

当我们想控制构件获取的远程地址时，我们该怎么做呢？此时需要使用远程仓库的配置功能。

### Maven 中远程仓库的配置

此处我们讲解 2 种方式。

#### 方式1：pom.xml配置远程仓库

```
<repositories>
	<repository>
		<id>public</id>
		<url>https://maven.aliyun.com/repository/public</url>
	</repository>
</repositories>
```

在 repositories 元素下，可以使用 repository 子元素声明一个或者多个远程仓库。

repository 元素说明：

*   id：远程仓库的一个标识，中央仓库的 id 是`central`，所以添加远程仓库的时候，id 不要和中央仓库的 id 重复，会把中央仓库的覆盖掉

*   url：远程仓库地址

*   releases：主要用来配置是否需要从这个远程仓库下载稳定版本构建

*   snapshots：主要用来配置是否需要从这个远程仓库下载快照版本构建

releases 和 snapshots 中有个`enabled`属性，是个 boolean 值，默认为 true，表示是否需要从这个远程仓库中下载稳定版本或者快照版本的构建，一般使用第三方的仓库，都是下载稳定版本的构建。

快照版本的构建以`-SNAPSHOT`结尾，稳定版没有这个标识。

#### 方式02：镜像的方式

如果仓库 X 可以提供仓库 Y 所有的内容，那么我们就可以认为 X 是 Y 的一个镜像，通俗点说，可以从 Y 获取的构件都可以从他的镜像中进行获取。

可以采用镜像的方式配置远程仓库，镜像在`settings.xml`中进行配置，对所有使用该配置的 maven 项目起效，配置方式如下：

```
<mirrors>
	<mirror>
		<id>central</id>
		<mirrorOf>central</mirrorOf>
		<name>阿里云公共仓库</name>
		<url>https://maven.aliyun.com/repository/public</url>
	</mirror>
</mirrors>
```

mirrors 元素下面可以有多个 mirror 元素，每个 mirror 元素表示一个远程镜像，元素说明：

*   id：镜像的 id，是一个标识

*   name：镜像的名称，这个相当于一个描述信息，方便大家查看

*   url：镜像对应的远程仓库的地址

*   mirrorOf：指定哪些远程仓库的 id 使用这个镜像，这个对应 pom.xml 文件中 repository 元素的 id，就是表示这个镜像是给哪些 pom.xml 文章中的远程仓库使用的，这里面需要列出远程仓库的 id，多个之间用逗号隔开，`*`表示给所有远程仓库做镜像

这里主要对 mirrorOf 再做一下说明，上面我们在项目中定义远程仓库的时候，pom.xml 文件的 repository 元素中有个 id，这个 id 就是远程仓库的 id，而 mirrorOf 就是用来配置哪些远程仓库会走这个镜像去下载构件。

mirrorOf 的配置有以下几种:

```
<mirrorOf>*</mirrorOf>
```

> 上面匹配所有远程仓库 id，这些远程仓库都会走这个镜像下载构件

```
<mirrorOf>远程仓库1的id,远程仓库2的id</mirrorOf>
```

> 上面匹配指定的仓库，这些指定的仓库会走这个镜像下载构件

```
<mirrorOf>*,! repo1</mirrorOf>
```

> 上面匹配所有远程仓库，repo1 除外，使用感叹号将仓库从匹配中移除。

需要注意镜像仓库完全屏蔽了被镜像的仓库，所以当镜像仓库无法使用的时候，maven 是无法自动切换到被镜像的仓库的，此时下载构件会失败，这个需要了解。

# 5、私服详解

### 私服

私服也是远程仓库中的一种，我们为什么需要私服呢？

如果我们一个团队中有几百个人在开发一些项目，都是采用 maven 的方式来组织项目，那么我们每个人都需要从远程仓库中把需要依赖的构件下载到本地仓库，这对公司的网络要求也比较高，为了节省这个宽带和加快下载速度，我们在公司内部局域网内部可以架设一台服务器，这台服务器起到一个代理的作用，公司里面的所有开发者去访问这个服务器，这台服务器将需要的构件返回给我们，如果这台服务器中也没有我们需要的构件，那么这个代理服务器会去远程仓库中查找，然后将其先下载到代理服务器中，然后再返回给开发者本地的仓库。

还有公司内部有很多项目之间会相互依赖，你可能是架构组的，你需要开发一些 jar 包给其他组使用，此时，我们可以将自己 jar 发布到私服中给其他同事使用，如果没有私服，可能需要我们手动发给别人或者上传到共享机器中，不过管理起来不是很方便。

**总体上来说私服有以下好处：**

1.  加速 maven 构件的下载速度

2.  节省宽带，加速项目构建速度

3.  方便部署自己的构件以供他人使用

4.  提高 maven 的稳定性，中央仓库需要本机能够访问外网，而如果采用私服的方式，只需要本机可以访问内网私服就可以了

有 3 种专门的 maven 仓库管理软件可以用来帮助我们搭建私服：

1. Apache 基金会的 archiva

   ```
   http://archiva.apache.org/
   ```

2. JFrog 的 Artifactory

   ```
   https://jfrog.com/artifactory/
   ```

3. Sonatype 的 Nexus

   ```
   https://my.sonatype.com/
   ```

这些都是开源的私服软件，都可以自由使用。用的最多的是第三种 Nexus

### Windows10 中安装 Nexus 私服

nexus 是 java 开发的，所以运行的时候需要有 java 环境的支持。

- 安装 jdk

- 下载 nexus

> 官网包含了 windows、linux、mac 版本 nexus 安装文件。
>
> 百度网盘地址：
>
> 链接：https://pan.baidu.com/s/18g1ugpZnKDOt8KGytqkCbA 
> 提取码：1234 

1. nexus 下载地址

```
https://help.sonatype.com/repomanager3/download
```

2. 解压 latest-win64.zip

> latest-win64.zip 解压之后会产生两个文件目录 nexus-3.19.1-01 和 sonatyp-work

- 启动 nexus

cmd 中直接运行`nexus-3.19.1-01/bin/nexus.exe /run` ，如果输出中出现了下面的异常请忽略

```
java.io.UnsupportedEncodingException: Encoding GBK is not supported yet (feel free to submit a patch)
```

浏览器中打开

```
http://localhost:8081/
```

效果如下：

![image-20201207125546619](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207125546.png)

- 登录 Nexus

点击上图右上角的`Sign in`，输入用户名和密码，nexus 默认用户名是`admin`

nexus 这个版本的密码是第一次启动的时候生成的，密码位于下面的文件中：

```
安装目录/sonatype-work/nexus3/admin.password
```

登录成功后会弹出一些设置，如下：

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207125649.png)

点击`Next`，设置新的登录密码（新密码要保存好），如下：

![image-20201207125716769](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207125716.png)

点击`Next`->`Finish`完成设置。

- 其他一些常见的操作

**停止 Nexus 的命令**

启动的 cmd 窗口中按：`ctrl+c`，可以停止 Nexus。

**修改启动端口**

默认端口是 8081，如果和本机有冲突，可以在下面的文件中修改：

```
nexus-3.19.1-01\etc\nexus-default.properties
```

> nexus 使用 java 开发的 web 项目，内置了 jetty web 容器，所以可以直接运行。

### Linux 安装 Nexus 私服

- 下载安装包

百度网盘中下载 linux 版本的 nexus 安装包，选择`latest-unix.tar.gz`文件，下载地址如下：

```
链接：https://pan.baidu.com/s/18g1ugpZnKDOt8KGytqkCbA 
提取码：1234
```

将上面的安装包放在`/opt/nexus/`目录。

- 解压

```
tar -zxvf latest-unix.tar.gz
```

- 启动

```
./nexus-3.19.1-01/bin/nexus start
```

> 我上面使用的是 root 用户操作的，为了安全性，你们最好自己创建个用户来操作。

- 开放端口

- 验证效果

访问

```
http://nexus私服所在的机器ip:8081/
```

出现下面效果表示一切 ok。

![image-20201207130519416](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207130519.png)

- 登录

用户名为`admin`，密码在

```
/opt/nexus/sonatype-work/nexus3/admin.password
```

登录之后请请立即修改密码。

### Nexus 中仓库分类

前面我们说过，用户可以通过 nexus 去访问远程仓库，可以将本地的构件发布到 nexus 中，nexus 是如何支撑这些操作的呢？

nexus 中有个仓库列表，里面包含了各种各样的仓库，有我们说的被代理的第三方远程仓库，如下图：

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207130727.jpeg)

上图中是 nexus 安装好默认自带的仓库列表，主要有 3 种类型：

1.  代理仓库

2.  宿主仓库

3.  仓库组

#### 代理仓库

代理仓库主要是让使用者通过代理仓库来间接访问外部的第三方远程仓库的，如通过代理仓库访问 maven 中央仓库、阿里的 maven 仓库等等。代理仓库会从被代理的仓库中下载构件，缓存在代理仓库中以供 maven 用户使用。

我们在 nexus 中创建一个阿里云的 maven 代理仓库来看下过程如下。

Nexus 仓库列表中点击`Create repository`按钮，如下图：

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207130752.png)

进入添加页面，选择`maven2(proxy)`，这个表示`代理仓库`，如下图：

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207130755.jpeg)

输入远程仓库的信息，如下图：

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207130816.png)

```
第一个红框中输入仓库名称：maven-aliyun
第二个红框选择：Release，表示从这个仓库中下载稳定版的构件
第三个红框输入阿里云仓库地址：https://maven.aliyun.com/repository/public
```

点击底部的`Create repository`按钮，创建完成，如下图：

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207130905.jpeg)

#### 宿主仓库

宿主仓库主要是给我们自己用的，主要有 2 点作用

1.  将私有的一些构件通过 nexus 中网页的方式上传到宿主仓库中给其他同事使用

2.  将自己开发好一些构件发布到 nexus 的宿主仓库中以供其他同事使用

#### 仓库组

maven 用户可以从代理仓库和宿主仓库中下载构件至本地仓库，为了方便从多个代理仓库和宿主仓库下载构件，maven 提供了仓库组，仓库组中可以有多个代理仓库和宿主仓库，而 maven 用户只用访问一个仓库组就可以间接的访问这个组内所有的仓库，仓库组中多个仓库是有顺序的，当 maven 用户从仓库组下载构件时，仓库组会按顺序依次在组内的仓库中查找组件，查找到了立即返回给本地仓库，所以一般情况我们会将速度快的放在前面。

仓库组内部实际上是没有构件内容的，他只是起到一个请求转发的作用，将 maven 用户下载构件的请求转发给组内的其他仓库处理。

nexus 默认有个仓库组`maven-public`，如下：

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06AUwG78vXxbDgGTwiamMsBgMAns6EbDnL0UIP2NibdeQdsFrb8Vvk5UVTf9DcStNZEQB3Ry8mwLkic9Q/640?wx_fmt=png)

点击一下`maven-public`这行记录，进去看一下，如下图：

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06AUwG78vXxbDgGTwiamMsBgMheGsyps7Od7HSckjyB9brlHfhfMg2QyVZnHO60CdtTwQ8IgwGfGIqg/640?wx_fmt=png)

> 上图中第一个红框是这个仓库组对外的一个 url，我们本地的 maven 可以通过这个 url 来从仓库组中下载构件至本地仓库。
>
> 第二个红框中是这个仓库组中的成员，目前包含了 3 个仓库，第 1 个是宿主的 releases 版本仓库，第 1 个是宿主快照版本的仓库，第 3 个是代理仓库（maven 社区中央仓库的代理）。
>
> 刚才我们新增的`maven-aliyun`在左边，我们将其也加到右边的仓库成员（`Members`）列表，然后将`maven-aliyun`这个仓库放在第 3 个位置，这个仓库的速度比`maven-central`要快一些，能加速我们下载 maven 构件的速度，如下图：

![](https://mmbiz.qpic.cn/sz_mmbiz_png/xicEJhWlK06AUwG78vXxbDgGTwiamMsBgM8QYFbNuyz5IiasNcAZxn9cwrMPhU5fStJdn1WjRWU9TTrxRvzbq2bxw/640?wx_fmt=png)

### 配置本地 Maven 从 nexus 下载构件

#### 方式 1：pom.xml 的方式

本次我们就从 nexus 默认仓库组中下载构件，先获取仓库组对外的地址，点击下图中的`copy`按钮，获取仓库组的地址：

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207135524.jpeg)

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207131125.png)

修改 pom.xml，加入如下内容：

> 注意下面`url`的地址为上面复制的地址。

```
<repositories>
    <repository>
        <id>maven-nexus</id>
        <url>http://192.168.36.14:8081/repository/maven-public/</url>
    </repository>
</repositories>
```

由于 nexus 私服需要有用户名和密码登录才能访问，所以需要有凭证，凭证需要在 settings.xml 文件中配置，在`~/.m2/settings.xml`文件的`servers`元素中加入如下内容：

```
<servers>
    <server>
        <id>>maven-nexus</id>
        <username>admin</username>
        <password>admin</password>
    </server>
</servers>
```

> 注意上面的`server->id`的值和`pom.xml中repository->id`的值一致，通过这个 id 关联找到凭证的。
>
> server 元素中的 username 和 password 你们根据自己的去编辑，我这边密码设置的是 admin

#### 方式 2：镜像方式

- 第 1 处：setting.xml 的 mirrors 元素中加入如下配置：

```
<mirrors>
    <mirror>
        <id>maven-nexus</id>
        <mirrorOf>*</mirrorOf>
        <url>http://192.168.36.14:8081/repository/maven-public/</url>
    </mirror>
</mirrors>
```

> 上面`mirrorOf`配置的`*`，说明所有远程仓库都通过该镜像下载构件。
>
> url：这个为 nexus 中仓库组的地址，上面方式一中有说过。

- 第 2 处：由于 nexus 的 url 是需要用户名和密码才可以访问的，所以需要配置访问凭证，在 `~/.m2/settings.xml` 文件的 `servers` 元素中加入如下内容：

```
<servers>
    <server>
        <id>>maven-nexus</id>
        <username>admin</username>
        <password>admin</password>
    </server>
</servers>
```

> 注意上面的`server->id`的值和`mirror->id`的值需要一致，这样才能找到对应的凭证。

### 本地构件发布到私服

1.  使用 maven 部署构件至 nexus 私服

2.  手动部署第三方构件至 nexus 私服：比如我们第三方发给我们的一个包，比如短信发送商的 jar 包，这个包远程仓库是不存在的，我们要把这个包上传到私服供所有开发使用。

下面我们来看一下这两种如何操作。

#### 使用 maven 部署构件至 nexus 私服

我们创建 maven 项目的时候，会有一个 pom.xml 文件，里面有个 version 元素，这个是这个构件的版本号，默认是`1.0-SNAPSHOT`，这个以`-SNAPSHOT`结尾的表示是个快照版本，叫做`SNAPSHOT`版本，快照版本一般是不稳定的，会反复发布、测试、修改、发布。而最终会有一个稳定的可以发布的版本，是没有`-SNAPSHOT`后缀的，这个叫做`release`版本。

而 nexus 私服中存储用户的构件是使用的宿主仓库，这个我们上面也有说过，nexus 私服中提供了两个默认的宿主仓库分别用来存放`SNAPSHOT`版本和`release`版本，如下图：

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207134902.png)

上图中第 1 个红框的`maven-releases`宿主仓库用来存放用户自己 release 版本的构件。

第 2 个红框的`maven-snapshots`宿主仓库用来存放用户 snapshot 版本的构件。

上面两个仓库的地址可以点击后面的`copy`按钮获取。

1. 第一步：修改 pom.xml 配置

我们需要将本地 maven 项目的构件发布到上面宿主仓库中，需要修改项目中 pom.xml 的配置，加入下面内容：

```
<distributionManagement>
    <repository>
        <id>release-nexus</id>
        <url>http://localhost:8081/repository/maven-releases/</url>
        <name>nexus私服中宿主仓库->存放/下载稳定版本的构件</name>
    </repository>
    <snapshotRepository>
        <id>snapshot-nexus</id>
        <url>http://localhost:8081/repository/maven-snapshots/</url>
        <name>nexus私服中宿主仓库->存放/下载快照版本的构件</name>
    </snapshotRepository>
</distributionManagement>
```

> 上面 2 个 url 分别是上图中两个宿主仓库的地址。

2. 第二步：修改 settings.xml

上面地址需要登录才可以访问，所以需要配置凭证，这个需要在`~/.m2/settings.xml`中进行配置，在这个文件的`servers`元素中加入：

```
<server>
    <id>release-nexus</id>
    <username>admin</username>
    <password>admin</password>
</server>
<server>
    <id>snapshot-nexus</id>
    <username>admin</username>
    <password>admin</password>
</server>
```

> 注意上面第 1 个`server->id`的值需要和 pom.xml 中的`distributionManagement->repository->id`的值一致。
>
> 第 2 个`server->id`的值需要和 pom.xml 中的`distributionManagement->snapshotRepository->id`的值一致。

3. 第三步：执行 `mvn deploy` 命令

执行这个命令的时候，会对构件进行打包，然后上传到私服中。

#### 手动部署构件至 nexus 私服

手动上传只支持发布稳定版本的构件，操作过程如下图：

登录 nexus，按照下图的步骤依次点击：

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207135254.png)

图中第一行`maven-releases`宿主仓库就是存放用户自己构件的仓库，点击上图中列表中的第一行，进入上传页面，如下图：

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207135302.png)

上面页面中点击`Browse`选择本地的构件，然后输入其他坐标信息，点击`Upload`完成上传操作。

# 6、生命周期插件详解

### Properties 的使用

项目 pom.xml 中，有下面这样一段依赖：

```
<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-core</artifactId>
        <version>5.2.1.RELEASE</version>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-beans</artifactId>
        <version>5.2.1.RELEASE</version>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-aop</artifactId>
        <version>5.2.1.RELEASE</version>
    </dependency>
</dependencies>
```

大家看一下上面的配置，有没有什么问题？

他们的 groupId 和 version 都是一样的，程序员面对与重复的代码，需要提取，如果是 java 代码中，我们可以将同样的代码或者变量值，提取成方法或者变量，做到重用，方便维护。

那么 maven 的 pom.xml 中也支持这么做：

```
<properties>
    <spring.group>org.springframework</spring.group>
    <spring.version>5.2.1.RELEASE</spring.version>
</properties>
<dependencies>
    <dependency>
        <groupId>${spring.group}</groupId>
        <artifactId>spring-core</artifactId>
        <version>${spring.version}</version>
    </dependency>
    <dependency>
        <groupId>${spring.group}</groupId>
        <artifactId>spring-beans</artifactId>
        <version>${spring.version}</version>
    </dependency>
    <dependency>
        <groupId>${spring.group}</groupId>
        <artifactId>spring-aop</artifactId>
        <version>${spring.version}</version>
    </dependency>
</dependencies>
```

`properties`位于 pom.xml 中的，是`project`元素的子元素，用户可以在`properties`中自定义一些用户属性，然后可以在其他地方使用`${属性名称}`这种方式进行引用。

### 生命周期

我们开发一个项目的时候，通常有这些环节：创建项目、编写代码、清理已编译的代码、编译代码、执行单元测试、打包、集成测试、验证、部署、生成站点等，这些环节组成了项目的生命周期，这些过程也叫做项目的**构建过程**，几乎所有的项目都由这些环节中的其中几个，创建项目和编写代码是我们程序员需要多参与的，其他的都可以做成自动化的方式。

用过 ant 的朋友回忆一下，在 maven 出现以前，开发人员每天都在对项目进行清理、编译、执行单元测试、打包、部署等操作，虽然大家都在做这些工作，但是没有一个统一的标准，项目和项目之间，公司和公司之间，大多数都是各写各的，写法是千奇百怪，能满足自身需求就可以了，但是换个项目就得从头再来，这些操作又需要重新编写脚本。

而 maven 出来之后，项目生命周期中的这些环节都被简化了，被规范化了，maven 出现之前，项目的结构没有一个统一的标准，所以生命周期中各个环节对应的自动化脚本也是各种各样，而 maven 约定好了项目的结构，源码的位置、资源文件的位置、测试代码的位置、测试用到的资源文件的位置、静态资源的位置、打包之后文件的位置等，这些都是 maven 约定好的，所以清理代码用一个命令`mvn clean`就可以完成，不需要我们去配置清理的目标目录；用`mvn compile`命令就可以完成编译的操作；用`mvn test`就可以自动运行测试用例；用`mvn package`就可以将项目打包为`jar、war`格式的包，能够如此简单，主要还是 maven 中约定大于配置的结果。

**maven 中生命周期详解**

maven 将项目的生命周期抽象成了 3 套生命周期，每套生命周期又包含多个阶段，每套中具体包含哪些阶段是 maven 已经约定好的，但是每个阶段具体需要做什么，是用户可以自己指定的。

maven 中定义的 3 套生命周期：

1.  **clean 生命周期**

2.  **default 生命周期**

3.  **site 生命周期**

上面这 3 套生命周期是相互独立的，没有依赖关系的，而每套生命周期中有多个阶段，每套中的多个阶段是有先后顺序的，并且后面的阶段依赖于前面的阶段，而用户可以直接使用`mvn`命令来调用这些阶段去完成项目生命周期中具体的操作，命令是：

```
mvn 生命周期阶段
```

> **通俗点解释：**
>
> maven 中的 3 套生命周期相当于 maven 定义了 3 个类来解决项目生命周期中需要的各种操作，每个类中有多个方法，这些方法就是指具体的阶段，方法名称就是阶段的名称，每个类的方法是有顺序的，当执行某个方法的时候，这个方法前面的方法也会执行。具体每个方法中需要执行什么，这个是通过插件的方式让用户去配置的，所以非常灵活。
>
> 用户执行`mvn 阶段名称`就相当于调用了具体的某个方法。

#### clean 生命周期

clean 生命周期的目的是清理项目，它包含三个阶段：

| 生命周期阶段 | 描述                                  |
| ------------ | ------------------------------------- |
| pre-clean    | 执行一些需要在clean之前完成的工作     |
| clean        | 基础所有上一次构建生成的文件          |
| post-clean   | 执行一些需要在clean之后立刻完成的工作 |

用户可以通过`mvn pre-clean`来调用 clean 生命周期中的`pre-clean`阶段需要执行的操作。

调用`mvn post-clean`会执行上面 3 个阶段所有的操作，上文中有说过，每个生命周期中的后面的阶段会依赖于前面的阶段，当执行某个阶段的时候，会先执行其前面的阶段。

#### default 生命周期

这个是 maven 主要的生命周期，主要被用于构建应用，包含了 23 个阶段。

![image-20201207141841776](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207141841.png)

#### site 生命周期

site 生命周期的目的是建立和发布项目站点，Maven 能够基于 pom.xml 所包含的信息，自动生成一个友好的站点，方便团队交流和发布项目信息。主要包含以下 4 个阶段：

![image-20201207141915436](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207141915.png)

#### mvn 命令和生命周期

从命令行执行 maven 任务的最主要方式就是调用 maven 生命周期的阶段，需要注意的是，每套生命周期是相互独立的，但是每套生命周期中阶段是有前后依赖关系的，执行某个的时候，会按序先执行其前面所有的。

mvn 执行阶段的命令格式是：

```
mvn 阶段1 [阶段2] [阶段n]
```

**mvn clean**

该命令是调用 clean 生命周期的 clean 阶段，实际执行的阶段为 clean 生命周期中的 pre-clean 和 clean 阶段。

**mvn test**

该命令调用 default 生命周期的 test 阶段，实际上会从 default 生命周期的第一个阶段（`validate`）开始执行一直到`test`阶段结束。这里面包含了代码的编译，运行测试用例。

**mvn clean install**

这个命令中执行了两个阶段：`clean`和`install`，从上面 3 个生命周期的阶段列表中找一下，可以看出`clean`位于`clean`生命周期的表格中，`install`位于`default`生命周期的表格中，所以这个命令会先从`clean`生命周期中的`pre-clean`阶段开始执行一直到`clean`生命周期的`clean`阶段；然后会继续从`default`生命周期的`validate`阶段开始执行一直到 default 生命周期的`install`阶段。

这里面包含了清理上次构建的结果，编译代码，测试，打包，将打好的包安装到本地仓库。

**mvn clean deploy**

这个命令也比较常用，会先按顺序执行`clean`生命周期的`[pre-clean,clean]`这个闭区间内所有的阶段，然后按序执行`default`生命周期的`[validate,deploy]`这个闭区间内的所有阶段（也就是`default`生命周期中的所有阶段）。这个命令内部包含了清理上次构建的结果、编译代码、运行单元测试、打包、将打好的包安装到本地仓库、将打好的包发布到私服仓库。

### Maven 插件

maven 插件主要是为 maven 中生命周期中的阶段服务的，maven 中只是定义了 3 套生命周期，以及每套生命周期中有哪些阶段，具体每个阶段中执行什么操作，完全是交给插件去干的。

maven 中的插件就相当于一些工具，比如编译代码的工具，运行测试用例的工具，打包代码的工具，将代码上传到本地仓库的工具，将代码部署到远程仓库的工具等等，这些都是 maven 中的插件。

插件可以通过`mvn`命令的方式调用直接运行，或者将插件和 maven 生命周期的阶段进行绑定，然后通过`mvn 阶段`的方式执行阶段的时候，会自动执行和这些阶段绑定的插件。

#### 插件目标

maven 中的插件以 jar 的方式存在于仓库中，和其他构件是一样的，也是通过坐标进行访问，每个插件中可能为了代码可以重用，一个插件可能包含了多个功能，比如编译代码的插件，可以编译源代码、也可以编译测试代码；**插件中的每个功能就叫做插件的目标（Plugin Goal），每个插件中可能包含一个或者多个插件目标（Plugin Goal）**。

**目标参数**

插件目标是用来执行任务的，那么执行任务肯定是有参数配的，这些就是目标的参数，每个插件目标对应于 java 中的一个类，参数就对应于这个类中的属性。

**列出插件所有目标**

```
mvn 插件goupId:插件artifactId[:插件version]:help
```

> 上面插件前缀的先略过，我们先看第一种效果。

```
mvn org.apache.maven.plugins:maven-clean-plugin:help
```

 ![image-20201207143134669](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207143134.png)

>上面列出了`maven-clean-plugin`这个插件所有的目标，有 2 个，分别是`clean:clean、clean:help`，分号后面的部分是目标名称，分号前面的部分是插件的前缀，每个目标的后面包含对这个目标的详细解释说明，关于前缀的后面会有详细介绍。

**查看插件目标参数列表**

```
mvn 插件goupId:插件artifactId[:插件version]:help -Dgoal=目标名称 -Ddetail
```

> 上面命令中的`-Ddetail`用户输出目标详细的参数列表信息，如果没有这个，目标的参数列表不会输出出来，看效果。

```
mvn org.apache.maven.plugins:maven-clean-plugin:help -Dgoal=help -Ddetail
```

![image-20201207143227753](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207143227.png)

上面列出了`clean`插件的`help`目标的详细参数信息。

注意上面参数详细参数说明中有`Expression: ${xxx}`这样的部分，这种表示给这个运行的目标传参，可以通过`mvn -Dxxx`这种方式传参，`xxx`为`${xxx}`中的`xxx`部分，这个`xxx`有时候和目标参数的名称不一致，所以这点需要注意，运行带参数的目标，看一下效果：

```
mvn org.apache.maven.plugins:maven-clean-plugin:help -Dgoal=help -Ddetail=false
```

![image-20201207143250010](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207143250.png)

上面传了一个`detail=false`，上面未输出目标的详细参数信息。

**命令行运行插件**

```
mvn 插件goupId:插件artifactId[:插件version]:插件目标 [-D目标参数1] [-D目标参数2] [-D目标参数n]mvn 插件前缀:插件目标  [-D目标参数1] [-D目标参数2] [-D目标参数n]
```

```
<dependency>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>2.12.4</version>
</dependency>
```

我们看一下这个插件有哪些目标：

```
mvn org.apache.maven.plugins:maven-surefire-plugin:help
```

![image-20201207143831331](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207143831.png)

> maven-surefire-plugin 插件有 2 个目标`help`和`test`，描述中可以看出`test`目标是用来运行测试用例的。

我们看一下`test`目标对应的参数列表：

> test 目标对应的参数太多，我们只列出了部分参数，如下：

```
mvn org.apache.maven.plugins:maven-surefire-plugin:help -Dgoal=test -Ddetail=true
```

![image-20201207144008662](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207144008.png)

> 看一下`skip`这个参数说明，这个参数默认是 false，如果设置为`true`的时候，项目将跳过`测试代码的编译和测试用例的执行`，可以`maven.test.skip`这个属性来进行命令行传参，将其传递给`test`目标的`skip`属性，这个通过`-D`传递的参数名称就和目标参数名称不一样了，所以需要注意`-D`后面并不一定是参数名称。

**插件传参的 2 种方式**

刚才上面讲了一种通过`-D`后面跟用户属性的方式给用户传参，还有一种方式，在 pom.xml 中`properties`的用户自定义属性中进行配置，如下：

修改项目的 pom.xml，`properties`中加入：

```
<maven.test.skip>true</maven.test.skip>
```

**获取插件目标详细描述信息的另外一种方式**

```
mvn help:describe -Dplugin=插件goupId:插件artifactId[:插件version] -Dgoal=目标名称 -Ddetail
```

> 上面这个命令调用的是 help 插件的`describe`这个目标，这个目标可以列出其他指定插件目标的详细信息，看效果：

```
mvn help:describe -Dplugin=org.apache.maven.plugins:maven-surefire-plugin -Dgoal=test -Ddetail
```

可以拿这种和上面获取插件目标参数详情列表对比一下，上面这个更详细一些，参数说明中多了一行`User property: 属性名称`，这个属性名称可以通过两种方式传递：

1.  mvn 命令`-D属性名称`的方式传递

2.  pom.xml 中`properties`中定义的方式指定。

#### 插件前缀

运行插件的时候，可以通过指定插件坐标的方式运行，但是插件的坐标信息过于复杂，也不方便写和记忆，所以 maven 中给插件定义了一些简捷的插件前缀，可以通过插件前缀来运行指定的插件。

可以通过下面命令查看到插件的前缀：

```
mvn help:describe -Dplugin=插件goupId:插件artifactId[:插件version]
```

示例效果：

```
mvn help:describe -Dplugin=org.apache.maven.plugins:maven-surefire-plugin
```

> 输出中的`Goal Prefix:`部分对应的就是插件的前缀，上面这个插件的前缀是`surefire`。

我们使用前缀来运行一下插件感受一下效果：

```
mvn surefire:test
```

> 上面通过别名来运行插件`maven-surefire-plugin`的`test`目标，是不是简洁了很多。

上面用了很多`mvn help:`这个命令，这个调用的是`maven-help-plugin`插件的功能，`help`是插件的前缀，它的坐标是：

```
<dependency>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-help-plugin</artifactId>
    <version>3.2.0</version>
</dependency>
```

#### 插件和生命周期阶段绑定

maven 只是定义了生命周期中的阶段，而没有定义每个阶段中具体的实现，这些实现是由插件的目标来完成的，所以需要将阶段和插件目标进行绑定，来让插件目标帮助生命周期的阶段做具体的工作，生命周期中的每个阶段支持绑定多个插件的多个目标。

**当我们将生命周期中的阶段和插件的目标进行绑定的时候，执行`mvn 阶段`就可以执行和这些阶段绑定的`插件目标`。**

#### maven 内置插件以及绑定

maven 为了让我们不用做任何配置就可以实现一些项目的构建操作，比如运行`mvn clean`就可以帮我们清理代码，运行`mvn install`就可以将构件安装到本地仓库，所以 maven 帮我们做了一些事情，maven 内部已经提供了很多默认的插件，而将一些阶段默认和这些插件阶段绑定好了，所以我们不用做任何配置就可以执行清理代码、编译代码、测试、打包、安装到本地仓库、上传到远程仓库等阶段的操作，是因为 maven 已经默认给这些阶段绑定好了插件目标，所以不需要我们再去配置，就直接可以运行，这些都是 maven 内置绑定帮我们做的事情，我们来看看 maven 有哪些内置绑定。

##### maven 内置绑定

**clean 生命周期阶段与插件绑定关系**

![image-20201207145020316](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207145020.png)

> clean 周期中只有 clean 阶段默认绑定了`maven-clean-plugin`插件的`clean`目标。`maven-clean-plugin`插件的`clean`目标作用就是删除项目的输出目录。

**default 生命周期阶段与插件绑定关系**

default 生命周期中有 23 个阶段，我只列出有默认绑定的，其他的没有列出的没有绑定任何插件，因此没有任何实际的行为。

![image-20201207145054532](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207145054.png)

**site 生命周期阶段与插件绑定关系**

![image-20201207145110919](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207145111.png)

##### 自定义绑定

除了默认绑定的一些操作，我们自己也可以将一些阶段绑定到指定的插件目标上来完成一些操作，这种自定义绑定让 maven 项目在构件的过程中可以执行更多更丰富的操作。

常见的一个案例是：创建项目的源码 jar 包，将其安装到仓库中，内置插件绑定关系中没有涉及到这一步的任务，所以需要用户自己配置。

插件`maven-source-plugin`的`jar-no-fork`可以帮助我们完成该任务，我们将这个目标绑定在`default`生命周期的`verify`阶段上面，这个阶段没有任何默认绑定，`verify`是在测试完成之后并将构件安装到本地仓库之前执行的阶段，在这个阶段我们生成源码，配置如下：

在项目中的`pom.xml`加入如下配置：

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-source-plugin</artifactId>
            <version>3.2.0</version>
            <executions>
                <!-- 使用插件需要执行的任务 -->
                <execution>
                    <!-- 任务id -->
                    <id>attach-source</id>                    
                    <goals>
                        <!-- 任务中插件的目标，可以指定多个 -->
                        <goal>jar-no-fork</goal>
                    </goals>
                    <!-- 绑定的阶段 -->
                    <phase>verify</phase>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

> 注意上面配置的`attach-source`，后面输出中会有。
>
> id：任务的 id，需唯一，如果不指定，默认为`default`。
>
> 每个插件的配置在 pom.xml 的`plugins`元素中只能写一次，否则会有警告。

运行下面命令：

```
mvn install
```

最后有个输出如下：

![image-20201207150329719](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207150329.png)

可以看出调用了我们配置的插件生成源码 jar，上面的括号中的`attach-source`就是`pom.xml`中配置的任务 id。

最后有个输出：

![image-20201207150350389](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207150350.png)

可以看到将源码安装到本地仓库了。

有些插件的目标默认会绑定到一些生命周期的阶段中，那么如果刚好插件默认绑定的阶段和上面配置的一致，那么上面`phase`元素可以不写了，那么怎么查看插件的默认绑定呢？

```
mvn help:describe -Dplugin=插件goupId:插件artifactId[:插件version] -Dgoal=目标名称 -Ddetail
```

我们看一下插件`source`的`jar-no-fork`目标默认的绑定：

```
mvn help:describe -Dplugin=source -Dgoal=jar-no-fork -Ddetail
```

![image-20201207150746880](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207150746.png)

上面输出中有个`Bound to phase: package`，表示默认绑定在了`package`阶段上。

我们知道 3 套生命周期的运行时没有依赖的，但是每套中的阶段是有先后顺序的，运行某个阶段的时候，会先执行他前面所有的阶段。清理代码使用的是`clean`周期中的`clean`阶段，编译代码用的是`default`周期中的`compile`阶段，当直接运行`mvn compile`编译代码的时候并不会去清理代码，编译代码的时候若发现文件没有变动，会跳过没有变化的文件进行编译。如果我们想每次编译之前强制先清理代码，我们经常这么写：

```
mvn clean compile
```

我们刚才学了自定义绑定，我们可以在`default`生命周期的第一个阶段`validate`绑定清理代码的插件，那我们来通过自定义绑定来实现一下，`project->build->plugins`元素中加入下面配置：

```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-clean-plugin</artifactId>
    <version>2.5</version>
    <executions>
    	<!--使用插件需要执行的任务-->
        <execution>
        	<!--任务中插件的目标，可以指定多个-->
            <id>clean-target</id>
            <goals>
                <goal>clean</goal>
            </goals>
            <!--绑定的阶段-->
            <phase>validate</phase>
        </execution>
    </executions>
</plugin>
```

#### POM.xml 插件配置详解

* 插件目标共享参数配置

`build->plugins->plugin`中配置：

```xml
<!--插件参数配置，对插件中所有的目标起效-->
<configuration><目标参数名>参数值</目标参数名></configuration>
```

> `configuration`节点下配置目标参数的值，节点名称为目标的参数名称，上面这种配置对当前插件的所有目标起效，也就是说这个插件中所有的目标共享此参数配置。

```
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-surefire-plugin</artifactId>
            <version>2.12.4</version>
            <!-- 插件参数配置，对插件中所有的目标起效 -->
            <configuration>
                <skip>true</skip>
            </configuration>
        </plugin>
    </plugins>
</build>
```

跳过测试已经讲了 3 种了：

```
1. mvn -Dmaven.test.skip=tue
2. properties中配置<maven.test.skip>true</maven.test.skip>
3. build中配置插件参数的方式
```

上面这个配置参数方式对当前插件的所有目标有效，如果想对指定的目标进行配置呢，用下面的方式。

* 插件目标参数配置

`project->build->plugins->plugin->executions->execution`元素中进行配置，如下：

```xml
<!-- 这个地方配置只对当前任务有效 --><configuration><目标参数名>参数值</目标参数名></configuration>
```

> 上面这种配置常用于自定义插件绑定，只对当前任务有效。

感受一下效果，将 pom.xml 中的 build 元素改为下面内容：

```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>2.12.4</version>
    <executions>
        <execution>
            <goals>
                <goal>test</goal>
                <goal>help</goal>
            </goals>
            <configuration>
                <skip>true</skip>
            </configuration>
            <phase>pre-clean</phase>
        </execution>
    </executions>
</plugin>
```

> 上面自定义了一个绑定，在 clean 周期的`pre-clean`阶段绑定了插件`maven-surefire-plugin`的两个目标`test和help`，`execution`元素没有指定`id`，所以默认 id 是`default`。

#### 获取 maven 插件信息

上面我们介绍了，可以通过下面命令获取插件详细介绍信息

```
mvn help:describe -Dplugin=插件goupId:插件artifactId[:插件version] -Dgoal=目标名称 -Ddetail
mvn help:describe -Dplugin=插件前缀 -Dgoal=目标名称 -Ddetail
```

更多 maven 插件的帮助文档可以参考 maven 的官方网站，上面有详细的介绍，建议大家去看看，地址：

```
http://maven.apache.org/plugins/
```

![](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207152604.jpeg)

#### 插件解析机制

为了方便用户使用和配置插件，maven 不需要用户提供完整的插件坐标信息，就可以解析到正确的插件，不过我建议使用插件配置的时候最好还是配置完整的坐标信息，不然不利于新人的理解和问题的排查。

##### 插件仓库

与其他 maven 构件一样，插件构件也是基于坐标存储在 maven 仓库中，有需要的时候，maven 会从本地查找插件，如果不存在，则到远程仓库查找，找到了以后下载到本地仓库，然后使用。

pom.xml 中可以配置依赖的构件的仓库地址，如下：

```
<repositories>
    <repository>
        <id>maven-nexus</id>
        <url>http://localhost:8081/repository/maven-public/</url>
        <releases>
            <enabled>true</enabled>
        </releases>
        <snapshots>
            <enabled>true</enabled>
        </snapshots>
    </repository>
</repositories>
```

但是插件仓库的配置和这个有一点不一样，插件的是在`pluginRepositories->pluginRepository`元素中配置的，如下：

```
<pluginRepositories>
    <pluginRepository>
        <id>myplugin-repository</id>
        <url>http://repo1.maven.org/maven2/</url>
        <releases>
            <enabled>true</enabled>
        </releases>
    </pluginRepository>
</pluginRepositories>
```

##### 插件的默认 groupId

在 pom.xml 中配置插件的时候，如果是官方的插件，可以省略`groupId`。

```
<plugin>
	<artifactId>maven-compiler-plugin</artifactId>
    <version>3.1</version>
    <configuration>
    	<compilerVersion>1.8</compilerVersion>
    	<source>1.8</source>
    	<target>1.8</target>
    </configuration>
</plugin>
```

> 上面用到了`maven-compiler-plugin`，这个插件是编译代码的，是 maven 官方提供的插件，我们省略了`groupId`。
>
> 上面这个插件用于编译代码的，编译代码的时候需要指定编译器的版本，源码的版本，目标代码的版本，都是用的是 1.8。
>
> 在`properties`中有几个属性值是 1.8 的配置，这几个值默认会被`maven-compiler-plugin`这个插件的上面 3 个参数获取，具体可以去看一下这个插件`compile`目标的参数说明。

上面 pom.xml 省略了插件的 groupId 配置，如下：

```
<groupId>org.apache.maven.plugins</groupId>
```

maven 在解析该插件的时候，会自动给这个插件补上默认的官方的 groupId，所以可以正常运行

##### 插件前缀的解析

前面说过了使用 mvn 命令调用插件的时候，可以使用插件的前缀来代替繁琐的插件坐标的方式，那么 maven 是如何根据插件的前缀找到对应的插件的呢？

插件前缀与插件 groupId:artifactId 是一一对应的关系，这个关系的配置存储在仓库的元数据中，元数据位于下面 2 个 xml 中：

```
~/.m2/repository/org/apache/maven/plugins/maven-metadata-central.xml
```

也可以通过在`settings.xml`中配置，让 maven 检查其他 grouId 上的插件元数据中前缀和插件关系的配置，如下：

```
<settings>
    <pluginGroups>
        <pluginGroup>com.your.plugins</pluginGroup>
    </pluginGroups>
</settings>
```

> pluginGroups 中有多个 pluginGroup，可以配置你自己插件的元数据所在的 groupId，然后可以通过前缀来访问你自己的插件元数据目录

#### 查看项目最终 pom.xml 文件

我们的 pom.xml 默认会继承 maven 顶级的一个父类 pom.xml，顶级的 pom.xml 中指定了很多默认的配置，如生命周期中的阶段和很多插件的绑定，这些如果我们想看到，到哪里看呢？

`mvn`命令在项目中执行的时候，我们的 pom.xml 和父类的 pom.xml 最终会进行合并，当我们的 pom.xml 写的比较复杂的时候，最终合并之后是什么效果呢，我们可以通过下面这个命令查看：

```
mvn help:effective-pom
```

```
mvn help:effective-pom > 1.xml
```

# 7、聚合、继承、单继承问题详解

### 聚合

maven 聚合需要创建一个新的 maven 项目， 用来管理其他的 maven 构件模块，新的 maven 项目中加入如下配置：

```
<modules>
    <module>模块1</module>
    <module>模块2</module>
    <module>模块n</module>
</modules>
<package>pom</package>
```

> 新的项目中执行任何`mvn`命令，都会`modules`中包含的所有模块执行同样的命令，而被包含的模块不需要做任何特殊的配置，正常的 maven 项目就行。
>
> 注意上面的`module`元素，这部分是被聚合的模块`pom.xml`所在目录的相对路径。
>
> package 的值必须为 pom，这个需要注意。

聚合的功能中，聚合模块的 pom.xml 中通过`modules->module`来引用被聚合的模块，被聚合的模块是不用感知自己被聚合了

### 继承

操作分为 3 步骤：

1. 创建一个父 maven 构件，将依赖信息放在 pom.xml 中

   ```
   <dependencies>
       <dependency>依赖的构件的坐标信息</dependency>
       <dependency>依赖的构件的坐标信息</dependency>
       <dependency>依赖的构件的坐标信息</dependency>
   </dependencies>
   ```

2. 将父构件的 package 元素的值置为 pom

   ```
   <packaging>pom</packaging>
   ```

3. 在子构件的 pom.xml 引入父构件的配置：

   ```
   <parent>
       <groupId>父构件groupId</groupId>
       <artifactId>父构件artifactId</artifactId>
       <version>父构件的版本号</version>
       <relativePath>父构件pom.xml路径</relativePath>
   </parent>
   ```

> relativePath 表示父构件 pom.xml 相对路径，默认是`../pom.xml`，所以一般情况下父子结构的 maven 构件在目录结构上一般也采用父子关系。

#### relativePath 元素

正确的设置`relativePath`是非常重要的，这个需要注意，子模块中执行`mvn`命令的时候，会去找父`pom.xml`的配置，会先通过`relativePath`指定的路径去找，如果找不到，会尝试通过坐标在本地仓库进行查找，如果本地找不到，会去远程仓库找，如果远程仓库也没有，会报错。

#### 可以通过继承的元素有以下这些

*   groupId：项目组 ID，项目坐标的核心元素

*   version：项目版本，项目坐标的核心元素

*   description：项目的描述信息

*   organization：项目的组织信息

*   inceptionYear：项目的创始年份

*   url：项目的 url 地址

*   developers：项目的开发者信息

*   contributors：项目的贡献者信息

*   distributionManagement：项目的部署配置信息

*   issueManagement：项目的缺陷跟踪系统信息

*   ciManagement：项目的持续集成系统信息

*   scm：项目的版本控制系统信息

*   mailingLists：项目的邮件列表信息

*   properties：自定义的 maven 属性配置信息

*   dependencyManagement：项目的依赖管理配置

*   repositories：项目的仓库配置

*   build：包括项目的源码目录配置、输出目录配置、插件管理配置等信息

*   reporting：包括项目的报告输出目录配置、报告插件配置等信息

### 依赖管理 (dependencyManagement)

大家是否发现了，上面的继承存在的一个问题，如果我在新增一个子构件，都会默认从父构件中继承依赖的一批构建，父 pom.xml 中配置的这些依赖的构建可能是其他项目不需要的，可能某个子项目只是想使用其中一个构件，但是上面的继承关系却把所有的依赖都给传递到子构件中了，这种显然是不合适的。

maven 中也考虑到了这种情况，可以使用`dependencyManagement`元素来解决这个问题。

maven 提供的 dependencyManagement 元素既能让子模块继承到父模块的依赖配置，又能保证子模块依赖使用的灵活性，**在 dependencyManagement 元素下声明的依赖不会引入实际的依赖，他只是声明了这些依赖，不过它可以对`dependencies`中使用的依赖起到一些约束作用。**

```
mvn dependency:tree
```

> 父 pom.xml 中 dependencyManagement 依赖的构建不会被子模块依赖进去。

子模块如果想用到这些配置，可以`dependencies`进行引用，引用之后，依赖才会真正的起效。

在在 3 个子模块的 pom.xml 中加入下面配置：

```
<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.mybatis</groupId>
        <artifactId>mybatis-spring</artifactId>
    </dependency>
</dependencies>
```

dependencyManagement 不会引入实际的依赖，只有在子类中使用dependency来引入父dependencyManagement声明的依赖之后，依赖的构建才会被真正的引入。

使用 dependencyManagement 来解决继承的问题，子 pom.xml 中只用写groupId,artifactId就可以了，其他信息都会从父dependencyManagement中声明的依赖关系中传递过来，通常我们使用这种方式将所有依赖的构建在父 pom.xml 中定义好，子构件中只需要通过groupId,artifactId就可以引入依赖的构建，而不需要写version，可以很好的确保多个子项目中依赖构件的版本的一致性，对应依赖构件版本的升级也非常方便，只需要在父 pom.xml 中修改一下就可以了。

### 单继承问题

#### 存在的问题及解决方案

上面讲解了 dependencyManagement 的使用，但是有个问题，只有使用继承的时候，dependencyManagement 中声明的依赖才可能被子 pom.xml 用到，如果我的项目本来就有父 pom.xml 了，但是我现在想使用另外一个项目 dependencyManagement 中声明的依赖，此时我们怎么办？这就是单继承的问题，这种情况在 spring-boot、spring-cloud 中会遇到

当我们想在项目中使用另外一个构件中 dependencyManagement 声明的依赖，而又不想继承这个项目的时候，可以在我们的项目中使用加入下面配置：

```
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.zkunm</groupId>
            <artifactId>zkunm-parent</artifactId>
            <version>1.0-SNAPSHOT</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
        <dependency>构件2</dependency>
        <dependency>构件3</dependency>
        <dependency>构件n</dependency>
    </dependencies>
</dependencyManagement>
```

上面这个配置会将zkunm-parent`构件中`dependencyManagement`元素中声明的所有依赖导入到当前 pom.xml 的`dependencyManagement中，相当于把下面部分的内容：

```
<dependency>
    <groupId>com.javacode2018</groupId>
    <artifactId>javacode2018-parent</artifactId>
    <version>1.0-SNAPSHOT</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

替换成了`zkunm-parent/pom.xml`中 dependencyManagement 元素内容，替换之后变成：

```
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-web</artifactId>
            <version>5.2.1.RELEASE</version>
        </dependency>
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis-spring</artifactId>
            <version>2.0.3</version>
        </dependency>
        <dependency>构件2</dependency>
        <dependency>构件3</dependency>
        <dependency>构件n</dependency>
    </dependencies>
</dependencyManagement>
```

### 插件管理 (pluginManagement)

maven 中提供了 dependencyManagement 来解决继承的问题，同样也提供了解决插件继承问题的`pluginManagement`元素，在父 pom 中可以在这个元素中声明插件的配置信息，但是子 pom.xml 中不会引入此插件的配置信息，只有在子 pom.xml 中使用`plugins->plugin`元素正在引入这些声明的插件的时候，插件才会起效，子插件中只需要写`groupId、artifactId`，其他信息都可以从父构件中传递过来。

### 聚合与继承的关系

前面已经详解了聚合和继承，想必大家对这块也有了自己的理解。

聚合主要是为了方便多模块快速构建。

而继承主要是为了重用相同的配置。

对于聚合来说，聚合模块是知道被聚合模块的存在的，而被聚合模块是感知不到聚合模块的存在。

对于继承来说，父构件是感知不到子构件的存在，而子构件需要使用`parent`来引用父构件。

两者的共同点是，聚合模块和继承中的父模块的 package 属性都必须是 pom 类型的，同时，聚合模块和父模块中的除了 pom.xml，一般都是没有什么内容的。

# 8、快速按需任意构建

### 反应堆

项目都开发好了，我们需要安装到本地仓库，

```
mvn clean install
```

maven 会根据模块之间的依赖关系，然后会得到所有模块的构建顺序。

`mvn`命令对多模块构件时，会根据模块的依赖关系而得到模块的构建顺序，这个功能就是 maven 的反应堆（reactor）做的事情，反应堆会根据模块之间的依赖关系、聚合关系、继承关系等等，从而计算得出一个合理的模块构建顺序，所以反应堆的功能是相当强大的。

### 按需随意构建

如果每次修改一个模块，我们都去重新打包所有的模块，这个构建过程耗时是非常久的，只能干等着，我们需要的是按需构建，需要构建哪些模块让我们自己能够随意指定，这样也可以加快构建的速度，所以我们需要这样的功能

maven 反应堆帮我们考虑到了这种情况，mvn 命令提供了一些功能可以帮我们实现这些操作，我们看一下 mvn 的帮助文档，`mvn -h`可以查看帮助，如下：

```
mvn -h
```

上面列出了`mvn`命令后面的一些选项，有几个选项本次我们需要用到，如下：

#### -pl,--projects <arg>

构件指定的模块，arg 表示多个模块，之间用逗号分开，模块有两种写法

```
-pl 模块1相对路径 [,模块2相对路径] [,模块n相对路径]-pl [模块1的groupId]:模块1的artifactId [,[模块2的groupId]:模块2的artifactId] [,[模块n的groupId]:模块n的artifactId]
```

#### -rf,--resume-from <arg>

从指定的模块恢复反应堆

#### -am,--also-make

同时构建所列模块的依赖模块

#### -amd,--also-make-dependents

同时构件依赖于所列模块的模块

# 9、多环境构建

### Maven 属性

#### 自定义属性

maven 属性前面我们有用到过，可以自定义一些属性进行重用，如下：

```
<properties>
    <spring.verion>5.2.1.RELEASE</spring.verion>
</properties>
<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-core</artifactId>
        <version>${spring.verion}</version>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-beans</artifactId>
        <version>${spring.verion}</version>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-aop</artifactId>
        <version>${spring.verion}</version>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-web</artifactId>
        <version>${spring.verion}</version>
    </dependency>
</dependencies>
```

可以看到上面依赖了 4 个 spring 相关的构建，他们的版本都是一样的，在`properties`元素中自定义了一个`spring.version`属性，值为 spring 的版本号，其他几个地方使用`${}`直接进行引用，这种方式好处还是比较明显的，升级 spring 版本的时候非常方便，只需要修改一个地方，方便维护。

上面这个是 maven 自定义属性，需要先在`properties`中定义，然后才可以在其他地方使用`${属性元素名称}`进行引用。

maven 的属性主要分为 2 大类，第一类就是上面说的自定义属性，另外一类是不需要自定义的，可以直接拿来使用的。

2 类属性在 pom.xml 中都是采用`${属性名称}`进行引用，maven 运行的时候会将`${}`替换为属性实际的值。

下面我们来看一下 maven 中不需要自定义的 5 类属性。

#### 内置属性

```
${basedir}：表示项目根目录，即包含pom.xml文件的目录
${version}：表示项目的版本号
```

#### POM 属性

用户可以使用该属性引用 pom.xml 文件中对应元素的值，例如 ${project.artifactId} 就可以取到`project->artifactId`元素的值，常用的有：

```
${pom.build.sourceDirectory}：项目的主源码目录，默认为src/main/java/
${project.build.testSourceDirectory}：项目的测试源码目录，默认为src/test/java/
${project.build.directory}：项目构建输出目录，默认为target/
${project.build.outputDirectory}：项目主代码编译输出目录，默认为target/classes
${project.build.testOutputDirectory}：项目测试代码编译输出目录，默认为target/test-classes
${project.groupId}：项目的groupId
${project.artifactId}：项目的artifactId
${project.version}：项目的version，与${version}等价
${project.build.finalName}：项目打包输出文件的名称，默认为${project.artifactId}-${project.version}
```

#### Settings 属性

这种属性以 settings. 开头来引用`~/.m2/settings.xml`中的内容，如:

```
${settings.localRepository}
```

指向用户本地仓库的地址。

#### java 系统属性

所有 java 系统属性都可以使用 maven 属性来进行引用，例如`${user.home}`指向了当前用户目录。

java 系统属性可以通过`mvn help:system`命令看到。

#### 环境变量属性

所有的环境变量都可以使用 env. 开头的方式来进行引用，如：

```
${env.JAVA_HOME}
```

可以获取环境变量`JAVA_HOME`的值。

用户可以使用`mvn help:system`命令查看所有环境变量的值。

上面的 maven 属性，我们在`pom.xml`中通过`${属性名称}`可以灵活的引用，对我们写 pom.xml 文件帮助还是比较大的。

**实操案例**

将下面配置放在`pom.xml`中：

```
<properties>    
    <!--项目的主源码目录，默认为src/main/java/-->
    <a>${pom.build.sourceDirectory}</a>    
    <!--项目的测试源码目录，默认为src/test/java/-->
    <b>${project.build.testSourceDirectory}</b>    
    <!--项目构建输出目录，默认为target/-->
    <c>${project.build.directory}</c>    
    <!--项目主代码编译输出目录，默认为target/classes-->
    <d>${project.build.outputDirectory}</d>    
    <!--项目测试代码编译输出目录，默认为target/test-classes-->
    <e>${project.build.testOutputDirectory}</e>    
    <!--项目的groupId-->
    <f>${project.groupId}</f>    
    <!--项目的artifactId-->
    <g>${project.artifactId}</g>    
    <!--项目的version，与${version}等价-->
    <h>${project.version}</h>    
    <!--项目打包输出文件的名称，默认为${project.artifactId}-${project.version}-->
    <i>${project.build.finalName}</i>    
    <!--setting属性-->    <!--获取本地仓库地址-->
    <a1>${settings.localRepository}</a1>    
    <!--系统属性-->    <!--用户目录-->
    <a2>${user.home}</a2>    
    <!--环境变量属性，获取环境变量JAVA_HOME的值-->
    <a3>${env.JAVA_HOME}</a3>
</properties>
```

然后在`pom.xml`所在目录执行下面命令：

```
mvn help:effective-pom > 1.xml
```

上面这个命令会将`mvn ...`执行的结果输出到`1.xml`，

### 多套环境构建问题

操作数据库，我们需要一个配置文件来放数据库的配置信息，配置文件一般都放在`src/main/resources`中，在这个目录中新建一个`jdbc.properties`文件，内容如下：

```
jdbc.url=jdbc:mysql://localhost:3306/zkunm?characterEncoding=UTF-8
jdbc.username=root
jdbc.password=root
```

现在系统需要打包，我们运行下面命令

```
mvn clean package -pl :b2b-account-service
```

问题来了：

上面 jdbc 的配置的是开发库的 db 信息，打包之后生成的 jar 中也是上面开发环境的配置，那么上测试环境是不是我们需要修改上面的配置，最终上线的时候，上面的配置是不是又得重新修改一次，相当痛苦的。

我们能不能写 3 套环境的 jdbc 配置，打包的时候去指定具体使用那套配置？

还是你们聪明，maven 支持这么做，pom.xml 的`project`元素下面提供了一个`profiles`元素可以用来对多套环境进行配置。

在讲 profiles 的使用之前，需要先了解资源文件打包的过程。

### 理解资源文件打包过程

resources 目录中的文件一般放的都是配置文件，配置文件一般最好我们都不会写死，所以此处有几个问题：

1.  这个插件复制资源文件如何设置编码？

2.  复制的过程中是否能够对资源文件进行替换，比如在资源文件中使用一些占位符，然后复制过程中对这些占位符进行替换。

`maven-resources-plugin`这个插件还真好，他也想到了这个功能，帮我们提供了这样的功能，下面我们来看看。

- 设置资源文件复制过程采用的编码

这个之前有提到过，有好几种方式，具体可以去前面的文章看一下。这里只说一种：

```
<properties><encoding>UTF-8</encoding></properties>
```

- 设置资源文件内容动态替换

资源文件中可以通过`${maven属性}`来引用 maven 属性中的值，打包的过程中这些会被替换掉，替换的过程默认是不开启的，需要手动开启配置。

修改`src/main/resource/jdbc.properties`内容如下：

```
jdbc.url=${jdbc.url}
jdbc.username=${jdbc.username}
jdbc.password=${jdbc.password}
```

修改`src/test/resource/jdbc.properties`内容如下：

```
jdbc.url=${jdbc.url
jdbc.username=${jdbc.username}
jdbc.password=${jdbc.password}
```

`b2b-account-service/pom.xml`中加入下面内容：

```
<properties>    <!-- 指定资源文件复制过程中采用的编码方式 -->
    <encoding>UTF-8</encoding>
    <jdbc.url>jdbc:mysql://localhost:3306/zkunm?characterEncoding=UTF-8</jdbc.url>
    <jdbc.username>root</jdbc.username>
    <jdbc.password>root</jdbc.password>
</properties>
```

开启动态替换配置，需要在 pom.xml 中加入下面配置：

```
<build>
    <resources>
        <resource>
            <!-- 指定资源文件的目录 -->
            <directory>${project.basedir}/src/main/resources</directory>     
            <!-- 是否开启过滤替换配置，默认是不开启的 -->       
            <filtering>true</filtering>
        </resource>
    </resources>
    <testResources>
        <testResource>
            <!-- 指定资源文件的目录 -->
            <directory>${project.basedir}/src/test/resources</directory>
            <!-- 是否开启过滤替换配置，默认是不开启的 -->
            <filtering>true</filtering>
        </testResource>
    </testResources>
</build>
```

> 注意上面开启动态替换的元素是`filtering`。
>
> 上面 build 元素中的`resources`和`testResources`是用来控制构建过程中资源文件配置信息的，比资源文件位于哪个目录，需要复制到那个目录，是否开启动态过滤等信息。
>
> `resources`元素中可以包含多个`resource`，每个`resource`表示一个资源的配置信息，一般使用来控制主资源的复制的。
>
> `testResources`元素和`testResources`类似，是用来控制测试资源复制的。

上面会将资源文件中`${}`的内容使用 maven 属性中的值进行替换，`${}`中包含的内容默认会被替换，那么我们是否可以自定义`${}`这个格式，比如我希望被`##`包含内容进行替换，这个就涉及到替换中分隔符的指定了，需要设置插件的一些参数。

- 自定义替换的分隔符

自定义分隔符，需要我们配置`maven-resources-plugin`插件的参数，如下：

```
<plugins>
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-resources-plugin</artifactId>
        <version>2.6</version>
        <configuration>
            <!-- 是否使用默认的分隔符，默认分隔符是${*}和@ ,这个地方设置为false，表示不启用默认分隔符配置-->
            <useDefaultDelimiters>false</useDefaultDelimiters>
            <!-- 自定义分隔符 -->
            <delimiters>
                <delimiter>$*$</delimiter>
                <delimiter>##</delimiter>
            </delimiters>
        </configuration>
    </plugin>
</plugins>
```

`delimiters`中可以配置多个`delimiter`，可以配置`#*#`, 其中的`*`表示属性名称，那么资源文件中的`#属性名#`在复制的过程中会被替换掉，`*`前后都是 #，表示前后分隔符都一样，那么可以简写为`#`，所以`#*#`和`#`写法是一样的，我们去看一下源码，delimiters 的默认值如下：

```
this.delimiters.add("${*}");
this.delimiters.add("@");
```

- 指定需要替换的资源文件

在`src/main/resources`中新增一个`const.properties`文件，内容如下：

```
email=zkunm@163.com
jdbc.url=${jdbc.url}
jdbc.username=$jdbc.username$
jdbc.password=##jdbc.password##
```

如果我们不想让`cont.properties`被复制到`target/classes`目录，我们怎么做？我们需要在资源构建的过程中排除他，可以使用`exclude`元素信息进行排除操作。

修改 pom.xml 中`resources`元素配置如下：

```
<resources>
    <resource>
        <!-- 指定资源文件的目录 -->
        <directory>${project.basedir}/src/main/resources</directory>
        <!-- 是否开启过滤替换配置，默认是不开启的 -->
        <filtering>true</filtering>
        <includes>
            <include>**/jdbc.properties</include>
        </includes>
        <excludes>
            <exclude>**/const.properties</exclude>
        </excludes>
    </resource>
</resources>
```

> 上面使用`includes`列出需要被处理的，使用`excludes`排除需要被处理的资源文件列表，采用通配符的写法，** 匹配任意深度的文件路径，* 匹配任意个字符。

### 使用 profiles 处理多环境构建问题

maven 支持让我们配置多套环境，每套环境中可以指定自己的 maven 属性，mvn 命令对模块进行构建的时候可以通过`-P`参数来指定具体使用哪个环境的配置，具体向下看。

profiles 元素支持定义多套环境的配置信息，配置如下用法：

```
<profiles>
    <profile>测试环境配置信息</profile>
    <profile>开发环境配置信息</profile>
    <profile>线上环境配置信息</profile>
    <profile>环境n配置信息</profile>
</profiles>
```

profiles 中包含多个 profile 元素，每个 profile 可以表示一套环境，profile 示例如下：

```
<profile>
    <id>dev</id>
    <properties>
        <jdbc.url>dev jdbc url</jdbc.url>
        <jdbc.username>dev jdbc username</jdbc.username>
        <jdbc.password>dev jdbc password</jdbc.password>
    </properties>
</profile>
```

> id：表示这套环境的标识信息，properties 可以定义环境中使用到的属性列表。
>
> 执行 mvn 命令编译的时候可以带上一个`-P profileid`来使用指定的环境进行构建。

- 指定环境进行构建

在pom.xml加入下面配置：

```
<profiles>    <!-- 开发环境使用的配置 -->
    <profile>
        <id>dev</id>
        <properties>
            <jdbc.url>dev jdbc url</jdbc.url>
            <jdbc.username>dev jdbc username</jdbc.username>
            <jdbc.password>dev jdbc password</jdbc.password>
        </properties>
    </profile>    <!-- 测试环境使用的配置 -->
    <profile>
        <id>test</id>
        <properties>
            <jdbc.url>test jdbc url</jdbc.url>
            <jdbc.username>test jdbc username</jdbc.username>
            <jdbc.password>test jdbc password</jdbc.password>
        </properties>
    </profile>    <!-- 线上环境使用的配置 -->
    <profile>
        <id>prod</id>
        <properties>
            <jdbc.url>test jdbc url</jdbc.url>
            <jdbc.username>test jdbc username</jdbc.username>
            <jdbc.password>test jdbc password</jdbc.password>
        </properties>
    </profile>
</profiles>
```

改`src/main/resource/jdbc.properties`内容如下：

```
jdbc.url=$jdbc.url$
```

运行下面的构建命令：

```
mvn clean package -Pdev
```

> **注意上面命令中多了一个`-Pdev`参数，`-P后面跟的是pom.xml中profile的id`，表示需要使用那套环境进行构建。此时我们使用的是`dev`环境，即开发环境。**

看一下`target/classes/jdbc.properties`，内容变成了下面这样：

```
jdbc.url=dev jdbc url
```

- 开启默认环境配置

指定一个默认开启的配置，我们默认开启 dev 的配置，修改 dev 的 profile 元素，在这个元素下面加上：

```
<activation>
    <activeByDefault>true</activeByDefault>
</activation>
```

> activeByDefault 表示默认开启这个环境的配置，默认值是 false，这个地方我们设置为 true，表示开启默认配置

- 通过 maven 属性来控制环境的开启

刚才上面说了通过 - P profileId 的方式来指定环境，现在我们想通过自定义的属性值来控制使用哪个环境。

可以在 profile 元素中加入下面配置

```
<activation>
    <property>
        <name>属性xx</name>
        <value>属性xx的值</value>
    </property>
</activation>
```

那么我们可以在 mvn 后面跟上下面的命令可以开启匹配的环境：

```
mvn ... -D属性xx=属性xx的值
```

> -D 可以通过命令行指定一些属性的值，这个前面有讲过，-D 后面的属性会和 activation->properties 中的 name、value 进行匹配，匹配成功的环境都会被开启。

将 pom.xml 中`profiles`元素修改成下面这样：

```
<!-- 配置多套环境 -->
<profiles>    <!-- 开发环境使用的配置 -->
    <profile>
        <id>dev</id>
        <activation>
            <activeByDefault>true</activeByDefault>
            <property>
                <name>env</name>
                <value>env_dev</value>
            </property>
        </activation>
        <properties>
            <jdbc.url>dev jdbc url</jdbc.url>
            <jdbc.username>dev jdbc username</jdbc.username>
            <jdbc.password>dev jdbc password</jdbc.password>
        </properties>
    </profile>    <!-- 测试环境使用的配置 -->
    <profile>
        <id>test</id>
        <activation>
            <property>
                <name>env</name>
                <value>env_test</value>
            </property>
        </activation>
        <properties>
            <jdbc.url>test jdbc url</jdbc.url>
            <jdbc.username>test jdbc username</jdbc.username>
            <jdbc.password>test jdbc password</jdbc.password>
        </properties>
    </profile>    <!-- 线上环境使用的配置 -->
    <profile>
        <id>prod</id>
        <activation>
            <property>
                <name>env</name>
                <value>env_prod</value>
            </property>
        </activation>
        <properties>
            <jdbc.url>prod jdbc url</jdbc.url>
            <jdbc.username>prod jdbc username</jdbc.username>
            <jdbc.password>prod jdbc password</jdbc.password>
        </properties>
    </profile>
</profiles>
```

运行命令：

```
mvn clean package -Denv=env_prod
```

- 启动的时候指定多个环境

可以在`-P`参数后跟多个环境的 id，多个之间用逗号隔开，当使用多套环境的时候，多套环境中的 maven 属性会进行合并，如果多套环境中属性有一样的，后面的会覆盖前面的。

运行下面命令看效果：

```
mvn clean package -Pdev,test,prod
```

修改 pom.xml 中的 profiles 元素，如下：

```
<!-- 配置多套环境 -->
<profiles>    <!-- 开发环境使用的配置 -->
    <profile>
        <id>dev</id>
        <activation>
            <activeByDefault>true</activeByDefault>
            <property>
                <name>env</name>
                <value>env_dev</value>
            </property>
        </activation>
        <properties>
            <jdbc.url>dev jdbc url</jdbc.url>
        </properties>
    </profile>    <!-- 测试环境使用的配置 -->
    <profile>
        <id>test</id>
        <activation>
            <property>
                <name>env</name>
                <value>env_test</value>
            </property>
        </activation>
        <properties>
            <jdbc.username>test jdbc username</jdbc.username>
        </properties>
    </profile>    <!-- 线上环境使用的配置 -->
    <profile>
        <id>prod</id>
        <activation>
            <property>
                <name>env</name>
                <value>env_prod</value>
            </property>
        </activation>
        <properties>
            <jdbc.password>prod jdbc password</jdbc.password>
        </properties>
    </profile>
</profiles>
```

> 注意看一下上面 3 个环境中都只有一个自定义属性了

下面我们同时使用 3 个环境，执行下面命令：

```
mvn clean package -Pdev,test,prod
```

target 中的 jdbc.properties 文件变成了这样：

```
jdbc.url=dev jdbc url
```

- 查看目前有哪些环境

```
mvn help:all-profiles
```

- 查看目前激活的是哪些环境

```
mvn help:active-profiles
```

- 新问题：配置太分散了

我们可以将数据库所有的配置放在一个文件中

maven 支持我们这么做，可以在 profile 中指定一个外部属性文件`xx.properties`，文件内容是这种格式的：

```
key1=value1
```

然后在 profile 元素中加入下面配置：

```
<build>
    <filters>
        <filter>xx.properties文件路径（相对路径或者完整路径）</filter>
    </filters>
</build>
```

上面的`filter`元素可以指定多个，当有多个外部属性配置文件的时候，可以指定多个来进行引用。

然后资源文件复制的时候就可以使用下面的方式引用外部资源文件的内容：

```
xxx=${key1}
```

#### profile 元素更强大的功能

profile 元素可以用于对不同环境的构建进行配置，project 中包含的元素，在 profile 元素中基本上都有，所以 profile 可以定制更复杂的构建过程，不同的环境依赖的构件、插件、build 过程、测试过程都是不一样的，这些都可以在 profile 中进行指定，也就是说不同的环境所有的东西都可以通过 profile 元素来进行个性化的设置

# 10、设计自己的 maven 插件

### 自定义插件详细步骤

maven 中的插件是有很多目标（goal）组成的，开发插件，实际上就是去编写插件中目标的具体代码。每个目标对应一个 java 类，这个类在 maven 中叫做 MOJO，maven 提供了一个 Mojo 的接口，我们开发插件也就是去实现这个接口的方法，这个接口是：

```
org.apache.maven.plugin.Mojo
```

接口有 3 个方法：

```
void execute() throws MojoExecutionException, MojoFailureException;
void setLog(Log var1);
Log getLog();
```

*   **execute**：这个方法比较重要，目标的主要代码就在这个方法中实现，当使用 mvn 命令调用插件的目标的时候，最后具体调用的就是这个方法。

*   **setLog**：注入一个标准的 Maven 日志记录器，允许这个 Mojo 向用户传递事件和反馈

*   **getLog**：获取注入的日志记录器

 Log是一日志接口，里面定义了很多方法，主要用户向交互者输出日志，比如我们运行`mvn clean`，会输出很多提示信息，这些输出的信息就是通过 Log 来输出的。

Mojo 接口有个默认的抽象类：

```
org.apache.maven.plugin.AbstractMojo
```

这个类中把`Mojo`接口中的`setLog`和`getLog`实现了，而`execute`方法没有实现，交给继承者去实现，这个类中 Log 默认可以向控制台输出日志信息，maven 中自带的插件都继承这个类，一般情况下我们开发插件目标可以直接继承这个类，然后实现`execute`方法就可以了。

- 实现一个插件的具体步骤

1、 创建一个 maven 构件，这个构件的 packaging 比较特殊，必须为 maven-plugin，表示这个构件是一个插件类型，如下：

> pom.xml 中的 packageing 元素必须如下值：

```
<packaging>maven-plugin</packaging>
```

2、导入 maven 插件依赖：

```
<dependency>
    <groupId>org.apache.maven</groupId>
    <artifactId>maven-plugin-api</artifactId>
    <version>3.0</version>
</dependency>
<dependency>
    <groupId>org.apache.maven.plugin-tools</groupId>
    <artifactId>maven-plugin-annotations</artifactId>
    <version>3.4</version>
    <scope>provided</scope>
</dependency>
```

3、创建一个目标类，需要继承 org.apache.maven.plugin.AbstractMojo

4、目标类中添加注解 @Mojo 注解：

```
@org.apache.maven.plugins.annotations.Mojo()
```

注意`@Mojo`注解用来标注这个类是一个目标类，maven 对插件进行构建的时候会根据这个注解来找到这个插件的目标，这个注解中还有其他参数，后面在详细介绍。

5、在目标类的 execute 方法中实现具体的逻辑

6、安装插件到本地仓库：插件的 pom.xml 所在目录执行下面命令

```
mvn clean install
```

或者可以部署到私服仓库，部署方式和其他构件的方式一样，这个具体去看前面文章的私服的文章。

7、让使用者去使用插件

**示例**

1. 创建一个 maven 项目，一个子模块demo1-maven-plugin

2. 设置 demo1-maven-plugin/pom.xml 中 packaging 的值为 maven-plugin，如下

```
<packaging>maven-plugin</packaging>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <!-- 配置maven编译的时候采用的编译器版本 -->
        <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
        <!-- 指定源代码是什么版本的，如果源码和这个版本不符将报错，maven中执行编译的时候会用到这个配置，默认是1.5，这个相当于javac命令后面的-source参数 -->
        <maven.compiler.source>1.8</maven.compiler.source>
        <!-- 该命令用于指定生成的class文件将保证和哪个版本的虚拟机进行兼容，maven中执行编译的时候会用到这个配置，默认是1.5，这个相当于javac命令后面的-target参数 -->
        <maven.compiler.target>1.8</maven.compiler.target>
    </properties>
    
    <plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-plugin-plugin</artifactId>
    <version>3.4</version>
</plugin>
```

3. demo1-maven-plugin/pom.xml 引入插件需要的依赖

```
<dependency>
    <groupId>org.apache.maven</groupId>
    <artifactId>maven-plugin-api</artifactId>
    <version>3.0</version>
</dependency>
<dependency>
    <groupId>org.apache.maven.plugin-tools</groupId>
    <artifactId>maven-plugin-annotations</artifactId>
    <version>3.4</version>
    <scope>provided</scope>
</dependency>
```

4. `demo1-maven-plugin`中创建的目标类`com.zkunm.Demo1`，需要继承`org.apache.maven.plugin.AbstractMojo`，需要实现`@Mojo注解`，如下：

```
package com.zkunm;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.Mojo;

/**
 * @Description
 * @author: zkunm
 * @create: 2020-12-07 16:30
 */
@Mojo(name="demo1")
public class Demo1 extends AbstractMojo {
    @Override
    public void execute() throws MojoExecutionException, MojoFailureException {

    }
}
```

注意上面注解`@Mojo(name = "demo1")`，`name`使用来标注目标的名称为`demo1`。

4. 实现目标类的 execute 方法

我们在`execute`方法中输出一句话

```
this.getLog().info("hello my first maven plugin!");
```

目前 execute 方法代码如下：

```
public void execute() throws MojoExecutionException, MojoFailureException {
    this.getLog().info("hello my first maven plugin!");
}
```

5. 安装插件到本地仓库

在目录执行下面命令：

```
mvn clean install
```

6. 验证插件，调用插件的 demo1 目标看效果

```
mvn com.zkunm:demo1-maven-plugin:demo1
```

![image-20201207164032942](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207164033.png)

### 目标中参数的使用

上面我们介绍了开发一个插件目标详细的实现过程，然后写了一个简单的案例，比较简单。不过自定义的`Mojo`如果没有参数，那么这个`Mojo`基本上也实现不了什么复杂的功能，下面我们来看一下 Mojo 中如何使用参数。

1. 需要先在 mojo 中定义参数

定义参数就像在 mojo 中创建一个实例变量并添加适当的注释一样简单。下面列出了一个简单 mojo 的参数示例：

```
@Parameter(property = "say.greeting", defaultValue = "hello world!")
private String greeting;
```

> @Parameter 注解之前的部分是参数的描述，这个注解将变量标识为 mojo 参数。注解的 defaultValue 参数定义变量的默认值，此值 maven 的属性值，例如 “${project.version}”，property 参数可用于通过引用用户通过 - D 选项设置的系统属性，即通过从命令行配置 mojo 参数，如`mvn ... -Dsay.greeting=zkunm`可以将`zkunm`的值传递给`greeting`参数

2. 在 pom.xml 配置参数的值

```
<plugin>
    <groupId>com.zkunm</groupId>
    <artifactId>demo1-maven-plugin</artifactId>
    <version>1.0-SNAPSHOT</version>
    <configuration>
        <greeting>zkunm</greeting>
    </configuration>
</plugin>
```

- Boolean 参数

```
@Parameter
private boolean myboolean;
```

```
<myBoolean>true</myBoolean>
```

- 数字类型参数

数字类型包含：`byte`, `Byte`, `int`, `Integer`, `long`, `Long`, `short`, `Short`，读取配置时，XML 文件中的文本将使用适当类的 integer.parseInt（）或 valueOf（）方法转换为整数值，这意味着字符串必须是有效的十进制整数值，仅由数字 0 到 9 组成，前面有一个可选的 - 表示负值。例子：

```
@Parameter
private Integer myInteger;
```

```
<myInteger>10</myInteger>
```

- File 类型参数

读取配置时，XML 文件中的文本用作所需文件或目录的路径。如果路径是相对的（不是以 / 或 C: 之类的驱动器号开头），则路径是相对于包含 POM 的目录的。例子：

```
@Parameter
private File myFile;
```

```
<myFile>c:\temp</myFile>
```

- 枚举类型参数

```
public enum Color {
    GREEN, RED, BLUE
}

@Parameter
private Color myColor;
```

```
<myColor>GREEN</myColor>
```

- 数组类型参数

```
@Parameter
private String[] myArray;
```

```
<myArray>
	<param>value1</param>
	<param>value2</param>
</myArray>
```

- Collections 类型参数

```
@Parameter
private List myList;
```

```
<myList>
	<param>value1</param>
	<param>value2</param>
</myList>
```

- Maps 类型参数

```
@Parameter
private Map myMap;
```

```
<myMap>
	<key1>value1</key1>
	<key2>value2</key2>
</myMap>
```

- Properties 类型参数

`java.util.Properties`的类型

```
@Parameter
private Properties myProperties;
```

```
<myProperties>
    <property>
        <name>propertyName1</name>
        <value>propertyValue1</value>
    </property>
    <property>
        <name>propertyName2</name>
        <value>propertyValue2</value>
    </property>
</myProperties>
```

- 自定义类型参数

```
@Parameter
private MyObject myObject;
```

```
<myObject>
    <myField>test</myField>
</myObject>
```

3. 修改案例代码

我们将上面各种类型的参数都放到 Demo1 中，Demo1类如下：

```
package com.zkunm;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;

import java.io.File;
import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * @Description
 * @author: zkunm
 * @create: 2020-12-07 16:30
 */
@Mojo(name = "demo1")
public class Demo1 extends AbstractMojo {
    @Parameter(property = "say.greeting", defaultValue = "hello world!")
    private String greeting;
    @Parameter
    private boolean myboolean;
    @Parameter
    private Integer myInteger;
    @Parameter
    private Color myColor;
    @Parameter
    private File myFile;
    @Parameter
    private String[] myArray;
    @Parameter
    private List myList;
    @Parameter
    private Map myMap;
    @Parameter
    private Properties myProperties;
    @Parameter
    private Person person;

    @Override
    public void execute() throws MojoExecutionException, MojoFailureException {
        this.getLog().info("hello my first maven plugin!");

        Field[] fields = Demo1.class.getDeclaredFields();
        Arrays.stream(fields).forEach(field -> {
            if (field.isAccessible()) {
                field.setAccessible(true);
            }
            try {
                this.getLog().info(field.getName()+":"+field.get(this));
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        });
    }
}
```

4. 将 `demo1-maven-plugin` 安装到本地仓库

```shell
mvn clean install
```

5. 创建测试模块 `demo1-maven-plugin-test`

6. 修改`demo1-mavein-plugin-test/pom.xml`文件，加入下面内容：

```
<plugin>
    <groupId>com.zkunm</groupId>
    <artifactId>demo1-maven-plugin</artifactId>
    <version>1.0-SNAPSHOT</version>
    <executions>
        <execution>
            <id>demo1 plugin test</id>
            <phase>pre-clean</phase>
            <goals>
                <goal>demo1</goal>
            </goals>
            <configuration>
                <myBoolean>true</myBoolean>
                <myInteger>30</myInteger>
                <myFile>${project.basedir}</myFile>
                <myColor>BLUE</myColor>
                <myArray>
                    <array>maven</array>
                    <array>spring</array>
                    <array>mybatis</array>
                    <array>springboot</array>
                    <array>springcloud</array>
                </myArray>
                <myList>
                    <list>30</list>
                    <list>35</list>
                </myList>
                <myMap>
                    <name>zkunm</name>
                    <age>30</age>
                </myMap>
                <myProperties>
                    <property>
                        <name>name</name>
                        <value>zkunm</value>
                    </property>
                    <property>
                        <name>age</name>
                        <value>30</value>
                    </property>
                </myProperties>
                <person>
                    <name>zkunm</name>
                    <age>32</age>
                </person>
            </configuration>
        </execution>
    </executions>
</plugin>
```

上面是将生命周期的`pre-clean`阶段绑定插件`demo1-maven-plugin`的`demo1`目标，并且设置了`demo1`目标所需要的所有参数的值。

7. 验证效果

在`demo1-maven-plugin-test`所在目录执行：

```
mvn pre-clean -Dsayhi.greeting="hello zkunm"
```

![image-20201207171208005](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20201207171208.png)

### 插件前缀

在案例 1 中，我们使用下面命令调用的插件：

```
mvn com.zkunm:demo1-maven-plugin:demo1
```

这种是采用下面这种格式：

```
mvn 插件groupId:插件artifactId[:插件版本]:插件目标名称
```

> 命令中插件版本是可以省略的，maven 会自动找到这个插件最新的版本运行，不过最好我们不要省略版本号，每个版本的插件功能可能不一样，为了保证任何情况下运行效果的一致性，强烈建议指定版本号。

上面执行插件需要插件的坐标信息，一长串比较麻烦，maven 也为了我们使用插件方便，提供了插件前缀来帮我们解决这个问题。

#### 自定义插件前缀的使用

1. 设置自定义插件的 artifactId

自定义插件的`artifactId`满足下面的格式：

```
xxx-maven-plugin
```

如果采用这种格式的 maven 会自动将`xxx`指定为插件的前缀，其他格式也可以，不过此处我们只说这种格式，这个是最常用的格式。

如我们上面的`demo1-maven-plugin`插件，他的前缀就是`demo1`。

当我们配置了插件前缀，可以插件前缀来调用插件的目标了，命令如下：

```
mvn 插件前缀:插件目标
```

maven 是如何通过插件前缀找到具体的插件的呢？

maven 默认会在仓库`"org.apache.maven.plugins" 和 "org.codehaus.mojo"`2 个位置查找插件，

我们自己定义的插件，如果也让 maven 能够找到，需要下面的配置。

2. 在 `~/.m2/settings.xml` 中配置自定义插件组

在`pluginGroups`中加入自定义的插件组`groupId`，如：

```
<pluginGroup>com.zkunm</pluginGroup>
```

这样当我们通过前缀调用插件的时候，maven 除了会在 2 个默认的组中查找，还会在这些自定义的插件组中找，一般情况下我们自定义的插件通常使用同样的`groupId`。

3. 使用插件前缀调用插件

```
mvn 插件前缀:插件目标
```

### 手动实现打包之后自动运行的插件

1、将目标构件打包为可以执行 jar 包到 target 目录

maven 中将构件打包为可以执行的 jar 的插件，maven 已经帮我们提供了，如下：

```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>3.2.1</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <transformers>
                    <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                        <mainClass>启动类完整路径</mainClass>
                    </transformer>
                </transformers>
            </configuration>
        </execution>
    </executions>
</plugin>
```

上面使用到了 maven 官方提供的一个打包的插件，可以将构件打包为可以直接运行的 jar 包。

2、自定义一个插件，然后执行上面打包好的插件

插件中需要通过 java 命令调用打包好的 jar 包，然后运行。

1. 创建自定义目标类

`demo1-maven-plugin`中创建一个插件目标类，如下：

```
package com.zkunm;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.Execute;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

@Mojo(name = "run", defaultPhase = LifecyclePhase.PACKAGE)
@Execute(phase = LifecyclePhase.PACKAGE)
public class RunMojo extends AbstractMojo {
    @Parameter(defaultValue = "${project.build.directory}\\${project.artifactId}-${project.version}.jar")
    private String jarPath;
    @Override
    public void execute() throws MojoExecutionException, MojoFailureException {
        try {
            this.getLog().info("Started:" + this.jarPath);
            ProcessBuilder builder = new ProcessBuilder("java", "-jar", this.jarPath);
            final Process process = builder.start();
            new Thread(() -> {
                BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
                try {
                    String s;
                    while ((s = reader.readLine()) != null) {
                        System.out.println(s);
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }).start(); Runtime.getRuntime().addShutdownHook(new Thread() {
                @Override
                public void run() {
                    RunMojo.this.getLog().info("Destroying...");
                    process.destroy();
                    RunMojo.this.getLog().info("Shutdownhookfinished.");
                }
            });
            process.waitFor();
            this.getLog().info("Finished.");
        } catch (Exception e) {
            this.getLog().warn(e);
        }
    }
}
```

> 上面这个插件目标的名称为`run`
>
> 注意这个类上面多了一个注解`@Execute`，这个注解可以配置这个目标执行之前可以先执行的`生命周期的阶段`或者需要先执行的`插件目标`。
>
> 上面配置的是`phase = LifecyclePhase.PACKAGE`，也就是说当我们运行上面`run`目标的时候，会先执行构件的`package`阶段，也就是先执行项目的打包阶段，打包完成之后才会执行`run`目标。

2. 安装插件到本地仓库

```
mvn clean install
```

3. 创建测试模块 `demo1-maven-plugin-run`

4. 创建 com.zkunm.Demo 类

```
package com.zkunm;

import java.util.Calendar;
import java.util.concurrent.TimeUnit;

/**
 * @Description
 * @author: zkunm
 * @create: 2020-12-07 17:24
 */
public class Demo {
    public static void main(String[] args) throws InterruptedException {
        for (int i = 0; i < 1000; i++) {
            System.out.println(Calendar.getInstance().getTime() + ": " + 1);
            TimeUnit.SECONDS.sleep(1);
        }
    }
}
```

5. 修改 demo1-maven-plugin-run/pom.xml，如下

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.zkunm</groupId>
    <artifactId>demo1-maven-plugin-run</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
    </properties>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <version>3.2.1</version>
                <executions>
                    <execution>
                        <phase>package</phase>
                        <goals>
                            <goal>shade</goal>
                        </goals>
                        <configuration>
                            <transformers>
                                <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                    <mainClass>com.zkunm.Demo1</mainClass>
                                </transformer>
                            </transformers>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

6. 验证效果见证奇迹的时刻

```
mvn clean demo1:run
```

