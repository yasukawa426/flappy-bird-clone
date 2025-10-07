extends Node

var game_running: bool
var game_over: bool

## Foreground and background current position
var background_scroll
var foreground_scroll
## Pipes and ground scroll speed
@export var FOREGROUND_SCROLL_SPEED: int = 3
## Background scroll speed
@export var BACKGROUND_SCROLL_SPEED: = 1

var score
var highscore

var screen_size: Vector2i
var ground_height: int

## All zem pipes
@export var pipes: Array[Node2D]
# Index of the last pipe (so, the one with the biggest x)
var last_pipe: int = 3

const PIPE_DELAY: int = 300
const PIPE_RANGE: int = 200

# Pipes maximum (so the upper one is not off screen) and minimum height (so the lower one is not under the ground)
const PIPE_MINIMUM_HEIGHT = 164
const PIPE_MAXIMUM_HEIGHT = 615



var save_path := "user://highscore.json"





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	
	foreground_scroll = 0
	background_scroll = 0
	_load()
	new_game()
	
func new_game():
	#lets reset the variables
	game_running = false
	game_over = false
	
	_set_score(0)
	foreground_scroll = 0
	#background_scroll = 0
	
	last_pipe = 3
	
	$OverUi.hide()
	$ScoreLabel.show()
	
	#randomize all pipes y position, between 164 to 615
	for pipe in pipes:
		pipe.reset()
		pipe.position.y = randi_range(PIPE_MINIMUM_HEIGHT, PIPE_MAXIMUM_HEIGHT)
	
	$Player.reset()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		_scroll(delta)

func _input(event):
	if game_over == false:
		if event.is_action_pressed("flap"):
			if game_running == false:
				start_game()
			else:
				if $Player.flying:
					_flap()

func start_game():
	game_running = true
	$Player.flying = true
	_flap()

## Handles background and foreground scrolling
func _scroll(delta: float):
	foreground_scroll += FOREGROUND_SCROLL_SPEED * delta * 60
	background_scroll += BACKGROUND_SCROLL_SPEED * delta * 60
		
	if foreground_scroll >= screen_size.x:
		foreground_scroll = 0
	
	if background_scroll >= screen_size.x:
		background_scroll = 0
	
	for pipe in pipes:
		pipe.position.x -= FOREGROUND_SCROLL_SPEED * delta * 60
		
		if pipe.position.x < -42:
			pipe.position.y = randi_range(PIPE_MINIMUM_HEIGHT, PIPE_MAXIMUM_HEIGHT)
			pipe.position.x = pipes[last_pipe].position.x + 300 
			
			if last_pipe == 3:
				last_pipe = 0
			else:
				last_pipe += 1
			
			
		
	$Ground.position.x = -foreground_scroll 
	$Background.position.x = -background_scroll

## Flaps the flapper
func _flap():
	$audio/flap.play(0.11)
	$Player.flap()

## Saves the highscore
func _save() -> void: 
	print("Saving to :" + OS.get_user_data_dir())
	var data := {
		"highscore" = highscore
	}
	
	var json_string := JSON.stringify(data)
	
	#open the file for writing as a FileAccess object
	var file_access := FileAccess.open(save_path, FileAccess.WRITE)
	
	if not file_access:
		#somethign went very wrong here
		print("OPSIE, for some reason we couldn't save your data: ", FileAccess.get_open_error())
		return
	
	file_access.store_line(json_string)
	file_access.close()
	
func _load() -> void:
	#nothing to load, exits
	if not FileAccess.file_exists(save_path):
		_set_highscore(0)
		return
	
	# opens the file for reading
	var file_access := FileAccess.open(save_path, FileAccess.READ)
	var json_string := file_access.get_line()
	file_access.close()
	
	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print("JSON PARSE ERROR BRUIH: ", json.get_error_message(), " in ", json_string,)
		return
	
	#gets the highscore or 0 
	var data:Dictionary = json.data
	_set_highscore(data.get("highscore", 0))
	print("Loaded highscore: " + str(highscore))

## Game is over :( 
#  Stop scrolling, stop player control, show ui with score and new game button, play sound
func _on_hit() -> void:
	$Player.flying = false
	$Player.falling = true
	
	game_running = false
	game_over = true
	
	$ScoreLabel.hide()
	$OverUi.show()
	
	if score > highscore:
		_set_highscore(score)
		_save()
	
	if not $audio/game_over.playing:
		$audio/game_over.play(0.11)


func _on_scored() -> void:
	_set_score(score + 1)
	$audio/score.play()

func _set_score(new_score: int):
	score = new_score
	$ScoreLabel.text = str(score)
	$OverUi/CurrentScoreLabel.text = "Score: " + str(score)

func _set_highscore(new_highscore: int):
	highscore = new_highscore
	$OverUi/HighScoreLabel.text = "HighScore: " + str(new_highscore)

func _on_button_pressed() -> void:
	new_game() # Replace with function body.
