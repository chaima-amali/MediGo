import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../main.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/back_arrow.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selectedLang = 'en';

  final Map<String, Map<String, dynamic>> languages = {
    'en': {
      'name': 'English',
      'flag': '🇬🇧',
    },
    'fr': {
      'name': 'Français',
      'flag': '🇫🇷',
    },
    'ar': {
      'name': 'العربية',
      'flag': '🇩🇿',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language') ?? 'en';
    setState(() {
      selectedLang = savedLanguage;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = Localizations.localeOf(context).languageCode;
    if (localeCode != selectedLang) {
      setState(() => selectedLang = localeCode);
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    
    setState(() {
      selectedLang = languageCode;
    });
    
    // Update app locale
    MediGoApp.setLocale(context, Locale(languageCode));
    
    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to ${languages[languageCode]!['name']}'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        leading: const CustomBackArrow(),
        title: Text(
          loc.language,
          style: AppText.bold.copyWith(
            fontSize: 24,
            color: AppColors.darkBlue,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your preferred language',
              style: AppText.regular.copyWith(
                fontSize: 16,
                color: AppColors.darkBlue.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            
            // Language options
            ...languages.entries.map((entry) {
              final bool isSelected = selectedLang == entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GestureDetector(
                  onTap: () => _changeLanguage(entry.key),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected 
                              ? AppColors.primary.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: isSelected ? 10 : 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          entry.value['flag'],
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            entry.value['name'],
                            style: AppText.medium.copyWith(
                              fontSize: 18,
                              color: isSelected ? Colors.white : AppColors.darkBlue,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}