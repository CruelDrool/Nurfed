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
-- This table will be populated with the buttons for the micro menu.
local mainMenu

-- Level 2 and up
local subMenus

if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then
	 mainMenu = {
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

	subMenus = {
		GAME_MENU = {
			"SUPPORT",
			"BLIZZARD_STORE",
			"WHATS_NEW",
			"SEPARATOR",
			"OPTIONS",
			"MACROS",
			"ADDONS",
			-- "SEPARATOR",
			-- "LOGOUT",
			-- "EXIT_GAME",
		},
		SOCIAL_MENU = {
			"FRIENDS_MENU", -- Submenu
			"WHO",
			"RAID",
			"QUICK_JOIN",
		},
		FRIENDS_MENU = {
			"FRIENDS_LIST",
			"IGNORE_LIST",
			"RECRUIT_FRIEND",
		},
		SPELLBOOK_ABILITIES_MENU = {
			"SPELLBOOK",
			"PROFESSIONSBOOK",
			"PETBOOK",
		},
	}
elseif addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_CLASSIC then
	mainMenu = {
		"TITLE",
		"BLANK",
		"CHARACTER",
		"SPELLBOOK_ABILITIES_MENU", -- Submenu
		"TALENTS",
		"QUESTLOG",
		"SOCIAL_MENU", -- Submenu
		"MAP",
		"DUNGEONS",
		"GAME_MENU", -- Submenu
		"HELP_REQUEST",
		"SEPARATOR",
		"CANCEL"
	}
	subMenus = {
		GAME_MENU = {
			"SUPPORT",
			"BLIZZARD_STORE",
			"SEPARATOR",
			"OPTIONS",
			"MACROS",
			"ADDONS",
			-- "SEPARATOR",
			-- "LOGOUT",
			-- "EXIT_GAME",
		},
		SOCIAL_MENU = { 
			"FRIENDS_MENU", -- Submenu
			"WHO",
			"GUILD",
			"RAID",
		},
		FRIENDS_MENU = {
			"FRIENDS_LIST",
			"IGNORE_LIST",
		},
		SPELLBOOK_ABILITIES_MENU = {
			"SPELLBOOK",
			"PETBOOK",
		},
	}
elseif addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_CATACLYSM_CLASSIC then
	mainMenu = {
		"TITLE",
		"BLANK",
		"CHARACTER",
		"SPELLBOOK_ABILITIES_MENU", -- Submenu
		"TALENTS",
		"ACHIEVEMENTS",
		"QUESTLOG",
		"GUILD",
		"COLLECTIONS",
		"PLAYER_V_PLAYER",
		"DUNGEONS",
		"DUNGEON_JOURNAL",
		"GAME_MENU", -- Submenu
		"HELP_REQUEST",
		"SEPARATOR",
		"CANCEL"
	}
	subMenus = {
		GAME_MENU = {
			"SUPPORT",
			"BLIZZARD_STORE",
			"SEPARATOR",
			"OPTIONS",
			"MACROS",
			"ADDONS",
			-- "SEPARATOR",
			-- "LOGOUT",
			-- "EXIT_GAME",
		},
		SOCIAL_MENU = {
			"FRIENDS_MENU", -- Submenu
			"WHO",
			"RAID",
		},
		FRIENDS_MENU = {
			"FRIENDS_LIST",
			"IGNORE_LIST",
		},
		SPELLBOOK_ABILITIES_MENU = {
			"SPELLBOOK",
			"PETBOOK",
		},
	}
end

-- /run for i=1,GetNumBindings() do local a, b, c = GetBinding(i);if string.find(a, "^TOGGLE") then print(a, c) end end

local HasPetSpells = _G.HasPetSpells or C_SpellBook.HasPetSpells

-- This functions returns an array the contains the available buttons that can be used in main menu itself and submenus.
local function ButtonsArray()
	local minLevelSpec, minLevelLFD, minLevelAchi, talentsText, toggleRaidTabFunc, toggleGuildFrameFunc, toggleLFDFunc, LFDtext, LFDKeybind, optionsFunc
	if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE then
		minLevelSpec = 10
		minLevelLFD = 10
		minLevelAchi = 1
		talentsText = TALENTS_BUTTON
		toggleRaidTabFunc = function() ToggleFriendsFrame(3) end
		toggleGuildFrameFunc = function() GuildMicroButton:Click() end
		toggleLFDFunc = function() LFDMicroButton:Click() end
		LFDtext = DUNGEONS_BUTTON
		LFDKeybind = "TOGGLEGROUPFINDER"
		optionsFunc = function() GameMenuButtonSettings:Click() end
	elseif addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_CLASSIC then
		minLevelSpec = SHOW_SPEC_LEVEL
		minLevelLFD = SHOW_LFD_LEVEL
		talentsText = TALENTS
		toggleRaidTabFunc = function() ToggleFriendsFrame(4) end
		toggleGuildFrameFunc = function() ToggleFriendsFrame(3) end
		toggleLFDFunc = function() PVEFrame_ToggleFrame() end
		LFDtext = LFG_BUTTON or DUNGEONS_BUTTON
		LFDKeybind = "TOGGLEGROUPFINDER"
		optionsFunc = function() GameMenuButtonOptions:Click() end
	elseif addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_CATACLYSM_CLASSIC then
		minLevelSpec = SHOW_SPEC_LEVEL
		minLevelLFD = SHOW_LFD_LEVEL
		minLevelAchi = 1
		talentsText = TALENTS
		toggleRaidTabFunc = function() ToggleFriendsFrame(4) end
		toggleGuildFrameFunc = function() GuildMicroButton:Click() end
		toggleLFDFunc = function() PVEFrame_ToggleFrame() end
		LFDtext = LFG_BUTTON or DUNGEONS_BUTTON
		LFDKeybind = "TOGGLEGROUPFINDER"
		optionsFunc = function() GameMenuButtonOptions:Click() end
	end

	local buttons = {
		SEPARATOR = { dist = 0, isTitle = true, isUninteractable = true, iconOnly = true, icon = "Interface\\Common\\UI-TooltipDivider-Transparent", tCoordLeft = 0, tCoordRight = 1, tCoordTop = 0, tCoordBottom = 1, tSizeX = 0, tFitDropDownSizeX = true, tSizeY = 8, },
		BLANK = { isTitle = 1, notClickable = 1},
		CANCEL = { text = CANCEL },
		TITLE = { text = displayName, isTitle = 1, notClickable = 1 },

		SOCIAL_MENU = { text = GetMenuButtonText(SOCIAL_BUTTON, "TOGGLESOCIAL"), func = function() ToggleFriendsFrame() end, nested = 1, },

		FRIENDS_MENU = { text = GetMenuButtonText(FRIENDS, "TOGGLEFRIENDSTAB"), func = function() ToggleFriendsFrame(1) end, nested = 1, },
		FRIENDS_LIST = { text = FRIENDS_LIST, func = function() FriendsTabHeaderTab1:Click(); if FriendsFrame:IsShown() then FriendsFrameTab1:Click() else ToggleFriendsFrame(1) end end, },
		IGNORE_LIST = {text = IGNORE_LIST, func = function() FriendsTabHeaderTab2:Click(); if FriendsFrame:IsShown() then FriendsFrameTab1:Click() else ToggleFriendsFrame(1) end end, },
		RECRUIT_FRIEND = {text = RECRUIT_A_FRIEND, func = function() FriendsTabHeaderTab3:Click(); if FriendsFrame:IsShown() then FriendsFrameTab1:Click() else ToggleFriendsFrame(1) end end, },

		WHO = { text = GetMenuButtonText(WHO, "TOGGLEWHOTAB"), func = function() ToggleFriendsFrame(2) end, },
		RAID = { text = GetMenuButtonText(RAID, "TOGGLERAIDTAB"), func = toggleRaidTabFunc, },
		QUICK_JOIN = { text = GetMenuButtonText(QUICK_JOIN, "TOGGLEQUICKJOINTAB"), func = function() ToggleFriendsFrame(4) end, },

		CHARACTER = { text = GetMenuButtonText(CHARACTER_BUTTON, "TOGGLECHARACTER0"), func = function() ToggleCharacter("PaperDollFrame"); end, },

		-- SPELLBOOK_ABILITIES = { text = GetMenuButtonText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK"), func = function() ToggleSpellBook(BOOKTYPE_SPELL) end, },
		SPELLBOOK_ABILITIES_MENU = { text = GetMenuButtonText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK"), func = function() ToggleSpellBook(BOOKTYPE_SPELL) end, nested = 1, },
		SPELLBOOK = { text = GetMenuButtonText(SPELLBOOK, "TOGGLESPELLBOOK"), func = function() ToggleSpellBook(BOOKTYPE_SPELL) end, },
		PROFESSIONSBOOK = { text = GetMenuButtonText(TRADE_SKILLS, "TOGGLEPROFESSIONBOOK"), func = function() ToggleSpellBook(BOOKTYPE_PROFESSION) end, },
		PETBOOK = { text = GetMenuButtonText(PET, "TOGGLEPETBOOK"), func = function() ToggleSpellBook(BOOKTYPE_PET ) end, skip = not (HasPetSpells() or PetHasSpellbook()), },

		TALENTS = { text = GetMenuButtonText(talentsText, "TOGGLETALENTS"), func = function() TalentMicroButton:Click() end, },
		ACHIEVEMENTS = { text = ACHIEVEMENT_BUTTON, func = function() ToggleAchievementFrame() end, disabled = true },
		PLAYER_V_PLAYER = { text = PLAYER_V_PLAYER, func = function() TogglePVPFrame() end, disabled = true },
		QUESTLOG = { text = GetMenuButtonText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG"), func = function() ToggleQuestLog() end, },
		GUILD = { func = toggleGuildFrameFunc, },
		DUNGEONS = { text = GetMenuButtonText(LFDtext, LFDKeybind), func = toggleLFDFunc, },
		COLLECTIONS = { text = GetMenuButtonText(COLLECTIONS, "TOGGLECOLLECTIONS"), func = function() CollectionsMicroButton:Click() end, },
		ADVENTURE_JOURNAL = { text = GetMenuButtonText(ADVENTURE_JOURNAL, "TOGGLEENCOUNTERJOURNAL"), func = function() ToggleEncounterJournal() end },
		DUNGEON_JOURNAL = { text = GetMenuButtonText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL"), func = function() ToggleEncounterJournal() end },
		BLIZZARD_STORE = { text = BLIZZARD_STORE, func = ToggleStoreUI, },

		GAME_MENU = { text = GetMenuButtonText(MAINMENU_BUTTON, "TOGGLEGAMEMENU"), func = function()
			if GameMenuFrame:IsShown() then
				PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
				HideUIPanel(GameMenuFrame)
			else
				PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
				ShowUIPanel(GameMenuFrame)
			end
		end, nested = 1, },
		SUPPORT = { text = GAMEMENU_SUPPORT, func = function() ToggleHelpFrame() end, },
		HELP_REQUEST = { text = HELP_BUTTON, func = function() ToggleHelpFrame() end, },
		WHATS_NEW = { text = GAMEMENU_NEW_BUTTON, func = function() GameMenuButtonWhatsNew:Click() end, skip = IsTrialAccount() },
		OPTIONS = { text = GAMEMENU_OPTIONS, func = optionsFunc, },
		-- UIOPTIONS = { text = UIOPTIONS_MENU, func = function() GameMenuButtonUIOptions:Click() end, },
		-- KEY_BINDINGS = { text = KEY_BINDINGS, func = function() GameMenuButtonKeybindings:Click() end, },
		MACROS = { text = MACROS, func = function() ShowMacroFrame() end, },
		ADDONS = { text = ADDONS, func = function() GameMenuButtonAddons:Click() end, },

		MAP = { text = GetMenuButtonText(WORLDMAP_BUTTON, "TOGGLEWORLDMAP"), func = function() ToggleWorldMap() end, },

		-- The functions for the buttons below are now restricted by Blizzard. The buttons are now disabled.
		LOGOUT = { text = LOGOUT, func = function() Logout() end, disabled = true, },
		EXIT_GAME = { text = EXIT_GAME, func = function() Quit() end, disabled = true, },
	}

	local level = UnitLevel("player")

	if C_SpecializationInfo and not C_SpecializationInfo.CanPlayerUseTalentSpecUI() then
		local _, failureReason = C_SpecializationInfo.CanPlayerUseTalentSpecUI();
		buttons["TALENTS"]["disabled"] = true
		buttons["TALENTS"]["text"] = GetMenuButtonText(string.format('%s (%s)', talentsText, failureReason), "TOGGLETALENTS")
	elseif level < minLevelSpec then
		buttons["TALENTS"]["disabled"] = true
		buttons["TALENTS"]["text"] = GetMenuButtonText(string.format('%s (%s)', talentsText, string.format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, minLevelSpec)), "TOGGLETALENTS")
	end

	if not C_StorePublic.IsEnabled() then
		buttons["BLIZZARD_STORE"]["disabled"] = true
		buttons["BLIZZARD_STORE"]["text"] = string.format('%s (%s)',  BLIZZARD_STORE, BLIZZARD_STORE_ERROR_UNAVAILABLE )
	end

	if UnitFactionGroup("player") ~= "Neutral" then
		local disabled, text = false, ""
		if IsTrialAccount() then
			disabled = true
			text = string.format('%s (%s)', LOOKINGFORGUILD, ERR_RESTRICTED_ACCOUNT_TRIAL)
		else
			if addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE or WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_CATACLYSM_CLASSIC  then
				text = GUILD_AND_COMMUNITIES
			else
				if not IsInGuild() then
					disabled = true
				end
				text = GUILD
			end
		end

		buttons["GUILD"]["disabled"] = disabled
		buttons["GUILD"]["text"] = GetMenuButtonText(text, "TOGGLEGUILDTAB")

		if not C_LFGInfo.CanPlayerUseGroupFinder() then
			local _, failureReason = C_LFGInfo.CanPlayerUseGroupFinder()
			buttons["DUNGEONS"]["disabled"] = true
			buttons["DUNGEONS"]["text"] = GetMenuButtonText(string.format('%s (%s)', LFDtext, failureReason), LFDKeybind)
		elseif level < minLevelLFD then
			buttons["DUNGEONS"]["disabled"] = true
			buttons["DUNGEONS"]["text"] = GetMenuButtonText(string.format('%s (%s)', LFDtext, string.format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, minLevelLFD)), LFDKeybind)
		end
	else
		buttons["GUILD"]["disabled"] = true
		buttons["GUILD"]["text"] = GetMenuButtonText(string.format('%s (%s)', LOOKINGFORGUILD, FEATURE_UNAVAILBLE_PLAYER_IS_NEUTRAL), "TOGGLEGUILDTAB")

		buttons["DUNGEONS"]["disabled"] = true
		buttons["DUNGEONS"]["text"] = GetMenuButtonText(string.format('%s (%s)', LFDtext, FEATURE_UNAVAILBLE_PLAYER_IS_NEUTRAL), LFDKeybind)
	end

	if not (C_AdventureJournal and C_AdventureJournal.CanBeShown()) then
		buttons["ADVENTURE_JOURNAL"]["disabled"] = true
		buttons["ADVENTURE_JOURNAL"]["text"] = GetMenuButtonText(string.format('%s (%s)', ADVENTURE_JOURNAL, FEATURE_NOT_YET_AVAILABLE), "TOGGLEENCOUNTERJOURNAL")
	end

	if ToggleAchievementFrame and addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_MAINLINE or addon.WOW_PROJECT_ID >= addon.WOW_PROJECT_ID_WRATH_OF_THE_LICH_KING_CLASSIC then
		local text
		local binding = "TOGGLEACHIEVEMENT"
		if  level < minLevelAchi then
			text = GetMenuButtonText(string.format('%s (%s)', ACHIEVEMENT_BUTTON, string.format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, minLevelAchi)), binding)
		else
			buttons["ACHIEVEMENTS"]["disabled"] = false
			text = GetMenuButtonText(ACHIEVEMENT_BUTTON, binding)
		end
		buttons["ACHIEVEMENTS"]["text"] = text
	end

	if TogglePVPFrame and addon.WOW_PROJECT_ID == addon.WOW_PROJECT_ID_CATACLYSM_CLASSIC then
		local text
		local binding = "TOGGLECHARACTER4"
		if level < SHOW_PVP_LEVEL then
			text = GetMenuButtonText(string.format('%s (%s)', PLAYER_V_PLAYER, string.format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL)), binding)
		else
			buttons["PLAYER_V_PLAYER"]["disabled"] = false
			text = GetMenuButtonText(PLAYER_V_PLAYER, binding)
		end
		buttons["PLAYER_V_PLAYER"]["text"] = text
	end

	if not (HasPetSpells() or PetHasSpellbook()) and addon.WOW_PROJECT_ID > addon.WOW_PROJECT_ID_MAINLINE then
		buttons["SPELLBOOK_ABILITIES_MENU"]["nested"] = nil
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
		if not info.skip then
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
