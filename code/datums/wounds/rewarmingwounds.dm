/datum/wound_pregen_data/rewarm
	abstract = TRUE
	required_limb_biostate = BIO_FLESH

	required_wounding_type = WOUND_BLUNT

	wound_series = WOUND_SERIES_BONE_BLUNT_BASIC

/datum/wound/rewarm
	name = "Base rewarming wound"
	desc = "If you're seeing this something has gone wrong! Tell a coder!"
//##
	wound_flags = (ACCEPTS_GAUZE)

	default_scar_file = BONE_SCAR_FILE
	threshold_penalty = 5

	/// Have we been bone gel'd?
	var/gelled
	/// Have we been taped?
	var/taped
	/// If we did the gel + surgical tape healing method for fractures, how many ticks does it take to heal by default
	var/regen_ticks_needed
	/// Our current counter for gel + surgical tape regeneration
	var/regen_ticks_current
	/// If we suffer severe head booboos, we can get brain traumas tied to them
	var/datum/brain_trauma/active_trauma
	/// What brain trauma group, if any, we can draw from for head wounds
	var/brain_trauma_group
	/// If we deal brain traumas, when is the next one due?
	var/next_trauma_cycle
	/// How long do we wait +/- 20% for the next trauma?
	var/trauma_cycle_cooldown
	/// If this is a chest wound and this is set, we have this chance to cough up blood when hit in the chest
	var/internal_bleeding_chance = 0

/datum/wound/rewarm/moderate //TO-DO once we have pain, we really should add some to this.
	//painful blisters, grabbing smth might hurt a little
//owie ouch blisters kinda painful
/datum/wound/rewarm/severe
//frozen skin blood vessles and fat, possible infection, painful
/datum/wound/rewarm/critical
//Frozen solid to the bone, guaranteed major infection
