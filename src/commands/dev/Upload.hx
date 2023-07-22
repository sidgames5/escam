package commands.dev;

import haxe.Http;
import sys.io.Process;
import repositories.RepoManager;
import sys.FileSystem;
import haxe.Json;
import haxe.io.Path;
import sys.io.File;
import structs.Package;

class Upload implements Command {
	public function bind(args:Array<String>) {
		var trepo = args[1];

		if (trepo == null) {
			Sys.println("Syntax: escam upload [repository name]");
			return;
		}

		var pjp = Path.join([Sys.getCwd(), "package.json"]);
		var pkg:Package;
		if (!FileSystem.exists(pjp)) {
			Sys.println("Error: package.json file not found");
			return;
		}
		pkg = Json.parse(File.getContent(pjp));

		var httpurl = "";
		var rawrepourl = "";
		for (repo in RepoManager.repolist()) {
			if (repo.name == trepo)
				rawrepourl = repo.url;
			httpurl = Path.join([repo.url, "/upload"]);
		}
		httpurl = Path.removeTrailingSlashes(httpurl);
		httpurl = httpurl + "?package=" + pkg.name + "&version" + pkg.version;

		Sys.println("Are you sure you want to upload " + pkg.name + " " + pkg.version + " to " + rawrepourl + "?");
		Sys.print("If so, please type 'Confirm Upload' (case sensitive) to upload: ");
		var input = Sys.stdin().readLine();
		if (input != "Confirm Upload") {
			Sys.println("Upload cancelled");
			return;
		}
		Sys.println("\nUploading " + pkg.name + " " + pkg.version + " to " + rawrepourl);

		Sys.command("cd \"" + Sys.getCwd() + "\" && zip -r " + pkg.version + ".zip ./");

		Sys.println("Collecting artifacts");
		var zipcontent = File.getBytes(Path.join([Sys.getCwd(), pkg.version + ".zip"]));

		Sys.println("Uploading artifacts to" + rawrepourl);
		var req = new Http(httpurl);
		req.setPostBytes(zipcontent);
		req.onData = function(data:String) {
			Sys.println("Uploaded package: " + pkg.name + " " + pkg.version);
		}
		req.onError = function(msg:String) {
			Sys.println("Error: " + msg);
		}
		req.request(true);
	}

	public function new() {}
}
