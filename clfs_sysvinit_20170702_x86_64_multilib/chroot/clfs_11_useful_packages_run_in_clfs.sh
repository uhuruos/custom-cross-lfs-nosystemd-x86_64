#!/bin/bash

function checkBuiltPackage() {

echo "Did everything build fine?: [Y/N]"
while read -n1 -r -p "[Y/N]   " && [[ $REPLY != q ]]; do
  case $REPLY in
    Y) break 1;;
    N) echo "$EXIT"
       echo "Fix it!"
       exit 1;;
    *) echo " Try again. Type y or n";;
  esac
done

}

#Building the final CLFS System
CLFS=/
CLFSHOME=/home
CLFSSOURCES=/sources
CLFSTOOLS=/tools
CLFSCROSSTOOLS=/cross-tools
CLFSFILESYSTEM=ext4
CLFSROOTDEV=/dev/sda4
CLFSHOMEDEV=/dev/sda5
MAKEFLAGS=j8
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"

export CLFS=/
export CLFSUSER=clfs
export CLFSHOME=/home
export CLFSSOURCES=/sources
export CLFSTOOLS=/tools
export CLFSCROSSTOOLS=/cross-tools
export CLFSFILESYSTEM=ext4
export CLFSROOTDEV=/dev/sda4
export CLFSHOMEDEV=/dev/sda5
export MAKEFLAGS=j8
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"

#=================
#YOUR SYSTEM STANDS AND BOOTS UP?
#NOW THEN, let's install some useful packages
#to make further progress easier
#=================

cd ${CLFSSOURCES}

#OpenSSL 32-bit
mkdir openssl && tar xf openssl-*.tar.* -C openssl --strip-components 1
cd openssl

./Configure linux-x86_64-32 --openssldir=/etc/ssl --prefix=/usr shared
PKG_CONFIG_PATH=${PKG_CONFIG_PATH32} \
USE_ARCH=32 make CC="gcc ${BUILD32}" PERL=/usr/bin/perl-32
USE_ARCH=32 make PERL=/usr/bin/perl-32 MANDIR=/usr/share/man install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf openssl

#OpenSSL 64-bit
mkdir openssl && tar xf openssl-*.tar.* -C openssl --strip-components 1
cd openssl

./Configure linux-x86_64-64 --openssldir=/etc/ssl --prefix=/usr shared
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 LIBDIR=lib64 make CC="gcc ${BUILD64}" PERL=/usr/bin/perl-64
USE_ARCH=64 LIBDIR=lib64 make PERL=/usr/bin/perl-64 MANDIR=/usr/share/man install

cp -v -r certs /etc/ssl &&
install -v -d -m755 /usr/share/doc/openssl-1.1.0f &&
cp -v -r doc/{HOWTO,README,*.{txt,html,gif}} \
    /usr/share/doc/openssl-1.1.0f


cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf openssl

#Install CA Certificates
cd ${CLFSSOURCES}

install -vdm755 /etc/ssl/local &&
openssl x509 -in root.crt -text -fingerprint -setalias "CAcert Class 1 root" \
        -addtrust serverAuth -addtrust emailProtection -addtrust codeSigning \
        > /etc/ssl/local/CAcert_Class_1_root.pem
install -vm755 make-ca.sh-20170514 /usr/sbin/make-ca.sh
/usr/sbin/make-ca.sh

#Wget
mkdir wget && tar xf wget-*.tar.* -C wget --strip-components 1
cd wget 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure --prefix=/usr \
  --sysconfdir=/etc \
  --libdir=/usr/lib64 \
  --with-ssl=openssl

PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf wget

#Curl
wget https://curl.haxx.se/download/curl-7.54.1.tar.lzma
mkdir curl && tar xf curl-*.tar.* -C curl --strip-components 1
cd curl

CC="gcc ${BUILD64}" USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
  ./configure --prefix=/usr \
  --libdir=/usr/lib64 \
  --disable-static \
  --enable-threaded-resolver \
  --with-ca-path=/etc/ssl/certs \
  --with-ca-bundle=/etc/ssl/ca-bundle.crt

PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install

find docs \( -name Makefile\* \
          -o -name \*.1       \
          -o -name \*.3 \)    \
          -exec rm {} \;      &&
install -v -d -m755 /usr/share/doc/curl-7.54.1 &&
cp -v -R docs/*     /usr/share/doc/curl-7.54.1

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf curl

#Git
wget https://www.kernel.org/pub/software/scm/git/git-2.13.3.tar.xz
mkdir git && tar xf git-*.tar. -C git --strip-components 1
cd git

USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure --prefix=/usr \
   --libexecdir=/usr/lib64 \
   --sysconfdir=/etc  \
   --with-gitconfig=/etc/gitconfig

PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf git

#openSSH
mkdir openssh && tar xf openssh-*.tat.* -C openssh --strip-components 1
cd openssh



cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf openssh
