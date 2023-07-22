sudo apt install haxe
sudo apt install wget
wget https://github.com/sidgames5/escam/archive/refs/tags/0.4.1.zip
unzip 0.4.1.zip
cd escam-0.4.1/
haxelib install hxcpp
haxe build.hxml
cd bin/
sudo cp ./Main /usr/bin/escam