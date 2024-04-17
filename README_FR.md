# intersectionBridge
Vérificateur de pont SOCKS5 SSH résistant aux deconnxions résau

[[EN](https://github.com/c22dev/intersectionBridge/) | [FR](https://github.com/c22dev/intersectionBridge/README_FR.md)]

*dédicace à Seb!*

Ceci a été programmé pour mes amis et n'est pas lié au jailbreaking d'iOS

## Installation

Pour installer intersectionBridge (intersectiond), vous avez deux possibilités :
- Script Shell
- Script Python appelant le Script Shell

Aucun n'est mieux que l'autre, ils fonctionnent de la même manière.
Le script principal devrait s'installer par lui-même une fois l'installeur lancé. Vous devrez seulement entrer vos identifiants SSH lors de la première connexion, et vous devriez être bon.
Je vous recommende de redémarrer votre Mac après la configuration.

### Script Shell

1. Téléchargez `installer.sh` dans n'importe quel dossier.
2. Ouvrez un Terminal, et rendez vous dans ce dossier en utilisant `cd`
3. Une fois dans le dossier, lancez les commandes suivantes : `chmod +x installer.sh && ./installer.sh`

### Script Python qui appelant le Script Shell

Lancez le code suivant
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

## Comment cela fonctionne ?

Ceci (`sshBridge.sh`) utilise une fonctionnalitée basique d'OpenSSH qui permet à l'utilisateur d'ouvrir un proxy local SOCKS5 passant par la connexion SSH. Ceci peut être aisément répliqué et n'est pas la chose la plus intéressante.

Le script principal (`intersectiond`) réveille, vérifie and assiste sshBridge. Voici ce qu'il fait :
1. Verifier les MàJ et certains identifiants
2. Lancer sshBridge
3. Vérifier, toutes les 5 secondes, si envoyer une requête via le proxy en utilisant curl fonctionne. Si non, on termine l'ancien processus sshBridge et on en relance un nouveau.

L'installeur (`installer.sh`) télécharge, configure et déplace des fichiers dans un dossier contenu dans le dossier parent Home.

## Problèmes communs et erreurs

- Vous pourriez avoir une erreur come quoi le nom du serveur n'a pas pu être trouvé (NOFILEINSRVDIR) ou que le script ne peut pas se connecter (MAXATTEMPTREACHEDNW); si c'est le cas, lancez les commandes suivantes :
    ```bash
    rm -rf $HOME/Intersection/.storedServers
    rm -rf $HOME/Intersection/.storedUsernames
    ```
    et redémarrez votre ordinateur. Vous serrez demandé d'entrer vos identifiants lors de la connexion.
