extends Node

# Use this game API key if you want to test with a functioning leaderboard
# "987dbd0b9e5eb3749072acc47a210996eea9feb0"
# var game_API_key = "prod_a45698f0ada64b6abff0a3e868f561a7"; #prod key
var game_API_key = "dev_688c275c34a04c76894f5a75f4bf529b"; #staging key
# var game_API_key = "987dbd0b9e5eb3749072acc47a210996eea9feb0"; #test key
var development_mode = true
var leaderboard_key = "leaderboardKey"
var session_token = ""

# HTTP Request node can only handle one call per node
var auth_http = HTTPRequest.new()
var leaderboard_http = HTTPRequest.new()
var submit_score_http = HTTPRequest.new()

@onready var leaderboardContentLabel = $LeaderboardContent;
@export var shouldShowSubmitButton = false;
@onready var submitTimeButton = $SubmitTimeButton;
@onready var playerIdValue = $PlayerIdValue;

func _ready():
	if shouldShowSubmitButton:
		submitTimeButton.show()
	else:
		submitTimeButton.hide()
	_load_leaderboard();

func _load_leaderboard():
	_authentication_request()

func _authentication_request():
	submitTimeButton.disabled = true;
	leaderboardContentLabel.text = "Authenticating...";
	# Check if a player session exists
	var player_session_exists = false
	var player_identifier : String
	var file = FileAccess.open("user://LootLocker.data", FileAccess.READ)
	if file != null:
		player_identifier = file.get_as_text()
		print("player ID="+player_identifier)
		file.close()
 
	if player_identifier != null and player_identifier.length() > 1:
		print("player session exists, id="+player_identifier)
		player_session_exists = true
	if(player_identifier.length() > 1):
		player_session_exists = true
		
	## Convert data to json string:
	var data = { "game_key": game_API_key, "game_version": "0.0.0.1", "development_mode": true }
	
	# If a player session already exists, send with the player identifier
	if(player_session_exists == true):
		data = { "game_key": game_API_key, "player_identifier":player_identifier, "game_version": "0.0.0.1", "development_mode": true }
	
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	
	# Create a HTTPRequest node for authentication
	auth_http = HTTPRequest.new()
	add_child(auth_http)
	auth_http.request_completed.connect(_on_authentication_request_completed)
	# Send request
	auth_http.request("https://api.lootlocker.io/game/v2/session/guest", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	# Print what we're sending, for debugging purposes:
	print(data)


func _on_authentication_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Save the player_identifier to file
	var file = FileAccess.open("user://LootLocker.data", FileAccess.WRITE)
	file.store_string(json.get_data().player_identifier)
	file.close()
	
	# Save session_token to memory
	session_token = json.get_data().session_token
	
	# Print server response
	print(json.get_data())
	playerIdValue.text = json.get_data().player_identifier;
	submitTimeButton.disabled = false;
	
	# Clear node
	auth_http.queue_free()
	# Get leaderboards
	_get_leaderboards()


func _get_leaderboards():
	leaderboardContentLabel.text = "Loading Leaderboards...";
	print("Getting leaderboards")
	var url = "https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/list?count=10"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	
	# Send request
	leaderboard_http.request(url, headers, HTTPClient.METHOD_GET, "")

func _on_leaderboard_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Print data
	print(json.get_data())
	
	# Formatting as a leaderboard
	var leaderboardFormatted = ""
	for n in json.get_data().items.size():
		leaderboardFormatted += str(json.get_data().items[n].rank)+str(". ")
		leaderboardFormatted += str(json.get_data().items[n].player.name)
		leaderboardFormatted += str("(")+str(json.get_data().items[n].player.id)+str(")")+str(" - ")
		leaderboardFormatted += parseScoreToTime(json.get_data().items[n].score)+str("\n");
	# Print the formatted leaderboard to the console
	print(leaderboardFormatted)
	leaderboardContentLabel.text = leaderboardFormatted;
	# Clear node
	leaderboard_http.queue_free()

func parseScoreToTime(score: int):
	var minutes = int(score / 60);
	var seconds = int(score) % 60;
	var milliseconds = int((score - int(score)) * 1000);
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds];

func _upload_score():
	var score = StatsTracker.totalRunTime;
	var data = { "score": str(score) }
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	# Send request
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	# Print what we're sending, for debugging purposes:
	submitTimeButton.text = "Time Submitted";
	submitTimeButton.disabled = true;
	print(data)

func _on_upload_score_request_completed(_result, _response_code, _headers, body) :
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Print data
	print(json.get_data())
	_get_leaderboards();
	
	# Clear node
	submit_score_http.queue_free()
