import 'package:flutter/material.dart';

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
  });

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
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
        ),
      ),
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
