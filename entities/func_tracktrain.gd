@tool
class_name func_tracktrain
extends ValveIONode

var current_point: path_track = null;
var current_tween: Tween = null;

func move_to_next_point():
	if current_tween != null:
		current_tween.stop();
		current_tween = null;
	
	if not current_point:
		current_point = get_target(entity.get("target", ""));

		if not current_point:
			push_error("No target specified for tracktrain");
			return;

	var target_position = current_point.global_transform.origin;
	var time = (target_position - global_transform.origin).length() / (entity.get("speed", 1.0) * config.import.scale);

	current_tween = create_tween();
	current_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS);
	current_tween.tween_property(self, "global_transform:origin", target_position, time);

	await current_tween.finished;
	current_point = current_point.next_stop_target;

	if current_point:
		move_to_next_point();

# INPUTS
func StartForward(_param):
	move_to_next_point();

func Stop(_param):
	pass;

func _apply_entity(e):
	super._apply_entity(e);

	$body/mesh.set_mesh(get_mesh());
	$body/collision.shape = get_entity_shape();
