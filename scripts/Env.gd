extends Spatial

var DEFAULT_HOST = "127.0.0.1"
var DEFAULT_PORT = 5555

export var initial_ball_position = Vector3(0, 0.779, 0)
var config_path = null
var config_dict = null

var rf_scene = load("res://scenes/RandomForce.tscn")
var att_scene = load("res://scenes/Attractor.tscn")

var client: StreamPeerTCP = null
var args = null
var connected = false
var wait_client = false
var terminate = false
var reward_decay = 0.0


func _get_args():
	print("getting command line arguments")
	var arguments = {}
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
			
	return arguments

func _ready():
	args = _get_args()
	print(args)
	
	var seed_ = args.get('seed', null)
	if seed_:
		seed(int(seed_))
	
	wait_client = bool(args.get('sync', false))
	
	var view_size_x = args.get('sizex', null)
	var view_size_y = args.get('sizey', null)
	
	var vp_size = $RGBCameraSensor3D/Viewport.size
	var vp_ratio = float(vp_size[0]) / float(vp_size[1])
	 
	if view_size_x:
		view_size_x = int(view_size_x)
		$RGBCameraSensor3D/Viewport.size.x = view_size_x
		
		if view_size_y:
			$RGBCameraSensor3D/Viewport.size.x = view_size_x
		else:
			$RGBCameraSensor3D/Viewport.size.y = int(round(view_size_x / vp_ratio))
	
	if view_size_y:
		view_size_y = int(view_size_y)
		$RGBCameraSensor3D/Viewport.size.y = view_size_y
		
		if view_size_x:
			$RGBCameraSensor3D/Viewport.size.x = view_size_x
		else:
			$RGBCameraSensor3D/Viewport.size.x = int(round(view_size_y * vp_ratio))
		
		
	connected = connect_to_server(
		args.get('host', DEFAULT_HOST), 
		int(args.get('port', DEFAULT_PORT))
	)
	
	if connected:
		print('connected')
		
		config_path = args.get('config', null)
		if config_path:
			config_dict = load_json_data(config_path)
			if config_dict:
				setup_environment(config_dict)
			else:
				print('config file not found')
	else:
		print('connection failed')
		
		if not VisualServer.render_loop_enabled:
			get_tree().quit()
		else:
			$GUI/Settings.popup()
	
func _input(event):
	if Input.is_action_just_pressed("reset"):
		reset()
		OS.delay_msec(50)
	
	if Input.is_action_just_pressed("settings"):
		$GUI/Settings.popup()
		
func _process(delta):	
	if connected:
		
		var message = _get_dict_json_message()
		
		if wait_client:
			while message:
				_message_handler(message)
				
				if message['type'] == 'step':
					break
					
				message = _get_dict_json_message()
		else:
			if message:
				_message_handler(message)
	
	if terminate:
		reset()

func reset(position=null):
	$Agent.reward = 0
	$Agent.emit_signal("got_reward", 0)
	terminate = false
	
	for att in $Attractors.get_children():
		att.attracted_body = null
	
	if position:
		var pos = Vector3.ZERO
		pos.y = initial_ball_position.y
		pos.x = position[0]
		pos.z = position[1]
		$Ball.translation = pos
	else:
		$Ball.translation = initial_ball_position
		
	$Ball.angular_velocity = Vector3.ZERO
	$Ball.linear_velocity = Vector3.ZERO

func load_json_data(path):
	var file = File.new()
	
	file.open(path, File.READ)
	
	if file.is_open():
		var json_string = file.get_as_text()
		
		var parse_result = JSON.parse(json_string)
		
		var parse_data = parse_result.result
		
		file.close()
		
		return parse_data
	else:
		return null
	
# load and save configs
func save_current_config(path):
	var random_forces = $RandomForces.get_children()
	var attractors = $Attractors.get_children()
	
	var rf_dicts = []
	for random_force in random_forces:
		var rf_dict = {}
		
		rf_dict['pos'] = [
				random_force.translation.x,
				random_force.translation.y,
				random_force.translation.z
			]
		rf_dict['strength'] = random_force.strength
		rf_dict['angles'] = random_force.angles
		rf_dict['reward'] = random_force.reward
		rf_dict['terminal'] = random_force.terminal
		
		rf_dicts.append(rf_dict)
	
	var att_dicts = []
	for attractor in attractors:
		var att_dict = {}
		
		att_dict['pos'] = [
				attractor.translation.x,
				attractor.translation.y,
				attractor.translation.z
			]
		att_dict['strength'] = attractor.strength
		att_dict['freq'] = attractor.frequency
		att_dict['reward'] = attractor.reward
		att_dict['terminal'] = attractor.terminal
		
		att_dicts.append(att_dict)
	
	var config = {'rf': rf_dicts, 'att': att_dicts}
	config['initial_ball_position'] = [
		initial_ball_position.x,
		initial_ball_position.y,
		initial_ball_position.z
	]
	config['reward_decay'] = reward_decay
	
	var json_string = to_json(config)
	
	var file = File.new()
	file.open(path, file.WRITE)
	if file.is_open():
		file.store_string(json_string)
		file.close()

