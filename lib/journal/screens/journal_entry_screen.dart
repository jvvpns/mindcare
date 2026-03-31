import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/journal_entry.dart';
import '../providers/journal_provider.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  final JournalEntry? entry;

  const JournalEntryScreen({super.key, this.entry});

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  double? _selectedMoodIndex;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    _selectedMoodIndex = widget.entry?.moodIndex;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title and some content.')),
      );
      return;
    }

    if (widget.entry == null) {
      ref.read(journalProvider.notifier).addEntry(
            title,
            content,
            moodIndex: _selectedMoodIndex,
          );
    } else {
      ref.read(journalProvider.notifier).updateEntry(
            widget.entry!,
            title,
            content,
            moodIndex: _selectedMoodIndex,
          );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry', style: AppTextStyles.headingSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.x, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: Text(
              'Save',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.headingMedium.copyWith(fontSize: 24),
                decoration: InputDecoration(
                  hintText: 'Entry Title',
                  hintStyle: AppTextStyles.headingMedium.copyWith(color: AppColors.textTertiary, fontSize: 24),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 16),
              const Text("How are you feeling?", style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(
                    AppConstants.moodEmojis.length,
                    (index) {
                      final isSelected = _selectedMoodIndex == index.toDouble();
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMoodIndex = isSelected ? null : index.toDouble();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(AppConstants.moodEmojis[index], style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  AppConstants.moodLabels[index],
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _contentController,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                maxLines: null,
                minLines: 10,
                decoration: InputDecoration(
                  hintText: 'Start writing your thoughts...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
