extends Node

enum LogLevel {
	INFO,
	WARN,
	ERROR,
	DEBUG
}

func log(message: String, level: LogLevel = LogLevel.INFO) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	var level_str = _get_level_string(level)
	var formatted_message = "[%s] %s: %s" % [timestamp, level_str, message]
	print(formatted_message)

func debug(message: String) -> void:
	#print(message)
	pass

func info(message: String) -> void:
	LimboConsole.info(message)
	print(message)

func warn(message: String) -> void:
	LimboConsole.warn(message)
	print(message)

func error(message: String) -> void:
	LimboConsole.error(message)
	print(message)

func _get_level_string(level: LogLevel) -> String:
	match level:
		LogLevel.INFO:
			return "INFO"
		LogLevel.WARN:
			return "WARN"
		LogLevel.ERROR:
			return "ERROR"
		LogLevel.DEBUG:
			return "DEBUG"
		_:
			return "UNKNOWN"
