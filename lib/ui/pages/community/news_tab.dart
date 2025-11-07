import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/community_models.dart';
import '../../../services/community/news_service.dart';

const List<String> INDUSTRIES = [
  'All Industries',
  'E-commerce',
  'FinTech',
  'Food & Beverage',
  'Healthcare',
  'Real Estate',
  'Technology',
  'Tourism & Hospitality',
  'Trade',
  'Logistics',
  'Manufacturing',
];

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  final NewsService _service = NewsService();
  bool _isLoading = true;
  String? _error;
  List<NewsItem> _news = [];
  String _selectedIndustry = 'All Industries';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final industry = _selectedIndustry == 'All Industries'
          ? null
          : _selectedIndustry;
      final news = await _service.fetch(
        industry: industry,
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          _news = news;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open article')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Industry filter
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              const Icon(Icons.filter_list, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedIndustry,
                    isExpanded: true,
                    items: INDUSTRIES.map((industry) {
                      return DropdownMenuItem(
                        value: industry,
                        child: Text(industry),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null && value != _selectedIndustry) {
                        setState(() {
                          _selectedIndustry = value;
                        });
                        _loadData();
                      }
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _loadData(forceRefresh: true),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadData(forceRefresh: true),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load news',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _news.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.newspaper,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No news available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No recent news for $_selectedIndustry',
                            style: TextStyle(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _news.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = _news[index];
                      return Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _openArticle(item.url),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.source,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      item.timeAgo,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.snippet,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _openArticle(item.url),
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        size: 16,
                                      ),
                                      label: const Text('Read More'),
                                    ),
                                  ],
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
      ],
    );
  }
}
