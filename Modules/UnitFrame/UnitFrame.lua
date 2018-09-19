local addonName = ...
local moduleName = "UnitFrames"
local displayName = moduleName
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local module = addon:NewModule(moduleName)
-- module:SetDefaultModuleState(false)

local defaults = {
	profile = {
		enabled = true,
		formats = {
			name = "$name",
			level = "$level",
			group = "$group",
			guild = "$guild",
			race = "$race",
			sex = "$sex",
			infoline = "$level $class ($g)",
			health = "$cur ($max)",
			power = "$cur ($max)",
			miss = "$miss",
			perc = "$perc",
			threat = "$cur",
			casting = "$spell",
		},
		skins = {
			keys = {
				["Nurfed"] = "Nurfed (default)",
				["Test"] = "Testeleste",
			},
			["Nurfed"] = {
				templatePrefix = "Nurfed_Unit_",
				glideFade = 0.35,
				-- statusbartexture = "Interface\\AddOns\\Nurfed\\Images\\statusbar5",
			},
			["Test"] = {
				glideFade = 0.1,
			},
		},
		decimalpoints = 2,
		skin = "Nurfed",
		templatePrefix = "Nurfed_Unit_",
		glideAnimation = true,
		glideFade = 0.35,
	}
}

module.options = {
	-- order = 3,
	type = "group",
	name = displayName,
	-- desc = "",
	-- icon = "Interface\\GossipFrame\\FooIconThatDoesntExist",
	args = {
		intro = {
			order = 1,
			type = "description",
			name = "Options for UnitFrames",
		},
		enabled = {
			order = 2,
			type = "toggle",
			width = "full",
			name = "Enabled",
			-- desc = "",
			get = function() return module:IsEnabled() end,
			set = function() if module:IsEnabled() then module:Disable() else module:Enable() end end,
		},
		decimalpoints = {
			order = 3,
			name = "Decimal points",
			-- desc = "",
			type = "range",
			min = 0, max = 2, step = 1,
			get = function() return module.db.profile.decimalpoints end,
			set = function(info, value) module.db.profile.decimalpoints = value end,
			-- disabled = function() return not module.db.profile.foo end,
		},
		glidefade = {
			order = 5,
			name = "Glide fade timeout",
			-- desc = "",
			type = "range",
			min = 0.1, max = 0.9, step = 0.05,
			get = function() local value = module.db.profile.glideFade; value=1-value; return value end,
			set = function(info, value) value=1-value; module.db.profile.glideFade = value end,
			-- disabled = function() return not module.db.profile.foo end,
		},
		skins = {
			type = "select",
			name = "Skins",
			values = function() return module.db.profile.skins.keys end,
			get = function() return module.db.profile.skin end,
			set = function(info, value)
				module.db.profile.skin = tostring(value)
				for k, v in pairs(module.db.profile.skins[value]) do
					module.db.profile[k] = v
				end
			end,
		},
	},
}

module.frames = {}
module.OutOfCombatQueue = {}

function module:OnInitialize()
	for name, mod in self:IterateModules() do
		if mod.options then
			if not self.options.args[name] then
				self.options.args[name] = mod.options
			end
		end
		if mod.defaults then
			defaults.profile[mod:GetName()] = mod.defaults
		end
	end
	
	-- Register DB namespace
	self.db = addon.db:RegisterNamespace(moduleName, defaults)
	
	-- Register callbacks
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateConfigs")
	
	self.locked = true
	
	-- Enable if we're supposed to be enabled
	if self.db.profile.enabled then
		self:Enable()
	end
end

function module:OnEnable()
	self:SecureHook(addon.LDBObj,"OnClick", function(frame, msg)
		if msg == "LeftButton" then
			module:Lock()
			addon.LDBObj.OnTooltipShow(GameTooltip)
		end
	end)
	
	self:SecureHook(addon.LDBObj,"OnTooltipShow", function(tooltip)
		if module.locked then
			tooltip:AddLine("Left Click - |cffff0000Unlock|r UI", 0.75, 0.75, 0.75)
		else
			tooltip:AddLine("Left Click - |cff00ff00Lock|r UI", 0.75, 0.75, 0.75)
		end
	end)
	
	if LDBTitan and _G["TitanPanel"..addonName.."Button"] then
		LDBTitan:TitanLDBHandleScripts("OnTooltipShow", addonName, nil, addon.LDBObj.OnTooltipShow, addon.LDBObj)
		LDBTitan:TitanLDBHandleScripts("OnClick", addonName, nil, addon.LDBObj.OnClick)
	end
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	
	self.db.profile.enabled = true
end

function module:OnDisable()
	if not self.locked then
		self:Lock()
	end
	
	self:UnhookAll()
	self:UnregisterAllEvents()
	self.db.profile.enabled = false
	-- for name, mod in self:IterateModules() do
		-- mod.disabledByParent = true
		-- mod:Disable()
	-- end
end

function module:UpdateConfigs()
	for f, modName in pairs(self.frames) do
		if f then
			local frame = _G[f]
			local db = self.db.profile[modName].frames[frame.unit]
			-- The reference to where the frame stores its positioning data has been removed.
			-- Need to re-register the config/storage.
			frame.RegisterConfig(frame, db) 
			frame:RestorePosition(frame)
			if frame.model then
				frame.model:RefreshUnit()
			end
		end
	end
	-- for name, mod in self:IterateModules() do
		-- if self.db.profile[mod:GetName()].enabled then
			-- mod:Enable()
		-- end
	-- end
end

function module:CreateFrame(modName, unit, events, oneventfunc, menufunc, isWatched, id)
	if not self:GetModule(modName) then return end
	if not type(unit) == "string" then return end
	if not type(events) == "table" then return end
	if not id then id = 0 end
	
	local name = addonName.."_"..unit
	local template = self.db.profile.templatePrefix..unit
	
	if id > 0 then name = name..id end
	
	if self.frames[name] then return end
	
	local frame = CreateFrame("Button", name, UIParent, template, id)

	if id > 0 then  
		frame.unit = unit..id
	else
		frame.unit = unit
	end

	if isWatched then RegisterUnitWatch(frame); frame.isWatched = true end
		
	for _, event in pairs(events) do
		if type(event) == "string" then
			frame:RegisterEvent(event)
		end
	end
	
	if frame.health then self:HealthBar_OnLoad(frame.health) end
	if frame.powerBar then self:PowerBar_OnLoad(frame.powerBar, frame.unit) end
	if frame.additionalPowerBar then self:AdditionalPowerBar_OnLoad(frame.additionalPowerBar, frame.unit) end
	if frame.cast then self:CastBar_OnLoad(frame.cast, frame.unit) end
	if frame.threat then self:ThreatBar_OnLoad(frame.threat, unit) end
	
	if frame.target then self:TargetofTarget_Onload(frame.target, frame.unit.."target") end
	if frame.targettarget then self:TargetofTarget_Onload(frame.targettarget, frame.unit.."targettarget") end
	if frame.pet then self:TargetofTarget_Onload(frame.pet, unit.."pet"..id) end -- partypetN, not partyNpet!
	if frame.buffs or frame.debuffs then frame.showAuraCount = true end

	if type(oneventfunc) == "function" then
		frame:SetScript("OnEvent", oneventfunc)
	end
		
	frame:SetScript("OnMouseWheel", function(frame, delta) module:OnMouseWheel(frame, delta) end)
	
	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	
	if type(menufunc) == "table" then
		
		local showmenu = function()
			ToggleDropDownMenu(1, nil, menufunc, "cursor")
		end
		SecureUnitButton_OnLoad(frame, frame.unit, showmenu)
	end
	
	local db = self.db.profile[modName].frames[frame.unit]
	LibStub("LibWindow-1.1"):Embed(frame)
	frame.RegisterConfig(frame, db)
	frame:RestorePosition(frame)
	
	self.frames[name] = modName

	return frame
