# 🔐 Intégration de l'Authentification Backend Spring Boot dans Flutter

## 📋 Table des matières
1. [Architecture globale](#architecture-globale)
2. [Fichiers créés et modifiés](#fichiers-créés-et-modifiés)
3. [Flux d'authentification](#flux-dauthentification)
4. [Liaison avec le backend](#liaison-avec-le-backend)
5. [Gestion des données locales](#gestion-des-données-locales)
6. [Configuration réseau](#configuration-réseau)

---

## 🏗️ Architecture globale

L'intégration suit une architecture en couches (Clean Architecture) :

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (Screens: Login, Register, OTP, CompleteProfile, PIN)      │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                   APPLICATION LAYER                          │
│              (AuthFlowController - State Management)         │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│         (AuthService Interface + UserProfile Model)         │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
┌───────▼────────┐           ┌────────▼────────┐
│  DATA LAYER    │           │   DATA LAYER    │
│ MockAuthService│           │ RealAuthService │
│  (Tests/Dev)   │           │ (Production)    │
└────────────────┘           └─────────┬───────┘
                                       │
                             ┌─────────▼─────────┐
                             │  Backend REST API │
                             │  Spring Boot      │
                             │  + Keycloak       │
                             └───────────────────┘
```

---

## 📁 Fichiers créés et modifiés

### 1. **Interface du service d'authentification**
**Fichier** : `lib/features/auth/domain/auth_service.dart`

**Rôle** : Définit le contrat que tous les services d'authentification doivent respecter.

```dart
abstract class AuthService {
  // Vérifie si un utilisateur existe
  Future<bool> checkUserExists({required String phoneNumber});
  
  // Envoie un OTP
  Future<void> sendOtp({required String phoneNumber});
  
  // Vérifie l'OTP
  Future<void> verifyOtp({required String phoneNumber, required String otp});
  
  // Complète le profil
  Future<void> completeProfile({required String phoneNumber, required UserProfile profile});
  
  // Gère le PIN
  Future<void> setPin({required String phoneNumber, required String pin});
  Future<void> verifyPin({required String phoneNumber, required String pin});
  
  // Getters
  UserProfile? get profile;
  String? get storedPhoneNumber;
  String? get authToken;
}
```

**Avantages** :
- Permet de changer facilement entre mock et vrai service
- Facilite les tests unitaires
- Respecte le principe d'inversion de dépendances (SOLID)

---

### 2. **Service d'authentification réel**
**Fichier** : `lib/features/auth/data/real_auth_service.dart`

**Rôle** : Implémente l'interface `AuthService` et communique avec le backend Spring Boot.

#### **Composants clés** :

##### a) **Configuration des URLs**
```dart
class RealAuthService implements AuthService {
  final String baseUrl;        // http://10.0.2.2:8080
  final String keycloakUrl;    // http://10.0.2.2:9080
  
  String? _lastPhoneNumber;
  UserProfile? _profile;
  int? _userId;
  String? _authToken;
}
```

##### b) **Vérification de l'existence de l'utilisateur**
```dart
Future<bool> checkUserExists({required String phoneNumber}) async {
  final checkUrl = '$baseUrl/api/users/getUserByPhone/$phoneNumber';
  final response = await http.get(Uri.parse(checkUrl));
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['success'] == true && data['data'] != null) {
      // Récupère le profil depuis le backend
      final userData = data['data'];
      
      // Vérifie si un profil local existe (priorité sur le backend)
      final prefs = await SharedPreferences.getInstance();
      final localFirstName = prefs.getString('user_firstName');
      
      if (localFirstName != null && localFirstName != 'Utilisateur') {
        // Garde le profil local
        return true;
      } else {
        // Utilise le profil du backend
        _profile = UserProfile(
          firstName: userData['prenom'],
          lastName: userData['nom'],
          nin: userData['nin'],
        );
        await _saveProfile();
        return true;
      }
    }
  }
  return false;
}
```

##### c) **Envoi de l'OTP (Inscription)**
```dart
Future<void> sendOtp({required String phoneNumber}) async {
  // 1. Vérifier si l'utilisateur existe déjà
  final checkUrl = '$baseUrl/api/users/getUserByPhone/$phoneNumber';
  final checkResponse = await http.get(Uri.parse(checkUrl));
  
  if (checkResponse.statusCode == 200) {
    final data = json.decode(checkResponse.body);
    if (data['success'] == true) {
      throw AuthFlowException('Ce numéro est déjà enregistré');
    }
  }
  
  // 2. Créer un nouvel utilisateur (avec données temporaires)
  final registerUrl = '$baseUrl/api/users/register/client';
  final response = await http.post(
    Uri.parse(registerUrl),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'telephone': phoneNumber,
      'nom': 'Mobile',           // Valeur temporaire
      'prenom': 'Utilisateur',   // Valeur temporaire
    }),
  );
  
  // L'OTP est généré et envoyé automatiquement par le backend
}
```

##### d) **Validation de l'OTP**
```dart
Future<void> verifyOtp({required String phoneNumber, required String otp}) async {
  final validateUrl = '$baseUrl/api/compte/validate-otp';
  final response = await http.post(
    Uri.parse(validateUrl),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'telephone': phoneNumber,
      'otpCode': otp,
    }),
  );
  
  if (response.statusCode == 200) {
    // Récupérer le userId pour la mise à jour du profil
    final userResponse = await http.get(
      Uri.parse('$baseUrl/api/users/getUserByPhone/$phoneNumber'),
    );
    
    if (userResponse.statusCode == 200) {
      final userData = json.decode(userResponse.body);
      _userId = userData['data']['id'];
    }
  }
}
```

##### e) **Complétion du profil**
```dart
Future<void> completeProfile({required String phoneNumber, required UserProfile profile}) async {
  // Tenter de mettre à jour le profil dans le backend
  final updateUrl = '$baseUrl/api/users/update/$_userId';
  final response = await http.put(
    Uri.parse(updateUrl),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'nom': profile.lastName,
      'prenom': profile.firstName,
      'nin': profile.nin,
      'telephone': phoneNumber,
    }),
  );
  
  if (response.statusCode == 200) {
    // Succès : profil mis à jour dans le backend
    _profile = profile;
    await _saveProfile();
  } else if (response.statusCode == 401) {
    // Erreur 401 : pas de token d'authentification
    // On sauvegarde quand même localement
    _profile = profile;
    await _saveProfile();
  }
}
```

##### f) **Persistance locale avec SharedPreferences**
```dart
Future<void> _saveProfile() async {
  final prefs = await SharedPreferences.getInstance();
  if (_profile != null) {
    await prefs.setString('user_firstName', _profile!.firstName);
    await prefs.setString('user_lastName', _profile!.lastName);
    await prefs.setString('user_nin', _profile!.nin);
    if (_lastPhoneNumber != null) {
      await prefs.setString('user_phone', _lastPhoneNumber!);
    }
  }
}

