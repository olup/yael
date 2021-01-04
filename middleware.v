module via

interface Middleware {
	handle(req Req, res Res) ?(Req, Res)
}

type Callback = fn (req Req, res Res) ?(Req, Res)

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

// Execute Middleware
struct Execute {
	callback fn (Req, Res) ?(Req, Res)
}

pub fn (middleware Execute) handle(req Req, res Res) ?(Req, Res) {
	return middleware.callback(req, res)
}

pub fn execute(callback fn (Req, Res) ?(Req, Res)) Execute {
	return Execute{
		callback: callback
	}
}

// Chain Middleware
struct Chain {
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

// shortcuts
pub fn get(route_path string, callback fn (Req, Res) ?(Req, Res)) &Chain {
	mut new_chain := &Chain{}
	new_chain.middlewares << &Method{
		method: 'GET'
	}
	new_chain.middlewares << &Route{
		route: route_path
	}
	new_chain.middlewares << &Execute{
		callback: callback
	}
	return new_chain
}
