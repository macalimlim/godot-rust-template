audit:
	cargo-audit audit

build: clean build-aarch64-linux-android build-armv7-linux-androideabi build-i686-linux-android build-x86_64-linux-android build-x86_64-unknown-linux-gnu

build-release: clean build-aarch64-linux-android-release build-armv7-linux-androideabi-release build-i686-linux-android-release build-x86_64-linux-android-release build-x86_64-unknown-linux-gnu-release

build-aarch64-linux-android:
	cargo build --target aarch64-linux-android
	mv -b ./target/aarch64-linux-android/debug/*.so ./native/lib/aarch64-linux-android

build-aarch64-linux-android-release:
	cargo build --target aarch64-linux-android --release
	mv -b ./target/aarch64-linux-android/release/*.so ./native/lib/aarch64-linux-android

build-armv7-linux-androideabi:
	cargo build --target armv7-linux-androideabi
	mv -b ./target/armv7-linux-androideabi/debug/*.so ./native/lib/armv7-linux-androideabi

build-armv7-linux-androideabi-release:
	cargo build --target armv7-linux-androideabi --release
	mv -b ./target/armv7-linux-androideabi/release/*.so ./native/lib/armv7-linux-androideabi

build-i686-linux-android:
	cargo build --target i686-linux-android
	mv -b ./target/i686-linux-android/debug/*.so ./native/lib/i686-linux-android

build-i686-linux-android-release:
	cargo build --target i686-linux-android --release
	mv -b ./target/i686-linux-android/release/*.so ./native/lib/i686-linux-android

build-x86_64-linux-android:
	cargo build --target x86_64-linux-android
	mv -b ./target/x86_64-linux-android/debug/*.so ./native/lib/x86_64-linux-android

build-x86_64-linux-android-release:
	cargo build --target x86_64-linux-android --release
	mv -b ./target/x86_64-linux-android/release/*.so ./native/lib/x86_64-linux-android

build-x86_64-unknown-linux-gnu:
	cargo build --target x86_64-unknown-linux-gnu
	mv -b ./target/x86_64-unknown-linux-gnu/debug/*.so ./native/lib/x86_64-unknown-linux-gnu

build-x86_64-unknown-linux-gnu-release:
	cargo build --target x86_64-unknown-linux-gnu --release
	mv -b ./target/x86_64-unknown-linux-gnu/release/*.so ./native/lib/x86_64-unknown-linux-gnu

check: clean
	cargo check

clean:
	cargo clean

doc: clean
	cargo doc --no-deps --open -v

edit:
	$EDITOR src/lib.rs &
	godot -e &

release: build-release clean
	godot --export "Android" ./native/bin/android/{{project-name}}.apk
	godot --export "Linux/X11" ./native/bin/linux-x11/{{project-name}}.x86_64

release-debug: build clean
	godot --export-debug "Android" ./native/bin/android/{{project-name}}.debug.apk
	godot --export-debug "Linux/X11" ./target/{{project-name}}.debug.x86_64

release-android: build-aarch64-linux-android-release build-armv7-linux-androideabi-release build-i686-linux-android build-x86_64-linux-android clean
	godot --export "Android" ./native/bin/android/{{project-name}}.apk

release-android-debug: build-aarch64-linux-android build-armv7-linux-androideabi build-i686-linux-android-release build-x86_64-linux-android-release clean
	godot --export-debug "Android" ./native/bin/android/{{project-name}}.debug.apk

release-linux-x11: build-x11-release clean
	godot --export "Linux/X11" ./native/bin/linux-x11/{{project-name}}.x86_64

release-linux-x11-debug: build-x11 clean
	godot --export-debug "Linux/X11" ./native/bin/linux-x11/{{project-name}}.debug.x86_64

run: build-x11
	godot -d

shell:
	nix-shell --pure

test: clean
	cargo test
