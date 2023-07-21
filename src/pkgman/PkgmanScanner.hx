package pkgman;

import haxe.io.Path;
import sys.FileSystem;

class PkgmanScanner {
	public static function getLocalPackageManager():String {
		for (folder in ScanFolders.get()) {
			for (pkgman in PackageManager.get()) {
				Sys.println("Checking " + Path.join([folder, pkgman]));
				if (FileSystem.exists(Path.join([folder, pkgman]))) {
					return pkgman;
				}
			}
		}
		return null;
	}
}
