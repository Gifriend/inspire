import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'widgets/widgets.dart';

// MAIN SCREEN
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final profileState = ref.read(profileControllerProvider);
    if (profileState.maybeWhen(
        loaded: (_) => false, loading: () => false, orElse: () => true)) {
      ref.read(profileControllerProvider.notifier).loadProfile();
    }

    final announcementState = ref.read(announcementControllerProvider);
    if (announcementState.maybeWhen(
        loaded: (_) => false, loading: () => false, orElse: () => true)) {
      ref.read(announcementControllerProvider.notifier).loadAnnouncements();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final profileState = ref.watch(profileControllerProvider);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      disablePadding: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            profileState.maybeWhen(
              loaded: (user) => DashboardHeader(user: user),
              orElse: () => _buildHeaderPlaceholder(),
            ),
            
            // Menu Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
              child: Transform.translate(
                offset: Offset(0, BaseSize.h12),
                child: const MainMenuGrid(),
              ),
            ),

            Gap.h24,
            
            // Announcement Section
            const AnnouncementSection(),
            
            Gap.h72,
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderPlaceholder() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2.75,
      child: Container(
        decoration: BoxDecoration(
          color: BaseColor.primaryInspire,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(BaseSize.radiusXl),
            bottomRight: Radius.circular(BaseSize.radiusXl),
          ),
        ),
      ),
    );
  }
}
