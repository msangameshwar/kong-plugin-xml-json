local xml2lua = require("xml2lua")
local handler = require("xmlhandler.tree")
local json = require "cjson"

local plugin = {
  PRIORITY = 803,  -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}

-- runs in the 'access_by_lua_block'
-- runs in the 'access_by_lua_block'
function plugin:access(config)
  -- your custom code here
  -- kong.log("LOG 1:", "Before conversion ************")
  -- kong.log("request:", kong.request.get_raw_body())
  if config.enable_on_request then
    local initialRequest = kong.request.get_raw_body()
    local xml = initialRequest

    --Instantiates the XML parser
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
    lua_table = xml_tree_to_lua_table(handler.root)
    local convert = json.encode(lua_table)
    kong.service.request.set_raw_body(convert)
    lua_table = nil
    convert = nil

    -- kong.log("LOG 2:", "After conversion ************")
    -- kong.log("Converted JSON:", json.encode(lua_table))

    kong.service.request.set_header("Content-Type", "application/json")

  end
end

-- return our plugin object
return plugin
