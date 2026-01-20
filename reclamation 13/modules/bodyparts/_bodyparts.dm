//Deals organ damage if a threshold is met

/obj/item/bodypart/proc/organ_attack(brute = 0, burn = 0, sharpness = NONE)
	var/damage_threshold = 20
	var/damage_amt = brute + burn

	if(sharpness & SHARP_POINTY)
		damage_threshold *= 0.5

	if(damage_amt <= damage_threshold)
		return FALSE

	var/list/organ_list = list()
	var/weighted_sum = 0
	for(var/obj/item/organ/I in contents)
		if(I.damage < I.maxHealth)
			organ_list[I] = I.organ_hit_weight
			weighted_sum += I.organ_hit_weight

	//No damageable organs
	if(!length(organ_list))
		return FALSE

	if(prob(min(weighted_sum, 100)))
		var/obj/item/organ/target = pick_weight(organ_list)
		target.apply_organ_damage(damage_amt)
		return TRUE
