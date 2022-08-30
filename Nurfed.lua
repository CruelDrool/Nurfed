local addonName = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
addon:SetDefaultModuleLibraries("AceEvent-3.0", "AceHook-3.0")
addon:SetDefaultModuleState(false)
_G[addonName] = addon -- uncomment for debugging purposess

-- local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

local defaults = {
	profile = {
		minimapIcon = {},
	}
}

addon.OutOfCombatQueue = {}

addon.infoMessages = {
	enableModuleInCombat = "Module %s will be enabled when combat ends.",
	disableModuleInCombat = "Module %s will be disabled when combat ends.",
}

addon.colors = {
	addonName = {r = 0, g = 0.75, b = 1},
	moduleName = {r = 0, g = 1, b = 0},
	tooltipLine = {r = 0.75, g = 0.75, b = 0.75},
}

addon.options = {
	childGroups = "tree",
	type = "group",
	plugins = {},
	args = {
		minimapIcon = {
			order = 1,
			type = "toggle",
			name = "Minimap Icon",
			desc = "Show a Icon to open the config at the Minimap",
			get = function() return not addon.db.profile.minimapIcon.hide end,
			set = function(info, value) addon.db.profile.minimapIcon.hide = not value; LDBIcon[value and "Show" or "Hide"](LDBIcon, addonName) end,
			-- disabled = function() return not LDBIcon end,
			disabled = function() return not LDBTitan end,
		},
		modules = {
			order = 2,
			type = "group",
			name = "Modules",
			-- cmdInline = true,
			args = {},
		},
	},
}

function addon:SetupOptions()
	self.options.plugins.profiles = { profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) }
	self.options.name = addonName
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(addonName, self.options)
	
	-- Was getting a bit of taint using the following line:
	-- LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
end

function addon:OnInitialize()
	-- Create the DB
	self.db = LibStub("AceDB-3.0"):New(addonName.."DB", defaults)
	
	-- Register callbacks
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateConfigs")
	
	-- Get the options created in the modules.
	for name, mod in self:IterateModules() do
		if mod.options then
			if not self.options.args[name] then
				self.options.args.modules.args[name] = mod.options
			end
		end
	end
	
	-- Create the LibDataBroker object. This is used to create the minimap icon later on.
	self.LDBObj = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
		type = "launcher",
		OnClick = function(frame, msg)
			if msg == "RightButton" then
				if LibStub("AceConfigDialog-3.0").OpenFrames[addonName] then
					-- PlaySound("GAMEGENERICBUTTONPRESS")
					PlaySound(624)
					LibStub("AceConfigDialog-3.0"):Close(addonName)
				else
					-- PlaySound("GAMEDIALOGOPEN")
					PlaySound(88)
					LibStub("AceConfigDialog-3.0"):Open(addonName)
				end
			end
		end,
		icon = "Interface\\AddOns\\"..addonName.."\\Images\\locked",
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:ClearLines()
			tooltip:AddDoubleLine(addonName, addon:WrapTextInColorCode(GetAddOnMetadata(addonName, "Version"), addon.colors.tooltipLine), addon:UnpackColorTable(addon.colors.addonName))
			tooltip:AddLine("Right Click - Toggle Options", addon:UnpackColorTable(addon.colors.tooltipLine))				
		end,
	})

	-- Create the minimap icon
	LDBIcon:Register(addonName, self.LDBObj, self.db.profile.minimapIcon)
	
	self:SetupOptions()
end

function addon:OnEnable()
	LDBIcon:Refresh(addonName, addon.db.profile.minimapIcon)
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function addon:UpdateConfigs()
	LDBIcon:Refresh(addonName, addon.db.profile.minimapIcon)
	LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
end

function addon:Transliterate(str, mark)
	return LibStub("LibTranslit-1.0"):Transliterate(str, mark)
end

function addon:WrapTextInColorCode(str, colorStr)
	if type(colorStr) == "table" then
		colorStr = self:ColorStr(colorStr)
	end
	return colorStr and string.format("|c%s%s|r", colorStr, str) or str
