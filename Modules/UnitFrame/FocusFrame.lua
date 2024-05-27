local addonName = ...
local moduleName = "FocusFrame"
local displayName = moduleName
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local UnitFrames = addon:GetModule("UnitFrames")
local module = UnitFrames:NewModule(moduleName, "AceHook-3.0")
local unit = "focus"

module.defaults = {
	enabled = true,
	formats = {
		name = "[$level] $name",
		infoline = "$class ($g)",	
	},

	frames = {
		[unit] = {
			["x"] = -88,
			["y"] = -130,
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
					get = function() return UnitFrames:GetTextFormat("power", nil, moduleName) end,
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
	"CVAR_UPDATE",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_FOCUS_CHANGED",
	"PARTY_LOOT_METHOD_CHANGED",
	"PLAYER_ROLES_ASSIGNED",
	"PLAYER_TARGET_CHANGED",
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
}

local function Update(frame)
	UnitFrames:PowerBar_Update(frame.powerBar, frame.unit)
	UnitFrames:HealthBar_Update(frame.health)
	if frame.threat then UnitFrames:ThreatBar_Update(frame.threat) end
	if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
	if UnitExists(frame.unit) then
		UnitFrames:UpdateLoot(frame)
		UnitFrames:UpdateReadyCheck(frame.unit, frame.readyCheck)
		UnitFrames:UpdateRaidIcon(frame)
		UnitFrames:UpdateInfo(frame)
		UnitFrames:UpdatePartyLeader(frame)
		UnitFrames:UpdateRaidIcon(frame)
		UnitFrames:UpdateRoles(frame)
		UnitFrames:UpdatePVPStatus(frame)
		UnitFrames:UpdateAuras(frame)
	end	
end

local function OnEvent(frame, event, ...)

	if not frame.isEnabled then return end

	local arg1, arg2, arg3, arg4, arg5 = ...
	if event == "PLAYER_ENTERING_WORLD" then
		Update(frame)
		module:DisableBlizz()
	elseif event == "DISPLAY_SIZE_CHANGED" then
		Update(frame)
	elseif event == "PLAYER_TARGET_CHANGED" then
		if UnitExists("target") and UnitIsUnit("target", frame.unit) then
			frame:LockHighlight()
		else
			frame:UnlockHighlight()
		end
	elseif event == "PLAYER_FOCUS_CHANGED" then
		Update(frame)
		if UnitExists("target") and UnitIsUnit("target", frame.unit) then
				frame:LockHighlight()
			else
				frame:UnlockHighlight()
		end
	elseif event == "UNIT_CLASSIFICATION_CHANGED" or event == "UNIT_LEVEL" or event == "UNIT_FACTION" or event == "UNIT_NAME_UPDATE" then
		if arg1 == frame.unit then
			UnitFrames:UpdateInfo(frame)
			if event == "UNIT_FACTION" then
				UnitFrames:UpdatePVPStatus(frame)
			end
		end
	elseif event == "UNIT_AURA" then
		if arg1 == frame.unit then
			UnitFrames:UpdateAuras(frame)
		end
	elseif event == "UNIT_MODEL_CHANGED" then
		if arg1 == frame.unit then
			if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
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
			-- -- have to set uvar manually or it will be the previous value
			-- SHOW_ALL_ENEMY_DEBUFFS = GetCVar("showAllEnemyDebuffs")
			-- if ( frame:IsShown() ) then
				-- UnitFrames:UpdateAuras(frame)
			-- end
		-- end
	elseif event == "UI_SCALE_CHANGED" then
		if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
	end
end

function module:DisableBlizz()
	if FocusFrame.ApplySystemAnchor then
		if not self:IsHooked(FocusFrame, "ApplySystemAnchor") then
			---@diagnostic disable-next-line: redefined-local
			self:SecureHook(FocusFrame, "ApplySystemAnchor", function(self)
				self:SetParent(UnitFrames.UIhider)
			end)
		end
	end
	FocusFrame:SetParent(UnitFrames.UIhider)
end

function module:EnableBlizz()
	if FocusFrame.ApplySystemAnchor then
		self:Unhook(FocusFrame, "ApplySystemAnchor")
	end
	FocusFrame:SetParent(UIParent)
end

function module:OnInitialize()
	-- Enable if we're supposed to be enabled
	if self.db and self.db.enabled and UnitFrames:IsEnabled() then
		self:Enable()
	end
end

function module:OnEnable()
	self:DisableBlizz()
	if not self.frame then
		self.frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent, FocusFrameDropDown or "FOCUS", true)
	end
	
	if self.frame then
		UnitFrames:EnableFrame(self.frame)
		Update(self.frame)
	end
end

function module:OnDisable()
	self:EnableBlizz()
	UnitFrames:DisableFrame(self.frame)
end