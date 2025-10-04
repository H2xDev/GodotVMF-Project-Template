@tool
class_name filter_activator_name extends filter_entity

func is_passed(node: Node3D) -> bool:
	var is_inverted = str(entity.get("Negated", 0)) == "1";
	var target_entity: VMFEntityNode = get_entity(node);

	if not target_entity: return false;

	var passed: bool = target_entity.entity.get("targetname", "") == entity.get("filtername", "");

	return passed if not is_inverted else not passed;
