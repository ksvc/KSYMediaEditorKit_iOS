#! /bin/sh
if which xcpretty > /dev/null 2>&1;
then
    XCPRETTY=xcpretty
else
    XCPRETTY=cat
fi
set -e

FRAMEWORKNAME="KSYMediaEditorKit"
FORMAT=$1
TYPE="static"
if [ -n "$1" ]; then
    TYPE="dynamic"
fi


function xBuild() {
	TARG=$1
	SDK=$2
	XCODE_BUILD="xcrun xcodebuild"
	XCODE_BUILD="$XCODE_BUILD  -configuration Release"
	# XCODE_BUILD="$XCODE_BUILD  -workspace *.xcwork*"
	XCODE_BUILD="$XCODE_BUILD  -scheme  ${TARG}"
	XCODE_BUILD="$XCODE_BUILD  -derivedDataPath `pwd`/xbuild"
	XCODE_BUILD="$XCODE_BUILD  -sdk ${SDK}"
	echo "== building ${TARG} ${SDK} `date` "
	xGenConfig ${XCODE_CONFIG}
	$XCODE_BUILD clean build -xcconfig ${XCODE_CONFIG}
}

	LD_FLAGS="-all_load -lstdc++.6 -lz"
	LIB_FLAGS=""
	DEPS=""
	# DEPS="-ObjC -l'GPUImage' -l'Ks3SDK' -l'libksygpulive'"

	LIB_FLAGS_DEV="${LIB_FLAGS} ${DEPS}"
    LD_FLAGS_DEV="${LD_FLAGS} ${DEPS} -lbz2 "
    LIB_FLAGS_SIM="${LIB_FLAGS} ${DEPS}"
    LD_FLAGS_SIM="${LD_FLAGS} ${DEPS} -lbz2 "

XCODE_CONFIG=${FRAMEWORKNAME}.xcconfig
function xGenConfig() {
    echo "// ${XCODE_CONFIG} ${TYPE}"        > $1
    if [ $TYPE == "static" ]; then
        echo "MACH_O_TYPE=staticlib"        >> $1
        echo "OTHER_LIBTOOLFLAGS[sdk=iphoneos*]=${LIB_FLAGS_DEV}"  >> $1
        echo "OTHER_LIBTOOLFLAGS[sdk=iphonesimulator*]=${LIB_FLAGS_SIM}"  >> $1
    elif [ $TYPE == "dynamic" ]; then
        echo "OTHER_LDFLAGS[sdk=iphoneos*]=${LD_FLAGS_DEV}"        >> $1
        echo "OTHER_LDFLAGS[sdk=iphonesimulator*]=${LD_FLAGS_SIM}" >> $1
        echo "IPHONEOS_DEPLOYMENT_TARGET=8.0" >> $1
    fi
    # echo "FRAMEWORK_SEARCH_PATHS='../frameworks/${TYPE}' \
    # '$PODS_CONFIGURATION_BUILD_DIR/Ks3SDK' \
    # '${PODS_ROOT}/Headers/Public/GPUImage'\
   	#  '${PODS_ROOT}/Headers/Public/libksygpulive' "   >> $1
	echo "FRAMEWORK_SEARCH_PATHS='../frameworks/${TYPE}'" >> $1
    echo "build ====== ${TYPE} ======"
}

function xUniversal() {
	TARG=$1
	CTYPE=$2

	echo "=====  strip & universal - $1 @ `date` " | tee -a $LOG_F
	DEV_F=xbuild/Build/Products/Release-iphoneos/$1.framework
	SIM_F=xbuild/Build/Products/Release-iphonesimulator/$1.framework

	xcrun lipo -create \
	${DEV_F}/$1  ${SIM_F}/$1 \
	-output ./$1.lipo

	OUT_D=../frameworks/$CTYPE
	if [ ! -d $OUT_D ]; then
	    mkdir -p $OUT_D
	fi
	OUT_F=${OUT_D}/${TARG}.framework

	cp -r $DEV_F $OUT_F
	cp ./$1.lipo $OUT_D/$1.framework/$1
	rm ./$1.lipo


	xcrun lipo -info $OUT_D/$1.framework/$1

	file "${OUT_F}/${TARG}"
}

function xPod () {
	LIBNAME=$1
	xBuild ${LIBNAME} iphoneos
	xBuild ${LIBNAME} iphonesimulator
	xUniversal $FRAMEWORKNAME $TYPE 

	rm -rf xbuild
	# rm -rf $1.xcworkspace
	# rm Podfile.lock
	# git co $1.xcodeproj/project.pbxproj
}


xPod $FRAMEWORKNAME
# # clean duplicate headers
# for i in `ls ./include/` ; do
# 	if [ -f ./include/$i ]; then
# 		rm ./include/$i
# 	fi
# done
