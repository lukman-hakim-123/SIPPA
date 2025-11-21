import 'dart:io';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String imageUrl;
  final File? pickedImage;
  final VoidCallback onBack;

  const ProfileHeader({
    super.key,
    required this.imageUrl,
    required this.pickedImage,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Color(0xFF4FB2FF),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 60),
          child: Text(
            "Profil",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        Positioned(
          top: 50,
          left: 10,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
          ),
        ),

        Positioned(
          bottom: -45,
          left: 0,
          right: 0,
          child: CircleAvatar(
            radius: 53,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: pickedImage != null
                  ? ClipOval(
                      child: Image.file(
                        pickedImage!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    )
                  : ClipOval(
                      child: Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
