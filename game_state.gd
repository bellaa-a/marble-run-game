# two player ideas
# each block have different symbol have to describe symbol for other player to move
# one player can move blocks. its placement on the board is scattered. other player is the actual setup. 
# tell one player to move blocks. other player can see action happen
# or both players have same blocks same symbols but different placement. both have a marble and need to use same blocks to create 2 paths
# certain number of combined turns. each player takes turns, if turns are used up, both sides can't modify board anymore. have to reset entire board to modify. 

# in second half, can forcefully clear other player's board at any time before they finish
# in first or second half, blocks other player's screen slightly (like camera shaking or paint spattering or egg spatter to block vision)
# in second half, able to break rules (turn blocks during play) for like 20 seconds
# increase/derease frame rate (tick speed)
# clog pipes (delay marble drops)
# invisible marble (still animations and sounds for blocks)
# moving obstacle
# things that stress out the player (like disco or fire alarm or ur freezing or ur hot, or edges turn black)
# mystery box (could be anything. could have low chances of special message or sudden death or win)
# locks screen until player gets it right (like higher or lower with card desks or does math problem, click through i agree, turns and conditions, robot checking drag puzzle peice, have to type certain number of words, xxx ur opponent is so great)
# flipped screen (upside down)
# exchange a card you choose for a random card from your oponent

extends Node

var locked = false
var didTutorial = false

# 1. baby steps - steps
var regular_progress = 1 # regular mechanics
# 2. reflections - mirror
var mirror_progress = 0 # turning block one way turns other blocks of same material on the other side the other way (half as much so). mirror dissapears oncce player presses play
# 3. upside down - gravity
var gravity_progress = 0 # gravity flips every time red button is pressed
# 4. twin paths - twins
var double_progress = 0 # two marbles, both need to be in goal. must press both open goal at same time
# 5. against time - timing
var timed_progress = 0 # blocks only valid during set time
# 6. break the rules! - break
var break_progress = 0 # can change rotation of blocks during play
# 7. center stage - spotlight
var light_progress = 0 # theater lights shine down on blocks. player toggles light on and off. if marble isn't in light, it becomes a shadow and travel along bottom of blocks instead. 
# 8. make it count - careful
var careful_progress = 0 # have a set number of balls. if hit goo and no more balls left, restart from lvl 1 of this world
# 9. everything everywhere - remix
var everything_progress = 0 # all previous mechanics are fair play
# 3 balls + goo + timed 
# gravity + timed (gotta time gravity buttons too
# light + mirror
# goo + gravity + 2 balls + timed
# light no gravity, no timed
# 10. worst enemy - myself
var myself_progress = 0 # second time trying to stop urself's first time. third time trying to avoid second time's attacks. Fourth time trying to stop urself's third time. 

var endTutorial = "res://Scenes/tutorial4"

var time := 0.0
const LEVELS_PER_WORLD := 4

var max_lives := 3
var lives := 3

var game_won := false
var life_loss_pending := false

var num_died := 0

var music_volume := 100.0
var sfx_volume := 100.0

var current_attack := false
var myself_turn := 0

var length_rolled := 0.0
var num_played := 0
var times_in_goo := 0


func _process(delta):
	if locked:
		time += delta


func _ready():
	load_progress()
	

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		

func _apply_bus_volume(bus_name: String, value: float):
	var bus = AudioServer.get_bus_index(bus_name)
	var v := value / 100.0

	if v <= 0.01:
		AudioServer.set_bus_volume_db(bus, -80)
	else:
		AudioServer.set_bus_volume_db(bus, linear_to_db(v))


