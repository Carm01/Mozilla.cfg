# Mozilla.cfg
Mozilla configuration files.

This creates default setting in Mozilla Firefox, you can create your own settings if you know them. This way FireFox will be setup with the configuration settings upon launch. i.e enalbe all plugins, set homepage, etc...

Mozilla.cfg goes where the Firefox.exe lives i.e C:\Program Files\Mozilla Firefox THIS IS YOUR DEFAULT SETTINGS FOR ALL USERS

local-settings.js tells Firefox to use the cfg file  and is placed here: C:\Program Files\Mozilla Firefox\defaults\pref

override.ini skips the import bookmark wizzard and is placed "C:\Program Files\Mozilla Firefox\browser" in that folder. 

FirefoxDefaultx64--x.au3 is an AutoIT script that you can compile yourself that will download and install the latest version of Firefox 64 bit and install it after it removes any current versions. It will also set up the configuration files above. If you have a compiled script and you need to changed the cfg file, simply place the mozilla.cfg file in the same location as the exe and it will override the integrated settings.
