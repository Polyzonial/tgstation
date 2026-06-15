/datum/wound_pregen_data/frostbite
	required_limb_biostate = BIO_FLESH
	can_be_randomly_generated = FALSE
	duplicates_allowed = FALSE
	wound_series = WOUND_SERIES_FLESH_FROST_BASIC
	wound_path_to_generate = /datum/wound/frostbite/flesh
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)

/datum/wound/frostbite/flesh
	name = "Frostbite Wound"
	undiagnosed_name = "Frostbite"
	a_or_from = "from"
	processes = TRUE
	var/rewarm_threshhold = 240 //amount of warming progress for us to start unfreezing
	var/flesh_temperature = 10 //120 //how much our flesh has unfrozen or frozen
	var/warming_rate = 1 //how fast our flesh warms up can be influenced by drugs and medical treatment
	var/infection_amount = 0 //idkkk
	var/infection_rate = 0.05//blegfggghhh
	var/cleanliness = 1//who knows
	var/demotes_to //what a wound downgrades to, leave blank to clear wound
	var/fullrot_sfx = 'sound/effects/soup_boil/soup_boil2.ogg'
	var/totally_rotted = FALSE

/datum/wound/frostbite/flesh/handle_process(seconds_per_tick, times_fired)

	if(!limb)
		return

	if(victim.bodytemperature >= BODYTEMP_COLD_DAMAGE_LIMIT) //if we're not freezing, start rewarming
		flesh_temperature += warming_rate*seconds_per_tick
		to_chat(victim, span_notice("Your [limb.plaintext_zone] stings as it thaws."))

	if(victim.bodytemperature <= BODYTEMP_COLD_DAMAGE_LIMIT) // we ARE freezing
		to_chat(victim, span_notice("Your [limb.plaintext_zone] loses sensation as it freezes."))
		flesh_temperature = clamp(rewarm_threshhold, 0, (flesh_temperature -= warming_rate))

	if(flesh_temperature >= rewarm_threshhold) //if we've been rewarmed, downgrade the wound

		if(infection_amount >= 10)	//if we have been rewarmed, but HAVENT cleared an infection
			if(SPT_PROB(15, seconds_per_tick))
				to_chat(victim, span_warning("Your [limb.plaintext_zone] feels warm again, but the infection remains."))
			return
		if(demotes_to)
			replace_wound(new demotes_to)
		else //we have have no wound to demote to
			to_chat(victim, span_green("Your [limb.plaintext_zone] feels warm again"))
			qdel(src)
	if(flesh_temperature == 0)// If we run out of bodyheat
		if(SPT_PROB(15, seconds_per_tick))
			to_chat(victim, span_warning("The chill in your [limb.plaintext_zone] deepens!"))
		var/frost_severity = src.severity
		switch(frost_severity)
			if(WOUND_SEVERITY_MODERATE)
				//victim.cause_wound_of_type_and_severity(WOUND_FREEZE, src.limb, WOUND_SEVERITY_SEVERE,wound_source = "cold temperatures")
				limb.force_wound_upwards(/datum/wound/frostbite/flesh/severe, smited = FALSE, wound_source = "cold temperatures")
			if(WOUND_SEVERITY_SEVERE)
				//victim.cause_wound_of_type_and_severity(WOUND_FREEZE, src.limb, WOUND_SEVERITY_CRITICAL, wound_source = "cold temperatures")
				limb.force_wound_upwards(/datum/wound/frostbite/flesh/critical, smited = FALSE, wound_source = "cold temperatures")


//Switching for infection
	infection_amount = clamp(infection_amount + (infection_rate * cleanliness),0, 100)
	switch(infection_amount)
		if(0 to 10) //little to no infection
			//no change, might not be noticed
		if(10 to 60) //minor infection
			if(SPT_PROB(10, seconds_per_tick))
				to_chat(victim, span_warning("Your [limb.plaintext_zone]'s skin forms streaks of grey and smells funny..."))
			//more frequent messages and jolts of pain
		if(60 to 99) //MAJOR INFECTION
			if(SPT_PROB(10, seconds_per_tick))
				to_chat(victim, span_warning("Your [limb.plaintext_zone] hurts"))
			//hand locks up and reduces movespeed slightly, visible emote, toxin damage
		if(99 to 100) //rotted
			if(prob(20))
				to_chat(victim, span_warning("You try to feel your [limb.plaintext_zone] but can't!"))
				victim.adjustToxLoss(0.75)
				totally_rotted = TRUE
				//TO DO make this wound not dissappear when full rotted, turns black, tox damage turns black, dead, cut it off twin
	if(totally_rotted)
		limb.add_color_override(COLOR_ALMOST_BLACK, LIMB_COLOR_HULK)
		victim.update_body_parts()
		to_chat(victim, span_warning("Your [limb.plaintext_zone]'s infection writhes as it is fully unthawed."))
		to_chat(victim, span_alert("The [limb.plaintext_zone] boils with rotten flesh!"))
		playsound(limb.owner, fullrot_sfx, 70 + (20 * severity), TRUE, falloff_exponent = SOUND_FALLOFF_EXPONENT + 2,  ignore_walls = FALSE, falloff_distance = 0)

