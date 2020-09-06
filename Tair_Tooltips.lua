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
	'Prayer of Healing'
}

---------------------------------------------
--
-- Functions
--
---------------------------------------------

---------------------------------------------
-- Check Spell
---------------------------------------------

function Tair_Tooltips_IsHeal(SpellName)
	for i, spell in ipairs(Tair_Tooltips_Spells) do
		if SpellName == spell then
			return true
		end
	end
end

---------------------------------------------
-- Update Tooltip
---------------------------------------------

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
    local name, id = self:GetSpell()
    if id then
		-- Get the spell info and description
	   	local SpellName, rank, icon, castTime, minRange, maxRange = GetSpellInfo(id)
	   	local SpellDescription = GetSpellDescription(id)
	   	if Tair_Tooltips_IsHeal(SpellName) then
			local costTable = GetSpellPowerCost(id)
			local expandedCostTable = costTable[1];
			local spellCost = expandedCostTable['cost'];
	        local minEffect = SpellDescription:match('(%d+)');
	        local maxEffect = SpellDescription:match('.-%d+.-([%d%.%,]+)');
	        local avgEffect = (minEffect + maxEffect) / 2;
	        if SpellName == 'Renew' then
	        	avgEffect = minEffect;
	        	healPerMana = minEffect / spellCost;
	        elseif SpellName == 'Prayer of Healing' then
	        	avgEffect = avgEffect * 5;
	        end
	        local healPerMana = avgEffect / spellCost;
	        local roundedHealPerMana = math.floor(healPerMana * 10) / 10;
	       	self:AddLine("—");
	       	self:AddLine(math.floor(avgEffect) .. ' Average healing');
		    self:AddLine(roundedHealPerMana .. ' Healing per mana');
	   	end
    end
end) -- End GameTooltip:HookScript("OnTooltipSetSpell", function(self)