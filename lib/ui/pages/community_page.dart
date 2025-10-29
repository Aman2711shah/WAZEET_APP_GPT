import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/post.dart';
import '../../providers/community_posts_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../theme.dart';
import '../widgets/post_card.dart';
import 'industry_selection_page.dart';
import 'user_profile_detail_page.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});
  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage>
    with SingleTickerProviderStateMixin {
  final _search = TextEditingController();
  final _composer = TextEditingController();
  bool _posting = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    _composer.dispose();
    super.dispose();
  }

  void _submitPost() {
    if (_composer.text.trim().isEmpty) return;

    setState(() => _posting = true);

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'demo_user',
      userName: 'David Chen',
      userTitle: 'Entrepreneur | WAZEET Founder',
      content: _composer.text.trim(),
      createdAt: DateTime.now(),
      likesCount: 0,
      commentsCount: 0,
      sharesCount: 0,
      likedBy: [],
    );

    ref.read(communityPostsProvider.notifier).addPost(newPost);
    _composer.clear();

    setState(() => _posting = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Posted successfully! 🎉')));
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.article, color: AppColors.purple),
                title: const Text('Write an article'),
                onTap: () {
                  Navigator.pop(context);
                  _showArticleEditor();
                },
              ),
              ListTile(
                leading: Icon(Icons.poll, color: AppColors.purple),
                title: const Text('Create a poll'),
                onTap: () {
                  Navigator.pop(context);
                  _showPollCreator();
                },
              ),
              ListTile(
                leading: Icon(Icons.event, color: AppColors.purple),
                title: const Text('Create an event'),
                onTap: () {
                  Navigator.pop(context);
                  _showEventCreator();
                },
              ),
              ListTile(
                leading: Icon(Icons.image, color: AppColors.purple),
                title: const Text('Share a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _showPhotoShare();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showArticleEditor() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.article, color: AppColors.purple),
                  const SizedBox(width: 12),
                  const Text(
                    'Write an Article',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Article Title',
                  hintText: 'Enter a catchy title...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Write your article here...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        contentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                        ),
                      );
                      return;
                    }

                    final newPost = Post(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: 'demo_user',
                      userName: 'David Chen',
                      userTitle: 'Entrepreneur | WAZEET Founder',
                      content:
                          '📝 ${titleController.text}\n\n${contentController.text}',
                      createdAt: DateTime.now(),
                      likesCount: 0,
                      commentsCount: 0,
                      imageUrl: null,
                    );

                    ref.read(communityPostsProvider.notifier).addPost(newPost);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Article published! 📝')),
                    );
                  },
                  icon: const Icon(Icons.publish),
                  label: const Text('Publish Article'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPollCreator() {
    final questionController = TextEditingController();
    final option1Controller = TextEditingController();
    final option2Controller = TextEditingController();
    final option3Controller = TextEditingController();
    final option4Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.poll, color: AppColors.purple),
                  const SizedBox(width: 12),
                  const Text(
                    'Create a Poll',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Poll Question',
                  hintText: 'Ask something...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: option1Controller,
                decoration: const InputDecoration(
                  labelText: 'Option 1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: option2Controller,
                decoration: const InputDecoration(
                  labelText: 'Option 2',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: option3Controller,
                decoration: const InputDecoration(
                  labelText: 'Option 3 (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: option4Controller,
                decoration: const InputDecoration(
                  labelText: 'Option 4 (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (questionController.text.trim().isEmpty ||
                        option1Controller.text.trim().isEmpty ||
                        option2Controller.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter question and at least 2 options',
                          ),
                        ),
                      );
                      return;
                    }

                    final options = <String>[
                      option1Controller.text.trim(),
                      option2Controller.text.trim(),
                      if (option3Controller.text.trim().isNotEmpty)
                        option3Controller.text.trim(),
                      if (option4Controller.text.trim().isNotEmpty)
                        option4Controller.text.trim(),
                    ];

                    final pollContent =
                        '📊 ${questionController.text}\n\n' +
                        options
                            .asMap()
                            .entries
                            .map((e) => '${e.key + 1}. ${e.value}')
                            .join('\n');

                    final newPost = Post(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: 'demo_user',
                      userName: 'David Chen',
                      userTitle: 'Entrepreneur | WAZEET Founder',
                      content: pollContent,
                      createdAt: DateTime.now(),
                      likesCount: 0,
                      commentsCount: 0,
                      imageUrl: null,
                    );

                    ref.read(communityPostsProvider.notifier).addPost(newPost);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Poll created! 📊')),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Create Poll'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventCreator() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.event, color: AppColors.purple),
                    const SizedBox(width: 12),
                    const Text(
                      'Create an Event',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    hintText: 'Enter event name...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is this event about?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Where will it take place?',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setDialogState(() => selectedDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setDialogState(() => selectedTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter event title'),
                          ),
                        );
                        return;
                      }

                      final eventContent =
                          '🎉 ${titleController.text}\n\n' +
                          (descriptionController.text.trim().isNotEmpty
                              ? '${descriptionController.text}\n\n'
                              : '') +
                          '📍 ${locationController.text.trim().isNotEmpty ? locationController.text : "TBA"}\n' +
                          '📅 ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at ${selectedTime.format(context)}';

                      final newPost = Post(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: 'demo_user',
                        userName: 'David Chen',
                        userTitle: 'Entrepreneur | WAZEET Founder',
                        content: eventContent,
                        createdAt: DateTime.now(),
                        likesCount: 0,
                        commentsCount: 0,
                        imageUrl: null,
                      );

                      ref
                          .read(communityPostsProvider.notifier)
                          .addPost(newPost);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event created! 🎉')),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Create Event'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPhotoShare() {
    final captionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.image, color: AppColors.purple),
                  const SizedBox(width: 12),
                  const Text(
                    'Share a Photo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Click to select photo',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '(Photo picker coming soon)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: captionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  hintText: 'Write something about this photo...',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (captionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please add a caption')),
                      );
                      return;
                    }

                    final newPost = Post(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: 'demo_user',
                      userName: 'David Chen',
                      userTitle: 'Entrepreneur | WAZEET Founder',
                      content: '📷 ${captionController.text}',
                      createdAt: DateTime.now(),
                      likesCount: 0,
                      commentsCount: 0,
                      imageUrl:
                          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800',
                    );

                    ref.read(communityPostsProvider.notifier).addPost(newPost);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo shared! 📷')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              floating: false,
              backgroundColor: AppColors.purple,
              actions: [
                // Industry Selection Button
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IndustrySelectionPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.filter_list),
                  color: Colors.white,
                  tooltip: 'Filter by Industry',
                ),
                // My Profile Button
                if (currentUser != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileDetailPage(profile: currentUser),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        backgroundImage: currentUser.photoUrl != null
                            ? NetworkImage(currentUser.photoUrl!)
                            : null,
                        child: currentUser.photoUrl == null
                            ? Text(
                                currentUser.initials,
                                style: TextStyle(
                                  color: AppColors.purple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Community',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.purple.withOpacity(0.3),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            AppColors.purple.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 56,
                      child: Text(
                        'Connect, share and grow together',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Stats Banner
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('2.5K', 'Members', Icons.people),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _buildStatItem('450', 'Posts', Icons.article),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        '15',
                        'Active Now',
                        Icons.circle,
                        activeColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tabs
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.purple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.purple,
                  tabs: const [
                    Tab(text: 'Feed'),
                    Tab(text: 'Trending'),
                    Tab(text: 'Events'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [_buildFeedTab(), _buildTrendingTab(), _buildEventsTab()],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPostOptions,
        backgroundColor: AppColors.purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
            Icon(icon, size: 16, color: activeColor ?? AppColors.purple),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: activeColor ?? Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildFeedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
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

          // Quick Composer
          Card(
            elevation: 0,
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
                        backgroundColor: AppColors.purple.withOpacity(0.1),
                        child: Text(
                          'D',
                          style: TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Photo upload coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.image, size: 20),
                          label: const Text('Photo'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Video upload coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.videocam, size: 20),
                          label: const Text('Video'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
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
          ),
          const SizedBox(height: 16),

          // Suggested Connections
          _buildSuggestedConnections(),
          const SizedBox(height: 16),

          // Feed
          Consumer(
            builder: (context, ref, child) {
              final posts = ref.watch(communityPostsProvider);

              final filteredPosts = _search.text.isEmpty
                  ? posts
                  : posts
                        .where(
                          (post) =>
                              post.content.toLowerCase().contains(
                                _search.text.toLowerCase(),
                              ) ||
                              post.userName.toLowerCase().contains(
                                _search.text.toLowerCase(),
                              ),
                        )
                        .toList();

              if (filteredPosts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share something!',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: filteredPosts
                    .map((post) => PostCard(post: post))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedConnections() {
    final suggestions = [
      {
        'name': 'Sarah Al Mansouri',
        'title': 'Business Consultant',
        'mutual': '12',
      },
      {'name': 'Ahmed Hassan', 'title': 'Legal Advisor', 'mutual': '8'},
      {'name': 'Maria Garcia', 'title': 'Marketing Expert', 'mutual': '15'},
    ];

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
                  onPressed: () {},
                  child: Text(
                    'See all',
                    style: TextStyle(color: AppColors.purple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...suggestions.map(
              (person) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.purple.withOpacity(0.1),
                      child: Text(
                        person['name']![0],
                        style: TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            person['title']!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${person['mutual']} mutual connections',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Connected with ${person['name']}!'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.purple,
                        side: BorderSide(color: AppColors.purple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Connect'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingTab() {
    final trendingTopics = [
      {'tag': '#DubaiStartup', 'posts': '1.2K', 'trend': 'up'},
      {'tag': '#UAEBusiness', 'posts': '850', 'trend': 'up'},
      {'tag': '#GoldenVisa', 'posts': '620', 'trend': 'up'},
      {'tag': '#FreelanceUAE', 'posts': '450', 'trend': 'stable'},
      {'tag': '#DubaiInvestor', 'posts': '380', 'trend': 'up'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Topics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...trendingTopics.map(
            (topic) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.tag, color: AppColors.purple, size: 20),
                ),
                title: Text(
                  topic['tag']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${topic['posts']} posts'),
                trailing: Icon(
                  topic['trend'] == 'up'
                      ? Icons.trending_up
                      : Icons.trending_flat,
                  color: topic['trend'] == 'up' ? Colors.green : Colors.grey,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viewing ${topic['tag']}')),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Popular This Week',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildPopularPost(
            'Starting a Business in Dubai: Complete Guide',
            'Ahmed Hassan',
            '2.5K views',
            '145 reactions',
          ),
          _buildPopularPost(
            'Golden Visa Application Tips',
            'Sarah Al Mansouri',
            '1.8K views',
            '98 reactions',
          ),
          _buildPopularPost(
            'Free Zone vs Mainland: Which is Better?',
            'Maria Garcia',
            '1.5K views',
            '87 reactions',
          ),
        ],
      ),
    );
  }

  Widget _buildPopularPost(
    String title,
    String author,
    String views,
    String reactions,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.purple.withOpacity(0.1),
                  child: Text(
                    author[0],
                    style: TextStyle(
                      color: AppColors.purple,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  author,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.visibility, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  views,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.thumb_up, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  reactions,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    final events = [
      {
        'title': 'Dubai Business Networking Mixer',
        'date': 'Nov 5, 2025',
        'time': '6:00 PM',
        'location': 'DIFC, Dubai',
        'attendees': '45',
        'type': 'Networking',
      },
      {
        'title': 'VAT Compliance Workshop',
        'date': 'Nov 8, 2025',
        'time': '2:00 PM',
        'location': 'Virtual Event',
        'attendees': '120',
        'type': 'Workshop',
      },
      {
        'title': 'Startup Pitch Competition',
        'date': 'Nov 12, 2025',
        'time': '10:00 AM',
        'location': 'Dubai Internet City',
        'attendees': '200',
        'type': 'Competition',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Events',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...events.map((event) => _buildEventCard(event)),
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all events')),
                );
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('View All Events'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.purple,
                side: BorderSide(color: AppColors.purple),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, String> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event['type']!,
                    style: TextStyle(
                      color: AppColors.purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  event['date']!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  event['time']!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  event['location']!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppColors.purple),
                const SizedBox(width: 6),
                Text(
                  '${event['attendees']} attending',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Registered for ${event['title']}'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Delegate for sticky tab bar in NestedScrollView
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
