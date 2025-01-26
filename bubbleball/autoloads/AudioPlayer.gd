extends Node2D


@export var effect_2D_max_distance: float = 480.0

@onready var music_players: = [$MusicPlayer0, $MusicPlayer1]
var music_player_index: = 0
var music_player_next_index: int : get = get_music_player_next_index
var music_player: AudioStreamPlayer : get = get_music_player
var music_player_next: AudioStreamPlayer : get = get_music_player_next
var max_volume = -10.0


func _ready():
	$MusicPlayer0.volume_db = max_volume
	$MusicPlayer1.volume_db = -80.0


static func choose_pitch_scale(scale: float, lower: float = 0.0, upper: float = 0.0) -> float:
	return randf_range(scale + lower, scale + upper)


static func choose_stream(_stream: AudioStream, _alt_streams: Array, _current_stream: AudioStream = null) -> AudioStream:
	if not _alt_streams.is_empty():
		if _current_stream and _alt_streams.size() > 1:
			_alt_streams = _alt_streams.duplicate()
			_alt_streams.erase(_current_stream)
		return _alt_streams[randi() % _alt_streams.size()]
	return _stream


func get_loop_mode(audio_stream: AudioStream) -> int:
	if "loop_mode" in audio_stream:
		return audio_stream.get("loop_mode")
	if "audio_stream" in audio_stream:
		audio_stream = audio_stream.get("audio_stream")
		if "loop_mode" in audio_stream:
			return audio_stream.get("loop_mode")
	return 0


func get_music_player_next_index() -> int:
	return posmod(music_player_index + 1, music_players.size())


func get_music_player() -> AudioStreamPlayer:
	return music_players[self.music_player_index]


func get_music_player_next() -> AudioStreamPlayer:
	return music_players[self.music_player_next_index]


func play_interface(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0, delay: float = 0.0) -> AudioStreamPlayer:
	var audio_player: = AudioStreamPlayer.new()
	audio_player.stream = stream
	play_audio_player(audio_player, "Interface", volume_db, pitch_scale, delay)
	return audio_player


func play_effect(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0, delay: float = 0.0, bus: String = "Effects") -> AudioStreamPlayer:
	var audio_player: = AudioStreamPlayer.new()
	audio_player.stream = stream
	play_audio_player(audio_player, bus, volume_db, pitch_scale, delay)
	return audio_player


func play_effect_2D(stream: AudioStream, audio_position: Vector2, volume_db: float = 0.0, pitch_scale: float = 1.0, delay: float = 0.0) -> AudioStreamPlayer2D:
	var audio_player: = AudioStreamPlayer2D.new()
	audio_player.max_distance = effect_2D_max_distance
	audio_player.stream = stream
	audio_player.position = audio_position
	play_audio_player(audio_player, "Effects", volume_db, pitch_scale, delay)
	return audio_player


func play_audio_player(audio_player, bus: String = "Effects", volume_db: float = 0.0, pitch_scale: float = 1.0, delay: float = 0.0):
	if not audio_player or not audio_player.stream:
		return

	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

#	if not Settings.is_initialized:
#		yield(Settings, "initialized")

	audio_player.volume_db = volume_db
	audio_player.pitch_scale = pitch_scale
	audio_player.bus = bus
	add_child(audio_player)
	audio_player.connect("finished", audio_player.queue_free, CONNECT_ONE_SHOT)
	audio_player.play()


func play_music(
	stream: AudioStream,
	cross_fade: float = 1.0,
	fade_out: float = 1.0,
	fade_in: float = 0.0,
	fade_out_trans: int = Tween.TRANS_SINE,
	fade_out_ease: int = Tween.EASE_IN_OUT,
	fade_in_trans: int = Tween.TRANS_SINE,
	fade_in_ease: int = Tween.EASE_IN_OUT
):

#	if not Settings.is_initialized:
#		yield(Settings, "initialized")

	if self.music_player.playing and self.music_player.stream == stream:
		# already playing requested stream
		return

	if self.music_player.playing and (cross_fade > 0.0 or fade_in > 0.0 or fade_out > 0.0):
		self.music_player_next.stop()
		self.music_player_next.volume_db = -80.0
		self.music_player_next.stream = stream

		var fade_out_delay: float = max(cross_fade - fade_out, 0.0)
		var fade_in_delay: float = max(fade_out - cross_fade, 0.0)
		
		var tween = get_tree().create_tween()
		tween.tween_property(
			self.music_player,
			"volume_db",
			-80,
			fade_out
		).set_ease(fade_out_ease).set_trans(fade_out_trans).set_delay(fade_out_delay)
		tween.tween_callback(self.music_player.stop).set_delay(fade_out + fade_out_delay)
		
		tween.parallel().tween_property(
			self.music_player_next,
			"volume_db",
			max_volume,
			fade_in
		).set_ease(fade_in_ease).set_trans(fade_in_trans).set_delay(fade_in_delay)
		tween.tween_callback(self.music_player_next.play).set_delay(fade_in_delay)
		self.music_player_index = self.music_player_next_index
	else:
		self.music_player.stop()
		self.music_player.stream = stream
		self.music_player.volume_db = max_volume
		
		var tween = get_tree().create_tween()
		tween.tween_callback(self.music_player.play).set_delay(fade_in)

func fade_music(fade_out: float = 2.0):
	if not self.music_player.playing:
		# already playing requested stream
		return
		
	if fade_out > 0.0:
		var tween = get_tree().create_tween()
		tween.tween_property(
			self.music_player,
			"volume_db",
			-80.0,
			fade_out
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(self.music_player.stop).set_delay(fade_out)
	else:
		self.music_player.stop()


func fade_and_stop(audio_player: AudioStreamPlayer, fade_out: float = 0.2):
	if not audio_player.playing:
		# already stopped
		return

	if fade_out > 0.0:
		var fade_tween: Tween = audio_player.create_tween().set_parallel(true)
		fade_tween.tween_property(
			audio_player,
			"volume_db",
			-80.0,
			fade_out
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		fade_tween.tween_callback(audio_player.stop).set_delay(fade_out)
	else:
		audio_player.stop()
