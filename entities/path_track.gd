@tool
class_name path_track
extends ValveIONode

var next_stop_target: path_track:
	get: return get_target(entity.get("target", ""));

var prev_stop_target: path_track = null;

func _entity_ready():
	if next_stop_target and next_stop_target is path_track:
		next_stop_target.prev_stop_target = self;

	rotation_degrees.y -= 90;

func _pass():
	trigger_output("OnPass");

func _teleport():
	trigger_output("OnTeleport");
