
.PHONY: build

run: 
	cargo run --manifest-path=./statico/Cargo.toml ./content ./dist

image:
	docker build . -t 'rustcross:latest'

run-image: image
	docker run -it --rm -v `pwd`:/usr/local/src rustcross:latest 

crossbuild-linux:
	rustup target add x86_64-unknown-linux-gnu
	RUSTFLAGS='-C linker=x86_64-linux-gnu-gcc' cargo build --manifest-path=./statico/Cargo.toml --release --target='x86_64-unknown-linux-gnu'
	mkdir -p ./bin
	cp ./statico/target/x86_64-unknown-linux-gnu/release/statico ./bin/statico-linux

build:
	cargo build --manifest-path=./statico/Cargo.toml --release
	mkdir -p ./bin
	cp ./statico/target/release/statico ./bin/statico-macos

clean:
	rm -rf ./statico/target


