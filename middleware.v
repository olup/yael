module yael

interface Middleware {
	handle(req Req, res Res) ?(Req, Res)
}

type Callback_signature = fn (req Req, res Res) ?(Req, Res)

// Method middleware
struct Method {
	method string = 'GET'
}

pub fn (middleware Method) handle(req Req, res Res) ?(Req, Res) {
	if middleware.method != req.method {
		return none
	}
	return req, res
}

pub fn method(method string) Method {
	return Method{
		method: method
	}
}

// Route Middlware
struct Route {
	route string
}

pub fn (middleware Route) handle(req Req, res Res) ?(Req, Res) {
	matches := match_routes(middleware.route, req.path) or { return none }
	return {
		req |
		params: matches
	}, res
}

pub fn route(route string) Route {
	mdlw := Route{
		route: route
	}
	return mdlw
}

// Callback Middleware
struct Callback {
	callback fn (Req, Res) ?(Req, Res)
}

pub fn (middleware Callback) handle(req Req, res Res) ?(Req, Res) {
	return middleware.callback(req, res)
}

pub fn callback(callback fn (Req, Res) ?(Req, Res)) Callback {
	return Callback{
		callback: callback
	}
}

// Chain Middleware
pub struct Chain {
pub mut:
	name        string
	middlewares []&Middleware
}

pub fn chain(middlewares []&Middleware) Chain {
	return Chain{
		middlewares: middlewares
	}
}

fn (chainer Chain) handle(req Req, res Res) ?(Req, Res) {
	mut this_req := req
	mut this_res := res
	for md in chainer.middlewares {
		this_req, this_res = md.handle(this_req, this_res) or { break }
	}
	return req, res
}

pub fn (mut chainer Chain) use(m &Middleware) {
	chainer.middlewares << m
}

pub fn (mut chainer Chain) get(route_path string, callback fn (Req, Res) ?(Req, Res)) {
	chainer.use(get(route_path, callback))
}

// shortcuts
pub fn add_route_callback(method string,route_path string, callback fn (Req, Res) ?(Req, Res)) &Chain {
	mut new_chain := &Chain{}
	new_chain.middlewares << &Method{
		method: method
	}
	new_chain.middlewares << &Route{
		route: route_path
	}
	new_chain.middlewares << &Callback{
		callback: callback
	}
	return new_chain
}

// shortcuts
pub fn get(route_path string, callback fn (Req, Res) ?(Req, Res)) &Chain {
	return add_route_callback("GET", route_path, callback)
}

pub fn post(route_path string, callback fn (Req, Res) ?(Req, Res)) &Chain {
	return add_route_callback("POST", route_path, callback)
}

pub fn put(route_path string, callback fn (Req, Res) ?(Req, Res)) &Chain {
	return add_route_callback("PUT", route_path, callback)
}

pub fn patch(route_path string, callback fn (Req, Res) ?(Req, Res)) &Chain {
	return add_route_callback("PATCH", route_path, callback)
}

pub fn delete(route_path string, callback fn (Req, Res) ?(Req, Res)) &Chain {
	return add_route_callback("DELETE", route_path, callback)
}
