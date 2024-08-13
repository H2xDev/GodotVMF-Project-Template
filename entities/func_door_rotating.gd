@tool
extends ValveIONode

const FLAG_USE_OPENS = 256;
const FLAG_REVERSE = 2;
const FLAG_X_AXIS = 64;
const FLAG_Z_AXIS = 128;
const FLAG_STARTS_LOCKED = 2048;
const FLAG_ONE_WAY = 16;
const FLAG_TOUCH_OPENS = 1024;

var is_open = false;
var is_locked = false;
var is_prevented = false;
var initial_rotation_state = Vector3(0, 0, 0);
var current_tween = null;
var start_sound = null;
var stop_sound = null;
var start_close_sound = null;
var stop_close_sound = null;

func precache_sounds():
	start_sound = SoundManager.precache_sound(entity.get("noise1", ""));
	stop_sound = SoundManager.precache_sound(entity.get("noise2", ""));
	start_close_sound = SoundManager.precache_sound(entity.get("startclosesound", ""));
	stop_close_sound = SoundManager.precache_sound(entity.get("closesound", ""));

func _interact(_player: Player):
	if not has_flag(FLAG_USE_OPENS):
		return;

	if is_locked:
		trigger_output("OnLockedUse");
		return;

	Toggle();

func _entity_ready():
	initial_rotation_state = rotation;
	is_locked = has_flag(FLAG_STARTS_LOCKED);

	precache_sounds();

func _apply_entity(e):
	super._apply_entity(e);

	var mesh = get_mesh();
	$body/mesh.set_mesh(mesh);
	$body/collision.shape = mesh.create_convex_shape();

func get_target_rotation(progress):
	var move_direction = -1 if has_flag(FLAG_REVERSE) else 1;
	var rotation_distance_rad = float(entity.get("distance", 90.0)) / 180.0 * PI;

	if has_flag(FLAG_X_AXIS):
		return initial_rotation_state + Vector3(rotation_distance_rad, 0, 0) * progress * move_direction;
	elif has_flag(FLAG_Z_AXIS):
		return initial_rotation_state + Vector3(0, 0, rotation_distance_rad) * progress * move_direction;

	return initial_rotation_state + Vector3(0, rotation_distance_rad, 0) * progress * move_direction;

func move_door(progress: float = 0.0):
	var speed = float(entity.get("speed", 0));
	var rotation_distance = float(entity.get("distance", 90.0));
	var target_rotation = get_target_rotation(progress);

	if current_tween:
		is_prevented = true;
		current_tween.stop();

	if speed == 0.0:
		Debugger.log("Door speed is 0, please set a speed value. Entity id " + str(entity.id));
		return;

	var move_time = rotation_distance / speed;

	current_tween = create_tween();
	current_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS);
	current_tween.tween_property(self, "rotation", target_rotation, move_time);

	await current_tween.finished;
	current_tween = null;

# INPUTS
func Open(_param):
	if is_open: return;

	is_open = true;
	trigger_output("OnOpen");

	if start_sound: SoundManager.play_sound(global_position, start_sound);

	await move_door(1.0);
	
	if stop_sound: SoundManager.play_sound(global_position, stop_sound);


	if not is_prevented:
		trigger_output("OnFullyOpen");
	else:
		is_prevented = false;

func Close(_param):
	if not is_open: return;

	is_open = false;

	trigger_output("OnClose");
	if start_close_sound: SoundManager.play_sound(global_position, start_close_sound);
	elif start_sound: SoundManager.play_sound(global_position, start_sound);
	await move_door(0.0);

	if stop_close_sound: SoundManager.play_sound(global_position, stop_close_sound);
	elif stop_sound: SoundManager.play_sound(global_position, stop_sound);

	if not is_prevented:
		trigger_output("OnFullyClosed");
	else:
		is_prevented = false;

func Toggle(_param = null):
	if is_open:
		Close(_param);
	else:
		Open(_param);
