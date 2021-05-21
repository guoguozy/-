FROM eclipse/cpp_gcc:latest

ADD . /home/app
ADD sources.list /etc/apt
ENV DEBIAN_FRONTEND=noninteractive
 
# 添加源
RUN sudo apt-get update
RUN sudo apt-get install -y --assume-yes apt-transport-https ca-certificates curl software-properties-common
RUN sudo apt-get install -y --assume-yes apt-utils && sudo apt-get install -y vim libssl-dev environment-modules


#openssl
WORKDIR /home/app
RUN sudo apt-get update \  
	&& sudo apt-get install -y build-essential checkinstall zlib1g-dev libtemplate-perl
RUN sudo tar -zxvf openssl-1.0.2p.tar.gz
WORKDIR /home/app/openssl-1.0.2p
RUN sudo ./config
RUN sudo make && sudo make test && sudo make install
RUN export PATH="/usr/local/ssl/bin:$PATH" \
	&& export OPENSSL_ROOT_DIR="/usr/local/ssl" \
	&& export OPENSSL_CRYPTO_DIR="/usr/local/ssl/lib" \
	&& export OPENSSL_INCLUDE_DIR="/usr/local/ssl/include" 
ENV PATH "/usr/local/ssl/bin:$PATH"
ENV OPENSSL_ROOT_DIR="/usr/local/ssl" 
ENV OPENSSL_CRYPTO_DIR="/usr/local/ssl/lib" 
ENV OPENSSL_INCLUDE_DIR="/usr/local/ssl/include" 

#cmake
WORKDIR /home/app
RUN sudo tar -zxvf cmake-3.19.8.tar.gz
WORKDIR /home/app/cmake-3.19.8
RUN sudo ./bootstrap && sudo make && sudo make install
RUN export PATH="/usr/local/cmake/bin:$PATH"

#module
RUN echo "source /usr/share/modules/init/bash" >> ~/.bashrc
RUN echo "export MODULEPATH=/etc/modulefiles" >> ~/.bashrc

#gmsh
RUN sudo apt-get install -y gmsh


#OOFEM
WORKDIR /home/app
RUN git clone https://github.com/oofem/oofem.git
WORKDIR /home/app/oofem
RUN sudo mkdir  build
WORKDIR /home/app/oofem/build
RUN sudo cmake .. && sudo make

#DeepMD
WORKDIR /home/app
RUN git clone --recursive https://github.com/deepmodeling/deepmd-kit.git deepmd-kit
WORKDIR /home/app/deepmd-kit
RUN deepmd_source_dir=`pwd`
WORKDIR /home/app/deepmd-kit/source
RUN sudo mkdir build 
WORKDIR /home/app/deepmd-kit/source/build
RUN sudo cmake -DTENSORFLOW_ROOT=$tensorflow_root -DCMAKE_INSTALL_PREFIX="/usr/local/deepmd" .. && sudo make && sudo make install 

