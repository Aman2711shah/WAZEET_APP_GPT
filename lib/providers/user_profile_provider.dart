import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

/// Provider for the current user profile
final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);

/// Notifier to manage user profile state
class UserProfileNotifier extends Notifier<UserProfile?> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  UserProfile? build() {
    _loadProfile();
    return null;
  }

  /// Load user profile from Firestore or create default
  Future<void> _loadProfile() async {
    try {
      final user = _auth.currentUser;

      // If no user is signed in, create a demo profile
      if (user == null) {
        state = UserProfile(
          id: 'demo_user',
          name: 'David Chen',
          email: 'david.chen@wazeet.com',
          title: 'Entrepreneur | WAZEET Founder',
          bio:
              'Building the future of business services in Dubai. Helping entrepreneurs navigate company setup, visa applications, and business growth.',
          phone: '+971 50 123 4567',
          company: 'WAZEET',
          location: 'Dubai, UAE',
          industries: ['tech', 'consulting', 'finance'],
          skills: [
            'Business Strategy',
            'Entrepreneurship',
            'Tech Startups',
            'Dubai Business Setup',
          ],
          interests: ['Innovation', 'Technology', 'UAE Market'],
          connectionsCount: 500,
          followersCount: 1250,
          postsCount: 87,
          joinedDate: DateTime(2023, 6, 1),
          isVerified: true,
        );
        return;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        state = UserProfile.fromJson({'id': user.uid, ...doc.data()!});
      } else {
        // Create default profile
        state = UserProfile(
          id: user.uid,
          name: user.displayName ?? user.email?.split('@').first ?? 'User',
          email: user.email ?? '',
          photoUrl: user.photoURL,
        );
        await _saveToFirestore();
      }
    } catch (e) {
      // Fallback to demo profile on any error
      state = UserProfile(
        id: 'demo_user',
        name: 'David Chen',
        email: 'david.chen@wazeet.com',
        title: 'Entrepreneur',
      );
    }
  }

  /// Update profile fields
  Future<void> updateProfile({
    String? name,
    String? email,
    String? title,
    String? bio,
    String? phone,
    String? countryCode,
    String? photoUrl,
    String? company,
    String? location,
    String? companyTagline,
    String? companySize,
    String? companyFounded,
    String? companyHeadquarters,
    String? companyLogoUrl,
    String? designation,
    String? qualification,
    List<String>? industries,
    List<String>? skills,
    List<String>? interests,
  }) async {
    if (state == null) return;

    state = state!.copyWith(
      name: name,
      email: email,
      title: title,
      bio: bio,
      phone: phone,
      countryCode: countryCode,
      photoUrl: photoUrl,
      company: company,
      location: location,
      companyTagline: companyTagline,
      companySize: companySize,
      companyFounded: companyFounded,
      companyHeadquarters: companyHeadquarters,
      companyLogoUrl: companyLogoUrl,
      designation: designation,
      qualification: qualification,
      industries: industries,
      skills: skills,
      interests: interests,
    );

    await _saveToFirestore();
  }

  /// Update user instance directly
  Future<void> updateUser(UserProfile user) async {
    state = user;
    await _saveToFirestore();
  }

  /// Update linked accounts
  Future<void> updateLinkedAccounts({
    String? linkedInUrl,
    String? twitterUrl,
    String? instagramUrl,
    String? websiteUrl,
  }) async {
    if (state == null) return;

    state = state!.copyWith(
      linkedInUrl: linkedInUrl,
      twitterUrl: twitterUrl,
      instagramUrl: instagramUrl,
      websiteUrl: websiteUrl,
    );

    await _saveToFirestore();
  }

  /// Update theme preference
  Future<void> setDarkMode(bool isDark) async {
    if (state == null) return;

    state = state!.copyWith(isDarkMode: isDark);
    await _saveToFirestore();
  }

  /// Save current profile state to Firestore
  Future<void> _saveToFirestore() async {
    if (state == null || state!.id == 'demo_user') return;

    try {
      await _firestore
          .collection('users')
          .doc(state!.id)
          .set(state!.toJson(), SetOptions(merge: true));
    } catch (e) {
      // Handle error silently or log
      debugPrint('Error saving profile: $e');
    }
  }

  /// Reload profile from Firestore
  Future<void> refresh() async {
    await _loadProfile();
  }
}
