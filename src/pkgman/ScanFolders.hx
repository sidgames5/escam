package pkgman;

class ScanFolders {
	public static function get():Array<String> {
		return ["/usr/local/bin", "/usr/bin", "/bin", "/usr/local/sbin", "/usr/sbin", "/bin"];
	}
}
