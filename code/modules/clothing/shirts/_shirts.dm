/obj/item/clothing/shirt
	name = "test shirt"
	icon = 'icons/mob/clothing/suits/costume.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	abstract_type = /obj/item/clothing/shirt
	body_parts_covered = CHEST|ARMS
	slot_flags = ITEM_SLOT_SHIRT
	interaction_flags_click = NEED_DEXTERITY|ALLOW_RESTING
	armor_type = /datum/armor/clothing_shirt
	drop_sound = 'sound/items/handling/cloth/cloth_drop1.ogg'
	pickup_sound = 'sound/items/handling/cloth/cloth_pickup1.ogg'
	limb_integrity = 30

/datum/armor/clothing_shirt
	bio = 10
	wound = 5

/obj/item/clothing/shirt/color
	name = "White shirt"
	desc = "A Normal white shirt for testing"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	icon_state = "worn_out"
	inhand_icon_state = null
