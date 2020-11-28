/* Talismans
   Chaplain can enchant piece of papers with powers of their god.
   There are three types of talismans effects: always active, direct and indirect (currently unused).
   Always active talismans provide wearer with some buffs while talisman is being worn. Everyone can benefit from those effects.
   Direct talismans provide some effect when chaplain hits someone with it.
   Indirect talismans provide effect when chaplain uses them in hands.

   Creation of talismans requires Partum (Spawn) aspect.

   See effects in holy_power.dm
*/

/obj/item/weapon/paper/holy_talisman
	icon_state = "holy_talisman"
	var/datum/holy_power/power
	var/power_t = /datum/holy_power

/obj/item/weapon/paper/holy_talisman/atom_init()
	. = ..()
	power = new power_t(src)
	if(power.name)
		icon_state = "[icon_state]_[power.name]"

/obj/item/weapon/paper/holy_talisman/attack_self(mob/user)
	if(!user.mind.holy_role && !istype(src, /datum/holy_power/indirect))
		return ..()
	var/datum/holy_power/indirect/D = power
	D.invoke(user)

/obj/item/weapon/paper/holy_talisman/attack(atom/T, mob/user)
	if(!user.mind.holy_role && !istype(src, /datum/holy_power/direct))
		return ..()
	var/datum/holy_power/direct/D = power
	if(D.valid_targets)
		if(!is_type_in_typecache(T, D.valid_targets))
			return
	D.apply(T, user)

/obj/item/weapon/paper/holy_talisman/examine(mob/user)
	if(user.mind.holy_role && power && power.desc)
		to_chat(user, power.desc)
	return ..()

/obj/item/weapon/paper/holy_talisman/light
	power_t = /datum/holy_power/light

/obj/item/weapon/paper/holy_talisman/regen
	power_t = /datum/holy_power/regen

/obj/item/weapon/paper/holy_talisman/antivirus
	power_t = /datum/holy_power/antivirus

/obj/item/weapon/paper/holy_talisman/stun
	power_t = /datum/holy_power/direct/stun

/obj/item/weapon/paper/holy_talisman/upgrade
	power_t = /datum/holy_power/direct/upgrade