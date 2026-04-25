import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/wave_painter.dart';
import 'policy_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = true;
  String? _errorMessage;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) return;

    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final credential = await _authService.registerWithEmail(
        name: _nameController.text, email: _emailController.text, password: _passwordController.text);

      // Do not block app login/navigation if profile write is delayed or denied.
      await _saveUserProfile(credential.user?.uid);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      final message = e is String ? e : e.toString();
      setState(() => _errorMessage = message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserProfile(String? uid) async {
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    try {
      await docRef.set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Ignore profile document write failures to avoid blocking successful signup login state.
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
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(LucideIcons.arrowLeft, color: Color(0xff1e293b)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Join Us 🚀",
                  style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xff1e293b)),
                ),
                const SizedBox(height: 12),
                Text(
                  "Join UniMateX and make college life easier",
                  style: GoogleFonts.inter(fontSize: 16, color: const Color(0xff64748b)),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController, 
                        hint: "Full Name", 
                        icon: LucideIcons.user,
                        validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _emailController, 
                        hint: "Email", 
                        icon: LucideIcons.mail,
                        validator: (v) => v == null || !v.contains('@') ? "Enter a valid email" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _passwordController,
                        hint: "Password",
                        icon: LucideIcons.lock,
                        isPassword: true,
                        obscure: _obscurePassword,
                        onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                        validator: (v) => v == null || v.length < 6 ? "Min 6 characters" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _confirmController,
                        hint: "Confirm Password",
                        icon: LucideIcons.lock,
                        isPassword: true,
                        obscure: _obscureConfirm,
                        onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) => v != _passwordController.text ? "Passwords do not match" : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (val) => setState(() => _agreeToTerms = val!),
                      activeColor: AppColors.blue600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: "I agree to the ",
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => context.push('/policy', extra: {'title': 'Terms & Conditions', 'content': PolicyScreen.dummyTC}),
                                child: Text("Terms & Conditions", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                              ),
                            ),
                            const TextSpan(text: " and "),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => context.push('/policy', extra: {'title': 'Privacy Policy', 'content': PolicyScreen.dummyPrivacy}),
                                child: Text("Privacy Policy", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                _buildPrimaryButton(text: "Sign Up", onPressed: _handleRegister, isLoading: _isLoading),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: GoogleFonts.inter(color: const Color(0xff64748b))),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text("Login", style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
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
          errorStyle: const TextStyle(height: 0),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed, bool isLoading = false}) {
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
        child: isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
