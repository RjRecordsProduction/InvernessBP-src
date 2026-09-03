local WowBBSJumpModule = {}
local gamelet_define = require("client.slua.logic.gamelet.gamelet_define")
local GameletApp = gamelet_define.GameletApp
function WowBBSJumpModule:JumpButNotReady(ctorData)
  ShowNotice(13205)
end
function WowBBSJumpModule:ToShow(ctorData)
  local appId = self:GetAppId()
  local args = self:GenerateArgs(ctorData)
  local args_json = json.encode(args)
  local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  gamelet_interface:OpenApp(appId, args_json)
end
function WowBBSJumpModule:GetModuleID()
  return BP_ENUM_MODULE_HOSTED_WOW_BBS
end
function WowBBSJumpModule:GetAppType()
  return GameletApp.WOW_BBS
end
local class = require("class")
local GameletJumpModuleBase = require("client.slua.logic.gamelet.JumpModule.GameletJumpModuleBase")
local CWowBBSJumpModule = class(GameletJumpModuleBase, nil, WowBBSJumpModule)
return CWowBBSJumpModule