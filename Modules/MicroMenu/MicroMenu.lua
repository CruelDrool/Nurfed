local addonName = ...
local moduleName = "MicroMenu"
local displayName = "WoW micro menu"
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local module = addon:NewModule(moduleName)

-- local AceGUI = LibStub("AceGUI-3.0")

local defaults = {
	profile = {
		enabled = true,
	}
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

local function GetMenuButtonText(text, binding, textFormat, abbr)
	if not text then return "" end
	if not binding then return text end
	if not abbr then abbr = true end
	if not textFormat then textFormat = "$t |cffffd200($b)|r" end
	
	textFormat = textFormat:gsub("$t", text, 1)
	textFormat = textFormat:gsub("$b", "%%s", 1)
	
	if GetBindingKey(binding) then
		-- binding = GetBindingText(GetBindingKey(binding), false)
		binding = GetBindingKey(binding)
		if abbr then
			binding = addon:Binding(binding)
		else
			-- SHIFT-J becomes Shift-J, and ESCAPE becomes Escape.
			binding = binding:gsub("%w+", function(w) 
				w = string.lower(w)
				w = w:gsub("^%l", function(l) return string.upper(l) end)
				return w
			end)
		end
		
		text = string.format(textFormat, binding)
	end

	return text
end

-- Level 1
local mainmenu = {"TITLE", "BLANK", "SOCIAL_MENU", "SEPARATOR", "CHARACTER_BUTTON", "SPELLBOOK_ABILITIES_BUTTON", "TALENTS_BUTTON", "ACHIEVEMENT_BUTTON", "QUESTLOG_BUTTON", "LOOKINGFORGUILD", "DUNGEONS_BUTTON", "COLLECTIONS", "ADVENTURE_JOURNAL", "BLIZZARD_STORE", "SEPARATOR", "GAME_MENU", }

-- Level 2 and up
local submenus = {
	GAME_MENU = { "GAMEMENU_HELP", "BLIZZARD_STORE", "GAMEMENU_NEW_BUTTON", "SEPARATOR", "SYSTEMOPTIONS_MENU", "UIOPTIONS_MENU", "KEY_BINDINGS", "MACROS", "ADDONS", "SEPARATOR", "LOGOUT", "EXIT_GAME", },
	SOCIAL_MENU = { "FRIENDS", "WHO", "CHAT", "RAID" },
}

-- /run for i=1,GetNumBindings() do local a, b, c = GetBinding(i);if string.find(a, "^TOGGLE") then print(a, c) end end
local function buttonsArray()
	
	local buttons = {
		SEPARATOR = UnitPopupButtons["SUBSECTION_SEPARATOR"],
		BLANK = { isTitle = 1, notClickable = 1},
		TITLE = { text = displayName, isTitle = 1, notClickable = 1 },
		-- SOCIAL_BUTTON = { text = GetMenuButtonText(SOCIAL_BUTTON, "TOGGLESOCIAL"), func = function() FriendsMicroButton:Click() end, },
		SOCIAL_MENU = { text = GetMenuButtonText(SOCIAL_BUTTON, "TOGGLESOCIAL"), nested = 1 },
		FRIENDS = { text = GetMenuButtonText(FRIENDS, "TOGGLEFRIENDSTAB"), func = function() ToggleFriendsFrame(1) end, },
		WHO = { text = GetMenuButtonText(WHO, "TOGGLEWHOTAB"), func = function() ToggleFriendsFrame(2) end, },
		CHAT = { text = GetMenuButtonText(CHAT, "TOGGLECHATTAB"), func = function() ToggleFriendsFrame(3) end, },
		RAID = { text = GetMenuButtonText(RAID, "TOGGLERAIDTAB"), func = function() ToggleFriendsFrame(4) end, },
		CHARACTER_BUTTON = { text = GetMenuButtonText(CHARACTER_BUTTON, "TOGGLECHARACTER0"), func = function() ToggleCharacter("PaperDollFrame"); end, },
		SPELLBOOK_ABILITIES_BUTTON = { text = GetMenuButtonText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK"), func = function() SpellbookMicroButton:Click() end, },
		ACHIEVEMENT_BUTTON = { text = GetMenuButtonText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT"), func = function() AchievementMicroButton:Click() end, },
		QUESTLOG_BUTTON = { text = GetMenuButtonText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG"), func = function() QuestLogMicroButton:Click() end, },
		COLLECTIONS = { text = GetMenuButtonText(COLLECTIONS, "TOGGLECOLLECTIONS"), func = function() CollectionsMicroButton:Click() end, },
		GAME_MENU = { text = GetMenuButtonText(MAINMENU_BUTTON, "TOGGLEGAMEMENU"), nested = 1},
		GAMEMENU_HELP = { text = GAMEMENU_HELP, func = function() ToggleHelpFrame() end, },
		GAMEMENU_NEW_BUTTON = { text = GAMEMENU_NEW_BUTTON, func = function() GameMenuButtonWhatsNew:Click() end, },
		SYSTEMOPTIONS_MENU = { text = SYSTEMOPTIONS_MENU, func = function() GameMenuButtonOptions:Click() end, },
		UIOPTIONS_MENU = { text = UIOPTIONS_MENU, func = function() GameMenuButtonUIOptions:Click() end, },
		KEY_BINDINGS = { text = KEY_BINDINGS, func = function() GameMenuButtonKeybindings:Click() end, },
		MACROS = { text = MACROS, func = function() ShowMacroFrame() end, },
		ADDONS = { text = ADDONS, func = function() GameMenuButtonAddons:Click() end, },
		LOGOUT = { text = LOGOUT, func = function() Logout() end, },
		EXIT_GAME = { text = EXIT_GAME, func = function() Quit() end, },
	}
	
	local level = UnitLevel("player")
	local factionGroup = UnitFactionGroup("player")
	local temp
	
	if level < SHOW_SPEC_LEVEL then
		temp = { text = GetMenuButtonText("|cff8d8d8d"..TALENTS_BUTTON.." (level "..SHOW_SPEC_LEVEL..")|r", "TOGGLETALENTS"), notClickable = true }
	else
		temp = { text = GetMenuButtonText(TALENTS_BUTTON, "TOGGLETALENTS"), func = function() TalentMicroButton:Click() end }
	end
	buttons["TALENTS_BUTTON"] = temp
	
	if IsTrialAccount() then
		temp = { text = GetMenuButtonText("|cff8d8d8d"..LOOKINGFORGUILD.." (upgrade account)|r".." |cffffd200(", "TOGGLEGUILDTAB"), notClickable = true }
	elseif IsInGuild() then
		temp = { text = GetMenuButtonText(GUILD, "TOGGLEGUILDTAB"), func = function() GuildMicroButton:Click() end }
	else
		if factionGroup ~= "Neutral" then
			temp = { text = GetMenuButtonText(LOOKINGFORGUILD, "TOGGLEGUILDTAB"), func = function() GuildMicroButton:Click() end }
		else
			temp = { text = GetMenuButtonText("|cff8d8d8d"..LOOKINGFORGUILD.." (choose faction)|r", "TOGGLEGUILDTAB"), notClickable = true }
		end
	end
	buttons["LOOKINGFORGUILD"] = temp
		
	if level < SHOW_LFD_LEVEL then
		temp = { text = GetMenuButtonText("|cff8d8d8d"..DUNGEONS_BUTTON.." (level "..SHOW_LFD_LEVEL..")|r", "TOGGLEGROUPFINDER"), notClickable = true }
	else
		if factionGroup ~= "Neutral" then
			temp = { text = GetMenuButtonText(DUNGEONS_BUTTON, "TOGGLEGROUPFINDER"), func = function() LFDMicroButton:Click() end }
		else
			temp = { text = GetMenuButtonText("|cff8d8d8d"..DUNGEONS_BUTTON.." (choose faction)|r", "TOGGLEGROUPFINDER"), notClickable = true }
		end
	end
	buttons["DUNGEONS_BUTTON"] = temp
	
	if level < SHOW_EJ_LEVEL then
		temp = { text = GetMenuButtonText("|cff8d8d8d"..ADVENTURE_JOURNAL.." (level "..SHOW_EJ_LEVEL..")|r", "TOGGLEENCOUNTERJOURNAL"), notClickable = true }
	else
		temp = { text = GetMenuButtonText(ADVENTURE_JOURNAL, "TOGGLEENCOUNTERJOURNAL"), func = function() EJMicroButton:Click() end }
	end
	buttons["ADVENTURE_JOURNAL"] = temp

	if IsTrialAccount() then
		temp = { text = "|cff8d8d8d"..BLIZZARD_STORE.." (upgrade account)|r", notClickable = true }
	else
		temp = { text = BLIZZARD_STORE, func = function() StoreMicroButton:Click() end }
	end
	buttons["BLIZZARD_STORE"] = temp

	return buttons
end

-- Function to create the menu
local function menuInit(frame, level)
	local buttons = buttonsArray()
	local menu
	-- local info = UIDropDownMenu_CreateInfo() -- is it needed?
	
	if level == 1 then
		menu = mainmenu
	else
		menu = submenus[UIDROPDOWNMENU_MENU_VALUE]
	end
	
	for _, button in ipairs(menu) do 
		local info = buttons[button]
		
		info.value = button
		
		if info.nested then
			info.hasArrow = true
			info.keepShownOnClick = true
		end
		
		if not info.checkable then 
			info.notCheckable = true
		end
		
		if info.iconOnly then
			info.hasArrow = false
			info.iconInfo = { tCoordLeft = info.tCoordLeft,
					  tCoordRight = info.tCoordRight,
					  tCoordTop = info.tCoordTop,
					  tCoordBottom = info.tCoordBottom,
					  tSizeX = info.tSizeX,
					  tSizeY = info.tSizeY,
					  tFitDropDownSizeX = info.tFitDropDownSizeX }
		else
			info.iconInfo = nil
		end
		
		UIDropDownMenu_AddButton(info,level)
	end
end


function module:OnInitialize()
	-- Register DB namespace
	self.db = addon.db:RegisterNamespace(moduleName, defaults)
	
	-- Register callbacks
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateConfigs")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateConfigs")
	
	-- Enable if we're supposed to be enabled
	if self.db.profile.enabled then
		self:Enable()
	end
end

function module:OnEnable()
	self:SecureHook(addon.LDBObj,"OnClick", function(frame, msg)
		if msg == "MiddleButton" then
				PlaySound("gsTitleOptionExit")
					if not frame.initialize then
						frame.displayMode = "MENU"
						frame.initialize = menuInit
					end
					ToggleDropDownMenu(1, nil, frame, "cursor")
			end
	end)

	self:SecureHook(addon.LDBObj,"OnTooltipShow", function(tooltip) tooltip:AddLine("Middle Click - "..displayName, 0.75, 0.75, 0.75) end)
	
	if LDBTitan and _G["TitanPanel"..addonName.."Button"] then
		LDBTitan:TitanLDBHandleScripts("OnTooltipShow", addonName, nil, addon.LDBObj.OnTooltipShow, addon.LDBObj)
		LDBTitan:TitanLDBHandleScripts("OnClick", addonName, nil, addon.LDBObj.OnClick)
	end
	self.db.profile.enabled = true
end

function module:OnDisable()
	self.db.profile.enabled = false
	self:UnhookAll()
end

function module:UpdateConfigs()
	if self.db.profile.enabled then 
		-- If profile says that the module is supposed to enabled, but it isn't already, then go ahead and enable it.
		if not self:IsEnabled() then
			self:Enable()
		end
	else
		-- If the module is currently enabled, but isn't supposed to, then disable it.
		if self:IsEnabled() then
			self:Disable()
		end
	end
end