package commands.hosting;

import sys.io.File;
import haxe.Json;
import structs.Repository;
import structs.Permissions;
import haxe.io.Path;
import sys.FileSystem;

using StringTools;

class InitRepository implements Command {
	public function bind(args:Array<String>) {}

	public function new() {
		Sys.print("Are you sure you want to initialize a repository? [y/N] ");
		var confirm = Sys.stdin().readLine();
		if (confirm.toLowerCase() != "y")
			return;

		/* FILE STRUCTURE
			/packages/
			/permissions.json
			/repository.json
		 */

		FileSystem.createDirectory(Path.join([Sys.getCwd(), "packages"]));

		var permissions:Permissions = {
			writes: false,
		};
		var repository:Repository = {
			name: "",
			packages: [],
			packagesURL: "",
			url: "",
		};

		Sys.println("========== REPOSITORY SETTINGS ==========");
		Sys.print("Repository name: ");
		repository.name = Sys.stdin().readLine();

		Sys.print("Hostname or IP address of your repository: ");
		repository.url = Path.removeTrailingSlashes(Sys.stdin().readLine());
		if (!repository.url.startsWith("http")) {
			repository.url = "http://" + repository.url;
		}

		Sys.print("Packages URL (leave blank for default): ");
		repository.packagesURL = Sys.stdin().readLine();
		if (repository.packagesURL == "") {
			repository.packagesURL = Path.removeTrailingSlashes(Path.join([repository.url, "packages"]));
		}

		Sys.println("\n" + repository + "\n");
		File.saveContent(Path.join([Sys.getCwd(), "repository.json"]), Json.stringify(repository));

		Sys.println("============== PERMISSIONS ==============");
		Sys.print("Write access: [y/N] ");
		var i = Sys.stdin().readLine();
		if (i.toLowerCase() == "y")
			permissions.writes = true;
		else
			permissions.writes = false;

		Sys.println("\n" + permissions + "\n");
		File.saveContent(Path.join([Sys.getCwd(), "permissions.json"]), Json.stringify(permissions));
	}
}
