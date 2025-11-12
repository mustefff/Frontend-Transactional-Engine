import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend_transactional_engine/core/routing/app_router.dart';
import 'package:frontend_transactional_engine/features/auth/application/auth_flow_controller.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;

  void _onNumberPressed(String number, {required bool isDisabled}) {
    if (isDisabled) {
      return;
    }

    setState(() {
      if (!_isConfirming) {
        if (_firstPin.length < 6) {
          _firstPin += number;
          if (_firstPin.length == 6) {
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted) {
                setState(() {
                  _isConfirming = true;
                });
              }
            });
          }
        }
      } else {
        if (_confirmPin.length < 6) {
          _confirmPin += number;
          if (_confirmPin.length == 6) {
            _verifyPins();
          }
        }
      }
    });
  }

  void _onDeletePressed({required bool isDisabled}) {
    if (isDisabled) {
      return;
    }

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

  Future<void> _verifyPins() async {
    if (_firstPin != _confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les codes ne correspondent pas. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _firstPin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
      return;
    }

    final authController = context.read<AuthFlowController>();
    final success = await authController.persistPin(_confirmPin);

    if (!mounted) return;

    if (success) {
      authController.resetFlow();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.login,
        (route) => false,
      );
    } else if (authController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage!),
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

  Widget _buildPinDots(String pin, {required bool isLoading}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLoading
                ? Colors.grey[300]
                : index < pin.length
                    ? const Color(0xFF0D47FF)
                    : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildKeyButton(
    String text, {
    bool isSpecial = false,
    required bool isDisabled,
  }) {
    return InkWell(
      onTap: isDisabled
          ? null
          : () {
              if (text == '←') {
                _onDeletePressed(isDisabled: isDisabled);
              } else {
                _onNumberPressed(text, isDisabled: isDisabled);
              }
            },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 88,
        height: 66,
        decoration: BoxDecoration(
          color: isSpecial ? const Color(0xFF0D47FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDisabled
                ? Colors.grey.shade200
                : const Color(0xFFE2E6F7),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: isSpecial ? Colors.white : const Color(0xFF0D47FF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
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
          Icons.wallet_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthFlowController>();
    final isLoading = authController.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFE9ECFF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 240,
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
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _BackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        _buildLogoPlaceholder(),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _isConfirming
                          ? 'Confirmez votre code'
                          : 'Définissez votre code',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isConfirming
                          ? 'Entrez à nouveau le code à 6 chiffres.'
                          : 'Choisissez un code secret à 6 chiffres facile à retenir.',
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
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                children: [
                  _buildPinDots(
                    _isConfirming ? _confirmPin : _firstPin,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: CircularProgressIndicator(),
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildKeyButton('1', isDisabled: isLoading),
                            _buildKeyButton('2', isDisabled: isLoading),
                            _buildKeyButton('3', isDisabled: isLoading),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildKeyButton('4', isDisabled: isLoading),
                            _buildKeyButton('5', isDisabled: isLoading),
                            _buildKeyButton('6', isDisabled: isLoading),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildKeyButton('7', isDisabled: isLoading),
                            _buildKeyButton('8', isDisabled: isLoading),
                            _buildKeyButton('9', isDisabled: isLoading),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 88, height: 66),
                            _buildKeyButton('0', isDisabled: isLoading),
                            _buildKeyButton('←', isSpecial: true, isDisabled: isLoading),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
    );
  }
}

