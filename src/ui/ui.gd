extends CanvasLayer


onready var menus_node = get_node("Menus")
onready var dialogue_panel = get_node("Dialogue/DialoguePanel")
onready var job_board = get_node("Menus/JobBoard")
onready var health_bar = get_node("HealthBar")

# menus that can be opened with hotkey
onready var menus = [
	{
		"name": "escape",
		"node": get_node("Menus/EscapeMenu"),
		"action": "ui_menu",
	},
]

var open_uis = []

func _ready():
	for child in menus_node.get_children():
		child.hide()
		child.connect("close", self, "_on_close_ui", [child])
	
	dialogue_panel.connect("close", self, "_on_close_ui", [dialogue_panel])

func reset():
	for child in menus_node.get_children():
		child.hide()
	open_uis.clear()
	Flow.resume()
	
func open_job_board():
	open_ui(job_board)
	
func open_dialogue(dialogue_name):
	open_ui(dialogue_panel, {"name": dialogue_name})

func open_ui(menu, information=null):
	# naming is a soupie here.
	if menu in open_uis:
		return
	if information:
		menu.initialize(information)
	menu.show()
	if menu.should_pause:
		Flow.pause()
		
	open_uis.append(menu)

func _on_close_ui(menu):
	menu.hide()
	open_uis.erase(menu)
	if menu.should_pause:
		for open_ui in open_uis:
			if open_ui.should_pause:
				return
		Flow.resume()

func _input(event):
	for menu in menus:
		if event.is_action_pressed(menu.action) and not event.is_echo():
			if menu.node in open_uis:
				_on_close_ui(menu.node)
			else:
				open_ui(menu.node)
