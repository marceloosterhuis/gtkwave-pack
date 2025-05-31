# gtkwave-pack

The script packs the result of meson build on MSYS2 on Windows of the latest gtkwave sources from github. The script puts all the necessary dlls and executables into a zip archive and add a launcher script to start the executable (by setting correct paths first). When distributed the the archive can be unpacked on a windows system and launch.bat can be double clicked to start the waveform viewer.
