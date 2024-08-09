@tool
extends ValveIONode

const FLAG_START_AT_PLAYER = 1; # NOTE: Actually stasts from the current active camera
const FLAG_INFINITE_HOLD_TIME = 8;
const FLAG_SET_FOV = 128;

var current_tween = null;
var start_transform = null;
var old_camera = null;

var current_stop_target = null;

func _apply_entity(e):
	super._apply_entity(e);

	if has_flag(FLAG_SET_FOV):
		$camera.fov = e.get("fov", 90.0);

func _entity_ready():
	start_transform = global_transform;
	current_stop_target = get_target(entity.get("moveto", ""));
	
func _tween_camera():
	if not old_camera: return;

	if current_tween:
		current_tween.stop();
		current_tween = null;

	var from_transform = Transform3D(old_camera.global_transform);
	var target_transform = Transform3D(self.global_transform);
	self.global_transform = Transform3D(old_camera.global_transform);

	var start_fov = old_camera.fov;
	var target_fov = $camera.fov \
			if has_flag(FLAG_SET_FOV) \
			else old_camera.fov;

	$camera.fov = start_fov;

	var acceleration = float(entity.get("acceleration", 1.0)) * config.import.scale;
	var time = target_transform.origin.distance_to(from_transform.origin) / acceleration;

	current_tween = create_tween();
	current_tween.set_ease(Tween.EASE_IN_OUT);
	current_tween.set_trans(Tween.TRANS_QUAD);
	current_tween.tween_property(self, "global_transform", target_transform, time);
	current_tween.parallel().tween_property($camera, "fov", target_fov, time);
	await current_tween.finished;

func _move_to_path_corner():
	if not current_stop_target: return;

	var distance = global_position.distance_to(current_stop_target.global_position);
	var acceleration = float(entity.get("acceleration", 1.0)) * config.import.scale;
	var time = distance / acceleration;

	current_tween = create_tween();
	current_tween.set_ease(Tween.EASE_IN_OUT);
	current_tween.set_trans(Tween.TRANS_SINE);
	current_tween.tween_property(self, "global_transform", current_stop_target.global_transform, time);

	await current_tween.finished;

	current_stop_target._pass();
	current_stop_target = current_stop_target.next_stop_target;

	_move_to_path_corner();

# INPUTS

func Enable(_param = null):
	super.Enable(_param);

	var player = get_target("!player");

	if "camera" in player:
		old_camera = player.camera;
	else:
		old_camera = get_viewport().get_camera();

	$camera.make_current();
	$camera/listener.make_current();

	if has_flag(FLAG_START_AT_PLAYER):
		await _tween_camera();
	else:
		global_transform = Transform3D(current_stop_target.global_transform);


	_move_to_path_corner();

	if not has_flag(FLAG_INFINITE_HOLD_TIME):
		await get_tree().create_timer(entity.get("wait", 0.0)).timeout;
		Disable();

func Disable(_param = null):
	super.Disable(_param);

	if old_camera:
		old_camera.make_current();
		var listener = old_camera.get_node("listener");
		if listener: listener.make_current();

	old_camera = null;

	if current_tween:
		current_tween.stop();
		current_tween = null;
