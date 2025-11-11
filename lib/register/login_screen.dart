import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isCodeValid = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _validateCode(String value) {
    setState(() {
      _isCodeValid = value.length == 6;
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
                    
                    // Champ Code à 6 chiffres
                    Text(
                      'Code',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onChanged: _validateCode,
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
                        suffixIcon: _isCodeValid
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
                    
                    // Bouton Se connecter
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          // Action du bouton (backend Laravel à venir)
                          print('Code: ${_codeController.text}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6B3FE8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
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
                    
                    // Lien Code oublié
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Action pour code oublié
                          print('Code oublié');
                        },
                        child: Text(
                          'Code oublié ?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B3FE8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 10),
                    
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
