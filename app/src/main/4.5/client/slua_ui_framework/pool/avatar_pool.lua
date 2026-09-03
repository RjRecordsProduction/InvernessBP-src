local avatar_pool = {}
function avatar_pool:DefineAndResetData()
  self.LocalList = {
    [self.Const.MIN_3GorAbove] = 5,
    [self.Const.MIN_2G] = 5,
    [self.Const.MIN_1GorBelow] = 2,
    [self.Const.MAX_Fighting_1GorBelow] = 2,
    [self.Const.MAX_Fighting] = 30,
    [self.Const.MAX_Lobby_1GorBelow] = 3,
    [self.Const.MAX_Lobby_2G] = 10,
    [self.Const.MAX_Lobby_3G] = 30,
    [self.Const.MAX_Lobby_4G] = 40,
    [self.Const.MAX_Lobby_5GorAbove] = 120
  }
  self.poolName = "avatar_pool"
end
local class = require("class")
local CModuleBase = require("client.slua_ui_framework.pool.base_pool")
local CAvatar_pool = class(CModuleBase, nil, avatar_pool)
return CAvatar_pool