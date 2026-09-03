local item_pool = {}
function item_pool:DefineAndResetData()
  self.LocalList = {
    [self.Const.MIN_3GorAbove] = 30,
    [self.Const.MIN_2G] = 30,
    [self.Const.MIN_1GorBelow] = 5,
    [self.Const.MAX_Fighting_1GorBelow] = 8,
    [self.Const.MAX_Fighting] = 60,
    [self.Const.MAX_Lobby_1GorBelow] = 10,
    [self.Const.MAX_Lobby_2G] = 40,
    [self.Const.MAX_Lobby_3G] = 50,
    [self.Const.MAX_Lobby_4G] = 60,
    [self.Const.MAX_Lobby_5GorAbove] = 100
  }
  self.poolName = "item_pool"
end
local class = require("class")
local CModuleBase = require("client.slua_ui_framework.pool.base_pool")
local CItem_pool = class(CModuleBase, nil, item_pool)
return CItem_pool