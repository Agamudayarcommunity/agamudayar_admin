import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../models/news_api_model.dart';
import '../../../widgets/sidebar.dart';

class NewsApiScreen extends StatelessWidget {
  const NewsApiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: BlocConsumer<NewsBloc, NewsState>(
              listener: (context, state) {
                if (state is ApiNewsImported) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${state.count} news items imported successfully'),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                } else if (state is NewsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: const Color(0xFFF44336), // Red
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'News API Integration',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<NewsBloc>().add(const FetchNewsFromApi());
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Fetch News'),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<NewsBloc>().add(const ImportNewsFromApi());
                                },
                                icon: const Icon(Icons.download),
                                label: const Text('Import to Database'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (state is ApiNewsLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (state is ApiNewsLoaded)
                        Expanded(
                          child: _buildApiNewsList(state.apiNews),
                        )
                      else
                        const Center(
                          child: Text('Press "Fetch News" to load news from the API'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiNewsList(List<dynamic> apiNews) {
    if (apiNews.isEmpty) {
      return const Center(
        child: Text('No news available from the API'),
      );
    }

    return ListView.builder(
      itemCount: apiNews.length,
      itemBuilder: (context, index) {
        final news = apiNews[index] as NewsApiModel;
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (news.images.isNotEmpty)
                      SizedBox(
                        width: 160,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: news.images
                              .where((u) => u.isNotEmpty)
                              .map((u) => ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      u,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 72,
                                          height: 72,
                                          color: AppColors.grey.withOpacity(0.3),
                                          child: const Icon(Icons.image_not_supported),
                                        );
                                      },
                                    ),
                                  ))
                              .toList(),
                        ),
                      )
                    else if (news.image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          news.image,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: AppColors.grey.withOpacity(0.3),
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            news.subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Published: ${_formatDate(news.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  news.contentMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}