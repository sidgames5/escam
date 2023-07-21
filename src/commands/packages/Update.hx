package commands.packages;

import haxe.Json;
import haxe.io.Path;
import haxe.Http;
import repositories.RepoManager;

class Update implements Command {
	public function bind(args:Array<String>) {
		var summary = [];

		if (args.length > 1) {
			var packages = args;
			args.shift();

			for (pkgname in packages) {
				Sys.println("Checking " + pkgname + " for updates");
			}
		} else {
			Sys.println("Starting full system upgrade");

			var packages = Database.get().packages;
			if (packages.length == 0) {
				Sys.println("No packages have been installed through escam");
			}

			for (pkg in packages) {
				Sys.println("Checking " + pkg.name + " for updates");

				var currentver = pkg.version;
				var latestver = currentver;

				var vjurl = Path.join([RepoManager.findfirst(pkg.name).packagesURL, pkg.name, "versions.json"]);
				var h1 = new Http(vjurl);
				h1.onData = function(data:String) {
					var json = Json.parse(data);
					latestver = json[json.length - 1];
					if (currentver != latestver) {
						Sys.println("Removing " + pkg.name + " " + pkg.version);
						new Remove().bind([pkg.name]);
						new Install().bind([pkg.name]);
						summary.push("UPDATED " + pkg.name);
					} else {
						Sys.println(pkg.name + " is up to date");
					}
				}
				h1.onError = function(msg:String) {
					Sys.println("Error fetching versions: " + msg);
					summary.push("FAILED " + pkg.name);
				}
				h1.request();
			}
		}

		Sys.println("\nTransaction summary:");
		for (s in summary)
			Sys.println(s);
	}

	public function new() {}
}
