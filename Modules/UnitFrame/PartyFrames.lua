local addonName = ...
local moduleName = "PartyFrames"
local displayName = moduleName
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local UnitFrames = addon:GetModule("UnitFrames")
local module = UnitFrames:NewModule(moduleName, "AceHook-3.0")
local unit = "party"

module.defaults = {
	enabled = true,
	formats = {
		name = "$name $level",
	},
	
	frames = {
		[unit.."1"] = {
			["x"] = 30,
			["y"] = 266,
			["point"] = "LEFT",
			["scale"] = 1,
		},
		[unit.."2"] = {
			["x"] = 30,
			["y"] = 184,
			["point"] = "LEFT",
			["scale"] = 1,
		},
		[unit.."3"] = {
			["x"] = 30,
			["y"] = 102,
			["point"] = "LEFT",
			["scale"] = 1,
		},
		[unit.."4"] = {
			["x"] = 30,
			["y"] = 20,
			["point"] = "LEFT",
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
					set = function(info, value) module.db.formats.name = value;for _,v in pairs(module.frames) do UnitFrames:UpdateInfo(v) end end,
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

module.frames = {}

local events = {
	"PLAYER_ENTERING_WORLD",
	-- "PLAYER_FLAGS_CHANGED",
	"PLAYER_ROLES_ASSIGNED",
	"PLAYER_TARGET_CHANGED",
	"PARTY_LEADER_CHANGED",
	"PARTY_LOOT_METHOD_CHANGED",
	"GROUP_ROSTER_UPDATE",
	"RAID_TARGET_UPDATE",
	"UNIT_AURA",
	"UNIT_LEVEL",
	"UNIT_OTHER_PARTY_CHANGED",
	"UNIT_FACTION",
	"UNIT_NAME_UPDATE",
	"UNIT_FLAGS",
	"READY_CHECK",
    "READY_CHECK_CONFIRM",
    "READY_CHECK_FINISHED",
	"PARTY_MEMBER_ENABLE",
    "PARTY_MEMBER_DISABLE",
    "UNIT_PHASE",
	"UNIT_CONNECTION",
	"DISPLAY_SIZE_CHANGED",
	"UPDATE_BINDINGS",
	"CVAR_UPDATE",
}

local function UpdatePhasing(frame)
	local unit = frame.unit
	local icon = frame.phasingIcon
	
	if UnitInOtherParty(unit) then
		frame:SetAlpha(0.6)
		icon.texture:SetTexture("Interface\\LFGFrame\\LFG-Eye")
		icon.texture:SetTexCoord(0.125, 0.25, 0.25, 0.5)
		icon.border:Show()
		icon.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE
		icon:Show()
	elseif C_IncomingSummon and C_IncomingSummon.HasIncomingSummon(unit) then
		local status = C_IncomingSummon.IncomingSummonStatus(unit)
		if status == Enum.SummonStatus.Pending then
			icon.texture:SetAtlas("Raid-Icon-SummonPending")
			icon.texture:SetTexCoord(0, 1, 0, 1)
			icon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_PENDING
			icon.border:Hide()
			icon:Show()
		elseif status == Enum.SummonStatus.Accepted then
			icon.texture:SetAtlas("Raid-Icon-SummonAccepted")
			icon.texture:SetTexCoord(0, 1, 0, 1)
			icon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_ACCEPTED
			icon.border:Hide()
			icon:Show()
		elseif status == Enum.SummonStatus.Declined then
			icon.texture:SetAtlas("Raid-Icon-SummonDeclined")
			icon.texture:SetTexCoord(0, 1, 0, 1)
			icon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_DECLINED
			icon.border:Hide()
			icon:Show()
		end
	else
		local phaseReason = UnitIsConnected(unit) and ( UnitPhaseReason and UnitPhaseReason(unit) ) or nil;
		if phaseReason then
			frame:SetAlpha(0.6);
			icon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon");
			icon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375);
			icon.border:Hide();
			icon.tooltip = PartyUtil.GetPhasedReasonString(phaseReason, unit);
			icon:Show()
		else
			frame:SetAlpha(1)
			icon:Hide()
		end
	end	
	-- if UnitPlayerOrPetInParty(unit) then
		-- if ( UnitInPhase(unit) or not UnitExists(unit) or not UnitIsConnected(unit)) then
			-- frame:SetAlpha(1)
			-- icon:Hide()
		-- else
			-- frame:SetAlpha(0.6)
			-- icon:Show()
		-- end
	-- end
end

local function UpdateOnlineStatus(frame)
	if not UnitIsConnected(frame.unit) and UnitIsPlayer(frame.unit) then
		frame.classIcon:Hide()
		frame.disconnected:Show()
	else
		local _, classFileName = UnitClass(frame.unit)
		local coords = CLASS_ICON_TCOORDS[classFileName]
		if coords ~= nil then
			frame.classIcon:SetTexCoord(unpack(coords))
			frame.disconnected:Hide()
			frame.classIcon:Show()
		end
	end
end

local function UpdateRange(frame)
	local inRange, checkedRange = UnitInRange(frame.unit)
	if checkedRange and not inRange then
		frame:SetBackdropBorderColor(1,0,0)
	else
		frame:SetBackdropBorderColor(1,1,1)
	end
end

local function Update(frame)
	UnitFrames:PowerBar_Update(frame.powerBar,frame.unit)
	UnitFrames:HealthBar_Update(frame.health)
	if UnitExists(frame.unit) then
		UnitFrames:UpdateInfo(frame)
		UnitFrames:UpdatePartyLeader(frame)
		UnitFrames:UpdateLoot(frame)
		UnitFrames:UpdateRaidIcon(frame)
		UnitFrames:UpdateRoles(frame)
		UnitFrames:UpdatePVPStatus(frame)
		UpdatePhasing(frame)
		UpdateOnlineStatus(frame)
		UnitFrames:UpdateAuras(frame)
	end
end

local function OnUpdate(frame, elapsed)
	if not UnitExists(frame.unit) then return end
	UpdateRange(frame)
end

local function OnEvent(frame, event, ...)

	if not frame.isEnabled then return end

	local arg1, arg2, arg3, arg4, arg5 = ...

	if event == "PLAYER_ENTERING_WORLD" or event == "CVAR_UPDATE" or event == "UPDATE_BINDINGS" or event == "DISPLAY_SIZE_CHANGED" then
		Update(frame)
	elseif event == "UNIT_PHASE" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "UNIT_FLAGS" or event == "UNIT_CTR_OPTIONS" then
		if event ~= "UNIT_PHASE" or arg1 == frame.unit then
			UpdatePhasing(frame)
		end
	elseif event == "UNIT_OTHER_PARTY_CHANGED" and arg1 == frame.unit then
		UpdatePhasing(frame)
	elseif event == "INCOMING_SUMMON_CHANGED" then
		UpdatePhasing(frame)
	elseif event == "UNIT_CONNECTION" then
		if arg1 == frame.unit then
			UpdateOnlineStatus(frame)
			UnitFrames:UpdateAuras(frame)
		end
	elseif event == "UNIT_LEVEL" or event == "UNIT_NAME_UPDATE" then
		if arg1 == frame.unit then
			UnitFrames:UpdateInfo(frame)
		end
	elseif event == "UNIT_AURA" then
		if arg1 == frame.unit then
			UnitFrames:UpdateAuras(frame)
		end
	elseif event == "UNIT_FACTION" then
		if arg1 == frame.unit then
			UnitFrames:UpdatePVPStatus(frame)
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		if UnitExists("target") and UnitIsUnit("target", frame.unit) then
			frame:LockHighlight()
		else
			frame:UnlockHighlight()
		end
	elseif event == "GROUP_ROSTER_UPDATE" then
		Update(frame)
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
	end
end


local function HideParty()
	if not IsInRaid() and GetCVar("useCompactPartyFrames") == "0" then return end
	-- GetCVarBool()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue(HideParty)
		return
	end

	for k,frame in pairs(module.frames) do
		if frame.isWatched then
			UnregisterUnitWatch(frame)
			frame.isWatched = false
		end
		
		frame.hidden = true
		
		if UnitFrames.locked and not frame.isWatched then
			frame:Hide()
		end
	end
end
 
local function ShowParty()
	if IsInRaid() and GetCVar("useCompactPartyFrames") == "1" then return end
	-- GetCVarBool()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue(ShowParty)
		return
	end
	
	for k,frame in pairs(module.frames) do
		if UnitFrames.locked and not frame.isWatched then
			RegisterUnitWatch(frame)
		end
		frame.hidden = false
		-- Even if not registered with an actual unit watch, set as watched for the UnitFrames:Lock() function.
		frame.isWatched = true
		UnitFrames:UpdateReadyCheck(frame.unit, frame.readyCheck)
	end
end

local blizzFrames = {}

local function DisableBlizz()
	for i = 1, MAX_PARTY_MEMBERS do
		local frame = _G["PartyMemberFrame"..i]
		local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(frame:GetNumPoints())
		
		blizzFrames[i] = { 
				[1] = point,
				[2] = relativeTo:GetName(),
				[3] = relativePoint,
				[4] = xOfs,
				[5] = yOfs,
		}
		
		-- frame:SetScript("OnEvent", nil)
		-- frame:SetScript("OnUpdate", nil)
		
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", -500, 500)
		frame:Hide()
	end
	CompactRaidFrameManager:SetFrameLevel(4)
end

local function EnableBlizz()
	for i = 1, MAX_PARTY_MEMBERS do
		local frame = _G["PartyMemberFrame"..i]
		local point, relativeTo, relativePoint, xOfs, yOfs = unpack(blizzFrames[i])
		
		frame:ClearAllPoints()
		frame:SetPoint(point, _G[relativeTo], relativePoint, xOfs, yOfs)
		
		-- frame:SetScript("OnEvent", PartyMemberFrame_OnEvent)
		-- frame:SetScript("OnUpdate", PartyMemberFrame_OnUpdate)
		PartyMemberFrame_UpdateArt(frame)
		PartyMemberFrame_UpdateMember(frame)
		PartyMemberFrame_UpdateLeader(frame)
		if PartyMemberFrame_UpdateAssignedRoles then PartyMemberFrame_UpdateAssignedRoles(frame) end
	end
	CompactRaidFrameManager:SetFrameLevel(1)
end

function module:OnInitialize()
	-- Enable if we're supposed to be enabled
	if self.db and self.db.enabled and UnitFrames:IsEnabled() then
		self:Enable()
	end
end

function module:OnEnable()
	if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then
		table.insert(events, "INCOMING_SUMMON_CHANGED")
		table.insert(events, "UNIT_CTR_OPTIONS")
	end

	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnEnable", module)
		addon:InfoMessage(string.format(addon.infoMessages.enableModuleInCombat, addon:WrapTextInColorCode(moduleName, addon.colors.moduleName)))
		return
	end
	DisableBlizz()
	if table.getn(self.frames) == 0 then
		for i=1,4 do
			local frame = UnitFrames:CreateFrame(moduleName, unit, events, OnEvent, _G["PartyMemberFrame"..i.."DropDown"], true, i)
			frame:SetScript("OnUpdate", OnUpdate)
			table.insert(module.frames, frame)
		end
	end

	if table.getn(self.frames) > 0 then
		for _, frame in ipairs(module.frames) do
			UnitFrames:EnableFrame(frame)
			Update(frame)
		end
		ShowParty()
		HideParty()
	end

	self:SecureHook("HidePartyFrame", HideParty)
	self:SecureHook("ShowPartyFrame", ShowParty)
end

function module:OnDisable()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("OnDisable", module)
		addon:InfoMessage(string.format(addon.infoMessages.disableModuleInCombat, addon:WrapTextInColorCode(moduleName, addon.colors.moduleName)))
		return
	end
	EnableBlizz()
	for _, frame in ipairs(self.frames) do
		UnitFrames:DisableFrame(frame)
	end
	self:UnhookAll()
end