/datum/wound/frostbite/flesh/get_wound_description(user)
	var/list/condition = list("[victim.p_Their()] [limb.plaintext_zone] [examine_desc]")
	var/infection_message
	switch(infection_amount)
		if(0 to 10) //little to no infection
			infection_message = " it appears clean."
		if(10 to 60) //minor infection
			infection_message = " it appears red and irritated."
		if(60 to 98) //MAJOR INFECTION
			infection_message = " it appears red with splotches of purple."
		if(99 to INFINITY) //rotted
			infection_message = " it is blackened and dead."
	condition += infection_message
	return "[condition.Join()]"
//mechanics todo, when on your legs you'll walk slower, when on the arms you'll craft slower
//freezing progress, pain, rewarming blisters

//First degree frostbite doesn't need to be done, can be handled by atmos mob interactions
/datum/wound/frostbite/flesh/moderate
	name = "Superficial Frostbite"
	desc = "Patient suffers Reduced feeling and control our skin layers have frozen."
	undiagnosed_name = "Frostnip"
	a_or_from = "from"
	occur_text = "becomes white and partially numb!"
	treat_text = "Rewarm, hot fluids can speed this process. Apply ointment to help with pain."
	treat_text_short = "Rewarm drink warm fluids."
	examine_desc = "skin is red and covered in blisters"
	severity = WOUND_SEVERITY_MODERATE
	damage_multiplier_penalty = 1.1
	interaction_efficiency_penalty = 1.3
	infection_rate = 0.5
	limp_slowdown = 3
	limp_chance = 20
	disabling = FALSE


/datum/wound_pregen_data/frostbite/moderate
	wound_path_to_generate = /datum/wound/frostbite/flesh/moderate
	required_limb_biostate = BIO_FLESH
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)


/datum/wound/frostbite/flesh/severe
	name = "Minor Frostbite"
	desc = "Patient suffers lack of feeling and control skin has frozen. Fat layer has partially frozen."
	undiagnosed_name = "Frostbite"
	a_or_from = "from"
	occur_text = "becomes hard to move and snow white!"
	treat_text = "Rewarm immediately. Prepare medicine for trauma from thawing. Possible infection."
	treat_text_short = "Rewarm immediately. Prepare gauze and antibiotics."
	examine_desc = "the flesh is pale and stiff."
	severity = WOUND_SEVERITY_SEVERE
	damage_multiplier_penalty = 1.3
	interaction_efficiency_penalty = 2
	infection_rate = 1
	limp_slowdown = 6
	limp_chance = 33
	disabling = FALSE
	demotes_to = /datum/wound/frostbite/flesh/moderate

/datum/wound_pregen_data/frostbite/severe
	wound_path_to_generate = /datum/wound/frostbite/flesh/severe
	required_limb_biostate = BIO_FLESH
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)

/datum/wound/frostbite/flesh/critical
	name = "Major Frostbite"
	desc = "Patient's muscle, skin and fat has fully frozen. Major infection almost guaranteed. Rewarm and prepare for amputation."
	undiagnosed_name = "Deep Frostbite"
	a_or_from = "from"
	occur_text = "becomes dark and numb!!"
	treat_text = "Prepare for amputation. Antibiotics to prevent sepsis. Rewarm limb to prevent unnecessary bloodloss from amputation."
	treat_text_short = "Amputate, rewarm to reduce bleeding."
	examine_desc = "is frozen solid and pale."
	severity = WOUND_SEVERITY_CRITICAL
	damage_multiplier_penalty = 2
	interaction_efficiency_penalty = 4
	infection_rate = 2
	limp_slowdown = 9
	limp_chance = 60
	demotes_to = /datum/wound/frostbite/flesh/severe

/datum/wound_pregen_data/frostbite/critical
	wound_path_to_generate = /datum/wound/frostbite/flesh/critical
	required_limb_biostate = BIO_FLESH
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)


//if we are above the temperature we would recieve this wound at, begin to rewarm, this will cause intermittent pain
//if we are below the temperature we would recieve this wound, start escalating to the next one
