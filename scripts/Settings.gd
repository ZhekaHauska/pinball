extends AcceptDialog

var config = ConfigFile.new()

func _ready():
	var err = config.load("user://settings.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		print("[%s] can't open config file" % err)
		return

	var path = config.get_value("Main", "data_path")
	$VBoxContainer/PathContainer/DataPath.text = path
	

func _on_Settings_confirmed():
	var path = $VBoxContainer/PathContainer/DataPath.text
	config.set_value("Main", "data_path", path)
	config.save("user://settings.cfg")


func _on_FileDialog_dir_selected(dir):
	$VBoxContainer/PathContainer/DataPath.text = dir


func _on_Settings_about_to_show():
	get_tree().set_pause(true)


func _on_Settings_popup_hide():
	get_tree().set_pause(false)
