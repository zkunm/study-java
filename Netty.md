# 第一章 IO基础

## 1.1 Linux网络IO模型简介

​	Linux 的内核将所有外部设备都看做一个文件来操作，对一个文件的读写操作会调用内核提供的系统命令，返回一个file descriptor ( fd，文件描述符)。而对一个socket 的读写也会有相应的描述符，称为socketfd ( socket描述符)，描述符就是一个数字，它指向内核中的一个结构体（文件路径，数据区等一些属性)。

​	根据UNIX网络编程对IO模型的分类，UNIX提供了5中IO模型，分别如下：

1.  **阻塞IO模型**：默认情况下，所有文件操作都是阻塞的。以套接字接口为例来讲解此模型:在进程空间中调用recvfrom，其系统调用直到数据包到达且被复制到应用进程的缓冲区中或者发生错误时才返回，在此期间一直会等待，进程在从调用recvfrom开始到它返回的整段时间内都是被阻塞的因此被称为阻塞I/O模型

![image-20210322101625641](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162916.png)

2.  **非阻塞I/O模型**: recvfrom从应用层到内核的时候，如果该缓冲区没有数据的话，就直接返回一个EWOULDBLOCK错误，一般都对非阻塞I/O模型进行轮询检查这个状态，看内核是不是有数据到来

    ![image-20210322101727105](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162917.png)

3.  **I/O复用模型**:Linux 提供 select/poll，进程通过将一个或多个fd传递给 select或poll系统调用，阻塞在select操作上，这样select/poll可以帮我们侦测多个fd是否处于就绪状态。select/poll是顺序扫描fd是否就绪，而且支持的fd数量有限，因此它的使用受到了一些制约。Linux还提供了一个epoll系统调用，epoll使用基于事件驱动方式代替顺序扫描，因此性能更高。当有fd就绪时，立即回调函数rollback

    ![image-20210322101911434](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162918.png)

4.  **信号驱动IO模型**:首先开启套接口信号驱动I/O功能，并通过系统调用sigaction执行一个信号处理函数（此系统调用立即返回，进程继续工作，它是非阻塞的)。当数据准备就绪时，就为该进程生成一个SIGIO信号，通过信号回调通知应用程序调用recvfrom来读取数据，并通知主循环函数处理数据。

    ![image-20210322102012263](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162919.png)

5.  **异步I/O**:告知内核启动某个操作，并让内核在整个操作完成后（包括将数据从内核复制到用户自己的缓冲区）通知我们。这种模型与信号驱动模型的主要区别是:信号驱动I/O由内核通知我们何时可以开始一个IO操作;异步I/O模型由内核通知我们IO操作何时已经完成

    ![image-20210322102132315](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162920.png)

## 1.2 IO多路复用技术

​	在I/O编程过程中，当需要同时处理多个客户端接入请求时，可以利用多线程或者IO多路复用技术进行处理。I/O多路复用技术通过把多个IO的阻塞复用到同一个select的阻塞上，从而使得系统在单线程的情况下可以同时处理多个客户端请求。与传统的多线程/多进程模型比，IO 多路复用的最大优势是系统开销小，系统不需要创建新的额外进程或者线程，也不需要维护这些进程和线程的运行，降低了系统的维护工作量，节省了系统资源，I/O多路复用的主要应用场景如下。

*   服务器需要同时处理多个处于监听状态或多个连接状态的套接字
*   服务器需要同时处理多种网络协议的套接字

​	目前支持IO多路复用的系统调用有select、pselect、poll、epoll，在 Linux网络编程过程中，很长一段时间都使用select做轮询和网络事件通知，然而 select的一些固有缺陷导致了它的应用受到了很大的限制，最终LInux不得不在新的内核版本中寻找select的替换方案，最终选择了epoll。epoll 与 select 的原理比较类似，为了克服select的缺点，epoll作了很多重大改进，现总结如下。

1.  支持一个进程打开的socket描述符(FD)不受限制（仅限制于操作系统的最大文件句柄数）
2.  IO效率不会随着FD数目的增加而线性下降
3.  使用mmap加速内核与用户空间的消息传递
4.  epoll的API更为简单

# 第二章 NIO入门

## 2.1 传统BIO编程

​	网络编程的基本模型是Client/Server模型，也就是两个进程之间进行通信，其中服务端提供位置信息和建通端口，客户端通过连接操作向服务端监听的地址发起请求，经过三次握手链接，如果连接建立成功，双方就可以通过网络套接字进行通信。

​	采用BIO通信模型的服务端，通常由一个独立的Acceptor线程负责监听客户端的连接，它接收到客户端连接请求之后为每个客户端创建一个新的线程进行链路处理，处理完成之后，通过输出流返回应答给客户端，线程销毁。这就是典型的一请求一应答通信模型。

