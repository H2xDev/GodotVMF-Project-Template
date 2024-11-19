@tool
class_name PointTeleport extends ValveIONode

func Teleport(_param = null):
	var target = get_target(entity.target);
	if not target:
		push_warning("point_teleport: Target not found");
		return;

	target.global_transform = global_transform;
	target.rotation.y = convert_direction(entity.angles).y - PI / 2.0;

	if "velocity" in target:
		target.velocity = Vector3.ZERO;

