extends Node

## AudioManager Singleton
## Provides audio voice pooling, procedural sound synthesis, and music playback.

var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
var procedural_sfx: Dictionary = {}

var sfx_volume_db: float = 0.0
var music_volume_db: float = -6.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Create SFX voice pool (8 voices)
	for i in range(8):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_players.append(p)

	# Dedicated Music Player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.volume_db = music_volume_db
	add_child(music_player)

	# Synthesize authentic Swordigo-calibrated sound effects
	_generate_procedural_sounds()

func _generate_procedural_sounds() -> void:
	procedural_sfx["jump"] = _generate_tone(320.0, 580.0, 0.15, 0.4, "sine")
	procedural_sfx["double_jump"] = _generate_tone(480.0, 780.0, 0.18, 0.4, "sine")
	procedural_sfx["attack"] = _generate_noise_sweep(0.12, 0.35)
	procedural_sfx["hit"] = _generate_impact(0.18, 0.5)
	procedural_sfx["magic"] = _generate_tone(520.0, 1040.0, 0.3, 0.45, "triangle")
	procedural_sfx["spell_aoe"] = _generate_impact(0.35, 0.6)
	procedural_sfx["coin"] = _generate_two_tone(987.77, 1318.51, 0.18, 0.35)
	procedural_sfx["hurt"] = _generate_tone(180.0, 90.0, 0.22, 0.5, "saw")
	procedural_sfx["pot_break"] = _generate_crunch(0.2, 0.4)
	procedural_sfx["chest"] = _generate_chord([523.25, 659.25, 783.99, 1046.50], 0.6, 0.4)
	procedural_sfx["checkpoint"] = _generate_chord([440.0, 554.37, 659.25], 0.5, 0.35)
	procedural_sfx["portal"] = _generate_sweep(220.0, 880.0, 0.5, 0.4)
	procedural_sfx["switch"] = _generate_tone(880.0, 1100.0, 0.12, 0.3, "square")
	procedural_sfx["boss_roar"] = _generate_tone(90.0, 55.0, 0.8, 0.6, "saw")
	procedural_sfx["victory"] = _generate_chord([523.25, 659.25, 783.99, 1046.50, 1318.51], 1.2, 0.45)

func play_sfx(sound_name: String, pitch_variance: float = 0.05) -> void:
	if not procedural_sfx.has(sound_name):
		return

	var player: AudioStreamPlayer = null
	for p in sfx_players:
		if not p.playing:
			player = p
			break

	if player == null:
		player = sfx_players[0]

	player.stream = procedural_sfx[sound_name]
	player.volume_db = sfx_volume_db
	if pitch_variance > 0.0:
		player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
	else:
		player.pitch_scale = 1.0
	player.play()

func play_music(music: Variant, _fade_time: float = 0.5) -> void:
	if music is AudioStream:
		if music_player.stream == music and music_player.playing:
			return
		music_player.stop()
		music_player.stream = music
		music_player.play()
	elif music is String:
		if procedural_sfx.has(music):
			music_player.stream = procedural_sfx[music]
			music_player.play()

func stop_music() -> void:
	music_player.stop()

func _create_wav(byte_data: PackedByteArray, sample_rate: int = 22050) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = byte_data
	return wav

func _generate_tone(f_start: float, f_end: float, duration: float, volume: float, wave: String) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(duration * sample_rate)
	var bytes = PackedByteArray()
	bytes.resize(total_samples)

	var phase: float = 0.0
	for i in range(total_samples):
		var t = float(i) / total_samples
		var freq = lerp(f_start, f_end, t)
		var delta_phase = freq / sample_rate
		phase = fmod(phase + delta_phase, 1.0)

		var env = 1.0 - t
		var sample: float = 0.0

		match wave:
			"sine":
				sample = sin(phase * TAU)
			"triangle":
				sample = (abs(phase - 0.5) * 4.0 - 1.0)
			"saw":
				sample = (phase * 2.0 - 1.0)
			"square":
				sample = 1.0 if phase < 0.5 else -1.0

		var val = clamp(int((sample * env * volume * 120.0) + 128.0), 0, 255)
		bytes[i] = val

	return _create_wav(bytes, sample_rate)

func _generate_two_tone(f1: float, f2: float, duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(duration * sample_rate)
	var half = total_samples / 2
	var bytes = PackedByteArray()
	bytes.resize(total_samples)

	var phase: float = 0.0
	for i in range(total_samples):
		var freq = f1 if i < half else f2
		phase = fmod(phase + freq / sample_rate, 1.0)
		var env = 1.0 - (float(i % half) / half) * 0.5
		var sample = sin(phase * TAU) * env * volume
		bytes[i] = clamp(int(sample * 120.0 + 128.0), 0, 255)

	return _create_wav(bytes, sample_rate)

func _generate_chord(freqs: Array, duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(duration * sample_rate)
	var bytes = PackedByteArray()
	bytes.resize(total_samples)

	var phases: Array[float] = []
	for _f in freqs:
		phases.append(0.0)

	for i in range(total_samples):
		var t = float(i) / total_samples
		var env = pow(1.0 - t, 1.5)
		var sample_sum: float = 0.0

		for j in range(freqs.size()):
			var f = freqs[j]
			phases[j] = fmod(phases[j] + f / sample_rate, 1.0)
			sample_sum += sin(phases[j] * TAU)

		sample_sum = (sample_sum / freqs.size()) * env * volume
		bytes[i] = clamp(int(sample_sum * 120.0 + 128.0), 0, 255)

	return _create_wav(bytes, sample_rate)

func _generate_noise_sweep(duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(duration * sample_rate)
	var bytes = PackedByteArray()
	bytes.resize(total_samples)

	for i in range(total_samples):
		var t = float(i) / total_samples
		var env = sin(t * PI)
		var noise = randf_range(-1.0, 1.0)
		var sample = noise * env * volume
		bytes[i] = clamp(int(sample * 120.0 + 128.0), 0, 255)

	return _create_wav(bytes, sample_rate)

func _generate_impact(duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(duration * sample_rate)
	var bytes = PackedByteArray()
	bytes.resize(total_samples)

	var phase: float = 0.0
	for i in range(total_samples):
		var t = float(i) / total_samples
		var freq = lerp(180.0, 35.0, pow(t, 0.4))
		phase = fmod(phase + freq / sample_rate, 1.0)
		var env = pow(1.0 - t, 2.0)
		var noise = randf_range(-0.3, 0.3)
		var sample = (sin(phase * TAU) + noise) * env * volume
		bytes[i] = clamp(int(sample * 120.0 + 128.0), 0, 255)

	return _create_wav(bytes, sample_rate)

func _generate_crunch(duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(duration * sample_rate)
	var bytes = PackedByteArray()
	bytes.resize(total_samples)

	for i in range(total_samples):
		var t = float(i) / total_samples
		var env = pow(1.0 - t, 1.2)
		var noise = randf_range(-1.0, 1.0)
		if randf() > 0.4:
			noise *= 0.2
		bytes[i] = clamp(int(noise * env * volume * 120.0 + 128.0), 0, 255)

	return _create_wav(bytes, sample_rate)

func _generate_sweep(f_start: float, f_end: float, duration: float, volume: float) -> AudioStreamWAV:
	return _generate_tone(f_start, f_end, duration, volume, "sine")
