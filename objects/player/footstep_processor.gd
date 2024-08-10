class_name FootstepProcessor
extends RefCounted

const SOUNDS_COUNT = 15;
const SOUND_PATTERN = "footsteps/footstep_{0}.wav";
const SOUND_INTERVAL = 2.0; # NOTE: meters per sound

var player: Player;
var sounds: Array[String] = []
var ticks: float = 0;

func _init(p: Player):
	self.player = p;

	_precache_sounds();

func _precache_sounds():
	for i in range(SOUNDS_COUNT):
		var sound = SoundManager.precache_sound(SOUND_PATTERN.format([i + 1]));
		if sound: sounds.append(sound);

func _play_sound():
	var sound = sounds.pick_random();
	var source = SoundManager.play_sound(player.global_position, sound);
	if source: source.max_distance = 3.0;

func process(delta):
	if not player.is_on_floor(): 
		ticks = SOUND_INTERVAL;
		return;

	var prev_tick = ticks;
	var horizontal_velocity = Vector2(player.velocity.x, player.velocity.z);

	ticks += delta * horizontal_velocity.length();
	ticks = fmod(ticks, SOUND_INTERVAL);

	if prev_tick > ticks: _play_sound();
