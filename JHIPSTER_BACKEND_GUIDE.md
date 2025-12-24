# 🚀 Guide de Démarrage - Backend JHipster

## 📍 Localisation du Backend

```
/Users/papidiaw/transactional_engine_g4
```

## 🏗️ Architecture

Ce backend est un **microservice JHipster** qui nécessite :
- **JHipster Registry** (Service Discovery sur port 8761)
- **Keycloak** (Authentification OAuth2/OIDC)
- **Base de données** (PostgreSQL ou autre)

## 🔧 Prérequis

1. **Java 17+** installé
2. **Docker** installé (pour Keycloak et autres services)
3. **Maven** (inclus avec mvnw)

## 📋 Étapes de Démarrage

### 1️⃣ Démarrer Keycloak (Authentification)

```bash
cd /Users/papidiaw/transactional_engine_g4

# Démarrer Keycloak avec Docker
docker compose -f src/main/docker/keycloak.yml up
```

**Keycloak sera accessible sur** : http://localhost:9080

### 2️⃣ Démarrer JHipster Registry (Service Discovery)

Le backend nécessite le JHipster Registry sur le port 8761.

**Option A - Avec Docker** :
```bash
docker compose -f src/main/docker/jhipster-registry.yml up
```

**Option B - Télécharger et lancer** :
```bash
# Télécharger depuis https://github.com/jhipster/jhipster-registry/releases
# Puis lancer :
java -jar jhipster-registry-*.jar
```

**Registry sera accessible sur** : http://localhost:8761
- Username: `admin`
- Password: (voir dans application-dev.yml)

### 3️⃣ Vérifier les Services Docker

```bash
cd /Users/papidiaw/transactional_engine_g4

# Voir tous les services Docker disponibles
ls src/main/docker/

# Démarrer tous les services nécessaires
docker compose -f src/main/docker/app.yml up
```

### 4️⃣ Démarrer le Backend

```bash
cd /Users/papidiaw/transactional_engine_g4

# Donner les permissions d'exécution
chmod +x mvnw

# Démarrer en mode développement
./mvnw

# OU avec Maven directement
mvn spring-boot:run
```

## 🔍 Vérifier que tout fonctionne

### 1. JHipster Registry
```
http://localhost:8761
```
Tu devrais voir le microservice enregistré.

### 2. Backend API
```
http://localhost:8080/management/health
```
Devrait retourner le statut de santé.

### 3. Swagger/OpenAPI
```
http://localhost:8080/v3/api-docs
```

### 4. Keycloak
```
http://localhost:9080
```

## 📊 Ports Utilisés

| Service | Port | URL |
|---------|------|-----|
| Backend Microservice | 8080 | http://localhost:8080 |
| JHipster Registry | 8761 | http://localhost:8761 |
| Keycloak | 9080 | http://localhost:9080 |
| PostgreSQL | 5432 | localhost:5432 |

## 🐛 Dépannage

### Erreur: "Unable to connect to JHipster Registry"

**Solution** :
```bash
# Démarrer le Registry d'abord
docker compose -f src/main/docker/jhipster-registry.yml up -d

# Puis démarrer le backend
./mvnw
```

### Erreur: "Keycloak connection refused"

**Solution** :
```bash
# Démarrer Keycloak
docker compose -f src/main/docker/keycloak.yml up -d

# Attendre que Keycloak soit prêt (30-60 secondes)
# Puis redémarrer le backend
```

### Erreur: "Port 8080 already in use"

**Solution** :
```bash
# Arrêter l'autre backend
# Si c'est ECOM_MERCHANT_MS, arrête-le d'abord

# Ou changer le port dans application-dev.yml
```

### Voir les logs Docker

```bash
# Voir les logs de tous les containers
docker compose -f src/main/docker/keycloak.yml logs -f

# Voir les containers en cours
docker ps
```

## 🔐 Authentification

Ce backend utilise **OAuth2/OIDC avec Keycloak**.

### Utilisateurs par défaut (Keycloak)

- **Admin** : admin / admin
- **User** : user / user

### Obtenir un token

```bash
# Exemple avec curl (à adapter selon ta config Keycloak)
curl -X POST http://localhost:9080/realms/jhipster/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password" \
  -d "client_id=web_app"
```

## 📝 Configuration

### Fichiers de configuration importants

- `src/main/resources/config/application.yml` - Config principale
- `src/main/resources/config/application-dev.yml` - Config développement
- `src/main/docker/` - Configurations Docker

### Base de données

Vérifier dans `application-dev.yml` quelle base de données est utilisée :
- H2 (en mémoire)
- PostgreSQL
- MySQL

## 🧪 Tester le Backend

### 1. Health Check
```bash
curl http://localhost:8080/management/health
```

### 2. Info
```bash
curl http://localhost:8080/management/info
```

### 3. Metrics
```bash
curl http://localhost:8080/management/metrics
```

## 🔗 Intégration avec Flutter

Une fois le backend démarré :

1. **Identifier les endpoints API** disponibles
2. **Obtenir un token OAuth2** depuis Keycloak
3. **Configurer Flutter** pour utiliser ces endpoints
4. **Ajouter le token** dans les headers des requêtes

## 📚 Documentation

- JHipster : https://www.jhipster.tech
- Keycloak : https://www.keycloak.org/documentation
- Spring Boot : https://spring.io/projects/spring-boot

## 🚀 Commandes Rapides

```bash
# Tout démarrer (dans l'ordre)
cd /Users/papidiaw/transactional_engine_g4

# 1. Services Docker
docker compose -f src/main/docker/keycloak.yml up -d
docker compose -f src/main/docker/jhipster-registry.yml up -d

# 2. Attendre 30 secondes

# 3. Backend
./mvnw

# Tout arrêter
docker compose -f src/main/docker/keycloak.yml down
docker compose -f src/main/docker/jhipster-registry.yml down
```

## ✅ Checklist de Démarrage

- [ ] Docker est installé et lancé
- [ ] Keycloak démarré (port 9080)
- [ ] JHipster Registry démarré (port 8761)
- [ ] Base de données démarrée (si externe)
- [ ] Backend démarré (port 8080)
- [ ] Health check OK
- [ ] Registry montre le microservice enregistré

---

**Note** : Ce backend est plus complexe que le simple ECOM_MERCHANT_MS car c'est une architecture microservices complète avec service discovery et OAuth2.
