extends RefCounted
const NAMES = ["Willowbrook", "Emberhearth", "Frosthaven", "Windrest", "Stormwatch", "Duskveil", "Shadow Fortress"]
const REGIONS = ["Whispering Forest", "Ember Depths", "Frozen Citadel", "Shattered Skies", "Thunder Highlands", "Shadow Border", "Vaelor's Keep"]
const POWERS = ["Arcane Bolt", "Flame Burst", "Frost Bind", "Wind Dash", "Lightning Chain", "Guardian Light"]
const COSTS = [10.0,20.0,25.0,15.0,30.0,40.0]
const COOLDOWNS = [.28,.8,1.2,.6,1.1,2.0]
const COLORS = [Color("66c9f1"),Color("ff9a44"),Color("9be5f6"),Color("a0e9c4"),Color("d1b6ff"),Color("ffe5a2")]
const BOSSES = ["Hollow Warden", "Cinder Sentinel", "Frostbound Keeper", "Gale Harrier", "Tempest Colossus", "Void Herald", "Lord Vaelor"]
const GUIDES = ["Lyra","Taren","Eira","Sora","Iona","Neris","Lyra"]
const PUZZLES = ["Strike the blue crystal with Arcane Bolt", "Burn the vine seal with Flame Burst", "Freeze the rune with Frost Bind", "Drive the vane using Wind Dash", "Charge the conductor using Lightning Chain", "Purify the seal using Guardian Light", "Attune Flame, Frost, Lightning and Light at the four seals"]
const STORIES = [
"The Void has bound our forest guardian. Strike the blue crystal with Arcane Bolt and free the Hollow Warden.",
"Our forge is cold. Flame Burst burns the marked vine seal and strikes nearby foes. Free the Cinder Sentinel.",
"The keeper is trapped beneath the ice. Frost Bind freezes ordinary foes and the marked pool. Freeze the rune to enter the citadel.",
"The bridges have fallen. Wind Dash crosses the wide chasm once per airtime. Land before dashing again, then drive the marked vane.",
"The storm engines are silent. Lightning Chain links three visible foes and powers the marked conductor.",
"The Void hides our roads. Guardian Light absorbs two hits, reveals the high secret relic and purifies the marked seal. It cannot prevent a fall.",
"Six villages stand together. Vaelor's monument needs Flame, Frost, Lightning and Guardian Light. Attune each seal before entering his keep."]
const SIDE_ITEMS = ["Sun shard","Forge ember","Moon pearl","Sky feather","Storm prism","Dawn petal","Last memory"]
const STATE_KEYS = ["checkpoint","quest","crystal","boss","secret","seals"]
static func fresh_state() -> Dictionary:
	return {"checkpoint":2.0,"quest":0,"crystal":false,"boss":false,"secret":false,"seals":[]}
static func snapshot() -> Dictionary:
	var state = {}
	for key in STATE_KEYS: state[key] = Progress.data.get(key,[])
	return state.duplicate(true)
static func enter(index: int) -> bool:
	var campaign: Dictionary = Progress.data.campaign
	if index < 0 or index > 6 or index > int(campaign.unlocked)+1: return false
	if index > int(campaign.unlocked) and not campaign.completed.has(index-1): return false
	campaign.states[str(int(campaign.region))] = snapshot()
	campaign.region = index
	campaign.unlocked = maxi(index,int(campaign.unlocked))
	var state: Dictionary = campaign.states.get(str(index),fresh_state()).duplicate(true)
	for key in STATE_KEYS: Progress.data[key] = state[key]
	var seals = []
	for seal in Progress.data.seals: seals.append(int(seal))
	Progress.data.seals = seals
	Progress.data.powers = range(mini(5,int(campaign.unlocked))+1)
	Progress.data.villages = NAMES.slice(0,mini(6,int(campaign.unlocked)+1))
	Progress.data.selected_power = mini(index,5)
	return true
