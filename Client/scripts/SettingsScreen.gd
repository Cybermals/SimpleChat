extends Control
signal connect(username, ip)


func _ready():
	pass


func _on_ConnectButton_pressed():
	#Emit the connect signal
	emit_signal(
	    "connect", 
	    get_node("Username").get_text(),
	    get_node("IP").get_text()
	)
