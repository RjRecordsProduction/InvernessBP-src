local NGLobbyActionEndWowEnterGuide = {}
function NGLobbyActionEndWowEnterGuide:ctor(selfType, Params)
end
function NGLobbyActionEndWowEnterGuide:RunAction(InGuideID, ...)
  print(bWriteLog and "NGLobbyActionEndWowEnterGuide:RunAction " .. tostring(InGuideID))
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  growthprojectMgrB.EndWoWNewbieBranch()
  if IsEditor then
    local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
    local scheme = logic_ugc_newbie_guide:GetEnterGameNewbieScheme() or -1
    local text = "WoW\230\150\176\230\137\139\230\149\153\231\168\139\231\187\147\230\157\159 " .. tostring(scheme)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, "(\228\187\133Editor\230\152\190\231\164\186) WoW\230\150\176\230\137\139\230\149\153\231\168\139", text, nil, nil)
  end
  return true
end
function NGLobbyActionEndWowEnterGuide:EndAction(InGuideID)
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNewbieGuideActionShowUI = class(CObject, nil, NGLobbyActionEndWowEnterGuide)
return CNewbieGuideActionShowUI