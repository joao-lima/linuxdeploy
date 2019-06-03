#! /bin/bash

set -xe

mkdir build
cd build

cmake /ws -DCMAKE_INSTALL_PREFIX=/usr -DUSE_SYSTEM_CIMG=Off

make -j8

ctest -V

# args are used more than once
LINUXDEPLOY_ARGS=("--appdir" "AppDir" "-e" "bin/linuxdeploy" "-i" "/ws/resources/linuxdeploy.png" "-d" "/ws/resources/linuxdeploy.desktop" "-e" "$(which patchelf)" "-e" "$(which strip)")

# deploy patchelf which is a dependency of linuxdeploy
bin/linuxdeploy "${LINUXDEPLOY_ARGS[@]}"

# bundle AppImage plugin
mkdir -p AppDir/plugins

wget --no-check-certificate https://github.com/TheAssassin/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-x86_64.AppImage
chmod +x linuxdeploy-plugin-appimage-x86_64.AppImage
./linuxdeploy-plugin-appimage-x86_64.AppImage --appimage-extract
mv squashfs-root/ AppDir/plugins/linuxdeploy-plugin-appimage

ln -s ../../plugins/linuxdeploy-plugin-appimage/AppRun AppDir/usr/bin/linuxdeploy-plugin-appimage

export UPD_INFO="gh-releases-zsync|linuxdeploy|linuxdeploy|continuous|linuxdeploy-x86_64.AppImage"

# build AppImage using plugin
AppDir/usr/bin/linuxdeploy-plugin-appimage --appdir AppDir/

appimage=linuxdeploy-ubuntu-x86_64.AppImage
# rename AppImage to avoid "Text file busy" issues when using it to create another one
mv ./linuxdeploy-x86_64.AppImage "$appimage"

chown "$OUTDIR_OWNER" "$appimage"

mv "$appimage" /out

#tar cfvz /out/appdir.tgz AppDir

# cannot add appimage plugin yet, since it won't work on CentOS 6 (at least for now)
# therefore we also need to use appimagetool directly to build an AppImage
# but we can still prepare the AppDir
#wget --no-check-certificate  https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
#chmod +x appimagetool-x86_64.AppImage
#sed -i 's/AI\x02/\x00\x00\x00/' appimagetool*.AppImage

#appimage=linuxdeploy-ubuntu-x86_64.AppImage
#./appimagetool-x86_64.AppImage --appimage-extract
#squashfs-root/AppRun AppDir "$appimage" 2>&1



