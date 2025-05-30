#!/usr/bin/env sh
set -e

executable_paths="
gtkwave.exe
twinwave.exe
helpers/evcd2vcd.exe
helpers/fst2vcd.exe
helpers/fstminer.exe
helpers/lxt2miner.exe
helpers/lxt2vcd.exe
helpers/vcd2fst.exe
helpers/vcd2lxt.exe
helpers/vcd2lxt2.exe
helpers/vcd2vzt.exe
helpers/vzt2vcd.exe
helpers/vztminer.exe
../contrib/xml2stems/xml2stems.exe
../contrib/rtlbrowse/rtlbrowse.exe
"

gtkver=4
tmpdir="gtkwave_${gtkver}"

if [ -d "$tmpdir" ]; then
  rm -rf "$tmpdir"
fi

mkdir "$tmpdir"

mkdir "$tmpdir"/bin
for item in $executable_paths; do
  cp ../gtkwave/build/src/"$item" "$tmpdir"/bin/
done

cp /mingw64/bin/gdbus.exe "$tmpdir"/bin/
cp /mingw64/bin/rsvg-convert.exe "$tmpdir"/bin/

echo "" > all_dll.inc

for exe in "$tmpdir"/bin/*.exe; do
  ntldd -R "$exe" | grep -v 'not found'| grep -v WINDOWS | awk '{print $1}' >> all_dll.inc
done

sort all_dll.inc | uniq > uniq_dll.inc

cp ../gtkwave/build/lib/libgtkwave/src/libgtkwave.dll "$tmpdir"/bin/
cp ../gtkwave/build/subprojects/libfst/src/libfst-1.dll "$tmpdir"/bin/
cp /mingw64/bin/librsvg-2-2.dll "$tmpdir"/bin/

for item in $(cat uniq_dll.inc); do
  src=/mingw64/bin/"$item"
  if [[ -e "$src" ]]; then
    cp "$src" "$tmpdir"/bin/
  else
    echo "Warning: $src not found."
  fi
done

mkdir "$tmpdir"/lib
cp -R /mingw64/lib/gdk-pixbuf-2.0 "$tmpdir"/lib

mkdir -p "$tmpdir"/share/glib-2.0/schemas
cp /mingw64/share/glib-2.0/schemas/gschemas.compiled "$tmpdir"/share/glib-2.0/schemas

mkdir -p "$tmpdir"/share/icons
cp -R /mingw64/share/icons/Adwaita "$tmpdir"/share/icons

cat <<EOF > "$tmpdir"/launch.bat
@echo off
setlocal

:: Get the directory of this script
set APPDIR=%~dp0

:: Add DLLs to path
set PATH=%APPDIR%bin;%PATH%

:: Tell GTK where to find schemas, icons, themes
set GSETTINGS_SCHEMA_DIR=%APPDIR%share\glib-2.0\schemas
set XDG_DATA_DIRS=%APPDIR%share
set GDK_PIXBUF_MODULEDIR=%APPDIR%lib\gdk-pixbuf-2.0\2.10.0\loaders
set GDK_PIXBUF_MODULE_FILE=%APPDIR%lib\gdk-pixbuf-2.0\2.10.0\loaders.cache

:: Launch your app
"%APPDIR%bin\gtkwave.exe"
EOF

tar czf "$tmpdir"_mingw64_standalone.tgz -C "$tmpdir" .