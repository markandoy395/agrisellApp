import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/chat/presentation/buyer_conversation_launcher.dart';
import 'package:agresell_app/features/buyer/home/data/farmer_directory_repository.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_card.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_header.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_entrance_animation.dart';
part 'farmer_screen_components.dart';
part 'farmer_screen_controls.dart';
part 'farmer_screen_filtering.dart';
part 'farmer_screen_loading.dart';

enum _FarmerSort { recommended, rating, availability }

class FarmerScreen extends StatefulWidget {
  const FarmerScreen({
    this.farmerDirectoryRepository = const FarmerDirectoryRepository(),
    this.followController,
    super.key,
  });

  final FarmerDirectoryRepository farmerDirectoryRepository;
  final FarmerFollowController? followController;

  @override
  State<FarmerScreen> createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> {
  late final TextEditingController _searchController;
  late final ValueNotifier<String> _query;
  late final FarmerFollowController _followController;
  List<FarmerProfile> _farmers = const [];
  List<String> _locations = const [];
  Map<FarmerProfile, int> _availableProductCounts = const {};
  Map<FarmerProfile, String> _searchText = const {};
  bool _isLoading = true;
  bool _loadFailed = false;
  String? _selectedLocation;
  var _availableOnly = false;
  var _followingOnly = false;
  var _sort = _FarmerSort.recommended;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _query = ValueNotifier<String>('');
    _followController =
        widget.followController ?? FarmerFollowController.instance;
    unawaited(_loadFarmers());
  }

  void _setSort(_FarmerSort value) => setState(() => _sort = value);
  void _updateUi(VoidCallback update) => setState(update);

  @override
  void dispose() {
    _searchController.dispose();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 12.0 : 14.0;
    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: Column(
        children: [
          FarmerHeader(
            controller: _searchController,
            onQueryChanged: (value) => _query.value = value,
            onClear: _clearSearch,
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _followController,
              builder: (context, _) => ValueListenableBuilder<String>(
                valueListenable: _query,
                builder: (context, query, _) {
                  final farmers = _visibleFarmers(query);
                  final itemCount = _isLoading || _loadFailed || farmers.isEmpty
                      ? 3
                      : farmers.length * 2 + 1;
                  return CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16,
                          horizontalPadding,
                          138,
                        ),
                        sliver: SliverList.builder(
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _FarmerListControls(
                                resultCount: farmers.length,
                                availableOnly: _availableOnly,
                                followingOnly: _followingOnly,
                                selectedLocation: _selectedLocation,
                                locations: _locations,
                                sortLabel: _sortLabel(_sort),
                                onAvailableChanged: (value) {
                                  setState(() => _availableOnly = value);
                                },
                                onFollowingChanged: (value) {
                                  setState(() => _followingOnly = value);
                                },
                                onLocationChanged: (location) {
                                  setState(() => _selectedLocation = location);
                                },
                                onSort: _chooseSort,
                              );
                            }
                            if (index == 1) {
                              return const SizedBox(height: 14);
                            }
                            if (_isLoading) {
                              return const _FarmerLoading();
                            }
                            if (_loadFailed) {
                              return _FarmerLoadFailure(onRetry: _loadFarmers);
                            }
                            if (farmers.isEmpty) {
                              return _EmptyFarmerResults(onClear: _clearSearch);
                            }
                            final resultIndex = index - 2;
                            if (resultIndex.isOdd) {
                              return const SizedBox(height: 14);
                            }
                            final farmerIndex = resultIndex ~/ 2;
                            final sourceFarmer = farmers[farmerIndex];
                            final followState = _followController.stateFor(
                              sourceFarmer,
                            );
                            final farmer = sourceFarmer.copyWith(
                              followerCount: followState.followerCount,
                              isFollowing: followState.isFollowing,
                            );
                            return HomeEntranceAnimation(
                              key: ValueKey(farmer.name),
                              delay: Duration(
                                milliseconds: (80 * farmerIndex)
                                    .clamp(0, 320)
                                    .toInt(),
                              ),
                              offset: const Offset(0, 0.05),
                              child: FarmerCard(
                                farmer: farmer,
                                onChat: () => _openChat(farmer),
                                onTap: () => _openFarmerShop(farmer),
                                followController: _followController,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
