local addonName = ...
local moduleName = "TargetFrame"
local displayName = moduleName
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local UnitFrames = addon:GetModule("UnitFrames")
local module = UnitFrames:NewModule(moduleName)
local unit = "target"

module.defaults = {
	enabled = true,
	formats = {
		-- name = "$name $guild",
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
			get = function() return module:IsEnabled() end,
			set = function() if module:IsEnabled() then module:Disable() else module:Enable() end end,
		},
	},
}

local events = {
	"UNIT_COMBO_POINTS",
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


local function UpdateCombo(frame, unit)
	local comboPoints = GetComboPoints("player", unit)
	local r, g, b
	local parent = frame:GetParent()
	if comboPoints > 0 then
		if comboPoints == 5 then
			r, g, b = 1, 0, 0
		elseif comboPoints == 4 then
			r, g, b = 1, 0.5, 0
		elseif comboPoints == 3 then
			r, g, b = 1, 1, 0
		elseif comboPoints == 2 then
			r, g, b = 0.5, 1, 0
		elseif comboPoints == 1 then
			r, g, b = 0, 0.5, 0
		end
		frame:SetTextColor(r, g, b)
		frame:SetText(comboPoints)
		frame:Show()
		-- parent:SetBackdropBorderColor(r,g,b)
	else
		-- parent:SetBackdropBorderColor(1,1,1)
		frame:Hide()
	end
end

local function Update(frame)
	UnitFrames:PowerBar_Update(frame.powerBar, frame.unit)
	UnitFrames:HealthBar_Update(frame.health)
	if frame.threat then UnitFrames:ThreatBar_Update(frame.threat) end
	if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
	if UnitExists(frame.unit) then
		-- if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit) end
		if frame.combo then UpdateCombo(frame.combo, frame.unit) end
		UnitFrames:UpdateLoot(frame)
		UnitFrames:UpdateReadyCheck(frame.unit, frame.readyCheck)
		UnitFrames:UpdateRaidIcon(frame)
		UnitFrames:UpdateInfo(frame)
		UnitFrames:UpdatePartyLeader(frame)
		UnitFrames:UpdateRoles(frame)
		UnitFrames:UpdatePVPStatus(frame)
		UnitFrames:UpdateAuras(frame)
	end	
end

local function OnEvent(frame, event, ...)
	local arg1, arg2, arg3, arg4, arg5 = ...
	if event == "PLAYER_ENTERING_WORLD" or event == "DISPLAY_SIZE_CHANGED" then
		Update(frame)
	elseif event == "PLAYER_TARGET_CHANGED" then
			Update(frame)
			if ( UnitExists(frame.unit) ) then
				if ( UnitIsEnemy(frame.unit, "player") ) then
					PlaySound("igCreatureAggroSelect");
				elseif ( UnitIsFriend("player", frame.unit) ) then
					PlaySound("igCharacterNPCSelect");
				else
					PlaySound("igCreatureNeutralSelect");
				end
			end		
	elseif event == "UNIT_COMBO_POINTS" then
		if arg1 == "player" then
			UpdateCombo(frame.combo, frame.unit)
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
	elseif event == "UNIT_TARGETABLE_CHANGED" then
		if arg1 == frame.unit then
			Update(frame)
			CloseDropDownMenus()
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
		if arg1 == "SHOW_ALL_ENEMY_DEBUFFS_TEXT" then
			-- have to set uvar manually or it will be the previous value
			SHOW_ALL_ENEMY_DEBUFFS = GetCVar("showAllEnemyDebuffs")
			if ( frame:IsShown() ) then
				UnitFrames:UpdateAuras(frame)
			end
		end
	elseif event == "UI_SCALE_CHANGED" then
		if frame.model then UnitFrames:UpdateModel(frame.model, frame.unit)end
	end
end

function module:OnInitialize()

end

function module:OnEnable()
	if not self.frame then
		self.frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent, TargetFrameDropDown, true)
	end
end

function module:OnDisable()

end