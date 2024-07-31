class_name Player
extends CharacterBody3D

@onready var head: Node3D = %Head;
@onready var capsule: CollisionShape3D = %Capsule;
@onready var camera: Camera3D = %Camera;

@export_category("Controls")
@export var mouse_sensitivity: float = 0.1;

@export_category("Movement Physics")
@export var max_speed: float = 10.0;
@export var sprint_rate: float = 1.5;
@export var ground_friction: float = 30.0;
@export var air_friction: float = 0.01;
@export var jump_force: float = 5.0;

var move_rate: float = 0.0;
var movement_vector: Vector3 = Vector3.ZERO;
var is_controls_disabled: bool = false;

func process_surface_movement(delta: float, input_dir: Vector2) -> void:
	var is_sprinting = Input.is_action_pressed("sprint");
	var target_rate = 1.0 if not is_sprinting else sprint_rate;
	
	move_rate = lerp(move_rate, target_rate, delta * 4);

	var current_friction = ground_friction if is_on_floor() else air_friction;
	var friction_factor = 1 / (1 + current_friction * delta);

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * move_rate;
	var computed_acceleration = ((max_speed / delta) / friction_factor - (max_speed / delta)) / 2.0;
	var current_acceleration = computed_acceleration if is_on_floor() else 0.0;

	movement_vector = direction * current_acceleration;
	movement_vector.y = 0;

	velocity += movement_vector * delta;
	velocity.x *= friction_factor;
	velocity.z *= friction_factor;

func process_gravity(delta: float):
	if is_on_floor(): return;

	var direction = ProjectSettings.get_setting("physics/3d/default_gravity_vector");
	var gravity = direction * ProjectSettings.get_setting("physics/3d/default_gravity") * delta;

	velocity += gravity;
	pass;

func process_mouse_look(event) -> void:
	if not event is InputEventMouseMotion: return;

	rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity));
	head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity));
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89));

func process_interaction() -> void:
	if Input.is_action_just_pressed("interact"):
		var ray_start = camera.global_transform.origin;
		var ray_end = camera.global_transform.origin - camera.global_transform.basis.z * 10;
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, 1, [self]);
		var result = get_world_3d().direct_space_state.intersect_ray(query);

		if result:
			var body = result["collider"].get_parent();
			if body.has_method("_interact"):
				body._interact(self);

func process_movement(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward") if not is_controls_disabled else Vector2(0, 0);
	process_surface_movement(delta, input_dir);

	if Input.is_action_just_pressed("jump"): do_jump();

func do_jump() -> void:
	if not is_on_floor(): return;
	velocity.y = jump_force;

func _input(event):
	process_mouse_look(event);
	process_interaction();

func _ready() -> void:
	ValveIONode.define_alias("!player", self);
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _process(_delta: float) -> void:
	process_gravity(_delta);
	process_movement(_delta);
	move_and_slide();
	pass;
