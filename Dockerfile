## build : docker build -t openair4g .
## run :   docker run --net=host --rm --privileged -v /dev/bus/usb:/dev/bus/usb -it openair4g
## run your own config and with a PCAP :   docker run --rm --net=host --privileged -v /dev/bus/usb:/dev/bus/usb -v /YOURCONFIGDIRECTORY:/root --entrypoint /openairinterface5g/targets/bin/lte-softmodem.Rel14 openair4g -P /root/capture.pcap  -O /root/enb.conf
FROM ubuntu:14.04
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
	libblas3gf \
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
	libpgm-5.1 \
	libpgm-dev \
	libsctp1  \
	libsctp-dev  \
	libssl-dev  \
	libtasn1-3-dev  \
	libtool  \
	libusb-1.0-0-dev \
	libxml2 \
	libxml2-dev  \
	linux-headers-`uname -r` \
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
RUN pip install paramiko==1.18.0
RUN pip install pyroute2
RUN update-alternatives --set liblapack.so /usr/lib/atlas-base/atlas/liblapack.so

# Fetching the SSL certificate of Eurecom
RUN echo -n | openssl s_client -showcerts -connect gitlab.eurecom.fr:443 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> /etc/ssl/certs/ca-certificates.crt

# Fetching the develop repository
RUN git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git && cd openairinterface5g && git checkout develop 

# ASN1 compiler with Eurecom fixes
RUN rm -rf /tmp/asn1c && GIT_SSL_NO_VERIFY=true git clone https://gitlab.eurecom.fr/oai/asn1c.git /tmp/asn1c && cd /tmp/asn1c && ./configure && make -j`nproc` && make install

# Building the OpenAirInterface eNodeB for USRP
RUN cd /openairinterface5g && /bin/bash -c "source oaienv" && cd cmake_targets && ./build_oai -I -w USRP --eNB -x

# Add a sample configuration file
ADD enb.conf /root/enb.conf

# Run directly the eNodeB code 
ENTRYPOINT /openairinterface5g/targets/bin/lte-softmodem.Rel14 -O /root/enb.conf
