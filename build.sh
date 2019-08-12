#!/bin/bash

set -eu

PLUGIN_NAME="rundeck-nginxplus-upstream-plugin"

#Get base directoru
BASE_DIR=$(pwd)

#Create build directory
BUILD_DIR="$BASE_DIR/build"
mkdir -p "$BUILD_DIR"

#Validate if plugin.yaml file exists
if [ ! -f "$BASE_DIR/plugin.yaml" ] ; then
    echo "plugin.yaml file is missing"
    exit 1
fi

#Validate if contents dir exists and it's not empty
if [ ! -d "$BASE_DIR/contents" ] ; then
    echo "contents directory is missing"
    exit 1
elif [ -z "$(ls -A $BASE_DIR/contents)" ] ; then
    echo "contents directory is empty"
    exit 1
fi

#Building plugin
echo "Building plugin..."
mkdir -p "$BUILD_DIR/$PLUGIN_NAME"
cp "$BASE_DIR/plugin.yaml" "$BUILD_DIR/$PLUGIN_NAME/"
cp -r "$BASE_DIR/contents" "$BUILD_DIR/$PLUGIN_NAME/"
cd $BASE_DIR/build
zip -r $PLUGIN_NAME.zip $PLUGIN_NAME -x \.git \.gitignore \.DS_Store

if [ "$?" = "0" ] ; then
    echo "Build successful"
else
    echo "Build filed"
    exit 1
fi

#Removing tmp files
echo "Removing tmp files"
rm -rf "$BUILD_DIR/$PLUGIN_NAME"