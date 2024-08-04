extends Node

const SOUND_FOLDER = "res://hammer_project/sound/";

var sound_cache: Dictionary = {};

## Play a sound at a given position
func play_sound(position: Vector3, sound_name: String, volume: float = 1.0, pitch: float = 1.0) -> AudioStreamPlayer3D:
	if sound_name == "":
		push_error("Sound name is empty.");
		return

	var sound = sound_cache.get(sound_name, null);

	if sound == null:
		push_error("Sound " + sound_name + " is not cached. Precache it first.");
		return;

	var sound_player = AudioStreamPlayer3D.new();

	get_tree().get_current_scene().add_child(sound_player);
	sound_player.global_transform.origin = position;

	sound_player.stream = sound;
	sound_player.volume_db = linear_to_db(volume);
	sound_player.pitch_scale = pitch;
	sound_player.connect("finished", sound_player.queue_free);
	sound_player.play(0.0);
	sound_player.max_distance = 10.0;
	return sound_player;

## Play a random sound from a list of sound names
func play_random_sound(position: Vector3, sound_list: PackedStringArray, volume: float = 1.0, pitch: float = 1.0) -> AudioStreamPlayer3D:
	var sound_name = Array(sound_list).pick_random();

	return play_sound(position, sound_cache[sound_name], volume, pitch);

func play_everywhere(sound_name: String, volume: float = 1.0, pitch: float = 1.0) -> AudioStreamPlayer:
	if sound_name == "":
		push_error("Sound name is empty.");
		return

	var sound = sound_cache.get(sound_name, null);

	if sound == null:
		push_error("Sound " + sound_name + " is not cached. Precache it first.");
		return;

	var sound_player = AudioStreamPlayer.new();

	get_tree().get_current_scene().add_child(sound_player);

	sound_player.stream = sound;
	sound_player.volume_db = linear_to_db(volume);
	sound_player.pitch_scale = pitch;
	sound_player.connect("finished", sound_player.queue_free);
	sound_player.play(0.0);
	return sound_player;

func precache_sound(sound_name) -> String:
	if not sound_name: return "";

	print("Precaching sound " + sound_name);
	sound_cache[sound_name] = load(SOUND_FOLDER + sound_name);

	return sound_name;