end

function module:Lock()

	if InCombatLockdown() then
		table.insert(module.OutOfCombatQueue, module.Lock)
		return
	end
	
	-- if module.locked and not InCombatLockdown() then
	if module.locked then
		module.locked = false
		addon.LDBObj.icon = "Interface\\AddOns\\"..addonName.."\\Images\\unlocked"
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		for f in pairs(module.frames) do
			local frame = _G[f]
			frame.overlay:Show()
			if frame.isWatched then
				UnregisterUnitWatch(frame)
			end
			frame:Show()
			if frame.model then module:UpdateModel(frame.model, frame.unit) end
		end
	elseif not module.locked then
		module.locked = true
		addon.LDBObj.icon = "Interface\\AddOns\\"..addonName.."\\Images\\locked"
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
		for f in pairs(module.frames) do
			local frame = _G[f]
			frame.overlay:Hide()
			if frame.model then module:UpdateModel(frame.model, frame.unit) end
			if frame.isWatched then
				RegisterUnitWatch(frame)
			elseif frame.hidden then
				frame:Hide()
			end
		end
	end
	return module.locked
end

function module:PLAYER_REGEN_DISABLED()
	if not self.locked then
		self:Lock()
	end
end

function module:PLAYER_REGEN_ENABLED()
	for i, func in pairs(self.OutOfCombatQueue) do 
		if type(func) == "function" then
			func()
		end
		self.OutOfCombatQueue[i] = nil
	end
end

function module:GetTextFormat(frame, f)
	local modName = self.frames[frame:GetName()]
	
	if modName ~= nil then
		if self.db.profile[modName].formats then
			if self.db.profile[modName].formats[f] then
				return self.db.profile[modName].formats[f]
			elseif self.db.profile.formats[f] then
				return self.db.profile.formats[f]
			end
		end
	else
		if self.db.profile.formats[f] then
			return self.db.profile.formats[f]
		end
	end
end

function module:FormatPercentage(number)
	return format("%."..tostring(self.db.profile.decimalpoints).."f", number).."%%"
end

local Colour_Gradients = {
	[0] = {
		minHP = {1.0, 0.0, 0.0},
		midHP = {1.0, 1.0, 0.0},
		maxHP = {0.0, 1.0, 0.0},
	},
	[1] = { 
		minHP = { 0.8078431372549, 0.66666666666667, 0.66666666666667 },
		midHP = { 0.43137254901961, 0.32843137254902, 0.42745098039216 },
		maxHP = { 0.30588235294118, 0.4156862745098, 0.56078431372549 },
	},
}

--/run for i=1,GetNumBindings() do local a, b, c = GetBinding(i);if string.find(a, "^TARGET") then print(a, c) end end
local keyBindingsMap = {
	player = "TARGETSELF",
	focus = "TARGETFOCUS",
	pet = "TARGETPET",
	party1 = "TARGETPARTYMEMBER1",
	party2 = "TARGETPARTYMEMBER2",
	party3 = "TARGETPARTYMEMBER3",
	party4 = "TARGETPARTYMEMBER4",
	partypet1 = "TARGETPARTYPET1",
	partypet2 = "TARGETPARTYPET2",
	partypet3 = "TARGETPARTYPET3",
	partypet4 = "TARGETPARTYPET4",
	arena1 = "TARGETARENA1",
	arena2 = "TARGETARENA2",
	arena3 = "TARGETARENA3",
	arena4 = "TARGETARENA4",
}

SecondsToTimeAbbrev_Orig = SecondsToTimeAbbrev
function SecondsToTimeAbbrev(seconds)
	local time
	if seconds > 86400 then
		local day = floor(seconds / 86400)
		local hour = floor((seconds % 86400) / 3600)
		time = format(DAY_ONELETTER_ABBR.." "..HOUR_ONELETTER_ABBR, day, hour)
		-- time = format(DAY_ONELETTER_ABBR, ceil(seconds / 86400))
	elseif seconds > 3600 then
		local hour = floor(seconds / 3600)
		local min = floor((seconds % 3600) / 60)
		local sec = (seconds % 3600) % 60
		-- time = format("%1d:%02d:%04.1f", hour, min, sec)
		time = format("%1d:%02d:%02d", hour, min, sec)
	elseif seconds > 60 then
		local min = floor(seconds / 60)
		local sec = seconds % 60
		time = format("%02d:%02d", min, sec)
	elseif seconds > 1 then
		time = format("%1d", seconds)
	else
		-- time = format("%.1f", seconds), (seconds * 100 - floor(seconds * 100))/100
		time = format("%.1f", seconds)
	end
	return time
end

local function RaidInfo(unit)
	local _, group, role
	if UnitPlayerOrPetInParty(unit) then
		if IsInRaid() then
			for i = 1, GetNumGroupMembers() do
				if UnitIsUnit("raid"..i, unit) then
					_, _, group, _, _, _, _, _, _, role = GetRaidRosterInfo(i)
					break
				end
			end
		end
	end
	return group, role
end

