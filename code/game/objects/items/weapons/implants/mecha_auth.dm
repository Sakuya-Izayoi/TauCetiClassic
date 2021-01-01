/obj/item/weapon/implant/mecha_auth
	name = "mecha auth implant"
	desc = "Allows user to access protected exosuits."
	var/corp = "Nanotrasen"
	data = list("id" = 1)

/obj/item/weapon/implant/mecha_auth/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> [corp] Exosuit Authorization Key<BR>
				<b>Life:</b> Ten year.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains NFC circuit that communicates with authorization device in exosuit.<BR>
				<b>Special Features:</b> Allows bearer to access locked exosuits.<BR>
				<b>Integrity:</b> Implant will last until the circuitry is intact.<BR>"}
	return dat

/obj/item/weapon/implant/mecha_auth/proc/auth(id)
	if(malfunction)
		return pick(TRUE, FALSE)
	return id == data["id"]

/obj/item/weapon/implant/mecha_auth/syndie
	corp = "Cybersun Industries"
	data = list("id" = 69)

/obj/item/mecha_parts/module/mecha_auth
	name = "Exosuit auth module"
	desc = "Device that protects exosuit from unauthorized access"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	w_class = ITEM_SIZE_SMALL
	var/id = 1

/obj/item/mecha_parts/module/mecha_auth/proc/auth(mob/user)
	if(prob(reliability))
		for(var/obj/item/weapon/implant/mecha_auth/I in user)
			if(I.auth(id))
				return TRUE
		return FALSE
	return pick(TRUE, FALSE)

/obj/item/mecha_parts/module/mecha_auth/attack_self(mob/user)
	id = clamp(input(user, "Set new auth module ID (1 - 100)", "Exosuit auth module", id) as num, 0, 100)

/obj/item/mecha_parts/module/mecha_auth/syndie
	id = 69