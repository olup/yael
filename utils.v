module via

import net

fn match_routes(route_one string, route_two string) ?map[string]string {
	route_one_tokens := route_one.split('/')
	route_two_tokens := route_two.split('/')

	mut matchs := map[string]string{}
	for index, token in route_one_tokens {
		if route_two_tokens.len < index + 1 {
			return none
		}
		if token.starts_with(':') {
			matchs[token.trim(':')] = route_two_tokens[index]
		} else if token != route_two_tokens[index] {
			return none
		}
	}
	return matchs
}

fn parse_query(query string) map[string]string {
	mut values := map[string]string{}
	if query.len == 0 {
		return values
	}
	words := query.split('&')
	tmp_query := words.map(it.split('='))
	for data in tmp_query {
		if data.len == 2 {
			values[data[0]] = data[1]
		} else {
			values[data[0]] = 'true'
		}
	}
	return values
}

fn strip(s string) string {
	// strip('\nabc\r\n') => 'abc'
	return s.trim('\r\n')
}

fn send_string(conn net.TcpConn, s string) ? {
	conn.write(s.bytes()) ?
}