function module:Replace(unit, textFormat)
	if textFormat == nil then return "" end
	if not UnitExists(unit) then return "" end
	-- local unit = frame.unit
	out = textFormat
	if string.find(textFormat,"$name") then
		local name = UnitName(unit)
		local color
		if UnitIsPlayer(unit) then
			local _, englishClass = UnitClass(unit)
			color = RAID_CLASS_COLORS[englishClass]
			if color ~= nil then color = addon:rgbhex(color) else color = addon:rgbhex(UnitSelectionColor(unit)) end
		else
			-- if not UnitPlayerControlled(unit) and UnitIsTapped(unit) then
				-- if not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit) then
					-- color = "|cff7f7f7f"
				-- elseif UnitIsTappedByPlayer(unit) or UnitIsTappedByAllThreatList(unit) then
					-- color = addon:rgbhex(UnitSelectionColor(unit))
				-- end
			if not UnitPlayerControlled(unit) then
				if UnitIsTapDenied(unit) then
					color = "|cff7f7f7f"
				else
					color = addon:rgbhex(UnitSelectionColor(unit))
				end
			else
				local creatureType = UnitCreatureType(unit)
				if UnitPlayerControlled(unit) and (creatureType == "Beast" or creatureType == "Demon" or creatureType == "Elemental" or creatureType == "Undead") then
					-- unit is a pet/minion
					color = "|cff005500"
				else
					-- color = addon:rgbhex(UnitSelectionColor(unit))
					color = addon:rgbhex(FACTION_BAR_COLORS[UnitReaction(unit, "player")])
				end
			end
		end
		out = out:gsub("$name", color..name.."|r")
	end
	if string.find(textFormat,"$guild") then
		local guildName = GetGuildInfo(unit)
		if guildName ~= nil then
			local color = "|cff00bfff"
			if UnitIsInMyGuild(unit) then
				color = "|cffff00ff"
			end
			guildName = color..guildName.."|r"
			out = out:gsub("$guild", guildName)
		else
			out = out:gsub("%S*$guild%S*%s?", "")
		end
	end
	
	if string.find(textFormat,"$level") then
		local level = UnitEffectiveLevel(unit)
		-- local level = UnitLevel(unit)
		local classification = UnitClassification(unit)
		local r, g, b
		if level > 0 then
			-- r, g, b = GetRelativeDifficultyColor(UnitLevel("player"), level)
			r, g, b = GetRelativeDifficultyColor(UnitEffectiveLevel("player"), level)
		end

		if level == 0 then
			level = ""
		elseif level < 0 then
			if UnitIsPlayer(unit) then
				level = "??"
			else
				level = BOSS
			end
			r, g, b = 1, 0, 0
		elseif level > 0 and (classification == "rareelite" or classification == "elite" or classification == "rare") then
			level = level.."+"
		end
		
		if classification == "worldboss" then
			level = BOSS
			r, g, b = 1, 0, 0
		end
		
		if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
			level = UnitBattlePetLevel(unit)
			local highestLevelPet = 1;
			local petGUID
			local slottedPets = 0
			for i=1,select(2,C_PetJournal.GetNumPets()) do
				if slottedPets == 3 then break end
				petGUID = select(1,C_PetJournal.GetPetInfoByIndex(i))
				if petGUID ~= nil then
					if C_PetJournal.PetIsSlotted(petGUID) then
						local current = select(5,C_PetJournal.GetPetInfoByIndex(i))
						if current > highestLevelPet then
							highestLevelPet = current
						end
						slottedPets = slottedPets + 1
					end
				end
			end
			r, g, b =  GetRelativeDifficultyColor(highestLevelPet, level)
		end
		
		level = addon:rgbhex(r,g,b)..level.."|r"
		out = out:gsub("$level", level)
	end
	
	if string.find(textFormat,"$class") then
		local class = ""
		if UnitIsPlayer(unit) then
			local englishClass
			class, englishClass = UnitClass(unit)
			if not class then class = "Unknown" end
			if RAID_CLASS_COLORS[englishClass] then
				class = addon:rgbhex(RAID_CLASS_COLORS[englishClass])..class.."|r"
			else
				class = addon:rgbhex(UnitSelectionColor(unit))..class.."|r"
			end
		else
			if UnitCreatureType(unit) == "Humanoid" and UnitIsFriend("player", unit) then
				class = "NPC"
			elseif UnitCreatureFamily(unit) then
				class = UnitCreatureFamily(unit)
			elseif UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
				local petType = UnitBattlePetType(unit);
				class = _G["BATTLE_PET_NAME_"..petType].." "..PET
			elseif UnitCreatureType(unit) then
				class = UnitCreatureType(unit)
			end
			
			local classification = UnitClassification(unit)
			
			if classification == "rareelite" then
				class = ITEM_QUALITY3_DESC.."-"..ELITE.." "..class
			elseif classification == "rare" then
				class = ITEM_QUALITY3_DESC.." "..class
			elseif classification == "elite" then
				class = ELITE.." "..class
			end
		end	
		out = out:gsub("$class", class)
	end
	
	if string.find(textFormat,"$race") then
		if UnitIsPlayer(unit) then
			local race = UnitRace(unit)
			out = out:gsub("$race", race)
		else
			out = out:gsub("%S*$race%S*%s?", "")
		end
	end
	
	if string.find(textFormat,"$sex") then
		local sex = UnitSex(unit)
		if sex > 1 then
			if sex == 2 then sex = MALE else sex = FEMALE end
			out = out:gsub("$sex", sex)
		else
			-- out = out:gsub("%S*$sex%S*%s?", "")
			out = out:gsub("$sex", NONE)
		end
	end
	
	if string.find(textFormat,"$group") then
		if UnitIsPlayer(unit) and UnitPlayerOrPetInParty(unit) and IsInRaid() then
			local groupNumber = RaidInfo(unit)
			if groupNumber then
				out = out:gsub("$group", GROUP..": |cffffff00"..groupNumber.."|r")
			end
		else
			out = out:gsub("%S*$group%S*%s?", "")
		end
	end
	if string.find(textFormat,"$g") then
		if UnitIsPlayer(unit) and UnitPlayerOrPetInParty(unit) and IsInRaid() then
			local groupNumber = RaidInfo(unit)
			if groupNumber then
				out = out:gsub("$g", string.sub(GROUP, 0, 1)..": |cffffff00"..groupNumber.."|r")
			end
		else
			out = out:gsub("%S*$g%S*%s?", "")
		end
	end
	if string.find(textFormat,"$realm") then
		local realm = select(2,UnitFullName(unit))
		if realm ~= nil then
			out = out:gsub("$realm", realm)
		else
			out = out:gsub("%S*$realm%S*%s?", "")
		end
		realm = nil
	end
	if string.find(textFormat,"$title") then
		local title = UnitPVPName(unit)
		title = title:gsub(UnitName(unit).."%p?%s?","")
		title = title:gsub("^%l?", function(l)
				return string.upper(l)
			end)
		if title ~= nil then
			out = out:gsub("$title", title)
		else
			out = out:gsub("%S*$title%S*%s?", "")
		end
		title = nil
	end
	if string.find(textFormat,"$key") then
		local binding = ""
		if keyBindingsMap[unit] then
			binding = addon:Binding(GetBindingKey(keyBindingsMap[unit]))
		end
		
		if binding ~= "" then
			out = out:gsub("$key", binding)
		else
			out = out:gsub("%S*$key%S*%s?", "")
		end
		binding = nil
	end
	if out ~= textFormat then
		return out
	end
end

--------------------------------------------

function module:UpdateLoot(frame)
	local icon = frame.master
	local unit = frame.unit
	local showIcon = false
	if UnitPlayerOrPetInParty(unit) then
		if GetNumGroupMembers() > 0 then
			local lootMethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()
			if lootMethod == "master" then
				local id
				if IsInRaid() then
					id = "raid"..masterlooterRaidID
				else
					if masterlooterPartyID == 0 then
						id = "player"
					else
						id = "party"..masterlooterPartyID
					end
				end
				if UnitIsUnit(id, unit) then
					showIcon = true
				end
			end
		end
	end
	
	if showIcon then
		icon:Show()
	else
		icon:Hide()
	end
	
end

function module:UpdatePartyLeader(frame)
	if UnitIsGroupLeader(frame.unit) then
		frame.assistant:Hide()
		if HasLFGRestrictions() then
			frame.guide:Show()
			frame.leader:Hide()
		else
			frame.guide:Hide()
			frame.leader:Show()
		end
	elseif UnitIsGroupAssistant(frame.unit) and IsInRaid() then
		frame.leader:Hide()
		frame.guide:Hide()
		frame.assistant:Show()
	else
		frame.assistant:Hide()
		frame.leader:Hide()
		frame.guide:Hide()
	end
end

function module:UpdateRoles(frame)
    local LFGRole = UnitGroupRolesAssigned(frame.unit);
    local LFGicon = frame.LFGRole

    if ( LFGRole == "TANK" or LFGRole == "HEALER" or LFGRole == "DAMAGER") then
        LFGicon:SetTexCoord(GetTexCoordsForRoleSmallCircle(LFGRole));
        LFGicon:Show()
    else
        LFGicon:Hide()
    end
	
	local _, raidRole = RaidInfo(frame.unit)
	local raidIcon = frame.raidRole
	if raidRole == "MAINASSIST" then
		raidIcon:SetTexture("Interface\\GroupFrame\\UI-GROUP-MAINASSISTICON")
		raidIcon:Show()
	elseif raidRole == "MAINTANK" then
		raidIcon:SetTexture("Interface\\GroupFrame\\UI-GROUP-MAINTANKICON")
		raidIcon:Show()
	else
		raidIcon:Hide()
	end
end

function module:UpdateName(frame)
	--local textFormat = frame:GetAttribute("nameFormat")
	local textFormat = self:GetTextFormat(frame, "name")
	local name
	if textFormat ~= nil then
		name = self:Replace(frame.unit, textFormat)
	end
	frame.name:SetText(name)
end

function module:UpdateLevel(frame)
	-- local textFormat = frame:GetAttribute("levelFormat")
	local textFormat = self:GetTextFormat(frame, "level")
	local level
	if textFormat ~= nil then
		level = self:Replace(frame.unit, textFormat)
	end
	
	frame.level:SetText(level)
end

