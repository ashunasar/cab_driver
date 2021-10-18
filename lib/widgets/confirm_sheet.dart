import 'package:cab_driver/widgets/taxi_button.dart';
import 'package:cab_driver/widgets/taxi_outline_button.dart';
import 'package:flutter/material.dart';

import '../brand_colors.dart';

class ConfirmSheet extends StatelessWidget {
  final String title;
  final String subTitle;
  final Function onPressed;
  ConfirmSheet({this.title, this.subTitle, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15.0,
            spreadRadius: 0.5,
            offset: Offset(0.7, 0.7),
          ),
        ],
      ),
      height: 220,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Brand-Bold',
                color: BrandColors.colorText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              subTitle,
              style: TextStyle(
                color: BrandColors.colorTextLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TaxiOutlineButton(
                    title: 'BACK',
                    color: BrandColors.colorLightGrayFair,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TaxiButton(
                      title: 'CONFIRM',
                      color: title == "GO ONLINE"
                          ? BrandColors.colorGreen
                          : Colors.red,
                      onPressed: onPressed),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
