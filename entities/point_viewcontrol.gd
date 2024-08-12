@tool
extends ValveIONode

const FLAG_START_AT_PLAYER = 1; # NOTE: Actually stasts from the current active camera
const FLAG_INFINITE_HOLD_TIME = 8;
const FLAG_SET_FOV = 128;

var current_tween = null;
var start_transform = null;
var old_camera = null;
var current_stop_target = null;
var old_position = Vector3.ZERO;

func _catmul_rom(p0, p1, p2, p3, t):
	var t2 = t * t;
	var t3 = t2 * t;

	return 0.5 * (
		(2.0 * p1) +
		(-p0 + p2) * t +
		(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
		(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
	);

func _calculate_spline_path(points: Array, subdivisions = 10):
	var path = [];

	for i in range(points.size() - 1):
		var p0 = points[i];
		var p1 = points[i + 1];
		var p2 = points[i + 2] if i + 2 < points.size() else p1;
		var p3 = points[i + 3] if i + 3 < points.size() else p2;

		for j in range(subdivisions):
			var t = float(j) / float(subdivisions);
			path.append(_catmul_rom(p0, p1, p2, p3, t));

	return path;

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
	var target_transform = Transform3D(global_transform);
	global_transform = Transform3D(old_camera.global_transform);

	var start_fov = old_camera.fov;
	var target_fov = $camera.fov \
			if has_flag(FLAG_SET_FOV) \
			else old_camera.fov;

	$camera.fov = start_fov;

	var acceleration = float(entity.get("acceleration", 1.0)) * config.import.scale;
	var time = target_transform.origin.distance_to(from_transform.origin) / acceleration;

	current_tween = create_tween();
	current_tween.tween_property(self, "global_transform", target_transform, time);
	current_tween.parallel().tween_property($camera, "fov", target_fov, time);
	await current_tween.finished;

func _move_through_path():
	var corners = [];

	while current_stop_target:
		corners.append(current_stop_target.global_transform.origin);

		var old_target = current_stop_target;
		current_stop_target = get_target(current_stop_target.entity.get("target", ""));

		if current_stop_target == old_target:
			current_stop_target = null;
			continue;

	var path_points = _calculate_spline_path(corners, 30);

	await _move_to_point(0, path_points);

func _find_corner_by_position(pos: Vector3):
	var target = get_target(entity.get("moveto", ""));

	while target:
		var distance = target.global_transform.origin.distance_to(pos);
		if distance < 0.001: return target;

		target = get_target(target.entity.get("target", ""));

	return null;

func _move_to_point(i = 0, points = []):
	if i >= points.size():
		return;

	var target_position = points[i];
	var next_target = points[i + 1] if i + 1 < points.size() else target_position;
	var to_rotation = Basis.looking_at((next_target - target_position).normalized(), Vector3.UP);

	var acceleration = float(entity.get("acceleration", 1.0)) * config.import.scale;
	var time = target_position.distance_to(next_target) / acceleration;

	current_tween = create_tween();
	current_tween.tween_property(self, "global_position", target_position, time);
	current_tween.parallel().tween_property(self, "global_transform:basis", to_rotation, time);

	await current_tween.finished;

	var passed_corner = _find_corner_by_position(target_position);
	if passed_corner:
		passed_corner._pass();

	await _move_to_point(i + 1, points);


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

	_move_through_path();

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
