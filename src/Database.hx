package;

import haxe.Http;
import structs.Repository;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

class Database {
	public static final path = "/opt/escam/database.json";

	public static function init():Bool {
		var central:Repository;
		var req = new Http("https://sidgames5.github.io/escam/central/repository.json");
		var yes = false;
		req.onData = function(data:String) {
			var db:structs.Database = {
				repositories: [],
				packages: []
			};
			File.saveContent(path, Json.stringify(db));
			yes = true;
		}
		req.onError = function(msg:String) {
			Sys.println("Error fetching central repository: " + msg);
		}
		req.request();
		var time = 0;
		while (true) {
			if (time >= 5)
				return false;
			if (yes)
				return true;
			Sys.sleep(1);
			time++;
		}
		return false;
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
