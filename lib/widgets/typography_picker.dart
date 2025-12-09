import 'package:flutter/material.dart';

class TypographyPicker extends StatelessWidget {
  final Color? selectedColor;
  final bool isBold;
  final bool isUnderline;
  final bool isItalic;
  final Function(Color?) onColorChanged;
  final VoidCallback onBoldToggle;
  final VoidCallback onUnderlineToggle;
  final VoidCallback onItalicToggle;

  const TypographyPicker({
    super.key,
    required this.selectedColor,
    required this.isBold,
    required this.isUnderline,
    required this.isItalic,
    required this.onColorChanged,
    required this.onBoldToggle,
    required this.onUnderlineToggle,
    required this.onItalicToggle,
  });

  // Available colors for notes
  static final List<Color?> noteColors = [
    null,
    Color(0xFFC4EFAC),
    Color(0xFF9FF2E1),
    Color(0xFFFFDAD7),
    Color(0xFFE6E762),
    Color(0xFFE74AC5),
    Colors.teal[300],
    Colors.cyan[300],
    Colors.blue[300],
    Colors.indigo[300],
    Colors.purple[300],
    Colors.pink[300],
  ];

  // Tag colors that match note colors
  static final List<Color> tagColors = [
    Color(0xFF9E9E9E), // Default gray for null note color
    Color(0xFF7CB342), // Green - Matches C4EFAC
    Color(0xFF26A69A), // Teal - Matches 9FF2E1
    Color(0xFFEF5350), // Red - Matches FFDAD7
    Color(0xFFFFA726), // Orange - Matches E6E762
    Color(0xFFAB47BC), // Purple - Matches E74AC5
    Color(0xFF00897B), // Dark Teal - Matches teal[300]
    Color(0xFF00ACC1), // Cyan - Matches cyan[300]
    Color(0xFF42A5F5), // Blue - Matches blue[300]
    Color(0xFF5C6BC0), // Indigo - Matches indigo[300]
    Color(0xFF7E57C2), // Deep Purple - Matches purple[300]
    Color(0xFFEC407A), // Pink - Matches pink[300]
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Тэмдэгтийн өнгө сонгох',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 5,
            alignment: WrapAlignment.center,
            children: List.generate(noteColors.length, (index) {
              final color = noteColors[index];
              final tagColor = tagColors[index];
              final isSelected = selectedColor == color;
              return GestureDetector(
                onTap: () {
                  onColorChanged(color);
                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color ?? Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color == null
                              ? Colors.grey
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: color == null
                                  ? Colors.black
                                  : Colors.white,
                              size: 28,
                            )
                          : (color == null
                                ? Icon(
                                    Icons.format_color_reset,
                                    color: Colors.grey[600],
                                  )
                                : null),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      child: const Text(
                        'Tag',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const Text(
            'Текстийн засах',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFormatButton(
                  icon: Icons.format_bold,
                  label: 'Bold',
                  isActive: isBold,
                  onTap: onBoldToggle,
                ),
                _buildFormatButton(
                  icon: Icons.format_underline,
                  label: 'Underline',
                  isActive: isUnderline,
                  onTap: onUnderlineToggle,
                ),
                _buildFormatButton(
                  icon: Icons.format_italic,
                  label: 'Italic',
                  isActive: isItalic,
                  onTap: onItalicToggle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF7C3AED) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Color(0xFF7C3AED) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
