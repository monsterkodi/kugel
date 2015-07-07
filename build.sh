#!/usr/bin/env bash

rm -rf kugel-darwin-x64
rm -rf kugel.app

node_modules/electron-packager/cli.js . kugel --platform=darwin --arch=x64 --prune --version=0.28.3 --app-version=1.0.2 --app-bundle-id=net.monsterkodi.kugel --icon=img/appicon.icns

mv kugel-darwin-x64/kugel.app .

rm -rf kugel-darwin-x64
rm -rf kugel.app/Contents/Resources/app/.*
rm -rf kugel.app/Contents/Resources/app/web
rm -rf kugel.app/Contents/Resources/default_app
rm  -f kugel.app/Contents/Resources/app/*.sh
rm  -f kugel.app/Contents/Resources/app/node.js
