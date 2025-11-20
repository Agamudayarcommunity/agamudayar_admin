import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../widgets/sidebar.dart';
import '../../news/providers/news_provider.dart';
import '../../news/widgets/news_status_card.dart';
import 'package:web/web.dart' as web;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Load initial data when dashboard is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadNews();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        actions: [
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              return IconButton(
                icon: newsProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      )
                    : const Icon(Icons.refresh_rounded),
                onPressed: newsProvider.isLoading
                    ? null
                    : () => newsProvider.refreshNews(),
                tooltip: 'Refresh Data',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const Sidebar(currentRoute: '/dashboard'),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          return _buildDashboardContent(newsProvider: newsProvider);
        },
      ),
    );
  }

  Widget _buildDashboardContent({required NewsProvider newsProvider}) {
    // Check if news provider is in loading state
    if (newsProvider.isLoading && newsProvider.news.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading dashboard data...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Check if news provider is in error state
    if (newsProvider.error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading news data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                newsProvider.error!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => newsProvider.refreshNews(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Main content with animations
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dashboard_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to Agamudayar Admin Panel',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage news content for the community',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Statistics Section
              Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    color: Colors.grey[700],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'News Statistics',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Beautiful news card
              _buildModernDashboardCard(context, newsProvider: newsProvider),

              const SizedBox(height: 32),

              // Status Overview Section
              Row(
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: Colors.grey[700],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'News Status Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const NewsStatusCard(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Version: 1.0.0+1',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                  Expanded(child: const DunsTrustBadge()),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Rest of the widget methods remain the same

  // Commented out - using News feature only
  /*
  Widget _buildJobsCard(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        int pendingCount = 0;
        int approvedCount = 0;
        int rejectedCount = 0;

        if (state is JobLoaded) {
          pendingCount = state.jobs
              .where((item) => item.status == ApprovalStatus.pending.name)
              .length;
          approvedCount = state.jobs
              .where((item) => item.status == ApprovalStatus.approved.name)
              .length;
          rejectedCount = state.jobs
              .where((item) => item.status == ApprovalStatus.rejected.name)
              .length;
        }

        return _buildDashboardCard(
          context,
          title: 'Jobs',
          icon: Icons.work,
          color: AppColors.secondary,
          pendingCount: pendingCount,
          approvedCount: approvedCount,
          rejectedCount: rejectedCount,
          onTap: () => context.go('/jobs'),
        );
      },
    );
  }
  */

  // Commented out - using News feature only
  /*
  Widget _buildAdvertisementsCard(BuildContext context) {
    return BlocBuilder<AdvertisementBloc, AdvertisementState>(
      builder: (context, state) {
        int pendingCount = 0;
        int approvedCount = 0;
        int rejectedCount = 0;

        if (state is AdvertisementLoaded) {
          pendingCount = state.advertisements
              .where((item) => item.status == ApprovalStatus.pending.name)
              .length;
          approvedCount = state.advertisements
              .where((item) => item.status == ApprovalStatus.approved.name)
              .length;
          rejectedCount = state.advertisements
              .where((item) => item.status == ApprovalStatus.rejected.name)
              .length;
        }

        return _buildDashboardCard(
          context,
          title: 'Advertisements',
          icon: Icons.ad_units,
          color: const Color(0xFFFFA000),
          pendingCount: pendingCount,
          approvedCount: approvedCount,
          rejectedCount: rejectedCount,
          onTap: () => context.go('/advertisements'),
        );
      },
    );
  }
  */

  // Commented out - using News feature only
  /*
  Widget _buildMatrimonyCard(BuildContext context) {
    return BlocBuilder<MatrimonyBloc, MatrimonyState>(
      builder: (context, state) {
        int pendingCount = 0;
        int approvedCount = 0;
        int rejectedCount = 0;

        if (state is MatrimonyLoaded) {
          pendingCount = state.profiles
              .where((item) => item.status == ApprovalStatus.pending.name)
              .length;
          approvedCount = state.profiles
              .where((item) => item.status == ApprovalStatus.approved.name)
              .length;
          rejectedCount = state.profiles
              .where((item) => item.status == ApprovalStatus.rejected.name)
              .length;
        }

        return _buildDashboardCard(
          context,
          title: 'Matrimony',
          icon: Icons.favorite,
          color: const Color(0xFFF44336),
          pendingCount: pendingCount,
          approvedCount: approvedCount,
          rejectedCount: rejectedCount,
          onTap: () => context.go('/matrimony'),
        );
      },
    );
  }
  */

  Widget _buildModernDashboardCard(
    BuildContext context, {
    required NewsProvider newsProvider,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/news'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[500]!, Colors.blue[600]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.article_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'News Management',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: ${newsProvider.news.length} articles',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Statistics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildModernStatusCard(
                        'Pending',
                        newsProvider.pendingCount,
                        Colors.orange[400]!,
                        Icons.schedule_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernStatusCard(
                        'Approved',
                        newsProvider.approvedCount,
                        Colors.green[400]!,
                        Icons.check_circle_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernStatusCard(
                        'Rejected',
                        newsProvider.rejectedCount,
                        Colors.red[400]!,
                        Icons.cancel_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[50]!, Colors.blue[100]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Manage All News',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatusCard(
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// Define the unique element ID for the browser's DOM
const String dunsElementId = 'duns-trust-badge-iframe';

class DunsTrustBadge extends StatelessWidget {
  const DunsTrustBadge({super.key});

  // The actual HTML iframe code
  static const String htmlContent =
      "<iframe id='Iframe1' src='https://dunsregistered.dnb.com/SealAuthentication.aspx?Cid=1' " +
      "width='114px' height='97px' frameborder='0' scrolling='no' allowtransparency='true' ></iframe>";

  @override
  Widget build(BuildContext context) {
    // We register the HTML element once.
    // This part of the code needs to check if it's running on the web
    if (web.window.document.getElementById(dunsElementId) == null) {
      // 1. Create a container element (a <div>)
      final div = web.document.createElement('div');
      div.id = dunsElementId;

      // 2. Set its inner HTML to be the iframe code
      div.innerHTML = htmlContent;

      // 3. Append the element to the body of the HTML document
      web.document.body?.appendChild(div);
    }

    // We render a placeholder in Flutter's widget tree
    // The actual content is rendered by the browser into the HTML body.
    return const SizedBox(
      width: 114,
      height: 97,
      // Note: We use a placeholder here. We no longer use HtmlElementView.
      child: Center(
        child: Text('D&B Trust Seal', style: TextStyle(fontSize: 10)),
      ),
    );
  }
}
