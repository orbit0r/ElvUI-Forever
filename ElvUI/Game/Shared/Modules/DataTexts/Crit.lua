local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local min = min
local format = format
local strjoin = strjoin

local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpellCritChance = GetSpellCritChance
local GetCritChance = GetCritChance
local GetRangedCritChance = GetRangedCritChance

local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local MELEE_CRIT_CHANCE = MELEE_CRIT_CHANCE
local MAX_SPELL_SCHOOLS = MAX_SPELL_SCHOOLS or 7
local CR_CRIT_MELEE = CR_CRIT_MELEE
local CR_CRIT_SPELL = CR_CRIT_SPELL
local CR_CRIT_RANGED = CR_CRIT_RANGED
local CR_CRIT_TOOLTIP = CR_CRIT_TOOLTIP

local displayString, db = ''
local critMelee, spellIndex, ratingIndex = 0, 0, CR_CRIT_MELEE

local function OnEnter()
	DT.tooltip:ClearLines()

	if E.Classic then
		DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %.2f%%', MELEE_CRIT_CHANCE, critMelee))
	else
		local critical = GetCombatRating(ratingIndex)

		DT.tooltip:AddLine(format('|cffFFFFFF%s:|r |cffFFFFFF%.2f%%|r', MELEE_CRIT_CHANCE, critMelee))
		DT.tooltip:AddDoubleLine(format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(critical) , GetCombatRatingBonus(ratingIndex)))
	end

	DT.tooltip:Show()
end

local function OnEvent(panel)
	local index, text = 2 -- start at holy to skip physical damage
	local minimum = GetSpellCritChance(index)

	critMelee = GetCritChance()

	if E:IsSecretValue(minimum) then
		if ratingIndex == CR_CRIT_MELEE then
			text = critMelee
		elseif ratingIndex == CR_CRIT_RANGED then
			text = GetRangedCritChance()
		else -- during secret phase, spellIndex is stale
			text = GetSpellCritChance(spellIndex)
		end
	else -- safe to do calculations and find ratingIndex
		for i = (index + 1), MAX_SPELL_SCHOOLS do
			local chance = GetSpellCritChance(i)
			minimum = min(minimum, chance)

			if chance == minimum then
				spellIndex = i
			end
		end

		local critRanged = GetRangedCritChance()
		if (minimum >= critRanged and minimum >= critMelee) then
			ratingIndex, text = CR_CRIT_SPELL, minimum
		elseif (critRanged >= critMelee) then
			ratingIndex, text = CR_CRIT_RANGED, critRanged
		else
			ratingIndex, text = CR_CRIT_MELEE, critMelee
		end
	end

	if db.NoLabel then
		panel.text:SetFormattedText(displayString, text)
	else
		panel.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or L["Crit"]..': ', text)
	end
end

local function ApplySettings(panel, hex)
	if not db then
		db = E.global.datatexts.settings[panel.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f%%|r')

	OnEvent(panel)
end

DT:RegisterDatatext('Crit', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS' }, OnEvent, nil, nil, OnEnter, nil, L["Crit"], nil, ApplySettings)
