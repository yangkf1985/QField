#!/bin/bash

docker run -i --rm -v $(pwd):/usr/src forderud/qtwasm:qt-5.15 /usr/src/scripts/qmlformat-wrapper.sh $@
