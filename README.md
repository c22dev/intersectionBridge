# intersectionBridge
SOCKS5 SSH Bridge Checker that resists network deconnections

[[EN](https://github.com/c22dev/intersectionBridge/) | [FR](https://github.com/c22dev/intersectionBridge/blob/main/README_FR.md)]

*dédicace à Seb!*

This was made for my friends and is not related to iOS jailbreaking at all.

If you are interested in using the alpha version, check the [dev branch](https://github.com/c22dev/intersectionBridge/tree/dev).
## Installation

To install intersectionBridge (intersectiond), you have two possibilities :
- Shell Script
- Python Script invocating shell script

None is better than the other, it just works the same.
The script should self install. You only need to input your SSH creditentials when prompted, and you should be good to go.
I recommend doing a reboot after first install.

### Shell Script

1. Download `installer.sh` in any directory you want.
2. Open a Terminal, then go to that directory using `cd`
3. Once you are there, run `chmod +x installer.sh && ./installer.sh`

### Python Script invocating shell script

Run the following code:
```python
import os
import urllib.request
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

def download_file(url, destination):
    try:
        urllib.request.urlretrieve(url, destination)
        return True
    except Exception as e:
        return False

def main():
    script_url = "https://raw.githubusercontent.com/c22dev/intersectionBridge/main/installer.sh"
    script_name = "installer.sh"
    if download_file(script_url, script_name):
        os.chmod(script_name, 0o755)
        os.system(f"./{script_name}")

if __name__ == "__main__":
    main()
```

## How does this works

This (`sshBridge.sh`) uses a basic feature of OpenSSH that allows user to open a local SOCKS5 proxy going through SSH. This can be easily replicated and isn't the most interesting thing.

The main script (`intersectiond`) wakes up, check and assist sshBridge. Here is what it does:
1. Check for updates and various stuff about creditentials
2. Launch sshBridge
3. Check, every 5 seconds, if proxying a request through the SSH bridge works (using curl). If not, we kill the process and run another instance of it.

The installer (`installer.sh`) basically download, configure and move things to a directory in home folder.

The updater (`updater.sh`) runs every 30mins.
## Common Issues & Error

- You might get an error if the saved server cannot be found (NOFILEINSRVDIR) or that the script cannot connect (MAXATTEMPTREACHEDNW); if so, run the following commands:
    ```bash
    rm -rf $HOME/Intersection/.storedServers
    rm -rf $HOME/Intersection/.storedUsernames
    ```
    and restart your mac. You will be asked for creditentials on login.
