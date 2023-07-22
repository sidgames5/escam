package commands.repositories;

import haxe.io.Path;
import haxe.Json;
import structs.Repository;
import haxe.Http;
import repositories.RepoManager;

class Sync implements Command {
	public function bind(args:Array<String>) {
		for (repo in Database.get().repositories) {
			Sys.print("░░░░░░░░░░░░░░░░░░░░ " + repo.name);

			if (RepoManager.isadded(repo.url)) {
				var db = Database.get();
				for (repoi in 0...db.repositories.length) {
					if (db.repositories[repoi].url == repo.url) {
						db.repositories.remove(db.repositories[repoi]);
						break;
					}
				}
				Database.save(db);
			}

			var reponame = repo.url;

			var http = new Http(Path.join([reponame, "repository.json"]));
			http.onError = function(msg:String) {
				Sys.println("Failed to add repository: " + msg);
				return;
			}
			http.onData = function(data:String) {
				var repo:Repository = Json.parse(data);

				if (!RepoManager.isadded(reponame)) {
					var db = Database.get();
					db.repositories.push(repo);
					Database.save(db);
				}
			}
			http.request();

			Sys.print("\r");
			for (i in 0...20) {
				Sys.print("█");
				Sys.sleep(Math.random() / 10);
			}
			Sys.print("\r\n");
		}
	}

	public function new() {}
}
