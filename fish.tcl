#
# 2010/12/09
#
# irssi-tcl script for FiSH IRC channels
#
# Setup:
#  /set fish_keys key1,#channel1 key2,#channel2 ..
#
# If you don't want to send encrypted to channels set with key, set:
#  /set fish_send_encrypted off
#
# Any channel that has a key set which receives a message
# prefixed with +OK will be decrypted with that key
# and any messages entered into that channel will be sent encrypted
#

set path_to_libfish /home/will/code/fish-tcl
load ${path_to_libfish}/libfish[info sharedlibextension]

namespace eval fish {
	settings_add_str "fish_keys" ""
	settings_add_str "fish_send_encrypted" ""

	signal_add msg_pub "+OK" fish::handler
	signal_add send_text "" fish::send_text

	set tag "\[\002fish\002\]"
}

proc fish::get_key {chan} {
	set raw [settings_get_str "fish_keys"]
	set entries [split $raw]
	foreach pair $entries {
		if {[lindex [split $pair ,] 1] == $chan} {
			return [lindex [split $pair ,] 0]
		}
	}
	return ""
}

proc fish::handler {server nick uhost chan argv} {
	set key [fish::get_key $chan]
	if {$key == ""} { return }

	if {[catch {decrypt $key $argv} decrypted]} {
		set output "$fish::tag Error decrypting: $decrypted"
	} else {
		set output "$fish::tag $decrypted"
	}
	signal_stop
	emit_message_public $server $chan $nick $uhost $output
}

proc fish::send_text {server target line} {
	# check whether we have outgoing encryption enabled
	if {[settings_get_str "fish_send_encrypted"] == "off"} { return }

	set key [fish::get_key $target]
	if {$key == ""} { return }

	signal_stop

	if {[catch {encrypt $key $line} text]} {
		irssi_print "$fish::tag Error encrypting '$line': $text"
	} else {
		putchan $server $target "+OK $text"
		irssi_print "$fish::tag (you) $line"
	}
}

proc fish::crypt {key text} {
	irssi_print [encrypt $key $text]
}

irssi_print "fish.tcl loaded"
