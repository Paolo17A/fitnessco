import 'package:flutter/material.dart';

import '../utils/log_out_util.dart';

AppBar homeAppBar(BuildContext context, {Widget? title}) {
  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0,
    title: title,
    actions: [
      Transform.scale(
        scale: 1.5,
        child: IconButton(
            onPressed: () => showLogOutModal(context),
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.black,
            )),
      )
    ],
  );
}
