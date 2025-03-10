/mob/living/silicon/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	log_say(multilingual_to_message(message_pieces), src)
	if(..())
		return 1

/mob/living/silicon/robot/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(..())
		return 1
	if(message_mode)
		used_radios += radio
		if(!is_component_functioning("radio"))
			to_chat(src, "<span class='warning'>Ваше радио не работает сейчас.</span>")
			return 0
		if(message_mode == "general")
			message_mode = null
		return radio.talk_into(src,message_pieces,message_mode,verb)

/mob/living/silicon/ai/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(..())
		return 1
	if(message_mode == "department")
		used_radios += aiRadio
		return holopad_talk(message_pieces, verb)
	else if(message_mode)
		used_radios += aiRadio
		if(aiRadio.disabledAi || aiRestorePowerRoutine || stat)
			to_chat(src, "<span class='danger'>Системная ошибка - Передатчик отключен.</span>")
			return 0
		if(message_mode == "general")
			message_mode = null
		return aiRadio.talk_into(src, message_pieces, message_mode, verb)

/mob/living/silicon/pai/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(..())
		return 1
	else if(message_mode == "whisper")
		whisper_say(message_pieces)
		return 1
	else if(message_mode)
		if(message_mode == "general")
			message_mode = null
		used_radios += radio
		return radio.talk_into(src, message_pieces, message_mode, verb)

/mob/living/silicon/say_quote(text)
	var/ending = copytext(text, length(text))

	if(ending == "?")
		return speak_query
	else if(ending == "!")
		return speak_exclamation

	return speak_statement

#define IS_AI 1
#define IS_ROBOT 2
#define IS_PAI 3

/mob/living/silicon/say_understands(other, datum/language/speaking = null)
	//These only pertain to common. Languages are handled by mob/say_understands()
	if(!speaking && ismob(other))
		if(iscarbon(other))
			return TRUE
		if(issilicon(other))
			return TRUE
		if(isbot(other))
			return TRUE
		if(isbrain(other))
			return TRUE
	return ..()

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(list/message_pieces, verb)
	log_say("(HPAD) [multilingual_to_message(message_pieces)]", src)

	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.masters[src])
		var/obj/effect/overlay/holo_pad_hologram/H = T.masters[src]
		if((client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT) && can_hear())
			var/message = combine_message(message_pieces, null, src)
			create_chat_message(H, message)
		for(var/mob/M in hearers(T.loc))//The location is the object, default distance.
			M.hear_holopad_talk(message_pieces, verb, src, H)
		to_chat(src, "<i><span class='game say'>Переданная речь, <span class='name'>[real_name]</span> [combine_message(message_pieces, verb, src)]</span></i>")
	else
		to_chat(src, "Нет подключённого голопада.")
		return
	return 1

/mob/living/silicon/ai/proc/holopad_emote(message) //This is called when the AI uses the 'me' verb while using a holopad.
	message = trim(message)

	if(!message)
		return

	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.masters[src])
		var/rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message]</span></span>"
		to_chat(src, "<i><span class='game say'>Переданное действие, <span class='name'>[real_name]</span> <span class='message'>[message]</span></span></i>")

		for(var/mob/M in viewers(T.loc))
			M.show_message(rendered, EMOTE_VISIBLE, chat_message_type = MESSAGE_TYPE_LOCALCHAT)

		log_emote("(HPAD) [message]", src)
	else //This shouldn't occur, but better safe then sorry.
		to_chat(src, "Нет подключённого голопада.")
		return
	return 1

/mob/living/silicon/ai/emote(act, type, message, intentional = TRUE, force_silence = FALSE)
	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.masters[src])//Is the AI using a holopad?
		holopad_emote(message)
	else //Emote normally, then.
		..()

#undef IS_AI
#undef IS_ROBOT
#undef IS_PAI
