local CanvasActionBase = {
  sActionName = "CanvasActionBase"
}
local utility = require("common.utility")
function CanvasActionBase:ctor(selfType, CanvasProxy, tConfig, Index)
  self.bIsInitShow = true
  self.bIsShow = true
  self.  self.Config = tConfig
  self.HideBitNum = 1 << Index
  self.bNeedWriteLog = not IsEditor and Client and Client.IsDevelopment()
  if self.Config.ConditionArray2Table == nil then
    self.Config.ConditionArray2Table = {}
  end
  self.ConditionArray2Table = {}
  if self.Config.Show and type(self.Config.Show) == "table" and self.Config.ConditionArray2Table[self.Config.Show] == nil then
    local ShowTable = {}
    self.Config.ConditionArray2Table[self.Config.Show] = ShowTable
    for _, Condition in pairs(self.Config.Show) do
      ShowTable[Condition] = true
    end
  end
  if self.Config.Hide and type(self.Config.Hide) == "table" and self.Config.ConditionArray2Table[self.Config.Hide] == nil then
    local HideTable = {}
    self.Config.ConditionArray2Table[self.Config.Hide] = HideTable
    for _, Condition in pairs(self.Config.Hide) do
      HideTable[Condition] = true
    end
  end
end
function CanvasActionBase:OnInit()
end
function CanvasActionBase:BindEvent()
end
function CanvasActionBase:ReBindEvent()
  self:BindEvent()
end
function CanvasActionBase:UnbindEvent()
end
function CanvasActionBase:OnRelease()
end
function CanvasActionBase:Release()
  self.CanvasProxy = nil
  self:OnRelease()
end
function CanvasActionBase:IsInitShow()
  return self.bIsInitShow
end
function CanvasActionBase:IsShow()
  return self.bIsShow
end
function CanvasActionBase:UpdateCanvasShow()
  if self.CanvasProxy then
    if self.bIsInitShow and self.bIsShow then
      self.CanvasProxy:RefreshCanvasPanelVisible(true, self.HideBitNum, self.sActionName)
    else
      self.CanvasProxy:RefreshCanvasPanelVisible(false, self.HideBitNum, self.sActionName)
    end
  end
end
function CanvasActionBase:HasValue(array, element)
  local Table = self.Config.ConditionArray2Table[array]
  if Table then
    return Table[element] or false
  end
  for k, v in ipairs(array) do
    if v == element then
      return true
    end
  end
  return false
end
function CanvasActionBase:ExecValue(array, func)
  for k, v in ipairs(array) do
    if func(v) then
      return true
    end
  end
  return false
end
function CanvasActionBase:CallUIRootFunction(sFuncName, ...)
  if self.CanvasProxy and self.CanvasProxy.CanvasUIRoot and self.CanvasProxy.CanvasUIRoot[sFuncName] then
    return xpcall(self.CanvasProxy.CanvasUIRoot[sFuncName], utility.ErrorMessageHandler, self.CanvasProxy.CanvasUIRoot, ...)
  end
  return false
end
function CanvasActionBase:AddControlEvent(control, eventName, handleFunc, ...)
  if not self.bIsInitShow or not self.CanvasProxy then
    return
  end
  local HandleStateCanvasSubsystem = SubsystemMgr:Get("HandleStateCanvasSubsystem")
  if HandleStateCanvasSubsystem then
    HandleStateCanvasSubsystem:CollectControlEvent(self.CanvasProxy, control, eventName, handleFunc, ...)
  end
end
function CanvasActionBase:RemoveControlEvent(control, eventName)
  if not self.bIsInitShow or not self.CanvasProxy then
    return
  end
  local HandleStateCanvasSubsystem = SubsystemMgr:Get("HandleStateCanvasSubsystem")
  if HandleStateCanvasSubsystem then
    HandleStateCanvasSubsystem:UnCollectControlEvent(self.CanvasProxy, control, eventName)
  end
end
function CanvasActionBase:AddCommonEvent(eventType, eventID, handleFunc, ...)
  if not self.bIsInitShow or not self.CanvasProxy then
    return
  end
  local HandleStateCanvasSubsystem = SubsystemMgr:Get("HandleStateCanvasSubsystem")
  if HandleStateCanvasSubsystem then
    HandleStateCanvasSubsystem:CollectCommonEvent(self.CanvasProxy, eventType, eventID, handleFunc, ...)
  end
end
function CanvasActionBase:RemoveCommonEvent(eventType, eventID)
  if not self.bIsInitShow or not self.CanvasProxy then
    return
  end
  local HandleStateCanvasSubsystem = SubsystemMgr:Get("HandleStateCanvasSubsystem")
  if HandleStateCanvasSubsystem then
    HandleStateCanvasSubsystem:UnCollectCommonEvent(self.CanvasProxy, eventType, eventID)
  end
end
local class = require("class")
local object = require("object")
local CCanvasActionBase = class(object, nil, CanvasActionBase)
return CCanvasActionBase