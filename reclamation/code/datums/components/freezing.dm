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
	/* switch stages */
	to_chat(parent, span_warning("before switch"))
	switch(warmth_stacks)
		if(WARMTH_TIER_1 to WARMTH_TIER_0)//warm
			to_chat(parent, span_warning("tier 1"))
//don't do anything, this is our "normal" state
		if(WARMTH_TIER_2 to WARMTH_TIER_1)//chilly
			parent.throw_alert(FREEZING_ALERT,/atom/movable/screen/alert/freezing)
			to_chat(parent, span_warning("25"))
		if(WARMTH_TIER_3 to WARMTH_TIER_2)//cold
			parent.throw_alert(FREEZING_ALERT,/atom/movable/screen/alert/freezing)
			to_chat(parent, span_warning("28"))
		if(WARMTH_TIER_3)//freezing
			parent.throw_alert(FREEZING_ALERT,/atom/movable/screen/alert/freezing)
			to_chat(parent, span_warning("31"))
