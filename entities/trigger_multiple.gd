@tool
class_name trigger_multiple
extends ValveIONode

func _entity_ready():
	$area.body_entered.connect(func(_node):
		if ValveIONode.aliases["!player"] == _node: 
			trigger_output("OnTrigger");
			trigger_output("OnStartTouch");
	);

	$area.body_exited.connect(func(_node):
		if ValveIONode.aliases["!player"] == _node: 
			trigger_output("OnEndTouch");
	);

func _apply_entity(e):
	super._apply_entity(e);
	
	$area/collision.shape = get_entity_shape();
