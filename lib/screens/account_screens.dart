import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/market_ui.dart';

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Enter your university email.';
  }
  final parts = email.toLowerCase().split('@');
  if (parts.length != 2 ||
      parts.first.isEmpty ||
      parts.last != 'sabanciuniv.edu' ||
      email.contains(' ')) {
    return 'Use a @sabanciuniv.edu email address.';
  }
  return null;
}

String? _validatePassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter a password.';
  }
  return null;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _passwordController.clear();
    final email = _emailController.text.trim();
    if (email.toLowerCase() == 'unverified@sabanciuniv.edu') {
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => _VerifyEmailScreen(email: email),
        ),
      );
      if (!mounted || verified != true) return;
    }
    widget.onLogin();
  }

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();
    _passwordController.clear();
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const _SignUpScreen()),
    );
    if (mounted && verified == true) {
      widget.onLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MarketPage(
      title: 'CampusMarket',
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _WelcomePanel(),
              const SizedBox(height: AppSpacing.extraLarge),
              const Text('Welcome back', style: AppText.heading),
              const SizedBox(height: AppSpacing.medium),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'University email',
                  hintText: 'name@sabanciuniv.edu',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _showPassword ? 'Hide password' : 'Show password',
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
                obscureText: !_showPassword,
                textInputAction: TextInputAction.done,
                validator: _validatePassword,
                onFieldSubmitted: (_) => _logIn(),
              ),
              const SizedBox(height: AppSpacing.large),
              ElevatedButton(onPressed: _logIn, child: const Text('Log in')),
              const SizedBox(height: AppSpacing.small),
              OutlinedButton(
                onPressed: _createAccount,
                child: const Text('Create an account'),
              ),
              const SizedBox(height: AppSpacing.medium),
              const Text(
                'Use a university email and a sample password for this demo.',
                style: AppText.note,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -36,
            bottom: -62,
            child: ExcludeSemantics(
              child: Icon(
                Icons.hub_outlined,
                color: AppColors.white.withAlpha(23),
                size: 208,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.extraLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      color: AppColors.lime,
                      size: 17,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'SABANCI CAMPUS',
                        style: AppText.eyebrow.copyWith(color: AppColors.lime),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Good finds.\nCloser to home.',
                  style: AppText.display.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Buy and sell with the Sabancı community.',
                  style: AppText.note.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignUpScreen extends StatefulWidget {
  const _SignUpScreen();

  @override
  State<_SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<_SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _passwordController.clear();
    _confirmController.clear();
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _VerifyEmailScreen(email: _emailController.text.trim()),
      ),
    );
    if (mounted && verified != null) {
      Navigator.pop(context, verified);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MarketPage(
      title: 'Create account',
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AccountIntro(
                icon: Icons.person_add_alt_1_outlined,
                heading: 'Join your campus marketplace',
                detail: 'Use your @sabanciuniv.edu address to get started.',
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your full name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'University email',
                  hintText: 'name@sabanciuniv.edu',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: _validatePassword,
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Confirm your password.';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _signUp(),
              ),
              const SizedBox(height: AppSpacing.large),
              ElevatedButton(onPressed: _signUp, child: const Text('Sign up')),
              const SizedBox(height: AppSpacing.small),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifyEmailScreen extends StatelessWidget {
  const _VerifyEmailScreen({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return MarketPage(
      title: 'Verify email',
      child: ListView(
        children: [
          _AccountIntro(
            icon: Icons.mark_email_unread_outlined,
            heading: 'Check your inbox',
            detail: 'A verification link would be sent to $email.',
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('I have verified my email'),
          ),
          const SizedBox(height: AppSpacing.small),
          OutlinedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Verification email'),
                content: Text('Sample resend request for $email.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
            child: const Text('Resend verification email'),
          ),
          const SizedBox(height: AppSpacing.medium),
          const Text(
            'You can continue by simulating verification for this demo.',
            style: AppText.note,
          ),
          const SizedBox(height: AppSpacing.large),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back to log in'),
          ),
        ],
      ),
    );
  }
}

class _AccountIntro extends StatelessWidget {
  const _AccountIntro({
    required this.icon,
    required this.heading,
    required this.detail,
  });

  final IconData icon;
  final String heading;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.navy, size: 28),
          const SizedBox(height: AppSpacing.small),
          Text(heading, style: AppText.heading),
          const SizedBox(height: AppSpacing.small),
          Text(detail, style: AppText.note),
        ],
      ),
    );
  }
}
