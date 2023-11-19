import 'package:flutter/material.dart';

import '../utils/log_out_util.dart';

AppBar homeAppBar(BuildContext context, {Widget? title, Function? onRefresh}) {
  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0,
    title: title,
    leading: onRefresh != null
        ? IconButton(
            onPressed: () => onRefresh(),
            icon: Image.asset('assets/images/icons/refresh.png'))
        : null,
    actions: [
      IconButton(
          onPressed: () => showLogOutModal(context),
          icon: Image.asset('assets/images/icons/logout.png'))
    ],
  );
}