![image-20210322105209354](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162921.png)

​	该模型最大的问题就是缺乏弹性伸缩能力，当客户端并发访问量增加后，服务端的线程个数和客户端并发访问数呈1:1的正比关系，由于线程是Java虚拟机非常宝贵的系统资源，当线程数膨胀之后，系统的性能将急剧下降，随着并发访问量的继续增大，系统会发生线程堆栈溢出、创建新线程失败等问题，并最终导致进程宕机或者僵死，不能对外提供服务。

## 2.2 伪异步IO编程

​	采用线程池和任务队列可以实现一种叫做伪异步的I/O通信框架,当有新的客户端接入的时候，将客户端的 Socket封装成一个Task（该任务实现java.lang.Runnable接口)投递到后端的线程池中进行处理，JDK的线程池维护一个消息队列和N个活跃线程对消息队列中的任务进行处理。由于线程池可以设置消息队列的大小和最大线程数，因此，它的资源占用是可控的，无论多少个客户端并发访问，都不会导致资源的耗尽和宕机。

![image-20210322105647813](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162922.png)

## 2.3 NIO编程

1.  类库介绍

    *   缓冲区 Buffer

        ​	Buffer是一个对象，它包含一些要写入或者要读出的数据。在 NIO类库中加入 Buffer对象，体现了新库与原IO的一个重要区别。在面向流的IO中，可以将数据直接写入或者将数据直接读到Stream对象中。在NIO库中，所有数据都是用缓冲区处理的。在读取数据时，它是直接读到缓冲区中的;在写入数据时，写入到缓冲区中。任何时候访问NIO中的数据，都是通过缓冲区进行操作。缓冲区实质上是一个数组。通常它是一个字节数组（ByteBuffer)，也可以使用其他种类的数组。但是一个缓冲区不仅仅是一个数组，缓冲区提供了对数据的结构化访问以及维护读写位置（ limit）等信息。最常用的缓冲区是 ByteBuffer，一个 ByteBuffer提供了一组功能用于操作byte数组。除了ByteBuffer，还有其他的一些缓冲区，每一种Java基本类型（除了Boolean类型）都对应有一种缓冲区。

    *   通道 Channel

        ​	Channel是一个通道，可以通过它读取和写入数据，它就像自来水管一样，网络数据通过Channel读取和写入。通道与流的不同之处在于通道是双向的，流只是在一个方向上移动(一个流必须是InputStream或者OutputStream的子类)，而且通道可以用于读、写或者同时用于读写。因为Channel是全双工的，所以它可以比流更好地映射底层操作系统的API。特别是在UNIX网络编程模型中，底层操作系统的通道都是全双工的，同时支持读写操作。

    -   多路复用器 Selector

        Selector会不断地轮询注册在其上的 Channel，如果某个 Channel 上面有新的TCP连接接入、读和写事件，这个Channel就处于就绪状态，会被Selector轮询出来，然后通过SelectionKey可以获取就绪Channel的集合，进行后续的1O操作。一个多路复用器Selector可以同时轮询多个 Channel，JDK使用了epoll()代替传统的select实现。

2.  NIO服务端序列图

    ![image-20210322110807088](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162923.png)

3.  NIO客户端序列图

    ![image-20210322110840313](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162924.png)

    4.  使用NIO优点总结
        *   客户端发起的连接操作是异步的，可以通过在多路复用器注册OP_CONNECT等待后续结果，不需要像之前的客户端那样被同步阻塞。
        *   SocketChannel的读写操作都是异步的，如果没有可读写的数据它不会同步等待，直接返回，这样I/O通信线程就可以处理其他的链路，不需要同步等待这个链路可用。
        *   线程模型的优化:由于JDK的Selector在 Linux等主流操作系统上通过 epoll 实现，它没有连接句柄数的限制(只受限于操作系统的最大句柄数或者对单个进程的句柄限制)，这意味着一个Selector 线程可以同时处理成千上万个客户端连接，而且性能不会随着客户端的增加而线性下降，因此，它非常适合做高性能、高负载的网络服务器。

## 2.4 AIO编程

*   通过java.util.concurrent.Future类来表示异步操作的结果
*   在执行异步操作的时候传入一个java.nio.channels

CompletionHandler接口的实现类作为异步完成的回调。

## 2.5 4种IO的对比

