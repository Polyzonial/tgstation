#define WARMTH_TIER_0 100
#define WARMTH_TIER_1 66
#define WARMTH_TIER_2 33
#define WARMTH_TIER_3 0
/datum/component/freezing
	///consider this our internal 'reserve' of bodyheat for our fluids and such
	var/warmth_stacks = 100
	var/max_warmth_stacks = 100 //how many stacks of warmth we can have
	var/min_warmth_stacks = 0


/datum/component/freezing/Initialize()
	RegisterSignal(src, WARMTH_ALTER, PROC_REF(modify_warmth))
	START_PROCESSING(SSprocessing, src)

/datum/component/freezing/proc/modify_warmth(mob/parent, warmth_remove)
	SIGNAL_HANDLER
	warmth_stacks = clamp(warmth_stacks -= warmth_remove, min_warmth_stacks, max_warmth_stacks)
	/* switch stages */
	switch(warmth_stacks)
		if(WARMTH_TIER_1 to WARMTH_TIER_0)//warm
//don't do anything, this is our "normal" state
		if(WARMTH_TIER_2 to WARMTH_TIER_1)//chilly
			parent.throw_alert(/atom/movable/screen/alert/freezing)
		if(WARMTH_TIER_3 to WARMTH_TIER_2)//cold
			parent.throw_alert(/atom/movable/screen/alert/freezing)
		if(WARMTH_TIER_3)//freezing
			parent.throw_alert(/atom/movable/screen/alert/freezing)
