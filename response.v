module yael

import net
import strings

struct Res {
pub mut:
	status     int
	headers    map[string]string
	connection &net.TcpConn
	body       string
}

pub fn (res Res) status(status int) Res {
	return {
		res |
		status: status
	}
}

fn (res Res) send_response() {
	conn := res.connection
	statuscode_msg := status_code_msg(res.status)
	mut sb := strings.new_builder(1024)
	defer {
		sb.free()
	}
	sb.write('HTTP/1.1 $res.status$separator')
	for header_name, header_value in res.headers {
		sb.write('$header_name: $header_value$separator')
	}
	sb.write('Content-Length: $res.body.len${separator}Connection: close$separator$separator')
	sb.write(if res.body == '' {
		statuscode_msg
	} else {
		res.body
	})
	s := sb.str()
	defer {
		s.free()
	}
	conn.write_str(s) or { }
	conn.close() or { }
}

pub fn (res Res) text(text string) {
	mut headers := res.headers
	headers['Content-Type'] = 'text'
	this_res := {
		res |
		headers: headers
		body: text
	}
	this_res.send_response()
}

pub fn (res Res) json(text string) {
	mut headers := res.headers
	headers['Content-Type'] = 'application/json'
	this_res := {
		res |
		headers: headers
		body: text
	}
	this_res.send_response()
}

pub fn (res Res) html(text string) {
	mut headers := res.headers
	headers['Content-Type'] = 'text/html'
	this_res := {
		res |
		headers: headers
		body: text
	}
	this_res.send_response()
}
