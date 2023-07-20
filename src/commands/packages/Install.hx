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
				var version = versions[versions.length - 1];
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

					var outfile = packagejson.outfile;

					if (preparescript != null) {
						Sys.println("Preparing build");
						Sys.command(preparescript);
					}
					if (buildscript != null) {
						Sys.println("Building package");
						Sys.command("cd /opt/escam/temp/" + zipname + " && " + buildscript);
					}
					Sys.println("Installing package");
					if (installscript != null) {
						Sys.command("cd /opt/escam/temp/" + zipname + " && " + installscript);
					} else {
						// handle stuff
						Sys.command("cd /opt/escam/temp/" + zipname + " && " + "cp " + outfile + " /usr/bin/" + pkgname);
					}
					if (postinstallscript != null) {
						Sys.println("Running post-install script");
						Sys.command(postinstallscript);
					}
					Sys.println("Installed " + pkgname + " " + version);
				}
				zipreq.onError = function(msg:String) {
					Sys.println("Error fetching zip: " + msg);
				}
				zipreq.request();
			}
			versionsreq.onError = function(msg:String) {
				Sys.println("Failed to fetch versions: " + msg);
			}
			versionsreq.request();
		}
	}

	public function new() {}
}
