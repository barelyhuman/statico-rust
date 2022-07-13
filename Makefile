
.PHONY: build

build:
	cargo build --manifest-path=./statico/Cargo.toml --release
	mkdir -p ./bin
	cp ./statico/target/release/statico ./bin/statico

clean:
	rm -rf ./statico/target


