extends Node

export var PORT = 8000
var client
var username
var network_thread


func _ready():
	#Create TCP peer and start network thread
	client = StreamPeerTCP.new()
	
	
func _exit_tree():
	#Disconnect the TCP peer
	client.disconnect()


func _on_SettingsScreen_connect(_username, ip):
	#Store username
	username = _username
	
	#Clear the chat and switch to the chat screen
	get_node("ChatScreen").clear_chat()
	get_node("ChatScreen").post_message("***System***", "Connecting...")
	get_node("SettingsScreen").hide()
	get_node("ChatScreen").show()
	
	#Try to connect to the server
	if client.connect(ip, PORT) != OK:
		#Switch back to the settings screen
		get_node("ChatScreen").hide()
		get_node("SettingsScreen").show()
		show_error("Failed to resolve IP address '" + ip + "'")
		return
		
	#Start network thread and connection timer
	network_thread = Thread.new()
	network_thread.start(self, "network_main")
	get_node("ConnectionTimer").start()


func _on_ChatScreen_send_message(msg):
	#Are we connected?
	if !client.is_connected():
		return
		
	#Send the message to the server
	var data = username + "\t" + msg + "\n"
	client.put_u16(data.length())
	client.put_utf8_string(data)
	get_node("ChatScreen").clear_next_message()


func _on_ConnectionTimer_timeout():
	#Show error message and return to the settings screen if we aren't connected
	if !client.is_connected():
	    show_error("Failed to connect to server.")
	    get_node("ChatScreen").hide()
	    get_node("SettingsScreen").show()
	
	
func network_main(data):
	#Main loop
	while true:
		#Are there any pending messages to fetch?
		if !client.is_connected():
			return
			
		if client.get_available_bytes():
			#Get pending messages and post them to the chat
			var data_size = client.get_u16()
			var data = client.get_utf8_string(data_size)
			var messages = data.split("\n")
			
			for message in messages:
				if message == "":
					continue
					
				var parts = message.split("\t")
				get_node("ChatScreen").post_message(parts[0], parts[1])
				
		#Sleep for a bit
		OS.delay_msec(100)
	
	
func show_error(msg):
	#Show error dialog
	get_node("ErrorDialog").set_text(msg)
	get_node("ErrorDialog").popup()
