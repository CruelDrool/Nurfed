# Nurfed
The original addon was made by Tivoli from the guild [Nurfed](http://www.nurfed.com).

## Background story
Tivoli stopped making updates to the addon many years ago. However, a fellow that went by the name Apoco did continue for some time. Eventually the whole project was discontinued all the together. For some time I was making local changes to the original addon, but decided to try and rewrite the whole thing using XML and Ace3 to fix bugs and add new features, etc. That was in late September, 2012. However, it was done without any version control; something I have been postponing ever since. Now the the whole thing is publically available for everyone's viewing pleasure (or displeasure).

## Further development
This whole project is somewhat of an on and off thing, so the likelihood of it getting a release version is low. I just do it for fun and to challenge myself a bit. I do, however, use this addon on a daily basis so I do try to fix any bugs I come across.

## What's new
* XML based.
* Uses [Ace3](http://www.wowace.com/addons/ace3/) libraries.
* Modular design - many features have been separated to be their own modules.

### Unitframes
* Boss frames added.
* Healthbars have now got:
	* Healing prediction.
	* Bars for showing absorbs.
		* The amount of damage the unit can absorb before losing health.
		* The amount of healing the unit can absorb without gaining health.
* Powerbar on the playerframe has got cost prediction.
* Pet frame shows the model of the pet.
* The threatbar's calculation of the your threat percentage has changed and will match what Omen shows. However, currently, it will stop at 250%.
* Focus frame has now got a threatbar.
* Raid target icons can now be displayed on all frames.
* Highlight texture added to all frames.
	* Is diplayed if you hover over the frame or if you're targeting the same unit as that frame represents.
* Automatically locks the unitframes if it's unlocked and the player enters combat. (This may have been a feature in the original).
* When the unitframes are unlocked, all frames are now displayed.
	* Draggable overlay (like Bartender).
		* Size is based upon the combined size of all the additional frames/textures; target of target, buffs/debuffs, cast bar, Target Markers.
		* Control-key locks the X-axis.
		* Shift-key locks the Y-axis.
	* Resize using the scroll-wheel. Reset the size by Ctrl+Shift+Scroll Up/Down
* Blinking healthbar of friendly units at <=30%, with increased intensity when at <=20% or <=10%. These thresholds can be changed.
* Able to show who is Master Looter on frames for Target and Focus.
* Group roles (tank/dps/healer) and raid roles (main assist/main tank) are displayed on frames for Player, Target, Focus and PartyN.
* Guide icon shown instead of Leader icon when in a group formed by Group/Raid Finder tool.
* Raid assistant icon will show when the player or a group member is an assistant.
* Party frames:
	* 40 yards ranged checking
	* Summoning/phasing status
	* Will automatically hide when in a raid group
* Ready check frame added for Player, Focus, Target and PartyN.
* [Playtime](http://wow.gamepedia.com/API_PartialPlayTime) frame added for our Chinese friends.
* Reputation bar seperated from the experience bar.
* Option to toggle Blizzard's cast bar.
* Option to toggle combat feedback.

### Chat
* Several types timestamp formats available:
	* Select between 12h and 24h.
	* Show milliseconds.
* Outputformats.

### Auto sell 
Automatically sells your grey trash loot.

### WoW micro menu

* All buttons are added and working.
* Keybindings displayed.
* Some buttons greyed out if the the features aren't available to the player.

### Aura timers

Changes how the time left on auras are formatted.

### Shaman class color (Classic era)

Set the color to blue like in TBC and later.

### Money receipt (Classic era and beyond)

The money receipt feature that exists Retail. Tells you how much you've gained at the vendor/mailbox.

### Auto repair
* Set limit for how much can be used each time.
* Use guild bank when possible (BCC and later).
* Output amount spent on repairs.
	

## What's missing/incomplete
* Options are incomplete, but improving.
* Skins.
* Missing features (that I can think of):
	* Showing who is pinging the minimap.
	* When ready check is completed, output to chat if everyone is ready or if someone is away.
	* Invite features:
		* Invite a player when they whisper a keyword.
		* Auto-join when friends or guild members invite you.
* Translations (AceLocale is available, but not utilized).
* Missing from Unitframes:
	* Arena frames.
	* These frames are missing from the player frame: voice chat
* Whatever Libs\MultiSpec.lua in the original did. Will probably not be implemented.
* Action bars. (will not be implemented).