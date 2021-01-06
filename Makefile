{%- comment -%} dynamic make targets {%- endcomment -%}
{%- assign target_dir = "./target" -%}
{%- assign lib_dir = "./lib" -%}
{%- assign bin_dir = "../bin" -%}
{%- assign aarch64-linux-android-debug = "aarch64-linux-android,Android,debug" | split: "|" -%}
{%- assign aarch64-linux-android-release = "aarch64-linux-android,Android,release" | split: "|" -%}
{%- assign armv7-linux-androideabi-debug = "armv7-linux-androideabi,Android,debug" | split: "|" -%}
{%- assign armv7-linux-androideabi-release = "armv7-linux-androideabi,Android,release" | split: "|" -%}
{%- assign arm_android_targets = aarch64-linux-android-debug | concat: aarch64-linux-android-release | concat: armv7-linux-androideabi-debug | concat: armv7-linux-androideabi-release | compact -%}
{%- assign i686-linux-android-debug = "i686-linux-android,Android,debug" | split: "|" -%}
{%- assign i686-linux-android-release = "i686-linux-android,Android,release" | split: "|" -%}
{%- assign x86_64-linux-android-debug = "x86_64-linux-android,Android,debug" | split: "|" -%}
{%- assign x86_64-linux-android-release = "x86_64-linux-android,Android,release" | split: "|" -%}
{%- assign x86_android_targets = i686-linux-android-debug | concat: i686-linux-android-release | concat: x86_64-linux-android-debug | concat: x86_64-linux-android-release | compact -%}
{%- assign android_targets = arm_android_targets | concat: x86_android_targets | compact -%}
{%- assign i686-unknown-linux-gnu-debug = "i686-unknown-linux-gnu,Linux/X11,debug" | split: "|" -%}
{%- assign i686-unknown-linux-gnu-release = "i686-unknown-linux-gnu,Linux/X11,release" | split: "|" -%}
{%- assign x86_64-unknown-linux-gnu-debug = "x86_64-unknown-linux-gnu,Linux/X11,debug" | split: "|" -%}
{%- assign x86_64-unknown-linux-gnu-release = "x86_64-unknown-linux-gnu,Linux/X11,release" | split: "|" -%}
{%- assign x86_linux_targets = i686-unknown-linux-gnu-debug | concat: i686-unknown-linux-gnu-release | concat: x86_64-unknown-linux-gnu-debug | concat: x86_64-unknown-linux-gnu-release | compact -%}
{%- assign x86_64-apple-darwin-debug = "x86_64-apple-darwin,Mac OSX,debug" | split: "|" -%}
{%- assign x86_64-apple-darwin-release = "x86_64-apple-darwin,Mac OSX,release" | split: "|" -%}
{%- assign mac_osx_targets = x86_64-apple-darwin-debug | concat: x86_64-apple-darwin-release | compact -%}
{%- assign all_targets = android_targets | concat: x86_linux_targets | concat: mac_osx_targets | compact -%}
{%- assign godot_project_path_arg = "--path godot/" -%}
build-debug:
{%  for target in all_targets -%}
{%-   assign t = target | split: "," -%}
{%-   assign build_target = t[0] -%}
{%-   assign target_type = t[2] -%}
{%-   if target_type == "debug" -%}
	# make build-{{build_target}}-{{target_type}}
{%    endif %}
{%- endfor %}
build-release:
{%  for target in all_targets -%}
{%-   assign t = target | split: "," -%}
{%-   assign build_target = t[0] -%}
{%-   assign target_type = t[2] -%}
{%-   if target_type == "release" -%}
	# make build-{{build_target}}-{{target_type}}
{%    endif %}
{%- endfor %}
export-debug:
{%  for target in all_targets -%}
{%-   assign t = target | split: "," -%}
{%-   assign build_target = t[0] -%}
{%-   assign target_type = t[2] -%}
{%-   if target_type == "debug" -%}
	# make export-{{build_target}}-{{target_type}}
{%   endif %}
{%- endfor %}
export-release:
{%  for target in all_targets -%}
{%-   assign t = target | split: "," -%}
{%-   assign build_target = t[0] -%}
{%-   assign target_type = t[2] -%}
{%-   if target_type == "release" -%}
	# make export-{{build_target}}-{{target_type}}
{%    endif %}
{%- endfor %}
{%- for target in all_targets %}
{%-   assign t = target | split: "," -%}
{%-   assign build_target = t[0] -%}
{%-   assign export_target = t[1] -%}
{%-   assign target_type = t[2] -%}
{%-   capture exported_project -%}
{%-     case export_target -%}
{%-       when "Android" -%}
{{project-name}}.{{target_type}}.{{build_target}}.apk
{%-       when "Linux/X11" -%}
{{project-name}}.{{target_type}}.{{build_target}}
{%-       when "Mac OSX" -%}
{{project-name}}.{{target_type}}.{{build_target}}
{%-     endcase -%}
{%-   endcapture -%}
{%-   capture lib_ext -%}
{%-     case export_target -%}
{%-       when "Android" -%}
so
{%-       when "Linux/X11" -%}
so
{%-       when "Mac OSX" -%}
dylib
{%-     endcase -%}
{%-   endcapture -%}
{%-   capture build_arg -%}
{%-     case target_type -%}
{%-       when "debug" -%}

{%-       when "release" -%}
--release
{%-     endcase -%}
{%-   endcapture -%}
{%-   capture export_arg -%}
{%-     case target_type -%}
{%-       when "debug" -%}
--export-debug
{%-       when "release" -%}
--export
{%-     endcase -%}
{%-   endcapture %}
build-{{build_target}}-{{target_type}}:
	cargo build --target {{build_target}} {{build_arg}}
	mv -b {{target_dir}}/{{build_target}}/{{target_type}}/*.{{lib_ext}} {{lib_dir}}/{{build_target}}

export-{{build_target}}-{{target_type}}: clean build-{{build_target}}-{{target_type}}
	cd godot/ ; godot {{export_arg}} "{{export_target}}.{{build_target}}.{{target_type}}" {{bin_dir}}/{{build_target}}/{{exported_project}}
{% endfor -%}
{% comment %} static make targets {% endcomment %}
audit:
	cargo-audit audit

check: clean
	cargo check

clean:
	cargo clean

create-debug-keystore:
	keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore {{project-name}}.debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12

create-release-keystore:
	keytool -v -genkey -v -keystore {{project-name}}.release.keystore -alias {{project-name}} -keyalg RSA -validity 10000

doc: clean
	cargo doc --no-deps --open -v

edit:
	# ${EDITOR} rust/src/lib.rs &
	godot {{godot_project_path_arg}} -e &

run:
	make build-x86_64-unknown-linux-gnu-debug
	godot {{godot_project_path_arg}} -d

shell:
	nix-shell --pure

test: clean
	cargo test
