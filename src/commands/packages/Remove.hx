package commands.packages;

import haxe.io.Path;
import sys.io.File;
import haxe.Json;
import structs.Package;

using StringTools;

class Remove implements Command {
	public function bind(args:Array<String>) {
		var packages = args;
		args.shift();

		var summary = [];

		for (pkgname in packages) {
			Sys.println("Removing package: " + pkgname);

			for (pkg in Database.get().packages) {
				if (pkg.name == pkgname) {
					var zipname = pkg.name + "-" + pkg.version;
					var packagejson:Package = Json.parse(File.getContent(Path.join(["/opt/escam/temp/", zipname, "package.json"])));

					var uninstallscript = packagejson.scripts.uninstall;

					if (uninstallscript != null) {
						if (uninstallscript.startsWith("./")) {
							Sys.command("cd /opt/escam/temp/" + zipname + " && " + "chmod +x " + uninstallscript);
						}
						Sys.command("cd /opt/escam/temp/" + zipname + " && " + uninstallscript);
					} else {
						Sys.command("rm /usr/bin/" + pkg.name);
					}

					Sys.println("Removed " + pkgname);
					Sys.println("Updating database");
					var db = Database.get();
					var pkgs = [];
					db.packages.remove({name: pkg.name, version: pkg.version});
					for (pac in db.packages) {
						if (pac.name != pkg.name) {
							pkgs.push(pac);
						}
					}
					db.packages = pkgs;
					Database.save(db);
					summary.push("REMOVED " + pkgname);
					break;
				}
			}

			if (!summary.contains("REMOVED " + pkgname)) {
				Sys.println("Failed to remove package: " + pkgname);
				Sys.println("The package is not installed");
				summary.push("MISSING " + pkgname);
			}
		}

		Sys.println("\nTransaction summary:");
		for (s in summary)
			Sys.println(s);
	}

	public function new() {}
}
