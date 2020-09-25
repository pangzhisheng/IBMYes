#! /bin/bash

cd $(dirname $0)

END="==================================="

# set default env
V2_ID=${V2_ID:-"d007eab8-ac2a-4a7f-287a-f0d50ef08680"}
V2_PATH=${V2_PATH:-"path"}
ALTER_ID=${ALTER_ID:-"1"}

if [ -z $HEROKU_ACCOUNT ]; then
    echo "HEROKU_ACCOUNT is empty, not deplay to heroku${END}"
    exit 0
fi
if [ -z $HEROKU_APP_NAME ]; then
    echo "HEROKU_APP_NAME is empty, not deplay to heroku${END}"
    exit 0
fi

if [ ! -f "./config/v2ray" ]; then
    echo "download v2ray${END}"
    pushd ./config
    new_ver=$(curl -s https://github.com/v2fly/v2ray-core/releases/latest | grep -Po "(\d+\.){2}\d+")
    wget -q -Ov2ray.zip https://github.com/v2fly/v2ray-core/releases/download/v${new_ver}/v2ray-linux-64.zip
    if [ $? -eq 0 ]; then
        7z x v2ray.zip v2ray v2ctl
        chmod 700 v2ctl v2ray
    else
        echo "download new version failed!${END}"
        exit 1
    fi
    rm -fv v2ray.zip
    popd
fi

# v2ray config
mkdir -p $HEROKU_APP_NAME
cp -vf ./config/v2ray ./$HEROKU_APP_NAME/
cp -vf ./config/v2ctl ./$HEROKU_APP_NAME/
cp -vf ./config/config.json ./$HEROKU_APP_NAME/
cd $HEROKU_APP_NAME
sed 's/V2_ID/$V2_ID/' config.json -i
sed 's/V2_PATH/$V2_PATH/' config.json -i
sed 's/ALTER_ID/$ALTER_ID/' config.json -i

echo "heroku login${END}"
heroku login -i <<EOF
tsymk220@gmail.com
ChgNwUDO4CU@QgaEKasF
EOF

if [ $(heroku list | tail -n +2 | grep -cP "^${HEROKU_APP_NAME}$") -eq 0 ]; then
    echo "heroku create${END}"
    heroku create $HEROKU_APP_NAME
fi





