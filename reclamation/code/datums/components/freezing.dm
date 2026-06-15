#define WARMTH_TIER_0 110
#define WARMTH_TIER_1 66
#define WARMTH_TIER_2 33
#define WARMTH_TIER_3 10
/datum/component/freezing
	///consider this our internal 'reserve' of bodyheat for our fluids and such
	var/warmth_stacks = 100
	var/max_warmth_stacks = 100 //how many stacks of warmth we can have
	var/min_warmth_stacks = 0


/datum/component/freezing/Initialize(...)
	RegisterSignal(parent, WARMTH_ALTER, PROC_REF(modify_warmth))
	START_PROCESSING(SSprocessing, src)

/datum/component/freezing/proc/modify_warmth(mob/parent, warmth_remove = 0)
	SIGNAL_HANDLER

	warmth_stacks = clamp((warmth_stacks - warmth_remove), min_warmth_stacks, max_warmth_stacks)
	/* switch stages to do, make it so your insulation decreases the speed this decrease*/
	//to_chat(parent, span_warning("before switch"))
	var/cold_slowdown = ((max_warmth_stacks - warmth_stacks)/110)
	switch(warmth_stacks)
		if(WARMTH_TIER_1 to WARMTH_TIER_0)//warm
			to_chat(parent, span_warning("tier 0"))
			parent.clear_alert(FREEZING_ALERT)
			parent.remove_movespeed_modifier(/datum/movespeed_modifier/freezing, update = TRUE)
			parent.remove_actionspeed_modifier(/datum/movespeed_modifier/freezing, update = TRUE)
//don't do anything, this is our "normal" state
		if(WARMTH_TIER_2 to WARMTH_TIER_1)//chilly
			to_chat(parent, span_warning("tier 1"))
			parent.throw_alert(FREEZING_ALERT,/atom/movable/screen/alert/freezing)
			parent.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/freezing, TRUE, cold_slowdown)
			parent.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/freezing, TRUE, cold_slowdown)
		if(WARMTH_TIER_3 to WARMTH_TIER_2)//cold
			to_chat(parent, span_warning("tier 2"))
			parent.throw_alert(FREEZING_ALERT,/atom/movable/screen/alert/freezing)
			parent.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/freezing, TRUE, cold_slowdown)
			parent.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/freezing, TRUE, cold_slowdown)
		if(0 to WARMTH_TIER_3)//freezing
			to_chat(parent, span_warning("tier 3"))
			//to add: cold damage, hallucinations of overheating, freezing wounds and recovery
			parent.throw_alert(FREEZING_ALERT,/atom/movable/screen/alert/freezing)
			parent.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/freezing, TRUE, cold_slowdown)
			parent.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/freezing, TRUE, cold_slowdown)
			apply_frost_wounds(parent)

/datum/component/freezing/proc/apply_frost_wounds(mob/living/carbon/human/parent)
	SIGNAL_HANDLER

	// If we are resistant to cold exit
	to_chat(parent, span_warning("frost wounds"))
	if(HAS_TRAIT(parent, TRAIT_RESISTCOLD))
		to_chat(parent, span_warning("54"))
		return
	//If our body temp is to high for a wound exit
	if(parent.bodytemperature > BODYTEMP_COLD_DAMAGE_LIMIT)
		to_chat(parent, span_warning("58"))
		return

	var/list/parts = list()
	for(var/obj/item/bodypart/to_freeze as anything in parent.bodyparts)
		if(to_freeze.body_zone == BODY_ZONE_HEAD || to_freeze.body_zone == BODY_ZONE_CHEST)
			continue
		if(to_freeze.bodypart_flags & BODYPART_UNREMOVABLE)
			continue
		parts += to_freeze
	if(!length(parts))
		to_chat(parent, span_warning("no valid limbs found"))
		return
	var/obj/item/bodypart/to_freeze = pick(parts)
	var/datum/wound/existing_frostbite
	for(var/datum/wound/iterated_wound as anything in to_freeze.wounds)
		var/datum/wound_pregen_data/pregen_data = iterated_wound.get_pregen_data()
		if(pregen_data.wound_series in GLOB.wounding_types_to_series[WOUND_FREEZE])
			existing_frostbite = iterated_wound
			break
	//if we have an existing frostbite, don't apply a new one
	if(existing_frostbite)
		to_chat(parent, span_warning("to freeze failed [to_freeze.plaintext_zone] has wound already"))
	else
		to_freeze.force_wound_upwards(/datum/wound/frostbite/flesh/moderate, wound_source = "cold temperatures")
		to_chat(parent, span_warning("success [to_freeze.plaintext_zone] frozen!"))

