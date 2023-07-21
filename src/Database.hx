package;

import sys.thread.Thread;
import haxe.Http;
import structs.Repository;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

class Database {
	public static final path = "/opt/escam/database.json";

	public static function init() {
		Sys.println("Initializing database");
		var db:structs.Database = {
			repositories: [
				{url: "https://sidgames5.github.io/escam/central", packages: [], packagesURL: ""}
			],
			packages: []
		};
		FileSystem.createDirectory("/opt/escam/");
		File.saveContent(path, Json.stringify(db));
	}

	public static function get():structs.Database {
		if (!FileSystem.exists(path)) {
			init();
		}
		return Json.parse(File.getContent(path));
	}

	public static function save(data:structs.Database) {
		File.saveContent(path, Json.stringify(data));
	}
}
