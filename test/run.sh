#!/bin/bash
cd $(dirname $0)
cd ../demo

./mvnw clean compile
ret=$?
if [ $ret -ne 0 ]; then
exit $ret
fi
rm -rf target

rm -rf target

exit