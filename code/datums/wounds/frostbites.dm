/datum/wound_pregen_data/frostbite
	required_limb_biostate = BIO_FLESH
	can_be_randomly_generated = FALSE
	duplicates_allowed = FALSE
	wound_series = WOUND_SERIES_FLESH_FROST_BASIC

	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)

	var/flesh_temperature = 0 //how much our flesh has unfrozen or frozen
	var/warming_rate //how fast our flesh warms up can be influenced by drugs and medical treatment
	var/rewarm_threshhold //amount of warming progress for us to start unfreezing

/datum/wound/frostbite/flesh
	name = "Frostbite Wound"
	undiagnosed_name = "Frostbite"
	a_or_from = "from"
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)
	rewarm_threshhold = 240
	flesh_temperature = 120


/datum/wound/frostbite/flesh/handle_process(seconds_per_tick, times_fired)
	if(victim.bodytemperature > COLD_DAMAGE_LEVEL_1) //if we're not freezing, start rewarming
		flesh_temperature += warming_rate * seconds_per_tick
		victim.adjustStaminaLoss * seconds_per_tick
		to_chat(victim, span_notice("Your [limb.plaintext_zone] stings as it thaws."))
	if(victim.bodytemperature < COLD_DAMAGE_LEVEL_1)
		to_chat(victim, span_notice("Your [limb.plaintext_zone] loses sensation as it freezes."))
		flesh_temperature -= warming_rate * seconds_per_tick
	if(flesh_temperature <= rewarm_threshhold) //if we've been rewarmed, apply the rewarming wound

	if(flesh_temperature = 0)// upgrade to next tier of frostbite
		to_chat(victim, span_warning("The chill in your [limb.plaintext_zone] deepens."))
		src.severity += 1


//mechanics todo, when on your legs you'll walk slower, when on the arms you'll craft slower
//freezing progress, pain, rewarming blisters

//First degree frostbite doesn't need to be done, can be handled by atmos mob interactions
/datum/wound/frostbite/flesh/moderate
	name = "Second degree frostbite"
	desc = "Patient suffers Reduced feeling and control our skin layers have frozen."
	undiagnosed_name = "Frostbite"
	a_or_from = "from"
	treat_text = "Rewarm, hot fluids can speed this process. Apply ointment to help with pain."
	treat_text_short = "Rewarm drink warm fluids."
	examine_desc = "skin is red and covered in blisters"
	severity = WOUND_SEVERITY_MODERATE
	damage_multiplier_penalty = 1.1
	interaction_efficiency_penalty = 1.3
	limp_slowdown = 3
	limp_chance = 20
	disabling = FALSE


/datum/wound_pregen_data/frostbite/moderate
	wound_path_to_generate = /datum/wound/frostbite/flesh/moderate
	required_limb_biostate = BIO_FLESH
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)


/datum/wound/frostbite/flesh/severe
	name = "Third degree frostbite"
	desc = "Patient suffers lack of feeling and control skin has frozen. Fat layer has partially frozen."
	undiagnosed_name = "Frostbite"
	a_or_from = "from"
	treat_text = "Rewarm immediately. Prepare medicine for trauma from thawing. Likely infection."
	treat_text_short = "Rewarm immediately. Prepare gauze and antibiotics."
	examine_desc = "the flesh is pale and stiff."
	severity = WOUND_SEVERITY_SEVERE
	damage_multiplier_penalty = 1.3
	interaction_efficiency_penalty = 2
	limp_slowdown = 6
	limp_chance = 33
	disabling = FALSE

/datum/wound_pregen_data/frostbite/severe
	wound_path_to_generate = /datum/wound/frostbite/flesh/moderate
	required_limb_biostate = BIO_FLESH
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)

/datum/wound/frostbite/flesh/critical
	name = "Fourth degree frostbite"
	desc = "Patient's muscle, skin and fat has fully frozen. Major infection almost guaranteed. Rewarm and prepare for amputation."
	undiagnosed_name = "Frostbite"
	a_or_from = "from"
	treat_text = "Prepare for amputation. Antibiotics to prevent sepsis. Rewarm limb to prevent unnecessary bloodloss."
	treat_text_short = "Amputate, rewarm to reduce bleeding."
	examine_desc = "is frozen solid and pale."
	severity = WOUND_SEVERITY_SEVERE
	damage_multiplier_penalty = 2
	interaction_efficiency_penalty = 4
	limp_slowdown = 9
	limp_chance = 60

//if we are above the temperature we would recieve this wound at, begin to rewarm, this will cause intermittent pain
//if we are below the temperature we would recieve this wound, start escalating to the next one
