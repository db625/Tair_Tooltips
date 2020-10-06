---------------------------------------------
--
-- Tair_Tooltips.lua
--
-- Adds useful information to classic healing spell tooltips.
--
---------------------------------------------

local name,addon=...;

---------------------------------------------
--
-- Config
--
---------------------------------------------

---------------------------------------------
-- Create Frame
---------------------------------------------

addon.EventFrame = CreateFrame("Frame")
-- addon.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- addon.EventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
-- addon.EventFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
-- addon.EventFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
-- addon.EventFrame:RegisterEvent("SPELL_UPDATE_USABLE")

---------------------------------------------
-- Define Spells
---------------------------------------------

local Tair_Tooltips_Spells = {
	'Flash of Light',
	'Holy Light',
	'Holy Shock',
	'Lesser Heal',
	'Heal',
	'Greater Heal',
	'Flash Heal',
	'Renew',
	'Prayer of Healing',
	'Healing Touch',
	'Rejuvenation'
}

---------------------------------------------
-- Define Action Bars
---------------------------------------------

-- Blizzard
-- local ActionBars = { "Action", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft" }

-- -- ElvUI
-- if IsAddOnLoaded("ElvUI") then
-- 	ActionBars = { "ElvUI_Bar1", "ElvUI_Bar2", "ElvUI_Bar3", "ElvUI_Bar4", "ElvUI_Bar5", "ElvUI_Bar6" }
-- end

---------------------------------------------
--
-- Functions
--
---------------------------------------------

---------------------------------------------
-- Check Spell
---------------------------------------------

function addon.Tair_Tooltips_IsHeal(SpellName)
	for i, spell in ipairs(Tair_Tooltips_Spells) do
		if SpellName == spell then
			return true
		end
	end
end

---------------------------------------------
-- Determine Average Heal of Spell
---------------------------------------------

function addon.Tair_Tooltips_GetAvgHeal(id)
	local SpellName, rank, icon, castTime, minRange, maxRange = GetSpellInfo(id)
	local SpellDescription = GetSpellDescription(id)
	local minEffect = SpellDescription:match('(%d+)');
	local maxEffect = SpellDescription:match('.-%d+.-([%d%.%,]+)');
	local avgEffect = (minEffect + maxEffect) / 2;
	if SpellName == 'Renew' then
	   	avgEffect = minEffect;
	end
	return math.floor(avgEffect)
end

---------------------------------------------
-- Update Tooltip
---------------------------------------------

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
    local name, id = self:GetSpell()
    if id then
	   	local SpellName, rank, icon, castTime, minRange, maxRange = GetSpellInfo(id)
	   	local SpellDescription = GetSpellDescription(id)
	   	if addon.Tair_Tooltips_IsHeal(SpellName) then
			local costTable = GetSpellPowerCost(id)
			local expandedCostTable = costTable[1];
			local spellCost = expandedCostTable['cost'];
	        local minEffect = SpellDescription:match('(%d+)');
	        local maxEffect = SpellDescription:match('.-%d+.-([%d%.%,]+)');
	        local avgEffect = (minEffect + maxEffect) / 2;
	        if SpellName == 'Renew' or SpellName == 'Rejuvenation' then
	        	avgEffect = minEffect;
	        	healPerMana = minEffect / spellCost;
	        elseif SpellName == 'Prayer of Healing' then
	        	avgEffect = avgEffect * 5;
	        end
	        local healPerMana = avgEffect / spellCost;
	        local roundedHealPerMana = math.floor(healPerMana * 10) / 10;
	       	self:AddLine(" ");
		   	self:AddDoubleLine('Average Healing', math.floor(avgEffect), 1, 1, 1, 1, 1, 1);
		   	self:AddDoubleLine('Healing Per Mana', roundedHealPerMana, 1, 1, 1, 1, 1, 1);
	   	end
    end
end) -- End GameTooltip:HookScript("OnTooltipSetSpell", function(self)

---------------------------------------------
-- Set up the action bar button text
---------------------------------------------

function addon.Tair_Tooltips_SetupActionBarText()
	local text
	text = ''
	if not IsAddOnLoaded("ElvUI") then
		-- Hide the blizzard macro names, because they overlap with the spell text
		for b=1,#ActionBars do for i=1,12 do _G[ActionBars[b].."Button"..i.."Name"]:SetAlpha(0) end end
		for _, barName in pairs(ActionBars) do
			for i = 1, 12 do
				local buttonName = barName .. "Button" .. i
				local button = _G[buttonName]
				button.TairSpellText = button:CreateFontString(nil, nil, "GameFontNormalLeft")
				button.TairSpellText:SetPoint("BOTTOMRIGHT", 0, 2)
				button.TairSpellText:SetShadowColor(0,0,0,0)
				button.TairSpellText:SetTextColor(0.15,1,0)
				button.TairSpellText:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE");
				button.TairSpellText:SetText(text)
			end
		end
	end
	if IsAddOnLoaded("ElvUI") then
		for _, barName in pairs(ActionBars) do
			for i = 1, 12 do
				local buttonName = barName .. "Button" .. i
				local button = _G[buttonName]
				button.TairSpellText = button:CreateFontString(nil, nil, "GameFontNormalLeft")
				button.TairSpellText:SetPoint("BOTTOMRIGHT", 0, 2)
				button.TairSpellText:SetShadowColor(0,0,0,0)
				button.TairSpellText:SetTextColor(0.15,1,0)
				if IsAddOnLoaded("Tair_Media") then
					button.TairSpellText:SetFont("Interface\\Addons\\Tair_Media\\fonts\\BigNoodleTitling\\big_noodle_titling.ttf", 15, "OUTLINE");
				else
					button.TairSpellText:SetFont("Fonts\\ARIALN.TTF", 13, "OUTLINE");
				end
				button.TairSpellText:SetText(text)
			end
		end
	end
end

----------------------------------------
-- Update the action bar button text
----------------------------------------

function addon.Tair_Tooltips_UpdateActionBarText()
	if not IsAddOnLoaded("ElvUI") then
		for _, barName in pairs(ActionBars) do
			for i = 1, 12 do
				local buttonName = barName .. "Button" .. i
				local button = _G[buttonName]
				-- Clear the button text for all slots
				addon.Tair_Tooltips_ClearActionButtonText(button);
				local slot = ActionButton_GetPagedID(button) or ActionButton_CalculateAction(button) or button:GetAttribute("action") or 0
				if HasAction(slot) then
					local actionType, id, _, actionName = GetActionInfo(slot)
					if actionType == "macro" then
						id = GetMacroSpell(id)
						actionName = GetSpellInfo(id)
					elseif actionType == "spell" then
						actionName = GetSpellInfo(id)
					end
					if addon.Tair_Tooltips_IsHeal(actionName) then
						addon.Tair_Tooltips_DrawActionButtonText(id, button);
					end
				end
			end
		end
	end
	if IsAddOnLoaded("ElvUI") then
		for _, barName in pairs(ActionBars) do
			for i = 1, 12 do
				local buttonName = barName .. "Button" .. i
				local button = _G[buttonName]
				-- Clear the button text for all slots
				addon.Tair_Tooltips_ClearActionButtonText(button);
				local type = button:GetAttribute('type')
				if type == 'action' then
					local slot = button:GetAttribute('action')
					local actionType, id, actionName = GetActionInfo(slot)
					if actionType == "macro" then
						id = GetMacroSpell(id)
						actionName = GetSpellInfo(id)
					elseif actionType == "spell" then
						actionName = GetSpellInfo(id)
					end
					if addon.Tair_Tooltips_IsHeal(actionName) then
						addon.Tair_Tooltips_DrawActionButtonText(id, button);
					end
				end
			end
		end
	end
end

---------------------------------------------
-- Draw the action bar button text
---------------------------------------------

function addon.Tair_Tooltips_DrawActionButtonText(id, button)
	text = addon.Tair_Tooltips_GetAvgHeal(id)
	button.TairSpellText:SetText(text)
end

---------------------------------------------
-- Clear the action bar button text
---------------------------------------------

function addon.Tair_Tooltips_ClearActionButtonText(button)
	text = ''
	button.TairSpellText:SetText(text)
end

---------------------------------------------
--
-- Events
--
---------------------------------------------

-- addon.EventFrame:HookScript("OnEvent", function(self, event, ...)
-- 	if event == "PLAYER_ENTERING_WORLD" then
-- 		addon.Tair_Tooltips_SetupActionBarText()
-- 		addon.Tair_Tooltips_UpdateActionBarText()
-- 	end
-- 	if event == "ACTIONBAR_SLOT_CHANGED" then
-- 		addon.Tair_Tooltips_UpdateActionBarText()
-- 	end
-- 	if event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_BONUS_ACTIONBAR" then
-- 		addon.Tair_Tooltips_UpdateActionBarText()
-- 	end
-- end)

-- function TestFunc()
-- 	print('test')
-- end

-- if IsAddOnLoaded("ElvUI") then
-- 	local E = unpack(ElvUI)
-- 	local AB = E:GetModule('ActionBars')
-- 	hooksecurefunc(ActionBars, "UpdateButtonSettings", TestFunc)
-- end