function module:UpdateGroupIndicator(frame)
	-- local textFormat = frame:GetAttribute("groupFormat")
	local textFormat = self:GetTextFormat(frame, "group")
	local text
	if textFormat ~= nil then
		text = self:Replace(frame.unit, textFormat)
	end
	frame.group:SetText(text)
	if text ~= "" then
		frame.group:Show()
	else
		frame.group:Hide()
	end
end

function module:UpdateInfo(frame)
	if frame.name then self:UpdateName(frame) end
	if frame.level then self:UpdateLevel(frame) end
	if frame.group then self:UpdateGroupIndicator(frame) end
	if frame.infoline then 
		local textFormat = self:GetTextFormat(frame, "infoline")
		local infoline
		if textFormat ~= nil then
			infoline = self:Replace(frame.unit, textFormat)
		end
		frame.infoline:SetText(infoline)
	end
end


function module:UpdateRaidIcon(frame)
	local icon = frame.raidtarget
	local index = GetRaidTargetIndex(frame.unit)
	if index then
		SetRaidTargetIconTexture(icon, index)
		icon:Show()
	else
		icon:Hide()
	end
end

function module:UpdatePVPStatus(frame)
	local unit = frame.unit
	local icon = frame.pvp
	local factionGroup = UnitFactionGroup(unit)
	if UnitIsPVPFreeForAll(unit) then
		icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		icon:Show()
	elseif factionGroup and UnitIsPVP(unit) then
		if factionGroup == "Neutral" then
			icon:Hide()
		else
			icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
			icon:Show()
		end
	else
		icon:Hide()
	end
end

function module:UpdateReadyCheck(unit, frame)
    local readyCheckStatus = GetReadyCheckStatus(unit);
    if ( readyCheckStatus ) then
        if ( readyCheckStatus == "ready" ) then
            ReadyCheck_Confirm(frame, 1);
        elseif ( readyCheckStatus == "notready" ) then
            ReadyCheck_Confirm(frame, 0);
        else -- "waiting"
            ReadyCheck_Start(frame);
        end
    else
        frame:Hide();
    end
end

function module:UpdateModel(frame, unit)
	if not UnitExists(unit) then
		frame:ClearModel()
		frame.portrait:Hide()
		return
	end
	frame:SetUnit(unit)
	frame:RefreshUnit()
	frame:SetPortraitZoom(1)
	if frame.portrait then
		if not InCombatLockdown() then
			SetPortraitTexture(frame.portrait, unit)
		end
		if not UnitIsVisible(unit) then
			frame.portrait:Show()
		else
			frame.portrait:Hide()
		end
	end
end

function module:OnMouseWheel(frame, delta)
	if not self.locked then
		local scale = frame:GetScale()
		if delta > 0 and scale < 3 then
			frame.SetScale(frame, scale + 0.1)
		elseif delta < 0 and scale > 0.25 then
			frame.SetScale(frame, scale - 0.1)
		end
		if IsShiftKeyDown() and IsControlKeyDown() then
			frame.SetScale(frame, 1)
		end
		if frame.model then self:UpdateModel(frame.model, frame.unit) end
	end
end

local function Glide(frame, e)
	-- if frame.fade < 1 then
	 if frame.glideFade < 1 then
		frame.fade = frame.glideFade
		frame.fade = frame.fade + e
		if frame.fade > 1 then frame.fade = 1 end
		local delta = frame.endvalue - frame.startvalue
		-- local diff = delta * (frame.fade / 1)
		local diff = delta * frame.fade
		frame.startvalue = frame.startvalue + diff
		frame:SetValue(frame.startvalue)
	end
end

--[[

HEALTHBAR functions

]]

local function HealthBar_Text(frame)
	local unit = frame:GetParent().unit
	
	local text = module:GetTextFormat(frame:GetParent(), "health")
	local miss = module:GetTextFormat(frame:GetParent(), "miss")
	local perc = module:GetTextFormat(frame:GetParent(), "perc")

	-- if frame.disconnected then
	if not UnitIsConnected(unit) and UnitIsPlayer(unit) then
		perc = PLAYER_OFFLINE
		miss = ""
	elseif UnitIsGhost(unit) then
		perc = GetSpellInfo(8326)
		miss = ""
	elseif (UnitIsDead(unit) or UnitIsCorpse(unit)) then
		perc = DEAD
		miss = ""
	else
		if miss ~= nil then
			local missing = frame.currValue - frame.maxValue
			if missing ~= 0 then
				miss = miss:gsub("$miss", addon:FormatNumber(missing))
			else
				miss = miss:gsub("$miss", "")
			end
		end
		if perc ~= nil then
			local percent
			if frame.currValue > 0 then
				percent = frame.currValue / frame.maxValue*100
			else
				percent = 0
			end
			perc = perc:gsub("$perc", module:FormatPercentage(percent))
		end
	end
	
	if text ~= nil then
		text = text:gsub("$cur", addon:CommaNumber(frame.currValue))
		text = text:gsub("$max", addon:FormatNumber(frame.maxValue))
	end
	
	if frame.miss then frame.miss:SetText(miss) end
	if frame.text then frame.text:SetText(text) end
	if frame.perc then frame.perc:SetText(perc) end
		
end

function HealthBar_Gradient(frame, elapsed, gradient)
	if not gradient then gradient = 0 end
	
	-- local unit = frame:GetParent().unit
	local perc = frame.currValue / frame.maxValue

	local alpha = 255;
	local perc = frame.currValue / frame.maxValue
	-- Blinking healthbar at low HP!
	if UnitIsFriend("player", frame:GetParent().unit) and perc < 0.3 then
		local divisor = 0.7
				
		if perc < 0.2 then
			divisor = 0.5
		elseif perc < 0.1 then
			divisor = 0.3
		end
		
		if elapsed then
			local counter = frame.statusCounter + elapsed;
			local sign    = frame.statusSign;
	 
			if ( counter > divisor ) then
				sign = -sign;
				frame.statusSign = sign;
			end
			counter = mod(counter, divisor);
			frame.statusCounter = counter;

			if ( sign == 1 ) then
				alpha = (55  + (counter * 400)) / 255;
			else
				alpha = (255 - (counter * 400)) / 255;
			end
			--frame:SetAlpha(alpha)
		end
	end
	
	local r1, g1, b1
	local r2, g2, b2
	if perc <= 0.5 then
		perc = perc * 2
		r1, g1, b1 = unpack(Colour_Gradients[gradient].minHP)
		r2, g2, b2 = unpack(Colour_Gradients[gradient].midHP)
	else
		perc = perc * 2 - 1
		r1, g1, b1 = unpack(Colour_Gradients[gradient].midHP)
		r2, g2, b2 = unpack(Colour_Gradients[gradient].maxHP)
	end
	-- if r1 and r2 and g1 and g2 and b1 and b2 then
		-- return r1 + (r2-r1)*perc, g1 + (g2-g1)*perc, b1 + (b2-b1)*perc
	-- else
		-- return 1, .5, .8
	-- end
	local r, g, b = r1 + (r2-r1)*perc, g1 + (g2-g1)*perc, b1 + (b2-b1)*perc
	
	-- frame:SetStatusBarColor(r, g, b)

	frame:SetStatusBarColor(r, g, b, alpha)
end

local function HealPredictionBar_Fill(frame, previousTexture, bar, amount, barOffsetXPercent)
	if amount == 0 then
		bar:Hide()
		return previousTexture
	end
	
	local barOffsetX = 0
	if barOffsetXPercent then
		barOffsetX = frame:GetWidth() * barOffsetXPercent
	end
	
	bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", barOffsetX, 0)
	bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", barOffsetX, 0)
	
	local totalWidth, totalHeight = frame:GetSize()
	local _, totalMax = frame:GetMinMaxValues()

	local barSize = (amount / totalMax) * totalWidth
	
	bar:SetWidth(barSize)
	bar:Show()
	return bar
end

