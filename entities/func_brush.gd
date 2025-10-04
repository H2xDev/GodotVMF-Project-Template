@tool
class_name func_brush extends VMFEntityNode

enum Solidity {
	TOGGLE,
	NEVER,
	ALWAYS,
}

func _entity_setup(e: VMFEntity) -> void:
	$body/mesh.set_mesh(get_mesh());

	if e.data.get("Solidity") == Solidity.NEVER:
		$body/collision.queue_free();
	else:
		$body/collision.shape = get_entity_shape();

func _process(_dt):
	if Engine.is_editor_hint(): return;

	if $body.has_node("collision"):
		$body/collision.disabled = not enabled;
	
	$body.visible = enabled;
