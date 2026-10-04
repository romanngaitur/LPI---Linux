# Security Policy

## Versions supportées

| Version | Support |
|---|---|
| `1.0.x` | ✅ Supportée |
| `< 1.0` | ❌ Non supportée |

Utilisez de préférence la dernière version disponible.

## Nature du projet

LPI for Linux est un outil d'administration système qui peut être exécuté avec les privilèges `root`.

Une vulnérabilité dans LPI peut donc avoir un impact important sur la machine qui l'exécute.

## Signaler une vulnérabilité

**Ne publiez pas une vulnérabilité de sécurité détaillée dans une issue publique.**

Pour un dépôt GitHub public, utilisez de préférence la fonctionnalité **Private vulnerability reporting / Security Advisories** de GitHub si elle est activée.

Si cette fonctionnalité n'est pas disponible, contactez le mainteneur avant toute divulgation publique.

Le rapport doit, si possible, contenir :

- une description du problème ;
- la version concernée ;
- les conditions nécessaires à l'exploitation ;
- les étapes permettant de reproduire le problème ;
- l'impact attendu ;
- une proposition de correction si vous en avez une.

## Exemples de problèmes de sécurité

Les problèmes suivants sont considérés comme importants :

- exécution de commandes arbitraires ;
- injection dans une commande shell ;
- contournement de la validation des paquets ;
- exécution de contenu depuis la configuration persistée ;
- élévation de privilèges inattendue ;
- contournement du mode `--dry-run` ;
- suppression ou écrasement de fichiers arbitraires ;
- modification non autorisée du pare-feu ;
- fuite d'informations sensibles.

## Bonnes pratiques pour les utilisateurs

Avant d'utiliser LPI :

1. lisez le README ;
2. sauvegardez les données importantes ;
3. testez dans une VM ;
4. utilisez `--dry-run` ;
5. vérifiez les changements UFW sur les serveurs distants ;
6. contrôlez les groupes ajoutés aux utilisateurs.

## Divulgation

Après correction, le mainteneur pourra publier les informations nécessaires dans le changelog ou les release notes.
