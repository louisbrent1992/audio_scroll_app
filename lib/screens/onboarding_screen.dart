import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingScreen({super.key, required this.onComplete});
  
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<String> _genres = [
    'Fiction',
    'Non-Fiction',
    'Mystery',
    'Thriller',
    'Science Fiction',
    'Fantasy',
    'Romance',
    'Historical Fiction',
    'Biography',
    'Self-Help',
    'Business',
    'Philosophy',
  ];
  
  final List<String> _narrators = [
    'Julia Whelan',
    'Ray Porter',
    'Jim Dale',
    'Stephen Fry',
    'Davina Porter',
    'Simon Vance',
    'Michael Kramer',
    'Kate Reading',
  ];
  
  Set<String> _selectedGenres = {};
  Set<String> _selectedNarrators = {};
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
          children: [
            _buildWelcomePage(),
            _buildGenreSelectionPage(),
            _buildNarratorSelectionPage(),
            _buildCompletePage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
  
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            Icons.headphones,
            size: 100,
            color: AppTheme.highlightColor,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Text(
            'Welcome to AudioScroll',
            style: AppTheme.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Discover your next favorite audiobook through short, engaging snippets',
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }
  
  Widget _buildGenreSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingXL),
          Text(
            'What genres do you like?',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Select all that interest you',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.spacingM,
                mainAxisSpacing: AppTheme.spacingM,
                childAspectRatio: 2.5,
              ),
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = _selectedGenres.contains(genre);
                return _buildSelectionChip(
                  label: genre,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGenres.remove(genre);
                      } else {
                        _selectedGenres.add(genre);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNarratorSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingXL),
          Text(
            'Who are your favorite narrators?',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Select all that you enjoy',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Expanded(
            child: ListView.builder(
              itemCount: _narrators.length,
              itemBuilder: (context, index) {
                final narrator = _narrators[index];
                final isSelected = _selectedNarrators.contains(narrator);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: _buildSelectionChip(
                    label: narrator,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedNarrators.remove(narrator);
                        } else {
                          _selectedNarrators.add(narrator);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompletePage() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            Icons.check_circle,
            size: 100,
            color: AppTheme.successColor,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Text(
            'You\'re all set!',
            style: AppTheme.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Start discovering amazing audiobooks',
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }
  
  Widget _buildSelectionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.highlightColor.withOpacity(0.3)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isSelected ? AppTheme.highlightColor : AppTheme.textTertiary,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: isSelected ? AppTheme.highlightColor : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(color: AppTheme.textTertiary.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Back'),
            )
          else
            const SizedBox(),
          Row(
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppTheme.highlightColor
                      : AppTheme.textTertiary,
                ),
              );
            }),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentPage < 3) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                widget.onComplete();
              }
            },
            child: Text(_currentPage < 3 ? 'Next' : 'Get Started'),
          ),
        ],
      ),
    );
  }
}

