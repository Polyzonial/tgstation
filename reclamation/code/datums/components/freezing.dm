#define WARMTH_TIER_0 100
#define WARMTH_TIER_1 66
#define WARMTH_TIER_2 33
#define WARMTH_TIER_3 0
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
	to_chat(parent, span_warning("before switch"))
	var/cold_slowdown = ((max_warmth_stacks - warmth_stacks)/100)
	switch(warmth_stacks)
		if(WARMTH_TIER_1 to WARMTH_TIER_0)//warm
			parent.clear_alert(FREEZING_ALERT)
			parent.remove_movespeed_modifier(/datum/movespeed_modifier/freezing, update = TRUE)
			parent.remove_actionspeed_modifier(/datum/movespeed_modifier/freezing, update = TRUE)
//don't do anything, this is our "normal" state
		if(WARMTH_TIER_2 to WARMTH_TIER_1)//chilly
			parent.throw_alert(FREEZING_ALERT,/atom/movable/screen/alert/freezing)
			parent.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/freezing, TRUE, cold_slowdown)
			parent.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/freezing, TRUE, cold_slowdown)
		if(WARMTH_TIER_3 to WARMTH_TIER_2)//cold
			parent.throw_alert(FREEZING_ALERT,/atom/movable/screen/alert/freezing)
			parent.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/freezing, TRUE, cold_slowdown)
			parent.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/freezing, TRUE, cold_slowdown)
		if(WARMTH_TIER_3)//freezing
			//to add: cold damage, hallucinations of overheating, freezing wounds and recovery
			parent.throw_alert(FREEZING_ALERT,/atom/movable/screen/alert/freezing)
			parent.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/freezing, TRUE, cold_slowdown)
			parent.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/freezing, TRUE, cold_slowdown)
			apply_frost_wounds()

/datum/component/freezing/proc/apply_frost_wounds()
