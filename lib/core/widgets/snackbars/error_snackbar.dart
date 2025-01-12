import 'package:flutter/material.dart';

SnackBar errorSnackbar(BuildContext context, String text) => SnackBar(
      backgroundColor: Theme.of(context).errorColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      content: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
      ),
    );
