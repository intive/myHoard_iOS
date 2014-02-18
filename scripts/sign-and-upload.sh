#!/bin/sh
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. No deployment will be done."
  exit 0
fi

# Thanks @djacobs https://gist.github.com/djacobs/2411095
# Thanks @johanneswuerbach https://gist.github.com/johanneswuerbach/5559514

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
OUTPUTDIR="$PWD/build/Release-iphoneos"

echo "***************************"
echo "*        Signing          *"
echo "***************************"

RELEASE_DATE=`date '+%Y%m%d_%H%M'`
FILE_NAME=${APP_NAME}_${RELEASE_DATE}_${TRAVIS_COMMIT}.ipa
xcrun -log -sdk iphoneos PackageApplication "$OUTPUTDIR/$APP_NAME.app" -o "$OUTPUTDIR/$FILE_NAME" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"
#zip -r -9 "$OUTPUTDIR/$APP_NAME.app.dSYM.zip" "$OUTPUTDIR/$APP_NAME.app.dSYM"

GOOGLE_ACCOUNT_TYPE="GOOGLE" #gooApps = HOSTED , gmail=GOOGLE
MIME_TYPE=`file -b --mime-type "$OUTPUTDIR/$FILE_NAME"`

curl -v --data-urlencode Email=$GOOGLE_ACCOUNT_USERNAME --data-urlencode Passwd=$GOOGLE_ACCOUNT_PASSWORD -d accountType=$GOOGLE_ACCOUNT_TYPE -d service=writely -d source=cURL "https://www.google.com/accounts/ClientLogin" > /tmp/login.txt
token=`cat /tmp/login.txt | grep Auth | cut -d \= -f 2`
uploadlink=`/usr/bin/curl -Sv -k --request POST -H "Content-Length: 0" -H "Authorization: GoogleLogin auth=${token}" -H "GData-Version: 3.0" -H "Content-Type: $MIME_TYPE" -H "Slug: $FILE_NAME" "https://docs.google.com/feeds/upload/create-session/default/private/full/folder:$GOOGLE_ACCOUNT_FOLDER/contents?convert=false" -D /dev/stdout | grep "Location:" | sed s/"Location: "//`
curl -Sv -k --request POST --data-binary "@$OUTPUTDIR/$FILE_NAME" -H "Authorization: GoogleLogin auth=${token}" -H "GData-Version: 3.0" -H "Content-Type: $mime_type" -H "Slug: $FILE" "$uploadlink" > /tmp/goolog.upload.txt
