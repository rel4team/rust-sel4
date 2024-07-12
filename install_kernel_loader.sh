ARCH=aarch64
TARGET=aarch64-unknown-none-softfloat
export CC=${ARCH}-linux-gnu-gcc SEL4_PREFIX=$SEL4_INSTALL_DIR
echo ${CC}
cargo install \
            -Z build-std=core,alloc,compiler_builtins \
            -Z build-std-features=compiler-builtins-mem \
            --target ${TARGET} \
            --root .. \
            --path ./crates/sel4-kernel-loader \
            sel4-kernel-loader
 
sudo cp ../bin/sel4-kernel-loader /deps/bin/

cd ../work && make run
