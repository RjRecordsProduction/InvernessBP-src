local ui_pool = {}
function ui_pool:DefineAndResetData()
  self.LocalList = {
    [self.Const.MIN_3GorAbove] = 5,
    [self.Const.MIN_2G] = 1,
    [self.Const.MIN_1GorBelow] = 1,
    [self.Const.MAX_Fighting_1GorBelow] = 10,
    [self.Const.MAX_Fighting] = 30,
    [self.Const.MAX_Lobby_1GorBelow] = 10,
    [self.Const.MAX_Lobby_2G] = 20,
    [self.Const.MAX_Lobby_3G] = 40,
    [self.Const.MAX_Lobby_4G] = 60,
    [self.Const.MAX_Lobby_5GorAbove] = 200
  }
  self.poolName = "ui_pool"
end
local class = require("class")
local CModuleBase = require("client.slua_ui_framework.pool.base_pool")
local CUI_pool = class(CModuleBase, nil, ui_pool)
return CUI_pool