import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/philippines_schools.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../../core/services/hive_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _otherSchoolController = TextEditingController();

  String? _selectedYearLevel;
  PhilippineSchool? _selectedSchool;
  bool _isOtherSchool = false;
  
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _otherSchoolController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedYearLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your year level'), backgroundColor: AppColors.error),
      );
      return;
    }
    
    if (_selectedSchool == null && !_isOtherSchool) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your school'), backgroundColor: AppColors.error),
      );
      return;
    }

    final schoolName = _isOtherSchool ? _otherSchoolController.text.trim() : _selectedSchool!.name;
    
    if (_isOtherSchool && schoolName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your school name'), backgroundColor: AppColors.error),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          yearLevel: _selectedYearLevel!,
          school: schoolName,
        );

    if (!mounted) return;
    if (success) {
      // First time user — go to tutorial
      final tutorialSeen = HiveService.settingsBox.get('tutorial_seen', defaultValue: false) as bool;
      if (!tutorialSeen) {
        context.go(AppRoutes.tutorial);
      } else {
        context.go(AppRoutes.dashboard);
      }
    }
  }

  void _showSchoolPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Select your School', style: AppTextStyles.headingMedium),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: AppSchools.capizNursingSchools.length + 1,
                    separatorBuilder: (_, __) => const Divider(color: AppColors.borderLight, height: 1),
                    itemBuilder: (context, index) {
                      if (index == AppSchools.capizNursingSchools.length) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(Icons.school_outlined, color: AppColors.primary),
                          ),
                          title: const Text('Other / Not Listed', style: AppTextStyles.bodyLarge),
                          onTap: () {
                            setState(() {
                              _selectedSchool = null;
                              _isOtherSchool = true;
                            });
                            Navigator.pop(context);
                          },
                        );
                      }
                      
                      final school = AppSchools.capizNursingSchools[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              school.logoUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                PhosphorIconsRegular.graduationCap,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        title: Text(school.name, style: AppTextStyles.bodyMedium),
                        onTap: () {
                          setState(() {
                            _selectedSchool = school;
                            _isOtherSchool = false;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 20),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Text('Create account', style: AppTextStyles.displayMedium),
                const SizedBox(height: 6),
                Text(
                  'Join HILWAY and start your wellness journey',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                // ── Personal Info ───────────────────────────────────────────
                const Text('Personal Information', style: AppTextStyles.labelLarge),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _fullNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(PhosphorIconsRegular.user, size: 20),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(PhosphorIconsRegular.phone, size: 20),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 24),

                // ── Academic Info ───────────────────────────────────────────
                const Text('Academic Details', style: AppTextStyles.labelLarge),
                const SizedBox(height: 16),

                // ignore: deprecated_member_use
                DropdownButtonFormField<String>(
                  initialValue: _selectedYearLevel,
                  decoration: const InputDecoration(
                    labelText: 'Year Level',
                    prefixIcon: Icon(PhosphorIconsRegular.graduationCap, size: 20),
                  ),
                  items: AppSchools.yearLevels.map((year) {
                    return DropdownMenuItem(value: year, child: Text(year));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedYearLevel = val),
                  validator: (v) => v == null ? 'Year level is required' : null,
                ),
                const SizedBox(height: 14),

                InkWell(
                  onTap: _showSchoolPicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderMedium),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(PhosphorIconsRegular.buildings, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isOtherSchool 
                              ? 'Other School' 
                              : (_selectedSchool?.name ?? 'Select your school'),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: (_selectedSchool != null || _isOtherSchool) ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Icon(PhosphorIconsRegular.caretDown, color: AppColors.textSecondary, size: 18),
                      ],
                    ),
                  ),
                ),
                
                if (_isOtherSchool) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _otherSchoolController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'School Name',
                      prefixIcon: Icon(PhosphorIconsRegular.pencilSimple, size: 20),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'School name is required' : null,
                  ),
                ],
                const SizedBox(height: 24),

                // ── Account Info ────────────────────────────────────────────
                const Text('Account Info', style: AppTextStyles.labelLarge),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(PhosphorIconsRegular.envelope, size: 20),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(PhosphorIconsRegular.lock, size: 20),
                    helperText: 'At least 8 characters with 1 uppercase and 1 number',
                    helperStyle: AppTextStyles.caption,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    prefixIcon: const Icon(PhosphorIconsRegular.lock, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: Validators.confirmPassword(_passwordController.text),
                ),

                const SizedBox(height: 32),

                // ── Submit ──────────────────────────────────────────────────
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create account'),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: Text('Sign in', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}