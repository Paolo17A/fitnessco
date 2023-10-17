import 'package:dropdown_search/dropdown_search.dart';
import 'package:fitnessco/utils/color_utils.dart';
import 'package:flutter/material.dart';

Widget dropdownWidget(
    String selectedOption,
    Function(String?) onDropdownValueChanged,
    List<String> dropdownItems,
    String label,
    bool searchable,
    {double? padding = 8}) {
  return Padding(
    padding: EdgeInsets.all(padding != null ? padding : 0),
    child: DropdownSearch<String>(
        popupProps: PopupProps.menu(
            showSelectedItems: true,
            showSearchBox: searchable,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                  alignLabelWithHint: true,
                  hintText: '${label.toLowerCase()}',
                  labelStyle: TextStyle(
                    color: CustomColors.purpleSnail,
                  ),
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
            )),
        items: dropdownItems,
        onChanged: onDropdownValueChanged,
        selectedItem: label),
  );
}
