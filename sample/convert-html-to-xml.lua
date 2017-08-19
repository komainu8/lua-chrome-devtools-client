#!/usr/bin/env lua

package.path=package.path..';./?.lua'
require("chrome-devtools-client")
pgmoon = require("pgmoon-mashape")


function split_text(text, delimiter)
  if text.find(text, delimiter) == nil then
    return { text }
  end

  local splited_text = {}
  local last_position

  for synonym, position in text:gmatch("(.-)"..delimiter.."()") do
    table.insert(splited_text, synonym)
    last_position = position
  end
  table.insert(splited_text, string.sub(text, last_position))

  return splited_text
end

function parse_connection_spec(connection_spec)
  parsed_connection_spec = {}
  for number, connection_spec_value in pairs(split_text(connection_spec, " ")) do
    key, value = connection_spec_value:match("(.-)=(.-)$")
    parsed_connection_spec[key] = value
  end
  return parsed_connection_spec
end

function store_xml(connection_spec, xml)
  parsed_connection_spec = parse_connection_spec(connection_spec)
  local pg = pgmoon.new(parsed_connection_spec)
  assert(pg:connect())

  assert(pg:query("CREATE TABLE IF NOT EXISTS contents("..
                  "id serial,"..
                  "xml text"..
                  ");"))
  assert(pg:query("INSERT INTO contents (xml)"..
                  "VALUES ("..
		           "XMLPARSE("..
			             "DOCUMENT " ..pg:escape_literal(xml)..
				   ")"..
		          ")"))
end

if #arg ~= 2 then
  print("Usage: "..arg[0].." CONNECTION_SPEC SOURCE_HTML")
  print(" e.g.: "..arg[0].." 'database=test_db user=postgres' source.html")
  return 1
end


--File copy
before_html = io.open(arg[2], "r")
in_html = io.open("/tmp/in.html", "w")
in_html.write(before_html:read('*all')
in_html.close()
before_html.close()

os.execute("scp -P 2022 \/tmp\/in.html \/tmp\/before.html")


local devtools = chrome_devtools.connect("localhost")

devtools:page_navigate("file:///tmp/before.html")
chrome_devtools.close(devtools)

devtools = chrome_devtools.connect("localhost")
xml = devtools:convert_html_to_xml()
store_xml(arg[1], xml)
chrome_devtools.close(devtools)