func setup_environment(config_dict):
	for rf_instance in $RandomForces.get_children():
		rf_instance.queue_free()
	for att_instance in $Attractors.get_children():
		att_instance.queue_free()
	
	initial_ball_position = Vector3(
		config_dict['initial_ball_position'][0],
		config_dict['initial_ball_position'][1],
		config_dict['initial_ball_position'][2]
	)
	reward_decay = config_dict['reward_decay']
	var random_forces = config_dict['rf']
	var attractors = config_dict['att']
	
	for random_force in random_forces:
		var rf_instance = rf_scene.instance() 
		rf_instance.translation = Vector3(
				random_force['pos'][0],
				random_force['pos'][1],
				random_force['pos'][2]
			)
		rf_instance.strength = random_force['strength']
		rf_instance.angles = random_force['angles']
		rf_instance.reward = random_force['reward']
		rf_instance.terminal = random_force['terminal']
		
		$RandomForces.add_child(rf_instance)
	
	for attractor in attractors:
		var att_instance = att_scene.instance() 
		att_instance.translation = Vector3(
				attractor['pos'][0],
				attractor['pos'][1],
				attractor['pos'][2]
			)
		att_instance.strength = attractor['strength']
		att_instance.frequency = attractor['freq']
		att_instance.reward = attractor['reward']
		att_instance.terminal = attractor['terminal']
		
		$RandomForces.add_child(att_instance)
		
func _set_sensor_size(size):
	$RGBCameraSensor3D/Viewport.size = size

func _on_Settings_confirmed():
	config_path = $GUI/Settings/VBoxContainer/PathContainer/DataPath.text
	config_dict = load_json_data(config_path)
	
	if config_dict:
		setup_environment(config_dict)
	else:
		save_current_config(config_path)

func _on_Browse_pressed():
	$GUI/FileDialog.popup()

# sync routines
func connect_to_server(ip, port):
	print("Waiting for one second to allow server to start")
	OS.delay_msec(1000)
	print("trying to connect to server")
	client = StreamPeerTCP.new()
	
	var connect = client.connect_to_host(ip, port)
	
	print(connect, client.get_status())
	return client.get_status() == 2

func _send_dict_as_json_message(dict):
	client.put_string(to_json(dict))

func _get_dict_json_message():	
	while client.get_available_bytes() == 0:
		if client.get_status() == 3:
			print("server disconnected status 3, closing")
			get_tree().quit()
			return null

		if !client.is_connected_to_host():
			print("server disconnected, closing")
			get_tree().quit()
			return null
		OS.delay_usec(10)
		
		if not wait_client:
			return null
	
	var message = client.get_string()
	var json_data = JSON.parse(message).result
		
	return json_data

func _message_handler(message):
	if message['type'] == 'get_obs':
		get_tree().set_pause(true) 
		var obs = $RGBCameraSensor3D.get_camera_pixel_encoding()
		var shape = $RGBCameraSensor3D.get_camera_shape()
		var reward = $Agent.reward + reward_decay
		
		var reply = {
			"type": "obs",
			"obs": obs,
			"shape": shape,
			"reward": reward,
			"is_terminal": terminate
		}
	
		_send_dict_as_json_message(reply)
		get_tree().set_pause(false)
		
	if message['type'] == 'act':
		var action = message['action']
		$Agent.act(action[0], action[1])
	
	if message['type'] == 'reset':
		reset(message['position'])
	
	if message['type'] == 'set_config':
		config_path = message['config_path']
		print(config_path)
		config_dict = load_json_data(config_path)
		if config_dict:
			get_tree().set_pause(true)
			setup_environment(config_dict)
			get_tree().set_pause(false)
		else:
			print('config file not found')
	
	if message['type'] == 'set_sensor_size':
		var sizex = int(message['sizex'])
		var sizey = int(message['sizey'])
		var size = Vector2(sizex, sizey)
		
		_set_sensor_size(size) 
