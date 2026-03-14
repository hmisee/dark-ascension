extends Node

## Centralized audio manager for BGM playback with crossfade transitions
## and SFX playback with polyphonic channel pooling.

# --- Constants ---
const CROSSFADE_DURATION: float = 1.5
const SFX_POOL_SIZE: int = 8

# --- BGM State ---
var _bgm_tracks: Dictionary = {}
var _bgm_players: Array[AudioStreamPlayer] = []
var _current_bgm: String = ""
var _active_bgm_index: int = 0
var _crossfade_tween: Tween = null

# --- SFX State ---
var _sfx_clips: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	_preload_bgm_tracks()
	_preload_sfx_clips()
	_create_bgm_players()
	_create_sfx_players()


func _preload_bgm_tracks() -> void:
	var bgm_names: Array[String] = ["menu", "wave", "boss"]
	for track_name in bgm_names:
		var path := "res://assets/audio/music/%s.ogg" % track_name
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream is AudioStreamOggVorbis:
				stream.loop = true
			_bgm_tracks[track_name] = stream
		else:
			push_warning("AudioManager: Missing BGM resource '%s'" % path)


func _preload_sfx_clips() -> void:
	var sfx_names: Array[String] = [
		"player_hit", "player_death", "player_attack",
		"enemy_hit", "enemy_death", "shadow_death", "boss_defeat"
	]
	for sfx_name in sfx_names:
		var path := "res://assets/audio/sfx/%s.wav" % sfx_name
		if ResourceLoader.exists(path):
			_sfx_clips[sfx_name] = load(path)
		else:
			push_warning("AudioManager: Missing SFX resource '%s'" % path)


func _create_bgm_players() -> void:
	for i in range(2):
		var player := AudioStreamPlayer.new()
		player.bus = "Music"
		player.name = "BGMPlayer%d" % i
		add_child(player)
		_bgm_players.append(player)


func _create_sfx_players() -> void:
	for i in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		player.volume_db = -18.0
		player.name = "SFXPlayer%d" % i
		add_child(player)
		_sfx_players.append(player)


# --- BGM ---

func play_bgm(track_name: String) -> void:
	if _bgm_tracks.is_empty():
		return
	if track_name not in _bgm_tracks:
		push_warning("AudioManager: Unknown BGM track '%s'" % track_name)
		return
	if track_name == _current_bgm:
		return

	var active_player := _bgm_players[_active_bgm_index]

	# If a BGM is currently playing, crossfade to the new track
	if active_player.playing:
		# Task 3.2: Kill any in-progress crossfade before starting a new one
		if is_instance_valid(_crossfade_tween):
			_crossfade_tween.kill()
			_crossfade_tween = null

		# Outgoing player is the current active one
		var outgoing_player := active_player
		# Incoming player is the alternate
		var incoming_index := 1 - _active_bgm_index
		var incoming_player := _bgm_players[incoming_index]

		# Set up the incoming player
		incoming_player.stream = _bgm_tracks[track_name]
		incoming_player.volume_db = -80.0
		incoming_player.play()

		# Create crossfade tween
		_crossfade_tween = create_tween()
		# Fade out outgoing from current volume to silence
		_crossfade_tween.tween_property(outgoing_player, "volume_db", -80.0, CROSSFADE_DURATION)
		# Fade in incoming from silence to full volume (in parallel)
		_crossfade_tween.parallel().tween_property(incoming_player, "volume_db", 0.0, CROSSFADE_DURATION)
		# Stop the outgoing player when crossfade completes
		_crossfade_tween.finished.connect(outgoing_player.stop)

		# Swap active index and update current track
		_active_bgm_index = incoming_index
		_current_bgm = track_name
	else:
		# No BGM playing — simple start
		active_player.stream = _bgm_tracks[track_name]
		active_player.volume_db = 0.0
		active_player.play()
		_current_bgm = track_name


func stop_bgm() -> void:
	for player in _bgm_players:
		player.stop()
	if is_instance_valid(_crossfade_tween):
		_crossfade_tween.kill()
		_crossfade_tween = null
	_current_bgm = ""


func get_current_bgm() -> String:
	return _current_bgm


# --- SFX ---

func play_sfx(sfx_name: String) -> void:
	if sfx_name not in _sfx_clips:
		push_warning("AudioManager: Unknown SFX clip '%s'" % sfx_name)
		return

	# Find the first non-playing SFX player
	for player in _sfx_players:
		if not player.playing:
			player.stream = _sfx_clips[sfx_name]
			player.play()
			return

	# All 8 channels busy — find the one closest to completion
	var best_player: AudioStreamPlayer = _sfx_players[0]
	var best_ratio: float = 0.0
	for player in _sfx_players:
		var length := player.stream.get_length()
		var ratio := player.get_playback_position() / length if length > 0.0 else 1.0
		if ratio > best_ratio:
			best_ratio = ratio
			best_player = player

	best_player.stream = _sfx_clips[sfx_name]
	best_player.play()
