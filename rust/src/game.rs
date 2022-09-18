use gdnative::api::*;
use gdnative::prelude::*;

/// The Game "class"
#[derive(NativeClass)]
#[inherit(Spatial)]
#[register_with(Self::register_builder)]
pub struct Game {
    name: String,
}

// __One__ `impl` block can have the `#[methods]` attribute, which will generate
// code to automatically bind any exported methods to Godot.
#[methods]
impl Game {
    // Register the builder for methods, properties and/or signals.
    fn register_builder(_builder: &ClassBuilder<Self>) {
        godot_print!("Game builder is registered!");
    }

    /// The "constructor" of the class.
    fn new(_owner: &Spatial) -> Self {
        godot_print!("Game is created!");
        Game {
            name: "".to_string(),
        }
    }

    // In order to make a method known to Godot, the #[export] attribute has to be used.
    // In Godot script-classes do not actually inherit the parent class.
    // Instead they are "attached" to the parent object, called the "owner".
    // The owner is passed to every single exposed method.
    #[method]
    unsafe fn _ready(&mut self, #[base] _owner: &Spatial) {
        // The `godot_print!` macro works like `println!` but prints to the Godot-editor
        // output tab as well.
        self.name = "Game".to_string();
        godot_print!("{} is ready!", self.name);
    }

    // This function will be called in every frame
    #[method]
    unsafe fn _process(&self, #[base] _owner: &Spatial, delta: f64) {
        godot_print!("Inside {} _process(), delta is {}", self.name, delta);
    }
}
