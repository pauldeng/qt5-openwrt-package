# Qt5 Library Package for OpenWRT

Cross compile the Qt5 Core library for OpenWRT MIPS platform.

## Target OpenWRT Versions

This branch is for OpenWRT v21.02.

## Configure Qt Modules and Features

You can see all the modules available by browsering the folders of Qt5 source code.  
For example, qtchart is a module under qt-everywhere-src-5.12.12. You can modify the Makefile to disable/enable this module.  

You can see all the features available by following command.

```bash
./configure --list-features
```

You can modify the Makefile to disable/enable this feature.  

For more information, please refer to <https://doc.qt.io/qt-5/configure-options.html>.

## Special Cases

### Not enough space in /usr/lib/

* If the target device has not enough space to install the library, you could choose to install the library to /tmp/. However, /tmp/ resides in ram and will be lost after reboot.  
* If the target device has enough space to install the library, you need to modify the Makefile.  

## How to Compile Shared Library

[![Cross Compile Qt5 for OpenWrt](https://img.youtube.com/vi/4yuvjuDuCLY/0.jpg)](https://www.youtube.com/watch?v=4yuvjuDuCLY)

OpenWRT compiler is required.

1. Download SDK, for example <https://archive.openwrt.org/releases/21.02.7/targets/ramips/mt76x8/openwrt-sdk-21.02.7-ramips-mt76x8_gcc-8.4.0_musl.Linux-x86_64.tar.xz>  or alternatively <https://dengpeng.de/wp-content/uploads/2025/10/openwrt-sdk-ramips-mt76x8_gcc-8.4.0_musl.Linux-x86_64.tar.xz>
2. Extract the SDK  
3. Clone this repo  
4. Put this repo into SDK/package  
5. Install dependencies by  

    ```bash
    sudo apt install libncurses-dev zlib1g-dev gawk subversion python build-essential ccache
    ```

6. Compile by  

    ```bash
    make package/qt5-openwrt-package/compile V=s
    ```

7. It will take a long time to build  
8. You can find compiled ipk files in SDK/bin/  

## Install the Compiled Shared Library to Target Device

1. Copy compiled ipk files to the target device by scp  
2. Install ipk files by  

    ```bash
    opkg install qt5-core_5.12-12_ramips_24kec.ipk
    opkg install qt5-network_5.12-12_ramips_24kec.ipk
    ```

## Hello World Application

1. At the root of SDK, execute following command

    ```bash
    make -C scripts/config/ clean  
    make
    ```

2. then, go to the qt source code and make install by

    ```bash
    cd  build_dir/target-mipsel_24kec+dsp_uClibc-0.9.33.2/qt-everywhere-src-5.12.12  
    make install
    ```

3. On your Ubuntu, please install qtcreator and other tools by

    ```bash
    sudo apt install qtcreator qt5-default build-essential  
    ```

4. Add a new QT Device: QT Creator --> Tools --> Options --> Devices --> Add --> Generic Linux Device
    * Name: OpenWrt Device
    * Authentcation Type: Password
    * Host address: Your device ip address
    * SSH port: 22
    * Username: your device username
    * Password: your device password

5. Set a new compiler: QT Creator --> Tools --> Options --> Build & Run --> Compilers --> Add --> GCC --> for both C/C++
    * Name: OpenWrt GCC and OpenWrt G++
    * ABI: mips-linux-generic-elf-32bit
    * Compiler path (GCC): staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_uClibc-0.9.33.2/bin/mipsel-openwrt-linux-uclibc-gcc
    * Compiler path (G++): staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_uClibc-0.9.33.2/bin/mipsel-openwrt-linux-uclibc-g++

6. Set a new debugger: QT Creator --> Tools --> Options --> Build & Run --> Debuggers --> Add  
    * Name: OpenWrt Debugger
    * Path: staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_uClibc-0.9.33.2/bin/mipsel-openwrt-linux-uclibc-gdb

7. Set a Qt5 version: QT Creator --> Tools --> Options --> Build & Run --> Qt Versions --> Add
    * qmake location: staging_dir/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_uClibc-0.9.33.2/bin/qmake

8. Add a new Kit: QT Creator --> Tools --> Options --> Build & Run --> Kits --> Add
    * Name: OpenWrt Kit
    * Device Type: Generic Linux Device
    * Device: OpenWrt Device (default for Generic Linux)
    * Compiler: C, OpenWrt GCC; C++, OpenWrt G++
    * Debugger: OpenWrt Debugger
    * Qt version: Qt 5.12.12

9. Create a New Project --> Qt Console Application --> Choose... --> Name: helloWorld --> qmake --> OpenWrt Kit --> Finsh

    ```cpp
    #include <QTextStream>
    int main()
    {
        QTextStream(stdout) << "Hello World!" << endl;
        return 0;
    }
    ```

10. Build. Transfer to your target device and run.

## Tested Hardware Platform

* OpenWRT 21.02 based industrial 4G router

## Acknowledgments

* Forked from <https://github.com/pawelkn/qt5-openwrt-package>  
* Updated by <https://github.com/vonger>  
* Inspired by <http://vonger.cn/?p=14588>  
