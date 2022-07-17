
.PHONY: build

GNU_LINUX_TARGET="x86_64-unknown-linux-gnu"
GNU_LINUX_ARM="aarch64-unknown-linux-gnu"
MUSL_LINUX_TARGET="x86_64-unknown-linux-musl"
MAC_ARM_TARGET="aarch64-apple-darwin"
MAC_TARGET="x86_64-apple-darwin"

clean:
	rm -rf ./statico/target
	rm -rf ./bin

run: 
	cargo run --manifest-path=./statico/Cargo.toml ./content ./dist

dockerbuild:
	docker run --rm -it -v `pwd`:/io -w /io messense/cargo-zigbuild make crossbuild

build-mac:
	cargo zigbuild --target="${MAC_TARGET}" --release --manifest-path="./statico/Cargo.toml"
	cp ./statico/target/${MAC_TARGET}/release/statico ./bin/statico-${MAC_TARGET}

	cargo zigbuild --target="${MAC_ARM_TARGET}" --release --manifest-path="./statico/Cargo.toml"
	cp ./statico/target/${MAC_ARM_TARGET}/release/statico ./bin/statico-${MAC_ARM_TARGET}

crossbuild: clean 
	mkdir -p ./bin
	rustup target add "${GNU_LINUX_TARGET}"
	rustup target add "${GNU_LINUX_ARM}"

	cargo zigbuild --target="${GNU_LINUX_TARGET}" --release --manifest-path="./statico/Cargo.toml"
	cp ./statico/target/${GNU_LINUX_TARGET}/release/statico ./bin/statico-${GNU_LINUX_TARGET}

	cargo zigbuild --target="${GNU_LINUX_TARGET}.2.17" --release --manifest-path="./statico/Cargo.toml"
	cp ./statico/target/${GNU_LINUX_TARGET}/release/statico ./bin/statico-${GNU_LINUX_TARGET}-libc217

	cargo zigbuild --target="${GNU_LINUX_ARM}" --release --manifest-path="./statico/Cargo.toml"
	cp ./statico/target/${GNU_LINUX_ARM}/release/statico ./bin/statico-${GNU_LINUX_ARM}

	cargo zigbuild --target="${GNU_LINUX_ARM}.2.17" --release --manifest-path="./statico/Cargo.toml"
	cp ./statico/target/${GNU_LINUX_ARM}/release/statico ./bin/statico-${GNU_LINUX_ARM}-libc217


