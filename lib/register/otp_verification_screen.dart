import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'complete_profile_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                SizedBox(height: 40),
                
                // Illustration du téléphone avec checkmark
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cercles en arrière-plan
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    // Main avec téléphone
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Téléphone bleu
                          Container(
                            width: 100,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Color(0xFF4169E1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                // Encoche du téléphone
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF5179F1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Icône de validation
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF4CAF50),
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                          // Main (partie inférieure)
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 80,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFFD4A574),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          // Doigts de la main
                          Positioned(
                            left: 40,
                            top: 30,
                            child: Container(
                              width: 25,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Color(0xFFD4A574),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 40,
                            top: 40,
                            child: Container(
                              width: 25,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Color(0xFFD4A574),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 40),
                
                // Titre
                Text(
                  'Vérification OTP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Sous-titre avec numéro de téléphone
                Text(
                  'Entrez le code OTP envoyé au ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
                
                SizedBox(height: 50),
                
                // Champs OTP
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
                
                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous n'avez pas reçu le code OTP ?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 5),
                    TextButton(
                      onPressed: () {
                        // Action pour renvoyer l'OTP
                        print('Renvoyer OTP');
                      },
                      child: Text(
                        'Renvoyer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7B5FFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 60),
                
                // Bouton Verify
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      String otp = _getOtpCode();
                      // Vérifier si l'OTP est complet
                      if (otp.length == 4) {
                        // Navigation vers complément d'inscription
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompleteProfileScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Veuillez entrer le code OTP complet'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7B5FFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Vérifier',
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
        ),
      ),
    );
  }
}
