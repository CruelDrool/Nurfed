local addonName = ...
local moduleName = "PlayerFrame"
local displayName = moduleName
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local UnitFrames = addon:GetModule("UnitFrames")
local module = UnitFrames:NewModule(moduleName, "AceHook-3.0")
local unit = "player"

module.defaults = {
	enabled = true,
	disableBlizzCastBar = false,
	shortenFactionRepName = false,
	shortenStandingRepName = false,
	hideClassResourceBars = false,
	combatFeedBack = false,
	formats = {
		infoline = "$level ($g)",
		xp = "$cur/$max ($rest) $perc",
		reputation = "$cur/$max - $faction ($standing) $perc",
		maxReputation = "$faction ($standing)",
		stagger = "$cur ($max)",
	},
	frames = {
		[unit] = {
			["x"] = -88,
			["y"] = -40,
			["point"] = "TOP",
			["scale"] = 1,
		},
	},
}

module.options = {
	type = "group",
	name = displayName,
	-- desc = "",
	-- icon = "Interface\\GossipFrame\\FooIconThatDoesntExist",
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = "Enabled",
			-- desc = "",
			width = "full",
			get = function() return module.db.enabled end,
			set = function(info, value) if UnitFrames:IsEnabled() then if module.db.enabled then module:Disable() else module:Enable() end end; module.db.enabled = value end,
		},
		formats = {
			order = 2,
			type = "group",
			width = "full",
			name = "Text formats",
			guiInline = true,
			args = {
				name = {
					order = 1,
					type = "input",
					name = "Name",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("name", nil, moduleName) end,
					set = function(info, value) module.db.formats.name = value;if module.frame then UnitFrames:UpdateInfo(module.frame) end end,
				},
				infoline = {
					order = 2,
					type = "input",
					name = "Infoline",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("infoline", nil, moduleName) end,
					set = function(info, value) module.db.formats.infoline = value;if module.frame then UnitFrames:UpdateInfo(module.frame) end end,
				},
				health = {
					order = 3,
					type = "input",
					name = "Health",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("health", nil, moduleName) end,
					set = function(info, value) module.db.formats.health = value end,
				},
				power = {
					order = 4,
					type = "input",
					name = "Power",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("power",nil, moduleName) end,
					set = function(info, value) module.db.formats.power = value end,
				},
				xp = {
					order = 5,
					type = "input",
					name = "Experience",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("xp", nil, moduleName) end,
					set = function(info, value) module.db.formats.xp = value;if module.frame then module:XPbar_Update(module.frame.xp) end end,
				},
				reputation = {
					order = 6,
					type = "input",
					name = "Reputation",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("reputation", nil, moduleName) end,
					set = function(info, value) module.db.formats.reputation = value;if module.frame then module:RepBar_Update(module.frame.reputation) end end,
				},
				maxReputation = {
					order = 7,
					type = "input",
					name = "Maximum reputation",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("maxReputation", nil, moduleName) end,
					set = function(info, value) module.db.formats.maxReputation = value;if module.frame then module:RepBar_Update(module.frame.reputation) end end,
				},
				stagger = select(2, UnitClass(unit)) == "MONK" and {
					order = 7,
					type = "input",
					name = "Stagger bar",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("stagger", nil, moduleName) end,
					set = function(info, value) module.db.formats.stagger = value; end,
				} or nil,
			},
		},
		shortenFactionRepName = {
			order = 3,
			type = "toggle",
			name = "Shorten faction name on the reputation bar",
			width = "full",
			get = function() return module.db.shortenFactionRepName end,
			set = function(info, value) module.db.shortenFactionRepName = value;if module.frame then module:RepBar_Update(module.frame.reputation) end end,
		},
		shortenStandingRepName = {
			order = 4,
			type = "toggle",
			name = "Shorten faction standing on the reputation bar",
			width = "full",
			get = function() return module.db.shortenStandingRepName end,
			set = function(info, value) module.db.shortenStandingRepName = value;if module.frame then module:RepBar_Update(module.frame.reputation) end end,
		},
		blizzCastBar = {
			order = 5,
			type = "toggle",
			name = "Disable Blizzard Castbar",
			width = "full",
			get = function() return module.db.disableBlizzCastBar end,
			set = 
			function(info, value)
				module.db.disableBlizzCastBar = value;
				if module.db.enabled and UnitFrames:IsEnabled() then
					if value == true then
						module:DisableBlizzCastBar()
					else
						module:EnableBlizzCastBar()
					end
				end
			end,
		},
		hideClassResourceBars = {
			order = 6,
			type = "toggle",
			name = "Hide class resource bars",
			desc = addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE and "Combo points, runes, soul shards, chi, stagger, essence, arcane charges etc.." or "Runes, soul shards, eclipse or holy power",
			width = "full",
			get = function() return module.db.hideClassResourceBars end,
			set =
			function(info, value)
				module.db.hideClassResourceBars = value
				if module.db.enabled and UnitFrames:IsEnabled() then
					module:ToggleClassResourceBars()
				end
			end,
		},
		combatFeedBack = {
			order = 7,
			type = "toggle",
			name = "Combat feedback",
			width = "full",
			get = function() return module.db.combatFeedBack end,
			set = function(info, value) module.db.combatFeedBack = value end,
		},
	},
}

local events = {
	"UNIT_COMBAT",
	"UNIT_FACTION",
	"UNIT_LEVEL",
	"UNIT_MODEL_CHANGED",
	"UNIT_NAME_UPDATE",
	"DISPLAY_SIZE_CHANGED",
	"PLAYER_ENTERING_WORLD",
	-- "PLAYER_FLAGS_CHANGED",
	"PLAYER_ROLES_ASSIGNED",
	"PLAYER_ENTER_COMBAT",
	"PLAYER_LEAVE_COMBAT",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_TARGET_CHANGED",
	"PLAYER_UPDATE_RESTING",
	"PARTY_LEADER_CHANGED",
	"PARTY_LOOT_METHOD_CHANGED",
	"GROUP_ROSTER_UPDATE",
	"RAID_TARGET_UPDATE",
	"READY_CHECK",
	"READY_CHECK_CONFIRM",
	"READY_CHECK_FINISHED",
	"UI_SCALE_CHANGED",
	"PLAYTIME_CHANGED",
	-- "VOICE_START",
	-- "VOICE_STOP",
}

