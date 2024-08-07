@tool
class_name filter_activator_name
extends filter_entity

func is_passed(node: Node3D) -> bool:
	var is_inverted = str(entity.get("Negated", 0)) == "1";
	var target_entity = get_entity(node);

	if not target_entity: return false;
	
	if is_inverted:
		return target_entity.name == entity.get("targetname", "");
	else:
		return target_entity.name != entity.get("targetname", "");
