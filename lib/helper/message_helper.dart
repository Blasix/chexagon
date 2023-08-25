import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void showErrorSnackbar(BuildContext context, String? message) {
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.error(
      message: message ?? 'An unknown error occurred. Please try again later.',
    ),
  );
}

void showSuccesSnackbar(BuildContext context, String message) {
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.success(
      message: message,
    ),
  );
}
