import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../theme.dart';

enum ProfileViewType { individual, company }

class UserProfileDetailPage extends ConsumerStatefulWidget {
  final UserProfile profile;
  const UserProfileDetailPage({super.key, required this.profile});

  @override
  ConsumerState<UserProfileDetailPage> createState() =>
      _UserProfileDetailPageState();
}

class _UserProfileDetailPageState extends ConsumerState<UserProfileDetailPage> {
  ProfileViewType _view = ProfileViewType.individual;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Cover & Profile Image Section
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.purple,
                          AppColors.purple.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Profile Image
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: profile.photoUrl != null
                            ? NetworkImage(profile.photoUrl!)
                            : null,
                        child: profile.photoUrl == null
                            ? Text(
                                profile.initials,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.purple,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  // Verified Badge
                  if (profile.isVerified)
                    Positioned(
                      bottom: 16,
                      left: 96,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile type segmented toggle
                  SegmentedButton<ProfileViewType>(
                    segments: const [
                      ButtonSegment(
                        value: ProfileViewType.individual,
                        icon: Icon(Icons.person_outline),
                        label: Text('Individual'),
                      ),
                      ButtonSegment(
                        value: ProfileViewType.company,
                        icon: Icon(Icons.apartment_outlined),
                        label: Text('Company'),
                      ),
                    ],
                    selected: <ProfileViewType>{_view},
                    onSelectionChanged: (s) => setState(() => _view = s.first),
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Animated switch between views
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _view == ProfileViewType.individual
                        ? _IndividualProfileView(
                            key: const ValueKey('ind'),
                            profile: profile,
                          )
                        : _CompanyProfileView(
                            key: const ValueKey('co'),
                            profile: profile,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndividualProfileView extends StatelessWidget {
  final UserProfile profile;
  const _IndividualProfileView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name & Title
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (profile.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  if (profile.title != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.title!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  if (profile.company != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      profile.company!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        if (profile.location != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                profile.location!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Connected with ${profile.name}')),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Connect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message feature coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.message),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  side: BorderSide(color: AppColors.purple),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile link copied')),
                  );
                },
                icon: const Icon(Icons.ios_share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  side: BorderSide(color: AppColors.purple),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Stats
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Connections',
                  profile.connectionsCount.toString(),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildStatColumn(
                  'Followers',
                  profile.followersCount.toString(),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildStatColumn('Posts', profile.postsCount.toString()),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Bio
        if (profile.bio != null) ...[
          const Text(
            'About Me',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                profile.bio!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Industries
        if (profile.industries.isNotEmpty) ...[
          const Text(
            'Industries',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.industries.map((industryId) {
                  final industry = availableIndustries.firstWhere(
                    (i) => i.id == industryId,
                    orElse: () => Industry(
                      id: industryId,
                      name: industryId,
                      icon: '📊',
                      description: '',
                    ),
                  );
                  return Chip(
                    avatar: Text(industry.icon),
                    label: Text(industry.name),
                    backgroundColor: AppColors.purple.withOpacity(0.1),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Skills
        if (profile.skills.isNotEmpty) ...[
          const Text(
            'Skills',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.skills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Contact Info
        const Text(
          'Contact Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              if (profile.email.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.email, color: AppColors.purple),
                  title: const Text('Email'),
                  subtitle: Text(profile.email),
                ),
              if (profile.phone != null)
                ListTile(
                  leading: Icon(Icons.phone, color: AppColors.purple),
                  title: const Text('Phone'),
                  subtitle: Text(profile.phone!),
                ),
              if (profile.websiteUrl != null)
                ListTile(
                  leading: Icon(Icons.language, color: AppColors.purple),
                  title: const Text('Website'),
                  subtitle: Text(profile.websiteUrl!),
                ),
              if (profile.linkedInUrl != null)
                ListTile(
                  leading: Icon(Icons.link, color: AppColors.purple),
                  title: const Text('LinkedIn'),
                  subtitle: Text(profile.linkedInUrl!),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Member Since
        if (profile.joinedDate != null)
          Center(
            child: Text(
              'Member since ${_formatDate(profile.joinedDate!)}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _CompanyProfileView extends StatelessWidget {
  final UserProfile profile;
  const _CompanyProfileView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header info: logo, name, tagline
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                image: profile.companyLogoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(profile.companyLogoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profile.companyLogoUrl == null
                  ? Center(
                      child: Text(
                        (profile.company ?? 'Co')[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        profile.company ?? 'Company',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (profile.isVerified)
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 20,
                        ),
                    ],
                  ),
                  if (profile.companyTagline != null)
                    Text(
                      profile.companyTagline!,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Buttons: Follow, Message, Share
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Follow'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.message_outlined),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  side: BorderSide(color: AppColors.purple),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.ios_share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  side: BorderSide(color: AppColors.purple),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Company facts card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv(
                  context,
                  'Industry',
                  profile.industries.isNotEmpty
                      ? profile.industries.join(', ')
                      : '—',
                ),
                const SizedBox(height: 8),
                _kv(context, 'Company Size', profile.companySize ?? '—'),
                const SizedBox(height: 8),
                _kv(context, 'Founded', profile.companyFounded ?? '—'),
                const SizedBox(height: 8),
                _kv(
                  context,
                  'Headquarters',
                  profile.companyHeadquarters ?? profile.location ?? '—',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // About Company
        if (profile.bio != null) ...[
          const Text(
            'About Company',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                profile.bio!,
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Team members (placeholder)
        const Text(
          'Team Members',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final initials = ['DC', 'AL', 'MS', 'RK', 'SJ'][index % 5];
              return Column(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.purple.withOpacity(0.15),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Member ${index + 1}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: 8,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(k, style: TextStyle(color: Colors.grey.shade600)),
        ),
        Expanded(
          child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
