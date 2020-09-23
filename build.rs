use gdnative_project_utils::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    /// directory to scan for Rust files
    let classes = scan_crate("src")?;

    /// generate files inside the Godot project directory
    Generator::new().godot_project_dir("./").build(classes)?;

    Ok(())
}
