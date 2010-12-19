#
# 2010/12/09
#
# irssi-tcl script for FiSH IRC channels
#
# Commands:
#  /fish <#channel> <message>
#
# Setup:
#  /set fish_keys key1,#channel1 key2,#channel2
#
# Any channel that has a key set which receives a message
# prefixed with +OK will be decrypted with that key
#

set path_to_libfish /home/will/code/fish-tcl
load ${path_to_libfish}/libfish[info sharedlibextension]

namespace eval fish {
	settings_add_str "fish_keys" ""

	signal_add msg_pub "+OK" fish::handler
}

proc fish::enabled {chan} {
	set raw [settings_get_str "fish_keys"]
	set entries [split $raw]
	foreach pair $entries {
		if {[lindex [split $pair ,] 1] == $chan} {
			return 1
		}
	}
	return 0
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
	if {![fish::enabled $chan]} { return }
	set key [fish::get_key $chan]
	if {[catch {decrypt $key $argv} decrypted]} {
		set output "\[\002fish\002\] Error decrypting: $decrypted"
	} else {
		set output "\[\002fish\002\] $decrypted"
	}
	signal_stop
	emit_message_public $server $chan $nick $uhost $output
}

proc fish::crypt {key text} {
	irssi_print [encrypt $key $text]
}

irssi_print "fish.tcl loaded"
