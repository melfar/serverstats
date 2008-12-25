#!/bin/sh

echo Copying /Library/Widgets/Server\ Status.wdgt/ ServerStats.wdgt
cp -R /Library/Widgets/Server\ Status.wdgt/ ServerStats.wdgt
cp -v base64.js jquery.js jquery.json-1.3.js ServerStatsAgent.js ServerStats.wdgt/
pushd ServerStats.wdgt && patch < ../patch && popd
