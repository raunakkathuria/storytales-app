import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/features/authentication/domain/entities/user_profile.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_event.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_state.dart';

/// A screen where authenticated users can manage their profile settings.
class ProfileSettingsPage extends StatefulWidget {
  /// The user profile to display and edit.
  final UserProfile userProfile;

  /// Creates a new ProfileSettingsPage instance.
  ///
  /// [userProfile] - The user profile to display and edit.
  const ProfileSettingsPage({
    super.key,
    required this.userProfile,
  });

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  bool _isLoading = false;
  late UserProfile _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = widget.userProfile;
    _displayNameController = TextEditingController(text: _userProfile.displayName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = _userProfile.copyWith(
        displayName: _displayNameController.text.trim(),
      );

      context.read<AuthBloc>().add(UpdateProfile(
            userProfile: updatedProfile,
          ));
    }
  }

  void _signOut() {
    context.read<AuthBloc>().add(const SignOutUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }

          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile successfully updated'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.fixed,
              ),
            );
            setState(() {
              _userProfile = state.userProfile;
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile header with avatar
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: StoryTalesTheme.primaryColor.withValues(alpha: .2),
                          child: _userProfile.photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    _userProfile.photoUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: StoryTalesTheme.primaryColor,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: StoryTalesTheme.primaryColor,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userProfile.email,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Account information section
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Display name field
                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Enter your display name',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Account creation date
                  ListTile(
                    title: const Text('Account Created'),
                    subtitle: Text(
                      '${_userProfile.createdAt.day}/${_userProfile.createdAt.month}/${_userProfile.createdAt.year}',
                    ),
                    leading: const Icon(Icons.calendar_today),
                  ),

                  // Last login date
                  ListTile(
                    title: const Text('Last Login'),
                    subtitle: Text(
                      '${_userProfile.lastLoginAt.day}/${_userProfile.lastLoginAt.month}/${_userProfile.lastLoginAt.year}',
                    ),
                    leading: const Icon(Icons.access_time),
                  ),

                  const SizedBox(height: 32),

                  // Update profile button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StoryTalesTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Update Profile'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