local function UpdateStatus(frame)
	local state = frame.state
	
	if IsResting() and not (frame.onHateList or frame.inCombat) then
		state.attackIcon:Hide()
		state.attackIconGlow:Hide()
		state.restIcon:Show()
		--state.restIconGlow:Show()
	elseif frame.inCombat and not frame.onHateList then
		state.restIcon:Hide()
		--state.restIconGlow:Hide()
		state.attackIcon:Show()
		--state.attackIconGlow:Show()
		state.attackIconGlow:Hide()
	elseif frame.onHateList then
		state.restIcon:Hide()
		--state.restIconGlow:Hide()
		state.attackIcon:Show()
		state.attackIconGlow:Show()
	else
		state.restIcon:Hide()
		--state.restIconGlow:Hide()
		state.attackIconGlow:Hide()
		state.attackIcon:Hide()
	end
end

local function UpdatePlaytime(frame)
	if PartialPlayTime() then
		frame.icon:SetTexture("Interface\\CharacterFrame\\UI-Player-PlayTimeTired")
		frame.tooltip = format(PLAYTIME_TIRED, REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60))
		frame:Show()
	elseif NoPlayTime() then
		frame.icon:SetTexture("Interface\\CharacterFrame\\UI-Player-PlayTimeUnhealthy")
		frame.tooltip = format(PLAYTIME_UNHEALTHY, REQUIRED_REST_HOURS - floor(GetBillingTimeRested()/60))
		frame:Show()
	else
		frame:Hide()
	end
end

local function Update(frame)
	UnitFrames:PowerBar_Update(frame.powerBar)
	UnitFrames:HealthBar_Update(frame.health)
	UnitFrames:ShowHideHighlight(frame)

	UnitFrames:UpdateModel(frame)
	if UnitExists(frame.unit) then
		UpdateStatus(frame)
		UpdatePlaytime(frame.playTime)
		UnitFrames:UpdateInfo(frame)
		UnitFrames:UpdatePartyLeader(frame)
		UnitFrames:UpdateLoot(frame)
		UnitFrames:UpdateRaidIcon(frame)
		UnitFrames:UpdateRoles(frame)
		UnitFrames:UpdatePVPStatus(frame)
	end
end

local function CombatFeedback_OnEvent(frame, event, flags, amount, school)
	if not ( frame and module.db.combatFeedBack ) then return end
	local isCrit = false
	local text = ""
	local r, g, b = 1, 0.647, 0

	if event == "WOUND" then
		if amount ~= 0 then
			isCrit =  flags == "CRITICAL" or flags == "CRUSHING"

			local colorInfo = CombatLog_Color_ColorArrayBySchool(school)
			r, g, b = colorInfo.r, colorInfo.g, colorInfo.b

			text = addon:FormatNumber(amount)
			if flags == "BLOCK_REDUCED" then
				text = COMBAT_TEXT_BLOCK_REDUCED:format(text)
			end

			text = "-" .. text
		elseif CombatFeedbackText[flags] then
			text = CombatFeedbackText[flags]
		else
			text = CombatFeedbackText["MISS"]
		end
	elseif event == "HEAL" then
		text = "+" .. addon:FormatNumber(amount)
		r, g, b = 0, 1, 0
		isCrit = flags == "CRITICAL"
	elseif event == "ENERGIZE" then
		text = addon:FormatNumber(amount)
		r, g, b = 0.41, 0.8, 0.94
		isCrit = flags == "CRITICAL"
	elseif CombatFeedbackText[event] then
		text = CombatFeedbackText[event]
	end

	local scale = isCrit and 1.25 or 1
	local messageFrame

	if event == "HEAL" then
		messageFrame = frame.heal
	else
		messageFrame = frame.damage
	end

	messageFrame:AddMessage(text, r, g,b, 1, 1)
	messageFrame:SetScale(scale)
end

local function OnEvent(frame, event, ...)

	if not frame.isEnabled then return end

	local arg1, arg2, arg3, arg4, arg5 = ...
	if event == "PLAYER_ENTERING_WORLD" then
		frame.inCombat = nil;
		frame.onHateList = nil;
		Update(frame)
	elseif event == "UNIT_LEVEL" or event == "UNIT_NAME_UPDATE" then
		if arg1 == frame.unit then
			UnitFrames:UpdateInfo(frame)
		end
	elseif event == "DISPLAY_SIZE_CHANGED" then
		Update(frame)
	elseif event == "UNIT_MODEL_CHANGED" then
		if arg1 == frame.unit then
			-- if frame.model then frame.model:RefreshUnit() end
			UnitFrames:UpdateModel(frame)
		end
	elseif event == "UNIT_FACTION" then
		if arg1 == frame.unit then
			UnitFrames:UpdatePVPStatus(frame)
		end
	elseif event == "PLAYER_ENTER_COMBAT" then
		frame.inCombat = 1
		UpdateStatus(frame)
	elseif event == "PLAYER_LEAVE_COMBAT" then
		frame.inCombat = nil
		UpdateStatus(frame)
	elseif event == "PLAYER_REGEN_DISABLED" then
		frame.onHateList = 1
		UpdateStatus(frame)
	elseif event == "PLAYER_REGEN_ENABLED" then
		frame.onHateList = nil
		UpdateStatus(frame)
	elseif event == "PLAYER_TARGET_CHANGED" then
		UnitFrames:ShowHideHighlight(frame)
	elseif event == "PLAYER_UPDATE_RESTING" then
		UpdateStatus(frame)
	elseif event == "PLAYTIME_CHANGED" then
		UpdatePlaytime(frame.playTime)
	elseif event == "GROUP_ROSTER_UPDATE" then
		UnitFrames:UpdateInfo(frame)
	elseif event == "PARTY_LEADER_CHANGED" then
		UnitFrames:UpdatePartyLeader(frame)
	elseif event == "PLAYER_ROLES_ASSIGNED" then
		UnitFrames:UpdatePartyLeader(frame)
		UnitFrames:UpdateRoles(frame)
		UnitFrames:UpdateLoot(frame)
	elseif event == "PARTY_LOOT_METHOD_CHANGED" then
		UnitFrames:UpdateLoot(frame)
	elseif event == "RAID_TARGET_UPDATE" then
		UnitFrames:UpdateRaidIcon(frame)
	elseif  event == "READY_CHECK" or event == "READY_CHECK_CONFIRM" then
        UnitFrames:UpdateReadyCheck(frame.unit, frame.readyCheck)
    elseif ( event == "READY_CHECK_FINISHED" ) then
        ReadyCheck_Finish(frame.readyCheck, DEFAULT_READY_CHECK_STAY_TIME)
	elseif event == "UI_SCALE_CHANGED" then
		if frame.model then frame.model:RefreshUnit() end
	elseif event == "UNIT_COMBAT" then
		if arg1 == frame.unit then
			CombatFeedback_OnEvent(frame.feedback, arg2, arg3, arg4, arg5)
		end
	end
