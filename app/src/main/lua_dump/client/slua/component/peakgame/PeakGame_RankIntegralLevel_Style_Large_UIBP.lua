local PeakGame_RankIntegralLevel_Style_Large_UIBP = {}
function PeakGame_RankIntegralLevel_Style_Large_UIBP:ctor()
end
function PeakGame_RankIntegralLevel_Style_Large_UIBP:OnInitialize()
  self.childUI = nil
end
function PeakGame_RankIntegralLevel_Style_Large_UIBP:OnPostInitialize()
end
function PeakGame_RankIntegralLevel_Style_Large_UIBP:OnClose()
end
function PeakGame_RankIntegralLevel_Style_Large_UIBP:SetPeakRankIntegral(peakSegment, bUseAnimBlueprint, aniFinishCallback)
  log(bWriteLog and "PeakGame_RankIntegralLevel_Large:SetPeakRankIntegral peakSegment = " .. tostring(peakSegment) .. " bUseAnimBlueprint = " .. tostring(bUseAnimBlueprint))
  self:Collapsed()
  if not peakSegment then
    log(bWriteLog and "PeakGame_RankIntegralLevel_Large:SetPeakRankIntegral no segment")
    return
  end
  log(bWriteLog and "PeakGame_RankIntegralLevel_Large:SetPeakRankIntegral peakSegment is " .. tostring(peakSegment))
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local segmentCfg = LogicPeakGameUtil.GetPeakRankTableData(peakSegment)
  if not segmentCfg then
    log(bWriteLog and "PeakGame_RankIntegralLevel_Large:SetPeakRankIntegral no segmentCfg")
    return
  end
  self:SelfHitTestInvisible()
  if bUseAnimBlueprint then
    local animBlueprintPath = segmentCfg.AnimBlueprintPath
    log(bWriteLog and "PeakGame_RankIntegralLevel_Large:SetPeakRankIntegral animBlueprintPath = " .. tostring(animBlueprintPath))
    if animBlueprintPath then
      self:SetWidgetVisible(self.UIRoot.Image_Base, false, false)
      if self.childUI == nil then
        self.childUI = self:CreateChildWindowWithBpPath("CanvasPanel_Attach", UIManager.UI_Config.ChildUIWithoutBpPath, animBlueprintPath)
        if self.childUI and self.childUI.UIRoot and slua.isValid(self.childUI.UIRoot) and self.childUI.UIRoot.Anim_Enter then
          self.childUI:PlayUserWidgetAnimation(self.childUI.UIRoot.Anim_Enter, 0, 1, 0, 1)
          local segUpConfig = CDataTable.GetTableData("PeakGameBigSegUpConfig", segmentCfg.IntegralType)
          if segUpConfig and segUpConfig.SegIconAuido and segUpConfig.SegIconAuido ~= "" then
            local SegIconAuido = segUpConfig.SegIconAuido
            log(bWriteLog and "PeakGame_RankIntegralLevel_Large:SetPeakRankIntegral SegIconAuido = " .. tostring(SegIconAuido))
            self:PlayAudio(SegIconAuido)
          end
          self:AddControlEventByControl(self.childUI.UIRoot.Anim_Enter, "OnAnimationFinished", function()
            if aniFinishCallback then
              aniFinishCallback()
            end
          end, self)
        end
      else
        log(bWriteLog and "PeakGame_RankIntegralLevel_Large:SetPeakRankIntegral childUI is exist")
      end
    end
  else
    self:SetWidgetVisible(self.UIRoot.Image_Base, true, false)
    self:SetTexture(self.UIRoot.Image_Base, segmentCfg.BigIcon, {sync = false})
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CPeakGame_RankIntegralLevel_Style_Large_UIBP = class(ui_base, nil, PeakGame_RankIntegralLevel_Style_Large_UIBP)
return CPeakGame_RankIntegralLevel_Style_Large_UIBP