local function HealPredictionBar_Update(frame)
	
	if not frame.myHealPrediction or not frame.otherHealPrediction or not frame.totalAbsorb or not frame.healAbsorb then
		return
	end
	local unit = frame:GetParent().unit
	local health = frame:GetValue()
    local _, maxHealth = frame:GetMinMaxValues()
	
	-- Returns the incoming healing from Player/oneself.
	local myIncomingHeal = UnitGetIncomingHeals(unit, "player") or 0
	
	-- Returns the incoming healing from all sources (including Player/oneself).
	local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
	
	-- Returns the total amount of healing the unit can absorb without gaining health.
	local healAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
	
	-- Returns the total amount of damage the unit can absorb before losing health.
	local totalAbsorb = UnitGetTotalAbsorbs(unit) or 0
	
	-- We don't fill outside the health bar with healAbsorbs.  Instead, an overHealAbsorbGlow is shown.
	if ( health < healAbsorb ) then
		frame.overHealAbsorbGlow:Show()
		healAbsorb = health
	else
		frame.overHealAbsorbGlow:Hide()
	end	
	
	-- See how far we're going over the health bar and make sure we don't go too far out of the frame.
	if ( health - healAbsorb + allIncomingHeal > maxHealth ) then
		allIncomingHeal = maxHealth - health + healAbsorb;
	end
	
	local otherIncomingHeal = 0;
	
	-- Split up incoming heals.
	if ( allIncomingHeal >= myIncomingHeal ) then
		otherIncomingHeal = allIncomingHeal - myIncomingHeal;
	else
		myIncomingHeal = allIncomingHeal;
	end
	
	-- We don't fill the outside of the health bar with absorbs.  Instead, an overAbsorbGlow is shown.
	local overAbsorb = false;
	if health - healAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth then
		if totalAbsorb > 0 then
			overAbsorb = true
		end
		
		if allIncomingHeal > healAbsorb then
			totalAbsorb = max(0,maxHealth - (health - healAbsorb + allIncomingHeal))
		else
			totalAbsorb = max(0,maxHealth - health)
		end
	end
	
	if overAbsorb then
		frame.overAbsorbGlow:Show()
	else
		frame.overAbsorbGlow:Hide()
	end

	local healthTexture = frame:GetStatusBarTexture();
	local healAbsorbPercent = 0;
	local healAbsorbTexture = nil;
	
	healAbsorbPercent = healAbsorb / maxHealth;
	
	-- If allIncomingHeal is greater than healAbsorb, then the current heal absorb will be completely overlayed by the incoming heals so we don't show it.
	if healAbsorb > allIncomingHeal then
		local shownHealAbsorb = healAbsorb - allIncomingHeal
		local shownHealAbsorbPercent = shownHealAbsorb / maxHealth
		
		healAbsorbTexture = HealPredictionBar_Fill(frame, healthTexture, frame.healAbsorb, shownHealAbsorb, -shownHealAbsorbPercent)
		
		-- If there are incoming heals the left shadow would be overlayed by the incoming heals so it isn't shown.
		if ( allIncomingHeal > 0 ) then
			frame.healAbsorb.leftShadow:Hide();
		else
			frame.healAbsorb.leftShadow:Show();
		end
		
		-- The right shadow is only shown if there are absorbs on the health bar.
		if ( totalAbsorb > 0 ) then
			frame.healAbsorb.rightShadow:Show();
		else
			frame.healAbsorb.rightShadow:Hide();
		end
	else
		frame.healAbsorb:Hide()
		-- frame.healAbsorbLeftShadow:Hide()
		-- frame.healAbsorbRightShadow:Hide()
	end
	
	-- Show myIncomingHeal on the health bar.
	local incomingHealTexture = HealPredictionBar_Fill(frame, healthTexture, frame.myHealPrediction, myIncomingHeal, -healAbsorbPercent);
	
	-- Append otherIncomingHeal on the health bar
	if (myIncomingHeal > 0) then
		incomingHealTexture = HealPredictionBar_Fill(frame, incomingHealTexture, frame.otherHealPrediction, otherIncomingHeal);
	else
		incomingHealTexture = HealPredictionBar_Fill(frame, healthTexture, frame.otherHealPrediction, otherIncomingHeal, -healAbsorbPercent);
	end
	
	-- Append absorbs to the correct section of the health bar.
	local appendTexture = nil;
	if ( healAbsorbTexture ) then
		-- If there is a healAbsorb part shown, append the absorb to the end of that.
		appendTexture = healAbsorbTexture;
	else
		-- Otherwise, append the absorb to the end of the the incomingHeals part;
		appendTexture = incomingHealTexture;
	end
	HealPredictionBar_Fill(frame, appendTexture, frame.totalAbsorb, totalAbsorb)
	
end

local function HealthBar_OnUpdate(frame, e)
	local unit = frame:GetParent().unit
    if UnitExists(unit) then
		--if not frame.pauseUpdates then
			local currValue = UnitHealth(unit)
			local maxValue = UnitHealthMax(unit)
			
			if maxValue ~= frame.maxValue then
				frame:SetMinMaxValues(0, maxValue)
				frame.maxValue = maxValue
			end
			
			frame.endvalue = currValue
			if currValue ~= frame.currValue then
				frame.currValue = currValue
			 end
			
			if frame.glide then
				Glide(frame, e)
			else
				frame:SetValue(currValue)
			end
			HealthBar_Gradient(frame,e)
			HealthBar_Text(frame)
			HealPredictionBar_Update(frame)
		--end
    end
end

function module:HealthBar_Update(frame)
	local unit = frame:GetParent().unit
	-- if frame.unit == unit then
        local maxValue = UnitHealthMax(unit)
		local currValue = UnitHealth(unit)

		--- For Glide animation!
		frame.startvalue = currValue
		frame.endvalue = currValue
		
		frame.currValue = currValue
		frame.maxValue = maxValue
		
		frame:SetMinMaxValues(0, maxValue)
		frame:SetValue(currValue)
		
		HealthBar_Text(frame)
		HealPredictionBar_Update(frame)
		
		if UnitExists(frame.unit) then
			HealthBar_Gradient(frame)
			
		end
	-- end
end

function module:HealthBar_OnLoad(frame)

	frame.glide = frame:GetAttribute("glide")
	frame.pauseUpdates = false
	frame.statusCounter = 0
	frame.statusSign = -1
	
	if frame.glide then
		local glideFade = frame:GetAttribute("glideFade")
		-- TODO: Override fadetime from in-game.
		if glideFade then
			frame.glideFade = glideFade
		else
			frame.glideFade = 0.35
		end
	end
	
	frame:SetScript("OnUpdate", HealthBar_OnUpdate)
end



--[[

POWERBAR functions

]]


local function PowerBar_Text(frame)
	-- local text = frame:GetAttribute("textFormat")
	local parent = frame:GetParent()
	if frame.parent then
		parent = frame:GetParent():GetParent()
	end
	local text = module:GetTextFormat(parent, "power")
	-- if not UnitIsConnected(frame.unit) UnitIsPlayer(frame.unit) then
		-- text = ""
	-- elseif UnitIsGhost(frame.unit) then
		-- text = ""
	-- elseif (UnitIsDead(frame.unit) or UnitIsCorpse(frame.unit)) then
		-- text = ""
	-- end
	
	if text ~= nil then
		text = text:gsub("$cur", addon:CommaNumber(frame.currValue))
		text = text:gsub("$max", addon:FormatNumber(frame.maxValue))
	end
	
	if frame.text then frame.text:SetText(text) end
end

local function PowerBar_OnEvent(frame, event, ...)
	local arg1 = ...
	local unit = frame:GetParent().unit or frame:GetParent():GetParent().unit
	
	if event == "PLAYER_ENTERING_WORLD" then
		module:PowerBar_Update(frame, unit)
	end
	
	if ( arg1 ~= unit ) then
         return
    end
	
	if event == "UNIT_DISPLAYPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_VEHICLE_ACTIONBAR" then
		module:PowerBar_Update(frame, unit)
	end
