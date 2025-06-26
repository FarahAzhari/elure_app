import 'package:elure_app/models/api_models.dart';
import 'package:elure_app/screens/admin/admin_dashboard_screen.dart';
import 'package:elure_app/screens/auth/auth_screen.dart';
import 'package:elure_app/services/local_storage_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryPink = Color(0xFFE91E63);
  bool _notificationEnabled = true; // State for the notification toggle

  // Instance of LocalStorageService to retrieve user data and handle logout
  final LocalStorageService _localStorageService = LocalStorageService();

  // State to hold the logged-in user's data
  User? _loggedInUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the screen initializes
  }

  // Function to load user data from local storage
  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUser = true;
    });
    try {
      final user = await _localStorageService.getUserData();
      setState(() {
        _loggedInUser = user;
        _isLoadingUser = false;
      });
      print('User data loaded: ${_loggedInUser?.name}');
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
      print('Error loading user data: $e');
    }
  }

  // Function to handle logout
  Future<void> _handleLogout() async {
    print('Attempting to log out...');
    await _localStorageService.clearAllData(); // Clear all user-related data
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out successfully!')));
    // Navigate to AuthScreen and remove all previous routes from the stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light grey background for the screen
      appBar: _buildAppBar(context),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator(color: primaryPink))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // User Profile Card
                  _buildProfileCard(),
                  const SizedBox(height: 30),

                  // General Section
                  _buildSectionTitle('General'),
                  const SizedBox(height: 10),
                  _buildSettingsList([
                    _buildSettingsItem(
                      icon: Icons.credit_card_outlined,
                      title: 'Payment method',
                      onTap: () => print('Payment method tapped'),
                    ),
                    _buildSettingsItem(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      onTap: () => print('Location tapped'),
                    ),
                    _buildSettingsItem(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      onTap: () => print('Language tapped'),
                    ),
                    _buildSettingsItem(
                      icon: Icons.notifications_none_outlined,
                      title: 'Notification',
                      trailing: Switch(
                        value: _notificationEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _notificationEnabled = value;
                          });
                          print('Notification toggled: $value');
                        },
                        activeColor: primaryPink, // Pink when on
                      ),
                      onTap: () {
                        // Toggling the switch directly is usually preferred for switches
                        // If you tap the row, you might toggle the switch
                        setState(() {
                          _notificationEnabled = !_notificationEnabled;
                        });
                      },
                    ),
                  ]),
                  const SizedBox(height: 30),

                  // Admin Section (conditionally displayed)
                  if (_loggedInUser?.email ==
                      'admin@mail.com') // Check for admin email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Admin'),
                        const SizedBox(height: 10),
                        _buildSettingsList([
                          _buildSettingsItem(
                            icon: Icons.dashboard_outlined,
                            title: 'Admin Dashboard',
                            onTap: () {
                              print('Admin Dashboard tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminDashboardScreen(),
                                ),
                              );
                            },
                          ),
                        ]),
                        const SizedBox(height: 30),
                      ],
                    ),

                  // Support Section
                  _buildSectionTitle('Support'),
                  const SizedBox(height: 10),
                  _buildSettingsList([
                    _buildSettingsItem(
                      icon: Icons.chat_bubble_outline,
                      title: 'Feedback',
                      onTap: () => print('Feedback tapped'),
                    ),
                    _buildSettingsItem(
                      icon: Icons.share_outlined,
                      title: 'Share',
                      onTap: () => print('Share tapped'),
                    ),
                    _buildSettingsItem(
                      icon: Icons.help_outline,
                      title: 'Help',
                      onTap: () => print('Help tapped'),
                    ),
                  ]),
                  const SizedBox(height: 30),

                  // Log Out Button
                  _buildSettingsList([
                    _buildSettingsItem(
                      icon: Icons.logout,
                      title: 'Log Out',
                      onTap: _handleLogout, // Call the logout handler
                      isLogout:
                          true, // Indicate this is a logout button for different styling
                    ),
                  ]),
                  const SizedBox(height: 20), // Padding at bottom
                ],
              ),
            ),
    );
  }

  // Custom AppBar for the Profile Screen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.notifications_none_outlined,
            color: Colors.grey[700],
            size: 28,
          ),
          onPressed: () {
            print('Notifications Tapped from Profile Screen');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  // Builds the user profile card at the top
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(
              'https://placehold.co/100x100/FFC0CB/000000?text=JW',
            ), // Placeholder for Jenny Wilson
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _loggedInUser?.name ??
                      'Guest User', // Display actual user name
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _loggedInUser?.email ??
                      'guest@example.com', // Display actual user email
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.grey[700]),
            onPressed: () {
              print('Edit profile tapped');
              // Navigate to edit profile screen
            },
          ),
        ],
      ),
    );
  }

  // Helper for section titles (General, Support)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // Helper for grouping settings items in a rounded card
  Widget _buildSettingsList(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          return Column(
            children: [
              items[index],
              if (index <
                  items.length - 1) // Add divider except for the last item
                Divider(
                  indent: 60, // Indent the divider as per design
                  endIndent: 16,
                  color: Colors.grey[200],
                  height: 1,
                ),
            ],
          );
        }),
      ),
    );
  }

  // Helper for individual settings item (Payment method, Location, etc.)
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors
          .transparent, // Make Material transparent so Container decoration shows
      child: InkWell(
        // Provides ripple effect on tap
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          20,
        ), // Match container's border radius
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLogout
                      ? primaryPink.withOpacity(0.1)
                      : Colors
                            .grey[100], // Pink tint for logout icon background
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isLogout
                      ? primaryPink
                      : Colors.grey[700], // Pink icon for logout
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isLogout
                        ? primaryPink
                        : Colors.black, // Pink text for logout
                  ),
                ),
              ),
              if (trailing != null)
                trailing
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
