package commands.repositories;

import haxe.io.Path;
import cpp.Float32;
import cpp.Float64;
import repositories.RepoManager;
import structs.Repository;
import haxe.Json;
import sys.Http;

class AddRepository implements Command {
	public function bind(args:Array<String>) {
		var reponame = args[1];

		var http = new Http(Path.join([reponame, "repository.json"]));
		http.onError = function(msg:String) {
			Sys.println("Failed to add repository: " + msg);
			return;
		}
		http.onData = function(data:String) {
			Sys.println("Data received");
			var repo:Repository = Json.parse(data);
			Sys.println("Adding repository to RepoManager");
			RepoManager.add(reponame, repo);
		}
		Sys.println("Fetching " + Path.join([reponame, "repository.json"]));
		http.request();
	}

	public function new() {}
}
