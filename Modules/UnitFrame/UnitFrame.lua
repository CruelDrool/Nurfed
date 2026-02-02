---@diagnostic disable: undefined-global
---@diagnostic disable: cast-local-type

local addonName = ...
local moduleName = "UnitFrames"
local displayName = moduleName

---@class Addon
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)

---@class UnitFrames:AddonModule
local module = addon:NewModule(moduleName)
module:SetDefaultModuleLibraries("AceHook-3.0")
module:SetDefaultModuleState(false)

---@class UnitFramesModule:AceModule
---@class UnitFramesModule:AceHook-3.0
---@field db table

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
		-- skins = {
		-- 	keys = {
		-- 		["Nurfed"] = "Nurfed (default)",
		-- 		["Test"] = "Testeleste",
		-- 	},
		-- 	["Nurfed"] = {
		-- 		templatePrefix = "Nurfed_Unit_",
		-- 		glideFade = 0.35,
		-- 		-- statusbartexture = "Interface\\AddOns\\Nurfed\\Images\\statusbar5",
		-- 	},
		-- 	["Test"] = {
		-- 		glideFade = 0.1,
		-- 	},
		-- },
		decimalpoints = 2,
		skin = "Nurfed",
		templatePrefix = "Nurfed_Unit_",
		glideAnimation = {
			enabled = true,
			fadeTimeout = 0.35,
		},
		lowHealthFlash = {
			enabled = true,
			warning = {
				perc = 0.3,
				interval = 1.5,
			},
			dangerous = {
				perc = 0.2,
				interval = 1,
			},
			critical = {
				perc = 0.1,
				interval = 0.5,
			},
		},
		transliterate = {
			enabled = false,
			mark = "!",
		},
		castBar = {
			finishedColorSameAsStart = false,
		},
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
			get = function() return module.db.profile.enabled end,
			set = function(info, value) module.db.profile.enabled = value; if module:IsEnabled() then module:DisableUnitframes() else module:EnableUnitframes() end end,
		},
		showAllDebuffs = {
			order = 2,
			type = "toggle",
			name = "Show all debuffs",
			desc = "Changes the value of the CVar \"noBuffDebuffFilterOnTarget\"",
			get = function() return GetCVarBool("noBuffDebuffFilterOnTarget") end,
			set = function(info, value) SetCVar("noBuffDebuffFilterOnTarget", value) end,
		},
		decimalpoints = {
			hidden = addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE,
			order = 7,
			name = "Decimal points",
			-- desc = "",
			type = "range",
			min = 0, max = 2, step = 1,
			get = function() return module.db.profile.decimalpoints end,
			set = function(info, value) module.db.profile.decimalpoints = value end,
			-- disabled = function() return not module.db.profile.foo end,
		},
		glideanimation = {
			hidden = addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE,
			order = 4,
			type = "group",
			width = "full",
			name = "Glide animation",
			guiInline = true,
			args = {
				enabled = {
					order = 1,
					type = "toggle",
					name = "Enabled",
					width = "full",
					-- desc = "",
					get = function() return module.db.profile.glideAnimation.enabled end,
					set = function(info, value) module.db.profile.glideAnimation.enabled = value end,
				},
				fadetimeout = {
					order = 2,
					name = "Fade timeout",
					-- desc = "",
					type = "range",
					min = 0.05, max = 0.95, step = 0.05,
					get = function() local value = module.db.profile.glideAnimation.fadeTimeout; value=1-value; return value end,
					set = function(info, value) value=1-value; module.db.profile.glideAnimation.fadeTimeout = value end,
					-- disabled = function() return not module.db.profile.foo end,
				},
			},
		},
		lowhealthflash = {
			hidden = addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE,
			order = 5,
			type = "group",
			width = "full",
			name = "Low health flash for friendly units",
			guiInline = true,
			args = {
				enabled = {
					order = 1,
					type = "toggle",
					name = "Enabled",
					width = "full",
					-- desc = "",
					get = function() return module.db.profile.lowHealthFlash.enabled end,
					set = function(info, value) module.db.profile.lowHealthFlash.enabled = value end,
				},
				warning = {
					order = 2,
					type = "group",
					width = "full",
					name = "Warning",
					guiInline = true,
					args = {
						perc = {
							order = 1,
							name = "Percent",
							desc = "Health threshold.",
							type = "range",
							isPercent = true,
							min = 0.01, max = 1, step = 0.01,
							get = function() return module.db.profile.lowHealthFlash.warning.perc end,
							set = function(info, value) module.db.profile.lowHealthFlash.warning.perc = value end,
						},
						interval = {
							order = 2,
							name = "Interval length/duration",
							desc = "How many seconds to complete a full flash cycle (from full opacity to none and back to full again).",
							type = "range",
							min = 0.1, max = 5, step = 0.05,
							get = function() return module.db.profile.lowHealthFlash.warning.interval end,
							set = function(info, value) module.db.profile.lowHealthFlash.warning.interval = value end,
						},
					},
				},
				dangerous = {
					order = 3,
					type = "group",
					width = "full",
					name = "Dangerous",
					guiInline = true,
					args = {
						perc = {
							order = 1,
							name = "Percent",
							desc = "Health threshold.",
							type = "range",
							isPercent = true,
							min = 0.01, max = 1, step = 0.01,
							get = function() return module.db.profile.lowHealthFlash.dangerous.perc end,
							set = function(info, value) module.db.profile.lowHealthFlash.dangerous.perc = value end,
						},
						interval = {
							order = 2,
							name = "Interval length/duration",
							desc = "How many seconds to complete a full flash cycle (from full opacity to none and back to full again).",
							type = "range",
							min = 0.1, max = 5, step = 0.05,
							get = function() return module.db.profile.lowHealthFlash.dangerous.interval end,
							set = function(info, value) module.db.profile.lowHealthFlash.dangerous.interval = value end,
						},
					},
				},
				critical = {
					order = 4,
					type = "group",
					width = "full",
					name = "Critical",
					guiInline = true,
					args = {
						perc = {
							order = 1,
							name = "Percent",
							desc = "Health threshold.",
							type = "range",
							isPercent = true,
							min = 0.01, max = 1, step = 0.01,
							get = function() return module.db.profile.lowHealthFlash.critical.perc end,
							set = function(info, value) module.db.profile.lowHealthFlash.critical.perc = value end,
						},
						interval = {
							order = 2,
							name = "Interval length/duration",
							desc = "How many seconds to complete a full flash cycle (from full opacity to none and back to full again).",
							type = "range",
							min = 0.1, max = 5, step = 0.05,
							get = function() return module.db.profile.lowHealthFlash.critical.interval end,
							set = function(info, value) module.db.profile.lowHealthFlash.critical.interval = value end,
						},
					},
				},
			},
		},
		translit = {
			order = 6,
			type = "group",
			width = "full",
			name = "Transliteration",
			guiInline = true,
			args = {
				intro = {
					order = 1,
					type = "description",
					name = "Convert Cyrillic to Latin.",
				},
				enabled = {
					order = 2,
					type = "toggle",
					name = "Enabled",
					width = "full",
					get = function() return module.db.profile.transliterate.enabled end,
					set = function(info, value) module.db.profile.transliterate.enabled = value end,
				},
				mark = {
					order = 3,
					type = "input",
					name = "Mark",
					width = "half",
					desc = "Mark words that have been transliterated.",
					get = function() return module.db.profile.transliterate.mark end,
					set = function(info, value) module.db.profile.transliterate.mark = value end,
				},
			},

		},
		-- skins = {
		-- 	type = "select",
		-- 	name = "Skins",
		-- 	values = function() return module.db.profile.skins.keys end,
		-- 	get = function() return module.db.profile.skin end,
		-- 	set = function(info, value)
		-- 		module.db.profile.skin = tostring(value)
		-- 		for k, v in pairs(module.db.profile.skins[value]) do
		-- 			module.db.profile[k] = v
		-- 		end
		-- 	end,
		-- },
		formats = {
			order = 3,
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
					get = function() return module:GetTextFormat("name") end,
					set = function(info, value) module.db.profile.formats.name = value;for k in pairs(module.frames) do module:UpdateInfo(_G[k]) end end,
				},
				infoline = {
					order = 2,
					type = "input",
					name = "Infoline",
					-- desc = "",
					get = function() return module:GetTextFormat("infoline") end,
					set = function(info, value) module.db.profile.formats.infoline = value;for k in pairs(module.frames) do module:UpdateInfo(_G[k]) end  end,
				},
				health = {
					order = 3,
					type = "input",
					name = "Health",
					-- desc = "",
					get = function() return module:GetTextFormat("health") end,
					set = function(info, value) module.db.profile.formats.health = value;for k in pairs(module.frames) do module:UpdateInfo(_G[k]) end  end,
				},
				power = {
					order = 4,
					type = "input",
					name = "Power",
					-- desc = "",
					get = function() return module:GetTextFormat("power") end,
					set = function(info, value) module.db.profile.formats.power = value; end,
				},
				threat = {
					order = 5,
					type = "input",
					name = "Threat",
					-- desc = "",
					get = function() return module:GetTextFormat("threat") end,
					set = function(info, value) module.db.profile.formats.threat = value end,
				},
			},
		},
		castBar = {
			order = 9,
			type = "group",
			width = "full",
			name = "Cast bar",
			guiInline = true,
			args = {
				finishedColorSameAsStart = {
					order = 1,
					type = "toggle",
					name = "Finished cast color same as start",
					width = "full",
					get = function() return module.db.profile.castBar.finishedColorSameAsStart end,
					set = function(info, value) module.db.profile.castBar.finishedColorSameAsStart = value end,
				},
			},
		},
	},
}

