import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePic extends StatelessWidget {

  final String? profileImageUrl;

   const ProfilePic({
    Key? key,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
           CircleAvatar(
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl!) // Use profile image URL if available
                : AssetImage("./images/ProfileImage.png"), // Use default image if profile image URL is not available
          ),
          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: () {},
                child: SvgPicture.asset("./icons/CameraIcon.svg"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
