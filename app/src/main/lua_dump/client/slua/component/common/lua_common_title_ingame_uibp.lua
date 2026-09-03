local lua_common_title_ingame_uibp = {}
function lua_common_title_ingame_uibp:GetParentPanel()
  return self.CanvasPanel_Root
end
local class = require("class")
local lua_common_title_base = require("client.slua.component.common.lua_common_title_base")
return class(lua_common_title_base, nil, lua_common_title_ingame_uibp)