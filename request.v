module yael

struct Req {
pub:
	ip        string
	path      string
	url       string
	method    string
	headers   map[string]string
	body      string
	query     string
	query_map map[string]string
	params    map[string]string
}
