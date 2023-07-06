# Qt5 Library Package for OpenWrt

Cross compile the Qt5 Core library for OpenWRT platform.

## Target OpenWrt Versions

Please choose the branch for target device OpenWrt version.

## Configure Qt Modules and Features

You can see all the modules available by browsering the folders of Qt5 source code.  
For example, qtchart is a module under qt-everywhere-src-5.11.3. You can modify the Makefile to disable/enable this module.  

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

OpenWrt compiler is required.

1. Under Ubuntu 18.04
2. Install dependencies by

    ```bash
    sudo apt install build-essential ccache ecj fastjar file flex g++ gawk gettext git java-propose-classpath java-wrappers jq libelf-dev libffi-dev libncurses5-dev libncursesw5-dev libssl-dev libtool python2.7 python2.7-dev python3 python3-dev python3-distutils python3-setuptools rsync subversion swig time u-boot-tools unzip wget xsltproc zlib1g-dev bison
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    # Close and open a new terminal
    nvm install v12
    # Close and open a new terminal
    ```

3. Download your [target device SDK](https://wiki.teltonika-networks.com/gpl/RUT9_R_GPL_00.07.04.4.tar.gz)  

4. Extract the SDK by

    ```bash
    tar -xvf RUT*.tar.gz
    ```

5. Update feeds and compile standard firmware by

    ```bash
    ./scripts/feeds update -a
    # have a walk outside
    make
    # have another walk outside
    ```

6. Clone this repo to the `SDK/packages`

7. Configure by  

    ```bash
    make menuconfig
    # Go to Libraries --> Qt5
    # Set <M> qt5-core
    # Set <M> qt5-network
    # Exit and Save
    ```

8. Compile by  

    ```bash
    make package/qt5-openwrt-package/compile V=s
    ```

9. It will take a long time to build  

10. You can find compiled ipk files in `SDK/bin/packages/mips_24kc/base`

## Install the Compiled Shared Library to Target Device

1. Copy compiled ipk files to the target device by scp

2. Install ipk files by

    ```bash
    opkg install qt5-core_5.11-3_mips_24kc.ipk
    opkg install qt5-network_5.11-3_mips_24kc.ipk
    ```

## Hello World Application

1. At the root of SDK, execute following command

    ```bash
    make -C scripts/config/ clean
    ./staging_dir/host/bin/usign -G -s ./key-build -p ./key-build.pub -c "Local build key"
    make
    ```

2. then, go to the qt source code and make install by

    ```bash
    cd build_dir/target-mips_24kc_musl/qt-everywhere-src-5.11.3/
    make install
    ```

3. On your Ubuntu, please install qtcreator and other tools by

    ```bash
    sudo apt install qtcreator qt5-default build-essential
    ```

4. Add a new QT Device: QT Creator --> Tools --> Options --> Devices --> Add --> Generic Linux Device
    * Name: OpenWrt Device
    * Authentication Type: Password
    * Host address: Your device ip address
    * SSH port: 22
    * Username: your device username
    * Password: your device password

5. Set a new compiler: QT Creator --> Tools --> Options --> Build & Run --> Compilers --> Add --> GCC --> for both C/C++
    * Name: OpenWrt GCC and OpenWrt G++
    * ABI: mips-linux-generic-elf-32bit
    * Compiler path (GCC): staging_dir/toolchain-mips_24kc_gcc-8.4.0_musl/bin/mips-openwrt-linux-musl-gcc
    * Compiler path (G++): staging_dir/toolchain-mips_24kc_gcc-8.4.0_musl/bin/mips-openwrt-linux-musl-g++

6. Set a new debugger: QT Creator --> Tools --> Options --> Build & Run --> Debuggers --> Add
    * Name: OpenWrt Debugger
    * Path: staging_dir/toolchain-mips_24kc_gcc-8.4.0_musl/bin/mips-openwrt-linux-musl-gdb

7. Set a Qt5 version: QT Creator --> Tools --> Options --> Build & Run --> Qt Versions --> Add
    * qmake location: staging_dir/toolchain-mips_24kc_gcc-8.4.0_musl/bin/qmake

8. Add a new Kit: QT Creator --> Tools --> Options --> Build & Run --> Kits --> Add
    * Name: OpenWrt Kit
    * Device Type: Generic Linux Device
    * Device: OpenWrt Device (default for Generic Linux)
    * Compiler: C, OpenWrt GCC; C++, OpenWrt G++
    * Debugger: OpenWrt Debugger
    * Qt version: Qt 5.11.3

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

* OpenWRT 22.03 based industrial 4G router

## Acknowledgments

* Forked from <https://github.com/pawelkn/qt5-openwrt-package>  
* Updated by <https://github.com/vonger>  
* Inspired by <http://vonger.cn/?p=14588>  
