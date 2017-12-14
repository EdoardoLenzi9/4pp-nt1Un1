function extract_url(config) {
    if("url" in config) {
        url = config.url;
    } else {
        url = "mongodb://"
        if("username" in config && "password" in config) {
            url += config.username + ":" + config.password + "@";
        }
        if("address" in config) {
            url += config.address;
        } else {
            throw "Unable to get address from credentials file";
        }
        if("port" in config) {
            url += ":" + config.port;
        }

        if("database" in config) {
            url += "/" + config.database;
        }
    }

    return url;
}

module.exports.extract_url = extract_url;