end

local function PowerBar_OnUpdate(frame, e)
	local unit = frame:GetParent().unit or frame:GetParent():GetParent().unit
    if UnitExists(unit) then
		if not frame.pauseUpdates then
			local currValue
			local maxValue
			if frame.additional then
				currValue = UnitPower(unit, ADDITIONAL_POWER_BAR_INDEX)
				maxValue = UnitPowerMax(unit, ADDITIONAL_POWER_BAR_INDEX)
			else
				currValue = UnitPower(unit)
				maxValue = UnitPowerMax(unit)
			end
			
			if maxValue ~= frame.maxValue then
				frame:SetMinMaxValues(0, maxValue)
				frame.maxValue = maxValue
			end
			
			frame.endvalue = currValue
			if currValue ~= frame.currValue then
				frame.currValue = currValue
			end

			if frame.glide then
				Glide(frame, e)
			else
				frame:SetValue(currValue)
			end
			PowerBar_Text(frame);
		end
    end
end

local function AdditionalPowerBar_ShowHide(frame)
	local unit = frame:GetParent().unit or frame:GetParent():GetParent().unit
	if UnitPowerType(unit) ~= ADDITIONAL_POWER_BAR_INDEX and UnitPowerMax(unit, ADDITIONAL_POWER_BAR_INDEX) ~= 0 and (not frame.specRestriction or frame.specRestriction == GetSpecialization()) and not UnitHasVehiclePlayerFrameUI("player") then
		frame.pauseUpdates = false
		if frame.parent then
			frame:GetParent():Show()
		else
			frame:Show()
		end

	else
		frame.pauseUpdates = true
		if frame.parent then
			frame:GetParent():Hide()
		else
			frame:Hide()
		end
	end
end

function module:PowerBar_Update(frame)
	local unit = frame:GetParent().unit or frame:GetParent():GetParent().unit
	 -- if unit == frame.unit then
		local powerType
		local powerBarColor
		local maxValue
		local currValue
		if frame.additional then
			powerType = ADDITIONAL_POWER_BAR_INDEX
			maxValue = UnitPowerMax(unit, powerType)
			currValue = UnitPower(unit, powerType)
			AdditionalPowerBar_ShowHide(frame)
		else
			powerType = UnitPowerType(unit)
			maxValue = UnitPowerMax(unit)
			currValue = UnitPower(unit)
		end

		powerBarColor = PowerBarColor[powerType]
		frame:SetStatusBarColor(powerBarColor.r, powerBarColor.g,powerBarColor.b)
		frame.bg:SetVertexColor(powerBarColor.r, powerBarColor.g,powerBarColor.b)
		
		--- For Glide animation!
		frame.startvalue = currValue
		frame.endvalue = currValue
		
		frame.currValue = currValue
		frame.maxValue = maxValue
		
		frame:SetMinMaxValues(0, maxValue);
		frame:SetValue(currValue)
		
		if maxValue == 0 and powerType == 1 then
			frame:Hide()
		else
			frame:Show()
		end
		
		PowerBar_Text(frame)
	-- end
end

function module:PowerBar_OnLoad(frame, unit)
	frame.glide = frame:GetAttribute("glide")
	frame.pauseUpdates = false
	
	if frame.glide then
		local glideFade = frame:GetAttribute("glideFade")
		-- TODO: Override fadetime from in-game.
		if glideFade then
			frame.glideFade = glideFade
		else
			frame.glideFade = 0.35
		end

	end
	
	-- if frame.additional then
		-- AdditionalPowerBar_ShowHide(frame)
	-- end
	
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("UNIT_DISPLAYPOWER")
	
	frame:SetScript("OnEvent", PowerBar_OnEvent)
	frame:SetScript("OnUpdate", PowerBar_OnUpdate)
end

function module:AdditionalPowerBar_OnLoad(frame, unit)
	local class = UnitClass(unit)
	if class == "Druid" or class == "Monk" then
		local statusbar
		if frame.statusbar then
			frame.statusbar.parent = true
			statusbar = frame.statusbar
		else
			statusbar = frame
		end
		
		if class == "Monk" then
			statusbar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
			statusbar.specRestriction = SPEC_MONK_MISTWEAVER
		end
		
		statusbar:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
		statusbar.additional = true
		
		self:PowerBar_OnLoad(statusbar, unit)
	end
end

--[[

CASTBAR functions

]]

local function CastBar_Text(text, statusbar, short, textFormat)
	local orient = statusbar:GetOrientation()
	local out = text
	if textFormat then
		out = textFormat
		out = out:gsub("$spell", text)
	end

	if orient == "VERTICAL" then
		if short then
			out = string.gsub(out, "[^A-Z:0-9.]", "") --fridg
			-- out = string.gsub(out, "R(%d+)", function(s) return " R"..s end)
		end
		local vtext = ""

		for i = 1, string.len(out) do
			vtext = vtext..string.sub(out, i, i).."\n"
		end
		out = vtext
	end
	statusbar.text:SetText(out)
end

local function CastBar_OnEvent(frame, event, unit,...)
	
	local frameUnit = frame:GetParent().unit
	if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TARGET_CHANGED" or event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_FOCUS_CHANGED" then
		local nameChannel  = UnitChannelInfo(frameUnit)
		local nameSpell  = UnitCastingInfo(frameUnit)
		if nameChannel then
			event = "UNIT_SPELLCAST_CHANNEL_START"
			unit = frameUnit
		elseif nameSpell then
			event = "UNIT_SPELLCAST_START"
			unit = frameUnit
		else
			frame:Hide()
			frame:Clear()
		end
	end
	
	if ( unit ~= frameUnit ) then
         return
    end	

	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
		local name, texture, startTime, endTime, castID, notInterruptible
		local r, g, b
		-- frame:Clear() will be called everytime the player changes target. Hmmmm...
		frame:Clear()
		if event == "UNIT_SPELLCAST_START" then
			name, _, texture, startTime, endTime, _, castID, notInterruptible = UnitCastingInfo(unit)
			if not endTime then frame:Hide(); frame:Clear(); return end
			frame.castID = castID
			frame.startTime = GetTime() - (startTime / 1000)
			-- frame.maxValue = (endTime - startTime) / 1000
			r, g, b = 1.0, 0.7, 0.0
			-- frame.statusbar:SetMinMaxValues(0,frame.maxValue)
			frame.channeling = false
			frame.casting = true
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
			name, _, texture, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
			if not endTime then frame:Hide(); frame:Clear(); return end
			frame.startTime = (endTime / 1000) - GetTime()
			-- frame.maxValue = (endTime - startTime) / 1000
			r, g, b = 0.0, 1.0, 0.0
			-- frame.statusbar:SetMinMaxValues(0,frame.maxValue)
			frame.channeling = true
			frame.casting = false
		end
		if notInterruptible then
			r, g, b = 1.0, 0.0, 0.0
		end
		frame.statusbar:SetStatusBarColor(r, g, b)
		frame.maxValue = (endTime - startTime) / 1000
		frame.statusbar:SetMinMaxValues(0,frame.maxValue)
		frame.statusbar:SetValue(frame.startTime)
		frame.icon:SetTexture(texture)
		frame.name = name
		CastBar_Text(frame.name, frame.statusbar, _, frame.textFormat)
		frame:SetAlpha(1.0)
		frame.fadeOut = false
		frame.holdTime = 0
		frame:Show()
	elseif event  == "UNIT_SPELLCAST_INTERRUPTIBLE" then
		local r, g, b
		if frame.casting then
			r, g, b = 1.0, 0.7, 0.0
		else -- Channeling
			r, g, b = 0.0, 1.0, 0.0
		end
		frame.statusbar:SetStatusBarColor(r, g, b)
	elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
		frame.statusbar:SetStatusBarColor(1.0, 0.0, 0.0)
	elseif event  == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		if ( frame.casting and select(1,...) == frame.castID ) or frame.channeling then
			if frame.casting then
				frame.statusbar:SetValue(frame.maxValue)
				frame.statusbar:SetStatusBarColor(0.0, 1.0, 0.0)
				frame.casting = false
			end

			if frame.channeling then
				frame.statusbar:SetValue(0)
				frame.channeling = false
			end
						
			frame.fadeOut = true
			frame.holdTime =  0
		end
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
		if frame.casting and select(1,...) == frame.castID then
			frame.statusbar:SetValue(frame.maxValue)
			frame.statusbar:SetStatusBarColor(1.0, 0.0, 0.0)
			frame.casting = false
			local text
			if event == "UNIT_SPELLCAST_FAILED" then
				text = FAILED
			else
				text = INTERRUPTED
			end
			CastBar_Text(text, frame.statusbar, false)
			frame.fadeOut = true
			frame.holdTime =  GetTime() + CASTING_BAR_HOLD_TIME
		end
	elseif event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
		if frame.casting or frame.channeling then
			local startTime, endTime
			if event == "UNIT_SPELLCAST_DELAYED" then
				_, _, _, startTime, endTime = UnitCastingInfo(unit)
				if not endTime then frame:Hide(); frame:Clear(); return end
				frame.startTime = GetTime() - (startTime / 1000)
				-- frame.maxValue = (endTime - startTime) / 1000
				frame.channeling = false
				frame.casting = true
			elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then		
				_, _, _, startTime, endTime = UnitChannelInfo(unit)
				if not endTime then frame:Hide(); frame:Clear(); return end
				frame.startTime = (endTime / 1000) - GetTime()
				-- frame.maxValue = (endTime - startTime) / 1000
				frame.statusbar:SetValue(frame.startTime)
				frame.channeling = true
				frame.casting = false
			end
			frame.maxValue = (endTime - startTime) / 1000
			frame.statusbar:SetMinMaxValues(0,frame.maxValue)
			frame.fadeOut = false
			frame.holdTime = 0
		end
	end
	