func complete_level(group_name: String, level_number: int):
	if group_name == "tutorial":
		return

	match group_name:
		"regular":
			regular_progress = max(regular_progress, level_number + 1)

			if regular_progress > LEVELS_PER_WORLD:
				mirror_progress = max(mirror_progress, 1)

		"mirror":
			mirror_progress = max(mirror_progress, level_number + 1)

			if mirror_progress > LEVELS_PER_WORLD:
				gravity_progress = max(gravity_progress, 1)

		"gravity":
			gravity_progress = max(gravity_progress, level_number + 1)

			if gravity_progress > LEVELS_PER_WORLD:
				double_progress = max(double_progress, 1)

		"double":
			double_progress = max(double_progress, level_number + 1)
			
			if double_progress > LEVELS_PER_WORLD:
				timed_progress = max(timed_progress, 1)
		
		"timed":
			timed_progress = max(timed_progress, level_number + 1)
			
			if timed_progress > LEVELS_PER_WORLD:
				break_progress = max(break_progress, 1)
		
		"break":
			break_progress = max(break_progress, level_number + 1)
			
			if break_progress > LEVELS_PER_WORLD:
				light_progress = max(light_progress, 1)
		
		"light":
			light_progress = max(light_progress, level_number + 1)
			
			if light_progress > LEVELS_PER_WORLD:
				careful_progress = max(careful_progress, 1)
				
		"careful":
			careful_progress = max(careful_progress, level_number + 1)
			
			if careful_progress > LEVELS_PER_WORLD:
				everything_progress = max(everything_progress, 1)
				
		"everything":
			everything_progress = max(everything_progress, level_number + 1)
			
			if everything_progress > LEVELS_PER_WORLD:
				myself_progress = max(myself_progress, 1)
		
		"myself":
			myself_progress = max(myself_progress, level_number + 1)
			
			
	save_progress()
	

func save_progress():
	var save_data = {
		"didTutorial": didTutorial,
		"lives": lives,
		"num_died": num_died,
		"music_volume" : music_volume,
		"sfx_volume" : sfx_volume,
		"regular_progress": regular_progress,
		"mirror_progress": mirror_progress,
		"gravity_progress": gravity_progress,
		"double_progress": double_progress,
		"timed_progress": timed_progress,
		"break_progress": break_progress,
		"light_progress": light_progress,
		"careful_progress": careful_progress,
		"everything_progress": everything_progress,
		"myself_progress": myself_progress,
		"length_rolled" : length_rolled,
		"num_played" : num_played,
		"times_in_goo" : times_in_goo
	}

	var file = FileAccess.open("user://save.save", FileAccess.WRITE)
	file.store_var(save_data)


func load_progress():
	if not FileAccess.file_exists("user://save.save"):
		lives = max_lives
		save_progress()
		return

	var file = FileAccess.open("user://save.save", FileAccess.READ)
	var save_data = file.get_var()

	didTutorial = save_data.get("didTutorial", false)
	lives = save_data.get("lives", max_lives)
	num_died = save_data.get("num_died", 0)
	music_volume = save_data.get("music_volume", 100)
	sfx_volume = save_data.get("sfx_volume", 100)
	regular_progress = save_data.get("regular_progress", 1)
	mirror_progress = save_data.get("mirror_progress", 0)
	gravity_progress = save_data.get("gravity_progress", 0)
	double_progress = save_data.get("double_progress", 0)
	timed_progress = save_data.get("timed_progress", 0)
	break_progress = save_data.get("break_progress", 0)
	light_progress = save_data.get("light_progress", 0)
	careful_progress = save_data.get("careful_progress", 0)
	everything_progress = save_data.get("everything_progress", 0)
	myself_progress = save_data.get("myself_progress", 0)
	length_rolled = save_data.get("length_rolled", 0.0)
	num_played = save_data.get("num_played", 0)
	times_in_goo = save_data.get("times_in_goo", 0)

	_apply_bus_volume("Music", GameState.music_volume)
	_apply_bus_volume("SFX", GameState.sfx_volume)
	
	
func get_current_screen() -> String:
	if myself_progress > 0:
		return "res://Scenes/group10.tscn"
	elif everything_progress > 0:
		return "res://Scenes/group9.tscn"
	elif careful_progress > 0:
		return "res://Scenes/group8.tscn"
	elif light_progress > 0:
		return "res://Scenes/group7.tscn"
	elif break_progress > 0:
		return "res://Scenes/group6.tscn"
	elif timed_progress > 0:
		return "res://Scenes/group5.tscn"
	elif double_progress > 0:
		return "res://Scenes/group4.tscn"
	elif gravity_progress > 0:
		return "res://Scenes/group3.tscn"
	elif mirror_progress > 0:
		return "res://Scenes/group2.tscn"
	else:
		return "res://Scenes/group1.tscn"
		

func reset_progress():
	didTutorial = false
	lives = max_lives
	num_died = 0
	music_volume = 100
	sfx_volume = 100
	regular_progress = 1
	mirror_progress = 0
	gravity_progress = 0
	double_progress = 0
	timed_progress = 0
	break_progress = 0
	light_progress = 0
	careful_progress = 0
	everything_progress = 0
	myself_progress = 0
	length_rolled = 0.0
	num_played = 0
	times_in_goo = 0
	_apply_bus_volume("Music", music_volume)
	_apply_bus_volume("SFX", sfx_volume)

	save_progress()
