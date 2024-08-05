@tool
extends ValveIONode

const FLAG_FADE_FROM = 1;

func Fade(_param = null):
	var duration = entity.get("duration", 0.0);
	var color_vector = entity.get("rendercolor", Vector3.ZERO);
	var alpha = entity.get("renderamt", 255.0);
	var color = Color8(int(color_vector.x), int(color_vector.y), int(color_vector.z), int(alpha));

	trigger_output("OnBeginFade");

	HUD.fade(color, duration, has_flag(FLAG_FADE_FROM));