module.UIhider = CreateFrame("Frame", nil, nil, "Nurfed_UI_Hider_Template")
module.frames = {}

function module:OnInitialize()
	-- Go through each module and get the options and default DB values.
	for name, m in self:IterateModules() do
		if m.options then
			if not self.options.args[name] then
				self.options.args[name] = m.options
			end
		end
		-- Need to do this part because we have modules to this module and
		-- the child-databases (created by :RegisterNamespace) only have :RegisterDefaults and :ResetProfile available.
		if m.defaults then
			defaults.profile[name] = m.defaults
		end
	end

	-- Register DB namespace
	self.db = addon.db:RegisterNamespace(moduleName, defaults)

	-- And then go through the modules again to givem them access to their databases.
	for name, m in self:IterateModules() do
		m.db = self.db.profile[name]
	end

	-- Register callbacks
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateConfigs")

	self.locked = true

	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	-- Enable if we're supposed to be enabled
	if self.db.profile.enabled then
		self:Enable()
	end
end

local runOnPlayerEnteringWorld = {}

function module:RunOnPlayerEnteringWorld(...)
	addon:AddToFuncQueue(runOnPlayerEnteringWorld, ...)
end

local isPlayerInWorld = false

function module:PLAYER_ENTERING_WORLD()
	isPlayerInWorld = true
	addon:EmptyFuncQueue(runOnPlayerEnteringWorld)
end

function module:IsPlayerInWorld()
	return isPlayerInWorld
end

-- Go through modules and enable/disable those that should be.
function module:ToggleModules()
	for name, m in self:IterateModules() do
		if m.db.enabled then
			m:Enable()
		else
			m:Disable()
		end
	end
end

function module:OnEnable()
	self:SecureHook(addon.LDBObj,"OnClick", function(frame, msg)
		if msg == "LeftButton" then
			module:Lock()
			addon.LDBObj.OnTooltipShow(LibDBIconTooltip)
		end
	end)

	self:SecureHook(addon.LDBObj,"OnTooltipShow", function(tooltip)
		if module.locked then
			tooltip:AddLine(string.format("Left Click - %s UI", addon:WrapTextInColorCode("Unlock", {1, 0, 0})), addon:UnpackColorTable(addon.colors.tooltipLine))
		else
			tooltip:AddLine(string.format("Left Click - %s UI", addon:WrapTextInColorCode("Lock", {0, 1, 0})), addon:UnpackColorTable(addon.colors.tooltipLine))
		end
	end)

	if LDBTitan and _G["TitanPanel"..addonName.."Button"] then
		LDBTitan:TitanLDBHandleScripts("OnTooltipShow", addonName, nil, addon.LDBObj.OnTooltipShow, addon.LDBObj)
		LDBTitan:TitanLDBHandleScripts("OnClick", addonName, nil, addon.LDBObj.OnClick)
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED")

	if self:IsPlayerInWorld() then
		self:ToggleModules()
	end

	self.db.profile.enabled = true
end

function module:OnDisable()
	self:UnhookAll()
	self:UnregisterAllEvents()
	self.db.profile.enabled = false
	-- for name, m in self:IterateModules() do
		-- m:Disable()
	-- end

end

function module:EnableUnitframes()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("Enable", module)
		addon:InfoMessage(string.format(addon.infoMessages.enableModuleInCombat, addon:WrapTextInColorCode(displayName, addon.colors.moduleName)))
		return
	end
	self:Enable()
end

function module:DisableUnitframes()
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("Disable", module)
		addon:InfoMessage(string.format(addon.infoMessages.disableModuleInCombat, addon:WrapTextInColorCode(displayName, addon.colors.moduleName)))
		return
	end

	if not self.locked then
		self:Lock()
	end

	self:Disable()
end

function module:UpdateConfigs()
	-- Go through the modules again to give them access to their databases.
	for name, m in self:IterateModules() do
		m.db = self.db.profile[name]
	end

	if self.db.profile.enabled then
		-- If profile says that the module is supposed to enabled, but it isn't already, then go ahead and enable it.
		if not self:IsEnabled() then
			self:Enable()
		else
		-- Already enabled. Go through modules and enable/disable those that should be.
			self:ToggleModules()
		end
	else
		-- If the module is currently enabled, but isn't supposed to, then disable it.
		if self:IsEnabled() then
			self:Disable()
		end
	end

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

	-- Go through the modules again, run :UpdateConfigs() if they have one.
	for _, m in self:IterateModules() do
		if m.UpdateConfigs then
			m:UpdateConfigs()
		end
	end
end

function module:CreateFrame(modName, unit, events, oneventfunc, isWatched, id)
	if not self:GetModule(modName) then return end
	if not type(unit) == "string" then return end
	if not type(events) == "table" then return end
	if not id then id = 0 end

	local name = addonName.."_"..unit
	local template = self.db.profile.templatePrefix..unit

	if id > 0 then name = name..id end

	if self.frames[name] then return end

	local frame = CreateFrame("Button", name, UIParent, PingableType_UnitFrameMixin and template..", PingReceiverAttributeTemplate" or template , id)

	if PingableType_UnitFrameMixin then
		Mixin(frame, PingableType_UnitFrameMixin)
	end

	if id > 0 then
		frame.unit = unit..id
	else
		frame.unit = unit
	end

	if isWatched then
		-- RegisterUnitWatch(frame);
		frame.isWatched = true
	end

	for _, event in pairs(events) do
		if type(event) == "string" then
			frame:RegisterEvent(event)
		end
	end

	if frame.health then self:HealthBar_OnLoad(frame.health, frame.unit) end
	if frame.powerBar then self:PowerBar_OnLoad(frame.powerBar, frame.unit) end
	if frame.target then self:TargetofTarget_Onload(frame.target, frame.unit.."target") end
	if frame.targettarget then self:TargetofTarget_Onload(frame.targettarget, frame.unit.."targettarget") end
	if frame.pet then self:TargetofTarget_Onload(frame.pet, unit.."pet"..id) end -- partypetN, not partyNpet!
	if frame.buffs or frame.debuffs then frame.showAuraCount = true end

	if frame.cast then self:CastBar_OnLoad(frame.cast, frame.unit) end

	if frame.threat then self:ThreatBar_OnLoad(frame.threat, frame.unit) end

	if type(oneventfunc) == "function" then
		frame:SetScript("OnEvent", oneventfunc)
	end

	frame:SetScript("OnMouseWheel", function(f, delta) module:OnMouseWheel(f, delta) end)

	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	frame:SetAttribute("*type1", "target")
	frame:SetAttribute("*type2", "togglemenu")
	frame:SetAttribute("unit", frame.unit)

	local db = self.db.profile[modName].frames[frame.unit]
	LibStub("LibWindow-1.1"):Embed(frame)
	frame.RegisterConfig(frame, db)

	self.frames[name] = modName

	return frame
end

