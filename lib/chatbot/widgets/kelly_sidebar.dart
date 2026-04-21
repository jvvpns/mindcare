import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../providers/chat_provider.dart';
import '../providers/kelly_state_provider.dart';
import '../widgets/kelly_orb_mascot.dart';

class KellySidebar extends ConsumerWidget {
  const KellySidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider);
    final isThinking = ref.watch(chatLoadingProvider);
    final emotion = ref.watch(kellyEmotionProvider);

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        border: const Border(
          left: BorderSide(color: Colors.white24),
        ),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                KellyMiniOrb(emotion: emotion, size: 40),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Kelly", style: AppTextStyles.headingSmall),
                    Text("Your AI Companion", style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
          
          // ── Messages List ───────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _SidebarMessageBubble(msg: msg);
              },
            ),
          ),
          
          if (isThinking)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            ),

          // ── Input ───────────────────────────────────────────────────────────
          _SidebarInput(isThinking: isThinking),
        ],
      ),
    );
  }
}

class _SidebarMessageBubble extends StatelessWidget {
  final dynamic msg;
  const _SidebarMessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser 
                  ? AppColors.secondary.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUser 
                    ? AppColors.secondary.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              msg.text,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarInput extends StatefulWidget {
  final bool isThinking;
  const _SidebarInput({required this.isThinking});

  @override
  State<_SidebarInput> createState() => _SidebarInputState();
}

class _SidebarInputState extends State<_SidebarInput> {
  final _controller = TextEditingController();

  void _submit(WidgetRef ref) {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isThinking) return;
    _controller.clear();
    ref.read(chatMessagesProvider.notifier).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _controller,
            enabled: !widget.isThinking,
            onSubmitted: (_) => _submit(ref),
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: "Talk to Kelly...",
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              suffixIcon: IconButton(
                onPressed: () => _submit(ref),
                icon: const PhosphorIcon(PhosphorIconsRegular.paperPlaneRight),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      },
    );
  }
}
