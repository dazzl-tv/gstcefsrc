all:
	mkdir build-cef-104/
	cd build-cef-104/ && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release .. && make V=1
	#cp ./libgstrtspclientsink.so ./build-cef-104/Release
	rm -fR third_party/

clean:
	cd build-cef-104/ && make clean

distclean:
	rm -fR build-cef-104/
	mkdir  build-cef-104/
	cd     build-cef-104/ && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release .. && make V=1

phony: all clean distclean
