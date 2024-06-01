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
			standingText = RENOWN_LEVEL_LABEL .. majorFactionInfo.renownLevel
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
	if classFileName == "DRUID" or classFileName == "SHAMAN" or classFileName == "PRIEST" then
		local statusbar
		if frame.statusbar then
			statusbar = frame.statusbar
			statusbar.isChild = true
		else
			statusbar = frame
		end

		statusbar.powerType = Enum.PowerType.Mana
		statusbar.updateFunc = function(self)
			local f
			if self.isChild then
				f = self:GetParent()
			else
				f = self
			end
			if UnitPowerType(self.unit) ~= statusbar.powerType and UnitPowerMax(self.unit, statusbar.powerType) ~= 0 and (not statusbar.specRestriction or statusbar.specRestriction == GetSpecialization()) then
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

	local powerMask = statusbar:CreateMaskTexture(nil, "OVERLAY", nil, 3)
	powerMask:SetPoint("TOPLEFT", statusbar, -2, 3)
	powerMask:IsSnappingToPixelGrid(false)
	powerMask:SetTexelSnappingBias(0.0)
	powerMask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Mask", true)
	powerMask:SetTexture(powerMask:GetTexture(), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

	statusbar.Spark:AddMaskTexture(powerMask)
	statusbar:GetStatusBarTexture():AddMaskTexture(powerMask)

	frame.statusbar = statusbar

	frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")

	StaggerBar_Update(frame)

	frame:SetScript("OnEvent", StaggerBar_OnEvent)
	frame:SetScript("OnUpdate", StaggerBar_OnUpdate)

	return frame
end

local function CreateClassResourceBar(parent, template, relativeTo, relativePoint, xOffset, yOffset)
	local frame =  CreateFrame("Frame", nil, nil, "Nurfed_Class_Resource_Bar_Template, " .. template)
	frame:ClearAllPoints()
	frame:SetPoint(relativeTo, parent, relativePoint, xOffset, yOffset)
	frame:SetScript("OnShow", nil)
	frame:SetScript("OnHide", nil)
	frame:SetParent(parent)
	frame.isManagedFrame = false
	frame.isPlayerFrameBottomManagedFrame = false
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
	if self.frame.resourceBars then return end

	self.frame.resourceBars = CreateFrame("Frame",nil, self.frame)
	self.frame.resourceBars:SetAllPoints()
	self.frame.resourceBars.unit = unit

	local resourceBars = self.frame.resourceBars
	local relativeTo = "TOP"
	local relativePoint = "BOTTOM"
	local xOffset = 0
	local yOffset =  0

	local _, classFileName = UnitClass("player")
	if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then
		if classFileName == "ROGUE" then
			resourceBars.comboPoints = CreateClassResourceBar(resourceBars, "RogueComboPointBarTemplate", relativeTo, relativePoint, xOffset, yOffset)
		elseif classFileName == "DRUID" then
			resourceBars.comboPoints = CreateClassResourceBar(resourceBars, "DruidComboPointBarTemplate", relativeTo, relativePoint, xOffset, yOffset)
		elseif classFileName == "MONK" then
			resourceBars.stagger = StaggerBar_Init(resourceBars, relativeTo, relativePoint, xOffset, yOffset)
			resourceBars.harmony = CreateClassResourceBar(resourceBars, "Nurfed_Monk_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset)
		elseif classFileName == "MAGE" then
			resourceBars.arcaneCharges = CreateClassResourceBar(resourceBars, "Nurfed_Mage_Arcane_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset)
			resourceBars.arcaneCharges:SetScale(0.9)
		elseif classFileName == "WARLOCK" then
			resourceBars.soulShards = CreateClassResourceBar(resourceBars, "WarlockPowerFrameTemplate", relativeTo, relativePoint, xOffset, yOffset)
			resourceBars.soulShards:SetScale(0.9)
		elseif classFileName == "EVOKER" then
			resourceBars.essence = CreateClassResourceBar(resourceBars, "Nurfed_Evoker_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset)
		elseif classFileName == "PALADIN" then
			resourceBars.holyPower = CreateClassResourceBar(resourceBars, "Nurfed_Paladin_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset + 9)
		elseif classFileName == "DEATHKNIGHT" then
			resourceBars.runes = CreateClassResourceBar(resourceBars, "Nurfed_DeathKnight_Resource_Bar_Template", relativeTo, relativePoint, xOffset, yOffset)
		elseif classFileName == "SHAMAN" then
			resourceBars.totems = CreateClassResourceBar(resourceBars, "Nurfed_Shaman_TotemFrame_Template", "TOPLEFT", "BOTTOMLEFT", xOffset, yOffset + 5)
		end
	end

	-- Yoink! Let's hope nothing yoinks it back.
	if classFileName == "DEATHKNIGHT" and addon.WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_WRATH_OF_THE_LICH_KING_CLASSIC then
		RuneFrame:ClearAllPoints()
		RuneFrame:SetPoint(relativeTo, resourceBars, relativePoint, xOffset, yOffset)
		RuneFrame:SetParent(resourceBars )
	elseif addon.WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_CATACLYSM_CLASSIC then
		if classFileName == "WARLOCK" then
			ShardBarFrame:ClearAllPoints()
			ShardBarFrame:SetPoint(relativeTo, resourceBars, relativePoint, xOffset, yOffset)
			ShardBarFrame:SetParent(resourceBars )
		elseif classFileName == "DRUID" then
			EclipseBarFrame:ClearAllPoints()
			EclipseBarFrame:SetPoint(relativeTo, resourceBars, relativePoint, xOffset, yOffset)
			EclipseBarFrame:SetParent(resourceBars )
		elseif classFileName == "PALADIN" then
			PaladinPowerBar:ClearAllPoints()
			PaladinPowerBar:SetPoint(relativeTo, resourceBars, relativePoint, xOffset, yOffset + 6)
			PaladinPowerBar:SetParent(resourceBars )
		end
	end
end

function module:DisableBlizzCastBar()
	if not self.db.disableBlizzCastBar then return end
	if PlayerCastingBarFrame then
		PlayerCastingBarFrame:SetParent(UnitFrames.UIhider)

		---@diagnostic disable-next-line: redefined-local
		self:SecureHook(PlayerCastingBarFrame, "ApplySystemAnchor", function(self)
			if not PlayerCastingBarFrame.attachedToPlayerFrame then
				self:SetParent(UnitFrames.UIhider)
			end
		end)

		---@diagnostic disable-next-line: redefined-local
		self:SecureHook(PlayerCastingBarFrame, "UpdateShownState", function(self)
			if not PlayerCastingBarFrame.attachedToPlayerFrame then
				self:SetParent(UnitFrames.UIhider)
			end
		end)
	else
		CastingBarFrame:SetParent(UnitFrames.UIhider)
	end
end

function module:EnableBlizzCastBar()
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
		---@diagnostic disable-next-line: redefined-local
		self:SecureHook(PlayerFrame, "ApplySystemAnchor", function(self)
			self:SetParent(UnitFrames.UIhider)
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
		UnitFrames:RunOnPlayerEnteringWorld(function()
			self:DisableBlizz()
			self:ClassResourceBars()
			self:ToggleClassResourceBars()
		end)
	end
end

function module:OnEnable()

	if not self.frame then
		self.frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent, PlayerFrameDropDown)
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
	end

	if UnitFrames:IsPlayerInWorld() then
		self:DisableBlizz()
		self:ClassResourceBars()
		self:ToggleClassResourceBars()
	end
end

function module:OnDisable()
	local _, classFileName = UnitClass("player")

	if classFileName == "DEATHKNIGHT" and addon.WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_WRATH_OF_THE_LICH_KING_CLASSIC then
		RuneFrame:ClearAllPoints()
		RuneFrame:SetPoint("TOP",PlayerFrame,"BOTTOM", 54, 34)
		RuneFrame:SetParent(PlayerFrame)
	elseif addon.WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_CATACLYSM_CLASSIC then
		if classFileName == "WARLOCK" then
			ShardBarFrame:ClearAllPoints()
			ShardBarFrame:SetPoint("TOP",PlayerFrame,"BOTTOM", 50, 34)
			ShardBarFrame:SetParent(PlayerFrame)
		elseif classFileName == "DRUID" then
			EclipseBarFrame:ClearAllPoints()
			EclipseBarFrame:SetPoint("TOP",PlayerFrame,"BOTTOM", 48, 40)
			EclipseBarFrame:SetParent(PlayerFrame)
		elseif classFileName == "PALADIN" then
			PaladinPowerBar:ClearAllPoints()
			PaladinPowerBar:SetPoint("TOP",PlayerFrame,"BOTTOM", 43,39)
			PaladinPowerBar:SetParent(PlayerFrame)
		end
	end
	self:EnableBlizz()
	UnitFrames:DisableFrame(self.frame)
end
