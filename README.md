# Nurfed
The original addon was made by Tivoli from the guild [Nurfed](http://www.nurfed.com).

# Background story
Tivoli stopped making updates to the addon many years ago. However, a fellow that went by the name Apoco did continue for some time. Eventually the whole project was discontinued all the together. For some time I was making local changes to the original addon, but decided to try and rewrite the whole thing using XML and Ace3 to fix bugs and add new features, etc. That was in late September, 2012. However, it was done without any version control; something I have been postponing ever since. Now the the whole thing is publically available for everyone's viewing pleasure (or displeasure).

# Further development
This whole project is somewhat of an on and off thing, so the likelihood of it getting a release version is low. I just do it for fun and to challenge myself a bit. I do, however, use this addon on a daily basis so I do try to fix any bugs I come across.

# What's new
* XML based.
* Uses [Ace3](http://www.wowace.com/addons/ace3/) libraries.
* Modular design - many features have been separated to be their own modules:
	* Unitframes:
		* Boss frames added.
		* Healthbars have now got:
			* Healing prediction.
			* Bars for showing absorbs.
				* The amount of damage the unit can absorb before losing health.
				* The amount of healing the unit can absorb without gaining health.
		* Pet frame shows the model of the pet.
		* The threatbar's calculation of the your threat percentage has changed and will match what Omen shows. However, currently, it will stop at 250%.
		* Focus frame has now got a threatbar.
		* Target Markers icons can now be displayed on all frames.
		* Highlight texture added to all frames.
			* Is diplayed if you hover over the frame or if you're targeting the same unit as that frame represents.
		* Automatically locks the unitframes if it's unlocked and the player enters combat. (This may have been a feature in the original).
		* When the unitframes are unlocked, all frames are now displayed.
			* Draggable overlay (like Bartender).
				* Size is based upon the combined size of all the additional frames/textures; target of target, buffs/debuffs, cast bar, Target Markers.
				* Control-key locks the X-axis.
				* Shift-key locks the Y-axis.
		* Blinking healthbar of friendly units below 20%, with increased intensity when below 10%.
		* Able to show who is Master Looter on frames for Target and Focus.
		* Group roles (tank/dps/healer) and raid roles (main assist/main tank) are displayed on frames for Player, Target, Focus and PartyN.
		* Guide icon shown instead of Leader icon when in a group formed by Group/Raid Finder tool.
		* Raid assistant icon will show when the player or a group member is an assistant.
		* Party frames will automatically hide when in a raid group. (Options for this to be turned on/off should be added).
		* Ready check frame added for Player, Focus, Target and PartyN.
		* [Playtime](http://wow.gamepedia.com/API_PartialPlayTime) frame added for our Chinese friends.
	* Chat:
		* Several types timestamp formats available:
			* Select between 12h and 24h.
			* Show milliseconds.
		* Outputformats.
	* Auto sell (sells your grey trash loot)
	* Wow micro menu:
		* All buttons are added and working.
		* Keybindings displayed.
		* Some buttons greyed out if the Player is too low level or is on a Starter Edition account.

# What's missing/incomplete
* Options are severely incomplete.
* Skins.
* Missing features (that I can think of):
	* Auto-repair.
	* Showing who is pinging the minimap.
	* When ready check is completed, output to chat if everyone is ready or if someone is away.
	* Invite features:
		* Invite a player when they whisper a keyword.
		* Auto-join when friends or guild members invite you.
* Heals/damage displayed on the portrait/model (this might never be implemented).
* Translations (AceLocale is available, but not utilized).
* Missing from Unitframes:
	* Battleground/Arena.
	* These frames are missing from the Player frame:
		* Runes.
		* Holy Power.
		* Chi.
		* Voice chat
* Whatever Libs\MultiSpec.lua in the original did. Will probably not be implemented.
* Action bars. (will not be implemented).