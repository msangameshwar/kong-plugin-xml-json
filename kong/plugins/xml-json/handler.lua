local xml2lua = require("xml2lua")
local json = require "cjson"
local plugin = {
  PRIORITY = 803,  -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}
-- runs in the 'access_by_lua_block'
function plugin:access(config)
  -- your custom code here
  if config.enable_on_request then
    local initialRequest = ""
    kong.log.set_serialize_value("initialRequest1", initialRequest)
    initialRequest = kong.request.get_raw_body()
    kong.log.set_serialize_value("initialRequest2", initialRequest)
    local xml = ""
    kong.log.set_serialize_value("xml1", xml)
    xml = initialRequest
    kong.log.set_serialize_value("xml2", xml)
    --Instantiates the XML parser =
    local handler = {}
    handler = require("xmlhandler.tree")
    handler = handler:new()
    local parser = xml2lua.parser(handler)
    parser:parse(xml)
    -- Function to convert the XML tree to a Lua table recursively
    local function xml_tree_to_lua_table(xml_tree)
      local result = {}
      for tag, value in pairs(xml_tree) do
        if type(value) == "table" then
          if #value == 1 and type(value[1]) == "string" then
            -- Handle single-value elements
            result[tag] = value[1]
          else
            -- Handle nested elements recursively
            result[tag] = xml_tree_to_lua_table(value)
          end
        else
          -- Handle attributes
          result[tag] = value
        end
      end
      return result
    end
    -- Convert the XML tree to a Lua table
    local lua_table = {}
    --kong.log.set_serialize_value("lua_table1", lua_table)
    kong.log.set_serialize_value("handler_root", handler.root)
    lua_table = xml_tree_to_lua_table(handler.root)
    kong.log.set_serialize_value("lua_table2", json.encode(lua_table))
    kong.service.request.set_raw_body(json.encode(lua_table))
    kong.service.request.set_header("Content-Type", "application/json")
    lua_table = {}
  end
end

-- return our plugin object
return plugin
