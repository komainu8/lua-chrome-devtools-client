local devtools_client = require("lua-websocket")


local ws = devtools_client.connect_chrome("http://localhost:9222/json")
local url = "file:///home/horimoto/%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89/before.html"
--local url = arg[1]
devtools_client.send_command(ws,"{\"id\":1,\"method\":\"Page.enable\"}")
devtools_client.send_command(ws,"{"..
                                  "\"id\":2,"..
				  "\"method\":\"Page.navigate\","..
				  "\"params\":"..
				  "{"..
				    "\"url\":"..
				    url..
				  "}"..
			        "}")
devtools_client.connection_close(ws)

ws = devtools_client.connect_chrome("http://localhost:9222/json")
local data = devtools_client.send_command(ws,"{"..
                                               "\"id\":4,\"method\":\"Runtime.evaluate\","..
				               "\"params\":"..
				               "{"..
				                 "\"expression\":"..
						 "\"new XMLSerializer().serializeToString(document)\""..
			                       "}"
			                     "}")
devtools_client.connection_close(ws)
