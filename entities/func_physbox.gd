@tool
extends ValveIONode

var FLAG_IGNORE_PICKUP = 8192;
var FLAG_MOTION_DISABLED = 32768;

func EnableMotion(_param):
	$body.freeze = false;

func DisableMotion(_param):
	$body.freeze = true;

func _apply_entity(e):
	super._apply_entity(e);

	$body.freeze = has_flag(FLAG_MOTION_DISABLED);
	$body/mesh.set_mesh(get_mesh());
	$body/collision.shape = get_entity_shape();

	$body.mass = $body/mesh.get_aabb().size.x * $body/mesh.get_aabb().size.y * $body/mesh.get_aabb().size.z * 0.01;
