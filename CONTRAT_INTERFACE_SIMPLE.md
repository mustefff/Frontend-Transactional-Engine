# Contrat d'Interface - Système de Paiement Mobile

**Équipe 4** | Version 2.0 | 23 Novembre 2025

---

## Table des Matières

1. [Architecture & Points d'Accès](#1-architecture--points-daccès)
2. [Modèle de Données](#2-modèle-de-données)
3. [MERCHANT-PAYMENT API](#3-merchant-payment-api)
4. [ECOM-SERVICE API](#4-ecom-service-api)
5. [TRX-ENGINE API](#5-trx-engine-api)
6. [Kafka Events](#6-kafka-events)
7. [Sécurité](#7-sécurité)

---

## 1. Architecture & Points d'Accès

### API Gateway (Point d'Entrée Unique)

**Base URL:** `http://localhost:8080`  
**Rôle:** Routage des requêtes vers les microservices

**Routes:**
- `/merchant/**` → MERCHANT-PAYMENT (8081)
- `/ecom/**` → ECOM-SERVICE (8082)
- `/transactions/**` → TRX-ENGINE (8083)

**Exemple:**
```bash
# Au lieu d'appeler directement http://localhost:8081/graphql
# On passe par le Gateway:
curl -X POST http://localhost:8080/merchant/graphql \
  -H "Authorization: Bearer TOKEN" \
  -d '{"query": "..."}'
```

### Service Registry (Eureka)

**URL:** `http://localhost:8761`  
**Rôle:** Découverte et enregistrement des microservices

**Services enregistrés:**
- `MERCHANT-PAYMENT-SERVICE` (8081)
- `ECOM-SERVICE` (8082)
- `TRX-ENGINE` (8083)

---

## 2. Modèle de Données

### User
```json
{
  "id": "int",
  "nom": "String",
  "prenom": "String",
  "telephone": "String",
  "password": "String",
  "nin": "Long"
}
```

### Marchand
```json
{
  "id": "int",
  "nomBoutique": "String",
  "logoBoutique": "String",
  "userId": "int"
}
```
**Relations:** 0..1 avec User

### CompteMarchand
```json
{
  "id": "int",
  "solde": "float",
  "numCompte": "Long",
  "codeMarchand": "int",
  "dateCreation": "date"
}
```
**Relations:** 1 CompteMarchand lié à 1 Marchand (0..1)

### Compte
```json
{
  "id": "int"
}
```
**Relations:** 1 Compte lié à 1 User (0..1)

### Transfert
```json
{
  "id": "int",
  "montantTransfert": "float",
  "dateTransfert": "date"
}
```
**Relations:** 0..* avec Details_Transaction

### Details_Transaction
```json
{
  "id": "int"
}
```
**Relations:** 
- Lié à 1 Transfert (0..*)
- Lié à 2 Comptes (débit et crédit)

---

## 3. MERCHANT-PAYMENT API

**Base URL:** `http://localhost:8081/graphql`  
**Protocole:** GraphQL  
**Auth:** JWT Bearer Token

### API 3.1 : Créer un Paiement Marchand

**Nom:** `createMerchantPayment`  
**Méthode:** POST  
**Type:** GraphQL Mutation

**Requête:**
```graphql
mutation {
  createMerchantPayment(input: {
    merchantId: "merchant-123"
    userId: "user-456"
    amount: 5000.0
    currency: "XOF"
  }) {
    id
    status
    reference
  }
}
```

**Réponse 200:**
```json
{
  "data": {
    "createMerchantPayment": {
      "id": "payment-789",
      "status": "PENDING",
      "reference": "MPY-20251123-789"
    }
  }
}
```

**Erreur 409 (Solde insuffisant):**
```json
{
  "errors": [{
    "code": "INSUFFICIENT_BALANCE",
    "message": "Solde insuffisant",
    "required": 5000.0,
    "available": 2000.0
  }]
}
```

**Statuts HTTP:**
- 200: Succès
- 400: Requête invalide
- 401: Non authentifié
- 409: Solde insuffisant
- 500: Erreur serveur

**Sécurité:** JWT Bearer Token (Keycloak)

**Exemple cURL:**
```bash
curl -X POST http://localhost:8081/graphql \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { createMerchantPayment(...) { id } }"}'
```

---

### API 3.2 : Lister les Paiements

**Nom:** `merchantPayments`  
**Méthode:** POST  
**Type:** GraphQL Query

**Requête:**
```graphql
query {
  merchantPayments(merchantId: "merchant-123", page: 1, limit: 20) {
    nodes {
      id
      amount
      status
      createdAt
    }
    totalCount
  }
}
```

**Réponse 200:**
```json
{
  "data": {
    "merchantPayments": {
      "nodes": [
        {
          "id": "payment-789",
          "amount": 5000.0,
          "status": "SUCCESS",
          "createdAt": "2025-11-23T14:40:00Z"
        }
      ],
      "totalCount": 45
    }
  }
}
```

---

### API 3.3 : Créer un Compte Marchand

**Nom:** `createMerchant`  
**Méthode:** POST  
**Type:** GraphQL Mutation

**Requête:**
```graphql
mutation {
  createMerchant(input: {
    name: "Boutique Dakar"
    email: "contact@boutique.sn"
    phone: "+221771234567"
  }) {
    id
    name
    qrCode
  }
}
```

**Réponse 200:**
```json
{
  "data": {
    "createMerchant": {
      "id": "merchant-123",
      "name": "Boutique Dakar",
      "qrCode": "MERCH-QR-123"
    }
  }
}
```

---

## 4. ECOM-SERVICE API (Paiement Marchand)

**Base URL:** `http://localhost:8082/graphql`  
**Protocole:** GraphQL  
**Auth:** JWT Bearer Token

**Use Cases:**
- Client : Payer marchand (le frontend décode le QR code et envoie merchantId + amount)
- Commercant : Consulter paiement / Rembourser paiement

### API 4.1 : Payer Marchand (Client)

**Nom:** `payerMarchand`  
**Méthode:** POST  
**Type:** GraphQL Mutation

**Requête:**
```graphql
mutation {
  payerMarchand(input: {
    userId: "user-456"
    merchantId: "merchant-123"
    amount: 5000.0
    currency: "XOF"
    paymentMethod: "QR_CODE"
  }) {
    id
    status
    reference
    createdAt
  }
}
```

**Réponse 200:**
```json
{
  "data": {
    "payerMarchand": {
      "id": "payment-789",
      "status": "SUCCESS",
      "reference": "PAY-20251123-789",
      "createdAt": "2025-11-23T14:40:00Z"
    }
  }
}
```

**Erreur 409 (Solde insuffisant):**
```json
{
  "errors": [{
    "code": "INSUFFICIENT_BALANCE",
    "message": "Solde insuffisant",
    "required": 5000.0,
    "available": 2000.0
  }]
}
```

**Statuts HTTP:**
- 200: Succès
- 400: Requête invalide
- 404: Marchand introuvable
- 409: Solde insuffisant
- 500: Erreur serveur

**Note:** L'erreur 401 est gérée par l'API Gateway, pas par ECOM-SERVICE

**Sécurité:** JWT Bearer Token + S'authentifier (include)

**Note:** Le frontend scanne le QR code et extrait `merchantId` et `amount`, puis appelle cette API.

---

### API 4.2 : Consulter Paiement (Commercant)

**Nom:** `consulterPaiement`  
**Méthode:** POST  
**Type:** GraphQL Query

**Requête:**
```graphql
query {
  consulterPaiement(merchantId: "merchant-123", page: 1, limit: 20) {
    nodes {
      id
      userId
      amount
      status
      createdAt
    }
    totalCount
  }
}
```

**Réponse 200:**
```json
{
  "data": {
    "consulterPaiement": {
      "nodes": [
        {
          "id": "payment-789",
          "userId": "user-456",
          "amount": 5000.0,
          "status": "SUCCESS",
          "createdAt": "2025-11-23T14:40:00Z"
        }
      ],
      "totalCount": 45
    }
  }
}
```

**Statuts HTTP:**
- 200: Succès
- 404: Paiement introuvable
- 500: Erreur serveur

**Note:** Les erreurs 401/403 sont gérées par l'API Gateway

**Sécurité:** JWT Bearer Token + S'authentifier (include)

---

### API 4.3 : Rembourser Paiement (Commercant)

**Nom:** `rembourserPaiement`  
**Méthode:** POST  
**Type:** GraphQL Mutation

**Requête:**
```graphql
mutation {
  rembourserPaiement(input: {
    paymentId: "payment-789"
    merchantId: "merchant-123"
    reason: "Produit défectueux"
  }) {
    id
    status
    refundAmount
    refundedAt
  }
}
```

**Réponse 200:**
```json
{
  "data": {
    "rembourserPaiement": {
      "id": "refund-456",
      "status": "REFUNDED",
      "refundAmount": 5000.0,
      "refundedAt": "2025-11-23T15:00:00Z"
    }
  }
}
```

**Erreur 409 (Paiement déjà remboursé):**
```json
{
  "errors": [{
    "code": "ALREADY_REFUNDED",
    "message": "Ce paiement a déjà été remboursé",
    "paymentId": "payment-789"
  }]
}
```

**Statuts HTTP:**
- 200: Succès
- 401: Non authentifié
- 403: Non autorisé
- 404: Paiement introuvable
- 409: Déjà remboursé

**Sécurité:** JWT Bearer Token + S'authentifier (include)

---

## 5. TRX-ENGINE API

**Base URL:** `http://localhost:8083/api`  
**Protocole:** REST  
**Auth:** JWT Bearer Token

### API 5.1 : Consulter le Solde

**URL:** `GET /api/users/{userId}/balance`  
**Méthode:** GET

**Headers:**
```http
Authorization: Bearer <JWT_TOKEN>
```

**Réponse 200:**
```json
{
  "userId": "user-456",
  "balance": 50000.0,
  "currency": "XOF"
}
```

**Statuts HTTP:**
- 200: Succès
- 404: Utilisateur introuvable
- 500: Erreur serveur

**Note:** Les erreurs 401 (Non authentifié) et 403 (Non autorisé) sont gérées par l'API Gateway avant d'atteindre TRX-ENGINE

**Exemple cURL:**
```bash
curl -X GET http://localhost:8083/api/users/user-456/balance \
  -H "Authorization: Bearer TOKEN"
```

---

### API 5.2 : Créer un Transfert P2P

**URL:** `POST /api/transfers`  
**Méthode:** POST

**Headers:**
```http
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Requête:**
```json
{
  "compteDebitId": "compte-456",
  "compteCreditId": "compte-789",
  "montantTransfert": 10000.0,
  "currency": "XOF"
}
```

**Réponse 201:**
```json
{
  "id": "transfert-123",
  "montantTransfert": 10000.0,
  "dateTransfert": "2025-11-23T14:40:00Z",
  "status": "SUCCESS"
}
```

**Erreur 409 (Solde insuffisant):**
```json
{
  "status": 409,
  "error": "Conflict",
  "message": "Solde insuffisant",
  "details": {
    "code": "INSUFFICIENT_BALANCE",
    "required": 10000.0,
    "available": 5000.0
  }
}
```

**Statuts HTTP:**
- 201: Créé avec succès
- 400: Requête invalide
- 409: Solde insuffisant
- 500: Erreur serveur

**Note:** L'erreur 401 est gérée par l'API Gateway

---

### API 5.3 : Historique des Transactions

**URL:** `GET /api/users/{userId}/transactions`  
**Méthode:** GET

**Query Parameters:**
- page: int (default: 0)
- size: int (default: 20)
- type: MERCHANT_PAYMENT | P2P_TRANSFER | ALL

**Réponse 200:**
```json
{
  "content": [
    {
      "id": "txn-456",
      "type": "MERCHANT_PAYMENT",
      "amount": 5000.0,
      "status": "SUCCESS",
      "createdAt": "2025-11-23T14:40:00Z"
    }
  ],
  "totalElements": 120,
  "totalPages": 6
}
```

---

## 6. Kafka Events

### Event 6.1 : merchant-payment-created

**Topic:** `merchant-payment-created`  
**Producer:** MERCHANT-PAYMENT  
**Consumer:** TRX-ENGINE

**Payload:**
```json
{
  "paymentId": "payment-789",
  "merchantId": "merchant-123",
  "userId": "user-456",
  "amount": 5000.0,
  "currency": "XOF",
  "timestamp": "2025-11-23T14:40:00Z"
}
```

**Action:** TRX-ENGINE traite le paiement et débite le compte utilisateur

---

### Event 6.2 : payment-ecom-created

**Topic:** `payment-ecom-created`  
**Producer:** ECOM-SERVICE  
**Consumer:** TRX-ENGINE

**Payload:**
```json
{
  "paymentId": "payment-456",
  "merchantId": "merchant-123",
  "userId": "user-456",
  "amount": 5000.0,
  "currency": "XOF",
  "paymentMethod": "QR_CODE",
  "timestamp": "2025-11-23T15:00:00Z"
}
```

**Action:** TRX-ENGINE traite le paiement marchand (débite client, crédite marchand)

---

### Event 6.3 : payment-ecom-completed

**Topic:** `payment-ecom-completed`  
**Producer:** TRX-ENGINE  
**Consumer:** ECOM-SERVICE

**Payload:**
```json
{
  "paymentId": "payment-456",
  "transactionId": "txn-789",
  "status": "SUCCESS",
  "timestamp": "2025-11-23T15:02:00Z"
}
```

**Action:** ECOM-SERVICE met à jour le statut du paiement (PENDING → SUCCESS)

---

### Event 6.4 : transaction-completed

**Topic:** `transaction-completed`  
**Producer:** TRX-ENGINE  
**Consumer:** HISTORY-SERVICE, NOTIFICATION-SERVICE

**Payload:**
```json
{
  "transactionId": "txn-456",
  "userId": "user-456",
  "merchantId": "merchant-123",
  "type": "MERCHANT_PAYMENT",
  "amount": 5000.0,
  "status": "SUCCESS",
  "timestamp": "2025-11-23T14:40:00Z"
}
```

**Actions:**
- **HISTORY-SERVICE** : Enregistre la transaction dans l'historique
- **NOTIFICATION-SERVICE** : Envoie une notification à l'utilisateur (SMS, Push)

---

### Event 6.5 : p2p-transfer-created

**Topic:** `p2p-transfer-created`  
**Producer:** TRX-ENGINE  
**Consumer:** HISTORY-SERVICE, NOTIFICATION-SERVICE

**Payload:**
```json
{
  "transfertId": "transfert-123",
  "compteDebitId": "compte-456",
  "compteCreditId": "compte-789",
  "montantTransfert": 10000.0,
  "dateTransfert": "2025-11-23T16:00:00Z",
  "status": "SUCCESS"
}
```

**Actions:**
- **HISTORY-SERVICE** : Enregistre le transfert P2P dans l'historique
- **NOTIFICATION-SERVICE** : Envoie une notification aux 2 utilisateurs (émetteur et récepteur)

---

### Event 6.6 : user-registered

**Topic:** `user-registered`  
**Producer:** AUTH-SERVICE  
**Consumer:** NOTIFICATION-SERVICE

**Payload:**
```json
{
  "userId": "user-456",
  "nom": "Diaw",
  "prenom": "Pape",
  "telephone": "+221771234567",
  "email": "pape@example.com",
  "timestamp": "2025-11-23T10:00:00Z"
}
```

**Action:** NOTIFICATION-SERVICE envoie un SMS/Email de bienvenue

---

### Event 6.7 : otp-generated

**Topic:** `otp-generated`  
**Producer:** AUTH-SERVICE  
**Consumer:** NOTIFICATION-SERVICE

**Payload:**
```json
{
  "userId": "user-456",
  "telephone": "+221771234567",
  "otpCode": "123456",
  "expiresAt": "2025-11-23T10:05:00Z",
  "purpose": "LOGIN"
}
```

**Action:** NOTIFICATION-SERVICE envoie le code OTP par SMS

**Purposes possibles:**
- `LOGIN` : Connexion
- `REGISTRATION` : Inscription
- `PASSWORD_RESET` : Réinitialisation mot de passe
- `TRANSACTION_CONFIRM` : Confirmation de transaction

---

### Event 6.8 : payment-failed

**Topic:** `payment-failed`  
**Producer:** TRX-ENGINE  
**Consumer:** ECOM-SERVICE, MERCHANT-PAYMENT, NOTIFICATION-SERVICE

**Payload:**
```json
{
  "paymentId": "payment-456",
  "userId": "user-456",
  "merchantId": "merchant-123",
  "amount": 5000.0,
  "reason": "INSUFFICIENT_BALANCE",
  "timestamp": "2025-11-23T14:40:00Z"
}
```

**Actions:**
- **ECOM-SERVICE / MERCHANT-PAYMENT** : Met à jour le statut du paiement (PENDING → FAILED)
- **NOTIFICATION-SERVICE** : Envoie une notification d'échec à l'utilisateur

---

## 7. Sécurité

### JWT Token

**Keycloak Configuration:**
```yaml
Host: localhost:9080
Realm: transactional-engine
Client ID: gateway-client
```

**Token Endpoint:**
```http
POST /realms/transactional-engine/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

grant_type=password
&username=+221771234567
&password=123456
&client_id=gateway-client
```

**Réponse:**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "token_type": "Bearer"
}
```

### Headers de Sécurité

```http
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

### Codes d'Erreur

| Code | Description |
|------|-------------|
| 200 | Succès |
| 201 | Créé |
| 400 | Requête invalide |
| 401 | Non authentifié |
| 403 | Non autorisé |
| 404 | Non trouvé |
| 409 | Conflit (solde insuffisant, rupture de stock) |
| 500 | Erreur serveur |

### Erreurs Métier

**INSUFFICIENT_BALANCE:** Solde insuffisant  
**OUT_OF_STOCK:** Produit en rupture de stock  
**INVALID_MERCHANT:** Marchand invalide  
**PAYMENT_FAILED:** Échec du paiement  
**USER_NOT_FOUND:** Utilisateur introuvable

---

## Résumé des Services

| Service | Port | Protocole | Base URL |
|---------|------|-----------|----------|
| API Gateway | 8080 | GraphQL/REST | http://localhost:8080 |
| MERCHANT-PAYMENT | 8081 | GraphQL | http://localhost:8081/graphql |
| ECOM-SERVICE | 8082 | GraphQL | http://localhost:8082/graphql |
| TRX-ENGINE | 8083 | REST | http://localhost:8083/api |
| Kafka | 9092 | Kafka | localhost:9092 |
| Redis | 6379 | Redis | localhost:6379 |
| Keycloak | 9080 | HTTP | http://localhost:9080 |

---

**Document maintenu par:** Équipe 4  
**Contact:** equipe4@payment-mobile.sn
