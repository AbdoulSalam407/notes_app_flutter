# notes_app_flutter

Application Flutter de prise de notes avec authentification simple et stockage local.

- **Android / iOS / Desktop** : stockage via **SQLite** (`sqflite`)
- **Web (Edge/Chrome)** : stockage via **localStorage** (`shared_preferences`)

## Prérequis

- Flutter SDK installé et opérationnel
- Vérifier l'installation :

```bash
flutter --version
flutter doctor
```

## Installation

1. Installer les dépendances :

```bash
flutter pub get
```

2. (Windows) Si tu vois l'erreur `symlink support` lors du build des plugins :

- Activer **Developer Mode**
- Ouvrir les paramètres :

```powershell
start ms-settings:developers
```

## Lancement

### Android

1. Brancher un téléphone (débogage USB activé) ou démarrer un émulateur Android
2. Lancer l'application :

```bash
flutter run
```

### Web (Microsoft Edge)

```bash
flutter run -d edge
```

## Utilisation

### Connexion

Identifiants de démonstration :

- **Nom d'utilisateur** : `admin`
- **Mot de passe** : `1234`

Après connexion, tu arrives sur l'écran **To do list** (liste des notes).

### Notes (CRUD)

- **Ajouter** : saisir le texte dans le champ "Ajouter une note" puis cliquer sur `+`
- **Modifier** : bouton crayon sur une note
- **Supprimer** : bouton poubelle, avec confirmation

## Structure du projet

```text
lib/
├── main.dart
├── models/
│   └── note.dart
├── database/
│   └── database_helper.dart
├── screens/
│   ├── login_screen.dart
│   ├── notes_list_screen.dart
│   └── note_form_dialog.dart
└── widgets/
    └── note_item.dart
```