Future<void> _loadProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final firstName = prefs.getString('user_firstName');
  final lastName = prefs.getString('user_lastName');
  final nin = prefs.getString('user_nin');
  
  if (firstName != null && lastName != null) {
    _profile = UserProfile(
      firstName: firstName,
      lastName: lastName,
      nin: nin ?? '',
      birthDate: DateTime.now(),
    );
  }
}
```

---

### 3. **Contrôleur de flux d'authentification**
**Fichier** : `lib/features/auth/application/auth_flow_controller.dart`

**Rôle** : Gère l'état de l'authentification et coordonne les appels au service.

```dart
class AuthFlowController extends ChangeNotifier {
  final AuthService _authService;
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _phoneNumber;
  UserProfile? _profile;
  
  // Vérifie si un utilisateur existe
  Future<bool> checkUserExists(String phoneNumber) async {
    _setLoading(true);
    try {
      final exists = await _authService.checkUserExists(phoneNumber: phoneNumber);
      if (exists) {
        _phoneNumber = phoneNumber;
        _profile = _authService.profile;  // Récupère le profil
        notifyListeners();
      }
      return exists;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Demande un OTP
  Future<bool> requestOtp(String phoneNumber) async {
    _setLoading(true);
    try {
      await _authService.sendOtp(phoneNumber: phoneNumber);
      _phoneNumber = phoneNumber;
      return true;
    } on AuthFlowException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Autres méthodes : verifyOtp, completeProfile, setPin, verifyPin...
}
```

---

### 4. **Injection de dépendances**
**Fichier** : `lib/main.dart`

**Rôle** : Configure l'application pour utiliser le vrai service d'authentification.

```dart
class AppBootstrap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Injection du service d'authentification réel
        Provider<AuthService>(
          create: (_) => RealAuthService(
            // 10.0.2.2 est l'adresse spéciale pour l'émulateur Android
            // qui pointe vers localhost de la machine hôte
            baseUrl: 'http://10.0.2.2:8080',
            keycloakUrl: 'http://10.0.2.2:9080',
          ),
          // Pour utiliser le mock à la place :
          // create: (_) => MockAuthService(),
        ),
        
        // Injection du contrôleur
        ChangeNotifierProvider<AuthFlowController>(
          create: (context) => AuthFlowController(
            authService: context.read<AuthService>(),
          ),
        ),
      ],
      child: MaterialApp(
        // Configuration de l'application...
      ),
    );
  }
}
```

---

### 5. **Écrans de présentation**

#### a) **Écran d'inscription**
**Fichier** : `lib/features/auth/presentation/pages/register_screen.dart`

- Saisie du numéro de téléphone
- Appelle `authController.requestOtp(phone)`
- Redirige vers l'écran OTP

#### b) **Écran de vérification OTP**
**Fichier** : `lib/features/auth/presentation/pages/otp_verification_screen.dart`

- Saisie de l'OTP à 6 chiffres
- Appelle `authController.verifyOtp(otp)`
- Redirige vers l'écran de complétion du profil

#### c) **Écran de complétion du profil**
**Fichier** : `lib/features/auth/presentation/pages/complete_profile_screen.dart`

- Saisie du nom, prénom, NIN, date de naissance
- Appelle `authController.completeProfile(profile)`
- Redirige vers l'écran de définition du PIN

#### d) **Écran de connexion**
**Fichier** : `lib/features/auth/presentation/pages/login_screen.dart`

- Saisie du numéro de téléphone
- Appelle `authController.checkUserExists(phone)`
- Si l'utilisateur existe → redirige vers l'écran PIN
- Sinon → affiche un message d'erreur

---

## 🔄 Flux d'authentification

### **Flux d'inscription**

```
┌─────────────────┐
│  1. Inscription │
│  (Numéro tel)   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│ Backend: POST /api/users/register/client            │
│ Body: { telephone, nom: "Mobile", prenom: "Utilisateur" } │
│ → Crée l'utilisateur avec données temporaires       │
│ → Génère et envoie l'OTP par SMS                    │
└────────┬────────────────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│  2. Validation  │
│  OTP (6 chiffres)│
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│ Backend: POST /api/compte/validate-otp              │
│ Body: { telephone, otpCode }                        │
│ → Valide l'OTP                                      │
│ → Active le compte Keycloak                         │
└────────┬────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│ Backend: GET /api/users/getUserByPhone/{phone}      │
│ → Récupère le userId                                │
└────────┬────────────────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│  3. Complétion  │
│  du profil      │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│ Backend: PUT /api/users/update/{userId}             │
│ Body: { nom, prenom, nin, telephone }               │
│ → Met à jour le profil avec les vraies données     │
│ → Si erreur 401: sauvegarde locale uniquement      │
└────────┬────────────────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│  4. Définition  │
│  du PIN         │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│ SharedPreferences: Sauvegarde locale du profil      │
│ → user_firstName, user_lastName, user_nin, user_phone│
└────────┬────────────────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│  5. Dashboard   │
│  (Connecté)     │
└─────────────────┘
```

### **Flux de connexion**

```
┌─────────────────┐
│  1. Connexion   │
│  (Numéro tel)   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│ Backend: GET /api/users/getUserByPhone/{phone}      │
│ → Vérifie si l'utilisateur existe                  │
└────────┬────────────────────────────────────────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌─────┐   ┌─────────┐
│Existe│   │N'existe │
│      │   │pas      │
└──┬───┘   └────┬────┘
   │            │
   │            ▼
   │      ┌──────────────┐
   │      │Message erreur│
   │      └──────────────┘
   │
   ▼
