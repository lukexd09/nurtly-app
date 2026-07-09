import 'package:flutter/material.dart';

import '../../core/ads/consent_flow_controller.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_note.dart';
import '../../core/widgets/detail_section.dart';
import '../../core/widgets/section_header.dart';

class PrivacyDataScreen extends StatelessWidget {
  const PrivacyDataScreen({
    super.key,
    this.strings = AppStrings.english,
    this.onOpenPrivacyChoices,
    this.onDeleteAllLocalData,
    this.refreshListenable,
    this.consentFlow,
  });

  final AppStrings strings;
  final VoidCallback? onOpenPrivacyChoices;
  final Future<void> Function()? onDeleteAllLocalData;
  final Listenable? refreshListenable;
  final ConsentFlow? consentFlow;

  @override
  Widget build(BuildContext context) {
    final body = refreshListenable == null
        ? _PrivacyBody(
            strings: strings,
            privacyChoicesVisible: _privacyChoicesVisible,
            onOpenPrivacyChoices: onOpenPrivacyChoices,
            onDeleteAllLocalData: onDeleteAllLocalData,
            onConfirmDelete: _confirmDelete,
          )
        : AnimatedBuilder(
            animation: refreshListenable!,
            builder: (context, _) {
              return _PrivacyBody(
                strings: strings,
                privacyChoicesVisible: _privacyChoicesVisible,
                onOpenPrivacyChoices: onOpenPrivacyChoices,
                onDeleteAllLocalData: onDeleteAllLocalData,
                onConfirmDelete: _confirmDelete,
              );
            },
          );

    return Scaffold(
      body: SafeArea(child: body),
    );
  }

  bool get _privacyChoicesVisible {
    return consentFlow?.privacyOptionsRequired ?? false;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final action = onDeleteAllLocalData;
    if (action == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.deleteAllLocalDataTitle),
          content: Text(strings.deleteAllLocalDataBody),
          actions: [
            TextButton(
              key: const ValueKey('delete-all-local-data-cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.back),
            ),
            FilledButton(
              key: const ValueKey('delete-all-local-data-confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(strings.deleteAllLocalData),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    try {
      await action();
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.deleteAllLocalDataFailed)),
      );
      return;
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.deleteAllLocalDataSuccess)),
    );
  }
}

class _PrivacyBody extends StatelessWidget {
  const _PrivacyBody({
    required this.strings,
    required this.privacyChoicesVisible,
    required this.onOpenPrivacyChoices,
    required this.onDeleteAllLocalData,
    required this.onConfirmDelete,
  });

  final AppStrings strings;
  final bool privacyChoicesVisible;
  final VoidCallback? onOpenPrivacyChoices;
  final Future<void> Function()? onDeleteAllLocalData;
  final Future<void> Function(BuildContext context) onConfirmDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: strings.back,
            color: AppColors.primary,
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(
          title: strings.privacyTitle,
          subtitle: strings.privacySubtitle,
        ),
        const SizedBox(height: AppSpacing.lg),
        DetailSection(
          title: strings.currentMvpBehavior,
          children: [
            _PrivacyLine(strings.parentFirstAudience),
            _PrivacyLine(strings.childNameNotRequired),
            _PrivacyLine(strings.birthdateNotRequired),
            if (privacyChoicesVisible && onOpenPrivacyChoices != null)
              _PrivacyAction(
                label: strings.privacyChoices,
                onTap: onOpenPrivacyChoices!,
              ),
            _PrivacyAction(
              label: strings.deleteAllLocalData,
              onTap: () => onConfirmDelete(context),
            ),
            const SizedBox(height: AppSpacing.xs),
            _PrivacyLine(strings.noAccount),
            _PrivacyLine(
              strings.noJournalCloudSync,
            ),
            _PrivacyLine(strings.premiumRemovesAdsInFreePlan),
            _PrivacyLine(strings.noCloudSync),
            _PrivacyLine(strings.noAnalytics),
            _PrivacyLine(strings.analyticsScopeMayInclude),
            _PrivacyLine(strings.freePlanMayShowAdsInPassiveSlots),
            _PrivacyLine(strings.purchasesGoThroughGooglePlay),
            _PrivacyLine(strings.journalContentNotUsedForAds),
            _PrivacyLine(strings.premiumStateMayBeStoredLocally),
            _PrivacyLine(strings.bundledSampleContent),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        DetailNote(
          title: strings.futureChangesTitle,
          text: strings.futureChanges,
        ),
      ],
    );
  }
}

class _PrivacyLine extends StatelessWidget {
  const _PrivacyLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text('- $text', style: AppTextStyles.body);
  }
}

class _PrivacyAction extends StatelessWidget {
  const _PrivacyAction({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