end

local GetWatchedFactionInfo = _G.GetWatchedFactionInfo or function()
	local info = C_Reputation and C_Reputation.GetWatchedFactionData() or {}
	return info.name or nil,
	info.reaction or 0,
	info.currentReactionThreshold or 0,
	info.nextReactionThreshold or 0,
	info.currentStanding or 0,
	info.factionID or 0
end

function module:RepBar_Update(frame)
	local factionName, standingID, barMin, barMax, barValue, factionID = GetWatchedFactionInfo()
	local currValue, maxValue = 0, 0
	local r, g, b = addon:UnpackColorTable(FACTION_BAR_COLORS[standingID] or FACTION_BAR_COLORS[4])
	local text = ""

	if factionName then
		local isMajorFaction = C_Reputation and C_Reputation.IsMajorFaction and C_Reputation.IsMajorFaction(factionID) or nil
		local friendshipInfo = C_GossipInfo and C_GossipInfo.GetFriendshipReputation and C_GossipInfo.GetFriendshipReputation(factionID) or nil
		local paragonID = C_Reputation and C_Reputation.IsFactionParagon and C_Reputation.IsFactionParagon(factionID) or nil
		local standingText = standingID and _G["FACTION_STANDING_LABEL"..standingID] or ""
		local isCapped = standingID and standingID == MAX_REPUTATION_REACTION

		if friendshipInfo and friendshipInfo.friendshipFactionID  > 0 then
			if friendshipInfo.nextThreshold then
				barMin, barMax, barValue = friendshipInfo.reactionThreshold, friendshipInfo.nextThreshold, friendshipInfo.standing
			else
				barMin, barMax, barValue = 0, 1, 1
				isCapped = true
			end

			standingText = friendshipInfo.reaction
			if not standingID then
				r, g, b = addon:UnpackColorTable(FACTION_BAR_COLORS[5])
			end
		end

		if isMajorFaction then
			local majorFactionInfo = C_MajorFactions.GetMajorFactionData(factionID)
			barMin, barMax = 0, majorFactionInfo.renownLevelThreshold
			isCapped = C_MajorFactions.HasMaximumRenown(factionID);
			barValue = isCapped and majorFactionInfo.renownLevelThreshold or majorFactionInfo.renownReputationEarned or 0
			standingText = RENOWN_LEVEL_LABEL:format(majorFactionInfo.renownLevel)
			r, g, b = addon:UnpackColorTable(BLUE_FONT_COLOR)
		end

		if paragonID and isCapped then
			local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
			barMin, barMax = 0, threshold
			barValue = currentValue % threshold

			if hasRewardPending then
				barValue = barValue + threshold
			end

			r, g, b = 0, .5 ,.9
		end

		currValue = barValue  - barMin
		maxValue = barMax - barMin

		if currValue == 0 and maxValue == 0 then
			currValue = 1
			maxValue = 1
		end

		if self.db.shortenFactionRepName then
			factionName = factionName:gsub("[A-Za-z']*%s?", function(s)
				return s:sub(0,1)
			end)
		end

		if self.db.shortenStandingRepName then
			standingText = standingText:gsub("[A-Za-z']*%s?", function(s)
				return s:sub(0,1)
			end)
		end

		if currValue == maxValue then
			text = UnitFrames:GetTextFormat("maxReputation", frame:GetParent())
		else
			text = UnitFrames:GetTextFormat("reputation", frame:GetParent())
		end

		text = text:gsub("$cur", addon:CommaNumber(currValue))
		text = text:gsub("$max", addon:FormatNumber(maxValue))
		text = text:gsub("$faction", factionName)
		text = text:gsub("$standing", standingText)
		text = text:gsub("$perc", UnitFrames:FormatPercentage(currValue / maxValue*100, true))

	end
	frame:SetMinMaxValues(0, maxValue)
	frame:SetStatusBarColor(r, g, b)
	frame.bg:SetVertexColor(r, g, b, frame.bg:GetAlpha())
	frame:SetValue(currValue)
	frame.text:SetText(text)
	frame:Show()
end

local function RepBar_OnEvent(frame)
	module:RepBar_Update(frame)
end

local function RepBar_OnLoad(frame)
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("UPDATE_FACTION")
	frame:RegisterEvent("QUEST_LOG_UPDATE")
	if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then
		frame:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
	end
	frame:SetScript("OnEvent", RepBar_OnEvent)
end

