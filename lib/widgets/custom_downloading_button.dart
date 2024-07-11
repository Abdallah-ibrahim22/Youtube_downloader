import 'package:flutter/material.dart';

class CustomDownloadingButton extends StatelessWidget {
  const CustomDownloadingButton(
      {super.key, required this.fn, required this.type, required this.quality});

  final VoidCallback fn;
  final IconData type;
  final String quality;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: GestureDetector(
        onTap: fn,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.blue[700],
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(type, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Download Audio $quality',
                style: TextStyle(
                    fontSize: quality.isEmpty ? 30 : 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
