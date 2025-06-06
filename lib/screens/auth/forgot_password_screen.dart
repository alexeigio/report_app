import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forgot_password_provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final forgotProvider = Provider.of<ForgotPasswordProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ingresa tu correo para recibir un enlace de recuperación.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            if (forgotProvider.message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  forgotProvider.message!,
                  style: TextStyle(
                    color: forgotProvider.success ? Colors.green : Colors.red,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: forgotProvider.loading
                    ? null
                    : () async {
                        await forgotProvider.sendResetEmail(_emailController.text);
                        if (forgotProvider.success) {
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pop(context);
                          });
                        }
                      },
                child: forgotProvider.loading
                    ? const CircularProgressIndicator()
                    : const Text('Enviar enlace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}