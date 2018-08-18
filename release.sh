echo "Build release version"
swift build -c release -Xswiftc -static-stdlib
echo "Copy binary to ./fbsCG"
cp .build/release/FlatBuffersSwiftCodeGen ./fbsCG
echo "Done 👌"
