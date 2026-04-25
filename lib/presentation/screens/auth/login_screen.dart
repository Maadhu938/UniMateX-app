import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/wave_painter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await _authService.signInWithEmail(email: _emailController.text, password: _passwordController.text);
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Welcome Text
                Text(
                  "Welcome Back! 👋",
                  style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xff1e293b)),
                ),
                const SizedBox(height: 12),
                Text(
                  "Login to continue your journey",
                  style: GoogleFonts.inter(fontSize: 16, color: const Color(0xff64748b)),
                ),
                const SizedBox(height: 60),
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        hint: "Email or Student ID",
                        icon: LucideIcons.mail,
                        validator: (v) => v == null || v.isEmpty ? "Email is required" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        hint: "Password",
                        icon: LucideIcons.lock,
                        isPassword: true,
                        obscure: _obscurePassword,
                        onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                        validator: (v) => v == null || v.length < 6 ? "Password must be at least 6 characters" : null,
                      ),
                    ],
                  ),
                ),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {}, // Handle forgot password
                    child: Text("Forgot Password?", style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertCircle, color: AppColors.danger, size: 18),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Login Button
                _buildPrimaryButton(
                  text: "Login",
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 32),
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("or", style: TextStyle(color: Colors.grey.shade400))),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 32),
                // Google Login
                _buildGoogleButton(),
                const SizedBox(height: 40),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don’t have an account? ", style: GoogleFonts.inter(color: const Color(0xff64748b))),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: Text("Sign Up", style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
          suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? LucideIcons.eyeOff : LucideIcons.eye, size: 18), onPressed: onToggleObscure) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          errorStyle: const TextStyle(height: 0), // Hide default error text to keep UI clean
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed, bool isLoading = false, String? loadingText}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: _handleGoogleLogin,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network("https://www.gstatic.com/images/branding/googleg/1x/googleg_standard_color_128dp.png", height: 24),
            const SizedBox(width: 12),
            Text("Continue with Google", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain)),
          ],
        ),
      ),
    );
  }
}
