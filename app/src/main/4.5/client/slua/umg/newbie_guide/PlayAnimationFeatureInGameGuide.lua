local specialItem = {
  [1407392] = "/Game/UMG/Texture_200/Lobby_NoAtlas/Wardrobe/Guide/Wardrobe_Image_Guide05.Wardrobe_Image_Guide05",
  [1407391] = "/Game/UMG/Texture_200/Lobby_NoAtlas/Wardrobe/Guide/Wardrobe_Image_Guide02.Wardrobe_Image_Guide02"
}
local featureId = 1401
local curItemId
local PlayAnimationFeatureInGameGuide = {
  guideConfig = {
    [1] = {
      TitleID = 774911,
      BPPath = "/Game/UMG/UI_BP/Common/Popup/Theme/Item/Common_Popup_Theme_Explain_Picture02_Item_UIBP.Common_Popup_Theme_Explain_Picture02_Item_UIBP",
      RefreshFun = function(node_root)
        if not node_root then
          return
        end
        local Util = require("client.slua_ui_framework.util")
        Util.SetTexture(node_root.Image_Pic_1, "/Game/UMG/Texture_200/Lobby_NoAtlas/Wardrobe/Guide/Wardrobe_Image_Guide01.Wardrobe_Image_Guide01")
        Util.SetTexture(node_root.Image_Pic_2, specialItem and specialItem[curItemId] or "")
        node_root.Text_Pic_1:SetText(LocUtil.LocalizeResFormat(774792))
        local itemInfo = CDataTable.GetTableData("Item", curItemId)
        node_root.Text_Pic_2:SetText(LocUtil.LocalizeResFormat(774793, itemInfo.ItemName or ""))
        node_root.Text_Desc:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        node_root.Text_Desc:SetText("")
      end
    },
    [2] = {
      TitleID = 774911,
      BPPath = "/Game/UMG/UI_BP/Common/Popup/Theme/Item/Common_Popup_Theme_Explain_Picture02_Item_UIBP.Common_Popup_Theme_Explain_Picture02_Item_UIBP",
      RefreshFun = function(node_root)
        if not node_root then
          return
        end
        local Util = require("client.slua_ui_framework.util")
        Util.SetTexture(node_root.Image_Pic_1, "/Game/UMG/Texture_200/Lobby_NoAtlas/Wardrobe/Guide/Wardrobe_Image_Guide03.Wardrobe_Image_Guide03")
        Util.SetTexture(node_root.Image_Pic_2, "/Game/UMG/Texture_200/Lobby_NoAtlas/Wardrobe/Guide/Wardrobe_Image_Guide04.Wardrobe_Image_Guide04")
        node_root.Text_Pic_1:SetText(LocUtil.LocalizeResFormat(774794))
        node_root.Text_Pic_2:SetText(LocUtil.LocalizeResFormat(774795))
        node_root.Text_Desc:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        node_root.Text_Desc:SetText("")
      end
    }
  },
  performance_switch = false
}
function PlayAnimationFeatureInGameGuide.GetGuideConfig()
  return PlayAnimationFeatureInGameGuide.guideConfig
end
function PlayAnimationFeatureInGameGuide.CanShowGuide(itemId)
  if specialItem and itemId and specialItem[itemId] and PlayAnimationFeatureInGameGuide.SuitHasPerformFeature(itemId) then
    if UIManager.GetUI(UIManager.UI_Config.NewStoreSystem) then
      return false
    end
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local featureGuide = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFeatureGuide)
    if not (featureGuide and next(featureGuide)) or not featureGuide.PlayAnimationFeatureInGameGuide then
      curItemId = itemId
      return true
    end
  end
  return false
end
function PlayAnimationFeatureInGameGuide.ShowAndSaveGuide()
  UIManager.ShowUI(UIManager.UI_Config.Common_Popup_Reward_Base, nil, PlayAnimationFeatureInGameGuide.guideConfig)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local featureGuide = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFeatureGuide)
  featureGuide = featureGuide or {}
  featureGuide.PlayAnimationFeatureInGameGuide = true
  PlayerPrefsSystem.SaveTableToFile_N(featureGuide, PlayerPrefsSystem.ePlayerPrefsType.eFeatureGuide)
end
function PlayAnimationFeatureInGameGuide.CanShowPerform(itemId)
  if specialItem and itemId and specialItem[itemId] and PlayAnimationFeatureInGameGuide.SuitHasPerformFeature(itemId) then
    curItemId = itemId
    return true
  end
  return false
end
function PlayAnimationFeatureInGameGuide.SuitHasPerformFeature(itemId)
  local featuresItem = CDataTable.GetTableData("FeaturesItems", itemId)
  if string.find(featuresItem.Features or "", tostring(featureId)) then
    return true
  end
  return false
end
function PlayAnimationFeatureInGameGuide.UpdatePerformanceSwitch(performance_switch)
  if performance_switch == 1 then
    PlayAnimationFeatureInGameGuide.performance_switch = true
    DataMgr.roleData.performance_switch = 1
  else
    PlayAnimationFeatureInGameGuide.performance_switch = false
    DataMgr.roleData.performance_switch = 0
  end
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_set_performance_switch_req(performance_switch)
end
return PlayAnimationFeatureInGameGuide