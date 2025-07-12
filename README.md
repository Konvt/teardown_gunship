# Gunship Airstrike
A Teardown mod about an AC130 gunship.

Project page: https://github.com/Konvt/teardown_gunship

# Description
The original scripts are written by My Cresta.

The vox model and sound files come from two different workshop mods: [AC130 Airstrike][1] and [AC130 MORE Enhanced][2], which I do not own or claim authorship of them.

Based on the original script from [AC130 Airstrike][1], this mod introduces a [class library](https://github.com/Konvt/lurti) and completes a large-scale refactoring.

# Notice
Because the Lua interpreter of the Teardown engine has disabled the global variable `package` and the function `require`, the mod needs to be linked into a single Lua file according to the dependency relationship by using `linker.py` in the project root directory to run normally.

# LICENSE
This mod is licensed under the [MPL](./LICENSE).

[1]: https://steamcommunity.com/sharedfiles/filedetails/?id=2401575709
[2]: https://steamcommunity.com/sharedfiles/filedetails/?id=2915027055
