package commands.packages;

import haxe.Json;
import haxe.io.Path;
import haxe.Http;
import repositories.RepoManager;

class Install implements Command {
	public function bind(args:Array<String>) {
		var packages = args;
		args.shift();
		for (pkgname in packages) {
			Sys.println("Installing package: " + pkgname);
			var pkgrepo = RepoManager.findfirst(pkgname);
			if (pkgrepo == null) {
				Sys.println("Could not find package: " + pkgname);
				continue;
			}
			Sys.println("Fetching repository: " + pkgrepo.url);

			var versionsreq = new Http(Path.join([pkgrepo.packagesURL, pkgname + "/versions.json"]));
			versionsreq.onData = function(data:String) {
				Sys.println("Fetched versions");
				var versions = Json.parse(data);
				var version = versions[0];
				Sys.println("Installing " + pkgname + " " + version);
			}
			versionsreq.onError = function(msg:String) {
				Sys.println("Failed to fetch versions: " + msg);
			}
			versionsreq.request();
		}
	}

	public function new() {}
}
