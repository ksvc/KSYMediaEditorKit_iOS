#! /bin/sh

#######################
## cmd line
#######################
function print_usage() {
echo "USAGE:"
echo "  $0 [dy]"
echo ""
echo "[dy]  :   if exist, build a dynamic framework, otherwise, build a static framework" 
echo ""
echo "FOR EXAMPLE:"
echo "$0 : build a static shortvideo framework which name is "KSYMediaEditor.framework""
echo "$0 dy : build a dynamic live framework which name is "KSYMediaEditor.framework""
}

PROJECT_BUILD_ROOT=`pwd`

TYPE="static"
PROJECT_NAME=libKSYMediaEditor
TARGET_NAME=libKSYMediaEditor
FRAMEWORK_NAME=KSYMediaEditorKit
FRAMEWORK_DIR=${PROJECT_BUILD_ROOT}/../framework
HEADERFILE_DIR=${PROJECT_BUILD_ROOT}/../prebuilt/include/

if [ $# -gt 0 ]; then
    TYPE="dynamic"
fi

#######################
## default opt
#######################
if [ $XCODE_STRIP ]; then
    echo "XCODE_STRIP=$XCODE_STRIP"
else
    XCODE_STRIP="xcrun strip"
fi

function xDownload() {
    FILE_NAME=$1
    SUB_DIR=$2
    FILE_DIR=$3

    DST_DIR=${FILE_DIR}/${SUB_DIR}
    mkdir -p ${DST_DIR}

    IOS_URL=http://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios/${SUB_DIR}${FILE_NAME}.zip
    ZIP_FILE=${DST_DIR}/${SUB_DIR}${FILE_NAME}.zip

    if [ ! -d "${DST_DIR}/${FILE_NAME}.framework" ]; then
        echo "download ${FILE_NAME}.framework(${IOS_URL}) to ${DST_DIR}"
        curl ${IOS_URL} -o ${ZIP_FILE}
        unzip -o -q ${ZIP_FILE} -d ${DST_DIR}/
        rm ${ZIP_FILE}
    fi
}

LIB_DEPS_PATH="../../prebuilt/libs"
LIB_DEPS_SIM="-L${LIB_DEPS_PATH}        \
              -lksybase                 \
              -lksyyuv                  \
              -lksymediacore_enc_base   \
              -lksymediacore_enc_265    \
              -lksyplayer               \
              -lksystreamerbase         \
              -lksystreamerengine       \
              -lksygpufilter            \
              -lksymediaeditorkit"  
LIB_DEPS_DEV="${LIB_DEPS_SIM}           \
              -lksymediacodec"

LD_FLAGS="-all_load -lc++ -lz"
LIB_FLAGS=""
LIB_FLAGS_DEV="${LIB_FLAGS} ${LIB_DEPS_DEV}"
LIB_FLAGS_SIM="${LIB_FLAGS} ${LIB_DEPS_SIM}"

LD_FLAGS_DEV="${LD_FLAGS} -framework GPUImage ${LIB_DEPS_DEV}"
LD_FLAGS_SIM="${LD_FLAGS} -framework GPUImage ${LIB_DEPS_SIM}"

function xGenConfig() {
    IPHONE_SDK=$2
    LIB_FLAGS=${LIB_FLAGS_DEV}

    if [ $IPHONE_SDK == "iphoneos" ];then
        LIB_FLAGS=${LIB_FLAGS_DEV}
    else
        LIB_FLAGS=${LIB_FLAGS_SIM}

    fi
    echo "// ${XCODE_CONFIG} ${TYPE}"        > $1
    if [ $TYPE == "static" ]; then
        echo "MACH_O_TYPE=staticlib"        >> $1
        echo "OTHER_LIBTOOLFLAGS=${LIB_FLAGS}"  >> $1
    elif [ $TYPE == "dynamic" ]; then
        echo "MACH_O_TYPE=mh_dylib"        >> $1
        echo "OTHER_LDFLAGS=${LIB_FLAGS}"        >> $1
    fi
    echo "FRAMEWORK_SEARCH_PATHS=../../framework/${TYPE}"   >> $1
}

function xBuild() {
    PROJ=$1
    TARG=$2
    SDK=$3
    if [ "$4" == "clean" ]; then
        xcrun xcodebuild -quiet $CLEAR
    fi
    XCODE_BUILD="xcrun xcodebuild -quiet "
    XCODE_BUILD="$XCODE_BUILD  -configuration Release"
    XCODE_BUILD="$XCODE_BUILD  -project ${PROJ}.xcodeproj"
    XCODE_BUILD="$XCODE_BUILD  -target  ${TARG}"
    XCODE_BUILD="$XCODE_BUILD  -sdk     ${SDK}"

    echo "=====  building ${PROJ} - ${TARG} - ${SDK} @ `date` "
    xGenConfig KSYMediaEditorKit.xcconfig $SDK
    $XCODE_BUILD  -xcconfig KSYMediaEditorKit.xcconfig 
    
}

function xUniversal() {
    TARG=$1
    OUTPATH=$2

    echo "=====  strip & universal - $1 @ `date` "
    DEV_F=build/Release-iphoneos/${TARG}.framework
    SIM_F=build/Release-iphonesimulator/${TARG}.framework

    cp -R ${DEV_F} ${OUTPATH}/
    OUT_F=${OUTPATH}/${TARG}.framework
    
    xcrun lipo -create -output "${OUT_F}/${TARG}" \
                               "${DEV_F}/${TARG}" \
                               "${SIM_F}/${TARG}"
    xcrun lipo -info "${OUT_F}/${TARG}"
    $XCODE_STRIP -S "${OUT_F}/${TARG}" 2> /dev/null
}

echo "======================"
echo "== build framework ==="
echo "======================"
OUT_DIR=${FRAMEWORK_DIR}/${TYPE}
echo "${OUT_DIR}"
mkdir -p ${OUT_DIR}
xDownload GPUImage $TYPE $FRAMEWORK_DIR

cd $PROJECT_NAME

xBuild $PROJECT_NAME $TARGET_NAME iphoneos clean
xBuild $PROJECT_NAME $TARGET_NAME iphonesimulator
xUniversal $FRAMEWORK_NAME $OUT_DIR 

INCDIR=${OUT_DIR}/${FRAMEWORK_NAME}.framework/Headers
mkdir -p ${INCDIR}    
find ${HEADERFILE_DIR} -name "*.h" | xargs -I {} cp {} ${INCDIR}
