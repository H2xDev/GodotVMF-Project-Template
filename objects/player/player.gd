class_name Player
extends CharacterBody3D

static var instance: Player;

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
@export var jump_height: float = 1.0;

var move_rate: float = 0.0;
var movement_vector: Vector3 = Vector3.ZERO;
var is_controls_disabled: bool = false;

const MAX_STEP_HEIGHT = 0.5;
const ALLOWED_COLLIDER_CLASSES = ["StaticBody3D", "RigidBody3D"];
var _snapped_to_stairs_last_frame = false;
var _last_frame_was_on_floor = -INF;

var pickup_processor: PlayerPickupProcessor = null;

func process_surface_movement(delta: float, input_dir: Vector2) -> void:
	var is_sprinting = Input.is_action_pressed("sprint");
	var target_rate = 1.0 if not is_sprinting else sprint_rate;
	
	move_rate = lerp(move_rate, target_rate, delta * 4);

	var current_friction = ground_friction if is_on_floor() else air_friction;
	var friction_factor = 1 / (1 + current_friction * delta);

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * move_rate;
	var computed_acceleration = ((max_speed / delta) / friction_factor - (max_speed / delta)) / 2.0;
	var current_acceleration = computed_acceleration if is_on_floor() else 0.5;

	movement_vector = direction * current_acceleration;
	movement_vector.y = 0;

	velocity += movement_vector * delta;
	velocity.x *= friction_factor;
	velocity.z *= friction_factor;

func process_gravity(delta: float):
	if is_on_floor(): 
		_last_frame_was_on_floor = Engine.get_physics_frames();
		return;

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

		if pickup_processor.has_item():
			pickup_processor.drop_item();
			return;

		var ray_start = camera.global_transform.origin;
		var ray_end = camera.global_transform.origin - camera.global_transform.basis.z * 10;
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, 1, [self]);
		var result = get_world_3d().direct_space_state.intersect_ray(query);

		if result:
			var body = result.collider.get_parent();
			if body.has_method("_interact"):
				body._interact(self);

			pickup_processor.pickup_item(result.collider);

func process_movement(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward") if not is_controls_disabled else Vector2(0, 0);
	process_surface_movement(delta, input_dir);

	if Input.is_action_just_pressed("jump"): do_jump();

func process_fire():
	if not Input.is_action_pressed("fire"): return;
	if pickup_processor.has_item():
		pickup_processor.throw_item();
		

func do_jump() -> void:
	if is_on_floor() or _snapped_to_stairs_last_frame:
		velocity.y = sqrt(2 * jump_height * abs(ProjectSettings.get_setting("physics/3d/default_gravity")));

func _input(event):
	process_mouse_look(event);
	process_interaction();
	process_fire();

func _ready() -> void:
	instance = self;
	pickup_processor = PlayerPickupProcessor.new(%hand_point);

	ValveIONode.define_alias("!player", self);
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

## CREDIT github.com/majikayogames
func snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false;
	if velocity.y > 0 or (velocity * Vector3(1, 0, 1)).length() == 0: return false;

	var expected_move_motion = velocity * Vector3(1, 0, 1) * delta;
	var step_pos_with_clearance = global_transform.translated(expected_move_motion + Vector3.UP * MAX_STEP_HEIGHT * 2);
	var down_check_result = KinematicCollision3D.new();

	var move_test_passed = test_move(step_pos_with_clearance, Vector3.DOWN * MAX_STEP_HEIGHT * 2, down_check_result);

	if not move_test_passed: return false;

	var collider_class = down_check_result.get_collider().get_class();
	var is_valid_collider = ALLOWED_COLLIDER_CLASSES.has(collider_class);

	if not is_valid_collider: return false;

	var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - global_position).y;
	if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - global_position).y > MAX_STEP_HEIGHT: return false;

	$StairsAheadRC.global_position = down_check_result.get_position() + Vector3.UP * MAX_STEP_HEIGHT + expected_move_motion.normalized() * 0.1;
	$StairsAheadRC.force_raycast_update();

	if $StairsAheadRC.is_colliding() and not is_surface_too_steep($StairsAheadRC.get_collision_normal()):
		global_position = step_pos_with_clearance.origin + down_check_result.get_travel();
		apply_floor_snap();
		_snapped_to_stairs_last_frame = true;
		return true;

	return false

## CREDIT github.com/majikayogames
func snap_down_to_stair_check() -> void:
	var did_snap := false
	$StairsBelowRC.force_raycast_update();

	var floor_below : bool = $StairsBelowRC.is_colliding() and not is_surface_too_steep($StairsBelowRC.get_collision_normal());
	var was_on_floor_last_frame = Engine.get_physics_frames() == _last_frame_was_on_floor;

	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = KinematicCollision3D.new();

		if not test_move(self.global_transform, Vector3.DOWN * MAX_STEP_HEIGHT, body_test_result): return;

		var translate_y = body_test_result.get_travel().y;
		position.y += translate_y;
		apply_floor_snap();
		did_snap = true;

	_snapped_to_stairs_last_frame = did_snap;

## CREDIT github.com/majikayogames
func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > floor_max_angle;

func _process(_delta: float) -> void:
	process_movement(_delta);

func _physics_process(_delta: float) -> void:
	pickup_processor.physics_process(_delta);

	process_gravity(_delta);
	if snap_up_stairs_check(_delta): return;

	move_and_slide();
	snap_down_to_stair_check();