┌─────────────────────────────────────────────────────┐
│ SharedPreferences: Vérifie si profil local existe   │
│ → Si oui: utilise le profil local                  │
│ → Sinon: utilise le profil du backend              │
└────────┬────────────────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│  2. Saisie PIN  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  3. Dashboard   │
│  (Connecté)     │
└─────────────────┘
```

---

## 🔗 Liaison avec le backend

### **Configuration réseau**

#### **Problème de l'émulateur Android**
L'émulateur Android ne peut pas accéder directement à `localhost` ou `192.168.x.x`. Il faut utiliser une adresse spéciale.

#### **Solution : 10.0.2.2**
```dart
RealAuthService(
  baseUrl: 'http://10.0.2.2:8080',      // Pointe vers localhost:8080 de la machine hôte
  keycloakUrl: 'http://10.0.2.2:9080',  // Pointe vers localhost:9080 de la machine hôte
)
```

**Correspondances** :
- `10.0.2.2:8080` → `localhost:8080` (Backend Spring Boot)
- `10.0.2.2:9080` → `localhost:9080` (Keycloak)

### **Endpoints utilisés**

| Endpoint | Méthode | Rôle | Corps de la requête |
|----------|---------|------|---------------------|
| `/api/users/getUserByPhone/{phone}` | GET | Vérifie si l'utilisateur existe | - |
| `/api/users/register/client` | POST | Crée un nouvel utilisateur | `{ telephone, nom, prenom }` |
| `/api/compte/validate-otp` | POST | Valide l'OTP | `{ telephone, otpCode }` |
| `/api/users/update/{userId}` | PUT | Met à jour le profil | `{ nom, prenom, nin, telephone }` |

### **Format des réponses**

Toutes les réponses suivent le même format :
```json
{
  "message": "Message descriptif",
  "success": true/false,
  "statusCode": 200,
  "data": { ... }
}
```

---

## 💾 Gestion des données locales

### **Pourquoi SharedPreferences ?**

Le backend crée l'utilisateur avec des données temporaires ("Utilisateur", "Mobile"). Pour afficher les vraies données de l'utilisateur dans l'application, on les sauvegarde localement.

### **Données sauvegardées**

```dart
SharedPreferences:
  - user_firstName: "Moussa"
  - user_lastName: "Diallo"
  - user_nin: "123456789"
  - user_phone: "+221773192372"
