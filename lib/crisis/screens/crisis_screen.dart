import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../shared/widgets/hilway_background.dart';
import '../../shared/widgets/hilway_card.dart';

class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key});

  Future<void> _makeCall(String number) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number.replaceAll(' ', '').replaceAll('-', '').replaceAll('+', ''),
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HilwayBackground(
        child: Stack(
          children: [
            // ── Glassmorphic AppBar ──────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.1),
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const PhosphorIcon(PhosphorIconsRegular.caretLeft),
                          onPressed: () => context.pop(),
                        ),
                        const Text('Crisis Support', style: AppTextStyles.headingSmall),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 80, bottom: 40),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildEmergencyHeader(),
                    const SizedBox(height: 40),
                  
                  _buildSectionHeader('City Mental Health Helpline'),
                  _buildHotlineCard(
                    context,
                    title: 'KaEstorya Line (Globe)',
                    number: '0966 493 1178',
                    icon: PhosphorIconsRegular.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildHotlineCard(
                    context,
                    title: 'KaEstorya Line (Smart)',
                    number: '0985 384 3678',
                    icon: PhosphorIconsRegular.phone,
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('National Crisis Hotlines'),
                  _buildHotlineCard(
                    context,
                    title: 'NCMH Crisis (Landline)',
                    number: '1553',
                    icon: PhosphorIconsRegular.phoneCall,
                  ),
                  const SizedBox(height: 16),
                  _buildHotlineCard(
                    context,
                    title: 'NCMH Crisis (Mobile)',
                    number: '0966 351 4518',
                    icon: PhosphorIconsRegular.phone,
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('In Touch Community Services'),
                  _buildHotlineCard(
                    context,
                    title: 'Support Line (24/7)',
                    number: '0917 899 8727',
                    icon: PhosphorIconsRegular.phone,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.crisis.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.crisis.withValues(alpha: 0.2)),
          ),
          child: const PhosphorIcon(PhosphorIconsFill.firstAid, size: 48, color: AppColors.crisis),
        ),
        const SizedBox(height: 24),
        const Text('You are not alone.', style: AppTextStyles.headingMedium),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'If you are in immediate danger or need someone to talk to, these services are available 24/7 in Roxas City and nationwide.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildHotlineCard(BuildContext context, {required String title, required String number, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: HilwayCard(
        isGlass: true,
        glowColor: AppColors.crisis.withValues(alpha: 0.15),
        padding: const EdgeInsets.all(16),
        onTap: () => _makeCall(number),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.crisis.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: PhosphorIcon(icon, color: AppColors.crisis, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    number, 
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.crisis.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const PhosphorIcon(PhosphorIconsFill.phoneCall, color: AppColors.crisis, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}