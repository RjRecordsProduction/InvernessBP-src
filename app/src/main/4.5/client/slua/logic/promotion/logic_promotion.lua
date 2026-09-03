local logic_promotion = {}
function logic_promotion:ctor()
end
function logic_promotion:DefineAndResetData()
end
function logic_promotion:OnInitialize()
  self.promotion_layer = nil
  self.bAutoShowPromotionGuide = false
end
function logic_promotion:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, self.OnLoadingFinish, self)
end
function logic_promotion:OnLoadingFinish()
  log(bWriteLog and "logic_promotion:OnLoadingFinish")
  self:SetLoadingPromotionLayer(nil)
end
function logic_promotion:IsOpen()
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local bSwitch = promotion_match_util.GetPromotionSwitch()
  local cur_season = DataMgr.season_id
  local start_season = promotion_match_util.GetPromotionStartSeasonId()
  if start_season == nil then
    log(bWriteLog and "logic_promotion:IsOpen start_season is nil from server")
    local Start_Season_ID = CDataTable.GetTableData("PromotionParams", "Start_Season_ID")
    start_season = tonumber(Start_Season_ID.Value)
  end
  local bSeason = cur_season >= start_season
  log_format(bWriteLog and "logic_promotion:IsOpen bSwitch: %s, bSeason: %s", bSwitch, bSeason)
  return bSwitch and bSeason
end
function logic_promotion:IsShowPromotionStatus(uid)
  if not self:IsOpen() then
    return false
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  log_format(bWriteLog and "logic_promotion:IsShowPromotionStatus uid: %s", uid)
  if profile then
    log_tree(bWriteLog and "logic_promotion:IsShowPromotionStatus profile.promotion_info: ", profile.promotion_info)
  end
  if not (profile and profile.promotion_info) or profile.promotion_info.is_progressing == false then
    return false
  end
  if profile.promotion_info.season_id ~= DataMgr.season_id then
    return false
  end
  local nPrivacy = profile.promotion_info.privacy
  if nPrivacy == 1 then
    return false
  end
  if nPrivacy == 0 then
    return true
  end
  return false
end
function logic_promotion:SetLoadingPromotionLayer(promotion_layer)
  log(bWriteLog and "logic_promotion:SetLoadingPromotionLayer promotion_layer = " .. tostring(promotion_layer) .. " self.promotion_layer = " .. tostring(self.promotion_layer))
  self.end
function logic_promotion:GetLoadingPromotionLayer()
  log(bWriteLog and "logic_promotion:LoadingPromotionLayer self.promotion_layer = " .. tostring(self.promotion_layer))
  return self.promotion_layer
end
function logic_promotion:SetbAutoShowPromotionGuide(bAutoShow)
  log(bWriteLog and "logic_promotion:SetbAutoShowPromotionGuide bAutoShow = " .. tostring(bAutoShow) .. " self.bAutoShowPromotionGuide = " .. tostring(self.bAutoShowPromotionGuide))
  self.bAutoShowPromotionGuide = bAutoShow
end
function logic_promotion:GetbAutoShowPromotionGuide()
  log(bWriteLog and "logic_promotion:GetbAutoShowPromotionGuide self.bAutoShowPromotionGuide = " .. tostring(self.bAutoShowPromotionGuide))
  return self.bAutoShowPromotionGuide
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_promotion = class(CModuleBase, nil, logic_promotion)
return Clogic_promotion