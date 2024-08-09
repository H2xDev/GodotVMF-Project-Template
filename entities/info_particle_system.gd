@tool
class_name info_particle_system
extends ValveIONode

func _apply_entity(e):
	super._apply_entity(e);

	var scene_path = 'res://particles/{effect_name}.tscn'.format(e);

	if not ResourceLoader.exists(scene_path):
		push_error('Particle effect not found: {0}'.format([scene_path]));
		return;

	var scene = load(scene_path);
	var node = scene.instantiate();
	node.name = "particles";
	node.visible = false;

	add_child(node);

func _entity_ready():
	$particles.visible = entity.get("start_active", 0) == 1;

# INPUTS

func Start(_param = null):
	$particles.visible = true;

func Stop(_param = null):
	$particles.visible = false;

