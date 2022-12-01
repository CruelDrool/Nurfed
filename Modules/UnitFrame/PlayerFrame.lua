local addonName = ...
local moduleName = "PlayerFrame"
local displayName = moduleName
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local UnitFrames = addon:GetModule("UnitFrames")
local module = UnitFrames:NewModule(moduleName)
local unit = "player"

module.defaults = {
	enabled = true,
	disableBlizzCastBar = true,
	shortenFactionRepName = false,
	shortenStandingRepName = false,
	formats = {
		infoline = "$level ($g)",
		xp = "$cur/$max ($rest) $perc",
		reputation = "$cur/$max - $faction ($standing) $perc",
		maxReputation = "$faction ($standing)",
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
			set = function() if UnitFrames:IsEnabled() then if module.db.enabled then module:Disable() else module:Enable() end end; if module.db.enabled then module.db.enabled = false else module.db.enabled = true end end,
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
					set = function(info, value) module.db.formats.maxReputation = value;if module.frame then module:RepBar_Update(module.frame.maxReputation) end end,
				},
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
		blizzCastBar = CastingBarFrame and {
			order = 5,
			type = "toggle",
			name = "Disable Blizzard Castbar",
			get = function() return module.db.disableBlizzCastBar end,
			set = function(info, value) module.db.disableBlizzCastBar = value; if value == true and module.db.enabled and UnitFrames:IsEnabled() then module:DisableBlizzCastBar() else module:EnableBlizzCastBar() end end,
		} or nil,
	},
}