function module:SetParent(frame, parent)
	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("SetParent", self, frame, parent)
		return
	end

	frame:SetParent(parent)
end

function module:DisableFrame(frame)
	frame.isEnabled = false
	frame:SetParent(self.UIhider)
	if frame.isWatched then
		UnregisterUnitWatch(frame)
		frame:Show()
	end
end

function module:EnableFrame(frame)
	frame:SetParent(UIParent)
	frame:SetFrameStrata("LOW")
	frame:RestorePosition(frame)
	if frame.isWatched and self.locked then
		RegisterUnitWatch(frame)
	elseif not self.locked then
		frame.overlay:Show()
	end
	self:UpdateModel(frame)
	frame.isEnabled = true
end

function module:ShowHideHighlight(frame)
	if UnitExists("target") and UnitIsUnit("target", frame.unit) then
		frame:LockHighlight()
	else
		frame:UnlockHighlight()
	end
end

function module:Lock()

	if InCombatLockdown() then
		addon:AddOutOfCombatQueue("Lock", self)
		addon:InfoMessage("Unlocking the UI when combat ends.")
		return
	end

	if not self:IsEnabled() then
		return
	end

	-- if module.locked and not InCombatLockdown() then
	if module.locked then
		module.locked = false
		addon.LDBObj.icon = "Interface\\AddOns\\"..addonName.."\\Images\\unlocked"
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		for f in pairs(module.frames) do
			local frame = _G[f]
			if frame.isEnabled then
				frame.overlay:Show()
				if frame.isWatched then
					UnregisterUnitWatch(frame)
				end
				frame:Show()
				self:UpdateModel(frame)
			end
		end
	elseif not module.locked then
		module.locked = true
		addon.LDBObj.icon = "Interface\\AddOns\\"..addonName.."\\Images\\locked"
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
		for f in pairs(module.frames) do
			local frame = _G[f]
			frame.overlay:Hide()
			if frame.isEnabled then
				self:UpdateModel(frame)
				if frame.isWatched then
					RegisterUnitWatch(frame)
				elseif frame.hidden then
					frame:Hide()
				end
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


function module:GetTextFormat(f,frame, modName)
	if not (self.db and self.db.profile) then return "" end
	modName = modName or frame and self.frames[frame:GetName()]

	if modName ~= nil then
		if self.db.profile[modName] and self.db.profile[modName].formats then
			if self.db.profile[modName].formats[f] then
				if self.db.profile[modName].formats[f] == "" then
					if defaults.profile[modName].formats[f] then
						return defaults.profile[modName].formats[f]
					elseif self.db.profile.formats[f] and self.db.profile.formats[f] ~= "" then
						return self.db.profile.formats[f]
					elseif defaults.profile.formats[f] then
						return defaults.profile.formats[f]
					end
				end
				return self.db.profile[modName].formats[f]
			elseif self.db.profile.formats and self.db.profile.formats[f] then
				if self.db.profile.formats[f] == "" then
					return defaults.profile.formats[f]
				end
				return self.db.profile.formats[f]
			end
			return ""
		end
	else
		if self.db.profile.formats[f] then
			if self.db.profile.formats[f] == "" then
				return defaults.profile.formats[f]
			end
			return self.db.profile.formats[f]
		end
		return ""
	end
end

function module:FormatPercentage(number, substitution)
	return format("%."..tostring(self.db.profile.decimalpoints).."f", number).. (substitution and "%%" or "%")
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

local CreatureTypeReverseLocalisation = LibStub("LibBabble-CreatureType-3.0"):GetReverseLookupTable()

local function GetUnitClassColor(unit)
	local creatureType = not addon:IsSecretValue(UnitCreatureType(unit)) and CreatureTypeReverseLocalisation[UnitCreatureType(unit)] or ""
	local color = {1,1,1}
	if UnitIsPlayer(unit) or (creatureType == "Humanoid" and UnitIsFriend("player", unit) and UnitPlayerOrPetInParty(unit)) then
		local _, englishClass = UnitClass(unit)
		if RAID_CLASS_COLORS[englishClass] ~= nil then color = RAID_CLASS_COLORS[englishClass] else color = {UnitSelectionColor(unit)} end
	else
		-- if not UnitPlayerControlled(unit) and UnitIsTapped(unit) then
			-- if not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit) then
				-- color = "|cff7f7f7f"
			-- elseif UnitIsTappedByPlayer(unit) or UnitIsTappedByAllThreatList(unit) then
				-- color = addon:rgbhex(UnitSelectionColor(unit))
			-- end
		if not UnitPlayerControlled(unit) then
			if UnitIsTapDenied(unit) then
				-- color = "ff7f7f7f"
				color = {0.5,0.5,0.5}
			else
				color = {UnitSelectionColor(unit)}
			end
		else
			if UnitPlayerControlled(unit) and (creatureType == "Beast" or creatureType == "Demon" or creatureType == "Elemental" or creatureType == "Undead") then
				-- unit is a pet/minion
				-- color = "ff005500"
				color = {0,1/3,0}
			else
				-- color = addon:rgbhex(UnitSelectionColor(unit))
				color = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
			end
		end
	end

	return color
end

function module:Replace(unit, textFormat)
	if textFormat == nil then return "" end
	if not UnitExists(unit) then return textFormat end
	-- local unit = frame.unit

	local textReplacements = {}

	local out = textFormat
	if string.find(textFormat,"$name") then
		local name = UnitName(unit)

		if not addon:IsSecretValue(name) and self.db.profile.transliterate.enabled then
			name = addon:Transliterate(name, self.db.profile.transliterate.mark)
		end

		local color = GetUnitClassColor(unit)

		name = addon:WrapTextInColorCode(name, color)

		table.insert(textReplacements, {"$name", name})
	end

	if string.find(textFormat,"$pvpname") then
		local name = UnitPVPName(unit)

		if not addon:IsSecretValue(name) and self.db.profile.transliterate.enabled then
			name = addon:Transliterate(name, self.db.profile.transliterate.mark)
		end

		local color = GetUnitClassColor(unit)

		name = addon:WrapTextInColorCode(name, color)

		table.insert(textReplacements, {"$pvpname", name})
	end

	if string.find(textFormat,"$guild") then
		local guildName = GetGuildInfo(unit) or ""
		if guildName ~= "" then
			-- local color = "ff00bfff"
			local color = {0,0.75,1}
			if UnitIsInMyGuild(unit) then
				-- color = "ffff00ff"
				color = {1,0,1}
			end

			if self.db.profile.transliterate.enabled then
				guildName = addon:Transliterate(guildName, self.db.profile.transliterate.mark)
			end
			guildName = addon:WrapTextInColorCode(guildName, color)

		end

		table.insert(textReplacements, {"$guild", guildName})
	end

	if string.find(textFormat,"$level") then
		local level = UnitEffectiveLevel and UnitEffectiveLevel(unit) or UnitLevel(unit)
		-- local level = UnitLevel(unit)
		local classification = UnitClassification(unit)
		local r, g, b
		if level > 0 then
			-- r, g, b = GetRelativeDifficultyColor(UnitLevel("player"), level)
			r, g, b = addon:UnpackColorTable(GetRelativeDifficultyColor(UnitEffectiveLevel and UnitEffectiveLevel("player") or UnitLevel("player"), level))
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

		if UnitIsWildBattlePet and ( UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) ) then
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
			r, g, b =  addon:UnpackColorTable(GetRelativeDifficultyColor(highestLevelPet, level))
		end
		level = addon:WrapTextInColorCode(level, {r, g, b})

		table.insert(textReplacements, {"$level", level})
	end

	if string.find(textFormat,"$class") then
		local class = ""
		if UnitIsPlayer(unit) then
			local englishClass
			class, englishClass = UnitClass(unit)
			if not class then class = "Unknown" end
			if RAID_CLASS_COLORS[englishClass] then
				class = addon:WrapTextInColorCode(class, RAID_CLASS_COLORS[englishClass])
			else
				class = addon:WrapTextInColorCode(class, {UnitSelectionColor(unit)})
			end
		else
			local creatureType = not addon:IsSecretValue(UnitCreatureType(unit)) and CreatureTypeReverseLocalisation[UnitCreatureType(unit)] or ""

			if creatureType == "Humanoid" and UnitIsFriend("player", unit) then
				class = "NPC"
			elseif UnitCreatureFamily(unit) then
				class = UnitCreatureFamily(unit)
			elseif UnitIsWildBattlePet and ( UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) ) then
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

		table.insert(textReplacements, {"$class", class})
	end

	if string.find(textFormat,"$race") then
		local race = ""
		if UnitIsPlayer(unit) then
			race = UnitRace(unit)
		end
		table.insert(textReplacements, {"$race", race})
	end

	if string.find(textFormat,"$sex") then
		local sexes = {UNKNOWN, MALE, FEMALE}
		table.insert(textReplacements, {"$sex", sexes[UnitSex(unit)]})
	end

	if string.find(textFormat,"$group") then
		local group = ""
		local groupNumber = NONE
		if UnitIsPlayer(unit) and UnitPlayerOrPetInParty(unit) and IsInRaid() then
			groupNumber = RaidInfo(unit)
		end

		groupNumber = addon:WrapTextInColorCode(groupNumber, {1,1,0})
		group = string.format("%s: %s", GROUP, groupNumber)
		table.insert(textReplacements, {"$group", group})
	end

	if string.find(textFormat,"$g") then
		local g = ""
		local groupNumber = NONE
		if UnitIsPlayer(unit) and UnitPlayerOrPetInParty(unit) and IsInRaid() then
			groupNumber = RaidInfo(unit)
		end

		groupNumber = addon:WrapTextInColorCode(groupNumber, {1,1,0})
		g = string.format("%s: %s", string.sub(GROUP, 0, 1), groupNumber)
		table.insert(textReplacements, {"$g", g})
	end

	if string.find(textFormat,"$realm") then
		local realm = select(2,UnitFullName(unit)) or ""
		table.insert(textReplacements, {"$realm", realm})
	end

	if string.find(textFormat,"$title") then
		local title = UnitPVPName(unit)

		if not addon:IsSecretValue(title) then
			title = title:gsub(UnitName(unit).."%p?%s?","")

			title = title:gsub("^%l?", function(l)
					return string.upper(l)
				end)

		else
			title = ""
		end

		table.insert(textReplacements, {"$title", title})
	end

	if string.find(textFormat,"$key") then
		local binding = ""
		if keyBindingsMap[unit] then
			binding = addon:Binding(GetBindingKey(keyBindingsMap[unit]))
		end

		table.insert(textReplacements, {"$key", binding})
	end

	local subtitutes = {}
	for k, v in ipairs(textReplacements) do
		out = out:gsub(v[1], format("%%%%%d$%s", k, type(v[1]) == "string" and "s" or "d"))
		table.insert(subtitutes, v[2])
	end

	return out:format(unpack(subtitutes))

