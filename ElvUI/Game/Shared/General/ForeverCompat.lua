------------------------------------------------------------------------
-- Forever (Interface 16001) compatibility shims for ElvUI Mainline port.
-- Loaded immediately after Initialize.lua so later files capture these globals.
------------------------------------------------------------------------
local E = unpack(ElvUI)

local toc = tonumber(E.wowtoc) or tonumber(select(4, GetBuildInfo())) or 0
local patch = tostring(E.wowpatch or select(1, GetBuildInfo()) or '')
local isForever = toc == 16001 or (toc >= 16000 and toc < 20000)
	or patch:find('^1%.60') ~= nil
	or (C_SwingTimer ~= nil and Enum ~= nil and Enum.PlayerSwingType ~= nil)
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

local function ProbeSave(report)
	Orbit0rErrorDumpDB = Orbit0rErrorDumpDB or {}
	Orbit0rErrorDumpDB.foreverProbe = report
	if ElvDB then
		ElvDB.foreverProbe = report
	end
end

local function ProbeLine(lines, text)
	lines[#lines + 1] = text
	print(text)
end

-- /euiforever — probe (also saved for agent read after /reload)
-- /euiforever paint — force 1.5s swipe on Bar1Button1
-- /euiforever aura — scan target harmful auras
SLASH_EUIFOREVER1 = '/euiforever'
SlashCmdList.EUIFOREVER = function(msg)
	msg = string.lower(strtrim(msg or ''))
	local lines = {}
	local ver, build, _, tocversion = GetBuildInfo()
	ProbeLine(lines, format('|cff1784d1ElvUI Forever|r E.Forever=%s toc=%s ver=%s build=%s', tostring(E.Forever), tostring(tocversion), tostring(ver), tostring(build)))
	ProbeLine(lines, format('  GetActionCooldown=%s GetActionCooldownDuration=%s CreateDuration=%s',
		tostring(C_ActionBar and C_ActionBar.GetActionCooldown ~= nil),
		tostring(C_ActionBar and C_ActionBar.GetActionCooldownDuration ~= nil),
		tostring(C_DurationUtil and C_DurationUtil.CreateDuration ~= nil)))
	ProbeLine(lines, format('  C_SwingTimer=%s PlayerSwingType=%s', tostring(C_SwingTimer ~= nil), tostring(Enum and Enum.PlayerSwingType ~= nil)))

	local btn = _G.ElvUI_Bar1Button1
	if not btn then
		ProbeLine(lines, '  ElvUI_Bar1Button1 missing')
		ProbeSave({ t = date('%Y-%m-%d %H:%M:%S'), lines = lines, paintSeen = false })
		print('|cffffff00Probe saved. /reload so the agent can read it.|r')
		return
	end

	local action = btn._state_action or (btn.GetAttribute and btn:GetAttribute('action'))
	ProbeLine(lines, format('  Bar1Button1 action=%s type=%s cooldown=%s', tostring(action), tostring(btn._state_type), tostring(btn.cooldown ~= nil)))
	if btn.cooldown then
		ProbeLine(lines, format('  SetCooldownFromDurationObject=%s SetCooldown=%s',
			tostring(btn.cooldown.SetCooldownFromDurationObject ~= nil),
			tostring(btn.cooldown.SetCooldown ~= nil)))
	end

	local cdActive, cdOnGCD, durOk
	if action and C_ActionBar and C_ActionBar.GetActionCooldown then
		local ok, info = pcall(C_ActionBar.GetActionCooldown, action)
		cdActive = ok and info and info.isActive
		cdOnGCD = ok and info and info.isOnGCD
		ProbeLine(lines, format('  GetActionCooldown ok=%s isActive=%s isOnGCD=%s', tostring(ok), tostring(cdActive), tostring(cdOnGCD)))
		if cdActive and C_ActionBar.GetActionCooldownDuration then
			local ok2, dur = pcall(C_ActionBar.GetActionCooldownDuration, action)
			durOk = ok2 and dur ~= nil
			ProbeLine(lines, format('  GetActionCooldownDuration ok=%s hasObj=%s', tostring(ok2), tostring(durOk)))
		end
	end

	local paintSeen = false
	if msg == 'paint' then
		local LAB = LibStub and LibStub('LibActionButton-1.0-ElvUI', true)
		local ok = false
		if LAB and LAB.EUI_ForceForeverSwipe then
			ok = LAB.EUI_ForceForeverSwipe(btn, 1.5)
		elseif btn.cooldown and C_DurationUtil and C_DurationUtil.CreateDuration then
			local dur = C_DurationUtil.CreateDuration()
			dur:SetTimeFromStart(GetTime(), 1.5)
			pcall(btn.cooldown.SetSwipeTexture, btn.cooldown, [[Interface\Buttons\WHITE8X8]])
			if btn.cooldown.SetDrawSwipe then btn.cooldown:SetDrawSwipe(true) end
			if btn.cooldown.SetSwipeColor then btn.cooldown:SetSwipeColor(0, 0, 0, 0.85) end
			btn.cooldown:SetAlpha(1)
			btn.cooldown:Show()
			btn.cooldown:SetCooldownFromDurationObject(dur)
			ok = true
		end
		paintSeen = ok
		ProbeLine(lines, format('  Forced 1.5s overlay swipe ok=%s — Bar1Button1 should go dark for 1.5s', tostring(ok)))
	elseif msg == 'gcd' then
		local LAB = LibStub and LibStub('LibActionButton-1.0-ElvUI', true)
		if LAB and LAB.EUI_ForeverPaintGCD then
			LAB.EUI_ForeverPaintGCD(1.5)
			ProbeLine(lines, '  Forced GCD swipe on ALL action buttons for 1.5s')
			paintSeen = true
		else
			ProbeLine(lines, '  EUI_ForeverPaintGCD missing — reload after latest LAB')
		end
	elseif msg == 'aura' then
		if not UnitExists('target') then
			ProbeLine(lines, '  No target')
		else
			local function scanIndex(filter)
				local n, names, err = 0, {}, nil
				if not (C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then
					return 0, '', 'no GetAuraDataByIndex'
				end
				for i = 1, 40 do
					local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, 'target', i, filter)
					if not ok then
						err = tostring(aura)
						break
					end
					if aura == nil then break end
					n = n + 1
					local sid = aura.spellId
					if sid ~= nil and not (issecretvalue and issecretvalue(sid)) then
						names[#names + 1] = tostring(sid) .. ':' .. tostring(aura.name)
					else
						names[#names + 1] = 'secret'
					end
				end
				return n, table.concat(names, ', '), err
			end
			local hn, hnames, herr = scanIndex('HARMFUL')
			local pn, pnames, perr = scanIndex('HARMFUL|PLAYER')
			ProbeLine(lines, format('  HARMFUL index n=%s err=%s [%s]', tostring(hn), tostring(herr), hnames))
			ProbeLine(lines, format('  HARMFUL|PLAYER index n=%s err=%s [%s]', tostring(pn), tostring(perr), pnames))
		end
	else
		ProbeLine(lines, '  Also: /euiforever paint   /euiforever gcd   /euiforever aura')
	end

	ProbeSave({
		t = date('%Y-%m-%d %H:%M:%S'),
		lines = lines,
		paintSeen = paintSeen,
		cdActive = cdActive,
		cdOnGCD = cdOnGCD,
		durOk = durOk,
		action = action,
	})
	print('|cffffff00Probe saved. /reload so the agent can read SavedVariables.|r')
end
