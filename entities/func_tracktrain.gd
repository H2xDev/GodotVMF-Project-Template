@tool
class_name func_tracktrain
extends ValveIONode

enum MovementState {
	MOVING_FORWARD,
	MOVING_BACKWARD,
	STOPPED
}

enum MovementDirection {
	FORWARD,
	BACKWARD
}

var current_point: path_track = null;
var current_tween: Tween = null;
var stop_required: bool = false;

var start_sound: String;
var stop_sound: String;
var move_sound: String;

var direction: MovementDirection = MovementDirection.FORWARD;
var state: MovementState = MovementState.STOPPED;

func _entity_ready():
	if is_current_point_valid():
		teleport_to_point(current_point.name, false);

	precache_sounds();

func precache_sounds():
	start_sound = entity.get("StartSound", "");
	stop_sound = entity.get("StopSound", "");
	move_sound = entity.get("MoveSound", "");

	if start_sound: SoundManager.precache_sound(start_sound);
	if stop_sound: SoundManager.precache_sound(stop_sound);
	if move_sound: SoundManager.precache_sound(move_sound);

func _apply_entity(e):
	super._apply_entity(e);

	$body/mesh.set_mesh(get_mesh());
	$body/collision.shape = get_entity_shape();

func reset_tween():
	if current_tween != null:
		current_tween.stop();
		current_tween = null;
		state = MovementState.STOPPED;
		SoundManager.play_sound(global_transform.origin, stop_sound);
		trigger_output("OnStop");

func is_current_point_valid():
	if not current_point:
		current_point = get_target(entity.get("target", ""));

		if not current_point:
			push_error("No target specified for tracktrain");
			return false

	return true;

## Returns true in case the entity should stop
func move_to_current_point():
	if stop_required:
		return true;

	var target_position = current_point.global_transform.origin;
	var distance = (target_position - global_transform.origin).length();
	var speed = entity.get("speed", 0.0) * config.import.scale;

	if speed == 0.0:
		push_error("Speed is 0, cannot move. Entity id: " + entity.id);
		return;

	var time = distance / speed;

	reset_tween();

	if state == MovementState.STOPPED:
		print("Playing start sound");
		SoundManager.play_sound(global_transform.origin, start_sound);
		SoundManager.play_sound(global_transform.origin, move_sound);

	state = MovementState.MOVING_FORWARD \
			if direction == MovementDirection.FORWARD \
			else MovementState.MOVING_BACKWARD;

	current_tween = create_tween();
	current_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS);
	current_tween.tween_property(self, "global_transform:origin", target_position, time);

	await current_tween.finished;

	current_point._pass();

func move_to_next_point():
	if not is_current_point_valid(): return;
	direction = MovementDirection.FORWARD;

	if await move_to_current_point(): return;

	current_point = current_point.next_stop_target;
	if current_point:
		move_to_next_point()
	else:
		stop_required = false;

func move_to_previous_point():
	if not is_current_point_valid(): return;
	direction = MovementDirection.BACKWARD;

	if await move_to_current_point(): return;

	current_point = current_point.prev_stop_target;
	if current_point:
		move_to_previous_point();
	else:
		stop_required = false;

func teleport_to_point(target_point: String, _trigger_output: bool = false):
	var track = get_target(target_point);

	if not track:
		Debugger.log("Path track not found: " + target_point);
		return;

	current_point = track;
	global_transform.origin = track.global_transform.origin;

	if _trigger_output: track._teleport();

# INPUTS
func StartForward(_param = null):
	if direction == MovementDirection.BACKWARD and current_point:
		current_point = current_point.next_stop_target;
	move_to_next_point();

func StartBackward(_param = null):
	if direction == MovementDirection.FORWARD and current_point:
		current_point = current_point.prev_stop_target;
	move_to_previous_point();

func Toggle(_param = null):
	if state == MovementState.STOPPED:
		if direction == MovementDirection.FORWARD:
			StartForward();
		else:
			StartBackward();
	else:
		Stop();

func Stop(_param = null):
	reset_tween();

func TeleportToPathTrack(target_path_track: String):
	teleport_to_point(target_path_track, true);
