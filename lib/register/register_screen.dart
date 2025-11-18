import 'package:flutter/material.dart';
import 'otp_verification_screen.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isPhoneValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Test de connexion au démarrage
    _testBackendConnection();
  }
  
  Future<void> _testBackendConnection() async {
    debugPrint('🔍 [FRONTEND] Test de connexion au backend au démarrage...');
    final isConnected = await ApiService.testConnection();
    debugPrint('🔍 [FRONTEND] Backend connecté: $isConnected');
    if (!isConnected) {
      debugPrint('⚠️ [FRONTEND] ATTENTION: Le backend ne répond pas !');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone(String value) {
    setState(() {
      _isPhoneValid = value.length >= 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header avec cercles violets et logo
              SizedBox(
                height: 400,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Grand cercle violet foncé (gauche)
                   
                    // Cercle moyen violet (centre-gauche)
                   
                    // Cercle violet clair (centre)
                    Positioned(
                      top: -200,
                      right: 1,
                      child: Container(
                        width: 600,
                        height: 600,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF9B6FFF),
                        ),
                      ),
                    ),
                    // Cercle bleu clair (droite)
                    Positioned(
                      top: -150,
                      right: 100,
                      child: Container(
                        width: 550,
                        height: 550,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFBBAFFF),
                        ),
                      ),
                    ),
                    // Contenu du header (logo et texte)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 80,
                      child: Column(
                        children: [
                          // Logo
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'M',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B3FE8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Texte BIENVENUE
                          Text(
                            'BIENVENUE',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
              
              // Formulaire d'inscription
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    // Titre S'inscrire
                    Text(
                      "S'inscrire",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    SizedBox(height: 40),
                    
                    // Champ Téléphone
                    Text(
                      'Téléphone',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: _validatePhone,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: '77 12345 67',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                        ),
                        suffixIcon: _isPhoneValid
                            ? Icon(
                                Icons.check,
                                color: Color(0xFF6B3FE8),
                              )
                            : null,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF6B3FE8),
                            width: 2,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF6B3FE8),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 60),
                    
                    // Bouton Sign up
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          debugPrint('═══════════════════════════════════════════════════════════');
                          debugPrint('🔵 [FRONTEND] Bouton "S\'inscrire" cliqué !');
                          debugPrint('🔵 [FRONTEND] Texte du champ téléphone: "${_phoneController.text}"');
                          debugPrint('🔵 [FRONTEND] Champ vide ? ${_phoneController.text.isEmpty}');
                          debugPrint('═══════════════════════════════════════════════════════════');
                          
                          if (_phoneController.text.isNotEmpty) {
                            debugPrint('🔵 [FRONTEND] Le champ n\'est pas vide, on continue...');
                            
                            setState(() {
                              _isLoading = true;
                            });
                            
                            // Utiliser la fonction de formatage centralisée du service API
                            String phone = ApiService.formatPhoneNumber(_phoneController.text);
                            
                            debugPrint('📱 [FRONTEND] Numéro original: "${_phoneController.text}"');
                            debugPrint('📱 [FRONTEND] Numéro formaté: $phone');
                            debugPrint('📱 [FRONTEND] Appel de ApiService.inscriptionEtape1...');
                            
                            // Appeler l'API étape 1 (la fonction formatera automatiquement le numéro)
                            final result = await ApiService.inscriptionEtape1(phone);
                            
                            debugPrint('📱 [FRONTEND] Résultat reçu de l\'API: $result');
                            
                            setState(() {
                              _isLoading = false;
                            });
                            
                            if (result['success'] == true) {
                              // Navigation vers l'écran OTP
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OtpVerificationScreen(
                                      phoneNumber: phone,
                                    ),
                                  ),
                                );
                              }
                            } else {
                              // Afficher l'erreur
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['error'] ?? 'Erreur lors de l\'envoi du code OTP'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6B3FE8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'S\'inscrire',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
