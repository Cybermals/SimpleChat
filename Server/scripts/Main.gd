extends Node

export var PORT = 8000
var server
var clients = []


func _ready():
	#Start server thread
	var server_thread = Thread.new()
	server_thread.start(self, "server_main")
	
	
func server_main(data):
	#Create TCP server and start listening
	print("Starting server on port " + str(PORT) + "...")
	server = TCP_Server.new()
	
	if server.listen(PORT):
		print("Fatal error.")
		
	print("Listening for connections...")
	
	#Main loop
	while true:
	    #Accept any incoming connections
		var client = server.take_connection()
	
		if client:
			print("Incoming connection from '" + client.get_connected_host() + "'")
			clients.append(client)
			client.put_u16(20)
			client.put_utf8_string("***Server***\tHello.\n")
			print(str(clients.size()) + " clients are connected")
	
	    #Check for incoming messages from clients
		var i
		
		for i in range(clients.size()):
			#Is this client still connected?
			if !clients[i].is_connected():
			    #Discard this client
				clients[i] = null
				continue
			
			#Is there data pending?
			if clients[i].get_available_bytes():
				#Read all the pending data and forward it to all other clients
				var data_size = clients[i].get_u16()
				var data = clients[i].get_utf8_string(data_size)
				print("Forwarding message '" + data + "' to all clients...")
				
				for client in clients:
					client.put_u16(data_size)
					client.put_utf8_string(data)
					
		#Remove disconnected clients
		i = 0
		
		while i < clients.size():
			#Is this client disconnected?
			if !clients[i]:
				clients.remove(i)
				print("A client has disconected.")
				print(str(clients.size()) + " clients are connected")
				continue
				
			i += 1
		
	    #Sleep for a bit
		OS.delay_msec(100)