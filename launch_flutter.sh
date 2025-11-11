#!/bin/bash

echo "🚀 Lancement de l'environnement Flutter..."

# Ouvrir Android Studio avec le projet
echo "📱 Ouverture d'Android Studio..."
open -a "Android Studio" /Users/papidiaw/CascadeProjects/Frontend-Transactional-Engine &

# Attendre 3 secondes
sleep 3

# Lancer l'émulateur Pixel 3a
echo "📲 Lancement de l'émulateur Pixel 3a..."
/Users/papidiaw/flutter/bin/flutter emulators --launch Pixel_3a &

# Attendre que l'émulateur démarre (30 secondes) 
echo "⏳ Attente du démarrage de l'émulateur (30 secondes)..."
sleep 30

# Vérifier si l'émulateur est prêt
echo "🔍 Vérification de l'émulateur..."
/Users/papidiaw/flutter/bin/flutter devices

# Lancer l'application Flutter sur l'émulateur
echo "🎯 Lancement de l'application Flutter sur l'émulateur..."
cd /Users/papidiaw/CascadeProjects/Frontend-Transactional-Engine

# Attendre encore un peu pour s'assurer que l'émulateur est complètement prêt
sleep 5

# Lancer l'application Flutter (elle s'ouvrira automatiquement sur l'émulateur)
/Users/papidiaw/flutter/bin/flutter run -d emulator-5554

echo "✅ Application lancée avec succès sur l'émulateur!"
