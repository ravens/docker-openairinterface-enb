FROM ubuntu:16.04
MAINTAINER Yan Grunenberger <yan@grunenberger.net>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -yq dist-upgrade 
# Dependencies for the UHD driver for the USRP hardware
RUN apt-get -yq install autoconf build-essential libusb-1.0-0-dev cmake wget pkg-config libboost-all-dev python-dev python-cheetah git subversion python-software-properties

# Dependencies for UHD image downloader script
RUN apt-get -yq install python-mako python-requests 

# Fetching the uhd 3.010.001 driver for our USRP SDR card 
RUN wget http://files.ettus.com/binaries/uhd/uhd_003.010.001.001-release/uhd-3.10.1.1.tar.gz && tar xvzf uhd-3.10.1.1.tar.gz && cd UHD_3.10.1.1_release && mkdir build && cd build && cmake ../ && make && make install && ldconfig && python /usr/local/lib/uhd/utils/uhd_images_downloader.py

# Dependencies for OpenAirInterface software
RUN apt-get -yq install autoconf  \
	automake  \
	bison  \
	build-essential \
	cmake \
	cmake-curses-gui  \
	doxygen \
	doxygen-gui \
	texlive-latex-base \
	ethtool \
	flex  \
	gccxml \
	gdb  \
	git \
	graphviz \
	gtkwave \
	guile-2.0-dev  \
	iperf \
	iproute \
	iptables \
	iptables-dev \
	libatlas-base-dev \
	libatlas-dev \
	libblas-dev \
	libconfig8-dev \
	libforms-bin \
	libforms-dev \
	libgcrypt11-dev \
	libgmp-dev \
	libgtk-3-dev \
	libidn2-0-dev  \
	libidn11-dev \
	libmysqlclient-dev  \
	liboctave-dev \
	libpgm-dev \
	libsctp1  \
	libsctp-dev  \
	libssl-dev  \
	libtasn1-dev  \
	libtool  \
	libusb-1.0-0-dev \
	libxml2 \
	libxml2-dev  \
	mscgen  \
	octave \
	octave-signal \
	openssh-client \
	openssh-server \
	openssl \
	python  \
	subversion \
	xmlstarlet \
	python-pip \
	pydb \
	wvdial \
        python-numpy \
        sshpass
RUN apt-get install -qy libgnutls-dev nettle-dev nettle-bin 
RUN apt-get install -qy 	check \
	dialog \
	dkms \
	gawk \
	libboost-all-dev \
	libpthread-stubs0-dev \
	openvpn \
	pkg-config \
	python-dev  \
	python-pexpect \
	sshfs \
	swig  \
	tshark \
	uml-utilities \
	unzip  \
	valgrind  \
	vlan	  \
	ctags \
        ntpdate
RUN apt-get -qy install libffi-dev libxslt1-dev
RUN pip install --upgrade pip
RUN pip install paramiko==1.17.1
RUN pip install pyroute2
RUN update-alternatives --set liblapack.so /usr/lib/atlas-base/atlas/liblapack.so

# ASN1 compiler with Eurecom fixes
WORKDIR /root
RUN git clone https://gitlab.eurecom.fr/oai/asn1c.git 
RUN cd asn1c && ./configure && make -j`nproc` && make install

# Fetching the develop repository
RUN git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git 
RUN cd openairinterface5g && git checkout develop 

# Compile
WORKDIR /root/openairinterface5g
RUN cd cmake_targets && mkdir -p lte_build_oai/build 
WORKDIR /root/openairinterface5g/cmake_targets/lte_build_oai

# CmakeLists generation
RUN echo "cmake_minimum_required(VERSION 2.8)"   					> CMakeLists.txt
RUN echo "set ( CMAKE_BUILD_TYPE \"\" )" 							>> CMakeLists.txt
RUN echo "set ( CFLAGS_PROCESSOR_USER \"\" )" 						>> CMakeLists.txt
RUN echo "set ( RRC_ASN1_VERSION \"Rel14\")" 						>> CMakeLists.txt
RUN echo "set ( ENABLE_VCD_FIFO \"False\")"     					>> CMakeLists.txt
RUN echo "set ( RF_BOARD \"OAI_USRP\")" 							>> CMakeLists.txt
RUN echo "set ( TRANSP_PRO \"None\")" 								>> CMakeLists.txt
RUN echo "set(PACKAGE_NAME \"lte-softmodem\")" 						>> CMakeLists.txt
RUN echo "set (DEADLINE_SCHEDULER \"False\" )" 						>> CMakeLists.txt
RUN echo "set (CPU_AFFINITY \"False\" )" 							>> CMakeLists.txt
RUN echo "set ( T_TRACER \"False\" )"              					>> CMakeLists.txt
RUN echo "set (UE_AUTOTEST_TRACE \"False\")"     					>> CMakeLists.txt
RUN echo "set (UE_DEBUG_TRACE \"False\")"    						>> CMakeLists.txt
RUN echo "set (UE_TIMING_TRACE \"False\")" 							>> CMakeLists.txt
RUN echo "set (DISABLE_LOG_X \"False\")"   							>> CMakeLists.txt
RUN echo 'include(${CMAKE_CURRENT_SOURCE_DIR}/../CMakeLists.txt)'   >> CMakeLists.txt

WORKDIR /root/openairinterface5g/cmake_targets/lte_build_oai/build
RUN OPENAIR_HOME=/root/openairinterface5g OPENAIR_DIR=$OPENAIR_HOME OPENAIR1_DIR=$OPENAIR_HOME/openair1 OPENAIR2_DIR=$OPENAIR_HOME/openair2 OPENAIR3_DIR=$OPENAIR_HOME/openair3 OPENAIR_TARGETS=$OPENAIR_HOME/targets cmake ../
RUN make -j`nproc` lte-softmodem
RUN make -j`nproc` oai_usrpdevif
RUN ln -sf liboai_usrpdevif.so liboai_device.so

# Add a sample configuration file
ADD enb.conf /config/enb.conf

# Run directly the eNodeB code 
ENTRYPOINT ["/root/openairinterface5g/cmake_targets/lte_build_oai/build/lte-softmodem", "-O", "/config/enb.conf"]
