use gdnative::api::*;
use gdnative::prelude::*;

/// The SpinningCube "class"
#[derive(NativeClass)]
#[inherit(MeshInstance)]
#[register_with(Self::register_builder)]
pub struct SpinningCube {
    start: Vector3,
    time: f32,
    #[property(path = "base/rotate_speed")]
    rotate_speed: f64,
}

// __One__ `impl` block can have the `#[methods]` attribute, which will generate
// code to automatically bind any exported methods to Godot.
#[methods]
impl SpinningCube {
    // Register the builder for methods, properties and/or signals.
    fn register_builder(_builder: &ClassBuilder<Self>) {
        godot_print!("SpinningCube builder is registered!");
    }

    /// The "constructor" of the class.
    fn new(_owner: &MeshInstance) -> Self {
        SpinningCube {
            start: Vector3::new(0.0, 0.0, 0.0),
            time: 0.0,
            rotate_speed: 0.05,
        }
    }

    // In order to make a method known to Godot, the #[export] attribute has to be used.
    // In Godot script-classes do not actually inherit the parent class.
    // Instead they are "attached" to the parent object, called the "owner".
    // The owner is passed to every single exposed method.
    #[export]
    unsafe fn _ready(&mut self, owner: &MeshInstance) {
        owner.set_physics_process(true);
    }

    #[export]
    unsafe fn _physics_process(&mut self, owner: &MeshInstance, delta: f64) {
        use gdnative::api::SpatialMaterial;

        self.time += delta as f32;
        owner.rotate_y(self.rotate_speed * delta);

        let offset = Vector3::new(0.0, 1.0, 0.0) * self.time.cos() * 0.5;
        owner.set_translation(self.start + offset);

        if let Some(mat) = owner.get_surface_material(0) {
            let mat = mat.assume_safe();
            let mat = mat.cast::<SpatialMaterial>().expect("Incorrect material");
            mat.set_albedo(Color::rgba(self.time.cos().abs(), 0.0, 0.0, 1.0));
        }
    }
}
