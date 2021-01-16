/obj/structure/cult/tech_table
	name = "scientific altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"
	light_color = "#2f0e0e"
	light_power = 2
	light_range = 3

	// /datum/aspect = image
	// Maybe be wrapped too in /datum/building_agent
	var/static/list/aspect_images
	// /datum/building_agent = image
	var/static/list/uniq_images
	// string = image
	var/static/list/category_images
	var/researching = FALSE
	var/research_time = 20 MINUTES
	var/end_research_time

	var/list/pylon_around

/obj/structure/cult/tech_table/Destroy()
	pylon_around = null
	return ..()

/obj/structure/cult/tech_table/examine(mob/user, distance)
	..()
	if(!user.mind.holy_role || !user.my_religion || user.my_religion.aspects.len == 0)
		return

	to_chat(user, "<span class='notice'>Aspects and his power in your religion:</span>")
	for(var/name in user.my_religion.aspects)
		var/datum/aspect/A = user.my_religion.aspects[name]
		to_chat(user, "\t<font color='[A.color]'>[name]</font> with power of <font size='[1+A.power]'><i>[A.power]</i></font>")

/obj/structure/cult/tech_table/attack_hand(mob/living/user)
	if(!user.mind.holy_role || !user.my_religion)
		return

	if(researching)
		to_chat(user, "<span class='warning'>There are [round((end_research_time - world.time) * 0.1)] seconds left until the end of studying the aspect.</span>")
		return

	if(!category_images || !uniq_images || !aspect_images)
		gen_aspect_images()
		gen_tech_images(user)
		gen_category_images()

	var/choice = show_radial_menu(user, src, category_images, tooltips = TRUE, require_near = TRUE)

	switch(choice)
		if("Aspect")
			choose_aspect(user)
		if("Unique techs")
			choose_uniq_tech(user)

/obj/structure/cult/tech_table/proc/choose_uniq_tech(mob/living/user)
	for(var/datum/building_agent/B in uniq_images)
		B.name = "[initial(B.name)] [B.get_costs()]"

	var/datum/building_agent/choosed_tech = show_radial_menu(user, src, uniq_images, tooltips = TRUE, require_near = TRUE)
	if(!choosed_tech)
		return
	if(!user.my_religion.check_costs(choosed_tech.favor_cost, choosed_tech.piety_cost, user))
		return

	to_chat(user, "<span class='notice'>You started to explore the [initial(choosed_tech.name)].</span>")

	start_activity(CALLBACK(src, .proc/research_tech, user.my_religion, choosed_tech))

/obj/structure/cult/tech_table/proc/research_tech(datum/religion/R, datum/building_agent/tech/choosed_tech)
	var/datum/religion_tech/T = new choosed_tech.building_type
	T.apply_effect(R)
	qdel(T)
	qdel(uniq_images[choosed_tech])
	uniq_images -= choosed_tech

	end_activity()

/obj/structure/cult/tech_table/proc/choose_aspect(mob/living/user)
	// Generates a name with the power of an aspect and upgrade cost
	for(var/datum/aspect/A in aspect_images)
		var/datum/aspect/in_religion = user.my_religion.aspects[initial(A.name)]
		A.name = "[initial(A.name)], power: [in_religion ? in_religion.power : "0"], upgrade piety cost: [get_upgrade_cost(in_religion)]"

	var/datum/aspect/choosed_aspect = show_radial_menu(user, src, aspect_images, tooltips = TRUE, require_near = TRUE)
	if(!choosed_aspect)
		return
	var/datum/aspect/in_religion = user.my_religion.aspects[initial(choosed_aspect.name)]
	if(!user.my_religion.check_costs(null, get_upgrade_cost(in_religion), user))
		return

	to_chat(user, "<span class='notice'>You started to [in_religion ? "upgrade" : "explore"] the [initial(choosed_aspect.name)].</span>")
	start_activity(CALLBACK(src, .proc/upgrade_aspect, user.my_religion, choosed_aspect))

/obj/structure/cult/tech_table/proc/upgrade_aspect(datum/religion/R, datum/aspect/aspect_to_upgrade)
	if(initial(aspect_to_upgrade.name) in R)
		var/datum/aspect/A = R.aspects[initial(aspect_to_upgrade.name)]
		A.power += 1
	else
		R.add_aspects(list(aspect_to_upgrade.type = 1))

	end_activity()

/obj/structure/cult/tech_table/proc/get_upgrade_cost(datum/aspect/in_religion)
	if(!in_religion)
		return 300
	else
		return in_religion.power * 50

/obj/structure/cult/tech_table/proc/gen_category_images()
	category_images = list(
		"Aspect" = aspect_images[pick(aspect_images)],
		"Unique techs" = uniq_images[pick(uniq_images)],
	)

/obj/structure/cult/tech_table/proc/gen_tech_images(mob/living/user)
	uniq_images= list()
	for(var/datum/building_agent/tech/BA in user.my_religion.available_techs)
		uniq_images[BA] = image(icon = BA.icon, icon_state = BA.icon_state)

/obj/structure/cult/tech_table/proc/gen_aspect_images()
	var/list/aspects = subtypesof(/datum/aspect)
	aspect_images = list()
	for(var/type in aspects)
		var/datum/aspect/A = new type
		if(!A.name)
			qdel(A)
			continue
		aspect_images[A] = image(icon = A.icon, icon_state = A.icon_state)

/obj/structure/cult/tech_table/proc/start_activity(datum/callback/end_activity)
	LAZYINITLIST(pylon_around)
	for(var/obj/structure/cult/pylon/P in oview(3))
		pylon_around += P
		P.icon_state = "pylon_glow"
	researching = TRUE
	end_research_time = world.time + research_time - (pylon_around.len SECONDS) // I will forget it, heh..
	addtimer(end_activity, research_time)

/obj/structure/cult/tech_table/proc/end_activity()
	researching = FALSE
	for(var/obj/structure/cult/pylon/P in pylon_around)
		pylon_around -= P
		P.icon_state = "pylon"