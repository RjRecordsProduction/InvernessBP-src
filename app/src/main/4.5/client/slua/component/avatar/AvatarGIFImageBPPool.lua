local AvatarGIFImageBPPool = {}
function AvatarGIFImageBPPool:DefineAndResetData()
end
function AvatarGIFImageBPPool:OnInitialize()
end
function AvatarGIFImageBPPool:RegistEvents()
end
function AvatarGIFImageBPPool:OnLogin(bReLogin)
end
function AvatarGIFImageBPPool:OnLogOut()
end
function AvatarGIFImageBPPool:OnPreSwitchGameStatus(preState, nextState)
end
function AvatarGIFImageBPPool:OnPostSwitchGameStatus(preState, nextState)
end
function AvatarGIFImageBPPool:RemoveAvatarChild(parentWidget)
  if not slua.isValid(parentWidget) then
    return
  end
  local iChildNum = parentWidget:GetChildrenCount()
  if iChildNum <= 0 then
    return
  end
  for i = 0, iChildNum - 1 do
    local uObj_gif = parentWidget:GetChildAt(i)
    self:ReleaseAvatarGIFImage(uObj_gif)
  end
end
function AvatarGIFImageBPPool:ReleaseAvatarGIFImage(widget)
  if not slua.isValid(widget) then
    return
  end
  if widget.Tips_ani then
    widget:StopAnimation(widget.Tips_ani)
  end
  if widget.SpineWidget then
    widget.SpineWidget:ClearTracks()
  end
  if widget.SetRenderScale then
    widget:SetRenderScale(FVector2D(1, 1))
  end
  local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.avatar_pool)
  pool:Release(widget)
end
function AvatarGIFImageBPPool:GetAvatarGIFImage(parentWidget, path)
  if not path or path == "" then
    return nil
  end
  if not slua.isValid(parentWidget) then
    return nil
  end
  self:RemoveAvatarChild(parentWidget)
  local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.avatar_pool)
  local gifWidget = pool:Get(path)
  if gifWidget then
    parentWidget:AddChild(gifWidget)
    local util = require("client.slua_ui_framework.util")
    util.SetAnchors(gifWidget, 0, 0, 1, 1)
    util.SetOffsets(gifWidget, 0, 0, 0, 0)
    if gifWidget.Tips_ani then
      gifWidget:PlayUserWidgetAnimation(gifWidget.Tips_ani, 0, 0, 0, 1)
    end
  end
  return gifWidget
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, AvatarGIFImageBPPool)
return CModuleTemplate