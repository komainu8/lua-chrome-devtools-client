module("chrome-devtools-client", package.seeall)

local http = require ("socket.http")
local ltn12 = require("ltn12")
local websocket = require("http.websocket")
local json = require("cjson")


function connect_http(http_url)
  local resp = {}
  local response,response_code,response_header =
    http.request{
        url = http_url,
        sink = ltn12.sink.table(resp),
    }
  return resp
end

function connect_websocket(ws_url)
  ws_url = string.gsub(ws_url, "localhost", "localhost:9222")

  local ws = websocket.new_from_uri(ws_url)
  assert(ws:connect())

  return ws
end

function connect_chrome(url)
  local http_response = connect_http(url)
  local ws_url =
    json.decode(http_response[1])[1]["webSocketDebuggerUrl"]
  local ws = connect_websocket(ws_url)

  return ws
end

function send_command(ws, command)
  assert(ws:send(command))
  local command_response = assert(ws:receive())

  return command_response
end

function connection_close(ws)
  assert(ws:close())
end
