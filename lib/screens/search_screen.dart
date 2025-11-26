import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMood = '';
  
  final List<String> _moods = [
    'Cozy',
    'Tense',
    'Educational',
    'Inspiring',
    'Relaxing',
    'Adventurous',
    'Mysterious',
    'Romantic',
  ];
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Search & Explore'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search by title, author, or narrator...',
                hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Search by Mood section
            Text(
              'Search by Mood',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Wrap(
              spacing: AppTheme.spacingM,
              runSpacing: AppTheme.spacingM,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood;
                return _buildMoodChip(mood, isSelected);
              }).toList(),
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Search by Narrator section
            Text(
              'Search by Narrator',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Use voice match technology to find books that sound like your favorite narrators',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spacingM),
            ElevatedButton.icon(
              onPressed: () {
                // Open narrator search
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Narrator search coming soon')),
                );
              },
              icon: const Icon(Icons.mic),
              label: const Text('Find Similar Voices'),
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Popular Genres
            Text(
              'Popular Genres',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildGenreGrid(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMoodChip(String mood, bool isSelected) {
    return FilterChip(
      label: Text(mood),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedMood = selected ? mood : '';
        });
      },
      selectedColor: AppTheme.highlightColor.withOpacity(0.3),
      checkmarkColor: AppTheme.highlightColor,
      labelStyle: AppTheme.bodyMedium.copyWith(
        color: isSelected ? AppTheme.highlightColor : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
  
  Widget _buildGenreGrid() {
    final genres = [
      'Fiction',
      'Mystery',
      'Sci-Fi',
      'Fantasy',
      'Romance',
      'Thriller',
      'Non-Fiction',
      'Biography',
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
        childAspectRatio: 2.5,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () {
              // Navigate to genre feed
            },
            child: Center(
              child: Text(
                genres[index],
                style: AppTheme.bodyMedium,
              ),
            ),
          ),
        );
      },
    );
  }
}

