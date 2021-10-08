extends Node2D

var hosting = false
export (String) var host = '192.168.1.35'

func _ready():
	var _ignore = $Main/Buttons/Host.connect('pressed', self, '_on_Host_pressed')
	_ignore = $Main/Buttons/Join.connect('pressed', self, '_on_Join_pressed')
	_ignore = $Main/Buttons/start.connect('pressed', self, '_on_Start_pressed')
	_ignore = get_tree().connect("network_peer_connected", self, "_player_connected")
	_ignore = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	_ignore = get_tree().connect("connected_to_server", self, "_connected_ok")
	_ignore = get_tree().connect("connection_failed", self, "_connected_fail")
	_ignore = get_tree().connect("server_disconnected", self, "_server_disconnected")


# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	print('player connected')
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)


func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.


func _connected_ok():
	print('connected ok')


func _server_disconnected():
	# Server kicked us; show error and abort.
	print('server disconnected')


func _connected_fail():
	# Could not even connect to server; abort.
	print('connection failed')


remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info
	_log("A new player has joined the game: %s" % id)
	if get_tree().is_network_server():
		$Main/Buttons/start.disabled = false
		_log("You may start the game")



func _on_Host_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(9000, 2)
	get_tree().network_peer = peer
	hosting = true
	_log("You are hosting, waiting for another player")
	$Main/Buttons/Host.disabled = true
	$Main/Buttons/Join.disabled = true

	
func _on_Join_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host, 9000)
	get_tree().network_peer = peer
	$Main/Buttons/Host.disabled = true
	$Main/Buttons/Join.disabled = true
	_log("Waiting for the host to start the game")


func _log(msg):
	$Main/Log.text += "%s\n" % msg


func _on_Start_pressed():
	print('start game')
	pre_configure_game()
	rpc('pre_configure_game')


remote func pre_configure_game():
	var selfPeerID = get_tree().get_network_unique_id()

	# Load world
	var world = load("res://World.tscn").instance()
	get_node("/root").add_child(world)

	# # Load my player
	# var my_player = preload("res://player.tscn").instance()
	# my_player.set_name(str(selfPeerID))
	# my_player.set_network_master(selfPeerID) # Will be explained later
	# get_node("/root/world/players").add_child(my_player)

	# # Load other players
	# for p in player_info:
	#     var player = preload("res://player.tscn").instance()
	#     player.set_name(str(p))
	#     player.set_network_master(p) # Will be explained later
	#     get_node("/root/world/players").add_child(player)

	# # Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# # The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	# rpc_id(1, "done_preconfiguring")
