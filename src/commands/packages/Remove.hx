package commands.packages;

class Remove implements Command {
	public function bind(args:Array<String>) {
		var packages = args;
		args.shift();

		var summary = [];

		for (pkgname in packages) {
			Sys.println("Removing package: " + pkgname);

			for (pkg in Database.get().packages) {
				if (pkg.name == pkgname) {
					if (Sys.command("rm /usr/bin/" + pkg.name) >= 0) {
						Sys.println("Failed to remove package: " + pkgname);
						summary.push("ERROR " + pkgname);
						return;
					}
					Sys.println("Removed " + pkgname);
					Sys.println("Updating database");
					var db = Database.get();
					db.packages.remove({name: pkg.name, version: pkg.version});
					Database.save(db);
					summary.push("REMOVED " + pkgname);
					return;
				}
			}

			Sys.println("Failed to remove package: " + pkgname);
			Sys.println("The package is not installed");
			summary.push("MISSING " + pkgname);
		}

		Sys.println("\nTransaction summary:");
		for (s in summary)
			Sys.println(s);
	}

	public function new() {}
}
