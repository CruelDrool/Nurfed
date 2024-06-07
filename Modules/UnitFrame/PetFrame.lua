local addonName = ...
local moduleName = "PetFrame"
local displayName = moduleName
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local UnitFrames = addon:GetModule("UnitFrames")
local module = UnitFrames:NewModule(moduleName, "AceHook-3.0")
local unit = "pet"

module.defaults = {
	enabled = true,
	formats = {
		name = "[$level] $name",	
	},

	frames = {
		[unit] = {
			["x"] = -283,
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
				health = {
					order = 2,
					type = "input",
					name = "Health",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("health", nil, moduleName) end,
					set = function(info, value) module.db.formats.health = value end,
				},
				power = {
					order = 3,
					type = "input",
					name = "Power",
					-- desc = "",
					get = function() return UnitFrames:GetTextFormat("power", nil, moduleName) end,
					set = function(info, value) module.db.formats.power = value end,
				},
			},
		},
	},
}

local events = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_TARGET_CHANGED",
	"RAID_TARGET_UPDATE",
	"UNIT_AURA",
	"UNIT_LEVEL",
	"UNIT_PET",
	"PET_ATTACK_START",
	"PET_ATTACK_STOP",
	"PET_UI_UPDATE",
	-- "PET_RENAMEABLE",
	"DISPLAY_SIZE_CHANGED",
	"UNIT_ENTERED_VEHICLE",
	"UNIT_EXITED_VEHICLE",
	"UNIT_MODEL_CHANGED",
	"UNIT_NAME_UPDATE",
	"UI_SCALE_CHANGED",
}

local function Update(frame)
	-- frame.cast.unit = frame.unit
	UnitFrames:PowerBar_Update(frame.powerBar, frame.unit)
	UnitFrames:HealthBar_Update(frame.health)
	if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
	if UnitExists(frame.unit) then
		UnitFrames:UpdateInfo(frame)
		UnitFrames:UpdateRaidIcon(frame)
		UnitFrames:UpdateAuras(frame)
	end
end

local function OnEvent(frame, event, ...)

	if not frame.isEnabled then return end

	local arg1, arg2, arg3, arg4, arg5 = ...

	if event == "PLAYER_ENTERING_WORLD" then
		Update(frame)
	elseif event == "DISPLAY_SIZE_CHANGED" then
		Update(frame)
	elseif event == "UNIT_PET" and arg1 == "player" then
		-- if UnitInVehicle(arg1) then
			-- frame.unit = "vehicle"
		-- else
			-- frame.unit = "pet"
		-- end
		-- frame.cast.unit = frame.unit
		Update(frame)
	elseif event == "PET_ATTACK_START" then
		frame.attackIcon:Show()
	elseif event == "PET_ATTACK_STOP" then
		frame.attackIcon:Hide()
	elseif event == "UNIT_ENTERED_VEHICLE" and arg1 == "player" then
		-- frame.unit = "vehicle"
		-- frame.cast.unit = frame.unit
		Update(frame)
	elseif event == "UNIT_EXITED_VEHICLE" and arg1 == "player" then
		-- frame.unit = "pet"
		-- frame.cast.unit = frame.unit
		Update(frame)
	elseif event == "UNIT_LEVEL" or event == "UNIT_NAME_UPDATE" then
		if arg1 == frame.unit then
			UnitFrames:UpdateInfo(frame)
		end
	elseif event == "UNIT_AURA" then
		if arg1 == frame.unit then
			UnitFrames:UpdateAuras(frame)
		end
	elseif event == "RAID_TARGET_UPDATE" then
		UnitFrames:UpdateRaidIcon(frame)
	-- elseif event == "PET_RENAMEABLE" then
		-- StaticPopup_Show("RENAME_PET")
	elseif event == "PLAYER_TARGET_CHANGED" then
		if UnitExists("target") and UnitIsUnit("target", frame.unit) then
			frame:LockHighlight()
		else
			frame:UnlockHighlight()
		end
	elseif event == "UNIT_MODEL_CHANGED" then
		if arg1 == frame.unit then
			if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
		end
	elseif event == "UI_SCALE_CHANGED" then
		if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit)end
	end
end

function module:DisableBlizz()

	if PetFrame.ApplySystemAnchor then
		---@diagnostic disable-next-line: redefined-local
		self:SecureHook(PetFrame, "ApplySystemAnchor", function(self)
			self:SetParent(UnitFrames.UIhider)
		end)
	end

	if PetFrame.UpdateShownState then
		---@diagnostic disable-next-line: redefined-local
		self:SecureHook(PetFrame, "UpdateShownState", function(self)
			self:SetParent(UnitFrames.UIhider)
		end)
	end

	PetFrame:SetParent(UnitFrames.UIhider)
end

function module:EnableBlizz()
	if PetFrame.ApplySystemAnchor then
		self:Unhook(PetFrame, "ApplySystemAnchor")
	end

	if PetFrame.UpdateShownState then
		self:Unhook(PetFrame, "UpdateShownState")
	end

	PetFrame:SetParent(PlayerFrameBottomManagedFramesContainer or PlayerFrame)
end

function module:OnInitialize()
	-- Enable if we're supposed to be enabled
	if self.db and self.db.enabled and UnitFrames:IsEnabled() then
		self:Enable()
		UnitFrames:RunOnPlayerEnteringWorld("DisableBlizz", self)
	end
end

function module:OnEnable()

	if not self.frame then
		self.frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent, PetFrameDropDown or "PET", true)
	end

	if self.frame then
		UnitFrames:EnableFrame(self.frame)
		Update(self.frame)
	end

	if UnitFrames:IsPlayerInWorld() then
		self:DisableBlizz()
	end
end

function module:OnDisable()
	self:EnableBlizz()
	UnitFrames:DisableFrame(self.frame)
end