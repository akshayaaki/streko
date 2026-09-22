import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../theme.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _auth = LocalAuthentication();
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attemptUnlock());
  }

  Future<void> _attemptUnlock() async {
    setState(() => _authenticating = true);
    try {
      final didAuth = await _auth.authenticate(
        localizedReason: 'Unlock Streako',
      );
      if (didAuth) widget.onUnlocked();
    } catch (_) {
      // Fall through to manual retry button.
    } finally {
      if (mounted) setState(() => _authenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logo.png',
                width: 72,
                height: 72,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Streako is locked', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            if (_authenticating)
              const CircularProgressIndicator()
            else
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: _attemptUnlock,
                child: const Text('Unlock'),
              ),
          ],
        ),
      ),
    );
  }
}
