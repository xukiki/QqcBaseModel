#!/bin/bash

version=$1

echo $version

sed -i "" "s/[0-9]*\.[0-9]*\.[0-9]*/$version/g" QqcBaseModel.podspec
