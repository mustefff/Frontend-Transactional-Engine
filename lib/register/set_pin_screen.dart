import 'package:flutter/material.dart';
import 'login_screen.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (!_isConfirming) {
        if (_firstPin.length < 6) {
          _firstPin += number;
          if (_firstPin.length == 6) {
            // Passer à la confirmation après un court délai
            Future.delayed(Duration(milliseconds: 500), () {
              setState(() {
                _isConfirming = true;
              });
            });
          }
        }
      } else {
        if (_confirmPin.length < 6) {
          _confirmPin += number;
          if (_confirmPin.length == 6) {
            // Vérifier si les codes correspondent
            _verifyPins();
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (!_isConfirming) {
        if (_firstPin.isNotEmpty) {
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      }
    });
  }

  void _verifyPins() {
    if (_firstPin == _confirmPin) {
      // Les codes correspondent, naviguer vers la connexion
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      });
    } else {
      // Les codes ne correspondent pas, afficher une erreur et recommencer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les codes ne correspondent pas. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _firstPin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
    }
  }

  Widget _buildPinDots(String pin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < pin.length ? Color(0xFF6B3FE8) : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildKeyButton(String text, {bool isSpecial = false}) {
    return InkWell(
      onTap: () {
        if (text == '←') {
          _onDeletePressed();
        } else if (text == '✓') {
          // Bouton de validation (optionnel)
        } else {
          _onNumberPressed(text);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 100,
        height: 70,
        decoration: BoxDecoration(
          color: isSpecial ? Color(0xFF6B3FE8) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: isSpecial ? Colors.white : Color(0xFF6B3FE8),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 60),
            
            // Titre
            Text(
              _isConfirming ? 'Confirmer votre code' : 'Définir votre code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Sous-titre
            Text(
              _isConfirming 
                  ? 'Entrez à nouveau votre code' 
                  : 'Créez un code à 6 chiffres',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: 60),
            
            // Points pour le code
            _buildPinDots(_isConfirming ? _confirmPin : _firstPin),
            
            Spacer(),
            
            // Clavier numérique
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // Ligne 1-2-3
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKeyButton('1'),
                      _buildKeyButton('2'),
                      _buildKeyButton('3'),
                    ],
                  ),
                  SizedBox(height: 15),
                  
                  // Ligne 4-5-6
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKeyButton('4'),
                      _buildKeyButton('5'),
                      _buildKeyButton('6'),
                    ],
                  ),
                  SizedBox(height: 15),
                  
                  // Ligne 7-8-9
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKeyButton('7'),
                      _buildKeyButton('8'),
                      _buildKeyButton('9'),
                    ],
                  ),
                  SizedBox(height: 15),
                  
                  // Ligne . - 0 - Flèche
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(width: 100, height: 70), // Espace vide
                      _buildKeyButton('0'),
                      _buildKeyButton('←', isSpecial: true),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