end

function addon:UnpackColorTable(tbl)
	return tbl.r or 1, tbl.g or 1, tbl.b or 1
end

function addon:ColorStr(r, g, b)
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end
	return string.format("ff%02x%02x%02x", (r or 1) * 255, (g or 1) * 255, (b or 1) * 255)
end

function addon:rgbhex(r, g, b)
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end
	return string.format("|c%s", addon:ColorStr(r, g, b))
end

function addon:CommaNumber(n)
	n = ("%.0f"):format(n)
   	local left,num,right = string.match(n,'^([^%d]*%d)(%d+)(.-)$')
   	return left and left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse()) or n --..right
end

function addon:FormatNumber(n)
	local number = math.abs(n)
	local text
	if number >= 1000000000 then
		text = format("%.3fG", number/1000000000)
	elseif number >= 1000000 then
		text = format("%.2fM", number/1000000)
	elseif number >= 10000 then
		text = format("%.1fk", number/1000)
	else text = self:CommaNumber(number)
	end
	if n < 0 then
		text = "-"..text
	end
	return text
end

function addon:Print(msg, out, r, g, b, ...)
	if type(out) == "string" then
		msg = msg:format(out, r, g, b, ...)
	end
	out	= _G["ChatFrame"..(type(out) == "number" and out or 1)]
	out:AddMessage(msg, (type(r) == "number" and r or 1), (type(g) == "number" and g or 1), (type(b) == "number" and b or 1))
end

function addon:InfoMessage(msg)
	local name = string.format("<%s>", addonName)
	addon:Print(string.format("%1$s %2$s", addon:WrapTextInColorCode(name, addon.colors.addonName), msg))
end

function addon:SystemMessageInPrimary(msg)
	local color = ChatTypeInfo["SYSTEM"]
	addon:Print(msg, 1, color.r, color.g, color.b)
end

function addon:Binding(bind)
	bind = bind or ""
	bind = bind:upper(bind)
	bind = bind:gsub("CTRL%-", "C-")
	bind = bind:gsub("ALT%-", "A-")
	bind = bind:gsub("SHIFT%-", "S-")
	bind = bind:gsub("NUM PAD", "NP")
	bind = bind:gsub("NUMPAD", "NP")
	bind = bind:gsub("BACKSPACE", "Bksp")
	bind = bind:gsub("SPACEBAR", "Space")
	bind = bind:gsub("PAGE", "Pg")
	bind = bind:gsub("DOWN", "Dn")
	bind = bind:gsub("ARROW", "")
	bind = bind:gsub("INSERT", "Ins")
	bind = bind:gsub("DELETE", "Del")
	bind = bind:gsub("ESCAPE", "Esc")
	bind = bind:gsub("BUTTON(%d)", "B%1")
	bind = bind:gsub("CAPSLOCK", "Cps Lck")
	bind = bind:gsub("%s$", "")
	return bind
end

function addon:AddOutOfCombatQueue(func, tbl)
	if type(func) == "function" then
		table.insert(self.OutOfCombatQueue, func)
	elseif type(func) == "string" then
		-- Name of method. Will need the table where it is located.
		if type(tbl)  ~= "table" then
			error(string.format("Please provide the table where the method '%s' is located.", func))
			return
		end
		if not tbl[func] then
			error(string.format("The method '%1$s' doesn't exist in the the provided table.", func))
			return
		end
		table.insert(self.OutOfCombatQueue, {tbl, func})
	end
end

local function EmptyOutOfCombatQueue()
	for i, entry in pairs(addon.OutOfCombatQueue) do 
		if type(entry) == "function" then
			entry()
		elseif type(entry) == "table" then
			local tbl = entry[1]
			local funcName = entry[2]
			tbl[funcName](tbl)
		end
		addon.OutOfCombatQueue[i] = nil
	end
end

function addon:PLAYER_REGEN_ENABLED()
	EmptyOutOfCombatQueue()
end