end

local function CastBar_OnUpdate(frame, e)
	if frame.casting then
		frame.startTime = frame.startTime + e
		if frame.startTime >= frame.maxValue then
			frame.statusbar:SetValue(frame.maxValue)
			frame.casting = false
			frame.channeling = false
			frame.fadeOut = true
			return
		end
		frame.time:SetText(string.format("(%.1fs)",frame.maxValue - frame.startTime))
		frame.statusbar:SetValue(frame.startTime)
	elseif frame.channeling then
		frame.startTime = frame.startTime - e
		if frame.startTime <= 0 then
			frame.statusbar:SetValue(0)
			frame.channeling = false
			frame.casting = false
			frame.fadeOut = true
			return
		end
		frame.statusbar:SetValue(frame.startTime)
		frame.time:SetText(string.format("(%.1fs)", frame.startTime))
	elseif GetTime() < frame.holdTime then
		return
	elseif frame.fadeOut then
		local alpha = frame:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if ( alpha > 0 ) then
			frame:SetAlpha(alpha)
		else
			frame:Clear()
			frame:Hide()
		end
	end
end

function module:CastBar_OnLoad(frame, unit)
	if not frame.unit then
		if unit then
			frame.unit = unit
		elseif not unit and frame:GetParent().unit then
			frame.unit = frame:GetParent().unit
		else
			return
		end
	end


	frame.textFormat = frame:GetAttribute("textFormat")
	
	if not frame.statusbar then 
		frame.statusbar = frame -- A bit silly?
	else
		frame.icon = frame.statusbar.icon
		frame.text = frame.statusbar.text
		frame.time = frame.statusbar.time
	end

	function frame:Clear()
		frame.statusbar:SetMinMaxValues(0,0)
		frame.statusbar:SetValue(0)
		frame.icon:SetTexture("")
		frame.text:SetText("")
		frame.time:SetText("")
		frame.casting = false
		frame.channeling = false
		frame.fadeOut = false
		frame.holdTime = 0
	end
	
	frame:Clear()
	

	frame:RegisterEvent("PLAYER_ENTERING_WORLD")	
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
	frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	
	frame:RegisterEvent("UNIT_SPELLCAST_START")
	frame:RegisterEvent("UNIT_SPELLCAST_STOP")
	frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
	frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	frame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
	
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

	frame:SetScript("OnEvent", CastBar_OnEvent)
	frame:SetScript("OnUpdate", CastBar_OnUpdate)
end

--[[

Target of Target and Target of Target's Target! This can keep on going on and on.

]]

local function TargetofTarget_Update(frame, e)
	if UnitExists(frame.unit) then
		module:UpdateName(frame)
	end
end

local function TargetofTarget_OnEvent(frame, event, ...)
	local arg1, arg2, arg3, arg4, arg5 = ...
	TargetofTarget_Update(frame)
	-- if event == "PLAYER_ENTERING_WORLD" then
		-- TargetofTarget_Update(self)
		-- --module:HealthBar_OnLoad(self.hp, self.unit, event)
	-- elseif event == "UNIT_FACTION" then
		-- TargetofTarget_Update(self)
	-- end
end

function module:TargetofTarget_Onload(frame, unit)
	frame.unit = unit
	RegisterUnitWatch(frame)
	-- self.isWatched = true
	-- self:RegisterEvent("PLAYER_ENTERING_WORLD");
	-- self:RegisterEvent("UNIT_FACTION")
	-- frame:RegisterEvent("UNIT_TARGET")

	 
	frame:RegisterForClicks("LeftButtonUp");
	SecureUnitButton_OnLoad(frame, frame.unit)
	self:HealthBar_OnLoad(frame.hp, frame.unit)
	
	-- frame:SetScript("OnEvent", TargetofTarget_OnEvent)
	frame:SetScript("OnUpdate", TargetofTarget_Update)
end

--[[

THREATBAR functions

]]

local function ThreatBar_Text(frame)
	local text = frame:GetAttribute("textFormat")
	local perc = frame:GetAttribute("percFormat")
	
	if text ~= nil then
		text = text:gsub("$cur", addon:CommaNumber(frame.currValue))
	end
	
	if perc ~= nil then
		local percent
		if frame.currValue > 0 then
			percent = frame.currValue / frame.maxValue*100
		else
			percent = 0
		end
		perc = perc:gsub("$perc", format("%.2f", percent).."%%")
	end
	
	if frame.text then frame.text:SetText(text) end
	if frame.perc then frame.perc:SetText(perc) end
end

function module:ThreatBar_Update(frame)
	if not UnitExists(frame.unit) then
		frame:Hide()
		return
	 end
	if UnitIsPlayer(frame.unit) then
		frame:Hide()
		return
	end
	
	if UnitIsDead(frame.unit) then
		frame:Hide()
		return
	end
	
	local isTanking, status, _, rawPercent, threatValue = UnitDetailedThreatSituation(frame.threatUnit, frame.unit)
	
	if not threatValue then
		frame:Hide()
		return
	end
	
	if threatValue == 0 then
		frame:Hide()
		return
	end
	
	local currValue, maxValue
	
	if isTanking then
		currValue = threatValue
		maxValue = threatValue
	else
		currValue = threatValue
		if rawPercent > 0 then
			maxValue = threatValue / rawPercent * 100
		else
			maxValue = threatValue
		end
	end
	
	frame.startvalue = currValue
	frame.endvalue = currValue
	
	frame.currValue = currValue
	frame.maxValue = maxValue
		
	frame:SetMinMaxValues(0, maxValue)
	frame:SetValue(currValue)
		
	ThreatBar_Text(frame)
	frame:SetStatusBarColor(GetThreatStatusColor(status))
	frame:Show()
