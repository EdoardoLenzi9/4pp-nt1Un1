const config = require("../../support/config")
const fetch = require("node-fetch")

beforeAll(function() {
	window.jasmine.DEFAULT_TIMEOUT_INTERVAL = 100000;

    //import gtfs file
	return fetch(
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
		console.log("import successful");
		return res;
	});
});

it("testing import on default config", done => {
	expect(
		fetch(
			config.baseURL+"trento/routes",
			{
				method: 'GET'
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
