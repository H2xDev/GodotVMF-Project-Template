@tool
class_name ambient_generic
extends ValveIONode

const FLAG_PLAY_EVERYWHERE = 1;
const FLAG_START_SILENT = 16;
const FLAG_IS_NOT_LOOPED = 32;

var sound = null;
var sound_instance = null;
var volume = 1.0;

func _entity_ready():
	sound = entity.get("message", "");
	volume = entity.get("health", 10.0) / 10.0;

	if sound:
		SoundManager.precache_sound(entity.get("message", ""));

func _apply_entity(e):
	super._apply_entity(e);

func play_sound(_v = volume):
	if has_flag(FLAG_PLAY_EVERYWHERE):
		sound_instance = SoundManager.play_everywhere(sound, _v);
		return;

	sound_instance = SoundManager.play_sound(global_transform.origin, sound, _v);

# INPUTS
func PlaySound(_param = null):
	play_sound();

func StopSound(_param = null):
	if sound_instance:
		SoundManager.stop_sound(sound_instance);
		sound_instance.queue_free();
		sound_instance = null;

func FadeIn(time = 0.0):
	play_sound(0.0);

	var target_volume = linear_to_db(volume);
	var tween = create_tween();
	tween.tween_property(sound_instance, "volume_db", target_volume, float(time));

func FadeOut(time = 0.0):
	if sound_instance: return;

	var target_volume = linear_to_db(0.0);
	var tween = create_tween();
	tween.tween_property(sound_instance, "volume_db", target_volume, float(time));