end

--------------------------------------------

 -- TODO: Check that Classic can use C_PartyInfo.GetLootMethod().
local lootMethods = {
	[0] = "freeforall", -- Enum.LootMethod.Freeforall
	[1] = "roundrobin", -- Enum.LootMethod.Roundrobin
	[2] = "master", -- Enum.LootMethod.Masterlooter
	[3] = "group", -- Enum.LootMethod.Group
	[4] = "needbeforegreed", -- Enum.LootMethod.Needbeforegreed
	[5] = "personalloot", -- Enum.LootMethod.Personal
}

local GetLootMethod = _G["GetLootMethod"] or function()
	local lootMethodId, masterlooterPartyID, masterlooterRaidID = C_PartyInfo.GetLootMethod()
	return lootMethods[lootMethodId], masterlooterPartyID, masterlooterRaidID
end

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
		if HasLFGRestrictions and HasLFGRestrictions() then
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

local GetTexCoordsForRoleSmallCircle = _G["GetTexCoordsForRoleSmallCircle"]  or function(role)
	if ( role == "TANK" ) then
		return 0, 19/64, 22/64, 41/64;
	elseif ( role == "HEALER" ) then
		return 20/64, 39/64, 1/64, 20/64;
	elseif ( role == "DAMAGER" ) then
		return 20/64, 39/64, 22/64, 41/64;
	else
		error("Unknown role: "..tostring(role));
	end
end;

function module:UpdateRoles(frame)
    local LFGRole = UnitGroupRolesAssigned and UnitGroupRolesAssigned(frame.unit) or "NONE"
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
	local textFormat = self:GetTextFormat("name", frame)
	local name
	if textFormat ~= nil then
		name = self:Replace(frame.unit, textFormat)
	end
	frame.name:SetText(name)
end

function module:UpdateLevel(frame)
	local textFormat = self:GetTextFormat("level", frame)
	local level
	if textFormat ~= nil then
		level = self:Replace(frame.unit, textFormat)
	end

	frame.level:SetText(level)
end

function module:UpdateGroupIndicator(frame)
	local textFormat = self:GetTextFormat("group", frame)
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
		local textFormat = self:GetTextFormat("infoline", frame)
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

function module:UpdateModel(frame)
	if not frame.model then return end
	local unit = frame.unit
	local model = frame.model
	if not UnitExists(unit) then
		model:ClearModel()
		model.portrait:Hide()
		return
	end
	model:SetUnit(unit)
	model:RefreshUnit()
	model:SetPortraitZoom(1)
	if model.portrait then
		SetPortraitTexture(model.portrait, unit)
		if not UnitIsVisible(unit) then
			model.portrait:Show()
		else
			model.portrait:Hide()
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
		self:UpdateModel(frame)
	end
end

local function Glide(frame, e)
	if not frame.startvalue or not module.db.profile.glideAnimation.enabled then frame:SetValue(frame.endvalue); return end
	if module.db.profile.glideAnimation.fadeTimeout < 1 then
		frame.fade = module.db.profile.glideAnimation.fadeTimeout
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


local GetSpellInfo = _G["GetSpellInfo"] or function(...)
	local info = C_Spell.GetSpellInfo(...)
	if info then
		return info.name,
		nil,
		info.iconID,
		info.castTime,
		info.minRange,
		info.maxRange,
		info.spellID,
		info.originalIconID
	end
end

local GHOST

local function HealthBar_Text(frame)
	local unit = frame:GetParent().unit

	local healthInfo = module:GetTextFormat("health", frame:GetParent())
	local miss = module:GetTextFormat("miss", frame:GetParent())
	local perc = module:GetTextFormat("perc", frame:GetParent())

	-- if frame.disconnected then
	if not UnitIsConnected(unit) and UnitIsPlayer(unit) then
		perc = PLAYER_OFFLINE
		miss = ""
	elseif UnitIsGhost(unit) then
		if not GHOST then
			GHOST = GetSpellInfo(8326)
		end
		perc = GHOST
		miss = ""
	elseif (UnitIsDead(unit) or UnitIsCorpse(unit)) then
		perc = DEAD
		miss = ""
	elseif UnitHealthPercent then
		perc = format("%d%%",UnitHealthPercent(frame.unit, false, CurveConstants.ScaleTo100))
		miss = AbbreviateNumbers(UnitHealthMissing(frame.unit))
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
			perc = perc:gsub("$perc", module:FormatPercentage(percent, true))
		end
	end

	if healthInfo ~= nil then
		healthInfo = healthInfo:gsub("$cur", "%%1$s")
		healthInfo = healthInfo:gsub("$max", "%%2$s")
		healthInfo = healthInfo:format(addon:CommaNumber(frame.currValue), addon:FormatNumber(frame.maxValue))
	end

	if frame.texts then
		if frame.texts.missing then frame.texts.missing:SetText(miss) end
		if frame.texts.healthInfo then frame.texts.healthInfo:SetText(healthInfo) end
	end
	if frame.perc then frame.perc:SetText(perc) end

end

