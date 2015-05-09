#!/bin/bash

GIT_BIN=/usr/local/git/bin/git
TOMCAT_HOME=/usr/local/apache-tomcat-7.0.61
BUILD_DIR=$HOME/Projects1
PROJECT_GIT=https://github.com/chrisgonsalves/ProjectXServingSystem.git
MVN_BIN=/usr/bin/mvn
GIT_PATH=https://github.com/chrisgonsalves/ProjectXServingSystem.git

#init
sudo -v

pushd `pwd`

if [ ! -d $TOMCAT_HOME ]; then
    echo "Tomcat 7.0.61 not installed at $TOMCAT_HOME" 
    popd 
    exit -1;
fi

chmod -R 755 $TOMCAT_HOME/bin/shutdown.sh
chmod -R 755 $TOMCAT_HOME/bin/startup.sh
chmod -R 755 $TOMCAT_HOME/bin/catalina.sh

if [ ! -d $BUILD_DIR ]; then
    mkdir $BUILD_DIR
fi

if [ -d $BUILD_DIR/ProjectXServingSystem ]; then
    rm -rf $BUILD_DIR/ProjectXServingSystem
fi

#fetch
$GIT_BIN clone $GIT_PATH $BUILD_DIR/ProjectXServingSystem
if [ $? -ne 0 ]; then
    echo "Failed to fetch project from github - $GIT_PATH\n";
    popd 
    exit -1;
fi

#package
cd $BUILD_DIR/ProjectXServingSystem
$MVN_BIN package

if [ "`ps -ef | grep tomcat | grep -v grep | awk '{print $2}'`" != "" ]; then
    $TOMCAT_HOME/bin/shutdown.sh
    if [ $? -ne 0 ]; then
        echo "Failed to shutdown Tomcat Server\n";
        popd 
        exit -1;
    fi
fi

#push to webapp
if [ -d $TOMCAT_HOME/webapps/ProjectXServingSystem ]; then
    rm -r $TOMCAT_HOME/webapps/ProjectXServingSystem
fi
cp target/ProjectXServingSystem.war $TOMCAT_HOME/webapps/

$TOMCAT_HOME/bin/startup.sh
if [ $? -ne 0 ]; then
    echo "Failed to start Tomcat Server\n";
    popd 
    exit -1;
fi

popd 

