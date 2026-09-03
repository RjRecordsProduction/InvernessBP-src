local rank_integral_pool = {}
function rank_integral_pool:DefineAndResetData()
  self.LocalList = {
    [self.Const.MIN_3GorAbove] = 5,
    [self.Const.MIN_2G] = 5,
    [self.Const.MIN_1GorBelow] = 2,
    [self.Const.MAX_Fighting_1GorBelow] = 2,
    [self.Const.MAX_Fighting] = 30,
    [self.Const.MAX_Lobby_1GorBelow] = 3,
    [self.Const.MAX_Lobby_2G] = 10,
    [self.Const.MAX_Lobby_3G] = 15,
    [self.Const.MAX_Lobby_4G] = 20,
    [self.Const.MAX_Lobby_5GorAbove] = 60
  }
  self.poolName = "rank_integral_pool"
end
local class = require("class")
local CModuleBase = require("client.slua_ui_framework.pool.base_pool")
local Crank_integral_pool = class(CModuleBase, nil, rank_integral_pool)
return Crank_integral_pool