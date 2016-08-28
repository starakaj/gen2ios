#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# perl -pi -e 's/<key>version<\/key><integer>66816<\/integer>/<key>version<\/key><integer>$RANDOM<\/integer>' $DIR/../OSX/OSXAUGenExportAppExtension/Info.plist
perl -pi -e 's/typedef double t_sample;/typedef float t_sample;/' $DIR/gen_dsp/genlib_common.h
xcodebuild -project $DIR/../AUGenExport.xcodeproj/ -target OSXAUGenExportAppExtension install