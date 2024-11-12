import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class SearchField extends StatefulWidget {
  final void Function(String) onTextChanges;
  final String hintText;

  const SearchField({
    super.key,
    required this.onTextChanges,
    required this.hintText,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    _controller.addListener(() {
      widget.onTextChanges(_controller.text.trim());
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(
          horizontal: screenSize * 0.0131, vertical: screenSize * 0.00659),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, child) {
          return TextField(
            focusNode: _focusNode,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: screenSize * 0.0263,
                  vertical: screenSize * 0.0237),
              suffixIcon: IconButton(
                onPressed: () {
                  _controller.clear();
                },
                icon: Icon(
                  Icons.cancel,
                  color: _controller.text.isEmpty
                      ? Colors.grey.shade500
                      : textColor,
                ),
              ),
              hintText: widget.hintText,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        _focusNode.hasFocus ? textColor : Colors.grey.shade500,
                  ),
              border: border(
                gapPadding: 4.0,
                borderradius: BorderRadius.circular(screenSize * 0.0263),
                borderside: const BorderSide(),
              ),
              enabledBorder: border(
                gapPadding: 4.0,
                borderradius: BorderRadius.circular(screenSize * 0.0263),
                borderside: BorderSide(
                  width: 2,
                  color: Colors.grey.shade500,
                  style: BorderStyle.solid,
                ),
              ),
              focusedBorder: border(
                gapPadding: 4.0,
                borderradius: BorderRadius.circular(screenSize * 0.0263),
                borderside: BorderSide(
                  width: 2,
                  color: textColor,
                  style: BorderStyle.solid,
                ),
              ),
              focusedErrorBorder: border(
                gapPadding: 4.0,
                borderradius: BorderRadius.circular(screenSize * 0.0263),
                borderside: const BorderSide(
                  width: 2,
                  color: Colors.red,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            cursorColor: textColor,
            cursorHeight: screenSize * 0.0329,
            style: Theme.of(context).textTheme.bodyMedium,
            controller: _controller,
          );
        },
      ),
    );
  }
}

OutlineInputBorder border({
  required double gapPadding,
  required BorderRadius borderradius,
  required BorderSide borderside,
}) {
  return OutlineInputBorder(
    gapPadding: gapPadding,
    borderRadius: borderradius,
    borderSide: borderside,
  );
}
