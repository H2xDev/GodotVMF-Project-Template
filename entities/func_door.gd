@tool
class_name func_door
extends ValveIONode

@export var move_direction = Vector3(0, 0, 0);
@export var move_distance = Vector3(0, 0, 0);
@export var lip_vector = Vector3(0, 0, 0);
@export var speed = 0.0;
@export var volume = 1.0;

const FLAG_NON_SOLID = 4;
const FLAG_PASSABLE = 8;
const FLAG_TOGGLE = 32;
const FLAG_USE_OPENS = 256;
const FLAG_NPC_CANT = 512;
const FLAG_TOUCH_OPENS = 1024;
const FLAG_STARTS_LOCKED = 2048;
const FLAG_SILENT = 4096;

var start_position = Vector3(0, 0, 0);
var open_value = 0.0;
var is_open = false;
var is_locked = false;
var open_sound = null;
var close_sound = null;
var current_tween = null;

func _entity_ready():
	start_position = position;

	is_locked = has_flag(FLAG_STARTS_LOCKED);

	var spawnpos = entity.get("spawnpos", 0);
	is_open = spawnpos == 1;
	call_deferred('move_door', float(spawnpos), true);

	open_sound = entity.get("noise1", null);
	close_sound = entity.get("startclosesound", null);

	if open_sound: SoundManager.precache_sound(open_sound);
	if close_sound: SoundManager.precache_sound(close_sound);

## 0.0 = closed, 1.0 = open
func move_door(target_value: float = 0.0, instant: bool = false):
	var target_position = start_position + move_distance * target_value - lip_vector * target_value;
	var time = (target_position - position).length() / speed;

	if instant:
		position = target_position;
		return;

	if current_tween:
		current_tween.stop();
		current_tween = null;

	current_tween = create_tween();
	current_tween.tween_property(self, "position", target_position, time);

func _apply_entity(e):
	super._apply_entity(e);

	$body/mesh.set_mesh(get_mesh());

	if not has_flag(FLAG_NON_SOLID):
		$body/collision.shape = get_entity_shape();
	else:
		$body/collision.queue_free();

	move_direction = get_movement_vector(e.movedir);
	move_distance = $body/mesh.mesh.get_aabb().size * move_direction;

	speed = e.speed * config.import.scale;
	lip_vector = move_direction * e.lip * config.import.scale;
	
	volume = e.get("volume", 10.0) / 10.0;
	e.radius = e.get("radius", 100.0 / config.import.scale) * config.import.scale;

# OUTPUTS
func _on_fully_open():
	trigger_output("OnFullyOpen");

func _on_fully_closed():
	trigger_output("OnFullyClosed");

## INPUTS
func Open(_param):
	if is_open: return;
	is_open = true;

	trigger_output("OnOpen");
	
	if open_sound:
		var snd = SoundManager.play_sound(global_transform.origin, open_sound);
		snd.max_distance = entity.radius;

	move_door(1.0);

func Close(_param):
	if not is_open: return;
	is_open = false;

	trigger_output("OnClose");

	var snd: AudioStreamPlayer3D;

	if close_sound:
		snd = SoundManager.play_sound(global_transform.origin, close_sound);
	else: if open_sound:
		snd = SoundManager.play_sound(global_transform.origin, open_sound);

	if snd:
		snd.max_distance = entity.radius;

	move_door(0.0);

func Toggle(_param = null):
	if is_open:
		Close(_param);
	else:
		Open(_param);