end

local function ThreatBar_OnEvent(frame,event,...)
	module:ThreatBar_Update(frame)
end

local function ThreatBar_OnUpdate(frame, e)
	if UnitExists(frame.unit) and not UnitIsPlayer(frame.unit) then
		local isTanking, status, _, rawPercent, threatValue = UnitDetailedThreatSituation(frame.threatUnit, frame.unit)
			if not threatValue then
				return
			end
			if threatValue == 0 then
				return
			end
			
			local maxValue, currValue
			
			if isTanking then
				currValue = threatValue
				maxValue = threatValue
			else
				currValue = threatValue
			if rawPercent > 0 then
				maxValue = threatValue / rawPercent * 100
			else
				maxValue = threatValue
			end
			end
			
			if maxValue ~= frame.maxValue then
				frame:SetMinMaxValues(0, maxValue)
				frame.maxValue = maxValue
			end
			frame.endvalue = currValue
			if currValue ~= frame.currValue then
				-- frame:SetMinMaxValues(0, maxValue)
				frame.currValue = currValue
			end
			
			if frame.glide then
				Glide(frame, e)
			else
				frame:SetValue(currValue)
			end
			
			ThreatBar_Text(frame)
			frame:SetStatusBarColor(GetThreatStatusColor(status))
	end
end

function module:ThreatBar_OnLoad(frame, unit)
	if not frame.unit then
		if unit then
			frame.unit = unit
		elseif not unit and frame:GetParent().unit then
			frame.unit = frame:GetParent().unit
		else
			return
		end
	end
	
	frame.glide = frame:GetAttribute("glide")
		if frame.glide then
		local glideFade = frame:GetAttribute("glideFade")
		-- TODO: Override fadetime from in-game.
		if glideFade then
			frame.glideFade = glideFade
		else
			frame.glideFade = 0.35
		end
	end
	frame.threatUnit = "player"
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	frame:SetScript("OnEvent", ThreatBar_OnEvent)
	frame:SetScript("OnUpdate", ThreatBar_OnUpdate)
end


--[[

Buffs, debuffs and stuffs.

]]

local PLAYER_UNITS = {
	player = true,
	vehicle = true,
	pet = true,
}

local ShouldShowDebuffs = TargetFrame_ShouldShowDebuffs

local function UpdateAuraAnchor(auraFrame, index, size)
	local aura = auraFrame["aura"..index]
    if ( index == 1 ) then
		aura:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", 0, 0);
    else
		aura:SetPoint("LEFT", auraFrame["aura"..index-1],"RIGHT", 0, 0);
    end
end

function module:UpdateAuras(frame)
	local normalSize, largeSize = 17, 21
	local aura, auraFrame, auraFrameHeight
	-- local name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, spellId, _
	local playerIsTarget = UnitIsUnit("player", frame.unit)
	local canAssist = UnitCanAssist("player", frame.unit)
	
	local filter;
	if SHOW_CASTABLE_BUFFS == "1" and canAssist then
		filter = "RAID";
	end
	
	local maxBuffs = frame.maxBuffs or MAX_TARGET_BUFFS
	auraFrame = frame.buffs
	auraFrameHeight = normalSize
	for i = 1, maxBuffs do
		local buffName, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _ , spellId, _, _, casterIsPlayer, nameplateShowAll = UnitBuff(frame.unit, i, nil);
		if icon then
			if not auraFrame["aura"..i] then
				auraFrame["aura"..i] = CreateFrame("Button", _, auraFrame, self.db.profile.templatePrefix.."Buff")
			end
			
			aura = auraFrame["aura"..i]
			
			aura.unit = frame.unit
			aura:SetID(i)

			-- set the icon
			aura.icon:SetTexture(icon)

			-- set the count
			if count > 1 and frame.showAuraCount then
				aura.count:SetText(count)
				aura.count:Show()
			else
				aura.count:Hide()
			end
			
			-- Handle cooldowns
			if ( duration > 0 ) then
				aura.cooldown:Show()
				CooldownFrame_Set(aura.cooldown, expirationTime - duration, duration, duration > 0, true)
			else
				aura.cooldown:Hide()
			end

			-- set the buff to be big if the buff is cast by the player or the player's pet
			local size
			if PLAYER_UNITS[caster] then 
				size = largeSize
				auraFrameHeight = largeSize
			else
				size = normalSize
			end
			aura:SetSize(size, size)
			
			-- Show stealable frame if the target is not the current player and the buff is stealable.
			if ( not playerIsTarget and canStealOrPurge ) then
				aura.stealable:Show()
			else
				aura.stealable:Hide()
			end
			
			aura:ClearAllPoints()
			UpdateAuraAnchor(auraFrame, i)
			
			aura:Show()
		else
			if auraFrame["aura"..i] then
				auraFrame["aura"..i]:Hide()
			else
				break
			end
		end
	end
		
	auraFrame:SetHeight(auraFrameHeight)
		
	if SHOW_DISPELLABLE_DEBUFFS == "1" and canAssist then
		filter = "RAID";
	else
		filter = nil;
	end
	
	local frameNum = 1;
	local index = 1;
	local maxDebuffs = frame.maxDebuffs or MAX_TARGET_DEBUFFS
	auraFrame = frame.debuffs
	auraFrameHeight = normalSize
	
	while frameNum <= maxDebuffs do
		-- local debuffName = UnitDebuff(frame.unit, index, filter)
		local debuffName, icon, count, debuffType, duration, expirationTime, caster, _, _, _, _, _, casterIsPlayer, nameplateShowAll = UnitDebuff(frame.unit, index, "INCLUDE_NAME_PLATE_ONLY");
		if debuffName then
			if ShouldShowDebuffs(frame.unit, caster, nameplateShowAll, casterIsPlayer) then
				-- name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitDebuff(frame.unit, index, filter)
				
				if icon then
					if not auraFrame["aura"..frameNum] then
						auraFrame["aura"..frameNum] = CreateFrame("Button", _, auraFrame, self.db.profile.templatePrefix.."Debuff")
					end
					
					aura = auraFrame["aura"..frameNum]
					aura.unit = frame.unit
					
					aura:SetID(index)

					-- set the icon
					aura.icon:SetTexture(icon)

					-- set the count
					if count > 1 and frame.showAuraCount then
						aura.count:SetText(count)
						aura.count:Show()
					else
						aura.count:Hide()
					end

					-- Handle cooldowns
					if duration > 0 then
						aura.cooldown:Show();
						CooldownFrame_Set(aura.cooldown, expirationTime - duration, duration, duration > 0, true)
					else
						aura.cooldown:Hide()
					end

					-- set the debuff to be big if the buff is cast by the player or the player's pet
					local size
					if PLAYER_UNITS[caster] then 
						size = largeSize
						-- largeAuras = true
						auraFrameHeight = largeSize
					else
						size = normalSize
					end
					aura:SetSize(size, size)
					
					-- set debuff type color
					local color
					if debuffType then
						color = DebuffTypeColor[debuffType]
					else
						color = DebuffTypeColor["none"]
					end
					aura.border:SetVertexColor(color.r, color.g, color.b)
					
					aura:ClearAllPoints()
					UpdateAuraAnchor(auraFrame, frameNum)
					
					aura:Show()
					
					frameNum = frameNum + 1
				end
			end
			index = index + 1
		else
			break
		end
	end

	for i = frameNum, MAX_TARGET_DEBUFFS do
		local frame = auraFrame["aura"..i]
		if frame then
			frame:Hide()
		else
			break
		end
	end
	
	auraFrame:SetHeight(auraFrameHeight)
end