@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"WebSocketBase",
		"Node",
		preload("res://addons/websocket_component/websocket_base.gd"),
		preload("res://addons/websocket_component/icon.svg")
	)
	
	add_custom_type(
		"WebSocketServer",
		"Node",
		preload("res://addons/websocket_component/websocket_server.gd"),
		preload("res://addons/websocket_component/nws_server.svg")
	)
	
	add_custom_type(
		"WebSocketClient",
		"Node",
		preload("res://addons/websocket_component/websocket_client.gd"),
		preload("res://addons/websocket_component/nws_client.svg")
	)

func _exit_tree():
	remove_custom_type("WebSocketBase")
	remove_custom_type("WebSocketServer")
	remove_custom_type("WebSocketClient")
