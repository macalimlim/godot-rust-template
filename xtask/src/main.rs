use std::ffi::OsStr;

use anyhow::{bail, Context, Result};
use xshell::{cmd, cp, mkdir_p};
use walkdir::WalkDir;

const PROJECT_NAME: &str = "{{project-name}}";

fn main() -> Result<()> {
    let task = std::env::args().nth(1);
    match task.as_deref() {
        Some("build") => build(),
        Some("audit") => audit(),
        Some("check") => check(),
        Some("clean") => clean(),
        Some("create_debug_keystore") => create_debug_keystore(),
        Some("create_release_keystore") => create_release_keystore(),
        Some("doc") => doc(),
        Some("edit") => edit(),
        Some("run") => run(),
        Some("shell") => shell(),
        Some("test") => test(),
        task => {
            bail!("Uknown Task: {:?}", task)
        }
    }
}

/// Build the rust library and copy it to the lib directory to be used by godot
fn build() -> Result<()> {
    {%  case os-arch -%}
    {%-   when "linux-x86" -%}
    let target = "i686-unknown-linux-gnu";
    {%-   when "linux-x86_64" -%}
    let target = "x86_64-unknown-linux-gnu";
    {%-   when "macos-x86_64" -%}
    let target = "x86_64-apple-darwin";
    {%-   when "windows-x86" -%}
    let target = "i686-pc-windows-msvc";
    {%-   when "windows-x86_64" -%}
    let target = "x86_64-pc-windows-msvc";
    {%- endcase %}

    // build the library
    cmd!("cargo build --target {target}").run()?;

    mkdir_p(format!("./lib/{}", target))?;

    for entry in WalkDir::new(format!("./target/{}/debug/", target))
        .into_iter()
        .filter_map(|e| e.ok())
    {
        if let Some("dll") = entry.path().extension().and_then(OsStr::to_str) {
            // create the required folder if it doesn't already exist
            mkdir_p(format!("./lib/{}", target))?;
            // copy the .dll to the lib directory
            return cp(entry.path(), format!("./lib/{}", target))
                .with_context(|| "Failed to copy library to lib directory".to_string());
        }
    }
    bail!("Compiled library not found in target directory")
}

fn audit() -> Result<()> {
    clean()?;
    cmd!("cargo-audit audit")
        .run()
        .with_context(|| format!("Failed to run cargo-audit audit"))
}

fn check() -> Result<()> {
    clean()?;
    cmd!("cargo check")
        .run()
        .with_context(|| format!("Failed to run cargo check"))
}

fn clean() -> Result<()> {
    cmd!("cargo clean")
        .run()
        .with_context(|| format!("Failed to run cargo clean"))
}

fn create_debug_keystore() -> Result<()> {
    cmd!("keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore dry-run.debug.keystore -storepass android -dname \"CN=Android Debug,O=Android,C=US\" -validity 9999 -deststoretype pkcs12")
        .run()
        .with_context(|| format!("Failed to create keystore"))
}

fn create_release_keystore() -> Result<()> {
    cmd!("keytool -v -genkey -v -keystore {PROJECT_NAME}.release.keystore -alias {PROJECT_NAME} -keyalg RSA -validity 10000")
        .run()
        .with_context(|| format!("Failed to create keystore"))
}

fn doc() -> Result<()> {
    clean()?;
    cmd!("cargo doc --no-deps --open -v")
        .run()
        .with_context(|| format!("Failed to generate doc"))
}

/// Launch the godot editor with the current project
fn edit() -> Result<()> {
    cmd!("godot --path godot/ -e &")
        .run()
        .with_context(|| format!("Failed to open godot editor"))
}

/// Builds the rust project then launchs the game with godot
fn run() -> Result<()> {
    build()?;
    cmd!("godot --path godot/ -d")
        .run()
        .with_context(|| format!("Failed to run game"))
}

fn shell() -> Result<()> {
    cmd!("nix-shell --pure")
        .run()
        .with_context(|| format!("Failed to run nix-shell"))
}

fn test() -> Result<()> {
    clean()?;
    cmd!("cargo test")
        .run()
        .with_context(|| format!("Failed to run test"))
}

