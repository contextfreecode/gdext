Some things I did, or at least similar to things I did. I don't have all steps
here, though.

```
pip install scons
mkdir gdext
cd gdext/
git init
git clone -b 4.2 https://github.com/godotengine/godot-cpp
godot --headless --dump-extension-api
echo godot-cpp/ >> .gitignore 
echo extension_api.json >> .gitignore 
cd godot-cpp/
time scons platform=linux custom_api_file=../extension_api.json
# Add cpp source files and gdextension file.
cd ..
time scons platform=linux
clang-format -i src/*.cpp src/*.h
```

```
mkdir swift
cd swifth
swift package init --type library --name GdSwift
swift build --configuration release
# cp .build/release/lib*.so ../demo/bin/
# Manually copied libSwiftGodot.so to export dir.
# TODO Put it in bin after all?
```

```
cargo init --lib
# modify file per instructions
cargo build --release
```
