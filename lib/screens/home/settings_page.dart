import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/utils/icon_assets.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';
import 'package:hey_notes/extension/extension.dart';
import 'package:hey_notes/screens/home/appearance_page.dart';
import 'package:hey_notes/widgets/custom_image.dart';
import 'package:hey_notes/widgets/show_svg.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings';
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? AppColors.black : AppColors.white,
      appBar: AppBar(
        backgroundColor: context.isDarkMode ? AppColors.black : AppColors.white,
        title: SlideInLeft(
          child: Text(
            'Settings',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIHelpers.scaffoldPadding,
          ),
          child: Column(
            children: [
              //*
              const Gap(UIHelpers.md),
              Center(
                child: CustomImage.circular(
                  imagePath: "https://avatar.iran.liara.run/public/35",
                  size: 100,
                ),
              ),
              const Gap(UIHelpers.md),
              Center(
                child: Text(
                  '@Collins',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Gap(UIHelpers.md),

              //*
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AppearancePage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: UIHelpers.sm),
                  decoration: BoxDecoration(
                    // color: context.isDarkMode ? AppColors.black : AppColors.white,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: UIHelpers.xl,
                            width: UIHelpers.xl,
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const ShowSVG(
                              svgPath: IconAssets.sun,
                              height: 16,
                              width: 16,
                              color: AppColors.white,
                            ),
                          ),
                          const Gap(UIHelpers.md),
                          Text(
                            "Appearance",
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const Gap(UIHelpers.md),
            ],
          ),
        ),
      ),
    );
  }
}
