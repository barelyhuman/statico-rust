source $stdenv/setup 

cd $src
cargo build 
cp $src/target/debug/builder $out