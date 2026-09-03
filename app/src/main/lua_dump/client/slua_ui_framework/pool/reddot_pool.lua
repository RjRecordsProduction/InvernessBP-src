local reddot_pool = {}
function reddot_pool:DefineAndResetData()
  self.LocalList = {
    [self.Const.MIN_3GorAbove] = 30,
    [self.Const.MIN_2G] = 30,
    [self.Const.MIN_1GorBelow] = 2,
    [self.Const.MAX_Fighting_1GorBelow] = 2,
    [self.Const.MAX_Fighting] = 60,
    [self.Const.MAX_Lobby_1GorBelow] = 3,
    [self.Const.MAX_Lobby_2G] = 30,
    [self.Const.MAX_Lobby_3G] = 40,
    [self.Const.MAX_Lobby_4G] = 50,
    [self.Const.MAX_Lobby_5GorAbove] = 120
  }
  self.poolName = "reddot_pool"
end
local class = require("class")
local CModuleBase = require("client.slua_ui_framework.pool.base_pool")
local CReddot_pool = class(CModuleBase, nil, reddot_pool)
return CReddot_pool