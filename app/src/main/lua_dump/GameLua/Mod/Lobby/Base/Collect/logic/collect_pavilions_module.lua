local collect_pavilions_module = {}
function collect_pavilions_module:DefineAndResetData()
  self.myMilestoneDisplayInfo = {}
  self.visitorMilestoneDisplayInfo = {}
end
function collect_pavilions_module:OnLogOut()
  self.myMilestoneDisplayInfo = {}
  self.visitorMilestoneDisplayInfo = {}
end
function collect_pavilions_module:SetMyMilestoneDisplayData(milestoneDisplayInfo)
  log_tree("collect_pavilions_module:OnChangeBadgeData. milestoneDisplayInfo ", milestoneDisplayInfo)
  self.myMilestoneDisplayInfo = milestoneDisplayInfo or {}
end
function collect_pavilions_module:SetVisitorMilestoneDisplayData(milestoneDisplayInfo)
  log_tree("collect_pavilions_module:OnChangeBadgeData. milestoneDisplayInfo ", milestoneDisplayInfo)
  self.visitorMilestoneDisplayInfo = milestoneDisplayInfo or {}
end
function collect_pavilions_module:GetMilestoneDisplayData(isSelf)
  log(bWriteLog and string.format("collect_pavilions_module:GetMilestoneDisplayData isSelf = %s", isSelf))
  if isSelf then
    return self.myMilestoneDisplayInfo
  end
  return self.visitorMilestoneDisplayInfo
end
function collect_pavilions_module:GetMilestoneSlotsData(bIsSelf, bIsShowNone)
  local tInfo = self:GetMilestoneDisplayData(bIsSelf)
  local tSlots = prealloctable(4, 0)
  for i = 1, 4 do
    tSlots[i] = {
      itemID = tInfo and tInfo[i] or 0,
          }
  end
  return tSlots
end
function collect_pavilions_module:CheckMilestonesAreInstalled(itemID)
  for i, v in pairs(self.myMilestoneDisplayInfo) do
    if v == itemID then
      return true
    end
  end
  return false
end
function collect_pavilions_module:SetShowMilestoneSlot(itemID, slotIndex)
  log(bWriteLog and string.format("collect_pavilions_module:SetShowMilestoneSlot itemID = %s, slotID = %s", itemID, slotIndex))
  local ModCollectHandler = RequireModDownload("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
  ModCollectHandler.send_set_show_milestone_data_req(slotIndex, itemID)
end
function collect_pavilions_module:OnSetShowMilestoneSlot(itemID, slotIndex)
  self.myMilestoneDisplayInfo[slotIndex] = itemID
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_REFRESH_MILESTONE_SLOTS)
  UIManager.CloseUI(UIManager.UI_Config.Collect_Milestone_Detail_UIBP)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_pavilions_module)
return CModuleTemplate