local function HealthBar_Gradient(frame, elapsed, gradient)
	if C_CurveUtil then
		local color = UnitHealthPercent(frame.unit, true, frame.colorCurve)
		frame:GetStatusBarTexture():SetVertexColor(color:GetRGBA())
		return
	end
	if not gradient then gradient = 0 end
	if frame.maxValue == 0 then return end
	-- local unit = frame:GetParent().unit
	local alpha = 1;
	local perc = frame.currValue / frame.maxValue

	if module.db.profile.lowHealthFlash and module.db.profile.lowHealthFlash.enabled and UnitIsFriend("player", frame:GetParent().unit) and perc <= module.db.profile.lowHealthFlash.warning.perc then
		local interval = module.db.profile.lowHealthFlash.warning.interval

		if perc <= module.db.profile.lowHealthFlash.dangerous.perc then
			interval = module.db.profile.lowHealthFlash.dangerous.interval
		end

		if perc <= module.db.profile.lowHealthFlash.critical.perc then
			interval = module.db.profile.lowHealthFlash.critical.interval
		end

		-- Safety measure to avoid dividing by zero later on.
		interval = interval > 0 and interval or 1

		if elapsed then
			-- Get current alpha value.
			local a = select(4, frame:GetStatusBarColor())

			-- Calculate how much to reduce/increase the alpha value by.
			-- Half the interval duration is spent reducing the alpha, the other half is spent increasing it.
			local step = elapsed / (interval * 0.5)

			-- frame.statusSign determines whether the alpha is reduced or increased.
			alpha = a - step * frame.statusSign

			-- If the alpha value goes under 0 or over 1, switch frame.statusSign to either 1 or -1. Initially it's set to 1 in the OnLoad function.
			if alpha <= 0 or alpha >= 1 then
				frame.statusSign = -frame.statusSign;
			end

			-- As of patch 10.0.0, we're not alllowed to set alpha values below 0 or above 1.
			alpha = alpha >= 0 and alpha or 0
			alpha = alpha <= 1 and alpha or 1
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

local function PredictionBar_Fill(frame, previousTexture, bar, amount, barOffsetXPercent, totalMax)
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

	local totalWidth = frame:GetWidth()
	totalMax = totalMax or select(2, frame:GetMinMaxValues())
	-- local _, totalMax = frame:GetMinMaxValues()

	local barSize = (amount / totalMax) * totalWidth

	bar:SetWidth(barSize)
	bar:Show()
	return bar
end

local function HealthBar_HealthPredictions_Old(frame)
	if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then return end

	if not frame.myHealPrediction or not frame.otherHealPrediction or not frame.totalAbsorb or not frame.healAbsorbOld then
		return
	end

	local unit = frame:GetParent().unit
	local health = frame:GetValue()
    local _, maxHealth = frame:GetMinMaxValues()
	if maxHealth == 0 then return end

	-- Returns the incoming healing from Player/oneself.
	local myIncomingHeal = UnitGetIncomingHeals and UnitGetIncomingHeals(unit, "player") or 0

	-- Returns the incoming healing from all sources (including Player/oneself).
	local allIncomingHeal = UnitGetIncomingHeals and UnitGetIncomingHeals(unit) or 0

	-- Returns the total amount of healing the unit can absorb without gaining health.
	local healAbsorb = UnitGetTotalHealAbsorbs and  UnitGetTotalHealAbsorbs(unit) or 0

	-- Returns the total amount of damage the unit can absorb before losing health.
	local totalAbsorb = UnitGetTotalAbsorbs and UnitGetTotalAbsorbs(unit) or 0

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

		healAbsorbTexture = PredictionBar_Fill(frame, healthTexture, frame.healAbsorbOld, shownHealAbsorb, -shownHealAbsorbPercent)

		-- If there are incoming heals the left shadow would be overlayed by the incoming heals so it isn't shown.
		if ( allIncomingHeal > 0 ) then
			frame.healAbsorbOld.leftShadow:Hide();
		else
			frame.healAbsorbOld.leftShadow:Show();
		end

		-- The right shadow is only shown if there are absorbs on the health bar.
		if ( totalAbsorb > 0 ) then
			frame.healAbsorbOld.rightShadow:Show();
		else
			frame.healAbsorbOld.rightShadow:Hide();
		end
	else
		frame.healAbsorbOld:Hide()
		-- frame.healAbsorbOldLeftShadow:Hide()
		-- frame.healAbsorbOldRightShadow:Hide()
	end

	-- Show myIncomingHeal on the health bar.
	local incomingHealTexture = PredictionBar_Fill(frame, healthTexture, frame.myHealPrediction, myIncomingHeal, -healAbsorbPercent);

	-- Append otherIncomingHeal on the health bar
	if (myIncomingHeal > 0) then
		incomingHealTexture = PredictionBar_Fill(frame, incomingHealTexture, frame.otherHealPrediction, otherIncomingHeal);
	else
		incomingHealTexture = PredictionBar_Fill(frame, healthTexture, frame.otherHealPrediction, otherIncomingHeal, -healAbsorbPercent);
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
	PredictionBar_Fill(frame, appendTexture, frame.totalAbsorb, totalAbsorb)

end


local function HealthBar_HealthPredictions(frame)

	if addon.WOW_PROJECT_ID ~= addon.WOW_PROJECT_ID_MAINLINE then return end

	local maxHealth = UnitHealthMax(frame.unit)
	local healerUnit = "player"
	UnitGetDetailedHealPrediction(frame.unit, healerUnit, frame.predictionCalc)

	local totalHealAmount, amountFromHealer, amountFromOthers, healClamped = frame.predictionCalc:GetIncomingHeals()

	if frame.predictAllHeals then
		frame.predictAllHeals:SetMinMaxValues(0, maxHealth)
		frame.predictAllHeals:SetValue(totalHealAmount)
		frame.predictAllHeals:SetAlpha(1)
	end

	if frame.predictMyHeals then
		frame.predictMyHeals:SetMinMaxValues(0, maxHealth)
		frame.predictMyHeals:SetValue(amountFromHealer)
		frame.predictMyHeals:SetAlpha(1)
	end

	local damageAbsorbAmount, damageAbsorbClamped = frame.predictionCalc:GetDamageAbsorbs()

	if frame.damageAbsorb then
		frame.damageAbsorb:SetMinMaxValues(0,maxHealth)
		frame.damageAbsorb:SetValue(damageAbsorbAmount)
		frame.damageAbsorb:SetAlpha(0.75)

		frame.damageAbsorb.overflowIndicator:SetAlphaFromBoolean(damageAbsorbClamped, 1, 0)
	end

	local healAbsorbAmount, healAbsorbClamped = frame.predictionCalc:GetHealAbsorbs()

	if frame.healAbsorb then
		frame.healAbsorb:SetMinMaxValues(0,maxHealth)
		frame.healAbsorb:SetValue(healAbsorbAmount)
		frame.healAbsorb:SetAlpha(1)

		frame.healAbsorb.overflowIndicator:SetAlphaFromBoolean(healAbsorbClamped, 1, 0)
	end
end

local function HealthBar_OnUpdate(frame, e)
	local unit = frame.unit
    -- if UnitExists(unit) then
		--if not frame.pauseUpdates then
			local currValue = UnitHealth(unit)
			local maxValue = UnitHealthMax(unit) -- Sometimes not a secret value. Very confusing.

			if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then
				frame.currValue = currValue
				frame.maxValue = maxValue
				frame:SetValue(currValue)
				frame:SetMinMaxValues(0, maxValue)
			else
				if maxValue ~= frame.maxValue then
					frame:SetMinMaxValues(0, maxValue)
					frame.maxValue = maxValue
				end

				frame.endvalue = currValue
				if currValue ~= frame.currValue then
					frame.currValue = currValue
				end

				Glide(frame, e)
			end

			HealthBar_Gradient(frame,e)

			HealthBar_Text(frame)
		--end
    -- end
end

function module:HealthBar_Update(frame)
	local unit = frame.unit
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

		HealthBar_HealthPredictions(frame)
		HealthBar_HealthPredictions_Old(frame)

		if UnitExists(frame.unit) then
			HealthBar_Gradient(frame)
		end
	-- end
end

function HealthBar_OnEvent(frame, event, ...)
	HealthBar_HealthPredictions(frame)
	HealthBar_HealthPredictions_Old(frame)
end

