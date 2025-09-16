part of 'create_product_dialog.dart';

class WordChipTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final List<TextSpan> children = [];
    final regex = RegExp(r"(\S+\s)");

    final chipStyle = TextStyle(
      backgroundColor: Colors.green.withValues(alpha: 0.4),
      color: Colors.green.shade900,
      fontWeight: FontWeight.bold,
    );

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final wordWithSpace = match.group(0)!;
        final word = wordWithSpace.trim();

        children.add(
          TextSpan(text: word, style: chipStyle),
        );

        children.add(
          TextSpan(text: ' ', style: style),
        );

        return '';
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }
}
