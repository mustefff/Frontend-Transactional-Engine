import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  bool _isPhoneValid = false;
  bool _isAmountValid = false;
  String _selectedContact = '';
  
  // Contacts favoris simulés
  final List<Map<String, String>> _favoriteContacts = [
    {'name': 'Aminata Diop', 'phone': '771234567', 'initial': 'A'},
    {'name': 'Moussa Sow', 'phone': '775551234', 'initial': 'M'},
    {'name': 'Fatou Kane', 'phone': '778889999', 'initial': 'F'},
    {'name': 'Ibrahima Fall', 'phone': '776667777', 'initial': 'I'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _validatePhone(String value) {
    setState(() {
      _isPhoneValid = value.replaceAll(RegExp(r'\s+'), '').length >= 8;
    });
  }

  void _validateAmount(String value) {
    setState(() {
      final amount = int.tryParse(value.replaceAll(RegExp(r'\s+'), ''));
      _isAmountValid = amount != null && amount > 0 && amount <= 350250;
    });
  }

  void _selectContact(String name, String phone) {
    setState(() {
      _selectedContact = name;
      _phoneController.text = _formatPhone(phone);
      _validatePhone(phone);
    });
  }

  String _formatPhone(String phone) {
    if (phone.isEmpty) return '';
    final buffer = StringBuffer();
    for (var i = 0; i < phone.length; i++) {
      buffer.write(phone[i]);
      if (i.isOdd && i != phone.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  void _showConfirmationDialog() {
    final phone = _phoneController.text.trim();
    final amount = _amountController.text.trim();
    final note = _noteController.text.trim();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Confirmer le transfert',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmRow('Destinataire', phone),
            const SizedBox(height: 12),
            _buildConfirmRow('Montant', '$amount CFA'),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildConfirmRow('Note', note),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFFFF9800),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Frais de transfert : 0 CFA',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F6F7C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(
                color: Color(0xFF8A8A9E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processTransfer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Confirmer',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8A8A9E),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }

  void _processTransfer() {
    // Simulation du transfert
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Fermer le loader
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Transfert réussi !',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Le transfert de ${_amountController.text} CFA a été effectué avec succès.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6F6F7C),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le dialog
                Navigator.pop(context); // Retourner au dashboard
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Terminer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _isPhoneValid && _isAmountValid;

    return Scaffold(
      backgroundColor: const Color(0xFFE9ECFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec gradient bleu
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47FF), Color(0xFF4C6DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.2,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1.2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.swap_horiz_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text(
                      'Transfert d\'argent',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Envoyez de l\'argent rapidement et en toute sécurité.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.78),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contacts favoris
                      const Text(
                        'Contacts favoris',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F3250),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _favoriteContacts.length,
                          itemBuilder: (context, index) {
                            final contact = _favoriteContacts[index];
                            final isSelected = _selectedContact == contact['name'];
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: InkWell(
                                onTap: () => _selectContact(
                                  contact['name']!,
                                  contact['phone']!,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF0D47FF),
                                                  Color(0xFF4C6DFF)
                                                ],
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : const Color(0xFFEAF0FF),
                                        borderRadius: BorderRadius.circular(18),
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          contact['initial']!,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF0D47FF),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      contact['name']!.split(' ')[0],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF6F6F7C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Formulaire de transfert
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, 18),
                              blurRadius: 36,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Numéro de téléphone
                            const Text(
                              'Numéro de téléphone',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2F3250),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              onChanged: _validatePhone,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: '77 123 45 67',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB0B3C6),
                                ),
                                prefixIcon: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: const Text(
                                    '+221',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0D47FF),
                                    ),
                                  ),
                                ),
                                suffixIcon: _isPhoneValid
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF4CAF50),
                                      )
                                    : null,
                                filled: true,
                                fillColor: const Color(0xFFF4F6FF),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF0D47FF),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Montant
                            const Text(
                              'Montant',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2F3250),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              onChanged: _validateAmount,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: '10 000',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB0B3C6),
                                ),
                                suffixIcon: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: const Text(
                                    'CFA',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0D47FF),
                                    ),
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF4F6FF),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF0D47FF),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Solde disponible
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 16,
                                  color: Color(0xFF8A8A9E),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Solde disponible : ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF8A8A9E),
                                  ),
                                ),
                                const Text(
                                  '350 250 CFA',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0D47FF),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Note (optionnel)
                            const Text(
                              'Note (optionnel)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2F3250),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _noteController,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ajouter une note...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB0B3C6),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF4F6FF),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF0D47FF),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Bouton Envoyer
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: canSubmit ? _showConfirmationDialog : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D47FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Envoyer',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
