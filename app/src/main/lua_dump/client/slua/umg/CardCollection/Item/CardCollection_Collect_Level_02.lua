local CardCollection_Collect_Level_02 = {}
local ImageNumPath = "/Game/UMG/UI_BP/CardCollection/NoAltas/Collection/Collect_Level_No%d.Collect_Level_No%d"
function CardCollection_Collect_Level_02:ctor()
end
function CardCollection_Collect_Level_02:OnInitialize()
  self.Widget_Hundred = self.UIRoot.Num_Old_3
  self.Widget_Ten = self.UIRoot.Num_Old_2
  self.Widget_One = self.UIRoot.Num_Old_1
end
function CardCollection_Collect_Level_02:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_FIND_SERIES_RSP, self.OnFindSeriesRsp, self)
end
function CardCollection_Collect_Level_02:OnPostInitialize()
  self:SetLevelByScore(0)
end
function CardCollection_Collect_Level_02:OnClose()
end
function CardCollection_Collect_Level_02:OnFindSeriesRsp(_, _, target_uid, show_info)
  log(bWrite and string.format("[CardCollection] CardCollection_Collect_Level_02:OnFindSeriesRsp score: %d", target_uid))
  if target_uid == self.uid then
    self:SetLevelByScore(show_info.career_score)
  end
end
function CardCollection_Collect_Level_02:SetTextureByPath(iconPath)
  self:SetTexture(self.UIRoot.Image_Default, iconPath)
end
function CardCollection_Collect_Level_02:SetDataByUid(uid, forceUpdata)
  self.  local logic_card_collection_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  if logic_card_collection_season then
    local score = logic_card_collection_season:GetCardScroreByUid(uid, forceUpdata)
    if score then
      self:SetLevelByScore(score)
    end
  end
end
function CardCollection_Collect_Level_02:SetLevelByScore(score)
  log(bWrite and string.format("[CardCollection] CardCollection_Collect_Level_02:SetLevelByScore score: %d", score))
  local logic_card_collection_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  local level = logic_card_collection_season:GetCardCollectionLevelByScore(score)
  log(bWrite and string.format("[CardCollection] CardCollection_Collect_Level_02:SetLevelByScore level: %d", level))
  local hundred = math.floor(level / 100)
  local ten = math.floor(level % 100 / 10)
  local one = level % 10
  self:SetWidgetVisible(self.Widget_Hundred, 0 < hundred)
  self:SetWidgetVisible(self.Widget_Ten, 0 < hundred or 0 < ten)
  if 0 < hundred then
    self:SetTexture(self.Widget_Hundred, string.format(ImageNumPath, hundred, hundred))
  end
  if 0 < hundred or 0 < ten then
    self:SetTexture(self.Widget_Ten, string.format(ImageNumPath, ten, ten))
  end
  self:SetTexture(self.Widget_One, string.format(ImageNumPath, one, one))
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, CardCollection_Collect_Level_02)