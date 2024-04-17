# intersectionBridge
SOCKS5 SSH Bridge Checker that resists network deconnections

*dédicace à Seb!*

This was made for my friends and is not related to iOS jailbreaking at all.

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
