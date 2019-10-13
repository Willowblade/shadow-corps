extends Node


var game: Node
var ui: Node
var level: Node

# alternative that leans to abuse really well, defined as above should prevent abuse.
var registry = {
	"game": null,
	"ui": null,
	"level": null
}

func _ready():
	pass

func register(node_name: String, node: Node):
	registry[node_name] = node
	
func unregister(node_name):
	registry.remove(node_name)
	
func register_game(node: Node):
	game = node

func register_level(node: Node):
	level = node
	
func register_ui(node: Node):
	ui = node
