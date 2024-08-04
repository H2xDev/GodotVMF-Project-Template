@tool
class_name InfoParticleSystem extends ValveIONode

func _apply_entity(e):
	super._apply_entity(e);

	var scenePath = 'res://Particles/{effect_name}.tscn'.format(e);

	if not ResourceLoader.exists(scenePath):
		push_error('Particle effect not found: {0}'.format([scenePath]));
		return;

	global_rotation = convert_direction(e.angles);

	var scene = load(scenePath);
	var node = scene.instantiate();

	get_parent().add_child(node);
	node.set_owner(owner);
	node.name = '{effect_name}_{id}'.format(e);
	node.global_transform = global_transform;

	queue_free();
