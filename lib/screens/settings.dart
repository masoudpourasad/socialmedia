import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/landing/landing_page.dart';
import 'package:socialmedia/utils/firebase.dart';
import 'package:socialmedia/view_models/theme/theme_view_model.dart';

class Setting extends StatefulWidget {
  const Setting({super.key, this.profileId});
  final dynamic profileId;

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.keyboard_backspace),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.0,
        title: const Text(
          "Settings",
          style: TextStyle(),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            const ListTile(
              title: Text(
                "Account",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Manage your account"),
              trailing: Icon(Icons.account_circle),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                "Notification",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Manage your notification"),
              trailing: Icon(Icons.notifications),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                "Security",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Manage your security"),
              trailing: Icon(Icons.security),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                "Language",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Manage your language"),
              trailing: Icon(Icons.language),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                "Data and Storage",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Manage your data and storage"),
              trailing: Icon(Icons.data_usage),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                "Help and Support",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Manage your help and support"),
              trailing: Icon(Icons.help),
            ),
            const Divider(),
            const ListTile(
                title: Text(
                  "About",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  "A Fully Functional The Minimalist Application Made by masoud pourasad",
                ),
                trailing: Icon(Icons.error)),
            const Divider(),
            ListTile(
              title: const Text(
                "Dark Mode",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: const Text("Use the dark mode"),
              trailing: Consumer<ThemeProvider>(
                builder: (context, notifier, child) => CupertinoSwitch(
                  onChanged: (val) {
                    notifier.toggleTheme();
                  },
                  value: notifier.dark,
                  activeColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                "Privacy Policy",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Read our privacy policy"),
              trailing: Icon(Icons.privacy_tip),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                "Terms and Conditions",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Read our terms and conditions"),
              trailing: Icon(Icons.description),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                "Contact Us",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Contact us for any query"),
              trailing: Icon(Icons.contact_mail),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                "Rate Us",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Rate us on play store"),
              trailing: Icon(Icons.star),
            ),
            const Divider(),
            ListTile(
                title: const Text(
                  "Log Out",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: const Text(
                  "Log out from the application",
                ),
                trailing: const Icon(Icons.logout),
                onTap: () async {
                  widget.profileId == firebaseAuth.currentUser!.uid;
                  await firebaseAuth.signOut();
                  setState(() {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const Landing(),
                      ),
                    );
                  });
                }),
            const Divider(),
            const ListTile(
              title: Text(
                "Delete Account",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Delete your account"),
              trailing: Icon(Icons.delete),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
