import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../search/search_screen.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        onTap: () {
          Navigator.pushNamed(context, SearchScreen.routeName);
        },
        readOnly: true,
        onChanged: (value) {},
        decoration: InputDecoration(
          filled: true,
          fillColor: kSecondaryColor.withAlpha((0.1 * 255).round()),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: searchOutlineInputBorder,
          focusedBorder: searchOutlineInputBorder,
          enabledBorder: searchOutlineInputBorder,
          hintText: "Search product",
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

const searchOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide.none,
);