local events = {
	-- "UNIT_COMBAT",
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
		
	if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
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

local function OnEvent(frame, event, ...)

	if not frame.isEnabled then return end
	
	local arg1, arg2, arg3, arg4, arg5 = ...
	if event == "PLAYER_ENTERING_WORLD" then
	    frame.inCombat = nil;
        frame.onHateList = nil;
		Update(frame)
		module:DisableBlizz()
	elseif event == "UNIT_LEVEL" or event == "UNIT_NAME_UPDATE" then
		if arg1 == frame.unit then
			UnitFrames:UpdateInfo(frame)
		end
	elseif event == "DISPLAY_SIZE_CHANGED" then
		Update(frame)
	elseif event == "UNIT_MODEL_CHANGED" then
		if arg1 == frame.unit then
			-- if frame.model then frame.model:RefreshUnit() end
			if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
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
	end
end

function module:RepBar_Update(frame)
	local factionName, standingID, barMin, barMax, barValue, factionID = GetWatchedFactionInfo()
	local currValue, maxValue = 0, 0
	local r, g, b = addon:UnpackColorTable(FACTION_BAR_COLORS[standingID] or FACTION_BAR_COLORS[4])
	local text = ""

	if factionName then
		local isMajorFaction = C_Reputation and C_Reputation.IsMajorFaction and C_Reputation.IsMajorFaction(factionID)
		local friendshipInfo = C_GossipInfo and C_GossipInfo.GetFriendshipReputation and C_GossipInfo.GetFriendshipReputation(factionID) or nil
		local paragonID = C_Reputation and C_Reputation.IsFactionParagon and C_Reputation.IsFactionParagon(factionID) or nil
		local standingText = _G["FACTION_STANDING_LABEL"..standingID]

		if friendshipInfo and friendshipInfo.friendshipFactionID  > 0 then
			if friendshipInfo.nextThreshold then
				barMin, barMax, barValue = friendshipInfo.reactionThreshold, friendshipInfo.nextThreshold, friendshipInfo.standing
			else
				barMin, barMax, barValue = 0, 1, 1
			end

			standingText = friendshipInfo.reaction
			if not standingID then
				r, g, b = addon:UnpackColorTable(FACTION_BAR_COLORS[5])
			end
		end

		if paragonID then
			local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
			barMin, barMax = 0, threshold
			barValue = currentValue % threshold

			if hasRewardPending then
				barValue = barValue + threshold
			end

			r, g, b = 0, .5 ,.9
		end

		if isMajorFaction then
			local majorFactionInfo = C_MajorFactions.GetMajorFactionData(factionID)
			barMin, barMax = 0, majorFactionInfo.renownLevelThreshold
			barValue = isCapped and majorFactionInfo.renownLevelThreshold or majorFactionInfo.renownReputationEarned or 0
			standingText = RENOWN_LEVEL_LABEL .. majorFactionInfo.renownLevel
			r, g, b = addon:UnpackColorTable(BLUE_FONT_COLOR)
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
		text = text:gsub("$perc", UnitFrames:FormatPercentage(currValue / maxValue*100))

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
		text = text:gsub("$perc", UnitFrames:FormatPercentage(currValue / (maxValue > 0 and maxValue or 1)*100))

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

local function XPbar_OnLoad(frame, unit)
	if not frame.unit then
		if unit then
			frame.unit = unit
		elseif not unit and frame:GetParent().unit then
			frame.unit = frame:GetParent().unit
		else
			return
		end
	end

	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("UPDATE_EXHAUSTION")
	frame:RegisterEvent("PLAYER_XP_UPDATE")
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:SetScript("OnEvent", XPbar_OnEvent)
end


local function AdditionalPowerBar_OnLoad(frame, unit)
	local _, class = UnitClass(unit)
	if class == "DRUID" or class == "SHAMAN" or class == "PRIEST" then
		local statusbar
		if frame.statusbar then
			statusbar = frame.statusbar
			statusbar.isChild = true
		else
			statusbar = frame
		end

		statusbar.powerType = 0 -- ADDITIONAL_POWER_BAR_INDEX only defined in Retail
		statusbar.updateFunc = function(statusbar)
			local unit = statusbar.unit
			local frame
			if statusbar.isChild then
				frame = statusbar:GetParent()
			else
				frame = statusbar
			end
			if UnitPowerType(unit) ~= statusbar.powerType and UnitPowerMax(unit, statusbar.powerType) ~= 0 and (not statusbar.specRestriction or statusbar.specRestriction == GetSpecialization()) then
				statusbar.pauseUpdates = false
				frame:Show()
		
			else
				statusbar.pauseUpdates = true
				frame:Hide()
			end
		end
		
		UnitFrames:PowerBar_OnLoad(statusbar, unit)
		UnitFrames:PowerBar_Update(statusbar)
	end
end


function module:DisableBlizzCastBar()
	if self.db.disableBlizzCastBar and CastingBarFrame then
		CastingBarFrame:SetScript("OnEvent", nil)
		CastingBarFrame:SetScript("OnUpdate", nil)
		CastingBarFrame:SetScript("OnShow", nil)
		CastingBarFrame:Hide()
	end
end

function module:EnableBlizzCastBar()
	if CastingBarFrame and CastingBarFrame then
		CastingBarFrame:SetScript("OnEvent", CastingBarFrame_OnEvent)
		CastingBarFrame:SetScript("OnUpdate", CastingBarFrame_OnUpdate)
		CastingBarFrame:SetScript("OnShow", CastingBarFrame_OnShow)
	end
end

local blizzFrame = {}

function module:DisableBlizz()
	if #blizzFrame > 0 then return end

	self:DisableBlizzCastBar()

	local frame = PlayerFrame
	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()

	if not point then return end

	blizzFrame = {
			[1] = point,
			[2] = "",
			[3] = relativePoint,
			[4] = xOfs,
			[5] = yOfs,
			[6] = frame:IsClampedToScreen()
	}

	frame:SetClampedToScreen(false)
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", -500, 500)
	frame:SetScript("OnEvent", nil)
	frame:SetScript("OnUpdate", nil)
	frame:Hide()
end

function module:EnableBlizz()
	if #blizzFrame == 0 then return end
	self:EnableBlizzCastBar()
	local frame = PlayerFrame
	frame:SetScript("OnEvent", PlayerFrame_OnEvent)
	frame:SetScript("OnUpdate", PlayerFrame_OnUpdate)
	PlayerFrame_Update()
	UnitFrame_Update(PlayerFrame)
	frame:Show()

	local point, _, relativePoint, xOfs, yOfs, IsClampedToScreen = unpack(blizzFrame)
	frame:ClearAllPoints()
	frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
	frame:SetClampedToScreen(IsClampedToScreen)

	blizzFrame = {}
end

function module:OnEnable()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnEnable", module)
		addon:InfoMessage(string.format(addon.infoMessages.enableModuleInCombat, addon:WrapTextInColorCode(moduleName, addon.colors.moduleName)))
		return
	end

	self:DisableBlizz()

	if not self.frame then
		self.frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent, PlayerFrameDropDown)
		if self.frame.xp then XPbar_OnLoad(self.frame.xp, unit) end
		if self.frame.additionalPowerBar then AdditionalPowerBar_OnLoad(self.frame.additionalPowerBar, unit) end
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
	end
end

function module:OnDisable()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnDisable", module)
		addon:InfoMessage(string.format(addon.infoMessages.disableModuleInCombat, addon:WrapTextInColorCode(moduleName, addon.colors.moduleName)))
		return
	end
	self:EnableBlizz()
	UnitFrames:DisableFrame(module.frame)
end