function module:XPbar_Update(frame)
	local XPDisabled = IsXPUserDisabled and IsXPUserDisabled()
	local maxLevel = (IsTrialAccount() or IsVeteranTrialAccount()) and GetRestrictedAccountData() or GetMaxPlayerLevel()
	local currValue, maxValue = 0, 0
	local r, g, b = 0.58, 0.0, 0.55
	local text = ""

	if UnitLevel(frame.unit) < maxLevel and not XPDisabled then
		text = UnitFrames:GetTextFormat("xp", frame:GetParent())

		if GetRestState() == 1 then
			r, g, b = 0.0, 0.39, 0.88
		end

		currValue, maxValue = UnitXP(frame.unit), UnitXPMax(frame.unit)

		text = text:gsub("$cur", addon:CommaNumber(currValue))
		text = text:gsub("$max", addon:FormatNumber(maxValue))
		text = text:gsub("$perc", UnitFrames:FormatPercentage(currValue / (maxValue > 0 and maxValue or 1)*100, true))

		local rest = GetXPExhaustion() or 0 -- Sometimes GetXPExhaustion() returns nil

		if rest > 0 then
			text = text:gsub("$rest", addon:FormatNumber(rest))
		else
			text = text:gsub("%S*$rest%S*%s?", "")
		end
	end

	frame:SetMinMaxValues(0, maxValue)
	frame:SetStatusBarColor(r, g, b)
	frame.bg:SetVertexColor(r, g, b, frame.bg:GetAlpha())
	frame:SetValue(currValue)
	frame.text:SetText(text)
	frame:Show()
end

local function XPbar_OnEvent(frame,event,...)
	if not frame:GetParent().isEnabled then return end
	module:XPbar_Update(frame)
end

local function XPbar_OnLoad(frame)
	frame.unit = unit

	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("UPDATE_EXHAUSTION")
	frame:RegisterEvent("PLAYER_XP_UPDATE")
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:SetScript("OnEvent", XPbar_OnEvent)
end

local function AdditionalPowerBar_OnLoad(frame)
	local _, classFileName = UnitClass(unit)
	if classFileName == "DRUID" or classFileName == "SHAMAN" or classFileName == "PRIEST" or ( addon.WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_MISTS_OF_PANDARIA_CLASSIC and classFileName =="MONK" ) then
		local statusbar
		if frame.statusbar then
			statusbar = frame.statusbar
			statusbar.isChild = true
		else
			statusbar = frame
		end

		statusbar.powerType = Enum.PowerType.Mana

		if classFileName =="MONK" then
			statusbar.specRestriction = SPEC_MONK_MISTWEAVER;
		end

		statusbar.updateFunc = function(self)
			local f
			if self.isChild then
				f = self:GetParent()
			else
				f = self
			end
			if UnitPowerType(self.unit) ~= statusbar.powerType and UnitPowerMax(self.unit, statusbar.powerType) ~= 0 and (not statusbar.specRestriction or statusbar.specRestriction == C_SpecializationInfo.GetSpecialization()) then
				statusbar.pauseUpdates = false
				f:Show()
		
			else
				statusbar.pauseUpdates = true
				f:Hide()
			end
		end
		UnitFrames:PowerBar_OnLoad(statusbar, unit)
		UnitFrames:PowerBar_Update(statusbar)
		-- statusbar:updateFunc()
	end
end

local function EbonMightBar_ShouldShowOverFlow(statusbar, active)
	local areVisualsActive = statusbar.overflowCap:IsShown() or statusbar.overflowAnim:IsPlaying();
	if areVisualsActive == active then
		return;
	end

	if active then
		statusbar.overflowFill:Show()
		statusbar.overflowCap:Show()
		statusbar.overflowAnim:Restart()
	else
		statusbar.overflowFill:Hide()
		statusbar.overflowCap:Hide()
		statusbar.overflowAnim:Stop()
	end
end

local function EbonMightBar_OnUpdate(frame, elapsed)
	if frame.pauseUpdates then return end
	local currValue = frame.auraExpirationTime and frame.auraExpirationTime - GetTime() or 0

	currValue = currValue >= 0 and currValue or 0
	frame.statusbar:SetValue(currValue)

	local text = frame.statusbar:GetValue() > 0 and string.format("%.1f",frame.statusbar:GetValue()) or ""

	frame.statusbar.text1:SetText(text)

	EbonMightBar_ShouldShowOverFlow(frame.statusbar, currValue > frame.maxPower )
end

local function EbonMightBar_Update(frame)
	if GetSpecialization() == SPEC_EVOKER_AUGMENTATION then
		frame:Show()
		frame.pauseUpdates = false
	else
		frame.pauseUpdates = true
		frame:Hide()
	end
end

