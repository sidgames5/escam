package commands.hosting;

import haxe.io.Bytes;
import hx_webserver.HTTPRequest;
import haxe.Json;
import structs.Permissions;
import structs.Repository;
import hx_webserver.HTTPServer;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class HostRepository implements Command {
	public function bind(args:Array<String>) {}

	public function new() {
		if (!FileSystem.exists("packages/") || !FileSystem.isDirectory("packages/")) {
			Sys.println("Error: package directory not found");
			return;
		}
		if (!FileSystem.exists("repository.json")) {
			Sys.println("Error: repository.json not found");
			return;
		}
		if (!FileSystem.exists("permissions.json")) {
			Sys.println("Error: permissions.json not found");
			return;
		}

		var repo:Repository = Json.parse(File.getContent("repository.json"));
		var perms:Permissions = Json.parse(File.getContent("permissions.json"));

		var server = new HTTPServer("0.0.0.0", 5454, true);
		server.onClientConnect = function(req:HTTPRequest) {
			var url = req.methods[1].substr(1);
			var turl = repo.url.split("/");
			turl.shift();
			turl.shift();
			turl.shift();
			if (!url.startsWith(turl[0])) {
				req.reply("Not found", 404);
				req.close();
				return;
			}

			if (url == "repository.json") {
				req.replyData(Json.stringify(repo), "application/json", 200);
				req.close();
				return;
			}

			if (url == "permissions.json") {
				req.replyData(Json.stringify(perms), "application/json", 200);
				req.close();
				return;
			}

			if (url.startsWith("packages")) {
				var surl = url.split("/");
				surl.shift();
				var pkgname = surl[0];
				if (pkgname == null) {
					req.reply("Not found", 404);
					req.close();
					return;
				}
				if (FileSystem.exists("packages/" + pkgname) && FileSystem.isDirectory("packages/" + pkgname)) {
					var file = surl[1];
					var versions:Array<String> = Json.parse(File.getContent("packages/" + pkgname + "/versions.json"));
					if (file.endsWith(".zip")) {
						var tver = file.substr(0, file.length - 4);
						if (versions.contains(tver)) {
							var zc = File.getContent("packages/" + pkgname + "/" + file);
							req.replyData(zc.toString(), "application/zip", 200);
						}
					}
				}
			}

			if (url.startsWith("upload")) {
				if (!perms.writes) {
					req.reply("Forbidden", 403);
					req.close();
					return;
				}
				var params = url.split("?")[1].split("&");
				var pkg = "";
				var version = "";
				for (param in params) {
					var k = param.split("=")[0];
					var v = param.split("=")[1];
					if (k == "package") {
						pkg = v;
					}
					if (k == "version") {
						version = v;
					}
				}
				if (pkg == "" || version == "") {
					req.reply("Package name and version not specified", 400);
					req.close();
					return;
				}
				if (!FileSystem.exists("packages/" + pkg)) {
					FileSystem.createDirectory("packages/" + pkg);
					File.saveContent("packages/" + pkg + "/versions.json", Json.stringify([]));
				}
				var vc:Array<String> = Json.parse(File.getContent("packages/" + pkg + "/versions.json"));
				if (vc.contains(version)) {
					req.reply("Package version already uploaded", 409);
					req.close();
					return;
				}
				var zd = Bytes.ofHex(req.postData);
				File.saveBytes("packages/" + pkg + "/" + version + ".zip", zd);
				vc.push(version);
				File.saveContent("packages/" + pkg + "/versions.json", Json.stringify(vc));
				repo.packages.push(pkg);
				File.saveContent("repository.json", Json.stringify(repo));
				req.reply("Uploaded", 200);
				req.close();
				return;
			}

			req.reply("Not found", 404);
			req.close();
			return;
		}
	}
}
