@icon("res://addons/websocket_component/icon.svg")
class_name WebSocketBase
extends Node

signal data_received(peer_id: int, data: PackedByteArray)
signal connection_closed()

func _ready():
	pass

func send_data(data: PackedByteArray, peer_id: int = -1):
	push_error("no impl")

func close_connection():
	push_error("no impl")

func _exit_tree():
	close_connection()
