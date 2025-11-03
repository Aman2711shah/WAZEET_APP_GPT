import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/post.dart';
import '../../models/event.dart';
import '../../models/business_news.dart';
import '../../providers/community_posts_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/event_service.dart';
import '../../services/business_news_service.dart';
import '../theme.dart';
import '../widgets/post_card.dart';
import 'industry_selection_page.dart';
import 'user_profile_detail_page.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});
  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();

  // Static method to show create options from anywhere
  // Static method that can be called from main_nav or anywhere else
  static void showCreateOptionsMenu(BuildContext context, WidgetRef ref) {
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
                  _showArticleEditor(context, ref);
                },
              ),
              ListTile(
                leading: Icon(Icons.poll, color: AppColors.purple),
                title: const Text('Create a poll'),
                onTap: () {
                  Navigator.pop(context);
                  _showPollCreator(context, ref);
                },
              ),
              ListTile(
                leading: Icon(Icons.event, color: AppColors.purple),
                title: const Text('Create an event'),
                onTap: () {
                  Navigator.pop(context);
                  _showEventCreator(context, ref);
                },
              ),
              ListTile(
                leading: Icon(Icons.image, color: AppColors.purple),
                title: const Text('Share a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _showPhotoShare(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Static helper methods to show dialogs
  static void _showArticleEditor(BuildContext context, WidgetRef ref) {
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

  static void _showPollCreator(BuildContext context, WidgetRef ref) {
    // Poll creator implementation - I'll add a placeholder for now
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Poll creator coming soon!')));
  }

  static void _showEventCreator(BuildContext context, WidgetRef ref) {
    // Event creator implementation - I'll add a placeholder for now
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Event creator coming soon!')));
  }

  static void _showPhotoShare(BuildContext context, WidgetRef ref) {
    // Photo share implementation - I'll add a placeholder for now
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Photo share coming soon!')));
  }
}

class _CommunityPageState extends ConsumerState<CommunityPage>
    with SingleTickerProviderStateMixin {
  final _search = TextEditingController();
  final _composer = TextEditingController();
  bool _posting = false;
  late TabController _tabController;
  String _newsIndustry = 'All Industries';

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
                        '📊 ${questionController.text}\n\n${options.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}';

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
                          '🎉 ${titleController.text}\n\n${descriptionController.text.trim().isNotEmpty ? '${descriptionController.text}\n\n' : ''}📍 ${locationController.text.trim().isNotEmpty ? locationController.text : "TBA"}\n📅 ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at ${selectedTime.format(context)}';

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
                          color: AppColors.purple.withValues(alpha: 0.3),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            AppColors.purple.withValues(alpha: 0.85),
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
                          color: Colors.white.withValues(alpha: 0.95),
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
                      color: Colors.black.withValues(alpha: 0.05),
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
                  indicator: _UnderlineGradientIndicator(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.purple,
                        AppColors.purple.withValues(alpha: 0.7),
                      ],
                    ),
                    thickness: 3,
                    radius: 2,
                  ),
                  tabs: const [
                    Tab(text: 'Feed'),
                    Tab(text: 'Trending'),
                    Tab(text: 'Events'),
                    Tab(text: 'Business News'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFeedTab(),
            _buildTrendingTab(),
            _buildEventsTab(),
            _buildBusinessNewsTab(),
          ],
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
                        backgroundColor: AppColors.purple.withValues(
                          alpha: 0.1,
                        ),
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
                      backgroundColor: AppColors.purple.withValues(alpha: 0.1),
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
                    color: AppColors.purple.withValues(alpha: 0.1),
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
                  backgroundColor: AppColors.purple.withValues(alpha: 0.1),
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
    final upcomingEventsAsync = ref.watch(upcomingEventsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Upcoming Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // Refresh events
                  ref.invalidate(upcomingEventsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshing events...')),
                  );
                },
                icon: Icon(Icons.refresh, color: AppColors.purple),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Discover business networking events, workshops, and conferences in Dubai',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Events Stream
          upcomingEventsAsync.when(
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: CircularProgressIndicator(color: AppColors.purple),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            data: (events) {
              if (events.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No upcoming events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back soon for new events!',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  ...events.map((event) => _buildDiscoveredEventCard(event)),
                  const SizedBox(height: 24),
                  Text(
                    'Showing ${events.length} upcoming ${events.length == 1 ? "event" : "events"}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Events are automatically discovered and updated daily',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessNewsTab() {
    final industries = const [
      'All Industries',
      'Technology',
      'Finance',
      'Real Estate',
      'Healthcare',
      'Energy',
      'Construction',
      'Retail',
      'Logistics',
    ];

    final newsAsync = ref.watch(
      businessNewsByIndustryProvider(
        _newsIndustry == 'All Industries' ? null : _newsIndustry,
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Global Business News',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<String>(
                    value: _newsIndustry,
                    alignment: Alignment.centerRight,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _newsIndustry = value);
                    },
                    items: industries
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Top Stories carousel (optional bonus)
          newsAsync.when(
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppColors.purple),
              ),
            ),
            error: (e, _) => _buildNewsError(e.toString()),
            data: (items) {
              final top = items.take(5).toList();
              if (top.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Stories Today',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 140,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.9),
                      itemCount: top.length,
                      itemBuilder: (context, index) {
                        final n = top[index];
                        return _buildTopStoryCard(n);
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // News list
          newsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.newspaper,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No news for this industry',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  ...items.map(_buildNewsCard),
                  const SizedBox(height: 8),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Placeholder: In real integration, paginate and fetch next page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Loading more news...')),
                        );
                      },
                      icon: const Icon(Icons.expand_more),
                      label: const Text('See More News'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.purple,
                        side: BorderSide(color: AppColors.purple),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Failed to load news',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStoryCard(BusinessNewsItem n) {
    return Card(
      margin: const EdgeInsets.only(right: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final url = Uri.parse(n.url);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: Row(
          children: [
            if (n.thumbnailUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
                child: Image.network(
                  n.thumbnailUrl!,
                  width: 120,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _industryTag(n.industry),
                    const SizedBox(height: 8),
                    Text(
                      n.headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (n.logoUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: CircleAvatar(
                              radius: 8,
                              backgroundImage: NetworkImage(n.logoUrl!),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        Text(
                          '${n.source} • ${n.timeAgo}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  Widget _buildNewsCard(BusinessNewsItem n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final url = Uri.parse(n.url);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _industryTag(n.industry),
                    const SizedBox(height: 8),
                    Text(
                      n.headline,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (n.logoUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: CircleAvatar(
                              radius: 8,
                              backgroundImage: NetworkImage(n.logoUrl!),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        Text(
                          '${n.source} • ${n.timeAgo}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (n.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    n.thumbnailUrl!,
                    width: 86,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _industryTag(String label) {
    final color = _industryColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _industryColor(String label) {
    switch (label.toLowerCase()) {
      case 'technology':
        return Colors.indigo;
      case 'finance':
        return Colors.green.shade700;
      case 'real estate':
        return Colors.brown;
      case 'healthcare':
        return Colors.red.shade600;
      case 'energy':
        return Colors.orange.shade700;
      case 'construction':
        return Colors.blueGrey;
      case 'retail':
        return Colors.pink.shade600;
      case 'logistics':
        return Colors.teal.shade700;
      default:
        return AppColors.purple;
    }
  }

  Widget _buildDiscoveredEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      event.category,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getCategoryColor(
                        event.category,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(event.category),
                        size: 14,
                        color: _getCategoryColor(event.category),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.category,
                        style: TextStyle(
                          color: _getCategoryColor(event.category),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (event.isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'TODAY',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Event Title
            Text(
              event.eventName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Description
            if (event.description.isNotEmpty)
              Text(
                event.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),

            // Date & Time
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  event.formattedDate,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (event.time != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    event.time!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.location.displayText,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Action Row
            Row(
              children: [
                if (event.attendees > 0) ...[
                  Icon(Icons.people, size: 16, color: AppColors.purple),
                  const SizedBox(width: 6),
                  Text(
                    '${event.attendees} attending',
                    style: TextStyle(
                      color: AppColors.purple,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(event.sourceURL);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open event link'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.purple,
                    side: BorderSide(color: AppColors.purple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'networking':
        return Colors.blue;
      case 'workshop':
        return Colors.orange;
      case 'conference':
        return Colors.purple;
      case 'competition':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'networking':
        return Icons.people_alt;
      case 'workshop':
        return Icons.school;
      case 'conference':
        return Icons.groups;
      case 'competition':
        return Icons.emoji_events;
      default:
        return Icons.event;
    }
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

/// Gradient underline indicator for TabBar
class _UnderlineGradientIndicator extends Decoration {
  final Gradient gradient;
  final double thickness;
  final double radius;

  const _UnderlineGradientIndicator({
    required this.gradient,
    this.thickness = 2,
    this.radius = 0,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _UnderlineGradientPainter(this, onChanged);
  }
}

class _UnderlineGradientPainter extends BoxPainter {
  final _UnderlineGradientIndicator decoration;

  _UnderlineGradientPainter(this.decoration, VoidCallback? onChanged)
    : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & configuration.size!;
    final lineRect = Rect.fromLTWH(
      rect.left + 16,
      rect.bottom - decoration.thickness - 6,
      rect.width - 32,
      decoration.thickness,
    );

    final rrect = RRect.fromRectAndRadius(
      lineRect,
      Radius.circular(decoration.radius),
    );
    final paint = Paint()
      ..shader = decoration.gradient.createShader(lineRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, paint);
  }
}
