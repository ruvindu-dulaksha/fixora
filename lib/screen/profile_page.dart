import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../state/app_state.dart';
import 'login_page.dart';

class _ProfileEditResult {
  const _ProfileEditResult({
    required this.name,
    required this.email,
    required this.profileImage,
    required this.currentPassword,
    required this.newPassword,
  });

  final String name;
  final String email;
  final String? profileImage;
  final String currentPassword;
  final String newPassword;
}

class _ProfileEditSheet extends StatefulWidget {
  const _ProfileEditSheet({
    required this.name,
    required this.email,
    required this.profileImage,
    required this.chooseImage,
  });

  final String name;
  final String email;
  final String? profileImage;
  final Future<String?> Function() chooseImage;

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late String? selectedImage = widget.profileImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> chooseImage() async {
    try {
      final image = await widget.chooseImage();
      if (image != null && mounted) setState(() => selectedImage = image);
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Photo access was denied. Enable Photos access in iPhone Settings > Fixora.',
          ),
        ),
      );
    }
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _ProfileEditResult(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        profileImage: selectedImage,
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit profile',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: CircleAvatar(
                radius: 42,
                backgroundImage: selectedImage == null
                    ? null
                    : MemoryImage(base64Decode(selectedImage!)),
                child: selectedImage == null
                    ? Text(
                        nameController.text.isEmpty
                            ? 'F'
                            : nameController.text[0].toUpperCase(),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: chooseImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose profile photo'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => value == null || value.trim().length < 3
                  ? 'Enter at least 3 characters'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) => value == null || !value.contains('@')
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password',
                prefixIcon: Icon(Icons.lock_reset_outlined),
                helperText: 'Leave blank to keep your password',
              ),
              validator: (value) => value!.isNotEmpty && value.length < 6
                  ? 'Use at least 6 characters'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
                prefixIcon: Icon(Icons.verified_user_outlined),
              ),
              validator: (value) =>
                  newPasswordController.text.isNotEmpty &&
                      value != newPasswordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: save, child: const Text('Save changes')),
          ],
        ),
      ),
    ),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AppState>().logout();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<String?> _chooseImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 600,
    );
    if (image == null) return null;
    return base64Encode(await image.readAsBytes());
  }

  Future<void> _editProfile(BuildContext context, AppState state) async {
    final result = await showModalBottomSheet<_ProfileEditResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProfileEditSheet(
        name: state.userName,
        email: state.userEmail,
        profileImage: state.profileImageBase64,
        chooseImage: _chooseImage,
      ),
    );
    if (result == null || !context.mounted) return;
    if (result.newPassword.isNotEmpty) {
      final passwordUpdated = await state.updatePassword(
        currentPassword: result.currentPassword,
        newPassword: result.newPassword,
      );
      if (!passwordUpdated) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Current password is incorrect.')),
          );
        }
        return;
      }
    }
    await state.updateProfile(name: result.name, email: result.email);
    await state.updateProfileImage(result.profileImage);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final image = state.profileImageBase64;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Profile',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 22),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _editProfile(context, state),
                    child: CircleAvatar(
                      radius: 34,
                      backgroundImage: image == null
                          ? null
                          : MemoryImage(base64Decode(image)),
                      child: image == null
                          ? Text(
                              state.userName.isEmpty
                                  ? 'F'
                                  : state.userName[0].toUpperCase(),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(state.userEmail),
                        Text(
                          state.isProviderMode
                              ? 'Provider mode'
                              : 'Customer mode',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => _editProfile(context, state),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit profile'),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Provider mode'),
            subtitle: const Text('Manage jobs as Kamal Perera'),
            value: state.isProviderMode,
            onChanged: (_) => state.toggleMode(),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        state.themeMode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Appearance',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.light_mode, size: 18),
                          label: const Text('Light mode'),
                          selected: state.themeMode == ThemeMode.light,
                          onSelected: (_) =>
                              state.setThemeMode(ThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.dark_mode, size: 18),
                          label: const Text('Dark mode'),
                          selected: state.themeMode == ThemeMode.dark,
                          onSelected: (_) => state.setThemeMode(ThemeMode.dark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
