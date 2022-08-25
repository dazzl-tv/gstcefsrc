all:
	mkdir build-cef-104/
	cd build-cef-104/ && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release .. && make V=1
	wget --content-disposition https://packagecloud.io/dazzltv/public-debpkg/packages/ubuntu/focal/rtspclientsink_1.16.2_all.deb/download.deb
	dpkg-deb -xv rtspclientsink_1.16.2_all.deb .
	cp ./usr/lib/x86_64-linux-gnu/gstreamer-1.0/libgstrtspclientsink.so ./build-cef-104/Release
	rm -f rtspclientsink_1.16.2_all.deb
	rm -fR usr/
	rm -fR third_party/

clean:
	cd build-cef-104/ && make clean

distclean:
	rm -fR build-cef-104/
	mkdir  build-cef-104/
	cd     build-cef-104/ && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release .. && make V=1

phony: all clean distclean
