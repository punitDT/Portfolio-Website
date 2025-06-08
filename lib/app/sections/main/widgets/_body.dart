part of '../main_section.dart';

class _Body extends StatefulWidget {
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with TickerProviderStateMixin {
  bool _isDragging = false;
  double _lastPanPosition = 0;
  double _velocity = 0;
  late AnimationController _momentumController;
  late Animation<double> _momentumAnimation;

  @override
  void initState() {
    super.initState();
    _momentumController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _momentumController.dispose();
    super.dispose();
  }

  void _startMomentumScroll(ScrollController controller, double velocity) {
    if (velocity.abs() < 50) return; // Minimum velocity threshold

    final startOffset = controller.offset;
    final targetOffset = startOffset + velocity * 0.5; // Momentum factor

    _momentumAnimation = Tween<double>(
      begin: startOffset,
      end: targetOffset.clamp(0.0, controller.position.maxScrollExtent),
    ).animate(CurvedAnimation(
      parent: _momentumController,
      curve: Curves.decelerate,
    ));

    _momentumAnimation.addListener(() {
      if (!_isDragging && controller.hasClients) {
        controller.jumpTo(_momentumAnimation.value);
      }
    });

    _momentumController.reset();
    _momentumController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final scrollProvider = Provider.of<ScrollProvider>(context);
    final dataProvider = Provider.of<PublicDataProvider>(context);

    return RefreshIndicator(
      onRefresh: () async {
        await dataProvider.forceRefreshData();
      },
      child: MouseRegion(
        cursor: _isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
        child: GestureDetector(
          onPanStart: (details) {
            setState(() {
              _isDragging = true;
            });
            _lastPanPosition = details.globalPosition.dy;
            _velocity = 0;
            _momentumController.stop(); // Stop any ongoing momentum
          },
          onPanUpdate: (details) {
            if (_isDragging && scrollProvider.scrollController.hasClients) {
              final delta = _lastPanPosition - details.globalPosition.dy;
              _velocity = delta; // Track velocity for momentum
              _lastPanPosition = details.globalPosition.dy;

              // Apply drag scrolling with sensitivity
              final currentOffset = scrollProvider.scrollController.offset;
              final newOffset = currentOffset + (delta * 1.2); // Sensitivity multiplier

              scrollProvider.scrollController.jumpTo(
                newOffset.clamp(
                  0.0,
                  scrollProvider.scrollController.position.maxScrollExtent,
                ),
              );
            }
          },
          onPanEnd: (details) {
            setState(() {
              _isDragging = false;
            });
            // Add momentum scrolling based on final velocity
            if (scrollProvider.scrollController.hasClients) {
              _startMomentumScroll(scrollProvider.scrollController, _velocity);
            }
          },
          child: SingleChildScrollView(
            controller: scrollProvider.scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: BodyUtils.views,
            ),
          ),
        ),
      ),
    );
  }
}
