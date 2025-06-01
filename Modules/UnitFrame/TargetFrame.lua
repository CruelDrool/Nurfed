local addonName = ...
local moduleName = "TargetFrame"
local displayName = moduleName
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local UnitFrames = addon:GetModule("UnitFrames")
local module = UnitFrames:NewModule(moduleName, "AceHook-3.0")
local unit = "target"

module.defaults = {
	enabled = true,
	formats = {
		name = "$name $guild",
		-- infoline = "$level $class ($group)",
	},
	frames = {
		[unit] = {
			["x"] = 107,
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
				threat = {
					order = 5,
					type = "input",
					name = "Threat",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("threat", nil, moduleName) end,
					set = function(info, value) module.db.formats.threat = value;if module.frame then UnitFrames:ThreatBar_Update(module.frame.threat) end end,
				},
			},
		},
	},
}

local events = {
	"UNIT_POWER_UPDATE",
	"PLAYER_ENTERING_WORLD",
	"PARTY_LOOT_METHOD_CHANGED",
	"PLAYER_ROLES_ASSIGNED",
	"PLAYER_TARGET_CHANGED",
	-- "PLAYER_FLAGS_CHANGED",
	"UI_SCALE_CHANGED",
	"UNIT_TARGETABLE_CHANGED",
	"UNIT_AURA",
	"UNIT_CLASSIFICATION_CHANGED",
	"UNIT_LEVEL",
	"UNIT_FACTION",
	"UNIT_MODEL_CHANGED",
	"UNIT_NAME_UPDATE",
	"PARTY_LEADER_CHANGED",
	"GROUP_ROSTER_UPDATE",
	"RAID_TARGET_UPDATE",
	"DISPLAY_SIZE_CHANGED",
	"READY_CHECK",
    "READY_CHECK_CONFIRM",
    "READY_CHECK_FINISHED",
    "CVAR_UPDATE",
}

local function UpdateCombo(frame)
	if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then return end
	-- local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints) -- for later, perhaps.

	local comboPoints = GetComboPoints("player", unit)
	local maxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
	-- local r, g, b
	-- local parent = frame:GetParent()
	if comboPoints > 0 then
		-- if comboPoints == 5 then
			-- r, g, b = 1, 0, 0
		-- elseif comboPoints == 4 then
			-- r, g, b = 1, 0.5, 0
		-- elseif comboPoints == 3 then
			-- r, g, b = 1, 1, 0
		-- elseif comboPoints == 2 then
			-- r, g, b = 0.5, 1, 0
		-- elseif comboPoints == 1 then
			-- r, g, b = 0, 0.5, 0
		-- end

		local perc = comboPoints / maxComboPoints
		local r1, g1, b1
		local r2, g2, b2
		if perc <= 0.5 then
			perc = perc * 2
			r1, g1, b1 = 0, 0.5, 0
			r2, g2, b2 = 1, 1, 0
		else
			perc = perc * 2 - 1
			r1, g1, b1 = 1, 1, 0
			r2, g2, b2 = 1, 0, 0
		end

		local r, g, b = r1 + (r2-r1)*perc, g1 + (g2-g1)*perc, b1 + (b2-b1)*perc




		frame:SetTextColor(r, g, b)
		frame:SetText(comboPoints)
		frame:Show()
		-- parent:SetBackdropBorderColor(r,g,b)
	else
		-- parent:SetBackdropBorderColor(1,1,1)
		frame:Hide()
	end
end

function UpdateQuestionIcon(frame)
	if (UnitIsQuestBoss and UnitIsQuestBoss(frame.unit)) then
		frame.questIcon:Show()
	else
		frame.questIcon:Hide()
	end
end

local function Update(frame)
	UnitFrames:PowerBar_Update(frame.powerBar, frame.unit)
	UnitFrames:HealthBar_Update(frame.health)
	if frame.threat then UnitFrames:ThreatBar_Update(frame.threat) end
	UnitFrames:UpdateModel(frame)
	if UnitExists(frame.unit) then
		-- UnitFrames:UpdateModel(frame)
		if frame.combo then UpdateCombo(frame.combo, frame.unit) end
		UnitFrames:UpdateLoot(frame)
		UnitFrames:UpdateReadyCheck(frame.unit, frame.readyCheck)
		UnitFrames:UpdateRaidIcon(frame)
		UnitFrames:UpdateInfo(frame)
		UnitFrames:UpdatePartyLeader(frame)
		UnitFrames:UpdateRoles(frame)
		UnitFrames:UpdatePVPStatus(frame)
		UnitFrames:UpdateAuras(frame)
		UpdateQuestionIcon(frame)
	end
