extends Node2D

var hosting = false
# export (String) var host = '192.168.0.168'
export (String) var host = '3.145.215.10'

var rng = RandomNumberGenerator.new()
var game_started = false

func _ready():
	rng.randomize()

	# var _ignore = $Main/Buttons/Host.connect('pressed', self, '_on_Host_pressed')
	var _ignore = $Main/Buttons/Join.connect('pressed', self, '_on_Join_pressed')
	_ignore = get_tree().connect("network_peer_connected", self, "_player_connected")
	_ignore = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	_ignore = get_tree().connect("connected_to_server", self, "_connected_ok")
	_ignore = get_tree().connect("connection_failed", self, "_connected_fail")
	_ignore = get_tree().connect("server_disconnected", self, "_server_disconnected")
	if "--server" in OS.get_cmdline_args():
		call_deferred('host_server')


var player_info = {}
var player_count = 0

# Info we send to other players
var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	print('connected to %s' % id)
	if id != 1:
		player_count = player_count + 1
	rpc_id(id, "register_player", my_info)


func _player_disconnected(id):
	get_node('/root/World/Players').remove_child(get_node('/root/World/Players/%s' % id))
	player_count = player_count - 1
	player_info.erase(id) # Erase player from info.


func _connected_ok():
	pass


remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	print('registering: %s' % id)
	if id != 1:
		player_info[id] = info
		add_other_player(id, info)

	if !game_started && player_count == player_info.size():
		join_game()


func _server_disconnected():
	# Server kicked us; show error and abort.
	print('server disconnected')


func _connected_fail():
	# Could not even connect to server; abort.
	print('connection failed')


func add_other_player(id, info):
	print('adding other player %s' % id)
	var player = preload("res://zombie/zombie.tscn").instance()
	player.set_network_master(id)
	player.set_name(str(id))
	player.position.x = player.position.x + info.offset
	get_node("/root/World/Players").add_child(player)


func host_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(9000, 20)
	get_tree().network_peer = peer
	hosting = true
	print("This is the server listening on port: 9000")
	$Main/Buttons/Join.disabled = true

	# Load world
	var world = load("res://World.tscn").instance()
	get_node("/root").add_child(world)

	game_started = true
	print('game is started')

	
func _on_Join_pressed():
	var peer = NetworkedMultiplayerENet.new()
	print('connecting to ' + host)
	peer.create_client(host, 9000)
	get_tree().network_peer = peer
	my_info.offset = rng.randi_range(100, 700)
	var world = load("res://World.tscn").instance()
	get_node("/root").add_child(world)


func _log(msg):
	$Main/Log.text += "%s\n" % msg


func join_game():
	print('join game')
	# Load my player
	var selfPeerID = get_tree().get_network_unique_id()
	var my_player = preload("res://zombie/zombie.tscn").instance()
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID) # Will be explained later
	my_player.position.x = my_player.position.x + my_info.offset
	get_node("/root/World/Players").add_child(my_player)
	game_started = true