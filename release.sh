echo "Build release version"
swift build -c release --static-swift-stdlib
echo "Copy binary to ./fbsCG"
cp .build/release/FlatBuffersSwiftCodeGen ./fbsCG
echo "Done 👌"
