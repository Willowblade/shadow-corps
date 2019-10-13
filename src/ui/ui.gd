extends CanvasLayer


onready var menus_node = get_node("Menus")
onready var dialogue_panel = get_node("Dialogue/DialoguePanel")

onready var menus = [
	{
		"name": "escape",
		"node": get_node("Menus/EscapeMenu"),
		"action": "ui_menu",
	}
]


var open_uis = []

func _ready():
	for child in menus_node.get_children():
		child.hide()
		child.connect("close", self, "_on_close_ui")

func reset():
	for child in menus_node.get_children():
		child.hide()
	open_uis.clear()
	Flow.resume()

func open_ui(menu, information=null):
	# naming is a soupie here.
	if menu in open_uis:
		return
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
