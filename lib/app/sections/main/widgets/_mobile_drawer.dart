part of '../main_section.dart';

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollProvider = Provider.of<ScrollProvider>(context);
    // theme
    var theme = Theme.of(context);
    return Drawer(
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return Material(
            color: theme.scaffoldBackgroundColor,
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: NavBarLogo()),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      state.isDarkThemeOn
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode,
                      // color: theme.textColor,
                    ),
                    title:
                        Text(state.isDarkThemeOn ? "Light Mode" : "Dark Mode"),
                    trailing: Switch(
                      value: state.isDarkThemeOn,
                      activeColor: theme.primaryColor,
                      inactiveTrackColor: Colors.grey,
                      onChanged: (newValue) {
                        context.read<ThemeCubit>().updateTheme(newValue);
                      },
                    ),
                  ),
                  const Divider(),
                  ...NavBarUtils.names.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                            hoverColor: primaryColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onPressed: () {
                              // scrollProvider.scrollMobile(e.key);
                              scrollProvider.jumpTo(e.key, context);
                              Navigator.pop(context);
                            },
                            child: ListTile(
                              leading: Icon(
                                NavBarUtils.icons[e.key],
                                // color: theme.primaryColor,
                              ),
                              title: Text(
                                e.value,
                                // style: AppText.l1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  Space.y(5.w)!,
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      // Only show admin panel button when user is logged in
                      if (authProvider.isLoggedIn) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                            hoverColor: theme.primaryColor.withAlpha(70),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed('/admin');
                            },
                            child: ListTile(
                              leading: Icon(
                                Icons.admin_panel_settings,
                                color: theme.primaryColor,
                              ),
                              title: Text(
                                'ADMIN PANEL',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Hide admin login button - user can access via /admin/login directly
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                  Space.y(2.w)!,
                  Consumer<PublicDataProvider>(
                    builder: (context, dataProvider, child) {
                      return ColorChageButton(
                        text: 'RESUME',
                        onTap: () {
                          final resumeUrl = dataProvider.getContent('resume_url',
                              defaultValue: 'https://drive.google.com/file/d/11SKV1YlDUEJJq5B7JYAFjSi8k2nmp-HC/view?usp=sharing');
                          openURL(resumeUrl);
                        },
                      );
                    },
                  ),
                  Space.y(2.w)!,
                  Consumer<PublicDataProvider>(
                    builder: (context, dataProvider, child) {
                      return ListTile(
                        leading: const Icon(Icons.refresh),
                        title: const Text('Refresh Portfolio'),
                        onTap: () async {
                          Navigator.of(context).pop(); // Close drawer
                          await dataProvider.forceRefreshData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Portfolio data refreshed!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
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
