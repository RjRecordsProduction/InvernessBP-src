local TreasureChestActorExtraDropFeature = {}
local UGameplayStatics = import("GameplayStatics")
local UKismetMathLibrary = import("KismetMathLibrary")
local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
local TreasureChestActorExtraDropConfig = {
  [50] = {
    [3001054] = {DropPercent = 0.4, ExtraDropID = 4301054}
  },
  TipsID = 81469,
  SortID = 100,
  SoundPath = "/Game/Mod/TPlan/WwiseEvent/Tplan_430/Tplan_UI_430/Play_Tplan_UI_Pick_AnotherGold_430.Play_Tplan_UI_Pick_AnotherGold_430",
  DelayTime = 1.5,
  ExtraStartAngle = 90
}
function TreasureChestActorExtraDropFeature:DelaySpawnExtraDropBox(uPlayer, TreasureChestBox, TalentExtraDropItemConfig)
  if slua.isValid(TreasureChestBox.BP_ProduceDropItemComponent) then
    TreasureChestBox.BP_ProduceDropItemComponent.ProduceID = TalentExtraDropItemConfig.ExtraDropID
    TreasureChestBox.BP_ProduceDropItemComponent.StartAngle = TreasureChestBox.BP_ProduceDropItemComponent.StartAngle + TreasureChestActorExtraDropConfig.ExtraStartAngle
    TreasureChestBox.BP_ProduceDropItemComponent:StartSimpleDropByBox(TreasureChestBox:K2_GetActorLocation())
    Game:UIShowImageTips(uPlayer.PlayerKey, TreasureChestActorExtraDropConfig.TipsID)
    if uPlayer.DS_Play2DAudio then
      uPlayer:DS_Play2DAudio(TreasureChestActorExtraDropConfig.SoundPath)
    end
  end
end
function TreasureChestActorExtraDropFeature:CheckGenerateExtraDropBox(uPlayer, ItemIDList)
  if self.Owner and self.Owner.Object and slua.isValid(self.Owner.Object) and slua.isValid(uPlayer) then
    local TreasureChestBox = self.Owner.Object
    local TalentExtraDrop = math.floor(uPlayer:GetAttrValue("TalentExtraDrop"))
    if 0 < TalentExtraDrop and TreasureChestActorExtraDropConfig[TalentExtraDrop] then
      do
        local TalentExtraDropConfig = TreasureChestActorExtraDropConfig[TalentExtraDrop]
        for _, v in pairs(ItemIDList) do
          local ItemID = v.ItemID
          if 0 < ItemID and TalentExtraDropConfig[ItemID] then
            local TalentExtraDropItemConfig = TalentExtraDropConfig[ItemID]
            local RandomPercent = math.random()
            if RandomPercent < TalentExtraDropItemConfig.DropPercent then
              print(bWriteLog and "TreasureChestActorExtraDropFeature:CheckGenerateExtraDropBox:", RandomPercent, TalentExtraDropItemConfig.DropPercent, ItemID)
              do
                local DelayTime = TreasureChestActorExtraDropConfig.DelayTime or 0
                if 0 < DelayTime then
                  self:AddGameTimer(DelayTime, false, function()
                    if slua.isValid(TreasureChestBox) and slua.isValid(uPlayer) then
                      self:DelaySpawnExtraDropBox(uPlayer, TreasureChestBox, TalentExtraDropItemConfig)
                    end
                  end)
                  break
                end
                self:DelaySpawnExtraDropBox(uPlayer, TreasureChestBox, TalentExtraDropItemConfig)
                break
              end
            end
          end
        end
      end
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, TreasureChestActorExtraDropFeature)