function module:HealthBar_OnLoad(frame, unit)

	frame.unit = unit
	if C_CurveUtil then
		frame.colorCurve = C_CurveUtil.CreateColorCurve()
		frame.colorCurve:AddPoint(0, CreateColor(1, 0, 0))
		frame.colorCurve:AddPoint(0.5, CreateColor(1, 1, 0))
		frame.colorCurve:AddPoint(1, CreateColor(0, 1, 0))
	end


	if frame.predictMyHeals then
		frame.predictMyHeals:SetSize(frame:GetSize())
		frame.predictMyHeals:SetPoint("TOPLEFT", frame:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		frame.predictMyHeals:SetPoint("BOTTOMLEFT", frame:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	end

	if frame.predictAllHeals then
		frame.predictAllHeals:SetSize(frame:GetSize())
		frame.predictAllHeals:SetPoint("TOPLEFT", frame:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		frame.predictAllHeals:SetPoint("BOTTOMLEFT", frame:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	end

	if frame.damageAbsorb then
		frame.damageAbsorb.overlay:ClearAllPoints()
		frame.damageAbsorb.overlay:SetPoint("TOPLEFT", frame.damageAbsorb:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		frame.damageAbsorb.overlay:SetPoint("BOTTOMLEFT", frame.damageAbsorb:GetStatusBarTexture(), "BOTTOMLEFT", 0, 0)
		frame.damageAbsorb.overlay:SetPoint("TOPRIGHT", frame.damageAbsorb:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		frame.damageAbsorb.overlay:SetPoint("BOTTOMRIGHT", frame.damageAbsorb:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	end


	if CreateUnitHealPredictionCalculator then
		frame.predictionCalc = CreateUnitHealPredictionCalculator()
		frame.predictionCalc:SetIncomingHealOverflowPercent(1)

		frame.predictionCalc:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MissingHealth)
		-- frame.predictionCalc:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MaximumHealth)

		--  frame.predictionCalc:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)
		-- frame.predictionCalc:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealthWithoutIncomingHeals)
		frame.predictionCalc:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MaximumHealth)

		frame.predictionCalc:SetHealAbsorbMode(Enum.UnitHealAbsorbMode.ReducedByIncomingHeals)
		-- frame.predictionCalc:SetHealAbsorbMode(Enum.UnitHealAbsorbMode.Total)
		-- frame.predictionCalc:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.CurrentHealth)
		frame.predictionCalc:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.MaximumHealth)
	end

	frame:RegisterUnitEvent("UNIT_HEALTH", frame.unit)
	frame:RegisterUnitEvent("UNIT_MAXHEALTH", frame.unit)
	frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", frame.unit)
	frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", frame.unit)
	frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", frame.unit)
	frame:RegisterUnitEvent("UNIT_MAX_HEALTH_MODIFIERS_CHANGED", frame.unit)

	frame.pauseUpdates = false

	-- This is used for the low health flashing. See HealthBar_Gradient() for more info
	frame.statusSign = 1
	frame:SetScript("OnEvent", HealthBar_OnEvent)
	frame:SetScript("OnUpdate", HealthBar_OnUpdate)
end



--[[

POWERBAR functions

]]


local function PowerBar_Text(frame)
	local parent = frame:GetParent()
	if frame.parent then
		parent = frame:GetParent():GetParent()
	end
	local text = module:GetTextFormat("power", parent)
	-- if not UnitIsConnected(frame.unit) UnitIsPlayer(frame.unit) then
		-- text = ""
	-- elseif UnitIsGhost(frame.unit) then
		-- text = ""
	-- elseif (UnitIsDead(frame.unit) or UnitIsCorpse(frame.unit)) then
		-- text = ""
	-- end

	if text ~= nil then
		text = text:gsub("$cur", "%%1$s")
		text = text:gsub("$max", "%%2$s")
		text = text:format(addon:CommaNumber(frame.currValue), addon:FormatNumber(frame.maxValue))
	end

	if frame.text then frame.text:SetText(text) end
end

local GetSpellPowerCost = _G["GetSpellPowerCost"] or C_Spell.GetSpellPowerCost

local function PowerBar_CostPrediction(frame, isStarting, startTime, endTime, spellId)
	local powerType = frame.powerType or UnitPowerType(frame.unit)
	local maxPower = UnitPowerMax(frame.unit, powerType)

	if addon:IsSecretValue(maxPower) then return end

	local cost = 0
	if not isStarting or startTime == endTime then
		local currentSpellID = select(9, UnitCastingInfo(frame.unit));
		if currentSpellID and frame.predictedPowerCost then
			cost = frame.predictedPowerCost
		else
			frame.predictedPowerCost = nil
		end
	else
		for _,info in pairs(GetSpellPowerCost(spellId) or {}) do
			if info.type == powerType and info.cost > 0 then
				cost = info.cost
				break
			end
		end
		frame.predictedPowerCost = cost
	end

	-- local _, maxPower= frame:GetMinMaxValues()
	local perc = maxPower > 0 and cost / maxPower or 0
	local texture = frame:GetStatusBarTexture()
	local colorInfo = PowerBarColor[powerType]
	if colorInfo and colorInfo.predictionColor then
		frame.costPredictionBar.fill:SetVertexColor(colorInfo.predictionColor:GetRGB())
		frame.costPredictionBar.fill:Show()
		frame.costPredictionBar.fillReserve:Hide()
	else
		frame.costPredictionBar.fill:Hide()
		frame.costPredictionBar.fillReserve:Show()
	end

	PredictionBar_Fill(frame, texture, frame.costPredictionBar, cost, -perc, maxPower)
end

local function PowerBar_OnEvent(frame, event, ...)
	-- if not (frame:GetParent().isEnabled or frame:GetParent():GetParent().isEnabled) then return end

	if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UNIT_DISPLAYPOWER" then
		module:PowerBar_Update(frame)
	elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_SUCCEEDED" then
		local _, _, _, startTime, endTime, _, _, _, spellId = UnitCastingInfo(frame.unit);
		PowerBar_CostPrediction(frame, event == "UNIT_SPELLCAST_START", startTime, endTime, spellId);
	end
end

local function PowerBar_OnUpdate(frame, e)
	-- if not (frame:GetParent().isEnabled or frame:GetParent():GetParent().isEnabled) then return end

	local unit = frame.unit
    -- if UnitExists(unit) then
		if not frame.pauseUpdates then
			local powerType = frame.powerType or UnitPowerType(unit)
			local currValue = UnitPower(unit, powerType)
			local maxValue = UnitPowerMax(unit, powerType) -- Sometimes not a secret value. Very weird.

			-- Checking for secret value on currValue can't be trusted. During loading screen it might return `false`.
			if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then
				frame.currValue = currValue
				frame.maxValue = maxValue
				frame:SetValue(currValue)
				frame:SetMinMaxValues(0, maxValue)
			else
				if maxValue ~= frame.maxValue then
					frame:SetMinMaxValues(0, maxValue)
					frame.maxValue = maxValue
				end

				frame.endvalue = currValue
				if currValue ~= frame.currValue then
					frame.currValue = currValue
				end

				Glide(frame, e)
			end

			PowerBar_Text(frame);
		end
    -- end
end

function module:PowerBar_Update(frame)

	local unit = frame.unit
	local powerType = frame.powerType or UnitPowerType(unit) or 0
	local powerBarColor = PowerBarColor[powerType]
	local maxValue = UnitPowerMax(unit, powerType)
	local currValue = UnitPower(unit, powerType)
	if frame.updateFunc then
		frame:updateFunc()
	end

	frame:GetStatusBarTexture():SetVertexColor(powerBarColor.r, powerBarColor.g,powerBarColor.b)
	frame.bg:SetVertexColor(powerBarColor.r, powerBarColor.g,powerBarColor.b)

	--- For Glide animation!
	frame.startvalue = currValue
	frame.endvalue = currValue

	frame.currValue = currValue
	frame.maxValue = maxValue

	frame:SetMinMaxValues(0, maxValue);
	frame:SetValue(currValue)


	if not (addon:IsSecretValue(maxValue) or addon:IsSecretValue(powerType)) and maxValue == 0 and powerType == 1 then
		frame:Hide()
	else
		frame:Show()
	end

	PowerBar_Text(frame)
end

function module:PowerBar_OnLoad(frame, unit)
	frame.pauseUpdates = false
	frame.unit = unit

	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", unit)
	frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)

	if frame.costPredictionBar and unit =="player" then
		frame:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
		frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
		frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
		frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
	end

	frame:SetScript("OnEvent", PowerBar_OnEvent)
	frame:SetScript("OnUpdate", PowerBar_OnUpdate)
end


--[[

CASTBAR functions

]]

local LibCC
local UnitCastingInfo
local UnitChannelInfo

if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_CLASSIC then
	LibCC = LibStub("LibClassicCasterino", true)
	UnitCastingInfo = function(unit)
		return LibCC:UnitCastingInfo(unit)
	end

	UnitChannelInfo = function(unit)
		return LibCC:UnitChannelInfo(unit)
	end
