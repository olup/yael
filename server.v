// Copyright (c) 2019-2020 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module yael

import io
import net
import net.http
import strings
import time

const (
	separator                 = '\r\n'
	http_request_typical_size = 1024
)

struct Server {
pub mut:
	port   int
	router Chain
}

pub fn create_server() Server {
	server := Server{
		router: chain([])
	}
	return server
}

pub fn (mut s Server) listen(port int) {
	s.port = port
	listener := net.listen_tcp(s.port) or { panic('Failed to listen to port $port') }
	println('Server started on port $port')
	for {
		conn := listener.accept() or { panic('conn accept() failed.') }
		handle_http_connection(mut s, &conn)
	}
}

fn handle_http_connection(mut s Server, mut conn net.TcpConn) {
	conn.set_read_timeout(1 * time.second)
	defer {
		conn.close() or { }
	}
	mut reader := io.new_buffered_reader(reader: io.make_reader(conn))
	page_gen_start := time.ticks()
	first_line := reader.read_line() or {
		println('Failed first_line')
		return
	}
	$if debug {
		println('firstline="$first_line"')
	}
	vals := first_line.split(' ')
	if vals.len < 2 {
		println('no vals for http')
		send_string(conn, status_code_msg(500)) or { }
		return
	}
	mut headers := []string{}
	mut body := ''
	mut in_headers := true
	mut len := 0
	for _ in 0 .. 100 {
		line := reader.read_line() or {
			println('Failed read_line')
			break
		}
		sline := strip(line)
		if sline == '' {
			if len == 0 {
				break
			}
			read_body := io.read_all(reader: reader) or { []byte{} }
			body += read_body.bytestr()
			break
		}
		if in_headers {
			headers << sline
			if sline.starts_with('Content-Length') {
				len = sline.all_after(': ').int()
			}
		}
	}
	url := vals[1]
	path := url.split('?')[0]
	query := url.trim_prefix('$path').trim_prefix('?')
	req := Req{
		method: http.method_from_str(vals[0]).str()
		url: url
		path: path
		headers: http.parse_headers(headers)
		body: strip(body)
		query: query
		query_map: parse_query(query)
	}
	res := Res{
		status: 200
		headers: {
			'Content-Type': 'text/plain'
			'Server':       'yael'
			'X-Powered-By': 'yael'
		}
		body: 'Hello world !'
		connection: conn
	}
	s.router.handle(req, res)
}
