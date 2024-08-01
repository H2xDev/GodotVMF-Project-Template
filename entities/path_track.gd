@tool
class_name path_track
extends ValveIONode

var next_stop_target: path_track:
	get: return get_target(entity.target);

func _apply_entity(e):
	super._apply_entity(e)