```

### **Stratégie de priorité**

1. **Au démarrage** : Charge le profil depuis SharedPreferences
2. **À la connexion** : 
   - Si profil local existe ET n'est pas "Utilisateur Mobile" → utilise le profil local
   - Sinon → utilise le profil du backend
3. **À l'inscription** : Sauvegarde le profil localement après complétion

---

## 🔧 Configuration requise

### **Dépendances Flutter**

```yaml
dependencies:
  http: ^1.1.0                    # Requêtes HTTP
  shared_preferences: ^2.2.2      # Stockage local
  provider: ^6.1.1                # Gestion d'état
```

### **Backend Spring Boot**

- Port : `8080`
- Keycloak : `9080`
- Base de données : PostgreSQL

### **Émulateur Android**

- Utiliser l'adresse `10.0.2.2` pour accéder à localhost
- Vérifier que le backend est démarré avant de lancer l'application

---

## 🎯 Points clés de l'intégration

### ✅ **Avantages**

1. **Architecture propre** : Séparation claire des responsabilités
2. **Testable** : Interface permet de basculer entre mock et vrai service
3. **Résilient** : Sauvegarde locale si le backend échoue
4. **Flexible** : Facile d'ajouter de nouveaux endpoints

### ⚠️ **Limitations actuelles**

1. **Authentification** : L'endpoint `/api/users/update/{userId}` nécessite un token Bearer (erreur 401)
   - **Solution actuelle** : Sauvegarde locale uniquement
   - **Solution future** : Récupérer le token Keycloak après validation OTP

2. **PIN** : Pas d'endpoint backend pour gérer le PIN
   - **Solution actuelle** : Stockage local uniquement
   - **Solution future** : Ajouter un endpoint `/api/users/setPin`

3. **Synchronisation** : Le profil local peut diverger du backend
   - **Solution actuelle** : Priorité au profil local
   - **Solution future** : Synchronisation bidirectionnelle

---

## 📝 Résumé

L'intégration connecte le frontend Flutter au backend Spring Boot via des appels REST API. Le flux d'inscription crée un utilisateur avec des données temporaires, valide l'OTP, puis met à jour le profil. Le flux de connexion vérifie l'existence de l'utilisateur et utilise un PIN pour l'authentification. Les données sont sauvegardées localement avec SharedPreferences pour garantir une expérience utilisateur fluide même en cas d'erreur backend.
