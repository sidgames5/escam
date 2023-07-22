sudo pacman -S haxe
sudo pacman -S wget
wget https://github.com/sidgames5/escam/archive/refs/tags/0.4.1.zip
unzip 0.4.1.zip
cd escam-0.4.1/
haxelib install hxcpp
haxe build.hxml
cd bin/
sudo cp ./Main /usr/bin/escam