end

local function OnEvent(frame, event, ...)

	if not frame.isEnabled then return end

	local arg1, arg2, arg3, arg4, arg5 = ...
	if event == "PLAYER_ENTERING_WORLD" then
		Update(frame)
	elseif event == "DISPLAY_SIZE_CHANGED" then
		Update(frame)
	elseif event == "PLAYER_TARGET_CHANGED" then
			Update(frame)
			if ( UnitExists(frame.unit) ) then
				if ( UnitIsEnemy(frame.unit, "player") ) then
					PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
				elseif ( UnitIsFriend("player", frame.unit) ) then
					PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT)
				else
					PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
				end
			end
	elseif event == "UNIT_POWER_UPDATE" then
		if arg1 == "player" then
			UpdateCombo(frame.combo)
		end
	elseif event == "UNIT_CLASSIFICATION_CHANGED" or event == "UNIT_LEVEL" or event == "UNIT_FACTION" or event == "UNIT_NAME_UPDATE" then
		if arg1 == frame.unit then
			UnitFrames:UpdateInfo(frame)
			if event == "UNIT_FACTION" then
				UnitFrames:UpdatePVPStatus(frame)
			end

			if event == "UNIT_CLASSIFICATION_CHANGED" then
				UpdateQuestionIcon(frame)
			end
		end
	elseif event == "UNIT_AURA" then
		if arg1 == frame.unit then
			UnitFrames:UpdateAuras(frame)
		end
	elseif event == "UNIT_TARGETABLE_CHANGED" then
		if arg1 == frame.unit then
			Update(frame)
			CloseDropDownMenus()
		end
	elseif event == "UNIT_MODEL_CHANGED" then
		if arg1 == frame.unit then
			UnitFrames:UpdateModel(frame)
		end
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
	elseif event == "CVAR_UPDATE" then
		-- if arg1 == "SHOW_ALL_ENEMY_DEBUFFS_TEXT" then
			-- GetCVar("NoBuffDebuffFilterOnTarget")
			-- /run SetCVar("NoBuffDebuffFilterOnTarget", 1)
			-- have to set uvar manually or it will be the previous value
			-- SHOW_ALL_ENEMY_DEBUFFS = GetCVar("showAllEnemyDebuffs")
			-- if ( frame:IsShown() ) then
				-- UnitFrames:UpdateAuras(frame)
			-- end
		-- end
	elseif event == "UI_SCALE_CHANGED" then
		UnitFrames:UpdateModel(frame)
	end
end

function module:DisableBlizz()
	if TargetFrame.ApplySystemAnchor then
		---@diagnostic disable-next-line: redefined-local
		self:SecureHook(TargetFrame, "ApplySystemAnchor", function(self)
			self:SetParent(UnitFrames.UIhider)
		end)
	end

	TargetFrame:SetParent(UnitFrames.UIhider)

	if ComboFrame and addon.WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_CLASSIC then
		ComboFrame:SetParent(UnitFrames.UIhider)
	end
end

function module:EnableBlizz()
	if TargetFrame.ApplySystemAnchor then
		self:Unhook(TargetFrame, "ApplySystemAnchor")
	end
	TargetFrame:SetParent(UIParent)
	if ComboFrame and addon.WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_CLASSIC then
		ComboFrame:SetParent(UIParent)
	end
end

function module:OnInitialize()
	-- Enable if we're supposed to be enabled
	if self.db and self.db.enabled and UnitFrames:IsEnabled() then
		self:Enable()
		if self.frame then
			UnitFrames:RunOnPlayerEnteringWorld("DisableBlizz", self)
		end
	end
end

function module:OnEnable()

	if not self.frame then
		if InCombatLockdown() then
			addon:AddOutOfCombatQueue("OnEnable", self)
			addon:InfoMessage(string.format(addon.infoMessages.enableModuleInCombat, addon:WrapTextInColorCode(moduleName, addon.colors.moduleName)))
			return
		end

		self.frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent, true)
	end

	if self.frame then
		UnitFrames:EnableFrame(self.frame)
		Update(self.frame)

		if UnitFrames:IsPlayerInWorld() then
			self:DisableBlizz()
		end
	end
end

function module:OnDisable()
	if not self.frame and InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnDisable", self)
		return
	end

	self:EnableBlizz()
	UnitFrames:DisableFrame(self.frame)
end