local _G = _G

local function IsItemArtifactPower(itemLink)
    local result = false
    for i = 1, GameTooltip:NumLines() do
        result = _G[GameTooltip:GetName()..'TextLeft'..i]:GetText() == "|cFFE6CC80"..ARTIFACT_POWER.."|r"
        if result then break end
    end
    return result
end

local function attachItemTooltip(self)
    local _,link = self:GetItem()
    if IsItemArtifactPower(link) then
        if ArtifactPowerSaver_PreferredSpec ~= GetSpecialization() then
            self:AddLine(SPELL_FAILED_CUSTOM_ERROR_304,255,0,0,true)
        else 
            self:AddLine(format(LOOT_SPECIALIZATION_DEFAULT,select(2,GetSpecializationInfo(GetSpecialization()))),0,255,0,true)
        end
    end
end

local f = CreateFrame('frame')
f:SetScript('OnEvent', function(self, event, ...)
    if event == 'PLAYER_LOGIN' then
        ArtifactPowerSaver_PreferredSpec = ArtifactPowerSaver_PreferredSpec or GetSpecialization()

        ArtifactPowerSaver = {}

        ArtifactPowerSaver.panel = CreateFrame("Frame", "ArtifactPowerSaverPanel", UIParent)
        ArtifactPowerSaver.panel.name = "ArtifactPowerSaver"

        local fs = ArtifactPowerSaver.panel:CreateFontString("PrefSpec", nil, "GameFontNormal")
        fs:SetText(CHOOSE_SPECIALIZATION..":")
        fs:SetPoint("TOPLEFT",10,-20)
        local dropDown = CreateFrame("FRAME", "APSDropDown", ArtifactPowerSaver.panel, "UIDropDownMenuTemplate")
        dropDown:SetPoint("TOPLEFT",fs,"RIGHT",0,10)
        UIDropDownMenu_SetWidth(dropDown, 250)
        UIDropDownMenu_SetText(dropDown, select(2,GetSpecializationInfo(ArtifactPowerSaver_PreferredSpec))) -- current spec

        function dropDown:SetValue(newValue)
         ArtifactPowerSaver_PreferredSpec = newValue
         UIDropDownMenu_SetText(dropDown, select(2,GetSpecializationInfo(newValue)))
        end

        UIDropDownMenu_Initialize(dropDown, function(self, menuList)
          local info = UIDropDownMenu_CreateInfo()
          info.func = self.SetValue
          for i = 1,GetNumSpecializations() do
           info.text, info.arg1, info.checked = select(2,GetSpecializationInfo(i)), i, i == ArtifactPowerSaver_PreferredSpec
           UIDropDownMenu_AddButton(info)
          end
        end)

        InterfaceOptions_AddCategory(ArtifactPowerSaver.panel)
    end
end)
f:RegisterEvent('PLAYER_LOGIN')

GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)