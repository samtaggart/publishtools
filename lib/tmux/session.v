module tmux

import os
import vredis2

struct Session {
pub mut:
	windows map[string]Window
	name    string
}

fn init_session(s_name string) Session {
	mut s := Session{
		name: s_name
	}
	os.log('tmux session: $s.name')
	s.windows = map[string]Window{}
	s.name = s.name.to_lower()
	return s
}

fn (mut s Session) create() {
	os.exec("tmux new-session -d -s $s.name 'sh'") or {
		os.Result{
			exit_code: 1
			output: 'cannot create tmux session $s.name'
		}
	}
	os.exec("tmux rename-window -t 0 'notused'") or {
		os.Result{
			exit_code: 1
			output: ''
		}
	}
}

fn (mut s Session) restart() {
	s.stop()
	s.create()
}

fn (mut s Session) stop() {
	os.exec('tmux kill-session -t $s.name') or {
		os.Result{
			exit_code: 1
			output: ''
		}
	}
}

fn (mut s Session) activate() {
	mut redis := vredis2.connect('localhost:6379') or { panic("Couldn't connect to redis client")}
	active_session := redis.get('tmux:active_session') or {" - Couldn't get tmux:active_session"}
	if s.name != active_session {
		os.exec('tmux switch -t $s.name') or {
			os.Result{
				exit_code: 1
				output: ''
			}
		}
		redis.set('tmux:active_session', s.name) or {panic("Failed to set tmux:active_session")}
	}
}

fn (mut s Session) execute(cmd string, check string) {
	os.log(cmd)
	os.log(check)
}

fn (mut s Session) window_exist(name string) bool {
	return name.to_lower() in s.windows
}

pub fn (mut s Session) window_get(name string) Window {
	name_l := name.to_lower()
	mut window := Window{}
	if name_l in s.windows {
		window = s.windows[name_l]
	} else {
		window = init_window(s, name_l, 0, false, 0)
		s.windows[name_l] = window
	}
	return window
}