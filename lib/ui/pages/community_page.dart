import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../community/models.dart' as community;
import '../../models/post.dart';
import '../../models/user_profile.dart' as app_profile;
import '../../providers/community_feed_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/community/community_feed_service.dart';
import '../responsive.dart';
import '../theme.dart';
import '../widgets/post_card.dart';
import '../widgets/post_comments_sheet.dart';
import 'community/events_tab.dart';
import 'community/news_tab.dart';
import 'community/trending_tab.dart';
import 'industry_selection_page.dart';
import 'user_profile_detail_page.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  static void showCreateOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => CommunityComposerSheet(
        service: ref.read(communityFeedServiceProvider),
      ),
    );
  }

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage>
    with SingleTickerProviderStateMixin {
  final _search = TextEditingController();
  final _composer = TextEditingController();
  final List<_PendingImage> _pendingImages = [];
  bool _posting = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(communityFeedSeedProvider); // ensure dev data exists
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => CommunityPage.showCreateOptionsMenu(context, ref),
        backgroundColor: AppColors.purple,
        child: const Icon(Icons.add),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: Responsive.heroHeight(context),
            pinned: true,
            backgroundColor: scheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroHeader(context),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: scheme.primary,
                unselectedLabelColor: scheme.onSurfaceVariant,
                indicatorColor: scheme.primary,
                tabs: const [
                  Tab(text: 'Feed'),
                  Tab(text: 'Trending'),
                  Tab(text: 'Events'),
                  Tab(text: 'Business News'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFeedTab(),
            const TrendingTab(),
            const EventsTab(),
            const NewsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.gradientPurple),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const IndustrySelectionPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Connect, share and grow together',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.white70),
              ),
              Text(
                'Community',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('2.5K', 'Members', Icons.people),
                    Container(width: 1, height: 24, color: Colors.white30),
                    _buildStatItem('450', 'Posts', Icons.article),
                    Container(width: 1, height: 24, color: Colors.white30),
                    _buildStatItem(
                      '15',
                      'Active Now',
                      Icons.circle,
                      activeColor: Colors.greenAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    final currentUser = ref.watch(userProfileProvider);
    final feedAsync = ref.watch(communityFeedProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(communityFeedProvider);
        await ref.read(communityFeedProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search posts and people...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _buildComposer(currentUser),
          if (_pendingImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSelectedImages(),
          ],
          const SizedBox(height: 16),
          _buildSuggestedConnections(),
          const SizedBox(height: 16),
          feedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Could not load feed: $error'),
            ),
            data: (posts) {
              final filtered = _filterPosts(posts);
              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No posts yet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to share something meaningful.',
                        style: TextStyle(color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: filtered
                    .map(
                      (post) => PostCard(
                        post: post,
                        onOpenComments: () => _openComments(post),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Post> _filterPosts(List<Post> posts) {
    if (_search.text.trim().isEmpty) return posts;
    final query = _search.text.trim().toLowerCase();
    return posts.where((post) {
      final matchText = (post.text ?? '').toLowerCase().contains(query);
      final matchAuthor = post.authorName.toLowerCase().contains(query);
      return matchText || matchAuthor;
    }).toList();
  }

  Widget _buildComposer(app_profile.UserProfile? currentUser) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.purple.withValues(alpha: 0.1),
                  backgroundImage: currentUser?.photoUrl != null
                      ? NetworkImage(currentUser!.photoUrl!)
                      : null,
                  child: currentUser?.photoUrl == null
                      ? Text(
                          currentUser?.name.isNotEmpty == true
                              ? currentUser!.name[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _composer,
                    decoration: const InputDecoration(
                      hintText: 'Share your thoughts...',
                      border: InputBorder.none,
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _pendingImages.length >= 4 ? null : _pickImages,
                    icon: const Icon(Icons.image, size: 20),
                    label: const Text('Photo'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.videocam_off, size: 20),
                    label: const Text('Video (soon)'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade400,
                    ),
                  ),
                ),
                _posting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : ElevatedButton(
                        onPressed: _submitPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Post'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImages() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _pendingImages.asMap().entries.map((entry) {
        final index = entry.key;
        final pending = entry.value;
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                pending.preview,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => setState(() => _pendingImages.removeAt(index)),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSuggestedConnections() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Suggested Connections',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: null,
                  child: Text(
                    'See all',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<community.UserProfile>>(
              stream: ref.read(peopleRepositoryProvider).suggested(limit: 3),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final profiles = snapshot.data ?? [];
                if (profiles.isEmpty) {
                  return const Text('No suggestions right now.');
                }

                return Column(
                  children: profiles.map((user) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: user.photoURL.isNotEmpty
                            ? NetworkImage(user.photoURL)
                            : null,
                        child: user.photoURL.isEmpty
                            ? Text(
                                user.displayName.isNotEmpty
                                    ? user.displayName[0].toUpperCase()
                                    : '?',
                              )
                            : null,
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(
                        user.headline.isNotEmpty
                            ? user.headline
                            : 'No headline provided',
                      ),
                      trailing: _ConnectionButton(userId: user.uid),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => UserProfileDetailPage(
                              profile: _mapCommunityProfile(user),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;

    setState(() {
      final availableSlots = 4 - _pendingImages.length;
      for (final file in result.files.take(availableSlots)) {
        final bytes = file.bytes;
        if (bytes != null) {
          _pendingImages.add(_PendingImage(file: file, preview: bytes));
        }
      }
    });
  }

  Future<void> _submitPost() async {
    final service = ref.read(communityFeedServiceProvider);
    final text = _composer.text.trim();
    if (text.isEmpty && _pendingImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add text or at least one image.')),
      );
      return;
    }
    setState(() => _posting = true);
    try {
      await service.createPost(
        text: text.isEmpty ? null : text,
        images: _pendingImages.map((e) => e.file).toList(),
      );
      _composer.clear();
      _pendingImages.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posted successfully! 🎉')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  void _openComments(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: PostCommentsSheet(post: post),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon, {
    Color? activeColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: activeColor ?? Colors.white),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}

class CommunityComposerSheet extends StatefulWidget {
  const CommunityComposerSheet({super.key, required this.service});

  final CommunityFeedService service;

  @override
  State<CommunityComposerSheet> createState() => _CommunityComposerSheetState();
}

class _CommunityComposerSheetState extends State<CommunityComposerSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<_PendingImage> _images = [];
  bool _posting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Share an update',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'What’s on your mind?',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 6,
              ),
              const SizedBox(height: 12),
              if (_images.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _images.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pending = entry.value;
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            pending.preview,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _images.removeAt(index)),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _images.length >= 4 ? null : _pickImages,
                    icon: const Icon(Icons.image),
                    label: const Text('Photo'),
                  ),
                  const Spacer(),
                  _posting
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Post'),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    setState(() {
      final availableSlots = 4 - _images.length;
      for (final file in result.files.take(availableSlots)) {
        final bytes = file.bytes;
        if (bytes != null) {
          _images.add(_PendingImage(file: file, preview: bytes));
        }
      }
    });
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _images.isEmpty) return;
    setState(() => _posting = true);
    try {
      await widget.service.createPost(
        text: text.isEmpty ? null : text,
        images: _images.map((e) => e.file).toList(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }
}

class _PendingImage {
  _PendingImage({required this.file, required this.preview});

  final PlatformFile file;
  final Uint8List preview;
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          if (shrinkOffset > 0)
            const BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
        ],
      ),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

class _ConnectionButton extends ConsumerStatefulWidget {
  const _ConnectionButton({required this.userId});

  final String userId;

  @override
  ConsumerState<_ConnectionButton> createState() => _ConnectionButtonState();
}

class _ConnectionButtonState extends ConsumerState<_ConnectionButton> {
  bool _loading = false;
  bool _requestSent = false;

  @override
  Widget build(BuildContext context) {
    if (_requestSent) {
      return OutlinedButton(onPressed: null, child: const Text('Pending'));
    }

    return OutlinedButton(
      onPressed: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              try {
                await ref
                    .read(peopleRepositoryProvider)
                    .sendRequest(widget.userId);
                setState(() {
                  _requestSent = true;
                });
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
      child: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Connect'),
    );
  }
}

app_profile.UserProfile _mapCommunityProfile(community.UserProfile profile) {
  return app_profile.UserProfile(
    id: profile.uid,
    name: profile.displayName,
    email: '${profile.uid}@community.wazeet',
    title: profile.headline,
    photoUrl: profile.photoURL,
    industries: profile.industries,
    bio: profile.location,
    isVerified: profile.isDiscoverable,
  );
}
