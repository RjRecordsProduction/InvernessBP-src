local Common_Tab_Vertical_LevelOne_Icon_UIBP = {}
local C_AnimPlayDelayTime = 0.1
function Common_Tab_Vertical_LevelOne_Icon_UIBP:ctor(_, bAutoSelect, noAnim)
  self.tabClickedHandleFunc = nil
  self.tabSelectedHandleFunc = nil
  self.tabRefreshHandleFunc = nil
  self.tabData = nil
  self.bAutoSelect = bAutoSelect ~= false
  self.itemClickCDType = nil
  self.bNoAnim = noAnim == true
  self.bIsExpanded = false
  self.animPlayStatusList = nil
  self.curAnimTime = 0
  self.itemAnimTimer = nil
  self.curSubAnimTime = 0
  self.subItemAnimTimer = nil
  self.lastSelectedIndex = 0
  self.LoopScrollBox_Tab = nil
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:OnInitialize()
  Common_Tab_Vertical_LevelOne_Icon_UIBP.__super.OnInitialize(self)
  self.LoopScrollBox_Tab = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Tab, "client.slua.component.common.Common_Tab_Vertical_LevelOne_Icon_Item_UIBP")
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:RegistEvents()
  Common_Tab_Vertical_LevelOne_Icon_UIBP.__super.RegistEvents(self)
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:OnPostInitialize()
  Common_Tab_Vertical_LevelOne_Icon_UIBP.__super.OnPostInitialize(self)
  if not self.bNoAnim and self.UIRoot.Anim_in then
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_in, 0, 1, 0, 1)
  end
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:OnLoopScrollBox_TabItemClicked(widget, index)
  if self.tabClickedHandleFunc then
    if false == self.tabClickedHandleFunc(widget, index) then
      log_warning("[DeanJYT] Common_Tab_Vertical_LevelOne_Icon_UIBP:OnLoopScrollBox_TabItemClicked tabClickedHandleFunc return false")
      return
    end
  else
    log_warning("[DeanJYT] Common_Tab_Vertical_LevelOne_Icon_UIBP:OnLoopScrollBox_TabItemClicked tabClickedHandleFunc not set")
  end
  if self.bAutoSelect then
    self:SelectTab(index, true)
  end
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:StartItemEnterAnim()
  self.animPlayStatusList = {}
  self.itemAnimTimer = 0
  if self.itemAnimTimer then
    self:RemoveTimer(self.itemAnimTimer)
    self.itemAnimTimer = nil
  end
  local itemCount = #self.tabData
  local totalAnimTime = itemCount * C_AnimPlayDelayTime
  local timer_ticker = require("common.time_ticker")
  local NEXT_FRAME = timer_ticker.NEXT_FRAME
  self.itemAnimTimer = self:AddTimer(0, function()
    while self.curAnimTime < totalAnimTime do
      local deltaTime = coroutine.yield(NEXT_FRAME)
      self.curAnimTime = self.curAnimTime + deltaTime
    end
    log(bWriteLog and "[DeanJYT] Common_Tab_Vertical_LevelOne_Icon_UIBP:StartItemEnterAnim anim done. cur anim time = " .. tostring(self.curAnimTime))
    self.itemAnimTimer = nil
  end)
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:OnClose()
  if not self.bNoAnim and self.UIRoot.Anim_in then
    self.UIRoot:PlayAnimationTo(self.UIRoot.Anim_in, 0, 0.01, 1, 0, 1)
  end
  Common_Tab_Vertical_LevelOne_Icon_UIBP.__super.OnClose(self)
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:SetTabs(tabs, initialIndex)
  self.tabData = tabs
  self:StartItemEnterAnim()
  self.lastSelectedIndex = 0
  self.LoopScrollBox_Tab:SetData(self.tabData)
  if initialIndex then
    self:SelectTab(initialIndex, false)
  end
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:SelectTab(index, bIsFromClick)
  index = index or 1
  self.LoopScrollBox_Tab:Select(index)
  if self.tabSelectedHandleFunc then
    self.tabSelectedHandleFunc(self.lastSelectedIndex, index, bIsFromClick)
  end
  self.lastSelectedIndex = index
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:AddOnTabClickedCallback(func, funcSelf)
  function self.tabClickedHandleFunc(widget, index)
    return func(funcSelf, widget, index)
  end
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:AddOnTabSelectedCallback(func, funcSelf)
  function self.tabSelectedHandleFunc(lastIndex, index, bIsFromClick)
    return func(funcSelf, lastIndex, index, bIsFromClick)
  end
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:AddOnTabRefreshCallback(func, funcSelf)
  function self.tabRefreshHandleFunc(widget, index)
    return func(funcSelf, widget, index)
  end
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:SetItemClickCDType(type)
  self.itemClickCDType = type
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:GetTabData(index)
  return self.tabData[index]
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:GetSelectedTabIndex()
  return self.LoopScrollBox_Tab:GetSelectIndex()
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:GetTabCount()
  return self.LoopScrollBox_Tab:GetItemCount()
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:RefreshSelectedTab()
  self.LoopScrollBox_Tab:RefreshItem(self.LoopScrollBox_Tab:GetSelectIndex())
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:RefreshTabItemShow(nIndex)
  if not nIndex then
    return
  end
  self.LoopScrollBox_Tab:RefreshItem(nIndex)
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:RefreshAllTabItemShow()
  self.LoopScrollBox_Tab:RefreshAllItems()
end
function Common_Tab_Vertical_LevelOne_Icon_UIBP:GetIndexOfWidget(nIndex)
  if not nIndex then
    return
  end
  return self.LoopScrollBox_Tab:GetIndexOfWidget(nIndex)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_Tab_Vertical_LevelOne_Icon_UIBP = class(ui_base, nil, Common_Tab_Vertical_LevelOne_Icon_UIBP)
return CCommon_Tab_Vertical_LevelOne_Icon_UIBP