local addonName = ...
local moduleName = "MicroMenu"
local displayName = "WoW micro menu"
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local module = addon:NewModule(moduleName)

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
-- This array contains the buttons for the micro menu.
local mainMenu = {
	"TITLE",
	"BLANK",
	"SOCIAL_MENU", -- Submenu
	"SEPARATOR",
	"CHARACTER",
	"SPELLBOOK_ABILITIES_MENU", -- Submenu
	"TALENTS",
	"ACHIEVEMENTS",
	"QUESTLOG",
	"GUILD",
	"DUNGEONS",
	"COLLECTIONS",
	"ADVENTURE_JOURNAL",
	"BLIZZARD_STORE",
	"GAME_MENU", -- Submenu
	"SEPARATOR",
	"CANCEL"
}

-- Level 2 and up
local subMenus = {
	GAME_MENU = { 
		"HELP",
		"BLIZZARD_STORE",
		"WHATS_NEW",
		"SEPARATOR",
		"SYSTEMOPTIONS",
		"UIOPTIONS",
		"KEY_BINDINGS",
		"MACROS",
		"ADDONS",
		-- "SEPARATOR",
		-- "LOGOUT",
		-- "EXIT_GAME",
	},
	SOCIAL_MENU = { 
		"FRIENDS_MENU",
		"WHO",
		"RAID",
		"QUICK_JOIN",
	},
	FRIENDS_MENU = {
		"FRIENDS_LIST",
		"IGNORE_LIST",
	},
	SPELLBOOK_ABILITIES_MENU = {
		"SPELLBOOK",
		"PROFESSIONSBOOK",
		"PETBOOK",
	},
}

-- /run for i=1,GetNumBindings() do local a, b, c = GetBinding(i);if string.find(a, "^TOGGLE") then print(a, c) end end

