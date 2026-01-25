import 'package:defake_app/screens/main_screen.dart';
import 'package:defake_app/services/auth_service.dart';
import 'package:defake_app/services/firestore_service.dart';
import 'package:defake_app/models/user_model.dart';
import 'package:defake_app/theme/app_theme.dart';
import 'package:defake_app/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        // Sign In
        await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Sign Up
        final credential = await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );

        // Create user profile in Firestore
        if (credential?.user != null) {
          final user = UserModel(
            uid: credential!.user!.uid,
            email: credential.user!.email!,
            displayName: _nameController.text.trim(),
          );
          await _firestoreService.createUserProfile(user);
        }
      }

      // Navigate to main screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // TEMPORARILY DISABLED - Google Sign-In compatibility issues
  // Future<void> _signInWithGoogle() async {
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });

  //   try {
  //     final credential = await _authService.signInWithGoogle();
      
  //     if (credential == null) {
  //       // User cancelled
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       return;
  //     }

  //     // Create or update user profile in Firestore
  //     if (credential.user != null) {
  //       final user = UserModel(
  //         uid: credential.user!.uid,
  //         email: credential.user!.email ?? '',
  //         displayName: credential.user!.displayName ?? 'User',
  //         photoURL: credential.user!.photoURL,
  //       );
  //       await _firestoreService.createUserProfile(user);
  //     }

  //     // Navigate to main screen
  //     if (mounted) {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (_) => const MainScreen()),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = e.toString();
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.3),
                        AppTheme.secondary.withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.shield,
                    size: 80,
                    color: AppTheme.primary,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 24),

                Text(
                  "TRUTHGUARD",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 8),

                Text(
                  "Deepfake Detection System",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 48),

                // Form Card
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Toggle Login/Signup
                        Row(
                          children: [
                            Expanded(
                              child: _buildTabButton("Login", _isLogin, () {
                                setState(() {
                                  _isLogin = true;
                                  _errorMessage = null;
                                });
                              }),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTabButton("Sign Up", !_isLogin, () {
                                setState(() {
                                  _isLogin = false;
                                  _errorMessage = null;
                                });
                              }),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Name field (Sign Up only)
                        if (!_isLogin)
                          _buildTextField(
                            controller: _nameController,
                            label: "Full Name",
                            icon: LucideIcons.user,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),

                        if (!_isLogin) const SizedBox(height: 16),

                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          label: "Email",
                          icon: LucideIcons.mail,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        _buildTextField(
                          controller: _passwordController,
                          label: "Password",
                          icon: LucideIcons.lock,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (!_isLogin && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        // Error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.alertCircle, color: AppTheme.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: AppTheme.error, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.black),
                                    ),
                                  )
                                : Text(
                                    _isLogin ? "Sign In" : "Create Account",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        // TEMPORARILY DISABLED - Google Sign-In
                        // const SizedBox(height: 24),

                        // // OR Divider
                        // Row(
                        //   children: [
                        //     const Expanded(child: Divider(color: AppTheme.surfaceLight)),
                        //     Padding(
                        //       padding: const EdgeInsets.symmetric(horizontal: 16),
                        //       child: Text(
                        //         "OR",
                        //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        //               color: AppTheme.textSecondary,
                        //             ),
                        //       ),
                        //     ),
                        //     const Expanded(child: Divider(color: AppTheme.surfaceLight)),
                        //   ],
                        // ),

                        // const SizedBox(height: 24),

                        // // Google Sign-In Button
                        // SizedBox(
                        //   width: double.infinity,
                        //   height: 50,
                        //   child: OutlinedButton.icon(
                        //     onPressed: _isLoading ? null : _signInWithGoogle,
                        //     icon: Image.network(
                        //       'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        //       height: 24,
                        //       width: 24,
                        //       errorBuilder: (context, error, stackTrace) => 
                        //           const Icon(LucideIcons.globe, size: 24, color: Colors.white),
                        //     ),
                        //     label: Text(
                        //       _isLogin ? "Sign in with Google" : "Sign up with Google",
                        //       style: const TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //     style: OutlinedButton.styleFrom(
                        //       backgroundColor: AppTheme.surfaceLight.withOpacity(0.3),
                        //       side: BorderSide(color: AppTheme.surfaceLight.withOpacity(0.5)),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.2, end: 0, delay: 400.ms).fadeIn(),

                const SizedBox(height: 24),

                // Security Note
                Text(
                  "🔒 Your data is encrypted and secure",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.surfaceLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.black : AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.surfaceLight.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.surfaceLight.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
      ),
    );
  }
}
