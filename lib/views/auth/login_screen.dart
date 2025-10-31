import '../../core/utils/library.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: context.isMobile ? context.screenWidth * 0.9 : 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Login",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  onSubmitted: (value) => login(),
                ),
                const SizedBox(height: 20),
                authProvider.isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          login();
                        },
                        child: Text("Login"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!context.mounted) return;
      if (authProvider.currentUser != null) {
        StorageUtils.storeData(
          AppText.userDataKey,
          json.encode(authProvider.currentUser!.toJson()),
        );
        final isAdmin = authProvider.currentUser!.role == 'admin';
        if (!mounted) return;
        context.go(isAdmin ? '/admin/dashboard' : '/home');
      } else {
        if (!mounted) return;
        context.showSnack(
          authProvider.errorMessage ?? "Login failed",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      context.showSnack("Error: $e", backgroundColor: Colors.red);
    }
  }
}
