import 'package:flutter/material.dart';
import '../models/user_model.dart';

class RoleBasedWidget extends StatelessWidget {
  final User user;
  final Widget adminWidget;
  final Widget userWidget;

  const RoleBasedWidget({
    super.key,
    required this.user,
    required this.adminWidget,
    required this.userWidget,
  });

  @override
  Widget build(BuildContext context) {
    return user.isAdmin ? adminWidget : userWidget;
  }
}

