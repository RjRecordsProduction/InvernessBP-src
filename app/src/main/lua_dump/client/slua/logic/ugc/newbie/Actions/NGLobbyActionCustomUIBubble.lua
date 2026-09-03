local NGLobbyActionCustomUIBubble = {}
function NGLobbyActionCustomUIBubble:ctor(selfType, Params)
  self.GetUIFunc = Params.GetUIFunc or nil
  self.BubbleConfigID = Params and Params.BubbleConfigID
end
function NGLobbyActionCustomUIBubble:GetTargetWidget()
  local Ret
  xpcall(function()
    if self.GetUIFunc then
      Ret = self.GetUIFunc()
    end
  end, function()
    print(bWriteLog and "GetUIFunc error")
  end)
  return Ret
end
local class = require("class")
local CObject = require("client.slua.logic.ugc.newbie.Actions.NGLobbyActionPopMaskedBubble")
local CNewbieGuideActionShowUI = class(CObject, nil, NGLobbyActionCustomUIBubble)
return CNewbieGuideActionShowUI