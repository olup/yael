# Yael server

Yael is a small - naive - implementation of a middleware based server in V - akin to express in node.js.

This is somewhat a proof of concept for now.

Yael is based off middlewares. Everything is a middleware, including routes.

Middlewares are executed one by one in the queue and pass on the request and the repsonse objects. The `chain` middleware can "branch out" a list of middlewares - this is usefull for a route, the sub list will execute in isolation to the main list of middleware.

Quick example :

```v
import yael

fn main() {
	mut app := yael.create_server()

	// A route. The server has a router (it's a Chain middleware itself). router.get is a helper function that
	// actually adds a Chain middleware with a Method middleware, a Route middleware and an Callback
	// middleware
	app.router.get('/hello/:name', fn (req yael.Req, res yael.Res) ?(yael.Req, yael.Res) {
		name := req.params['name']
		res.json('{"message" : "hello dear $name"}')
	})

	app.router.get('/healthcheck', fn (req yael.Req, res yael.Res) ?(yael.Req, yael.Res) {
		res.status(202).json('{"message" : "Ok"}')
	})

    // Catch-all 404 route : yael.callback is a general-puropose middleware that executes a callback
	app.router.use(yael.callback(fn (req yael.Req, res yael.Res) ?(yael.Req, yael.Res) {
		res.status(404).text('404 : cannot $req.method $req.path')
	}))

	app.listen(9900)
}

```