|                    | 同步阻塞IO | 伪异步IO              | 非阻塞IO                            | 异步IO                                  |
| ------------------ | ---------- | --------------------- | ----------------------------------- | --------------------------------------- |
| 客户端个数：IO线程 | 1:1        | M:N（其中M可以大于N） | M:1（一个IO线程处理多个客户端连接） | M:0（不需要启动额外的IO线程，被动回调） |
| IO类型（阻塞）     | 阻塞IO     | 阻塞IO                | 非阻塞IO                            | 非阻塞IO                                |
| IO类型（同步）     | 同步IO     | 同步IO                | 同步IO（IO多路复用）                | 异步IO                                  |
| API难度            | 简单       | 简单                  | 非常复杂                            | 复杂                                    |
| 调试难度           | 简单       | 简单                  | 复杂                                | 复杂                                    |
| 可靠性             | 非常差     | 差                    | 高                                  | 高                                      |
| 吞吐量             | 低         | 中                    | 高                                  | 高                                      |

# 第三章 Netty入门应用

## 3.1 TimeServer服务器

![image-20210322125903561](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162925.png)

![image-20210322125916588](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162926.png)

## 3.2 TimeClient

![image-20210322125950285](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162927.png)

![image-20210322130000535](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162928.png)

# 第四章 TCP粘包拆包问题的解决



## 4.1 TCP粘包拆包

​	TCP是个“流”协议，所谓流，就是没有界限的一串数据。TCP底层并不了解上层业务数据的具体含义，它会根据TCP缓冲区的实际情况进行包的划分﹐所以在业务上认为，一个完整的包可能会被TCP拆分成多个包进行发送，也有可能把多个小的包封装成一个大的数据包发送，这就是所谓的TCP粘包和拆包问题。

![image-20210323100444046](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162929.png)

假设客户端分别发送了两个数据包D1和D2给服务端，由于服务端一次读取到的字节数是不确定的，故可能存在以下4种情况。

1.  服务端分两次读取到了两个独立的数据包，分别是D1和 D2，没有粘包和拆包;

2.  服务端一次接收到了两个数据包，D1和D2粘合在一起，被称为TCP粘包;

3.  服务端分两次读取到了两个数据包，第一次读取到了完整的D1包和 D2包的部分内容，第二次读取到了D2包的剩余内容，这被称为TCP拆包;

4.  服务端分两次读取到了两个数据包，第一次读取到了D1包的部分内容Dl_1，第二次读取到了D1包的剩余内容D1_2和 D2包的整包。

如果此时服务端TCP接收滑窗非常小，而数据包D1和D2比较大，很有可能会发生第五种可能，即服务端分多次才能将D1和D2包接收完全，期间发生多次拆包。

TCP粘包拆包发生的原因：

1.  应用程序 write 写入的字节大小大于套接口发送缓冲区大小;
2.  进行MSS大小的 TCP分段;
3.  以太网帧的 payload大于MTU进行IP分片。

![image-20210323100902953](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162930.png)

粘包问题的解决策略

1.  消息定长，例如每个报文的大小为固定长度200字节，如果不够，空位补空格;
2.  在包尾增加回车换行符进行分割，例如FTP协议;
3.  将消息分为消息头和消息体，消息头中包含表示消息总长度（或者消息体长度）的字段，通常设计思路为消息头的第一个字段使用int32来表示消息的总长度;
4.  更复杂的应用层协议。

## 4.2 利用LineBasedFrameDecoder解决TCP粘包问题

​	LineBasedFrameDecoder 的工作原理是它依次遍历 ByteBuf中的可读字节，判断看是否有“\n”或者“\r\n”，如果有，就以此位置为结束位置，从可读索引到结束位置区间的字节就组成了一行。它是以换行符为结束标志的解码器，支持携带结束符或者不携带结束符两种解码方式，同时支持配置单行的最大长度。如果连续读取到最大长度后仍然没有发现换行符，就会抛出异常，同时忽略掉之前读到的异常码流。

​	StringDecoder的功能非常简单，就是将接收到的对象转换成字符串，然后继续调用后面的 handler。LineBasedFrameDecoder + StringDecoder组合就是按行切换的文本解码器，它被设计用来支持TCP的粘包和拆包。

​	对于使用者来说，只要将支持半包解码的handler添加到ChannelPipeline中即可。

![image-20210323113923086](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162931.png)

![image-20210323114002836](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162932.png)

# 第五章 分隔符和定长解码器的应用

## 5.1 DelimiterBasedFrameDecoder

![image-20210323114036555](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162933.png)

![image-20210323114103812](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162934.png)

## 5.2 FixedLengthFrameDecoder

![image-20210323114357548](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162935.png)

# 第六章 编解码技术

​	JDK默认的序列化方式在序列化后的码流大小和序列化的性能上都是很差。

## 6.1 Google的Protobuf

