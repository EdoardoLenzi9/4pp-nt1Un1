const config = require("../../support/config")
const fetch = require("node-fetch")

it("testing import on default config", done => {
	window.jasmine.DEFAULT_TIMEOUT_INTERVAL = 100000;
	expect(
		fetch(
			config.baseURL+"trento/import",
			{
				method: 'PUT'
			}
		).
		then(function(res) {
			done();
			return res;
		})
	).
	resolves.
	toHaveProperty('status', 200)
});

it("testing import with custom config", done => {
	window.jasmine.DEFAULT_TIMEOUT_INTERVAL = 100000;
	expect(
		fetch(
			config.baseURL+"trento/import",
			{
				method: 'PUT',
				headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify({
					mongoUrl: config.mongoUrl,
					"agencies": [
							{
								"agency_key": "trentino_trasporti",
								"path": "tests/support/gtfs"
							}
						]
					})
			}
		).
		then(function(res) {
			done();
			return res;
		})
	).
	resolves.
	toHaveProperty('status', 200)
});