else
	UnitCastingInfo = _G["UnitCastingInfo"]
	UnitChannelInfo = _G["UnitChannelInfo"]
end

local function CastBar_Text(text, statusbar, short)
	local orient = statusbar:GetOrientation()
	local out = text

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

	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START" then
		local _, name, texture, startTime, endTime, castID, notInterruptible, numStages
		local r, g, b
		-- frame:Clear() will be called everytime the player changes target. Hmmmm...
		frame:Clear()
		if event == "UNIT_SPELLCAST_START" then
			name, _, texture, startTime, endTime, _, castID, notInterruptible = UnitCastingInfo(unit)

			if addon:IsSecretValue(startTime) or addon:IsSecretValue(castID) then return end

			if not endTime then frame:Hide(); frame:Clear(); return end
			frame.castID = castID
			frame.value = GetTime() - (startTime / 1000)
			-- frame.maxValue = (endTime - startTime) / 1000
			r, g, b = 1.0, 0.7, 0.0
			-- r, g, b = CastingBarFrame.startCastColor:GetRGB()
			-- frame.statusbar:SetMinMaxValues(0,frame.maxValue)
			frame.channeling = false
			frame.casting = true
			frame.reverseChanneling = false
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START" then
			if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then
				name, _, texture, startTime, endTime, _, notInterruptible, _, _, numStages = UnitChannelInfo(unit)
				if numStages and numStages > 0 then
					endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
					frame.reverseChanneling = true
					frame.channeling = false
				else
					frame.channeling = true
					frame.reverseChanneling = false
				end
			else
				name, _, texture, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
				frame.channeling = true
				frame.reverseChanneling = false
			end

			if not endTime or addon:IsSecretValue(startTime) then frame:Hide()frame:Clear(); return end

			if frame.reverseChanneling then
				-- Same calculations as a regular cast.
				frame.value = GetTime() - (startTime / 1000)
			else
				frame.value = (endTime / 1000) - GetTime()
			end

			-- frame.maxValue = (endTime - startTime) / 1000
			r, g, b = 0.0, 1.0, 0.0
			-- r, g, b = CastingBarFrame.startChannelColor:GetRGB()
			-- frame.statusbar:SetMinMaxValues(0,frame.maxValue)
			-- frame.channeling = true
			frame.casting = false
		end
		if notInterruptible then
			-- r, g, b = CastingBarFrame.nonInterruptibleColor:GetRGB()
			r, g, b = 0.7, 0.7, 0.7
		end

		frame.statusbar:SetStatusBarColor(r, g, b)
		frame.maxValue = (endTime - startTime) / 1000
		frame.statusbar:SetMinMaxValues(0,frame.maxValue)
		frame.statusbar:SetValue(frame.value)
		frame.icon:SetTexture(texture)
		frame.name = name
		CastBar_Text(frame.name, frame.statusbar, true)
		frame:SetAlpha(1.0)
		frame.fadeOut = false
		frame.holdTime = 0
		frame:Show()
	elseif event  == "UNIT_SPELLCAST_INTERRUPTIBLE" then
		local r, g, b
		if frame.casting then
			r, g, b = 1.0, 0.7, 0.0
			-- r, g, b = CastingBarFrame.startCastColor:GetRGB()
		else -- Channeling
			r, g, b = 0.0, 1.0, 0.0
			-- r, g, b = CastingBarFrame.startChannelColor:GetRGB()
		end
		frame.statusbar:SetStatusBarColor(r, g, b)
	elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
		-- frame.statusbar:SetStatusBarColor(CastingBarFrame.nonInterruptibleColor:GetRGB())
		frame.statusbar:SetStatusBarColor(0.7, 0.7, 0.7)
	elseif event  == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
		if ( frame.casting and select(1,...) == frame.castID ) or frame.channeling or frame.reverseChanneling then
			if frame.casting then
				if not module.db.profile.castBar.finishedColorSameAsStart then
					frame.statusbar:SetStatusBarColor(0.0, 1.0, 0.0)
				end

				frame.statusbar:SetValue(frame.maxValue)

				-- frame.statusbar:SetStatusBarColor(CastingBarFrame.finishedCastColor:GetRGB())
				frame.casting = false
			end

			if frame.channeling then
				frame.statusbar:SetValue(0)
				frame.channeling = false
			end

			local now = GetTime()

			frame.fadeOut = true
			frame.holdTime = now + 0.2

			if frame.reverseChanneling  then
				frame.reverseChanneling = false
				frame.holdTime = now + 1
			end
		end
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then

		if addon:IsSecretValue(frame.castID) then frame:Hide()frame:clear() return end

		if frame.casting and select(1,...) == frame.castID then
			frame.statusbar:SetValue(frame.maxValue)
			frame.statusbar:SetStatusBarColor(1.0, 0.0, 0.0)
			-- frame.statusbar:SetStatusBarColor(CastingBarFrame.failedCastColor:GetRGB())
			frame.casting = false
			local text
			if event == "UNIT_SPELLCAST_FAILED" then
				text = FAILED
			else
				text = INTERRUPTED
			end
			CastBar_Text(text, frame.statusbar, false)
			frame.fadeOut = true
			frame.holdTime =  GetTime() + 1
		end
	elseif event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE" then
		if frame.casting or frame.channeling or frame.reverseChanneling then
			local _, startTime, endTime
			if frame.casting then
				_, _, _, startTime, endTime = UnitCastingInfo(unit)

				if not endTime or addon:IsSecretValue(startTime)  then frame:Hide()frame:Clear(); return end

				frame.value = GetTime() - (startTime / 1000)
			elseif frame.channeling or frame.reverseChanneling then
				_, _, _, startTime, endTime = UnitChannelInfo(unit)

				if addon:IsSecretValue(startTime)  then frame:Hide()frame:Clear(); return end

				if not endTime then frame:Hide(); frame:Clear(); return end

				frame.value = (endTime / 1000) - GetTime()

				if frame.reverseChanneling then
					endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
					frame.value = GetTime() - (startTime / 1000)
				end

				frame.statusbar:SetValue(frame.value)
			end
			frame.maxValue = (endTime - startTime) / 1000
			frame.statusbar:SetMinMaxValues(0,frame.maxValue)
			frame.fadeOut = false
			frame.holdTime = 0
		end
	end
end

local function CastBar_OnUpdate(frame, e)
	if frame.casting or frame.reverseChanneling then
		-- treating reverse channels the same as casts.
		frame.value = frame.value + e
		if frame.value >= frame.maxValue then
			frame.statusbar:SetValue(frame.maxValue)
			-- frame.casting = false
			frame.channeling = false
			frame.fadeOut = true
			return
		end
		frame.time:SetText(string.format("(%.1fs)",frame.maxValue - frame.value))
		frame.statusbar:SetValue(frame.value)
	elseif frame.channeling then
		frame.value = frame.value - e
		if frame.value <= 0 then
			frame.statusbar:SetValue(0)
			-- frame.channeling = false
			frame.casting = false
			frame.fadeOut = true
			return
		end
		frame.statusbar:SetValue(frame.value)
		frame.time:SetText(string.format("(%.1fs)", frame.value))
	elseif GetTime() < frame.holdTime then
		return
	elseif frame.fadeOut then
		local step = e / 0.3
		local alpha = frame:GetAlpha() - step;
		alpha = alpha >= 0 and alpha or 0
		frame:SetAlpha(alpha)

		if ( alpha == 0 ) then
			frame:Clear()
			frame:Hide()
			frame.fadeOut = false
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
		frame.reverseChanneling = false
		frame.fadeOut = false
		frame.holdTime = 0
	end

	frame:Clear()

	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	frame:RegisterEvent("PLAYER_TARGET_CHANGED")

	if LibCC then
		local CastbarEventHandler = function(event, ...)
			CastBar_OnEvent(frame, event, ...)
		end
		LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_START", CastbarEventHandler)
		LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_STOP", CastbarEventHandler)
		LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_DELAYED", CastbarEventHandler) -- only for player
		LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_FAILED", CastbarEventHandler)
		LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_INTERRUPTED", CastbarEventHandler)
		LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_CHANNEL_START", CastbarEventHandler)
		LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_CHANNEL_UPDATE", CastbarEventHandler) -- only for player
		LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_CHANNEL_STOP", CastbarEventHandler)
	else
		frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
		frame:RegisterEvent("UNIT_SPELLCAST_START")
		frame:RegisterEvent("UNIT_SPELLCAST_STOP")
		frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
		frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
		frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

		if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE or addon.WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_CATACLYSM_CLASSIC then
			frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
			frame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

			if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then
			-- Empowered casts.
				frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
				frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
				frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
			end
		end
	end

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

	-- Uncomment the next line to use Glide animation on the Target of Target hp bar.
	-- self:HealthBar_Update(frame.hp)

	-- frame:SetScript("OnEvent", TargetofTarget_OnEvent)
	frame:SetScript("OnUpdate", TargetofTarget_Update)
