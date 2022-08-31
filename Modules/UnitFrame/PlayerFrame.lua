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
	formats = {
		infoline = "$level ($g)",
		xp = "$cur/$max ($rest)",
		azerite = "$cur/$max ($level)",
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
					get = function() return UnitFrames:GetTextFormat("name", module.frame) end,
					set = function(info, value) module.db.formats.name = value;UnitFrames:UpdateInfo(module.frame) end,
				},
				infoline = {
					order = 2,
					type = "input",
					name = "Infoline",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("infoline", module.frame) end,
					set = function(info, value) module.db.formats.infoline = value;UnitFrames:UpdateInfo(module.frame) end,
				},
				health = {
					order = 3,
					type = "input",
					name = "Health",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("health", module.frame) end,
					set = function(info, value) module.db.formats.health = value end,
				},
				power = {
					order = 4,
					type = "input",
					name = "Power",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("power", module.frame) end,
					set = function(info, value) module.db.formats.power = value end,
				},
				xp = {
					order = 5,
					type = "input",
					name = "Experience",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("xp", module.frame) end,
					set = function(info, value) module.db.formats.xp = value;module:XPbar_Update(module.frame.xp) end,
				},
				azerite = {
					order = 6,
					type = "input",
					name = "Azerite",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("azerite", module.frame) end,
					set = function(info, value) module.db.formats.azerite = value;module:AzeriteBar_Update(module.frame.azerite) end,
				},
			},
		},
		blizzCastBar = {
			order = 3,
			type = "toggle",
			name = "Disable Blizzard Castbar",
			get = function() return module.db.disableBlizzCastBar end,
			set = function(info, value) module.db.disableBlizzCastBar = value; if value == true then module:DisableBlizzCastBar() else module:EnableBlizzCastBar() end end,
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

function module:AzeriteBar_Update(frame)
	local currValue, maxValue, currLevel, r, g, b
	local text, perc = ""
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
 
	if not azeriteItemLocation then
		frame:Hide()
		return
	end
	
	currLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
	
	r, g, b = ARTIFACT_BAR_COLOR:GetRGB()
	
	frame:SetStatusBarColor(r, g, b)
	frame.bg:SetVertexColor(r, g, b, frame.bg:GetAlpha())
	if C_AzeriteItem.IsAzeriteItemAtMaxLevel() then
		frame:SetMinMaxValues(0,1)
		frame:SetValue(1)
		text = LEVEL.." "..currLevel
	else
		text = UnitFrames:GetTextFormat("azerite", frame:GetParent())
		perc = UnitFrames:GetTextFormat("perc", frame:GetParent())
		
		currValue, maxValue = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
		
		frame:SetMinMaxValues(0, maxValue)	
		frame:SetValue(currValue)

		text = text:gsub("$cur", addon:CommaNumber(currValue))
		text = text:gsub("$max", addon:FormatNumber(maxValue))
		text = text:gsub("$level", LEVEL.." "..currLevel)
		
		perc = perc:gsub("$perc", UnitFrames:FormatPercentage(currValue / maxValue*100))
	end
	
	frame.text:SetText(text)
	frame.perc:SetText(perc)
	frame:Show()
end

local function AzeriteBar_OnEvent(frame)
	module:AzeriteBar_Update(frame)
end

local function AzeriteBar_OnLoad(frame)
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
	frame:RegisterEvent("AZERITE_ITEM_POWER_LEVEL_CHANGED")
	
	frame:SetScript("OnEvent", AzeriteBar_OnEvent)
end

function module:XPbar_Update(frame)

	local unit = frame.unit
	local currValue, maxValue, rest, r, g, b
	local text, perc = ""
	local name, standingID, barMin, barMax, barValue, factionID = GetWatchedFactionInfo()
	local friendshipID = GetFriendshipReputation and GetFriendshipReputation(factionID) or nil

	-- text = frame:GetAttribute("textFormat")
	-- perc = frame:GetAttribute("percFormat")
	text = UnitFrames:GetTextFormat("xp", frame:GetParent())
	perc = UnitFrames:GetTextFormat("perc", frame:GetParent())
	if name then
		if friendshipID then
			local _, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
			if nextFriendThreshold then
				barMin, barMax, barValue = friendThreshold, nextFriendThreshold, friendRep
			else
				barMin, barMax, barValue = 0, 1, 1
			end
			standingID = 5
		end

		currValue = barValue  - barMin
		maxValue = barMax - barMin
		
		if currValue == 0 then
			currValue = 1
		end
		
		if maxValue == 0 then
			maxValue = 1
		end
		
		if FACTION_BAR_COLORS[standingID] then
			r, g, b = FACTION_BAR_COLORS[standingID].r, FACTION_BAR_COLORS[standingID].g, FACTION_BAR_COLORS[standingID].b
		-- else
			-- r, g, b = 1.0, 1.0, 1.0
		end
		
		if string.len(name) > 13 then
			name = name:gsub("[A-Za-z']*%s?", function(s) 
				return s:sub(0,1)
			end)
		end
		rest = name
	else
		-- -- GetMaxPlayerLevel()
		if UnitLevel(unit) == MAX_PLAYER_LEVEL or (IsXPUserDisabled and IsXPUserDisabled()) then
			frame:Hide()
			return
		end
		if GetRestState() == 1 then
			r, g, b = 0.0, 0.39, 0.88
		else
			r, g, b = 0.58, 0.0, 0.55
		end
		currValue, maxValue = UnitXP(unit), UnitXPMax(unit)
		rest = GetXPExhaustion()
		if rest then rest = addon:FormatNumber(rest) end
	end
	
	frame:SetMinMaxValues(0, maxValue)
	frame:SetStatusBarColor(r, g, b)
	frame.bg:SetVertexColor(r, g, b, frame.bg:GetAlpha())
	frame:SetValue(currValue)

	text = text:gsub("$cur", addon:CommaNumber(currValue))
	text = text:gsub("$max", addon:FormatNumber(maxValue))
	if rest then
		
		text = text:gsub("$rest", rest)
	else
		text = text:gsub("%S*$rest%S*%s?", "")
	end
	perc = perc:gsub("$perc", UnitFrames:FormatPercentage(currValue / maxValue*100))
	
	frame.text:SetText(text)
	frame.perc:SetText(perc)
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
    frame:RegisterEvent("PLAYER_XP_UPDATE")
    frame:RegisterEvent("UPDATE_EXHAUSTION")
    frame:RegisterEvent("PLAYER_LEVEL_UP")
    frame:RegisterEvent("UPDATE_FACTION")
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
	if self.db.disableBlizzCastBar then
		CastingBarFrame:SetScript("OnEvent", nil)
		CastingBarFrame:SetScript("OnUpdate", nil)
		CastingBarFrame:SetScript("OnShow", nil)
		CastingBarFrame:Hide()
	end
end

function module:EnableBlizzCastBar()
	CastingBarFrame:SetScript("OnEvent", CastingBarFrame_OnEvent)
	CastingBarFrame:SetScript("OnUpdate", CastingBarFrame_OnUpdate)
	CastingBarFrame:SetScript("OnShow", CastingBarFrame_OnShow)
end

local blizzFrame = {}

local function DisableBlizz()
	module:DisableBlizzCastBar()
	local frame = PlayerFrame
	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
	blizzFrame = {
			[1] = point,
			[2] = relativeTo:GetName(),
			[3] = relativePoint,
			[4] = xOfs,
			[5] = yOfs,
	}

	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", -500, 500)
	frame:SetScript("OnEvent", nil)
	frame:SetScript("OnUpdate", nil)
	frame:Hide()
end

local function EnableBlizz()
	module:EnableBlizzCastBar()
	local frame = PlayerFrame
	frame:SetScript("OnEvent", PlayerFrame_OnEvent)
	frame:SetScript("OnUpdate", PlayerFrame_OnUpdate)
	PlayerFrame_Update()
	UnitFrame_Update(PlayerFrame)
	frame:Show()

	local point, relativeTo, relativePoint, xOfs, yOfs = unpack(blizzFrame)
	frame:ClearAllPoints()
	frame:SetPoint(point, _G[relativeTo], relativePoint, xOfs, yOfs)
end

function module:OnInitialize()
	-- Enable if we're supposed to be enabled
	if self.db and self.db.enabled and UnitFrames:IsEnabled() then
		self:Enable()
	end
end

function module:OnEnable()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnEnable", module)
		addon:InfoMessage(string.format(addon.infoMessages.enableModuleInCombat, addon:WrapTextInColorCode(moduleName, addon.colors.moduleName)))
		return
	end
	DisableBlizz()
	if addon.WOW_PROJECT_ID ~= addon.WOW_PROJECT_ID_MAINLINE then
		self.options.args.formats.args.azerite = nil;
	end
	if not self.frame then
		self.frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent, PlayerFrameDropDown)
		if self.frame.xp then XPbar_OnLoad(self.frame.xp, unit) end
		if self.frame.additionalPowerBar then AdditionalPowerBar_OnLoad(self.frame.additionalPowerBar, unit) end
		if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE and self.frame.azerite then 
			AzeriteBar_OnLoad(self.frame.azerite)
		else
			self.frame.health:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -5, 25)
			self.frame.powerBar:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -5, 14)
			self.frame:SetHeight(59)
			self.frame.overlay:SetHeight(90)
		end
	end
	
	if self.frame then
		UnitFrames:EnableFrame(self.frame)
		self.frame.inCombat = nil
		self.frame.onHateList = nil
		Update(self.frame)

		if self.frame.xp then
			module:XPbar_Update(self.frame.xp)
		end
		
		if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE and self.frame.azerite then 
			self:AzeriteBar_Update(self.frame.azerite)
		end
	end
end

function module:OnDisable()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnDisable", module)
		addon:InfoMessage(string.format(addon.infoMessages.disableModuleInCombat, addon:WrapTextInColorCode(moduleName, addon.colors.moduleName)))
		return
	end
	EnableBlizz()
	UnitFrames:DisableFrame(module.frame)
end
