# ADS-B/SDR image for armhf architecture. This will NOT work on x86 platforms.
#
# Build an image using this Dockerfile as shown below:
#
#    $ docker build . -t <name>
#
# Start Dump1090 Server in a container based on the newly created image as
# shown below:
#
#    $ docker run -d --privileged -v /dev/bus/usb:/dev/bus/usb -p 30002:30002 <image_id>
#
# Attach to the container to see the ADS-B messages being received from SDR
# as shown below:
#
#    $ docker attach <container_id>
#
# <container_id> is generated when the image is run.
#
FROM resin/rpi-raspbian:jessie-20160831 

RUN apt-get update && \  
    apt-get -qy install curl ca-certificates
RUN apt-get upgrade && \
    apt-get dist-upgrade
RUN apt-get install build-essential
RUN apt-get install apt-utils
RUN apt-get install usbutils
RUN apt-get install pkg-config
RUN apt-get install cmake
RUN apt-get install libusb-1.0-0-dev
RUN apt-get install git-core git

RUN git clone git://git.osmocom.org/rtl-sdr.git /tmp/rtl-sdr
WORKDIR /tmp/rtl-sdr
RUN cmake ./ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON
RUN make
RUN make install
RUN ldconfig

RUN git clone https://github.com/MalcolmRobb/dump1090 /tmp/dump1090
WORKDIR /tmp/dump1090
RUN make

EXPOSE 30002
CMD ["./dump1090", "--raw", "--net"]

