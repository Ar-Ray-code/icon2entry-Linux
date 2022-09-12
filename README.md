# icon2entry-Linux
Entry point generator for bash that provides a Desktop app-like experience

![](image_readme/description.png)

<br>

## Install your bash-file

```bash
# git clone https://github.com/Ar-Ray-code/icon2entry-Linux.git
sudo bash icon2entry_linux.bash --entry_bash ./entrypoint.bash -t
```

### Option

- `--entry_bash (-e) <.bash file>` : Entry point .bash file (Required).
  - will be installed with bash file directory recursively.
- `--icon (-i) <icon file>` : Icon path
  - If you don't add this option, installer script will download [this picture (irasutoya)](https://1.bp.blogspot.com/-z-Fj7jStrFA/X9w89_xgmhI/AAAAAAABc_8/AuabFNLnpLQsrsnptghJHI2NwRANjsR1gCNcBGAsYHQ/s593/document_paper_mekure.png).
- `--terminal (-t)` : Open terminal flag (store_true)
- `--uninstall (-u)` : Uninstall mode (store_true)
- `--bin_path (-b)` : install binary path
    - default : `/usr/local/bin/`)
- `--install_path (-p)` : install application path
    - default : `~/.app` (create automatically)

After running command, you can find desktop entrypoint named `entrypoint`.

![](image_readme/desktop_shortcut.png)

You can click this to run `entrypoint.bash`.

`entrypoint.bash` is only showing `"hello world"` string.

When you run `entrypoint.bash`, showing only the string `"hello world"`. (5 sec elapsed, this terminal window will be closed.)

![](image_readme/hello_world.png)
