import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../clippers/top_pattern_clipper.dart';

class RenameFileDialog extends StatefulWidget {
  final String initialName;
  final ValueChanged<String> onRename;
  final Color accentColor;

  const RenameFileDialog({
    super.key,
    required this.initialName,
    required this.onRename,
    this.accentColor = Colors.amber,
  });

  @override
  State<RenameFileDialog> createState() => _RenameFileDialogState();
}

class _RenameFileDialogState extends State<RenameFileDialog> {
  late TextEditingController _controller;
  late String _extension; // store extension separately

  @override
  void initState() {
    super.initState();

    // Extract extension (e.g., ".pdf") from the file name
    final dotIndex = widget.initialName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex != widget.initialName.length - 1) {
      _extension = widget.initialName.substring(dotIndex); // includes the dot
      _controller =
          TextEditingController(text: widget.initialName.substring(0, dotIndex));
    } else {
      _extension = '';
      _controller = TextEditingController(text: widget.initialName);
    }
  }

  void _save() {
    final baseName = _controller.text.trim();

    if (baseName.isEmpty) return;

    // Ensure we don't double-append extension
    String finalName = baseName.endsWith(_extension)
        ? baseName
        : baseName + _extension;

    widget.onRename(finalName);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main dialog container
          Container(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0F2C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 60),
                TextField(
                  controller: _controller,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'File Name',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1A1F3F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixText: _extension, // show extension but not editable
                    suffixStyle:
                    GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        label: Text('Cancel',
                            style: GoogleFonts.poppins(color: Colors.white70)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: widget.accentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text('Save',
                            style: GoogleFonts.poppins(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top clipped header
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopPatternClipper(),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Rename File',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
