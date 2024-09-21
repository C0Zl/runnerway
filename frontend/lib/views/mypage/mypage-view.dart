import 'package:flutter/material.dart';
import 'package:frontend/widgets/under_bar.dart';
import 'package:frontend/views/auth/signup_view.dart';

class MypageView extends StatelessWidget {
  const MypageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('My Page'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpView()),
                );
              },
              child: const Text('Go to Signup Page'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UnderBar(),
    );
  }
}