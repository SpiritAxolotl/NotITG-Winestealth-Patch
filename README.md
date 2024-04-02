# Winestealth
If you've ever run NotITG through wine, you've probably noticed that stealth renders differently. This bash script patches NotITG v4.3.0 to make stealth render as it's intended.

Winestealth in action (normal): <https://youtu.be/bXpeyOiDX_Y>  
Winestealth not in action (fixed): <https://youtu.be/p1l1lPyS0AI>
# Dependencies
For checksum validation, you'll need `sha256sum`. You can install it via homebrew with

```bash
brew install coreutils
```

If you don't want checksum, put `-n` in the command below.

# Usage
Open your terminal of choice and `cd` to wherever you downloaded the `patch.sh`. Run:

```bash
./patch.sh -i <your-path-to-the-nitg-v4.3.0-exe>
```

If the checksum passes, congrats! The patched file will be called `NotITG-v4.3.1.exe` by default and it should be in the same directory as the original exe.

If the checksum fails, make sure your filepath is correct.

If you're running this script on a different NotITG version, pass `-n` to disable the checksum. This script should still correctly patch all past versions of NotITG. The output exe will be changed to `NotITG.exe` ~~because I can't be bothered to update the version number for more than one build~~.

# Explanation
In Stepmania v2, a RageDisplay method called `SetTextureModeGlow` was implemented to achieve a white glowing effect on actors<sup>[\[1\]](https://github.com/Jousway/stepmania-old/blob/02016ae442156402ffb6541be0715d21292be6d8/stepmania/src/RageDisplay_OGL.cpp#L612)[\[2\]](https://github.com/openitg/openitg/blob/f2c129fe65c65e4a9b3a691ff35e7717b4e8de51/src/RageDisplay_OGL.cpp#L1401)</sup>. This method was later used for the `stealth` modifier<!--in Stepmania v4-->. In the method, the game checks if the player's GPU has [`EXT_texture_env_combine`](https://registry.khronos.org/OpenGL/extensions/EXT/EXT_texture_env_combine.txt), a new extension that not everyone in 2003 had. Nowadays, all modern GPUs have this, but because this extension is so old, wine doesn't even recognize it, and fails the check. Windows passes the check, which leaves wine users with the gross fallback rendering.

# Credits
- [HeySora](https://heysora.net) for explaining to me back in early 2023 why winestealth existed
- [Jousway](https://github.com/jousway) for fact-checking some of the [readme explanation](#explanation)
- [jj](https://github.com/schlizzawg) for general decompilation and assembly help, giving me the ghidra SavePatch.py script, and for writing the original bash script that I then modified
- My stubbornness
