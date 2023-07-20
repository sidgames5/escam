package repositories;

import structs.Package;
import structs.Repository;

class RepoManager {
	public static function add(url:String, repo:Repository) {
		if (!isadded(url)) {
			var db = Database.get();
			db.repositories.push(repo);
			Database.save(db);
			Sys.println("Added repository: " + url);
		} else {
			Sys.println("Repository already added");
			return;
		}
	}

	public static function remove(url:String) {
		if (isadded(url)) {
			var db = Database.get();
			for (repoi in 0...db.repositories.length) {
				if (db.repositories[repoi].url == url) {
					db.repositories.remove(db.repositories[repoi]);
					Sys.println("Removed repository: " + url);
					break;
				}
			}
			Database.save(db);
		} else {
			Sys.println("Repository has not been added");
			return;
		}
	}

	public static function isadded(url:String):Bool {
		var repos = Database.get().repositories;
		for (repo in repos) {
			if (repo.url == url) {
				return true;
			}
		}
		return false;
	}

	public static function repolist():Array<Repository> {
		return Database.get().repositories;
	}

	public static function findfirst(pkgname:String):Repository {
		var repos = repolist();
		for (repo in repos) {
			if (repo.packages.contains(pkgname)) {
				Sys.println("Package found in " + repo.url);
				return repo;
			}
		}
		return null;
	}
}