​	Protobuf全称Google Protocol Buffers，它由谷歌开源而来，在谷歌内部久经考验。它将数据结构以.proto文件进行描述，通过代码生成工具可以生成对应数据结构的POJO对象和 Protobuf相关的方法和属性。它的特点如下:

*   结构化数据存储格式(XML，JSON等);
*   高效的编解码性能
*   语言无关、平台无关、扩展性好;
*   官方支持Java、C++和 Python三种语言。

​	XML解析的时间开销和XML 为了可读性而牺牲的空间开销都非常大，因此不适合做高性能的通信协议。Protobuf使用二进制编码，在空间和性能上具有更大的优势。

Protobuf另一个比较吸引人的地方就是它的数据描述文件和代码生成机制，利用数据描述文件对数据结构进行说明的优点如下。

*   文本化的数据结构描述语言，可以实现语言和平台无关，特别适合异构系统间的集成
*   通过标识字段的顺序，可以实现协议的前向兼容
*   自动代码生成，不需要手工编写同样数据结构的C++和 Java版本
*   方便后续的管理和维护.相比于代码，结构化的文档更容易管理和维护

## 6.2 Facebook的Thrift

​	在多种不同的语言之间通信，Thrift可以作为高性能的通信中间件使用，它支持数据(对象）序列化和多种类型的RPC服务。Thrift 适用于静态的数据交换，需要先确定好它的数据结构，当数据结构发生变化时，必须重新编辑IDL文件，生成代码和编译，这一点跟其他IDL工具相比可以视为是Thrift的弱项。Thrift适用于搭建大型数据交换及存储的通用工具，对于大型系统中的内部数据传输，相对于JSON和XML 在性能和传输大小上都有明显的优势。Thrift主要由5部分组成。

1.  语言系统以及IDL编译器:负责由用户给定的IDL文件生成相应语言的接口代码
2.  TProtocol: RPC的协议层，可以选择多种不同的对象序列化方式，如JSON和 Binary
3.  TTransport: RPC 的传输层，同样可以选择不同的传输层实现，如 socket、NIO、MemoryBuffer 等;
4.  TProcessor:作为协议层和用户提供的服务实现之间的纽带，负责调用服务实现的接口;
5.  TServer:聚合TProtocol、TTransport 和 TProcessor等对象。

## 6.3 JBoss的Marshalling

​	JBoss Marshalling 是一个Java对象的序列化API包，修正了JDK自带的序列化包的很多问题，但又保持跟 java.io.Serializable 接口的兼容;同时增加了一些可调的参数和附加的特性，并且这些参数和特性可通过工厂类进行配置。

​	相比于传统的Java序列化机制，它的优点如下:

*   可插拔的类解析器，提供更加便捷的类加载定制策略，通过一个接口即可实现定制
*   可插拔的对象替换技术，不需要通过继承的方式
*   可插拔的预定义类缓存表，可以减小序列化的字节数组长度，提升常用类型的对象序列化性能
*   无须实现java.io.Serializable接口，即可实现Java序列化
*   通过缓存技术提升对象的序列化性能。
    

#  第七章 Java序列化

![image-20210323152343431](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162936.png)

![image-20210323152441030](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162937.png)

# 第八章 Google Protobuf编解码

​	Protobuf的优点：

1.  在谷歌内部长期使用，产品成熟度高
2.  跨语言，支持多种语言，包括C++、Java和 Python
3.  编码后的消息更小，更加有利于存储和传输
4.  编解码的性能非常高
5.  支持不同协议版本的前向兼容
6.  支持定义可选和必选字段

## 8.1 Protobuf入门

1.  下载 https://github.com/protocolbuffers/protobuf/releases/download/v2.5.0/protoc-2.5.0-win32.zip

2.  编写.proto文件

    

![image-20210323162303187](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162938.png)

![image-20210323162315752](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162939.png)

3.  生成命令

    protoc.exe --java_out=.\src .\netty\SubscribeReq.proto

    protoc.exe --java_out=.\src .\netty\SubscribeResp.proto

![image-20210323162508903](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162940.png)

## 8.2 Netty融合Protobuf

![image-20210323162621461](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162941.png)

![image-20210323162652781](https://mdimgz.oss-cn-shanghai.aliyuncs.com/image/20210323162942.png)

## 8.3 注意事项

​	ProtobufDecoder仅仅负责解码，它不支持读半包。因此，在 ProtobufDecoder前面，一定要有能够处理读半包的解码器，有三种方式可以选择。

*   使用 Netty提供的 ProtobufVarint32FrameDecoder，它可以处理半包消息
*   继承Netty提供的通用半包解码器LengthFieldBasedFrameDecoder
*   继承 ByteToMessageDecoder类，自己处理半包消息

# 第九章 JBoss Marshalling编解码

