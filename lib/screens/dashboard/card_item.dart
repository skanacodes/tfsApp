import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:tfsappv1/services/constants.dart';

class CardItem extends StatelessWidget {
  final String logo;
  final String holder;
  final String number;
  final String type;

  const CardItem(
      {Key? key,
      required this.logo,
      required this.number,
      required this.holder,
      required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 7, right: 5.5, top: 10, bottom: 10),
      child: FadeInUp(
        duration: const Duration(milliseconds: 900),
        child: Container(
          // height: 100,
          width: 200,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(10)),
              color: Colors.lightBlueAccent,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey[400]!,
                    offset: const Offset(2, 5),
                    blurRadius: 1,
                    spreadRadius: 1)
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  kPrimaryColor,
                  Colors.green[100]!,
                ],
              )),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 25,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProgressLine(
                  percentage: 90,
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                Text(
                  number,
                  style: kCardNumber.copyWith(
                      fontFamily: 'Ubuntu', color: Colors.white),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descr',
                          style: kCardHolder,
                        ),
                        Text(
                          holder,
                          style: kCardName,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    Key? key,
    this.color = kPrimaryColor,
    required this.percentage,
  }) : super(key: key);

  final Color? color;
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth * (percentage! / 100),
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
