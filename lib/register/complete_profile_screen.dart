import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'set_pin_screen.dart';
import '../services/api_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String phoneNumber;
  
  const CompleteProfileScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _ninController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _ninController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Format pour l'affichage : DD-MM-YYYY
        _dateNaissanceController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }
  
  // Convertir la date du format DD-MM-YYYY vers YYYY-MM-DD pour l'API
  String _formatDateForApi(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7B5FFF),
              Color(0xFF9B7FFF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  
                  // Bouton retour
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Zone de titre (remplace la photo)
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'Complément\nd\'inscription',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7B5FFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 50),
                  
                  // Champ Nom
                  Text(
                    'Nom',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _nomController,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Votre nom',
                      hintStyle: TextStyle(
                        color: Colors.white60,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white70,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Champ Prénom
                  Text(
                    'Prénom',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _prenomController,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Votre prénom',
                      hintStyle: TextStyle(
                        color: Colors.white60,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white70,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Champ NIN
                  Text(
                    'NIN',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _ninController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Votre NIN',
                      hintStyle: TextStyle(
                        color: Colors.white60,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white70,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Champ Date de Naissance
                  Text(
                    'Date de Naissance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _dateNaissanceController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Votre date de naissance (jj-mm-aaaa)',
                      hintStyle: TextStyle(
                        color: Colors.white60,
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 16,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white70,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 80),
                  
                  // Bouton Terminer
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        // Vérifier que tous les champs sont remplis
                        if (_nomController.text.isNotEmpty &&
                            _prenomController.text.isNotEmpty &&
                            _ninController.text.isNotEmpty &&
                            _dateNaissanceController.text.isNotEmpty) {
                          setState(() {
                            _isLoading = true;
                          });
                          
                          // Convertir la date au format YYYY-MM-DD
                          final dateNaissance = _formatDateForApi(_dateNaissanceController.text);
                          
                          // Appeler l'API étape 2
                          final result = await ApiService.inscriptionEtape2(
                            telephone: widget.phoneNumber,
                            nom: _nomController.text.trim(),
                            prenom: _prenomController.text.trim(),
                            nin: _ninController.text.trim(),
                            dateNaissance: dateNaissance,
                          );
                          
                          setState(() {
                            _isLoading = false;
                          });
                          
                          if (result['success'] == true) {
                            // Navigation vers l'écran de définition du code
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SetPinScreen(
                                    phoneNumber: widget.phoneNumber,
                                  ),
                                ),
                              );
                            }
                          } else {
                            // Afficher l'erreur
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['error'] ?? 'Erreur lors de l\'enregistrement'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          // Afficher un message d'erreur
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Veuillez remplir tous les champs'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
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
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B5FFF)),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Terminer',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7B5FFF),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.check,
                                  color: Color(0xFF7B5FFF),
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
      ),
    );
  }
}
