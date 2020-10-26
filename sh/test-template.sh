GAME=my-awesome-game
GODOT_VER=3.2
template_directory=$PWD
git branch
tree -a "${template_directory}"
rustup component add clippy rustfmt
cargo install cargo-generate --features vendored-openssl
if [ ! -f /tmp/godot.zip ]; then
    wget "https://downloads.tuxfamily.org/godotengine/$GODOT_VER/Godot_v${GODOT_VER}-stable_linux_headless.64.zip" -O /tmp/godot.zip
fi
if [ ! -d /tmp/godot_bin ]; then
    unzip /tmp/godot.zip -d /tmp/godot_bin
fi
export PATH=$PATH:/tmp/godot_bin/
cd /tmp || exit 1
rm -rf ${GAME}
cargo generate --git "${template_directory}" --name "${GAME}" --branch "${TRAVIS_BRANCH}"
cd "${GAME}" || exit 1
cargo fmt --all -- --check
cargo clippy --all --all-features -- -D clippy::style -D clippy::complexity -D clippy::perf -D clippy::dbg_macro -D clippy::todo -D clippy::unimplemented
make build-x86_64-unknown-linux-gnu-debug
tree -a lib/
"Godot_v${GODOT_VER}-stable_linux_headless.64" --path godot/ &
run_pid=$!
echo ${run_pid}
sleep 5
kill -9 ${run_pid}
