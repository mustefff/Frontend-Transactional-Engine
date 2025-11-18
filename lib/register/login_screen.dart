import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'register_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Étape 1 : Téléphone
  final TextEditingController _phoneController = TextEditingController();
  bool _isPhoneValid = false;
  
  // Étape 2 : OTP et mot de passe
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isStep2 = false;
  bool _isLoading = false;
  String _phoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePhone(String value) {
    setState(() {
      _isPhoneValid = value.length >= 8;
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Formater le numéro de téléphone avec le préfixe +221 si nécessaire
        String phone = _phoneController.text.trim();
        print('📱 [LOGIN] Numéro saisi: $phone');
        
        // Si le numéro contient déjà +221, on le garde tel quel
        if (phone.contains('+221')) {
          // Extraire juste le numéro après +221
          phone = phone.replaceAll('+221', '').replaceAll(' ', '').replaceAll('-', '');
          phone = '+221$phone';
        } else if (!phone.startsWith('+')) {
          if (phone.startsWith('221')) {
            phone = '+$phone';
          } else if (phone.startsWith('0')) {
            phone = '+221${phone.substring(1)}';
          } else {
            // Enlever les espaces et tirets
            phone = phone.replaceAll(' ', '').replaceAll('-', '');
            phone = '+221$phone';
          }
        }
        
        print('📱 [LOGIN] Numéro formaté: $phone');
        
        // Appeler l'API pour envoyer le code OTP
        final result = await ApiService.connexionOtp(phone);
        
        setState(() {
          _isLoading = false;
        });
        
        if (result['success'] == true) {
          setState(() {
            _isStep2 = true;
            _phoneNumber = phone;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Code OTP envoyé avec succès ! Vérifiez vos messages.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          if (mounted) {
            // Afficher l'erreur dans un dialog pour plus de visibilité
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Erreur'),
                content: Text(result['error'] ?? 'Erreur lors de l\'envoi du code OTP'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['error'] ?? 'Erreur lors de l\'envoi du code OTP'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('❌ [LOGIN] Exception: ${e.toString()}');
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Erreur'),
              content: Text('Une erreur est survenue: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _login() async {
    String otp = _getOtpCode();
    String password = _passwordController.text;
    
    if (otp.length == 4 && password.length == 6) {
      setState(() {
        _isLoading = true;
      });
      
      // Appeler l'API de connexion
      final result = await ApiService.connexion(
        telephone: _phoneNumber,
        codeOtp: otp,
        password: password,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success'] == true) {
        // Connexion réussie
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connexion réussie !'),
              backgroundColor: Colors.green,
            ),
          );
          // TODO: Naviguer vers l'écran principal de l'application
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Erreur lors de la connexion'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez remplir tous les champs correctement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            
              
              // Formulaire de connexion
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    // Titre Connexion
                    Text(
                      "Connexion",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    SizedBox(height: 40),
                    
                    if (!_isStep2) ...[
                      // ÉTAPE 1 : Téléphone
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
                      // Bouton Envoyer OTP
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOtp,
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
                                      'Envoyer le code',
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
                    ] else ...[
                      // ÉTAPE 2 : OTP et Mot de passe
                      // Champ OTP
                      Text(
                        'Code OTP',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 60,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              onChanged: (value) => _onOtpChanged(index, value),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF7B5FFF),
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF7B5FFF),
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 40),
                      // Champ Mot de passe
                      Text(
                        'Mot de passe (6 chiffres)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 8,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '••••••',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            letterSpacing: 8,
                          ),
                          counterText: '',
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
                      // Bouton Se connecter
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
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
                                      'Se connecter',
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
                      SizedBox(height: 20),
                      // Bouton Retour
                      Center(
                        child: TextButton(
                          onPressed: _isLoading ? null : () {
                            setState(() {
                              _isStep2 = false;
                              _phoneNumber = '';
                              for (var controller in _otpControllers) {
                                controller.clear();
                              }
                              _passwordController.clear();
                            });
                          },
                          child: Text(
                            'Retour',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B3FE8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                    
                    SizedBox(height: 20),
                    
                    // Lien S'inscrire
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Vous n'avez pas de compte ?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 5),
                          TextButton(
                            onPressed: () {
                              // Navigation vers l'écran d'inscription
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B3FE8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
