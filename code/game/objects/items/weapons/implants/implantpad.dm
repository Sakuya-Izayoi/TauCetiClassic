//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/implantpad
	name = "implantpad"
	desc = "Used to modify implants."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantpad-0"
	item_state = "electronic"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	var/obj/item/weapon/implantcase/case = null
	var/broadcasting = null
	var/listening = 1.0

/obj/item/weapon/implantpad/proc/update()
	if (src.case)
		src.icon_state = "implantpad-1"
	else
		src.icon_state = "implantpad-0"
	return


/obj/item/weapon/implantpad/attack_hand(mob/user)
	if ((src.case && (user.l_hand == src || user.r_hand == src)))
		user.put_in_active_hand(case)

		src.case.add_fingerprint(user)
		src.case = null

		src.add_fingerprint(user)
		update()
	else
		return ..()
	return


/obj/item/weapon/implantpad/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/implantcase))
		if(!case)
			user.drop_from_inventory(I, src)
			case = I
			update()

	else
		return ..()

/obj/item/weapon/implantpad/attack_self(mob/user)
	user.set_machine(src)
	var/dat = ""
	if (case)
		if(case.imp)
			if(istype(case.imp, /obj/item/weapon/implant))
				dat += case.imp.get_data()
				if(case.imp.data["id"] != null)
					dat += {"ID (1-100):
					<A href='byond://?src=\ref[src];tracking_id=-10'>-</A>
					<A href='byond://?src=\ref[src];tracking_id=-1'>-</A> [case.imp.data["id"]]
					<A href='byond://?src=\ref[src];tracking_id=1'>+</A>
					<A href='byond://?src=\ref[src];tracking_id=10'>+</A><BR>"}
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"

	var/datum/browser/popup = new(user, "implantpad", "Implant Mini-Computer")
	popup.set_content(dat)
	popup.open()
	return


/obj/item/weapon/implantpad/Topic(href, href_list)
	..()
	if (usr.incapacitated())
		return
	if ((usr.contents.Find(src)) || ((in_range(src, usr) && istype(loc, /turf))))
		usr.set_machine(src)
		if (href_list["tracking_id"] && case.imp.data["id"] != null)
			case.imp.data["id"] += text2num(href_list["tracking_id"])
			case.imp.data["id"] = clamp(case.imp.data["id"], 1, 100)

		if (istype(loc, /mob))
			attack_self(loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					attack_self(M)
		add_fingerprint(usr)
	else
		usr << browse(null, "window=implantpad")
		return
	return
