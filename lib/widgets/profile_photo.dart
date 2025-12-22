import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/extensions/photo/profile/image_cache_extension.dart';
import '../cubit/navigation/user/user_nav_bar_cubit.dart';
import '../cubit/photo/profile/profile_photo_cubit.dart';
import '../cubit/photo/profile/profile_photo_state.dart';
import '../utils/di/locator.dart';

class ProfilePhoto extends StatefulWidget {
  final double? radius;
  final bool openDrawerOnTap;

  const ProfilePhoto({
    super.key,
    this.radius,
    this.openDrawerOnTap = true,
  });

  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  late final ProfilePhotoCubit _cubit;
  Uint8List? _cachedImage;

  @override
  void initState() {
    super.initState();
    _cubit = locator<ProfilePhotoCubit>();

    _cachedImage = loadCachedImage();
    _cubit.getProfilePhoto();
  }

  @override
  Widget build(BuildContext context) {
    final double effectiveRadius = widget.radius ?? 24;

    return GestureDetector(
      onTap: () {
        if (widget.openDrawerOnTap) {
          Scaffold.of(context).openDrawer();
        } else {
          context.read<UserNavBarCubit>().goToSettingsPage();
        }
      },
      child: BlocProvider.value(
        value: _cubit,
        child: BlocBuilder<ProfilePhotoCubit, ProfilePhotoState>(
          builder: (context, state) {
            ImageProvider? imageProvider;

            if (state is ProfilePhotoLoaded) {
              imageProvider = MemoryImage(state.imageData);
            } else if (_cachedImage != null) {
              imageProvider = MemoryImage(_cachedImage!);
            }

            return CircleAvatar(
              radius: effectiveRadius,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? FaIcon(
                FontAwesomeIcons.user,
                color: Colors.grey.shade600,
                size: effectiveRadius * 0.9,
              )
                  : null,
            );
          },
        ),
      ),
    );
  }
}