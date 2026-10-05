------------------------------------------------------------------------
-- Forever (Interface 16001) compatibility shims for ElvUI Mainline port.
-- Loaded immediately after Initialize.lua so later files capture these globals.
------------------------------------------------------------------------
local E = unpack(ElvUI)

local toc = tonumber(E.wowtoc) or tonumber(select(4, GetBuildInfo())) or 0
local isForever = toc == 16001 or (toc >= 16000 and toc < 20000)
if not isForever then return end

E.Forever = true
E.Retail = true -- Mainline UI family
-- Tiny hide-scale: Forever rejects ~0.00001 as not > 0
E.HideScale = 0.01

-- Chat timestamps (Blizzard BetterDate missing on Forever)
if type(_G.BetterDate) ~= 'function' then
	function _G.BetterDate(formatString, timeValue)
		return date(formatString or '%H:%M:%S', timeValue or time())
	end
end

-- XP / account APIs missing on Forever
if type(_G.IsLevelAtEffectiveMaxLevel) ~= 'function' then
	function _G.IsLevelAtEffectiveMaxLevel(level)
		level = level or UnitLevel('player')
		local maxLevel = E.expansionLevelMax or 60
		if GetMaxLevelForPlayerExpansion then
			maxLevel = GetMaxLevelForPlayerExpansion() or maxLevel
		end
		return level >= maxLevel
	end
end

if type(_G.IsXPUserDisabled) ~= 'function' then
	function _G.IsXPUserDisabled()
		return false
	end
end

if type(_G.IsRestrictedAccount) ~= 'function' then
	function _G.IsRestrictedAccount()
		return false
	end
end

if type(_G.IsTrialAccount) ~= 'function' then
	function _G.IsTrialAccount()
		return false
	end
end

if type(_G.IsVeteranTrialAccount) ~= 'function' then
	function _G.IsVeteranTrialAccount()
		return false
	end
end

-- Action bars: Forever may omit this constant
if type(_G.NUM_ACTIONBAR_BUTTONS) ~= 'number' then
	_G.NUM_ACTIONBAR_BUTTONS = 12
end
