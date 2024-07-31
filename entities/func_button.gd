@tool
class_name func_button
extends func_door

const FLAG_DONT_MOVE = 1;
const FLAG_TOUCH_ACTIVATES = 256;
const FLAG_DAMAGE_ACTIVATES = 512;
const FLAG_USE_ACTIVATES = 1024;
const FLAG_SPARKS = 4096;

var wait_time = 0.0;

func _interact(_player: Player):
	if not has_flag(FLAG_USE_ACTIVATES):
		return;

	if is_locked:
		trigger_output("OnUseLocked");
		return;

	if not has_flag(FLAG_DONT_MOVE):
		if wait_time > 0.0: return;
		wait_time = float(entity.wait);

	if not has_flag(FLAG_DONT_MOVE):
		Open(null);

	trigger_output("OnPressed");

func _process(delta: float):
	if wait_time > 0.0:
		wait_time -= delta;
		if wait_time <= 0.0:
			Close(null);
