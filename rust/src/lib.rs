mod gd_main;

use gdnative::prelude::{godot_init, InitHandle};

// Function that registers all exposed classes to Godot
fn init(handle: InitHandle) {
    handle.add_class::<gd_main::Main>();
}

// macros that create the entry-points of the dynamic library.
godot_init!(init);
