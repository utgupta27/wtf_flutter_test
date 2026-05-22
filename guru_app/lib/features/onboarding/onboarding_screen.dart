import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/theme/app_theme.dart';
import 'package:guru_app/features/onboarding/viewmodel/onboarding_viewmodel.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
}

const _introPages = [
  _OnboardingPage(
    icon: Icons.fitness_center_rounded,
    title: 'Welcome to WTF',
    subtitle:
        'Your personal trainer, always available. Get expert guidance wherever you are.',
  ),
  _OnboardingPage(
    icon: Icons.video_call_rounded,
    title: 'Chat, Schedule & Call',
    subtitle:
        'Message your trainer, book sessions, and join live video calls — all in one place.',
  ),
];

const _profilePageIndex = 2;
const _pageCount = 3;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  final _nameController = TextEditingController(text: 'DK');
  int _currentPage = 0;
  String _selectedTrainerId = SeedTrainers.list.first.id;
  String? _nameError;
  String? _trainerError;

  bool get _isProfilePage => _currentPage == _profilePageIndex;

  Future<void> _completeProfile() async {
    final name = _nameController.text;
    if (name.trim().isEmpty) {
      setState(() => _nameError = 'Please enter your name');
      return;
    }
    if (_selectedTrainerId.isEmpty) {
      setState(() => _trainerError = 'Please choose a trainer');
      return;
    }
    setState(() {
      _nameError = null;
      _trainerError = null;
    });
    await ref.read(onboardingViewModelProvider.notifier).completeProfile(
          name: name,
          trainerId: _selectedTrainerId,
        );
  }

  Future<void> _completeWithDefaults() async {
    await ref.read(onboardingViewModelProvider.notifier).completeProfile(
          name: 'DK',
          trainerId: SeedTrainers.list.first.id,
        );
  }

  void _skip() {
    if (_isProfilePage) {
      _completeWithDefaults();
      return;
    }
    _controller.jumpToPage(_profilePageIndex);
    setState(() => _currentPage = _profilePageIndex);
  }

  void _next() {
    if (_currentPage < _profilePageIndex) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPrimaryPressed() {
    if (_isProfilePage) {
      _completeProfile();
    } else {
      _next();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastIntroPage = _currentPage == _profilePageIndex - 1;
    final primaryLabel = _isProfilePage
        ? 'Get Started'
        : (isLastIntroPage ? 'Continue' : 'Next');

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: TextButton(
                  onPressed: _skip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: AppColors.subtle, fontSize: 14),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageCount,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  if (index < _introPages.length) {
                    return _PageContent(page: _introPages[index]);
                  }
                  return _ProfileSetupPage(
                    nameController: _nameController,
                    selectedTrainerId: _selectedTrainerId,
                    nameError: _nameError,
                    trainerError: _trainerError,
                    onTrainerSelected: (id) =>
                        setState(() => _selectedTrainerId = id),
                    onNameChanged: (_) =>
                        setState(() => _nameError = null),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pageCount,
                      (i) => OnboardingDot(active: i == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _onPrimaryPressed,
                    child: Text(primaryLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.icon, size: 96, color: AppColors.primary),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.subtle,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileSetupPage extends StatelessWidget {
  const _ProfileSetupPage({
    required this.nameController,
    required this.selectedTrainerId,
    required this.nameError,
    required this.trainerError,
    required this.onTrainerSelected,
    required this.onNameChanged,
  });

  final TextEditingController nameController;
  final String selectedTrainerId;
  final String? nameError;
  final String? trainerError;
  final ValueChanged<String> onTrainerSelected;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Set up your profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Confirm your name and choose your trainer.',
            style: TextStyle(fontSize: 16, color: AppColors.subtle),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: nameController,
            onChanged: onNameChanged,
            decoration: InputDecoration(
              labelText: 'Your name',
              errorText: nameError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Choose your trainer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          if (trainerError != null) ...[
            const SizedBox(height: 8),
            Text(
              trainerError!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 8),
          ...SeedTrainers.list.map(
            (trainer) {
              final isSelected = selectedTrainerId == trainer.id;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : null,
                child: ListTile(
                  title: Text(trainer.name),
                  subtitle: Text(trainer.email),
                  trailing: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: isSelected ? AppColors.primary : AppColors.subtle,
                  ),
                  onTap: () => onTrainerSelected(trainer.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class OnboardingDot extends StatelessWidget {
  const OnboardingDot({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
