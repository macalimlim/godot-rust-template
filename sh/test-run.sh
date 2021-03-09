GAME=my-awesome-game
TMPL_DIR=$(pwd)
ls -l "${HOME}"
mkdir -p ~/.cargo
touch ~/.cargo/config
printf "[net]\ngit-fetch-with-cli = true\n" >> ~/.cargo/config
cat ~/.cargo/config
git branch master
git checkout master
git branch --list
echo "${TMPL_DIR}"
ls -la
cd /opt || exit 1
rm -rf ${GAME}
cargo generate --git "${TMPL_DIR}" --name "${GAME}" --branch master --verbose
ls -la
cd /opt/"${GAME}" || exit 1
cargo fmt --all -- --check
cargo clippy --all --all-features -- -D clippy::style -D clippy::complexity -D clippy::perf -D clippy::dbg_macro -D clippy::todo -D clippy::unimplemented
make build-x86_64-unknown-linux-gnu-debug
godot-headless --path godot/ &
RUN_PID=$!
echo ${RUN_PID}
sleep 5
kill -9 ${RUN_PID}
