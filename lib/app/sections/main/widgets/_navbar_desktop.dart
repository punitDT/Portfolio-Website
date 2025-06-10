part of '../main_section.dart';

class _NavbarDesktop extends StatefulWidget {
  const _NavbarDesktop({Key? key}) : super(key: key);

  @override
  State<_NavbarDesktop> createState() => _NavbarDesktopState();
}

class _NavbarDesktopState extends State<_NavbarDesktop> {


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // theme
    var theme = Theme.of(context);
    return BlocBuilder<ThemeCubit, ThemeState>(builder: (context, state) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: ResponsivePadding.getHorizontalPadding(size.width), vertical: 16),
        decoration: BoxDecoration(
          color: theme.navBarColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border(
            bottom: BorderSide(
              color: Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            const NavBarLogo(),
            Space.xm!,
            ...NavBarUtils.names.asMap().entries.map(
                  (e) => NavBarActionButton(
                    label: e.value,
                    index: e.key,
                  ),
                ),
            const SizedBox(width: 16),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                // Only show admin button when user is logged in
                if (authProvider.isLoggedIn) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('/admin');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
            const SizedBox(width: 16),
            Consumer<PublicDataProvider>(
              builder: (context, dataProvider, child) {
                return InkWell(
                  onTap: () async {
                    await dataProvider.forceRefreshData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Portfolio data refreshed!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.textColor.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: theme.textColor,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            InkWell(
                onTap: () {
                  context.read<ThemeCubit>().updateTheme(!state.isDarkThemeOn);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.textColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    state.isDarkThemeOn ? Icons.dark_mode : Icons.light_mode,
                    color: theme.textColor,
                    size: 20,
                  ),
                )),
          ],
        ),
      );
    });
  }
}

class _NavBarTablet extends StatelessWidget {
  const _NavBarTablet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerProvider = Provider.of<DrawerProvider>(context);
    var theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.navBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.isTablet(context) ? 10.w : 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            highlightColor: Colors.white54,
            onPressed: () {
              drawerProvider.key.currentState!.openDrawer();
            },
            icon: const Icon(Icons.menu),
          ),
          Space.xm!,
          const NavBarLogo(),
          // Space.x1!,
        ],
      ),
    );
  }
}
