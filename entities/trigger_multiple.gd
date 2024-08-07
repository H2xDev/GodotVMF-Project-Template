@tool
class_name trigger_multiple
extends ValveIONode

const FLAG_CLIENTS = 1;

var has_filter:
	get: return entity.get("filtername", "") != "";

func get_filter_entity() -> filter_entity:
	if not has_filter: return null;
	var target_entity = get_target(entity.get("filtername", ""));

	if not target_entity: return null;

	return target_entity as filter_entity;

func _entity_ready():
	$area.body_entered.connect(func(body):
		var is_client_passed = has_flag(FLAG_CLIENTS) and ValveIONode.aliases["!player"] == body;
		var is_filter_passed = has_filter and get_filter_entity().is_passed(body);

		prints("has_filter", has_filter);

		if is_client_passed or is_filter_passed:
			trigger_output("OnTrigger");
			trigger_output("OnStartTouch");
	);

	$area.body_exited.connect(func(body):
		var is_client_passed = has_flag(FLAG_CLIENTS) and ValveIONode.aliases["!player"] == body;
		var is_filter_passed = has_filter and get_filter_entity().is_passed(body);

		if is_client_passed or is_filter_passed: 
			trigger_output("OnEndTouch");
	);

func _apply_entity(e):
	super._apply_entity(e);
	
	$area/collision.shape = get_entity_shape();
