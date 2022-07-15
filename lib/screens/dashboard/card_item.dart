import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:tfsappv1/services/constants.dart';

class CardItem extends StatefulWidget {
  final String logo;
  final String holder;
  final String number;
  final String type;
  final int ratio;
  final Color color;

  const CardItem(
      {Key? key,
      required this.logo,
      required this.number,
      required this.holder,
      required this.ratio,
      required this.color,
      required this.type})
      : super(key: key);

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
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
              borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                Text("Total   ${widget.logo}",
                    style: const TextStyle(color: Colors.white)),
                Text(widget.number,
                    style: const TextStyle(color: Colors.black)),
                // const SizedBox(height: 10),
                ProgressLine(percentage: widget.ratio, color: widget.color),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.logo}  Revenue",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            formatNumber.format(double.parse(widget.holder)),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
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
