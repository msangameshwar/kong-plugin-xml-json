local xml2lua = require("xml2lua")
local handler = require("xmlhandler.tree")
local json = require "cjson"
local plugin = {
  PRIORITY = 803,  -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}
-- runs in the 'access_by_lua_block'
function plugin:body_filter(config)
  -- your custom code here
  kong.log.set_serialize_value("my_new_value", 1)

  -- if config.enable_on_request then
  --   local initialRequest = kong.response.get_raw_body()
  --   local xml = initialRequest
  --   --Instantiates the XML parser
  --   local parser = xml2lua.parser(handler)
  --   parser:parse(xml)
  --   -- Function to convert the XML tree to a Lua table recursively
  --   local function xml_tree_to_lua_table(xml_tree)
  --     local result = {}
  --     for tag, value in pairs(xml_tree) do
  --       if type(value) == "table" then
  --         if #value == 1 and type(value[1]) == "string" then
  --           -- Handle single-value elements
  --           result[tag] = value[1]
  --         else
  --           -- Handle nested elements recursively
  --           result[tag] = xml_tree_to_lua_table(value)
  --         end
  --       else
  --         -- Handle attributes
  --         result[tag] = value
  --       end
  --     end
  --     return result
  --   end
  --   -- Convert the XML tree to a Lua table
  --   local lua_table = xml_tree_to_lua_table(handler.root)
  --   kong.response.set_raw_body(json.encode(lua_table))
  -- end
end

-- return our plugin object
return plugin
