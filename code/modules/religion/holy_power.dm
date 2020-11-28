
// normal holy powers represent some constant effect that talisman possesses
/datum/holy_power
	var/name // used to determine talisman sprite
	var/desc // description chaplain sees when inspecting talisman
	var/obj/item/weapon/paper/holy_talisman/holder
	var/application

/datum/holy_power/proc/talisman_init()
	return

/datum/holy_power/New(holder)
	if(!holder)
		qdel(src)
		CRASH("someone stupid tried to create datum without holder")
	src.holder = holder
	talisman_init()

/datum/holy_power/Destroy()
	STOP_PROCESSING(SSobj, holder)
	holder = null
	return ..()

/datum/holy_power/light
	name = "light"
	desc = "Imbued with holy power to emit shining light."

/datum/holy_power/light/talisman_init()
	holder.set_light(4)

/datum/holy_power/regen
	name = "regen"
	desc = "Imbued with holy power to regenerate wearer."

/datum/holy_power/regen/process()
	if(!holder)
		return
	if(!istype(holder.loc, /mob/living))
		return

	var/mob/living/L = holder.loc
	L.apply_damages(brute = -0.03, burn = -0.03)

/datum/holy_power/antivirus
	name = "antivirus"
	desc = "Imbued with holy power to protect wearer from virus infections."

/datum/holy_power/antivirus/process()
	if(!holder)
		return
	if(!istype(holder.loc, /mob/living/carbon))
		return

	var/mob/living/carbon/M = holder.loc
	for(var/ID in M.virus2)
		var/datum/disease2/disease/D = M.virus2[ID]
		if(D.stage < 2) // don't cure if user is already seriously infected
			D.cure(M)


/* DIRECT */

// direct holy powers can be applied to only one target
/datum/holy_power/direct
	var/list/valid_targets // when the type is invalid we silently quit without destroying the talisman

/datum/holy_power/direct/proc/apply(atom/T, mob/user)
	holder.visible_message("\The [src] vanishes as [user] hovers it against [T].")
	qdel(src)
	return

/datum/holy_power/direct/stun
	name = "stun"
	desc = "Stuns target with divine powers on application."

/datum/holy_power/direct/stun/talisman_init()
	valid_targets = typecacheof(/mob/living)

/datum/holy_power/direct/stun/apply(mob/living/T, mob/user)
	if(issilicon(T))
		T.Weaken(15)
	else if(iscarbon(T))
		var/mob/living/carbon/C = T
		C.flash_eyes()
		if(!(HULK in C.mutations))
			C.silent += 10
			C.Weaken(15)
			C.Stun(15)
	return ..()

/datum/holy_power/direct/upgrade
	name = "upgrade"
	desc = "Upgrades machinery parts on application."

/datum/holy_power/direct/upgrade/talisman_init()
	valid_targets = typecacheof(/obj/machinery)

/datum/holy_power/direct/upgrade/apply(obj/machinery/T, mob/user)
	if(T.component_parts && T.component_parts.len)
		var/do_glow = FALSE // don't glow if nothing got an upgrade
		for(var/obj/item/weapon/stock_parts/A in T.component_parts)
			if(stock_parts_increase_list[A.type])
				do_glow = TRUE
				var/replacement = stock_parts_increase_list[A.type]
				T.component_parts -= A
				T.component_parts += new replacement
				qdel(A)
		if(do_glow)
			T.RefreshParts()
			var/holy_outline = filter(type = "outline", size = 1, color = "#FFD700EE")
			T.filters += holy_outline
			animate(T.filters[T.filters.len], color = "#FFD70000", time = 2 SECONDS)
			addtimer(CALLBACK(src, .proc/revert_effects, T, user, holy_outline), 2 SECONDS)

/datum/holy_power/proc/revert_effects(atom/T, mob/user, holy_outline)
	T.filters -= holy_outline


/* INDIRECT */

// indirect holy powers either have no target
/datum/holy_power/indirect/proc/invoke(mob/user)
	holder.visible_message("\The [src] vanishes as [user] holds it.")
	qdel(src)
	return