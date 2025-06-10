#!/bin/sh

set -eux

APP=rofi
export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1

UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
APPIMAGETOOL="https://github.com/pkgforge-dev/appimagetool-uruntime/releases/download/continuous/appimagetool-$ARCH.AppImage"

# CREATE DIRECTORIES
mkdir ./AppDir
cd ./AppDir

# DOWNLOAD AND BUILD ROFI
git clone --depth 1 "https://github.com/davatorium/rofi.git" ./rofi && (
	cd ./rofi
	meson --prefix /usr . build
	meson compile -C build
	meson install -C build --destdir "$(realpath ../)"
)
mv -v ./usr/* ./
cp -v ./share/icons/hicolor/scalable/apps/rofi.svg  ./
cp -v ./share/icons/hicolor/scalable/apps/rofi.svg  ./.DirIcon
cp -v ./share/applications/rofi.desktop             ./
echo "Categories=Utility;" >> ./rofi.desktop

# ADD LIBRARIES
wget "$LIB4BN" -O ./lib4bin
chmod +x ./lib4bin
./lib4bin -p -v -k -s \
	./bin/* \
	/usr/lib/gio/modules/* \
	/usr/lib/gdk-pixbuf-*/*/*/*

# We can't use the gdk variables here because that breaks child processes
#git clone --depth 1 "https://github.com/fritzw/ld-preload-open" && (
#	cd ./ld-preload-open
#	make all
#	mv ./path-mapping.so ../lib
#)
#mv -v ./shared/lib/gdk-pixbuf-* ./
#echo 'path-mapping.so' >./.preload
#echo 'PATH_MAPPING=/usr/lib/gdk-pixbuf-2.0:${SHARUN_DIR}/gdk-pixbuf-2.0' >> ./.env

rm -rf ./rofi ./usr ./ld-preload-open

# AppRun
echo '#!/bin/sh
CURRENTDIR="$(dirname "$(readlink -f "$0")")"

BIN="${ARGV0#./}"
unset ARGV0
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}"

export XDG_DATA_DIRS="$DATADIR:$XDG_DATA_DIRS:/usr/local/share:/usr/share"
export PATH="$CURRENTDIR/bin:$PATH"

if [ ! -d "$DATADIR"/rofi/themes ]; then
	mkdir -p "$DATADIR"/rofi || exit 1
	cp -rn "$CURRENTDIR"/share/rofi/themes "$DATADIR"/rofi/themes || exit 1
fi

if [ "$1" = "rofi-theme-selector" ]; then
	shift
	exec "$CURRENTDIR/bin/rofi-theme-selector" "$@"
elif [ -f "$CURRENTDIR/bin/$BIN" ]; then
	exec "$CURRENTDIR/bin/$BIN" "$@"
else
	exec "$CURRENTDIR/bin/rofi" "$@"
fi' > ./AppRun

chmod a+x ./AppRun
./sharun -g

export VERSION="$(./AppRun -v | awk 'FNR==1 {print $2; exit}')"
echo "$VERSION" > ~/version

# MAKE APPIMAGE WITH FUSE3 COMPATIBLE APPIMAGETOOL
cd ..
wget "$APPIMAGETOOL" -O ./appimagetool
chmod +x ./appimagetool

echo "Generating AppImage..."
./appimagetool -n -u "$UPINFO" "$PWD"/AppDir "$PWD"/"$APP"-"$VERSION"-anylinux-"$ARCH".AppImage

echo "All Done!"
asdf
