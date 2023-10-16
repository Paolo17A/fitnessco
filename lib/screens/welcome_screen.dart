import 'package:fitnessco/widgets/custom_button_widgets.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_container_widget.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: welcomeBackgroundContainer(context,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/fitnessco_logo.png'),
                    roundedContainer(
                        color: Colors.white.withOpacity(0.8),
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: futuraText('WELCOME',
                                    textStyle: blackBoldStyle(size: 24)),
                              ),
                              gradientOvalButton(
                                  label: 'Create Your Account',
                                  width: 250,
                                  height: 70,
                                  onTap: () => Navigator.of(context)
                                      .pushNamed('/signUp')),
                              const SizedBox(height: 50),
                              _alreadyHaveAccount(context)
                            ],
                          ),
                        ))
                  ]))),
    );
  }

  Widget _alreadyHaveAccount(BuildContext context) {
    return Column(
      children: [
        futuraText('Already have an account?',
            textStyle: blackBoldStyle(size: 18)),
        TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/signIn'),
            child: Text('Sign in Here')),
        const SizedBox(height: 20)
      ],
    );
  }
}
