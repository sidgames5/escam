package commands.packages;

import structs.Package;
import sys.io.Process;
import sys.thread.Thread;
import sys.FileSystem;
import haxe.io.Bytes;
import sys.io.File;
import haxe.Json;
import haxe.io.Path;
import haxe.Http;
import repositories.RepoManager;

using StringTools;

class Install implements Command {
	public function bind(args:Array<String>) {
		var packages = args;
		args.shift();

		var summary = [];

		for (pkgname in packages) {
			Sys.println("Installing package: " + pkgname);
			var pkgrepo = RepoManager.findfirst(pkgname);
			if (pkgrepo == null) {
				Sys.println("Could not find package: " + pkgname);
				Sys.print("Would you like to install this package from pacman? [y/N] ");
				var a = Sys.stdin().readLine();
				if (a.toLowerCase() == "y") {
					if (Sys.command("pacman -S " + pkgname) > 0) {
						summary.push("ERROR " + pkgname);
					} else {
						summary.push("EXTERNAL " + pkgname);
						Sys.println("Updating database");
						var db = Database.get();
						db.packages.push({name: pkgname, version: null});
						Database.save(db);
						continue;
					}
				} else {
					summary.push("MISSING " + pkgname);
					continue;
				}
			}
			Sys.println("Fetching repository: " + pkgrepo.url);

			var versionsreq = new Http(Path.join([pkgrepo.packagesURL, pkgname + "/versions.json"]));
			versionsreq.onData = function(data:String) {
				Sys.println("Fetched versions");
				var versions = Json.parse(data);
				var version = versions[versions.length - 1];
				if (Database.get().packages.contains({name: pkgname, version: version})) {
					Sys.println("Skipping " + pkgname + " - already installed");
					summary.push("SKIPPED " + pkgname);
				} else {
					Sys.println("Installing " + pkgname + " " + version);
					var zipname = pkgname + "-" + version;
					var zipreq = new Http(Path.join([pkgrepo.packagesURL, pkgname, version + ".zip"]));
					zipreq.onData = function(data) {
						Sys.println("Fetching zip");
						FileSystem.createDirectory("/opt/escam/temp/");
						// File.saveContent("/opt/escam/temp/" + pkgname + ".zip", data);
						Sys.command("curl -o /opt/escam/temp/" + zipname + ".zip " + Path.join([pkgrepo.packagesURL, pkgname, version + ".zip"]));
						Sys.command("cd /opt/escam/temp/ && unzip /opt/escam/temp/" + zipname + ".zip -d /opt/escam/temp/" + zipname);

						var packagejson:Package = Json.parse(File.getContent(Path.join(["/opt/escam/temp/", zipname, "package.json"])));

						var preparescript = packagejson.scripts.prepare;
						var buildscript = packagejson.scripts.build;
						var installscript = packagejson.scripts.install;
						var postinstallscript = packagejson.scripts.postinstall;

						Sys.setCwd(Path.join(["/opt/escam/temp/", zipname]));

						for (dep in packagejson.dependencies) {
							if (Database.get().packages.contains({name: dep.name, version: dep.version})) {
								Sys.println("Skipping dependency " + dep.name + " - already installed");
								summary.push("SKIPPED " + pkgname);
							} else {
								packages.push(dep.name);
							}
						}

						var outfile = packagejson.outfile;

						if (preparescript != null) {
							Sys.println("Preparing build");
							if (preparescript.startsWith("./")) {
								Sys.command("cd /opt/escam/temp/" + zipname + " && " + "chmod +x " + preparescript);
							}
							if (Sys.command("cd /opt/escam/temp/" + zipname + " && " + preparescript) > 0) {
								Sys.println("Error: failed to run prepare script");
								summary.push("FAILED " + pkgname);
								return;
							}
						}
						if (buildscript != null) {
							Sys.println("Building package");
							if (buildscript.startsWith("./")) {
								Sys.command("cd /opt/escam/temp/" + zipname + " && " + "chmod +x " + buildscript);
							}
							if (Sys.command("cd /opt/escam/temp/" + zipname + " && " + buildscript) > 0) {
								Sys.println("Error: failed to run build script");
								summary.push("FAILED " + pkgname);
								return;
							}
						}
						Sys.println("Installing package");
						if (installscript != null) {
							if (installscript.startsWith("./")) {
								Sys.command("cd /opt/escam/temp/" + zipname + " && " + "chmod +x " + installscript);
							}
							if (Sys.command("cd /opt/escam/temp/" + zipname + " && " + installscript) > 0) {
								Sys.println("Error: failed to run install script");
								summary.push("FAILED " + pkgname);
								return;
							}
						} else {
							if (Sys.command("cd /opt/escam/temp/" + zipname + " && " + "cp " + outfile + " /usr/bin/" + pkgname) > 0) {
								Sys.println("Error: failed to run install script");
								summary.push("FAILED " + pkgname);
								return;
							}
						}
						if (postinstallscript != null) {
							Sys.println("Running post-install script");
							if (postinstallscript.startsWith("./")) {
								Sys.command("cd /opt/escam/temp/" + zipname + " && " + "chmod +x " + postinstallscript);
							}
							if (Sys.command(postinstallscript) > 0) {
								Sys.println("Error: failed to run post-install script");
								summary.push("FAILED " + pkgname);
								return;
							}
						}
						Sys.println("Updating database");
						var db = Database.get();
						db.packages.push({name: pkgname, version: version});
						Database.save(db);
						Sys.println("Installed " + pkgname + " " + version);
						summary.push("INSTALLED  " + pkgname);
					}
					zipreq.onError = function(msg:String) {
						Sys.println("Error fetching zip: " + msg);
						summary.push("ERROR " + pkgname);
					}
					zipreq.request();
				}
			}
			versionsreq.onError = function(msg:String) {
				Sys.println("Failed to fetch versions: " + msg);
				summary.push("ERROR " + pkgname);
			}
			versionsreq.request();
		}

		Sys.println("\nTransaction summary:");
		for (s in summary)
			Sys.println(s);
	}

	public function new() {}
}
