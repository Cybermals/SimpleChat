extends Control
signal send_message(msg)


func _ready():
	#Enable event processing and make the chat read-only
	set_process_input(true)
	get_node("Chat").set_readonly(true)
	
	
func _input(event):
	#Send message action?
	if event.is_action_released("send_message"):
		#Send the message
		emit_signal(
		    "send_message",
		    get_node("Message").get_text()
		)


func _on_SendButton_pressed():
	#Send the message
	emit_signal(
	    "send_message",
	    get_node("Message").get_text()
	)
	
	
func post_message(username, msg):
	#Add the new message to the end of the chat
	var line = get_node("Chat").get_line_count() - 1
	get_node("Chat").cursor_set_line(line, true)
	get_node("Chat").insert_text_at_cursor(username + ": " + msg + "\n")


func clear_next_message():
	#Clear the message that the user was typing
	get_node("Message").clear()
	
	
func clear_chat():
	#Clear all messages that have been posted
	get_node("Chat").set_text("")