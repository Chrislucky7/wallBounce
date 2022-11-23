set -e

rm -rf dist/
mkdir dist/

echo -n 'Building wallBounce.love ... '
zip -q -9 -r dist/wallBounce.love . \
    --exclude=*.git/* \
    --exclude=*.idea/* \
    --exclude=*dist/*
echo 'done.'

(
cd dist/

# building for macos
echo -n 'Building for MacOS ... '
wget -q https://bitbucket.org/rude/love/downloads/love-11.2-macos.zip -O love.zip
unzip -q love.zip
rm love.zip
mv love.app wallBounce.app
cp wallBounce.love wallBounce.app/Contents/Resources
cp ../assets/build/Info.plist wallBounce.app/Contents/Info.plist
zip -q -9 -y -r wallBounce-macos.zip wallBounce.app
rm -r wallBounce.app
echo 'done.'
)