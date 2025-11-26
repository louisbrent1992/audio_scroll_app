import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/audiobook_snippet.dart';
import '../services/mock_data_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AudiobookSnippet> _wishlist = [];
  List<AudiobookSnippet> _history = [];
  List<AudiobookSnippet> _purchased = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  void _loadData() {
    // In a real app, this would load from a database or API
    final allSnippets = MockDataService.getMockSnippets();
    setState(() {
      _wishlist = [allSnippets[0]]; // Example: first snippet in wishlist
      _history = allSnippets; // Example: all snippets in history
      _purchased = [allSnippets[1]]; // Example: second snippet purchased
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Library'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Wishlist'),
            Tab(text: 'History'),
            Tab(text: 'Purchased'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLibraryList(_wishlist, 'No books in wishlist yet'),
          _buildLibraryList(_history, 'No listening history'),
          _buildLibraryList(_purchased, 'No purchased books'),
        ],
      ),
    );
  }
  
  Widget _buildLibraryList(List<AudiobookSnippet> items, String emptyMessage) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              emptyMessage,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildLibraryItem(items[index]);
      },
    );
  }
  
  Widget _buildLibraryItem(AudiobookSnippet snippet) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
          child: CachedNetworkImage(
            imageUrl: snippet.coverImageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 60,
              height: 60,
              color: AppTheme.surfaceColor,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 60,
              height: 60,
              color: AppTheme.surfaceColor,
              child: const Icon(Icons.book, color: AppTheme.textSecondary),
            ),
          ),
        ),
        title: Text(
          snippet.bookTitle,
          style: AppTheme.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              snippet.author,
              style: AppTheme.bodySmall,
            ),
            Text(
              'Narrated by ${snippet.narrator}',
              style: AppTheme.caption,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_outline),
          onPressed: () {
            // Navigate to feed with this snippet
          },
        ),
      ),
    );
  }
}

