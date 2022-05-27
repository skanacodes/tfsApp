// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class AppBarActionItems extends StatefulWidget {
  final List? roles;
  final String? username;
  final String? checkpoint;
  final String? station;
  const AppBarActionItems(
      {Key? key, this.username, this.checkpoint, this.roles, this.station})
      : super(key: key);

  @override
  State<AppBarActionItems> createState() => _AppBarActionItemsState();
}

class _AppBarActionItemsState extends State<AppBarActionItems> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            icon: SvgPicture.asset(
              'assets/icons/calendar.svg',
              width: 20,
            ),
            onPressed: () {}),
        const SizedBox(width: 10),
        IconButton(
            icon: SvgPicture.asset('assets/icons/ring.svg', width: 20.0),
            onPressed: () {}),
        const SizedBox(width: 15),
        popBar()
      ],
    );
  }

  popBar() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: PopupMenuButton(
        tooltip: 'Menu',
        child: Row(children: [
          widget.roles!.contains("HQ Officer")
              ? const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage("assets/images/dos.jpg"),
                )
              : const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person_outline_outlined,
                    color: Colors.black,
                  ),
                  //backgroundImage: AssetImage("assets/images/dos.jpg"),
                ),
          const Icon(Icons.arrow_drop_down_outlined, color: Colors.black)
        ]),
        offset: const Offset(20, 40),
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () async {},
            child: Row(
              children: [
                Icon(
                  Icons.supervised_user_circle_outlined,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    widget.username!.toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () {
              //print("mail");
              setState(() {});
            },
            child: Row(
              children: [
                Icon(
                  Icons.landscape_outlined,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    widget.station.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () {
              setState(() {});
            },
            child: Row(
              children: [
                Icon(
                  Icons.work_outline_outlined,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    widget.roles.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
