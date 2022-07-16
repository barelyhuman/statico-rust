
.PHONY: build

GNU_LINUX_TARGET="x86_64-unknown-linux-gnu"
MUSL_LINUX_TARGET="x86_64-unknown-linux-musl"

run: 
	cargo run --manifest-path=./statico/Cargo.toml ./content ./dist

image:
	docker build . -t 'rustcross:latest'

run-image: image
	docker run -it --rm -v `pwd`:/usr/local/src rustcross:latest

crossbuild-linux-gnu:
	rustup target add "${GNU_LINUX_TARGET}"
	RUSTFLAGS='-C linker=x86_64-linux-gnu-gcc' cargo build --manifest-path=./statico/Cargo.toml --release --target="${GNU_LINUX_TARGET}"
	mkdir -p ./bin
	cp "./statico/target/${GNU_LINUX_TARGET}/release/statico" "./bin/statico-${GNU_LINUX_TARGET}"

crossbuild-linux-musl:
	rustup target add "${MUSL_LINUX_TARGET}"
	RUSTFLAGS='-C linker=x86_64-linux-gnu-gcc' cargo build --manifest-path=./statico/Cargo.toml --release --target="${MUSL_LINUX_TARGET}"
	mkdir -p ./bin
	cp "./statico/target/${MUSL_LINUX_TARGET}/release/statico" "./bin/statico-${MUSL_LINUX_TARGET}"

crossbuild: build-mac image
	docker run -it --rm -v `pwd`:/usr/local/src rustcross:latest bash -c "cd /usr/local/src; make crossbuild-linux-gnu; make crossbuild-linux-musl"

build:
	cargo build --manifest-path=./statico/Cargo.toml --release
	mkdir -p ./bin
	cp ./statico/target/release/statico ./bin/statico-native

build-mac: build
	mv ./bin/statico-native ./bin/statico-mac

clean:
	rm -rf ./statico/target


