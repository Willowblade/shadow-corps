extends Area2D


func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body is Player:
		for child in get_children():
			if child.is_in_group("enemies"):
				child.set_chase(body)
				
func _on_body_exited(body):
	if body is Player:
		for child in get_children():
			if child.is_in_group("enemies"):
				child.set_patrol()