end

--[[

THREATBAR functions

]]

local GetThreatStatusColor = _G["GetThreatStatusColor"] or function(status)
	local r, g, b
	if status == 0 then
		r = 0.69
		g = 0.69
		b = 0.69
	elseif status == 1 then
		r = 1
		g = 1
		b = 0.47
	elseif status == 2 then
		r = 1
		g = 0.6
		b = 0
	elseif status == 3 then
		r = 1
		g = 0
		b = 0
	end
	return r, g, b
end

local function ThreatBar_Text(frame)
	local text = module:GetTextFormat("threat", frame:GetParent())
	local perc = module:GetTextFormat("perc", frame:GetParent())

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
		perc = perc:gsub("$perc", module:FormatPercentage(percent, true))
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

			Glide(frame, e)

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

local LibClassicDurations

if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_CLASSIC then
	LibClassicDurations = LibStub("LibClassicDurations")
	LibClassicDurations:Register(addon)
end

local PLAYER_UNITS = {
	player = true,
	vehicle = true,
	pet = true,
}

local function UnpackAuraData(auraData)
	if not auraData then
		return nil;
	end

	return not addon:IsSecretValue(auraData.name) and auraData.name or nil,
		not addon:IsSecretValue(auraData.icon) and auraData.icon or nil,
		not addon:IsSecretValue(auraData.applications) and auraData.applications or 0,
		not addon:IsSecretValue(auraData.dispelName) and auraData.dispelName or nil,
		not addon:IsSecretValue(auraData.duration) and auraData.duration or 0,
		not addon:IsSecretValue(auraData.expirationTime) and auraData.expirationTime or 0,
		not addon:IsSecretValue(auraData.sourceUnit) and auraData.sourceUnit or nil,
		not addon:IsSecretValue(auraData.isStealable) and auraData.isStealable or false,
		not addon:IsSecretValue(auraData.nameplateShowPersonal) and auraData.nameplateShowPersonal or false,
		not addon:IsSecretValue(auraData.spellId) and auraData.spellId or 0,
		not addon:IsSecretValue(auraData.canApplyAura) and auraData.canApplyAura or false,
		not addon:IsSecretValue(auraData.isBossAura) and auraData.isBossAura or false,
		not addon:IsSecretValue(auraData.isFromPlayerOrPlayerPet) and auraData.isFromPlayerOrPlayerPet or false,
		not addon:IsSecretValue(auraData.nameplateShowAll) and auraData.nameplateShowAll or false,
		not addon:IsSecretValue(auraData.timeMod) and auraData.timeMod or 1,
		not addon:IsSecretValue(auraData.points) and unpack(auraData.points)
end

local ShouldShowDebuffs = _G["TargetFrame_ShouldShowDebuffs"] or function(unit, caster, nameplateShowAll, casterIsAPlayer)
	return TargetFrame:ShouldShowDebuffs(unit, caster, nameplateShowAll, casterIsAPlayer)
end

local UnitBuff = _G["UnitBuff"] or function(unitToken, index, filter)
	return UnpackAuraData(C_UnitAuras.GetBuffDataByIndex(unitToken, index, filter))
end

local UnitDebuff = _G["UnitDebuff"] or function(unitToken, index, filter)
	return UnpackAuraData(C_UnitAuras.GetDebuffDataByIndex(unitToken, index, filter))
end

local DebuffTypeColor = DebuffTypeColor or AuraUtil.GetDebuffDisplayInfoTable()

local function UpdateAuraAnchor(auraFrame, index, size)
	local aura = auraFrame["aura"..index]
    if ( index == 1 ) then
		aura:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", 0, 0);
    else
		aura:SetPoint("LEFT", auraFrame["aura"..index-1],"RIGHT", 0, 0);
    end
end

function module:UpdateAuras(frame)
	-- if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then return end

	local normalSize, largeSize = 17, 21
	local aura, auraFrame, auraFrameHeight
	-- local name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, spellId, _
	local playerIsTarget = UnitIsUnit("player", frame.unit)
	local canAssist = UnitCanAssist("player", frame.unit)

	local filter;
	-- if SHOW_CASTABLE_BUFFS == "1" and canAssist then
	-- 	filter = "RAID";
	-- end

	local maxBuffs = frame.maxBuffs or MAX_TARGET_BUFFS
	auraFrame = frame.buffs
	auraFrameHeight = normalSize
	for i = 1, maxBuffs do
		local buffName, icon, count, _, duration, expirationTime, caster, canStealOrPurge, _ , spellId = UnitBuff(frame.unit, i, nil);
		if icon then
			if not auraFrame["aura"..i] then
				auraFrame["aura"..i] = CreateFrame("Button", nil, auraFrame, self.db.profile.templatePrefix.."Buff")
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

			if LibClassicDurations then
				local durationNew, expirationTimeNew = LibClassicDurations:GetAuraDurationByUnit(frame.unit, spellId, caster, buffName)
				if duration == 0 and durationNew then
					duration = durationNew
					expirationTime = expirationTimeNew
				end
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

			-- Handle cooldowns
			if not OmniCC then
				local fontHeight = 
				aura.cooldown:SetCountdownFont("Nurfed_CountdownFontOutline")
				aura.cooldown:SetHideCountdownNumbers(false)
			end
			if ( duration > 0 ) then
				aura.cooldown:Show()
				CooldownFrame_Set(aura.cooldown, expirationTime - duration, duration, duration > 0, true)
			else
				aura.cooldown:Hide()
			end

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

	-- if SHOW_DISPELLABLE_DEBUFFS == "1" and canAssist then
	-- 	filter = "RAID";
	-- else
	-- 	filter = nil;
	-- end

	local frameNum = 1;
	local index = 1;
	local maxDebuffs = frame.maxDebuffs or MAX_TARGET_DEBUFFS
	auraFrame = frame.debuffs
	auraFrameHeight = normalSize

	while frameNum <= maxDebuffs do
		-- local debuffName = UnitDebuff(frame.unit, index, filter)
		local debuffName, icon, count, debuffType, duration, expirationTime, caster, _, _, spellId, _, _, casterIsPlayer, nameplateShowAll = UnitDebuff(frame.unit, index, "INCLUDE_NAME_PLATE_ONLY");
		if debuffName then
			if ShouldShowDebuffs(frame.unit, caster, nameplateShowAll, casterIsPlayer) then
				-- name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitDebuff(frame.unit, index, filter)

				if icon then
					if not auraFrame["aura"..frameNum] then
						auraFrame["aura"..frameNum] = CreateFrame("Button", nil, auraFrame, self.db.profile.templatePrefix.."Debuff")
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

					if LibClassicDurations then
						local durationNew, expirationTimeNew = LibClassicDurations:GetAuraDurationByUnit(frame.unit, spellId, caster, debuffName)
						if duration == 0 and durationNew then
							duration = durationNew
							expirationTime = expirationTimeNew
						end
					end
					-- Handle cooldowns
					if not OmniCC then
						aura.cooldown:SetCountdownFont("Nurfed_CountdownFontOutline")
						aura.cooldown:SetHideCountdownNumbers(false)
					end
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
					local colorInfo
					if debuffType then
						colorInfo = DebuffTypeColor[debuffType]
					else
						colorInfo = DebuffTypeColor["none"] or DebuffTypeColor["None"]
					end

					if colorInfo.r then
						aura.border:SetVertexColor(colorInfo.r, colorInfo.g, colorInfo.b)
					else
						aura.border:SetVertexColor(colorInfo.color:GetRGB())
					end

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
