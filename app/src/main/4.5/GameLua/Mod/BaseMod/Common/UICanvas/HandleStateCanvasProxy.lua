local HandleStateCanvasProxy = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function HandleStateCanvasProxy:ctor(selfType, uCanvasPanel, uCanvasUIRoot)
  self.CanvasPanel = uCanvasPanel
  self.CanvasUIRoot = uCanvasUIRoot
  self.bInitialized = false
  self.ActionList = {}
  self.nHideBitNum = 0
  self.bNeedWriteLog = not IsEditor and Client and Client.IsDevelopment()
end
function HandleStateCanvasProxy:Init(tConfig)
  local nIndex = 0
  for Key, Value in pairs(tConfig) do
    if Value ~= nil then
      local Suffix = string.format("Common.UICanvas.Action.CanvasAction_%s", Key)
      local ActionMuduleName = GamePlayTools.GetModPath(true, Suffix, true)
      local ActionMudule = require(ActionMuduleName)
      print(bWriteLog and "HandleStateCanvasProxy:InitActionList", Key, ActionMuduleName, ActionMudule)
      if ActionMudule then
        local ActionInst = ActionMudule(self, Value, nIndex)
        table.insert(self.ActionList, ActionInst)
        ActionInst:OnInit()
        nIndex = nIndex + 1
      end
    end
  end
  for _, Action in ipairs(self.ActionList) do
    Action:BindEvent()
  end
  self.bInitialized = true
  self:ForceRefreshCanvasPanelVisible("Init")
end
function HandleStateCanvasProxy:ReInit()
  self.bInitialized = false
  for _, Action in ipairs(self.ActionList) do
    Action:BindEvent()
  end
  self.bInitialized = true
  self:ForceRefreshCanvasPanelVisible("ReInit")
end
function HandleStateCanvasProxy:Release()
  for _, Action in ipairs(self.ActionList) do
    Action:UnbindEvent()
    Action:Release()
  end
  self.CanvasPanel = nil
  self.CanvasUIRoot = nil
  self.ActionList = {}
end
function HandleStateCanvasProxy:IsValid()
  return slua.isValid(self.CanvasPanel)
end
function HandleStateCanvasProxy:ForceRefreshCanvasPanelVisible(sReason)
  if not self.bInitialized then
    return
  end
  local nHideBitNum = 0
  for _, Action in ipairs(self.ActionList) do
    if not Action.bIsInitShow or not Action.bIsShow then
      nHideBitNum = nHideBitNum | Action.HideBitNum
    end
  end
  local sCanvasName = "nil"
  if self.bNeedWriteLog then
    sCanvasName = self:IsValid() and tostring(self.CanvasPanel) or "nil"
    print(bWriteLog and "HandleStateCanvasProxy:ForceRefreshCanvasPanelVisible: " .. sCanvasName .. " Reason:" .. sReason .. " HideBitNum: " .. self.nHideBitNum .. " " .. nHideBitNum)
  end
  if self.nHideBitNum ~= nHideBitNum and self.nHideBitNum & nHideBitNum == 0 then
    if self.bNeedWriteLog then
      print(bWriteLog and "HandleStateCanvasProxy:ForceRefreshCanvasPanelVisible RealSet: " .. sCanvasName .. "HideBitNum: " .. nHideBitNum)
    end
    if slua.isValid(self.CanvasPanel) then
      if nHideBitNum == 0 then
        self.CanvasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      else
        self.CanvasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
  self.end
function HandleStateCanvasProxy:RefreshCanvasPanelVisible(bShow, nBitNum, sReason)
  if not self.bInitialized then
    return
  end
  local nHideBitNum = 0
  if bShow then
    nHideBitNum = self.nHideBitNum & ~nBitNum
  else
    nHideBitNum = self.nHideBitNum | nBitNum
  end
  local sCanvasName = "nil"
  if self.bNeedWriteLog then
    sCanvasName = self:IsValid() and tostring(self.CanvasPanel) or "nil"
    print(bWriteLog and "HandleStateCanvasProxy:RefreshCanvasPanelVisible: " .. sCanvasName .. " Reason:" .. sReason .. " HideBitNum: " .. self.nHideBitNum .. " " .. nHideBitNum .. tostring(bShow))
  end
  if self.nHideBitNum ~= nHideBitNum and self.nHideBitNum & nHideBitNum == 0 then
    if self.bNeedWriteLog then
      print(bWriteLog and "HandleStateCanvasProxy:RefreshCanvasPanelVisible RealSet: " .. sCanvasName .. "HideBitNum: " .. nHideBitNum)
    end
    if nHideBitNum == 0 then
      self:SetCanvasVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self:SetCanvasVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  self.end
function HandleStateCanvasProxy:SetCanvasVisibility(InVisibility)
  if slua.isValid(self.CanvasPanel) then
    self.CanvasPanel:SetWidgetVisibility(InVisibility)
    if bWriteLog then
      print(bWriteLog and "HandleStateCanvasProxy:SetCanvasVisibility: ", self:IsValid() and tostring(self.CanvasPanel), InVisibility)
    end
  end
end
local class = require("class")
local object = require("object")
local CHandleStateCanvasProxy = class(object, nil, HandleStateCanvasProxy)
return CHandleStateCanvasProxy