local function EbonMightBar_OnEvent(frame, event, ...)
	if event == "PLAYER_SPECIALIZATION_CHANGED" then
		EbonMightBar_Update(frame)
	elseif event == "UNIT_AURA" and not frame.pauseUpdates then

		local _, auraUpdateInfo = ...
		local isUpdatePopulated = auraUpdateInfo.isFullUpdate
		or (auraUpdateInfo.addedAuras ~= nil and #auraUpdateInfo.addedAuras > 0)
		or (auraUpdateInfo.removedAuraInstanceIDs ~= nil and #auraUpdateInfo.removedAuraInstanceIDs > 0)
		or (auraUpdateInfo.updatedAuraInstanceIDs ~= nil and #auraUpdateInfo.updatedAuraInstanceIDs > 0)

		if isUpdatePopulated then
			local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(frame.spellId)
			local auraExpirationTime = auraInfo and auraInfo.expirationTime or nil;
			if auraExpirationTime ~= frame.auraExpirationTime then
				frame.auraExpirationTime = auraExpirationTime
			end
		end
	end
end

local function EbonMightBar_Init(parent, relativeTo, relativePoint, xOffset, yOffset)
	local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	frame:SetSize(130, 15)
	frame:Hide()
	frame:SetFrameStrata("LOW")
	frame:SetPoint(relativeTo, parent, relativePoint, xOffset, yOffset)

	frame:SetBackdrop({
		bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		tile = true,
		tileEdge = true,
		tileSize = 16,
		edgeSize = 8,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	frame:SetBackdropColor(0, 0, 0, 0.75)

	frame.artInfo = PowerBarColor["EBON_MIGHT"];
	frame.spellId = 395296
	frame.maxPower = 20

	local statusbar = CreateFrame("StatusBar", nil, frame, "TextStatusBar")
	statusbar:SetSize(124, 9)
	statusbar:SetFrameStrata("LOW")
	statusbar:SetPoint("CENTER", frame, "CENTER", 0, 0)
	statusbar:SetStatusBarTexture(frame.artInfo.atlas)
	statusbar:GetStatusBarTexture():SetTexelSnappingBias(0);
	statusbar:GetStatusBarTexture():SetSnapToPixelGrid(false);
	statusbar:SetMinMaxValues(0, frame.maxPower)

	statusbar.bg = statusbar:CreateTexture(nil, "BACKGROUND")
	statusbar.bg:SetTexture([[Interface\AddOns\Nurfed\Images\statusbar5]])
	statusbar.bg:SetVertexColor(0, 0, 0, 0.25)
	statusbar.bg:SetAllPoints()

	statusbar.text1 = statusbar:CreateFontString(nil, "OVERLAY", "Nurfed_UnitFontShadow")
	statusbar.text1:SetPoint("RIGHT", statusbar)

	local powerMaskAtlas = "UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Mask"
	local atlasInfo = C_Texture.GetAtlasInfo(powerMaskAtlas)
	local powerMask = statusbar:CreateMaskTexture(nil, "OVERLAY", nil, 3)
	powerMask:SetPoint("TOPLEFT", statusbar, -2, 3)
	powerMask:SetSnapToPixelGrid(false)
	powerMask:SetTexelSnappingBias(0.0)
	powerMask:SetTexture(atlasInfo.file, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	powerMask:SetAtlas(powerMaskAtlas, true)
	statusbar:GetStatusBarTexture():AddMaskTexture(powerMask)

	local overflowFill = statusbar:CreateTexture(nil, "OVERLAY",nil, 1)
	overflowFill:SetAtlas("Unit_Evoker_EbonMight_Highlight")
	overflowFill:SetSize(126, 10)
	overflowFill:SetPoint("RIGHT", statusbar, "LEFT", 0, 0)
	overflowFill:SetBlendMode("BLEND")
	overflowFill:SetSnapToPixelGrid(false)
	overflowFill:SetTexelSnappingBias(0.0)
	overflowFill:AddMaskTexture(powerMask)
	overflowFill:Hide()

	statusbar.overflowFill = overflowFill

	local overflowCap = statusbar:CreateTexture(nil, "OVERLAY",nil, 1)
	overflowCap:SetAtlas("Unit_Evoker_EbonMight_EndCap")
	overflowCap:SetSize(10, 20)
	overflowCap:SetPoint("RIGHT", statusbar, 1, 0)
	overflowCap:SetBlendMode("BLEND")
	overflowCap:SetSnapToPixelGrid(false)
	overflowCap:SetTexelSnappingBias(0.0)
	overflowCap:Hide()

	statusbar.overflowCap = overflowCap

	local overflowAnim = statusbar:CreateAnimationGroup()
	overflowAnim:SetToFinalAlpha(true)

	local translationAnim = overflowAnim:CreateAnimation("Translation")
	translationAnim:SetChildKey("overflowFill")
	translationAnim:SetOffset(252, 0)
	translationAnim:SetDuration(.766)
	translationAnim:SetOrder(1)

	local alphaAnim1 = overflowAnim:CreateAnimation("Alpha")
	alphaAnim1:SetChildKey("overflowCap")
	alphaAnim1:SetFromAlpha(0)
	alphaAnim1:SetToAlpha(0)
	alphaAnim1:SetDuration(.1)
	alphaAnim1:SetOrder(1)

	local alphaAnim2 = overflowAnim:CreateAnimation("Alpha")
	alphaAnim2:SetChildKey("overflowCap")
	alphaAnim2:SetFromAlpha(0)
	alphaAnim2:SetToAlpha(1)
	alphaAnim2:SetDuration(.1)
	alphaAnim2:SetStartDelay(.5)
	alphaAnim2:SetOrder(1)

	statusbar.overflowAnim = overflowAnim

	frame.statusbar = statusbar

	frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", unit)
	frame:RegisterUnitEvent("UNIT_AURA", unit)

	EbonMightBar_Update(frame)

	frame:SetScript("OnEvent", EbonMightBar_OnEvent)
	frame:SetScript("OnUpdate", EbonMightBar_OnUpdate)

	return frame
end

local function StaggerBar_OnUpdate(frame, elapsed)
	if frame.pauseUpdates then return end

	local currValue, maxValue = UnitStagger(unit),  UnitHealthMax(unit)
	local percent = maxValue > 0 and currValue / maxValue or 0
	local staggerStateKey;

	if percent >= STAGGER_STATES.RED.threshold then
		staggerStateKey = STAGGER_STATES.RED.key;
	elseif percent >= STAGGER_STATES.YELLOW.threshold then
		staggerStateKey = STAGGER_STATES.YELLOW.key;
	else
		staggerStateKey = STAGGER_STATES.GREEN.key;
	end

	if frame.staggerStateKey ~= staggerStateKey then
		frame.staggerStateKey = staggerStateKey;
		frame.statusbar:SetStatusBarTexture(frame.artInfo[staggerStateKey].atlas)
	end

	frame.statusbar:SetMinMaxValues(0, maxValue)
	frame.statusbar:SetValue(currValue)
	local  text = UnitFrames:GetTextFormat("stagger", nil, moduleName)
	text = text:gsub("$cur", addon:FormatNumber(currValue, 100000))
	text = text:gsub("$max", addon:FormatNumber(maxValue))
	frame.statusbar.text1:SetText(text)
	frame.statusbar.text2:SetText(UnitFrames:FormatPercentage(percent * 100))
end

local function StaggerBar_Update(frame)
	if GetSpecialization() == SPEC_MONK_BREWMASTER then
		frame:Show()
		frame.pauseUpdates = false
	else
		frame.pauseUpdates = true
		frame:Hide()
	end
end

local function StaggerBar_OnEvent(frame, event, ...)
	StaggerBar_Update(frame)
end

local function StaggerBar_Init(parent, relativeTo, relativePoint, xOffset, yOffset)
	local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	frame:SetSize(130, 15)
	frame:Hide()
	frame:SetFrameStrata("LOW")
	frame:SetPoint(relativeTo, parent, relativePoint, xOffset, yOffset)

	frame:SetBackdrop({
		bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		tile = true,
		tileEdge = true,
		tileSize = 16,
		edgeSize = 8,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	frame:SetBackdropColor(0, 0, 0, 0.75)

	frame.artInfo = PowerBarColor["STAGGER"];

	local statusbar = CreateFrame("StatusBar", nil, frame, "TextStatusBar")
	statusbar:SetSize(124, 9)
	statusbar:SetFrameStrata("LOW")
	statusbar:SetPoint("CENTER", frame, "CENTER", 0, 0)
	statusbar:SetStatusBarTexture(frame.artInfo["green"].atlas)
	statusbar:GetStatusBarTexture():SetTexelSnappingBias(0);
	statusbar:GetStatusBarTexture():SetSnapToPixelGrid(false);

	statusbar.bg = statusbar:CreateTexture(nil, "BACKGROUND")
	statusbar.bg:SetTexture([[Interface\AddOns\Nurfed\Images\statusbar5]])
	statusbar.bg:SetVertexColor(0, 0, 0, 0.25)
	statusbar.bg:SetAllPoints()

	statusbar.text1 = statusbar:CreateFontString(nil, "OVERLAY", "Nurfed_UnitFontShadow")
	statusbar.text1:SetPoint("LEFT", statusbar)

	statusbar.text2 = statusbar:CreateFontString(nil, "OVERLAY", "Nurfed_UnitFontShadow")
	statusbar.text2:SetPoint("RIGHT", statusbar)

	statusbar.Spark = statusbar:CreateTexture(nil, "OVERLAY","TextStatusBarSparkTemplate" )
	statusbar:InitializeTextStatusBar()
	statusbar.Spark:SetVisuals(frame.artInfo.spark)

	local powerMaskAtlas = "UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Mask"
	local atlasInfo = C_Texture.GetAtlasInfo(powerMaskAtlas)
	local powerMask = statusbar:CreateMaskTexture(nil, "OVERLAY", nil, 3)
	powerMask:SetPoint("TOPLEFT", statusbar, -2, 3)
	powerMask:SetSnapToPixelGrid(false)
	powerMask:SetTexelSnappingBias(0.0)
	powerMask:SetTexture(atlasInfo.file, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	powerMask:SetAtlas(powerMaskAtlas, true)
	statusbar:GetStatusBarTexture():AddMaskTexture(powerMask)

	statusbar.Spark:AddMaskTexture(powerMask)
	statusbar:GetStatusBarTexture():AddMaskTexture(powerMask)

	frame.statusbar = statusbar

	frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", unit)

	StaggerBar_Update(frame)

	frame:SetScript("OnEvent", StaggerBar_OnEvent)
	frame:SetScript("OnUpdate", StaggerBar_OnUpdate)

	return frame
end

local function CreateClassResourceBar(parent, template, relativeTo, relativePoint, xOffset, yOffset)
	local frame =  CreateFrame("Frame", nil, parent, template)

	if frame.resourceBarMixin and frame.resourceBarMixin.Setup then
	--[[
		1. Template Nurfed_Class_Resource_Bar_Template will empty the these two keys: .class and .class. Instead, the keys .classFileName and .specialization will be used in invdiual templates.
		2. A copy of the table frame.resourceBarMixin, since all tables in lua are by reference. Need a new memory allocation, free of taint.
		3. Re-define the function frame.resourceBarMixin.Setup to remove this line: "PlayerFrame.classPowerBar = self;".

		May this last a long time!
	--]]

		-- Copy the table.
		frame.resourceBarMixin = CopyTable(frame.resourceBarMixin)

		-- Re-define the function.
		frame.resourceBarMixin.Setup = function(f)
			local _, class = UnitClass(unit)
			local spec = C_SpecializationInfo.GetSpecialization()
			local showBar = false

			if class == f.classFileName then
				if not f.specialization or spec == f.specialization then
					f:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
					f:RegisterEvent("PLAYER_ENTERING_WORLD")
					f:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit) -- The original had :RegisterEvent() here.
					showBar = true
				else
					f:UnregisterEvent("UNIT_POWER_FREQUENT")
					f:UnregisterEvent("PLAYER_ENTERING_WORLD")
					f:UnregisterEvent("UNIT_DISPLAYPOWER")
				end

				f:RegisterEvent("PLAYER_TALENT_UPDATE")
			end

			f:SetShown(showBar)
			return showBar
		end

		-- Re-run ClassResourceBarMixin:Setup(). This will also run frame.resourceBarMixin.Setup()
		frame:Setup()
	end

	frame:ClearAllPoints()
	frame:SetPoint(relativeTo, parent, relativePoint, xOffset, yOffset)
	frame:SetParent(parent)

	return frame
end

function module:ToggleClassResourceBars()
	if not (self.frame and self.frame.resourceBars) then return end
	if self.db.hideClassResourceBars then
		self.frame.resourceBars:Hide()
	else
		self.frame.resourceBars:Show()
	end
end

function module:ClassResourceBars()
	if not self.frame then return end

	local createNewBars = false

	if not self.frame.resourceBars then
		self.frame.resourceBars = CreateFrame("Frame",nil, self.frame)
		self.frame.resourceBars:SetAllPoints()
		self.frame.resourceBars.unit = "player"
		createNewBars = true
	end

	local resourceBars = self.frame.resourceBars
	local relativeTo = "TOP"
	local relativePoint = "BOTTOM"
	local xOffset = 0
	local yOffset =  0
	local _, classFileName = UnitClass(resourceBars.unit)

	if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE and createNewBars then
		if classFileName == "ROGUE" then
			resourceBars.comboPoints = CreateClassResourceBar(resourceBars, "Nurfed_Rogue_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset)

			local RogueComboPointsUpdatePosition = function()
				local maxPoints = UnitPowerMax(unit, Enum.PowerType.ComboPoints)
				resourceBars.comboPoints:SetPoint(relativeTo, resourceBars, relativePoint, xOffset + UnitPowerMax(unit, Enum.PowerType.ComboPoints) > 5 and ( 10 * (maxPoints - 5) ) or 0, yOffset)
			end

			RogueComboPointsUpdatePosition()

			self:SecureHook(resourceBars.comboPoints, "UpdateMaxPower", RogueComboPointsUpdatePosition)
		elseif classFileName == "DRUID" then
			resourceBars.comboPoints = CreateClassResourceBar(resourceBars, "Nurfed_Druid_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset)
		elseif classFileName == "MONK" then
			resourceBars.stagger = StaggerBar_Init(resourceBars, relativeTo, relativePoint, xOffset, yOffset)
			resourceBars.harmony = CreateClassResourceBar(resourceBars, "Nurfed_Monk_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset)
		elseif classFileName == "MAGE" then
			resourceBars.arcaneCharges = CreateClassResourceBar(resourceBars, "Nurfed_Mage_Arcane_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset)
			resourceBars.arcaneCharges:SetScale(0.9)
		elseif classFileName == "WARLOCK" then
			resourceBars.soulShards = CreateClassResourceBar(resourceBars, "Nurfed_Warlock_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset)
			resourceBars.soulShards:SetScale(0.9)
		elseif classFileName == "EVOKER" then
			resourceBars.essence = CreateClassResourceBar(resourceBars, "Nurfed_Evoker_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset+4)
			resourceBars.ebonMight = EbonMightBar_Init(resourceBars, relativeTo, relativePoint, xOffset, yOffset-16.5)
		elseif classFileName == "PALADIN" then
			resourceBars.holyPower = CreateClassResourceBar(resourceBars, "Nurfed_Paladin_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset + 9)
		elseif classFileName == "DEATHKNIGHT" then
			resourceBars.runes = CreateClassResourceBar(resourceBars, "Nurfed_DeathKnight_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset)
			resourceBars.runes:UpdateRunes(true)
		end

		if classFileName == "SHAMAN" then
			resourceBars.totems = CreateClassResourceBar(resourceBars, "Nurfed_TotemFrame_Horizontal_Template", relativeTo, relativePoint, xOffset, yOffset + 5)
		else
			resourceBars.totems = CreateClassResourceBar(resourceBars, "Nurfed_TotemFrame_Horizontal_Template", "BOTTOMLEFT", "TOPLEFT", -2, 3)
		end
	end

	-- Yoink! Let's hope nothing yoinks it back.
	if addon.WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_MISTS_OF_PANDARIA_CLASSIC then
		if classFileName == "DEATHKNIGHT" then
			RuneFrame:ClearAllPoints()
			RuneFrame:SetPoint(relativeTo, resourceBars, relativePoint, xOffset, yOffset)
			RuneFrame:SetParent(resourceBars)
		elseif classFileName == "WARLOCK" then
			WarlockPowerFrame:ClearAllPoints()
			WarlockPowerFrame:SetPoint(relativeTo, resourceBars, relativePoint, xOffset, yOffset)
			WarlockPowerFrame:SetParent(resourceBars)
		elseif classFileName == "DRUID" then
			EclipseBarFrame:ClearAllPoints()
			EclipseBarFrame:SetPoint(relativeTo, resourceBars, relativePoint, xOffset, yOffset)
			EclipseBarFrame:SetParent(resourceBars)
		elseif classFileName == "PALADIN" then
			PaladinPowerBar:ClearAllPoints()
			PaladinPowerBar:SetPoint(relativeTo, resourceBars, relativePoint, xOffset, yOffset + 6)
			PaladinPowerBar:SetParent(resourceBars)
		elseif classFileName == "MONK" then
			MonkHarmonyBar:ClearAllPoints()
			MonkHarmonyBar:SetPoint(relativeTo, resourceBars, relativePoint, xOffset, yOffset + 20)
			MonkHarmonyBar:SetParent(resourceBars)
			MonkHarmonyBar:SetFrameLevel(0)

			local MonkStaggerUpdatePosition = function()
				MonkStaggerBar:ClearAllPoints()
				MonkStaggerBar:SetPoint(relativeTo, resourceBars, relativePoint, xOffset, yOffset - 18)
				MonkStaggerBar:SetParent(resourceBars)
			end

			MonkStaggerUpdatePosition()

			self:SecureHook("AlternatePowerBar_SetLook", MonkStaggerUpdatePosition)
		end
	end
end

function module:DisableBlizzCastBar()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("DisableBlizzCastBar", self)
		return
	end

	if not self.db.disableBlizzCastBar then return end

	if PlayerCastingBarFrame then
		PlayerCastingBarFrame:SetParent(UnitFrames.UIhider)

		self:SecureHook(PlayerCastingBarFrame, "ApplySystemAnchor", function(frame)
			if not PlayerCastingBarFrame.attachedToPlayerFrame then
				if frame:IsVisible() then
					addon:DebugLog("UI~6~WARN~PlayerCastingBarFrame.ApplySystemAnchor: frame is visible.")
					UnitFrames:SetParent(frame, UnitFrames.UIhider)
				end
			end
		end)

		self:SecureHook(PlayerCastingBarFrame, "UpdateShownState", function(frame)
			if not PlayerCastingBarFrame.attachedToPlayerFrame then
				if frame:IsVisible() then
					addon:DebugLog("UI~6~WARN~PlayerCastingBarFrame.UpdateShownState: frame is visible.")
					UnitFrames:SetParent(frame, UnitFrames.UIhider)
				end
			end
		end)
	else
		CastingBarFrame:SetParent(UnitFrames.UIhider)
	end
end

function module:EnableBlizzCastBar()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("EnableBlizzCastBar", self)
		return
	end

	if PlayerCastingBarFrame then
		self:Unhook(PlayerCastingBarFrame, "ApplySystemAnchor")
		self:Unhook(PlayerCastingBarFrame, "UpdateShownState")
		PlayerCastingBarFrame:SetParent(PlayerCastingBarFrame.attachedToPlayerFrame and PlayerFrame or UIParent)
	else
		CastingBarFrame:SetParent(UIParent)
	end
end

function module:DisableBlizz()
	if PlayerFrame.ApplySystemAnchor then
		self:SecureHook(PlayerFrame, "ApplySystemAnchor", function(frame)
			if frame:IsVisible() then
				addon:DebugLog("UI~6~WARN~PlayerFrame.ApplySystemAnchor: frame is visible.")
				UnitFrames:SetParent(frame, UnitFrames.UIhider)
			end
		end)
	end
	PlayerFrame:SetParent(UnitFrames.UIhider)
	self:DisableBlizzCastBar()
end

function module:EnableBlizz()
	if PlayerFrame.ApplySystemAnchor then
		self:Unhook(PlayerFrame, "ApplySystemAnchor")
	end

	PlayerFrame:SetParent(UIParent)

	self:EnableBlizzCastBar()
end

function module:OnInitialize()
	-- Enable if we're supposed to be enabled
	if self.db and self.db.enabled and UnitFrames:IsEnabled() then
		self:Enable()
		if self.frame then
			UnitFrames:RunOnPlayerEnteringWorld(function()
				self:DisableBlizz()
				self:ClassResourceBars()
				self:ToggleClassResourceBars()
			end)
		end
	end
end

function module:OnEnable()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnEnable", self)
		addon:InfoMessage(string.format(addon.infoMessages.enableModuleInCombat, addon:WrapTextInColorCode(displayName, addon.colors.moduleName)))
		return
	end

	if not self.frame then
		self.frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent)
		if self.frame.xp then XPbar_OnLoad(self.frame.xp) end
		if self.frame.additionalPowerBar then AdditionalPowerBar_OnLoad(self.frame.additionalPowerBar) end
		if self.frame.reputation then RepBar_OnLoad(self.frame.reputation) end
	end

	if self.frame then
		UnitFrames:EnableFrame(self.frame)
		self.frame.inCombat = nil
		self.frame.onHateList = nil
		Update(self.frame)
		if self.frame.xp then
			self:XPbar_Update(self.frame.xp)
		end

		if self.frame.reputation then
			self:RepBar_Update(self.frame.reputation)
		end

		if UnitFrames:IsPlayerInWorld() then
			self:DisableBlizz()
			self:ClassResourceBars()
			self:ToggleClassResourceBars()
		end
	end
end

function module:OnDisable()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnDisable", self)
		addon:InfoMessage(string.format(addon.infoMessages.disableModuleInCombat, addon:WrapTextInColorCode(displayName, addon.colors.moduleName)))
		return
	end

	if addon.WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_MISTS_OF_PANDARIA_CLASSIC then
		local _, classFileName = UnitClass("player")

		if classFileName == "DEATHKNIGHT" then
			RuneFrame:ClearAllPoints()
			RuneFrame:SetPoint("TOP",PlayerFrame,"BOTTOM", 54, 34)
			RuneFrame:SetParent(PlayerFrame)
		elseif classFileName == "WARLOCK" then
			WarlockPowerFrame:ClearAllPoints()
			WarlockPowerFrame:SetPoint("TOP",PlayerFrame,"BOTTOM", 50, 34)
			WarlockPowerFrame:SetParent(PlayerFrame)
		elseif classFileName == "DRUID" then
			EclipseBarFrame:ClearAllPoints()
			EclipseBarFrame:SetPoint("TOP",PlayerFrame,"BOTTOM", 48, 40)
			EclipseBarFrame:SetParent(PlayerFrame)
		elseif classFileName == "PALADIN" then
			PaladinPowerBar:ClearAllPoints()
			PaladinPowerBar:SetPoint("TOP",PlayerFrame,"BOTTOM", 43, 39)
			PaladinPowerBar:SetParent(PlayerFrame)
		elseif classFileName == "MONK" then
			MonkHarmonyBar:ClearAllPoints()
			MonkHarmonyBar:SetPoint("TOP",PlayerFrame,"TOP", 49, -46)
			MonkHarmonyBar:SetParent(PlayerFrame)
			MonkHarmonyBar:SetFrameLevel(3)

			self:Unhook("AlternatePowerBar_SetLook")
			MonkStaggerBar:ClearAllPoints()
			MonkStaggerBar:SetPoint("BOTTOMLEFT",PlayerFrame,"BOTTOMLEFT", 118, 4)
			MonkStaggerBar:SetParent(PlayerFrame)
			AlternatePowerBar_SetLook(MonkStaggerBar)
		end
	end

	self:EnableBlizz()
	self:UnhookAll()

	UnitFrames:DisableFrame(self.frame)
end

function module:UpdateConfigs()
	if self.frame then

		Update(self.frame)

		if self.frame.xp then
			self:XPbar_Update(self.frame.xp)
		end

		if self.frame.reputation then
			self:RepBar_Update(self.frame.reputation)
		end

		if self.db.disableBlizzCastBar then
			self:DisableBlizzCastBar()
		else
			self:EnableBlizzCastBar()
		end

		self:ToggleClassResourceBars()
	end
end
