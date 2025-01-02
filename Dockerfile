# Check https://nightlies.apache.org/flink/flink-docs-master/docs/deployment/resource-providers/standalone/docker/#using-flink-python-on-docker for more details
FROM apache/flink:1.16.3-scala_2.12-java8

# 更换为阿里云镜像源
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装编译Python所需依赖
RUN apt-get update -y && \
    apt-get install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libffi-dev \
    wget

# 下载并编译安装Python 3.7
RUN wget https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz && \
    tar -xvf Python-3.7.9.tgz && \
    cd Python-3.7.9 && \
    ./configure --without-tests --enable-shared && \
    make -j6 && \
    make install && \
    ldconfig /usr/local/lib && \
    cd .. && \
    rm -f Python-3.7.9.tgz && \
    rm -rf Python-3.7.9 && \
    ln -s /usr/local/bin/python3 /usr/local/bin/python

# 清理apt缓存
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装PyFlink
RUN pip3 install "apache-flink>=1.16.0,<1.17.1"

# 添加python脚本
USER flink
RUN mkdir /opt/flink/usrlib
ADD python_demo.py /opt/flink/usrlib/python_demo.py
