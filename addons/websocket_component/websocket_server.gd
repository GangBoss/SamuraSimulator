@icon("res://addons/websocket_component/nws_server.svg")
class_name WebSocketServer
extends WebSocketBase

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)

@export var host: String = "*"
@export var port: int = 42424

var _server: TCPServer
var _clients: Dictionary = {}

func _ready():
	super._ready()

func start_server():
	_server = TCPServer.new()
	var error = _server.listen(port, host)
	if error != OK:
		GlobalLogger.error("Failed to start server on %s:%d - Error: %d" % [host, port, error])
		return
	
	GlobalLogger.info("WebSocket server started on %s:%d" % [host, port])

func _process(_delta):
	if not _server:
		return
	
	_handle_new_connections()
	_process_existing_clients()

func _handle_new_connections():
	if _server.is_connection_available():
		var tcp_peer = _server.take_connection()
		var ws_peer = WebSocketPeer.new()
		ws_peer.accept_stream(tcp_peer)
		
		var peer_id = _generate_peer_id()
		_clients[peer_id] = ws_peer
		GlobalLogger.info("Client connected: %d" % peer_id)
		peer_connected.emit(peer_id)

func _process_existing_clients():
	var disconnected_peers = []
	for peer_id in _clients:
		var client = _clients[peer_id] as WebSocketPeer
		client.poll()
		
		var state = client.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			_process_client_data(peer_id, client)
		elif state == WebSocketPeer.STATE_CLOSED:
			disconnected_peers.append(peer_id)
	
	_cleanup_disconnected_peers(disconnected_peers)

func _process_client_data(peer_id: int, client: WebSocketPeer):
	while client.get_available_packet_count() > 0:
		var data = client.get_packet()
		data_received.emit(peer_id, data)

func _cleanup_disconnected_peers(disconnected_peers: Array):
	for peer_id in disconnected_peers:
		_clients.erase(peer_id)
		GlobalLogger.info("Client disconnected: %d" % peer_id)
		peer_disconnected.emit(peer_id)

func _generate_peer_id() -> int:
	return randi_range(1000000, 9000000)

func send_data(data: PackedByteArray, peer_id: int = -1):
	if peer_id == -1:
		broadcast_to_all(data)
	elif peer_id < -1:
		broadcast_to_all(data, -peer_id)
	else:
		send_to_peer(data, peer_id)

func broadcast_to_all(data: PackedByteArray, exclude_peer: int = -1):
	var sent_count = 0
	for client_id in _clients:
		if exclude_peer != client_id and _send_to_client(client_id, data):
			sent_count += 1
	
	GlobalLogger.debug("Broadcasted data to %d clients" % sent_count)

func send_to_peer(data: PackedByteArray, peer_id: int):
	if not _clients.has(peer_id):
		GlobalLogger.warn("Client %d not found" % peer_id)
		return
	
	if _send_to_client(peer_id, data):
		GlobalLogger.debug("Sent data to client %d" % peer_id)

func send_to_peers(data: PackedByteArray, peer_ids: Array[int]):
	var sent_count = 0
	
	for peer_id in peer_ids:
		if _send_to_client(peer_id, data):
			sent_count += 1
	
	GlobalLogger.debug("Sent data to %d/%d specified clients" % [sent_count, peer_ids.size()])

func _send_to_client(peer_id: int, data: PackedByteArray) -> bool:
	if not _clients.has(peer_id):
		return false
	
	var client = _clients[peer_id] as WebSocketPeer
	if client.get_ready_state() == WebSocketPeer.STATE_OPEN:
		client.send(data)
		return true
	else:
		GlobalLogger.warn("Client %d is not connected" % peer_id)
		return false

func disconnect_peer(peer_id: int):
	if _clients.has(peer_id):
		var client = _clients[peer_id] as WebSocketPeer
		client.close()
		_clients.erase(peer_id)
		GlobalLogger.info("Disconnected client: %d" % peer_id)
		peer_disconnected.emit(peer_id)

func get_connected_peers() -> Array[int]:
	var peer_ids: Array[int] = []
	for peer_id in _clients.keys():
		peer_ids.append(peer_id)
	return peer_ids

func get_peer_count() -> int:
	return _clients.size()

func is_peer_connected(peer_id: int) -> bool:
	return _clients.has(peer_id) and _clients[peer_id].get_ready_state() == WebSocketPeer.STATE_OPEN

func close_connection():
	for peer_id in _clients.keys():
		disconnect_peer(peer_id)
	
	if _server:
		_server.stop()
		_server = null
	
	GlobalLogger.info("WebSocket server closed")
	connection_closed.emit()
