audit:
	cargo-audit audit

build: clean build-aarch64-linux-android build-armv7-linux-androideabi build-x11

build-release: clean build-aarch64-linux-android-release build-armv7-linux-androideabi-release build-x11-release

build-aarch64-linux-android:
	cargo build --target aarch64-linux-android
	mv -b ./target/aarch64-linux-android/debug/*.so ./target/aarch64-linux-android

build-aarch64-linux-android-release:
	cargo build --target aarch64-linux-android --release
	mv -b ./target/aarch64-linux-android/release/*.so ./target/aarch64-linux-android

build-armv7-linux-androideabi:
	cargo build --target armv7-linux-androideabi
	mv -b ./target/armv7-linux-androideabi/debug/*.so ./target/armv7-linux-androideabi

build-armv7-linux-androideabi-release:
	cargo build --target armv7-linux-androideabi --release
	mv -b ./target/armv7-linux-androideabi/release/*.so ./target/armv7-linux-androideabi

build-x11:
	cargo build
	mv -b ./target/debug/*.so ./target/

build-x11-release:
	cargo build --release
	mv -b ./target/release/*.so ./target/

check: clean
	cargo check

clean:
	cargo clean

doc: clean
	cargo doc --no-deps --open -v

edit:
	$EDITOR src/lib.rs &
	godot -e &

release: build-release
	godot --export "Android" ./target/{{project-name}}.apk
	godot --export "Linux/X11" ./target/{{project-name}}

release-debug: build
	godot --export-debug "Android" ./target/{{project-name}}.apk
	godot --export-debug "Linux/X11" ./target/{{project-name}}

release-android: build-aarch64-linux-android-release build-armv7-linux-androideabi-release
	godot --export "Android" ./target/{{project-name}}.apk

release-android-debug: build-aarch64-linux-android build-armv7-linux-androideabi
	godot --export-debug "Android" ./target/{{project-name}}.apk

release-x11: build-x11-release
	godot --export "Linux/X11" ./target/{{project-name}}

release-x11-debug: build-x11
	godot --export-debug "Linux/X11" ./target/{{project-name}}

run: build-x11
	godot -d

shell:
	nix-shell --pure

test: clean
	cargo test