-- This functions returns an array the contains the available buttons that can be used in main menu itself and submenus.
local function ButtonsArray()
	
	local buttons = {
		SEPARATOR = { dist = 0, isTitle = true, isUninteractable = true, iconOnly = true, icon = "Interface\\Common\\UI-TooltipDivider-Transparent", tCoordLeft = 0, tCoordRight = 1, tCoordTop = 0, tCoordBottom = 1, tSizeX = 0, tFitDropDownSizeX = true, tSizeY = 8, },
		BLANK = { isTitle = 1, notClickable = 1},
		CANCEL = { text = CANCEL },
		TITLE = { text = displayName, isTitle = 1, notClickable = 1 },
		
		SOCIAL_MENU = { text = GetMenuButtonText(SOCIAL_BUTTON, "TOGGLESOCIAL"), func = function() ToggleFriendsFrame() end, nested = 1, },

		FRIENDS_MENU = { text = GetMenuButtonText(FRIENDS, "TOGGLEFRIENDSTAB"), func = function() ToggleFriendsFrame(1) end, nested = 1, },
		FRIENDS_LIST = { text = FRIENDS_LIST, func = function() FriendsTabHeaderTab1:Click(); if FriendsFrame:IsShown() then FriendsFrameTab1:Click() else ToggleFriendsFrame(1) end end, },
		QUICK_JOIN = { text = GetMenuButtonText(QUICK_JOIN, "TOGGLEQUICKJOINTAB"), func = function() ToggleFriendsFrame(4) end, },
		IGNORE_LIST = {text = IGNORE_LIST, func = function() FriendsTabHeaderTab3:Click(); if FriendsFrame:IsShown() then FriendsFrameTab1:Click() else ToggleFriendsFrame(1) end end, },
		
		WHO = { text = GetMenuButtonText(WHO, "TOGGLEWHOTAB"), func = function() ToggleFriendsFrame(2) end, },
		RAID = { text = GetMenuButtonText(RAID, "TOGGLERAIDTAB"), func = function() ToggleFriendsFrame(3) end, },
		
		CHARACTER = { text = GetMenuButtonText(CHARACTER_BUTTON, "TOGGLECHARACTER0"), func = function() ToggleCharacter("PaperDollFrame"); end, },
		
		-- SPELLBOOK_ABILITIES = { text = GetMenuButtonText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK"), func = function() SpellbookMicroButton:Click() end, },
		SPELLBOOK_ABILITIES_MENU = { text = GetMenuButtonText(SPELLBOOK_ABILITIES_BUTTON), nested = 1, },
		SPELLBOOK = { text = GetMenuButtonText(SPELLBOOK, "TOGGLESPELLBOOK"), func = function() ToggleSpellBook(BOOKTYPE_SPELL) end, },
		PROFESSIONSBOOK = { text = GetMenuButtonText(TRADE_SKILLS, "TOGGLEPROFESSIONBOOK"), func = function() ToggleSpellBook(BOOKTYPE_PROFESSION) end, },
		PETBOOK = { text = GetMenuButtonText(PET, "TOGGLEPETBOOK"), func = function() ToggleSpellBook(BOOKTYPE_PET ) end, disabled = true, },
		
		TALENTS = { text = GetMenuButtonText(TALENTS_BUTTON, "TOGGLETALENTS"), func = function() TalentMicroButton:Click() end, },
		ACHIEVEMENTS = { text = GetMenuButtonText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT"), func = function() ToggleAchievementFrame() end, },
		QUESTLOG = { text = GetMenuButtonText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG"), func = function() ToggleQuestLog() end, },
		GUILD = { func = function() GuildMicroButton:Click() end, },
		DUNGEONS = { text = GetMenuButtonText(DUNGEONS_BUTTON, "TOGGLEGROUPFINDER"), func = function() LFDMicroButton:Click() end, },
		COLLECTIONS = { text = GetMenuButtonText(COLLECTIONS, "TOGGLECOLLECTIONS"), func = function() CollectionsMicroButton:Click() end, },
		ADVENTURE_JOURNAL = { text = GetMenuButtonText(ADVENTURE_JOURNAL, "TOGGLEENCOUNTERJOURNAL"), func = function() EJMicroButton:Click() end },
		BLIZZARD_STORE = { text = BLIZZARD_STORE, func = function() ToggleStoreUI() end, },
		
		GAME_MENU = { text = GetMenuButtonText(MAINMENU_BUTTON, "TOGGLEGAMEMENU"), func = function() 
			if GameMenuFrame:IsShown() then
				PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
				HideUIPanel(GameMenuFrame)
			else 
				PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
				ShowUIPanel(GameMenuFrame)
			end
		end, nested = 1, },
		HELP = { text = GAMEMENU_HELP, func = function() ToggleHelpFrame() end, },
		WHATS_NEW = { text = GAMEMENU_NEW_BUTTON, func = function() GameMenuButtonWhatsNew:Click() end, },
		SYSTEMOPTIONS = { text = SYSTEMOPTIONS_MENU, func = function() GameMenuButtonOptions:Click() end, },
		UIOPTIONS = { text = UIOPTIONS_MENU, func = function() GameMenuButtonUIOptions:Click() end, },
		KEY_BINDINGS = { text = KEY_BINDINGS, func = function() GameMenuButtonKeybindings:Click() end, },
		MACROS = { text = MACROS, func = function() ShowMacroFrame() end, },
		ADDONS = { text = ADDONS, func = function() GameMenuButtonAddons:Click() end, },
		
		-- The functions for the buttons below are now restricted by Blizzard. The buttons are now disabled.
		LOGOUT = { text = LOGOUT, func = function() Logout() end, disabled = true, },
		EXIT_GAME = { text = EXIT_GAME, func = function() Quit() end, disabled = true, },
	}
	
	local level = UnitLevel("player")
		
	if level < SHOW_SPEC_LEVEL then
		buttons["TALENTS"]["disabled"] = true
		buttons["TALENTS"]["text"] = GetMenuButtonText(TALENTS_BUTTON.." ("..string.format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_SPEC_LEVEL)..")", "TOGGLETALENTS")
	end
	
	if IsTrialAccount() then
		buttons["BLIZZARD_STORE"]["disabled"] = true
		buttons["BLIZZARD_STORE"]["text"] = BLIZZARD_STORE.." ("..ERR_RESTRICTED_ACCOUNT_TRIAL..")"
	end
	
	if UnitFactionGroup("player") ~= "Neutral" then
		if IsTrialAccount() then
			buttons["GUILD"]["disabled"] = true
			buttons["GUILD"]["text"] = GetMenuButtonText(LOOKINGFORGUILD.." ("..ERR_RESTRICTED_ACCOUNT_TRIAL..")", "TOGGLEGUILDTAB")
		elseif IsInGuild() then
			buttons["GUILD"]["text"] = GetMenuButtonText(GUILD, "TOGGLEGUILDTAB")
		else
			buttons["GUILD"]["text"] = GetMenuButtonText(LOOKINGFORGUILD, "TOGGLEGUILDTAB")
		end
		
		if level < SHOW_LFD_LEVEL then
			buttons["DUNGEONS"]["disabled"] = true
			buttons["DUNGEONS"]["text"] = GetMenuButtonText(DUNGEONS_BUTTON.." ("..string.format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL)..")", "TOGGLEGROUPFINDER")
		end
	else
		buttons["GUILD"]["disabled"] = true
		buttons["GUILD"]["text"] = GetMenuButtonText(LOOKINGFORGUILD.." ("..FEATURE_NOT_AVAILBLE_PANDAREN..")", "TOGGLEGUILDTAB")
		
		buttons["DUNGEONS"]["disabled"] = true
		buttons["DUNGEONS"]["text"] = GetMenuButtonText(DUNGEONS_BUTTON.." ("..FEATURE_NOT_AVAILBLE_PANDAREN..")", "TOGGLEGROUPFINDER")		
	end
	
	if not C_AdventureJournal.CanBeShown() then
		buttons["ADVENTURE_JOURNAL"]["disabled"] = true
		buttons["ADVENTURE_JOURNAL"]["text"] = GetMenuButtonText(ADVENTURE_JOURNAL.." ("..FEATURE_NOT_YET_AVAILABLE ..")", "TOGGLEENCOUNTERJOURNAL")
	end
	
	if HasPetSpells() or PetHasSpellbook() then
		buttons["PETBOOK"]["disabled"] = false	
	end
	
	return buttons
end

-- Function to create the menu
local function MenuInit(frame, level)
	local buttons = ButtonsArray()
	local menu
	-- local info = UIDropDownMenu_CreateInfo() -- is it needed?
	
	if level == 1 then
		menu = mainMenu
	else
		menu = subMenus[UIDROPDOWNMENU_MENU_VALUE]
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
				PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
					if not frame.initialize then
						frame.displayMode = "MENU"
						frame.initialize = MenuInit
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